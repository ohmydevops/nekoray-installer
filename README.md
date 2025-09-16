# Throne Installer & Management Tools

Cross-platform installer and management tools for [Throne](https://github.com/throneproj/Throne) - the next-generation proxy client. This repository provides comprehensive scripts for installation, configuration management, and advanced features across Linux, macOS, and Windows.

---

## 🚀 Quick Start

Choose your platform and run the appropriate command:

### 🐧 Linux
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/throne-linux.sh)
```

### 🍎 macOS
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/throne-mac.sh)
```

### 🪟 Windows
```powershell
# Run in PowerShell as Administrator
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ohmydevops/nekoray-installer/main/windows/installer.ps1" -UseBasicParsing).Content
```

---

## 📑 Table of Contents

1. [🐧 Linux Features](#-linux-features)
2. [🍎 macOS Features](#-macos-features)
3. [🪟 Windows Features](#-windows-features)
4. [🔧 Prerequisites](#-prerequisites)
5. [📖 Detailed Usage](#-detailed-usage)

---

## 🐧 Linux Features

The Linux script (`throne-linux.sh`) provides a comprehensive menu-driven interface with the following options:

### Menu Options:
1. **Install Throne** - Downloads and installs the latest Throne release system-wide
2. **Backup Configuration** - Creates a backup of your current Throne/NekoRay configuration
3. **Restore Configuration** - Restores configuration from a backup file
4. **Uninstall** - Completely removes Throne and all related files
5. **Enable Hotspot** - Creates a Wi-Fi hotspot that routes traffic through Throne
6. **Disable Hotspot** - Stops the hotspot and removes routing rules
7. **Exit** - Closes the installer

### Supported Distributions:
- Ubuntu, Debian, Linux Mint, Pop!_OS (`.deb` packages)
- Fedora, RHEL, CentOS, Rocky Linux, AlmaLinux (`.rpm` packages)

### Hotspot Features:
- Automatic Wi-Fi interface detection
- nftables-based traffic routing
- NetworkManager integration
- Secure WPA2 password protection

---

## 🍎 macOS Features

The macOS script (`throne-mac.sh`) provides a menu-driven interface optimized for macOS:

### Menu Options:
1. **Install Throne** - Downloads and installs Throne to `/Applications/Throne.app`
2. **Backup Configuration** - Creates a backup of your Throne/NekoRay configuration
3. **Restore Configuration** - Restores configuration from a backup file
4. **Uninstall** - Removes application and preferences (supports both Throne and NekoRay)
5. **Exit** - Closes the installer

### Features:
- Native macOS application installation
- Automatic architecture detection (Intel/Apple Silicon)
- Homebrew integration for dependencies
- Spotlight and Launchpad integration

---

## 🪟 Windows Features

The Windows PowerShell script (`windows/installer.ps1`) provides automated installation:

### Features:
- Downloads the latest Windows installer executable
- Automatically launches the official installer
- Uses native Windows installation methods
- PowerShell-based for maximum compatibility

### Usage:
The script automatically:
1. Fetches the latest release from GitHub
2. Downloads the Windows installer
3. Launches the installer with elevated permissions

---

## 🔧 Prerequisites

### Linux Requirements:
- One of the supported distributions
- `curl` (usually pre-installed)
- Package manager (`dpkg` for Debian-based, `rpm` for Red Hat-based)
- For hotspot features: `nmcli`, `iw`, `nftables`

### macOS Requirements:
- macOS 10.15 or later
- Homebrew (script can install if missing)
- `curl` and `unzip` (installable via Homebrew)

### Windows Requirements:
- Windows 10 or later
- PowerShell 5.1 or later
- Administrator privileges for installation

---

### Advanced Hotspot Setup (Linux Only)

For the Wi-Fi hotspot feature to work properly:

1. **Enable Tun Mode in Throne:**
   - Open Throne GUI
   - Go to Settings → Enable **Tun Mode**

2. **Required Packages:**
   ```bash
   # Debian/Ubuntu
   sudo apt install network-manager iw nftables

   # Fedora/RHEL
   sudo dnf install NetworkManager iw nftables
   ```

3. **Run Hotspot Setup:**
   - Execute the Linux script and select option 5
   - Choose a secure password (minimum 8 characters)
   - The script will create SSID "ohmythrone" by default

---

## � Troubleshooting

### Common Issues:

**Linux:**
- **Permission denied:** Ensure you have sudo privileges
- **Package not found:** Verify your distribution is supported
- **Hotspot not working:** Check that NetworkManager is active and Tun Mode is enabled

**macOS:**
- **App not opening:** Check Gatekeeper settings and allow unidentified developers if needed
- **Homebrew not found:** The script will offer to install Homebrew automatically

**Windows:**
- **PowerShell execution policy:** Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Download failed:** Check internet connection and Windows Defender settings

---

## 📄 License

This project is open source and available under the MIT License.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.
