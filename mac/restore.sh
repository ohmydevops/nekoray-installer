#!/bin/bash
set -e

NEKORAY_FILE_NAME="nekoray"
NEKORAY_RESTORE_DIR="$HOME/Library/Preferences/$NEKORAY_FILE_NAME/config"
ZIP_FILE="$1"

if [ -z "$ZIP_FILE" ]; then
  echo "❌ Please provide the path to the backup .zip file."
  echo "Usage: $0 <backup-file.zip>"
  exit 1
fi

if [ ! -f "$ZIP_FILE" ]; then
  echo "❌ File not found: $ZIP_FILE"
  exit 1
fi

if ! command -v unzip &> /dev/null; then
  echo "❌ Please install unzip to restore backups."
  echo "Macos: brew install unzip"
  exit 1
fi

if [ -d "$NEKORAY_RESTORE_DIR" ]; then
  echo "⚠️ Removing existing config folder: $NEKORAY_RESTORE_DIR"
  rm -rf "$NEKORAY_RESTORE_DIR"
fi

mkdir -p "$NEKORAY_RESTORE_DIR"

echo "📦 Restoring config to $NEKORAY_RESTORE_DIR ..."
unzip -q "$ZIP_FILE" -d "$NEKORAY_RESTORE_DIR"

echo "✅ Config restored successfully!"
