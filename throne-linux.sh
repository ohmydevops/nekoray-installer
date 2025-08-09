#!/bin/bash
set -euo pipefail

# Configuration
THRONE_URL="https://api.github.com/repos/throneproj/Throne/releases/latest"
THRONE_FILE_NAME="Throne"
THRONE_DESKTOP_FILE="$HOME/.local/share/applications/throne.desktop"
WGET_TIMEOUT=15
TMPDIR=$(mktemp -d)

# Hotspot Configuration
SSID="ohmythrone"
TUN_IFACE="nekoray-tun"
NFT_TABLE="throne_hotspot"
REQUIRED_INET_TABLE="sing-box"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Display banner
show_banner() {
  echo -e "${YELLOW}"
  cat <<EOF



████████╗██╗  ██╗██████╗  ██████╗ ███╗   ██╗███████╗
╚══██╔══╝██║  ██║██╔══██╗██╔═══██╗████╗  ██║██╔════╝
   ██║   ███████║██████╔╝██║   ██║██╔██╗ ██║█████╗
   ██║   ██╔══██║██╔══██╗██║   ██║██║╚██╗██║██╔══╝
   ██║   ██║  ██║██║  ██║╚██████╔╝██║ ╚████║███████╗
   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝



EOF
  echo -e "${NC}"
  echo -e "${BLUE}$THRONE_APP_NAME Installer for macOS${NC}\n\n\n"
}

# Show main menu
show_menu() {
  echo -e "${YELLOW}Please select an option:${NC}"
  echo "1) Install Throne"
  echo "2) Backup configuration"
  echo "3) Restore configuration"
  echo "4) Uninstall"
  echo "5) Enable Hotspot"
  echo "6) Disable Hotspot"
  echo "7) Exit"
  echo
}

# Function to get app name from user
get_app_name() {
  read -rp "👉 Enter which app (nekoray, throne): " APP_NAME
  APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')

  if [[ "$APP_NAME" != "nekoray" && "$APP_NAME" != "throne" ]]; then
    echo -e "${RED}Invalid app name. Only 'nekoray' or 'throne' allowed.${NC}"
    exit 1
  fi
}

# Safe command runner for hotspot operations
run_cmd() {
    local dry_run=${1:-false}
    shift
    if $dry_run; then
        echo -e "${BLUE}→ $*${NC}"
    else
        eval "$@"
    fi
}

