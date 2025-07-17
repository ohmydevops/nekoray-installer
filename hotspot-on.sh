#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Config
SSID="ohmynekoray"
TUN_IFACE="nekoray-tun"
NFT_TABLE="nekoray_hotspot"
REQUIRED_INET_TABLE="sing-box"

# Parse arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}🧪 Running in dry-run mode — no changes will be made.${NC}"
fi

# Safe command runner
run_cmd() {
    if $DRY_RUN; then
        echo -e "${BLUE}→ $*${NC}"
    else
        eval "$@"
    fi
}

echo -e "\n${GREEN}🚀 Starting Nekoray Hotspot...${NC}"

# Check nmcli
if ! command -v nmcli &>/dev/null; then
    echo -e "${RED}❌ 'nmcli' not found. Please install NetworkManager.${NC}"
    echo -e "   Debian/Ubuntu: sudo apt install network-manager"
    echo -e "   Fedora:        sudo dnf install NetworkManager"
    echo -e "   Arch:          sudo pacman -S networkmanager"
    exit 1
fi

# Detect Wi-Fi interface
HOTSPOT_IFACE=$(nmcli device status | awk '$2 == "wifi" {print $1; exit}')
if [ -z "$HOTSPOT_IFACE" ]; then
    echo -e "${RED}❌ No Wi-Fi interface found. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Wi-Fi interface: ${BOLD}$HOTSPOT_IFACE${NC}"

# Check required nftables table
if ! sudo nft list table inet "$REQUIRED_INET_TABLE" &>/dev/null; then
    echo -e "${RED}❌ Missing 'inet $REQUIRED_INET_TABLE' nftables table.${NC}"
    echo -e "   Please enable 'Tun Mode' in Nekoray GUI settings."
    exit 1
fi

# Get passwrod from user
while true; do
    read -rsp $'\n🔒 Enter hotspot password (min 8 chars): ' PASSWORD
    echo
    if [ ${#PASSWORD} -ge 8 ]; then
        break
    else
        echo -e "${RED}❌ Password must be at least 8 characters.${NC}"
    fi
done

echo -e "${GREEN}✅ Enabling Wi-Fi...${NC}"
run_cmd "nmcli radio wifi on"

echo -e "${GREEN}✅ Starting hotspot...${NC}"
if ! $DRY_RUN && ! nmcli dev wifi hotspot ifname "$HOTSPOT_IFACE" ssid "$SSID" password "$PASSWORD"; then
    echo -e "${RED}❌ Failed to start hotspot — maybe AP mode is unsupported.${NC}"
    exit 1
elif $DRY_RUN; then
    echo -e "${BLUE}→ nmcli dev wifi hotspot ifname \"$HOTSPOT_IFACE\" ssid \"$SSID\" password \"********\"${NC}"
fi

echo -e "${GREEN}✅ Setting up nftables rules...${NC}"
run_cmd "sudo nft delete table ip $NFT_TABLE 2>/dev/null || true"
run_cmd "sudo nft add table ip $NFT_TABLE"
run_cmd "sudo nft add chain ip $NFT_TABLE postrouting { type nat hook postrouting priority srcnat\; policy accept\; }"
run_cmd "sudo nft add rule ip $NFT_TABLE postrouting oifname \"$TUN_IFACE\" masquerade"
run_cmd "sudo nft add chain ip $NFT_TABLE forward { type filter hook forward priority filter\; policy accept\; }"
run_cmd "sudo nft add rule ip $NFT_TABLE forward iifname \"$HOTSPOT_IFACE\" oifname \"$TUN_IFACE\" accept"
run_cmd "sudo nft add rule ip $NFT_TABLE forward iifname \"$TUN_IFACE\" oifname \"$HOTSPOT_IFACE\" ct state established,related accept"

echo -e "\n${BOLD}${GREEN}✔ Hotspot is ready and running!${NC}\n"

if $DRY_RUN; then
    echo -e "${BLUE}→ nmcli dev wifi show-password${NC}"
else
    nmcli dev wifi show-password
fi
