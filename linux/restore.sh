#!/bin/bash
set -euo pipefail

ZIP_FILE="${1:-}"

if [[ -z "$ZIP_FILE" ]]; then
  echo "Please provide the path to the backup .zip file."
  echo "Usage: $0 <backup-file.zip>"
  exit 1
fi

if [[ ! -f "$ZIP_FILE" ]]; then
  echo "File not found: $ZIP_FILE"
  exit 1
fi

read -rp "👉 Which app are you restoring? (nekoray, throne): " APP_NAME
APP_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')

if [[ "$APP_NAME" != "nekoray" && "$APP_NAME" != "throne" ]]; then
  echo "Invalid app name. Only 'nekoray' or 'throne' allowed."
  exit 1
fi

RESTORE_DIR="$HOME/$APP_NAME/$APP_NAME/config"

if ! command -v unzip &> /dev/null; then
  echo "'unzip' is required. Install it with:"
  echo "  Debian: apt install unzip"
  exit 1
fi

if [[ -d "$RESTORE_DIR" ]]; then
  echo "Removing existing config: $RESTORE_DIR"
  rm -rf "$RESTORE_DIR"
fi

mkdir -p "$RESTORE_DIR"

echo "📦 Restoring backup to: $RESTORE_DIR"
unzip -q "$ZIP_FILE" -d "$RESTORE_DIR"

echo "✅ Restore complete!"
