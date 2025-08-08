#!/bin/bash
set -euo pipefail

THRONE_URL="https://api.github.com/repos/throneproj/Throne/releases/latest"
THRONE_APP_NAME="Throne"
THRONE_APP_PATH="/Applications/${THRONE_APP_NAME}.app"
ARCH=$(uname -m)
TMPDIR=$(mktemp -d)
WGET_TIMEOUT=15

# Just for fun
# Source: https://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=NekoRay%20Installer
GREEN='\033[0;32m'
NC='\033[0m'

cat <<EOF

${GREEN}
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
${NC}

EOF

# Check if already installed
if [ -d "$THRONE_APP_PATH" ]; then
  echo -e "${THRONE_APP_NAME} is already installed at ${THRONE_APP_PATH}."
  echo -e "Please back it up and delete it if you want to reinstall.\n"
  exit 0
fi

# Check for required commands
for cmd in unzip wget; do
  if ! command -v $cmd &> /dev/null; then
    echo -e "Missing command: $cmd"
    echo -e "Install it with: brew install $cmd"
    exit 1
  fi
done

# Fetch latest release download and install
echo -e "Fetching latest ${THRONE_APP_NAME} release..."
DOWNLOAD_URL=$(wget --timeout=$WGET_TIMEOUT -q -O- "$THRONE_URL" \
  | grep -Eo "https.*${THRONE_APP_NAME}.*macos-${ARCH}\.zip" \
  | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Failed to find download URL for macOS $ARCH."
  exit 1
fi

echo -e "Downloading from: $DOWNLOAD_URL"
wget --timeout=$WGET_TIMEOUT -q --show-progress --progress=bar:force \
  -O "$TMPDIR/${THRONE_APP_NAME}.zip" "$DOWNLOAD_URL"

echo -e "Installing..."
unzip -q "$TMPDIR/${THRONE_APP_NAME}.zip" -d "$TMPDIR"
mv "$TMPDIR/${THRONE_APP_NAME}/${THRONE_APP_NAME}.app" "/Applications/"

rm -rf "$TMPDIR"

# Done
echo -e "\n✅ Done! ${THRONE_APP_NAME} has been installed to /Applications."
echo -e "You can now launch '${THRONE_APP_NAME}' from Spotlight or Launchpad.\n"