# Install function
install_app() {
  echo -e "${BLUE}=== INSTALLATION ===${NC}\n"

  # Check if already installed
  if dpkg -l | grep -q "throne" 2>/dev/null || rpm -q throne 2>/dev/null; then
    echo -e "${YELLOW}Throne is already installed on your system.${NC}"
    echo -e "${YELLOW}Please uninstall it first using your package manager.${NC}\n"
    return 0
  fi

  # Detect Linux distribution
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
  else
    echo -e "${RED}Cannot detect Linux distribution.${NC}"
    exit 1
  fi

  # Determine package type and manager based on distribution
  case "$DISTRO" in
    ubuntu|debian|linuxmint|pop)
      PACKAGE_TYPE="deb"
      PACKAGE_MANAGER="dpkg"
      INSTALL_CMD="sudo dpkg -i"
      FIX_DEPS_CMD="sudo apt-get install -f -y"
      PACKAGE_PATTERN="Throne.*debian.*\.deb"
      ;;
    fedora|rhel|centos|rocky|almalinux)
      PACKAGE_TYPE="rpm"
      PACKAGE_MANAGER="rpm"
      INSTALL_CMD="sudo rpm -i"
      FIX_DEPS_CMD="sudo dnf install -y"
      PACKAGE_PATTERN="Throne.*\.el.*\.rpm"
      ;;
    *)
      echo -e "${RED}Unsupported distribution: $DISTRO${NC}"
      echo -e "${RED}Supported distributions: Ubuntu, Debian, Fedora, RHEL, CentOS${NC}"
      exit 1
      ;;
  esac

  # Check for required commands
  for cmd in wget $PACKAGE_MANAGER; do
    if ! command -v $cmd &> /dev/null; then
      echo -e "${RED}$cmd is not installed.${NC}"
      echo -e "${RED}Install $cmd in your system.${NC}"
      case "$DISTRO" in
        ubuntu|debian|linuxmint|pop)
          echo -e "${RED}For example: sudo apt install $cmd${NC}"
          ;;
        fedora|rhel|centos|rocky|almalinux)
          echo -e "${RED}For example: sudo dnf install $cmd${NC}"
          ;;
      esac
      exit 1
    fi
  done

  echo -e "Fetching latest Throne release information..."

  # Get the latest release info and find the appropriate package URL
  RELEASE_INFO=$(wget --timeout=$WGET_TIMEOUT -q -O- $THRONE_URL)
  PACKAGE_URL=$(echo "$RELEASE_INFO" | grep -E "browser_download_url.*$PACKAGE_PATTERN" | head -1 | cut -d '"' -f 4)

  if [ -z "$PACKAGE_URL" ]; then
    echo -e "${RED}Could not find $PACKAGE_TYPE package in the latest release.${NC}"
    echo -e "${RED}Available packages:${NC}"
    echo "$RELEASE_INFO" | grep "browser_download_url" | cut -d '"' -f 4 | sed 's/.*\///g'
    exit 1
  fi

  PACKAGE_NAME=$(basename "$PACKAGE_URL")
  echo -e "Downloading $PACKAGE_NAME..."

  # Download the package
  wget --timeout=$WGET_TIMEOUT -q --show-progress --progress=bar:force -O "$TMPDIR/$PACKAGE_NAME" "$PACKAGE_URL"

  echo -e "Installing Throne $PACKAGE_TYPE package..."

  # Install the package
  if $INSTALL_CMD "$TMPDIR/$PACKAGE_NAME"; then
    echo -e "${GREEN}✅ Throne installed successfully!${NC}"
  else
    echo -e "${YELLOW}Installation completed with some warnings. Fixing dependencies...${NC}"
    $FIX_DEPS_CMD
  fi

  # Clean up
  rm "$TMPDIR/$PACKAGE_NAME"

  echo -e "\n${GREEN}✅ Done! Throne has been installed system-wide. You can find it in your applications menu!${NC}\n"
}

# Backup function
backup_config() {
  echo -e "${BLUE}=== BACKUP CONFIGURATION ===${NC}\n"

  get_app_name

  CONFIG_DIR=""
  # Check for both old NekoRay and new Throne configs
  if [[ "$APP_NAME" == "nekoray" ]]; then
    # Support both old and new paths for NekoRay
    if [ -d "$HOME/nekoray/nekoray/config" ]; then
      CONFIG_DIR="$HOME/nekoray/nekoray/config"
    elif [ -d "$HOME/NekoRay/nekoray/config" ]; then
      CONFIG_DIR="$HOME/NekoRay/nekoray/config"
    fi
  elif [[ "$APP_NAME" == "throne" ]]; then
    # New Throne path
    if [ -d "$HOME/Throne/nekoray/config" ]; then
      CONFIG_DIR="$HOME/Throne/nekoray/config"
    elif [ -d "$HOME/throne/throne/config" ]; then
      CONFIG_DIR="$HOME/throne/throne/config"
    fi
  fi
  BACKUP_NAME="${APP_NAME}-backup-$(date +%Y-%m-%d).zip"
  DEST_DIR="$(pwd)"

  if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}Config directory does not exist: $CONFIG_DIR${NC}"
    exit 1
  fi

  if ! command -v zip &> /dev/null; then
    echo -e "${RED}Missing 'zip'. Install it with:${NC}"
    echo -e "${RED}  Debian/Ubuntu: sudo apt install zip${NC}"
    echo -e "${RED}  Fedora: sudo dnf install zip${NC}"
    echo -e "${RED}  Arch: sudo pacman -S zip${NC}"
    exit 1
  fi

  echo "📦 Compressing config ..."
  echo "Compressing config from $CONFIG_DIR..."
  (cd "$CONFIG_DIR" && zip -rq "$DEST_DIR/$BACKUP_NAME" .)

  echo -e "${GREEN}✅ Backup created:${NC}"
  echo -e "${GREEN}$DEST_DIR/$BACKUP_NAME${NC}\n"
}

