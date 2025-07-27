#!/bin/bash
set -e

NEKORAY_FILE_NAME="nekoray"
NEKORAY_CONFIG_DIR="$HOME/Library/Preferences/$NEKORAY_FILE_NAME/config"
BACKUP_NAME="nekoray-backup-$(date +%Y-%m-%d).zip"
DEST_DIR="$(pwd)"

if [ ! -d "$NEKORAY_CONFIG_DIR" ]; then
  echo "❌ Config directory does not exist: $NEKORAY_CONFIG_DIR"
  exit 1
fi

if ! command -v zip &> /dev/null; then
  echo "❌ Please install zip to create backups."
  echo "Debian: sudo apt install zip"
  exit 1
fi

echo "📦 Compressing config ..."

cd "$NEKORAY_CONFIG_DIR"
zip -r "$DEST_DIR/$BACKUP_NAME" ./* > /dev/null

echo -e "✅ Backup file created at:\n$DEST_DIR/$BACKUP_NAME"
