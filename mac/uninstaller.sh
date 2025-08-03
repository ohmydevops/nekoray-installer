#!/bin/bash
set -euo pipefail

read -p "👉 Enter which app you want to delete (nekoray, throne): " APP_NAME
APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')

if [[ "$APP_NAME" != "nekoray" && "$APP_NAME" != "throne" ]]; then
  echo "Invalid app name. Only 'nekoray' or 'throne' allowed."
  exit 1
fi

APP_PREFS_DIR="$HOME/Library/Preferences/$APP_NAME"
APP_BUNDLE="/Applications/$APP_NAME.app"

echo -e "\nUninstalling $APP_NAME..."

# Remove app preferences folder
if [ -d "$APP_PREFS_DIR" ]; then
  echo "Removing preferences: $APP_PREFS_DIR"
  sudo rm -rvf "$APP_PREFS_DIR"
else
  echo "No preferences folder found at: $APP_PREFS_DIR"
fi

# Remove application bundle
if [ -d "$APP_BUNDLE" ]; then
  echo "Removing app bundle: $APP_BUNDLE"
  sudo rm -rvf "$APP_BUNDLE"
else
  echo "No app found at: $APP_BUNDLE"
fi

echo -e "\n✅ $APP_NAME has been successfully uninstalled."
