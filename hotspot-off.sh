#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Config
HOTSPOT_IFACE=$(nmcli device status | awk '$2 == "wifi" {print $1; exit}')
NFT_TABLE="nekoray_hotspot"

# Parse arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}🧪 Running in dry-run mode — no changes will be made.${NC}"
fi

# Define safe run function
run_cmd() {
    if $DRY_RUN; then
        echo -e "${BLUE}→ $*${NC}"
    else
        eval "$@"
    fi
}

echo -e "\n${GREEN}✅ Stopping hotspot...${NC}"
run_cmd "nmcli connection down Hotspot 2>/dev/null || true"
run_cmd "nmcli connection delete Hotspot 2>/dev/null || true"

echo -e "${GREEN}✅ Removing nftables table...${NC}"
run_cmd "sudo nft delete table ip $NFT_TABLE 2>/dev/null || true"

echo -e "\n${BOLD}${GREEN}✔ Hotspot stopped and nftables rules removed.${NC}\n"
