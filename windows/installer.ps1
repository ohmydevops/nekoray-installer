$ErrorActionPreference = "Stop"

$installerUrl = "https://github.com/throneproj/Throne/releases/download/4.3.7/nekoray-4.3.7-2025-07-08-windows64-installer.exe"
$installerPath = "$env:TEMP\nekoray_installer.exe"

Write-Host "`nDownloading NekoRay installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

if (Test-Path $installerPath) {
    Write-Host "Download completed. Launching installer..."
    Start-Process -FilePath $installerPath
    Write-Host "Installer launched. Exiting script."
} else {
    Write-Host "Download failed."
    exit 1
}
