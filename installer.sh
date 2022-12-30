#!/bin/bash

NEKORAY_URL="https://api.github.com/repos/MatsuriDayo/nekoray/releases/latest"
NEKORAY_SHORTCUT="$HOME/.local/share/applications/nekoray.desktop"
NEKORAY_FILE_NAME="NekoRay"

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
wget -q -O- $NEKORAY_URL \
| grep -E "browser_download_url.*linux" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -O /tmp/nekoray.zip -i -
unzip /tmp/nekoray.zip -d $HOME/$NEKORAY_FILE_NAME
rm /tmp/nekoray.zip

# Create Desktop icon for current user
cat <<EOT >> $HOME/.local/share/applications/nekoray.desktop
[Desktop Entry]
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
