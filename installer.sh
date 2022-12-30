#!/bin/bash

NEKORAY_VERSION="2.9"
NEKORAY_FILE_NAME="nekoray-2.9-2022-12-19-linux64"
NEKORAY_URL="https://github.com/MatsuriDayo/nekoray/releases/download/$NEKORAY_VERSION/$NEKORAY_FILE_NAME.zip"
NEKORAY_SHORTCUT="$HOME/.local/share/applications/nekoray.desktop"

# Check if installed or not
if [ -d "$HOME/$NEKORAY_FILE_NAME" ]; then
  echo -e "You already have this software installed in $HOME/$NEKORAY_FILE_NAME"
  exit
fi

# Download NekoRay and move to current user home 
if ! command -v unzip &> /dev/null
then
    echo -e "unzip is not installed.\nInstall unzip in your system.\nFor example: sudo apt install unzip"
    exit
fi
if ! command -v wget &> /dev/null
then
    echo -e "wget is not installed.\nInstall wget in your system.\nFor example: sudo apt install wget"
    exit
fi
wget "$NEKORAY_URL" -O /tmp/nekoray.zip
unzip /tmp/nekoray.zip -d $HOME/$NEKORAY_FILE_NAME
rm /tmp/nekoray.zip

# Create Desktop icon for current user
cat <<EOT >> $HOME/.local/share/applications/nekoray.desktop
[Desktop Entry]
Version=$NEKORAY_VERSION
Name=NekoRay
Comment=NekoRay
Exec=$HOME/$NEKORAY_FILE_NAME/nekoray/nekoray
Icon=$HOME/$NEKORAY_FILE_NAME/nekoray/nekoray.png
Terminal=false
StartupWMClass=NekoRay,nekoray,Nekoray,nekoRay
Type=Application
Categories=Network
EOT

# Permissions
chown $USER:$USER $HOME/$NEKORAY_FILE_NAME/ -R

# Done
echo -e "\nDone, type 'NekoRay' in your desktop!"
