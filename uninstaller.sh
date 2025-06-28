#!/bin/bash
set -e

NEKORAY_FILE_NAME="NekoRay"
NEKORAY_FOLDER="$HOME/$NEKORAY_FILE_NAME"
NEKORAY_DESKTOPFILE="$HOME/.local/share/applications/nekoray.desktop"

echo -e "\n🔧 Uninstalling NekoRay..."

# Remove application folder with sudo
if [ -d "$NEKORAY_FOLDER" ]; then
  echo "Removing folder (using sudo): $NEKORAY_FOLDER"
  sudo rm -rf "$NEKORAY_FOLDER"
else
  echo "No NekoRay folder found at $NEKORAY_FOLDER"
fi

# Remove desktop shortcut (no sudo needed since it's in your home)
if [ -f "$NEKORAY_DESKTOPFILE" ]; then
  echo "Removing desktop entry: $NEKORAY_DESKTOPFILE"
  rm -f "$NEKORAY_DESKTOPFILE"
else
  echo "No desktop entry found at $NEKORAY_DESKTOPFILE"
fi

echo -e "\n✅ NekoRay has been removed successfully."
