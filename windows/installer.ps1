$ErrorActionPreference = "Stop"

# Configuration
$throneApiUrl = "https://api.github.com/repos/throneproj/Throne/releases/latest"
$installerPath = "$env:TEMP\throne_installer.exe"

Write-Host "`nFetching latest Throne release..."

try {
    # Get latest release info
    $response = Invoke-RestMethod -Uri $throneApiUrl -UseBasicParsing
    
    # Find Windows installer download URL
    $installerAsset = $response.assets | Where-Object { $_.name -match "windows.*installer\.exe$" }
    
    if (-not $installerAsset) {
        Write-Host "No Windows installer found in the latest release."
        exit 1
    }
    
    $installerUrl = $installerAsset.browser_download_url
    Write-Host "Found installer: $($installerAsset.name)"
    
    Write-Host "Downloading Throne installer..."
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

    if (Test-Path $installerPath) {
        Write-Host "Download completed. Launching installer..."
        Start-Process -FilePath $installerPath
        Write-Host "Installer launched. Exiting script."
    } else {
        Write-Host "Download failed."
        exit 1
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