# Restore function
restore_config() {
  echo -e "${BLUE}=== RESTORE CONFIGURATION ===${NC}\n"

  read -rp "Enter the path to the backup .zip file: " ZIP_FILE

  if [[ -z "$ZIP_FILE" ]]; then
    echo -e "${RED}Please provide the path to the backup .zip file.${NC}"
    exit 1
  fi

  if [[ ! -f "$ZIP_FILE" ]]; then
    echo -e "${RED}File not found: $ZIP_FILE${NC}"
    exit 1
  fi

  get_app_name

  RESTORE_DIR=""
  # Determine restore directory based on app name and what's installed
  if [[ "$APP_NAME" == "nekoray" ]]; then
    # For NekoRay, check if new Throne is installed and use that, otherwise use old path
    if [ -d "$HOME/Throne" ]; then
      RESTORE_DIR="$HOME/Throne/nekoray/config"
      echo "Note: Restoring NekoRay backup to Throne installation"
    elif [ -d "$HOME/NekoRay" ]; then
      RESTORE_DIR="$HOME/NekoRay/nekoray/config"
    else
      RESTORE_DIR="$HOME/nekoray/nekoray/config"
    fi
  elif [[ "$APP_NAME" == "throne" ]]; then
    # For Throne, use the new path
    if [ -d "$HOME/Throne" ]; then
      RESTORE_DIR="$HOME/Throne/nekoray/config"
    else
      RESTORE_DIR="$HOME/throne/throne/config"
    fi
  fi

  if ! command -v unzip &> /dev/null; then
    echo -e "${RED}'unzip' is required. Install it with:${NC}"
    echo -e "${RED}  Debian/Ubuntu: sudo apt install unzip${NC}"
    echo -e "${RED}  Fedora: sudo dnf install unzip${NC}"
    echo -e "${RED}  Arch: sudo pacman -S unzip${NC}"
    exit 1
  fi

  if [[ -d "$RESTORE_DIR" ]]; then
    echo "Removing existing config: $RESTORE_DIR"
    rm -rf "$RESTORE_DIR"
  fi

  mkdir -p "$RESTORE_DIR"

  echo "📦 Restoring backup to: $RESTORE_DIR"
  unzip -q "$ZIP_FILE" -d "$RESTORE_DIR"

  echo -e "${GREEN}✅ Restore complete!${NC}\n"
}

