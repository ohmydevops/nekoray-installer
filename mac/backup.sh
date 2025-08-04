#!/bin/bash
set -euo pipefail

read -rp "👉 Enter which app you want to backup (nekoray, throne): " APP_NAME
APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')

if [[ "$APP_NAME" != "nekoray" && "$APP_NAME" != "throne" ]]; then
  echo "Invalid app name. Only 'nekoray' or 'throne' allowed."
  exit 1
fi

CONFIG_DIR="$HOME/Library/Preferences/$APP_NAME/config"
BACKUP_NAME="${APP_NAME}-backup-$(date +%Y-%m-%d).zip"
DEST_DIR="$(pwd)"

if [ ! -d "$CONFIG_DIR" ]; then
  echo "Config directory does not exist: $CONFIG_DIR"
  exit 1
fi

if ! command -v zip &> /dev/null; then
  echo "Missing 'zip'. Install it with:"
  echo "  brew install zip"
  exit 1
fi

echo "📦 Compressing config ..."

echo "Compressing config from $CONFIG_DIR..."
(cd "$CONFIG_DIR" && zip -rq "$DEST_DIR/$BACKUP_NAME" .)

echo -e "✅ Backup created:\n$DEST_DIR/$BACKUP_NAME"
