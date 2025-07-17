# NekoRay Installer

Install latest [NekoRay](https://github.com/Mahdi-zarei/nekoray) with desktop shortcut on your Linux.

------------------------------------------------------------

## 📦 Requirements (Debian-based OS)

sudo apt update && sudo apt install build-essential \
                                    libfontconfig1 \
                                    libqt5network5 \
                                    libqt5widgets5 \
                                    libqt5x11extras5 \
                                    libqt5gui5

------------------------------------------------------------

## 🚀 Install

```
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/installer.sh | bash
```

------------------------------------------------------------

## ❌ Uninstall

```
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/uninstaller.sh | bash
```

------------------------------------------------------------

## 🔐 Backup Config

Create a backup of your NekoRay config folder:
```
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/backup.sh | bash
```

A .zip file will be created in your current directory.

------------------------------------------------------------

## ♻️ Restore Config

Restore your NekoRay config from a backup zip file:

```
bash <(wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/restore.sh) path/to/your-backup.zip
```

This will replace the current config folder with the one from the zip file.

------------------------------------------------------------

## 📡 Hotspot Control

You can enable or disable your system hotspot using the provided scripts, first enable Tun Mode from Nekoray GUI then:

### Turn Hotspot **On**

```
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/hotspot-on.sh | bash
```

### Turn Hotspot **Off**

```
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/hotspot-off.sh | bash
```

These scripts use `nmcli` to manage your network hotspot. Make sure you have NetworkManager installed and running.

------------------------------------------------------------
