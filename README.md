# NekoRay Installer for Linux

Easily install [NekoRay](https://github.com/Mahdi-zarei/nekoray) on Linux with desktop shortcut support.  
Supports backup, restore, and Wi-Fi hotspot tunneling through Nekoray.

---

## 📑 Table of Contents

1. [📦 Installation](#-1-installation)  
2. [🔐 Backup & Restore](#-2-backup--restore)  
3. [📡 WiFi Hotspot Routing via NekoRay](#-3-wifi-hotspot-routing-via-nekoray) 

---

## 📦 1. Installation

### ✅ Requirements (Debian-based distros)

```bash
sudo apt update && sudo apt install build-essential \
    libfontconfig1 \
    libqt5network5 \
    libqt5widgets5 \
    libqt5x11extras5 \
    libqt5gui5
```

### 🚀 Install NekoRay

```bash
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/linux/installer.sh | bash
```

Creates a desktop shortcut and installs the latest release in your home directory.

### ❌ Uninstall NekoRay

```bash
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/linux/uninstaller.sh | bash
```

Removes the installed files and shortcut.

---

## 🔐 2. Backup & Restore

### 🗄 Backup Config

Backup your NekoRay config folder to a `.zip` file:

```bash
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/linux/backup.sh | bash
```

> This will create a file like `nekoray-backup-2025-07-17.zip` in the current directory.

### ♻️ Restore Config

Restore your config from a backup zip:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/linux/restore.sh) path/to/backup.zip
```

> It will replace your current config with the contents of the zip file.

---

## 📡 3. WiFi Hotspot Routing via NekoRay

Tunnel all traffic from connected devices through Nekoray using a Wi-Fi hotspot.

### 🔧 Step 1: Enable Tun Mode

In the NekoRay GUI, go to `Settings` → enable **Tun Mode**:

![Enable Tun Mode](./tun-mode.png)

---

### 📶 Start Hotspot

```bash
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/linux/hotspot-on.sh | bash
```

Creates a Wi-Fi hotspot and redirects traffic through the VPN tunnel.

---

### 📴 Stop Hotspot

```bash
wget -qO- https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/linux/hotspot-off.sh | bash
```

Turns off the hotspot and restores previous settings.

> These scripts rely on `nmcli`. Ensure **NetworkManager** is installed and active.

---
