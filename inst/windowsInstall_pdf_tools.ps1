<#
.SYNOPSIS
  Set up a WSL2 Ubuntu environment and install pdfjam + pdftk-java for PNG→PDF workflows.

.DESCRIPTION
  - Checks if WSL feature is enabled; if not, enables it (requires reboot).
  - Checks for Ubuntu distro; if missing, installs it (requires reboot).
  - Installs pdfjam, Java, and pdftk-java inside WSL.
  - Validates installation.
  - Idempotent—can be run multiple times.
#>

[CmdletBinding()]
param()

function Ensure-WSL {
  $feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
  if ($feature.State -ne 'Enabled') {
    Write-Host "✅ WSL not enabled: enabling now..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
    Write-Warning "⚠️ WSL features enabled. Please REBOOT and re-run this script."
    exit 0
  } else {
    Write-Host "✅ WSL feature already enabled."
  }
}

function Ensure-WSLInstall {
  $distros = (& wsl --list --verbose) 2>&1
  if ($distros -notmatch 'Ubuntu') {
    Write-Host "⚙️ Ubuntu distro not found. Installing Ubuntu for WSL..."
    # Optional: specify version like Ubuntu-22.04
    wsl --install -d Ubuntu
    Write-Warning "⚠️ Ubuntu installation started. Please REBOOT and re-run this script."
    exit 0
  } else {
    Write-Host "✅ Ubuntu distro already installed."
  }
}

function Install-LinuxTools {
  Write-Host "📦 Installing pdfjam, Java, pdftk-java inside WSL..."
  wsl sudo apt-get update
  wsl sudo apt-get install -y texlive-extra-utils texlive-latex-recommended \
                              default-jre-headless pdftk-java
  Write-Host "🔍 Validating installations..."
  wsl pdfjam --version
  wsl pdftk --version
  wsl java -version
  Write-Host "🎉 Linux tools installed successfully!"
}

# === Main Script ===

Ensure-WSL
Ensure-WSLInstall
Install-LinuxTools

Write-Host "`n✅ All set! You can now run your existing Bash script inside WSL:" -ForegroundColor Green
Write-Host "  wsl bash path/to/your-script.sh collector=XYZ" -ForegroundColor Green