# Uninstall function
uninstall_app() {
  echo -e "${BLUE}=== UNINSTALL ===${NC}\n"

  # Check for package installations first
  PACKAGE_INSTALLED=false
  if dpkg -l | grep -q "throne" 2>/dev/null; then
    echo "Removing Throne .deb package..."
    sudo dpkg -r throne
    PACKAGE_INSTALLED=true
  elif rpm -q throne 2>/dev/null; then
    echo "Removing Throne .rpm package..."
    sudo rpm -e throne
    PACKAGE_INSTALLED=true
  fi

  # Check for legacy directory installations
  LEGACY_FOUND=false

  # Check for various possible legacy installation directories
  LEGACY_DIRS=(
    "$HOME/Throne"
    "$HOME/throne"
    "$HOME/NekoRay"
    "$HOME/nekoray"
  )

  LEGACY_DESKTOPS=(
    "$HOME/.local/share/applications/throne.desktop"
    "$HOME/.local/share/applications/nekoray.desktop"
  )

  echo "Checking for legacy installations..."

  # Check and remove legacy app directories
  for LEGACY_DIR in "${LEGACY_DIRS[@]}"; do
    if [ -d "$LEGACY_DIR" ]; then
      echo "Found legacy installation directory: $LEGACY_DIR"
      read -rp "Remove legacy installation in $LEGACY_DIR? (y/N): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Removing legacy app directory: $LEGACY_DIR"
        rm -rf "$LEGACY_DIR"
        LEGACY_FOUND=true
      else
        echo "Skipping removal of $LEGACY_DIR"
      fi
    fi
  done

  # Check and remove legacy desktop files
  for LEGACY_DESKTOP in "${LEGACY_DESKTOPS[@]}"; do
    if [ -f "$LEGACY_DESKTOP" ]; then
      echo "Found legacy desktop file: $LEGACY_DESKTOP"
      echo "Removing legacy desktop file: $LEGACY_DESKTOP"
      rm -f "$LEGACY_DESKTOP"
      LEGACY_FOUND=true
    fi
  done

  # Provide feedback based on what was found and removed
  if [ "$PACKAGE_INSTALLED" = true ] && [ "$LEGACY_FOUND" = true ]; then
    echo -e "\n${GREEN}✅ Both package installation and legacy installations have been removed.${NC}\n"
  elif [ "$PACKAGE_INSTALLED" = true ]; then
    echo -e "\n${GREEN}✅ Throne package has been successfully uninstalled.${NC}\n"
  elif [ "$LEGACY_FOUND" = true ]; then
    echo -e "\n${GREEN}✅ Legacy installations have been removed.${NC}\n"
  else
    echo -e "\n${YELLOW}⚠ No Throne installations found on this system.${NC}\n"
  fi
}

