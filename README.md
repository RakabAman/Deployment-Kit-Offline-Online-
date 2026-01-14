# Deployment Kit v2.1

A Windows batch-based deployment toolkit designed to streamline application setup, driver installation, and system optimization. Built for developers, IT admins, and power users who want a one-stop automation script for provisioning Windows environments.

---

## ✨ Features

- **Administrator Privilege Check**: Auto-elevates with UAC if needed.
- **System Information Detection**: OS version, build number, architecture.
- **Chocolatey Integration**:
  - Install/Update Chocolatey
  - Install developer tools
  - Install basic applications
  - Upgrade all installed packages
- **Offline Installation**:
  - Run silent/non-silent PowerShell installers
  - Driver installation (online/offline)
- **Automation**:
  - Complete installation sequence (all steps in one run)
- **Tools & Utilities**:
  - Backup and restore scripts
  - Custom script deployment with context menu integration
  - System information viewer
- **System Optimization**:
  - Disk cleanup
  - Drive defragmentation
  - Temporary file removal

---

## 📂 Project Structure

- `@echo off.txt` → Main batch script (Deployment Kit)
- `defaultapps.config` → List of basic applications
- `devapps.config` → List of developer applications
- `drivers.config` → Driver installation list
- `backup.ps1` / `restore.ps1` → Backup and restore utilities
- `installnonsilent.ps1` / `installsilent.ps1` → Offline app installers
- `installdriver.ps1` → Offline driver installer
- `Custom_Scripts/` → Custom scripts to be deployed
- `powertools/` → Additional utilities

---

## ⚙️ Requirements

- Windows 8.1 / Server 2012 R2 or later
- Minimum build: 10049 (Windows 10 Technical Preview and above)
- Administrator privileges
- Internet connection (for online installation)

---

## 🚀 Usage

1. Clone or download this repository.
2. Place configuration files (`*.config`, `*.ps1`) in the same directory as the script.
3. Run the batch script as Administrator:
   ```bat
   @echo off.txt
4. Follow the interactive menu to install applications, drivers, or run utilities.

⚠️ Disclaimer
This script modifies system configuration and installs third-party software.
Use at your own risk. Always review configuration files before running.