# Enable hotspot function
enable_hotspot() {
  echo -e "${BLUE}=== ENABLE HOTSPOT ===${NC}\n"

  echo -e "${GREEN}🚀 Starting Throne Hotspot...${NC}"

  # Parse dry-run option
  local dry_run=false
  read -rp "Run in dry-run mode? (y/N): " dry_choice
  if [[ "$dry_choice" =~ ^[Yy]$ ]]; then
    dry_run=true
    echo -e "${YELLOW}🧪 Running in dry-run mode — no changes will be made.${NC}"
  fi

  # Check required commands
  for cmd in nmcli iw nft; do
    if ! command -v "$cmd" &>/dev/null; then
      echo -e "${RED}❌ '$cmd' command not found. Please install it.${NC}"
      case "$cmd" in
      nmcli)
        echo -e "   Debian/Ubuntu: sudo apt install network-manager"
        echo -e "   Fedora:        sudo dnf install NetworkManager"
        echo -e "   Arch:          sudo pacman -S networkmanager"
        ;;
      iw)
        echo -e "   Debian/Ubuntu: sudo apt install iw"
        echo -e "   Fedora:        sudo dnf install iw"
        echo -e "   Arch:          sudo pacman -S iw"
        ;;
      nft)
        echo -e "   Debian/Ubuntu: sudo apt install nftables"
        echo -e "   Fedora:        sudo dnf install nftables"
        echo -e "   Arch:          sudo pacman -S nftables"
        ;;
      esac
      exit 1
    fi
  done

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
    echo -e "   Please enable 'Tun Mode' in Throne/NekoRay GUI settings."
    exit 1
  fi

  echo -e "${GREEN}✅ Enabling Wi-Fi...${NC}"
  run_cmd $dry_run "nmcli radio wifi on"

  # Check if a Wi-Fi hotspot is already active
  if iw dev "$HOTSPOT_IFACE" info 2>/dev/null | grep -q "type AP"; then
    echo -e "${YELLOW}⚠ A Wi-Fi hotspot is already active on $HOTSPOT_IFACE. Skipping creation.${NC}"
    return 0
  fi

  echo -e "${GREEN}✅ Starting hotspot...${NC}"

  # Get password from user
  while true; do
    read -rsp $'\n🔒 Enter hotspot password (min 8 chars): ' PASSWORD
    echo
    if [ ${#PASSWORD} -ge 8 ]; then
      break
    else
      echo -e "${RED}❌ Password must be at least 8 characters.${NC}"
    fi
  done

  if ! $dry_run && ! nmcli dev wifi hotspot ifname "$HOTSPOT_IFACE" ssid "$SSID" password "$PASSWORD" >/dev/null 2>&1; then
    echo -e "${RED}❌ Failed to start hotspot — maybe AP mode is unsupported.${NC}"
    exit 1
  fi

  if $dry_run; then
    echo -e "${BLUE}→ nmcli dev wifi hotspot ifname \"$HOTSPOT_IFACE\" ssid \"$SSID\" password \"********\"${NC}"
  fi

  echo -e "${GREEN}✅ Setting up nftables rules...${NC}"
  run_cmd $dry_run "sudo nft delete table ip $NFT_TABLE 2>/dev/null || true"
  run_cmd $dry_run "sudo nft add table ip $NFT_TABLE"
  run_cmd $dry_run "sudo nft add chain ip $NFT_TABLE postrouting { type nat hook postrouting priority srcnat\; policy accept\; }"
  run_cmd $dry_run "sudo nft add rule ip $NFT_TABLE postrouting oifname \"$TUN_IFACE\" masquerade"
  run_cmd $dry_run "sudo nft add chain ip $NFT_TABLE forward { type filter hook forward priority filter\; policy accept\; }"
  run_cmd $dry_run "sudo nft add rule ip $NFT_TABLE forward iifname \"$HOTSPOT_IFACE\" oifname \"$TUN_IFACE\" accept"
  run_cmd $dry_run "sudo nft add rule ip $NFT_TABLE forward iifname \"$TUN_IFACE\" oifname \"$HOTSPOT_IFACE\" ct state established,related accept"

  echo -e "\n${BOLD}${GREEN}✔ Hotspot is ready and running!${NC}\n"
  echo "SSID: $SSID"
  echo "Password: $PASSWORD"
  echo
}

# Disable hotspot function
disable_hotspot() {
  echo -e "${BLUE}=== DISABLE HOTSPOT ===${NC}\n"

  # Parse dry-run option
  local dry_run=false
  read -rp "Run in dry-run mode? (y/N): " dry_choice
  if [[ "$dry_choice" =~ ^[Yy]$ ]]; then
    dry_run=true
    echo -e "${YELLOW}🧪 Running in dry-run mode — no changes will be made.${NC}"
  fi

  echo -e "${GREEN}✅ Stopping hotspot...${NC}"
  run_cmd $dry_run "nmcli connection down Hotspot 2>/dev/null || true"
  run_cmd $dry_run "nmcli connection delete Hotspot 2>/dev/null || true"

  echo -e "${GREEN}✅ Removing nftables table...${NC}"
  run_cmd $dry_run "sudo nft delete table ip $NFT_TABLE 2>/dev/null || true"

  echo -e "\n${BOLD}${GREEN}✔ Hotspot stopped and nftables rules removed.${NC}\n"
}

# Main function
main() {
  show_banner

  while true; do
    show_menu
    read -rp "Enter your choice (1-7): " choice
    echo

    case $choice in
      1)
        install_app
        ;;
      2)
        backup_config
        ;;
      3)
        restore_config
        ;;
      4)
        uninstall_app
        ;;
      5)
        enable_hotspot
        ;;
      6)
        disable_hotspot
        ;;
      7)
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
        ;;
      *)
        echo -e "${RED}Invalid choice. Please select 1-7.${NC}\n"
        ;;
    esac

    read -rp "Press Enter to continue..."
    echo
  done
}

# Cleanup on exit
trap 'rm -rf "$TMPDIR"' EXIT

# Run main function
main
