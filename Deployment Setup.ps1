# Deployment Kit GUI v2.0
# Created by: Rakab Aman

# =============================================================================
# INITIALIZATION
# =============================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# =============================================================================
# GLOBAL VARIABLES AND CONFIGURATION
# =============================================================================
$script:ScriptVersion = "2.0"
$script:Author = "Rakab Aman"
$script:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:WindowWidth = 800
$script:WindowHeight = 600
$script:IsAdmin = $false

# =============================================================================
# FUNCTIONS
# =============================================================================

function Check-Admin {
    # Check if running as administrator
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-MessageBox {
    param(
        [string]$Message,
        [string]$Title = "Deployment Kit",
        [string]$Type = "Info"
    )
    
    switch ($Type) {
        "Error" { [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
        "Warning" { [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) }
        "Question" { [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) }
        default { [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) }
    }
}

function Get-SystemInfo {
    try {
        $os = Get-WmiObject -Class Win32_OperatingSystem
        $computer = Get-WmiObject -Class Win32_ComputerSystem
        
        $info = @{
            OSName = $os.Caption
            Version = $os.Version
            Build = $os.BuildNumber
            Architecture = if ([Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }
            TotalMemory = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
            Manufacturer = $computer.Manufacturer
            Model = $computer.Model
        }
        
        return $info
    } catch {
        return @{
            OSName = "Unknown"
            Version = "Unknown"
            Build = "Unknown"
            Architecture = "Unknown"
            TotalMemory = 0
            Manufacturer = "Unknown"
            Model = "Unknown"
        }
    }
}

function Install-Chocolatey {
    param([System.Windows.Forms.RichTextBox]$OutputBox)
    
    $OutputBox.AppendText("`n=== INSTALLING CHOCOLATEY ===`n")
    
    # Check if Chocolatey is already installed
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $OutputBox.AppendText("Chocolatey is already installed. Updating...`n")
        try {
            choco upgrade chocolatey -y
            $OutputBox.AppendText("Chocolatey updated successfully.`n")
        } catch {
            $OutputBox.AppendText("ERROR: Failed to update Chocolatey.`n")
            return $false
        }
    } else {
        $OutputBox.AppendText("Installing Chocolatey package manager...`n")
        
        # Show progress
        $progressBar.Value = 10
        $form.Refresh()
        
        try {
            # Install Chocolatey
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            
            $progressBar.Value = 50
            $form.Refresh()
            
            # Configure Chocolatey
            choco feature enable -n allowGlobalConfirmation
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            $progressBar.Value = 100
            $OutputBox.AppendText("Chocolatey installed and configured successfully.`n")
            return $true
        } catch {
            $OutputBox.AppendText("ERROR: Chocolatey installation failed.`n")
            $OutputBox.AppendText("Error details: $_`n")
            return $false
        }
    }
}

function Install-AppsFromConfig {
    param(
        [string]$ConfigFile,
        [string]$Category,
        [System.Windows.Forms.RichTextBox]$OutputBox
    )
    
    $configPath = Join-Path $script:ScriptPath $ConfigFile
    
    if (-not (Test-Path $configPath)) {
        $OutputBox.AppendText("ERROR: Configuration file '$ConfigFile' not found.`n")
        return $false
    }
    
    $OutputBox.AppendText("`n=== INSTALLING $Category APPLICATIONS ===`n")
    $OutputBox.AppendText("Reading configuration from: $configPath`n")
    
    try {
        $progressBar.Value = 10
        $form.Refresh()
        
        choco install $configPath -y
        
        $progressBar.Value = 100
        $OutputBox.AppendText("$Category applications installed successfully.`n")
        return $true
    } catch {
        $OutputBox.AppendText("ERROR: Failed to install $Category applications.`n")
        return $false
    }
}

function Upgrade-AllApps {
    param([System.Windows.Forms.RichTextBox]$OutputBox)
    
    $OutputBox.AppendText("`n=== UPGRADING ALL APPLICATIONS ===`n")
    
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        $OutputBox.AppendText("ERROR: Chocolatey not installed. Please install it first.`n")
        return $false
    }
    
    try {
        $progressBar.Value = 10
        $form.Refresh()
        
        $OutputBox.AppendText("Upgrading Chocolatey itself...`n")
        choco upgrade chocolatey -y
        
        $progressBar.Value = 30
        $form.Refresh()
        
        $OutputBox.AppendText("Upgrading all installed packages...`n")
        choco upgrade all -y
        
        $progressBar.Value = 100
        $OutputBox.AppendText("All applications upgraded successfully.`n")
        return $true
    } catch {
        $OutputBox.AppendText("ERROR: Failed to upgrade applications.`n")
        return $false
    }
}

function Install-Drivers {
    param(
        [string]$Mode,
        [System.Windows.Forms.RichTextBox]$OutputBox
    )
    
    $OutputBox.AppendText("`n=== INSTALLING DRIVERS ===`n")
    
    if ($Mode -eq "Online") {
        $configPath = Join-Path $script:ScriptPath "drivers.config"
        if (-not (Test-Path $configPath)) {
            $OutputBox.AppendText("ERROR: drivers.config not found.`n")
            return $false
        }
        
        $OutputBox.AppendText("Installing drivers via Chocolatey...`n")
        try {
            choco install $configPath -y
            $OutputBox.AppendText("Drivers installed successfully.`n")
            return $true
        } catch {
            $OutputBox.AppendText("ERROR: Failed to install drivers.`n")
            return $false
        }
    } else {
        $scriptPath = Join-Path $script:ScriptPath "installdriver.ps1"
        if (-not (Test-Path $scriptPath)) {
            $OutputBox.AppendText("ERROR: installdriver.ps1 not found.`n")
            return $false
        }
        
        $OutputBox.AppendText("Running offline driver installation...`n")
        try {
            & $scriptPath
            $OutputBox.AppendText("Offline driver installation completed.`n")
            return $true
        } catch {
            $OutputBox.AppendText("ERROR: Offline driver installation failed.`n")
            return $false
        }
    }
}

function Install-OfflineApps {
    param([System.Windows.Forms.RichTextBox]$OutputBox)
    
    $OutputBox.AppendText("`n=== INSTALLING OFFLINE APPLICATIONS ===`n")
    
    $nonSilentPath = Join-Path $script:ScriptPath "installnonsilent.ps1"
    $silentPath = Join-Path $script:ScriptPath "installsilent.ps1"
    
    $success = $true
    
    if (Test-Path $nonSilentPath) {
        $OutputBox.AppendText("Installing non-silent applications...`n")
        try {
            & $nonSilentPath
            $OutputBox.AppendText("Non-silent applications installed.`n")
        } catch {
            $OutputBox.AppendText("WARNING: Non-silent installation had issues.`n")
            $success = $false
        }
    } else {
        $OutputBox.AppendText("WARNING: installnonsilent.ps1 not found.`n")
    }
    
    if (Test-Path $silentPath) {
        $OutputBox.AppendText("Installing silent applications...`n")
        try {
            & $silentPath
            $OutputBox.AppendText("Silent applications installed.`n")
        } catch {
            $OutputBox.AppendText("WARNING: Silent installation had issues.`n")
            $success = $false
        }
    } else {
        $OutputBox.AppendText("WARNING: installsilent.ps1 not found.`n")
    }
    
    return $success
}

function Run-Backup {
    param([System.Windows.Forms.RichTextBox]$OutputBox)
    
    $scriptPath = Join-Path $script:ScriptPath "backup.ps1"
    
    if (-not (Test-Path $scriptPath)) {
        $OutputBox.AppendText("ERROR: backup.ps1 not found.`n")
        return $false
    }
    
    $OutputBox.AppendText("`n=== RUNNING BACKUP ===`n")
    
    try {
        & $scriptPath
        $OutputBox.AppendText("Backup completed successfully.`n")
        return $true
    } catch {
        $OutputBox.AppendText("ERROR: Backup failed.`n")
        return $false
    }
}

function Run-Restore {
    param([System.Windows.Forms.RichTextBox]$OutputBox)
    
    $scriptPath = Join-Path $script:ScriptPath "restore.ps1"
    
    if (-not (Test-Path $scriptPath)) {
        $OutputBox.AppendText("ERROR: restore.ps1 not found.`n")
        return $false
    }
    
    $OutputBox.AppendText("`n=== RUNNING RESTORE ===`n")
    
    try {
        & $scriptPath
        $OutputBox.AppendText("Restore completed successfully.`n")
        return $true
    } catch {
        $OutputBox.AppendText("ERROR: Restore failed.`n")
        return $false
    }
}

function Install-CustomScripts {
    param([System.Windows.Forms.RichTextBox]$OutputBox)
    
    $OutputBox.AppendText("`n=== INSTALLING CUSTOM SCRIPTS ===`n")
    
    $customScriptsPath = Join-Path $script:ScriptPath "Custom_Scripts"
    $powerToolsPath = Join-Path $script:ScriptPath "powertools"
    
    # Copy Custom Scripts
    if (Test-Path $customScriptsPath) {
        $OutputBox.AppendText("Copying custom scripts...`n")
        try {
            Copy-Item -Path "$customScriptsPath\*" -Destination "C:\Scripts\" -Recurse -Force
            $OutputBox.AppendText("Custom scripts copied to C:\Scripts\`n")
        } catch {
            $OutputBox.AppendText("ERROR: Failed to copy custom scripts.`n")
        }
    } else {
        $OutputBox.AppendText("WARNING: Custom_Scripts folder not found.`n")
    }
    
    # Copy Power Tools
    if (Test-Path $powerToolsPath) {
        $OutputBox.AppendText("Copying power tools...`n")
        try {
            Copy-Item -Path "$powerToolsPath\*" -Destination "C:\PowerTools\" -Recurse -Force
            $OutputBox.AppendText("Power tools copied to C:\PowerTools\`n")
        } catch {
            $OutputBox.AppendText("ERROR: Failed to copy power tools.`n")
        }
    } else {
        $OutputBox.AppendText("WARNING: powertools folder not found.`n")
    }
    
    # Register context menu entries
    $regPath = "C:\Scripts\reg"
    if (Test-Path $regPath) {
        $OutputBox.AppendText("Registering context menu entries...`n")
        $regFiles = Get-ChildItem -Path $regPath -Filter "*.reg"
        foreach ($file in $regFiles) {
            try {
                reg import $file.FullName
                $OutputBox.AppendText("  Imported: $($file.Name)`n")
            } catch {
                $OutputBox.AppendText("  ERROR importing: $($file.Name)`n")
            }
        }
    }
    
    # Create shortcuts
    $ecMenuShortcut = "C:\scripts\tools\EcMenu\EcMenu.lnk"
    $audioRepeaterShortcut = "C:\scripts\Audio Repeater (Games).lnk"
    $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    
    if (Test-Path $ecMenuShortcut) {
        try {
            Copy-Item -Path $ecMenuShortcut -Destination $startMenuPath -Force
            $OutputBox.AppendText("Created EcMenu shortcut in Start Menu.`n")
        } catch {
            $OutputBox.AppendText("ERROR creating EcMenu shortcut.`n")
        }
    }
    
    if (Test-Path $audioRepeaterShortcut) {
        try {
            Copy-Item -Path $audioRepeaterShortcut -Destination $startMenuPath -Force
            $OutputBox.AppendText("Created Audio Repeater shortcut in Start Menu.`n")
        } catch {
            $OutputBox.AppendText("ERROR creating Audio Repeater shortcut.`n")
        }
    }
    
    $OutputBox.AppendText("Custom scripts installation completed.`n")
    return $true
}

function Optimize-System {
    param([System.Windows.Forms.RichTextBox]$OutputBox)
    
    $OutputBox.AppendText("`n=== SYSTEM OPTIMIZATION ===`n")
    
    try {
        # Disk Cleanup
        $OutputBox.AppendText("Running Disk Cleanup...`n")
        Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait -NoNewWindow
        
        # Defrag drives
        $OutputBox.AppendText("Optimizing drives...`n")
        Start-Process defrag -ArgumentList "/C /H" -Wait -NoNewWindow
        
        # Clear temporary files
        $OutputBox.AppendText("Clearing temporary files...`n")
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:WINDIR\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        $OutputBox.AppendText("System optimization completed successfully.`n")
        return $true
    } catch {
        $OutputBox.AppendText("ERROR: System optimization failed.`n")
        return $false
    }
}

function Complete-Installation {
    param([System.Windows.Forms.RichTextBox]$OutputBox)
    
    $result = Show-MessageBox -Message "This will install ALL components including:`n`n• Chocolatey Package Manager`n• Basic Applications`n• Developer Tools`n• Offline Applications`n• Drivers`n`nEstimated time: 30-60 minutes`n`nDo you want to continue?" -Title "Complete Installation" -Type "Question"
    
    if ($result -eq "No") {
        return
    }
    
    $OutputBox.AppendText("`n=== STARTING COMPLETE INSTALLATION ===`n")
    
    # Step 1: Install Chocolatey
    $OutputBox.AppendText("Step 1/5: Installing Chocolatey...`n")
    $progressBar.Value = 10
    $form.Refresh()
    $chocoSuccess = Install-Chocolatey -OutputBox $OutputBox
    
    if (-not $chocoSuccess) {
        $OutputBox.AppendText("ERROR: Chocolatey installation failed. Aborting.`n")
        return
    }
    
    # Step 2: Install Basic Apps
    $OutputBox.AppendText("Step 2/5: Installing Basic Applications...`n")
    $progressBar.Value = 30
    $form.Refresh()
    $basicSuccess = Install-AppsFromConfig -ConfigFile "defaultapps.config" -Category "BASIC" -OutputBox $OutputBox
    
    # Step 3: Install Developer Tools
    $OutputBox.AppendText("Step 3/5: Installing Developer Tools...`n")
    $progressBar.Value = 50
    $form.Refresh()
    $devSuccess = Install-AppsFromConfig -ConfigFile "devapps.config" -Category "DEVELOPER" -OutputBox $OutputBox
    
    # Step 4: Install Offline Apps
    $OutputBox.AppendText("Step 4/5: Installing Offline Applications...`n")
    $progressBar.Value = 70
    $form.Refresh()
    $offlineSuccess = Install-OfflineApps -OutputBox $OutputBox
    
    # Step 5: Install Drivers
    $OutputBox.AppendText("Step 5/5: Installing Drivers...`n")
    $progressBar.Value = 90
    $form.Refresh()
    
    $driverMode = if (Test-Path (Join-Path $script:ScriptPath "drivers.config")) { "Online" } else { "Offline" }
    $driverSuccess = Install-Drivers -Mode $driverMode -OutputBox $OutputBox
    
    $progressBar.Value = 100
    $OutputBox.AppendText("`n=== COMPLETE INSTALLATION FINISHED ===`n")
    $OutputBox.AppendText("All components have been installed successfully!`n")
    $OutputBox.AppendText("Recommendation: Restart your computer to complete setup.`n")
    
    Show-MessageBox -Message "Complete installation finished successfully!`n`nRecommendation: Restart your computer to complete the setup." -Title "Installation Complete" -Type "Info"
}

function Clear-Output {
    $outputBox.Clear()
    $outputBox.AppendText("Deployment Kit v$script:ScriptVersion by $script:Author`n")
    $outputBox.AppendText("=" * 60 + "`n")
    $outputBox.AppendText("Ready for commands. Select an option from the menu.`n")
}

# =============================================================================
# CREATE MAIN FORM
# =============================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Deployment Kit v$script:ScriptVersion"
$form.Size = New-Object System.Drawing.Size($script:WindowWidth, $script:WindowHeight)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Check admin rights
$script:IsAdmin = Check-Admin
if (-not $script:IsAdmin) {
    $result = Show-MessageBox -Message "This application requires administrator privileges to run properly.`n`nClick OK to restart as administrator, or Cancel to exit." -Title "Administrator Required" -Type "Warning"
    
    if ($result -eq "OK") {
        # Relaunch as admin
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell"
        $psi.Arguments = "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
        $psi.Verb = "runas"
        
        try {
            [System.Diagnostics.Process]::Start($psi) | Out-Null
            exit
        } catch {
            Show-MessageBox -Message "Failed to restart as administrator. Please run PowerShell as administrator and execute this script." -Title "Error" -Type "Error"
            exit
        }
    } else {
        exit
    }
}

# =============================================================================
# CREATE CONTROLS
# =============================================================================

# System Info Panel
$infoPanel = New-Object System.Windows.Forms.Panel
$infoPanel.Location = New-Object System.Drawing.Point(10, 10)
$infoPanel.Size = New-Object System.Drawing.Size(780, 80)
$infoPanel.BorderStyle = "FixedSingle"

$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Location = New-Object System.Drawing.Point(10, 10)
$infoLabel.Size = New-Object System.Drawing.Size(760, 60)
$infoLabel.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($infoPanel)
$infoPanel.Controls.Add($infoLabel)

# Output Box
$outputBox = New-Object System.Windows.Forms.RichTextBox
$outputBox.Location = New-Object System.Drawing.Point(10, 100)
$outputBox.Size = New-Object System.Drawing.Size(780, 300)
$outputBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$outputBox.BackColor = [System.Drawing.Color]::Black
$outputBox.ForeColor = [System.Drawing.Color]::Lime
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 410)
$progressBar.Size = New-Object System.Drawing.Size(780, 20)
$form.Controls.Add($progressBar)

# Buttons Panel
$buttonsPanel = New-Object System.Windows.Forms.Panel
$buttonsPanel.Location = New-Object System.Drawing.Point(10, 440)
$buttonsPanel.Size = New-Object System.Drawing.Size(780, 120)
$form.Controls.Add($buttonsPanel)

# Function to create buttons
function Create-Button {
    param(
        [string]$Text,
        [int]$X,
        [int]$Y,
        [int]$Width = 180,
        [int]$Height = 30,
        [scriptblock]$OnClick
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.Size = New-Object System.Drawing.Size($Width, $Height)
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $button.Add_Click($OnClick)
    $buttonsPanel.Controls.Add($button)
    
    return $button
}

# Create buttons in two rows
# Row 1
$btnChoco = Create-Button -Text "1. Install Chocolatey" -X 10 -Y 10 -OnClick {
    Install-Chocolatey -OutputBox $outputBox
}

$btnBasicApps = Create-Button -Text "2. Install Basic Apps" -X 200 -Y 10 -OnClick {
    Install-AppsFromConfig -ConfigFile "defaultapps.config" -Category "BASIC" -OutputBox $outputBox
}

$btnDevApps = Create-Button -Text "3. Install Dev Tools" -X 390 -Y 10 -OnClick {
    Install-AppsFromConfig -ConfigFile "devapps.config" -Category "DEVELOPER" -OutputBox $outputBox
}

$btnUpgrade = Create-Button -Text "4. Upgrade Apps" -X 580 -Y 10 -OnClick {
    Upgrade-AllApps -OutputBox $outputBox
}

# Row 2
$btnOffline = Create-Button -Text "5. Install Offline" -X 10 -Y 50 -OnClick {
    Install-OfflineApps -OutputBox $outputBox
}

$btnDrivers = Create-Button -Text "6. Install Drivers" -X 200 -Y 50 -OnClick {
    # Show driver mode selection
    $driverForm = New-Object System.Windows.Forms.Form
    $driverForm.Text = "Driver Installation"
    $driverForm.Size = New-Object System.Drawing.Size(300, 150)
    $driverForm.StartPosition = "CenterParent"
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Select driver installation mode:"
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.Size = New-Object System.Drawing.Size(250, 20)
    $driverForm.Controls.Add($label)
    
    $btnOnline = New-Object System.Windows.Forms.Button
    $btnOnline.Text = "Online (Chocolatey)"
    $btnOnline.Location = New-Object System.Drawing.Point(20, 50)
    $btnOnline.Size = New-Object System.Drawing.Size(120, 30)
    $btnOnline.Add_Click({
        $driverForm.Close()
        Install-Drivers -Mode "Online" -OutputBox $outputBox
    })
    $driverForm.Controls.Add($btnOnline)
    
    $btnOfflineDrivers = New-Object System.Windows.Forms.Button
    $btnOfflineDrivers.Text = "Offline (Local)"
    $btnOfflineDrivers.Location = New-Object System.Drawing.Point(150, 50)
    $btnOfflineDrivers.Size = New-Object System.Drawing.Size(120, 30)
    $btnOfflineDrivers.Add_Click({
        $driverForm.Close()
        Install-Drivers -Mode "Offline" -OutputBox $outputBox
    })
    $driverForm.Controls.Add($btnOfflineDrivers)
    
    $driverForm.ShowDialog()
}

$btnComplete = Create-Button -Text "7. Complete Install" -X 390 -Y 50 -OnClick {
    Complete-Installation -OutputBox $outputBox
}

$btnTools = Create-Button -Text "8. Tools Menu" -X 580 -Y 50 -Width 100 -OnClick {
    # Show tools menu
    $toolsForm = New-Object System.Windows.Forms.Form
    $toolsForm.Text = "Tools Menu"
    $toolsForm.Size = New-Object System.Drawing.Size(400, 300)
    $toolsForm.StartPosition = "CenterParent"
    
    $btnBackup = Create-Button -Text "Backup" -X 20 -Y 20 -Width 150 -OnClick {
        $toolsForm.Close()
        Run-Backup -OutputBox $outputBox
    }
    $btnBackup.Parent = $toolsForm
    
    $btnRestore = Create-Button -Text "Restore" -X 190 -Y 20 -Width 150 -OnClick {
        $toolsForm.Close()
        Run-Restore -OutputBox $outputBox
    }
    $btnRestore.Parent = $toolsForm
    
    $btnCustomScripts = Create-Button -Text "Install Custom Scripts" -X 20 -Y 60 -Width 150 -OnClick {
        $toolsForm.Close()
        Install-CustomScripts -OutputBox $outputBox
    }
    $btnCustomScripts.Parent = $toolsForm
    
    $btnOptimize = Create-Button -Text "System Optimization" -X 190 -Y 60 -Width 150 -OnClick {
        $toolsForm.Close()
        Optimize-System -OutputBox $outputBox
    }
    $btnOptimize.Parent = $toolsForm
    
    $btnCloseTools = New-Object System.Windows.Forms.Button
    $btnCloseTools.Text = "Close"
    $btnCloseTools.Location = New-Object System.Drawing.Point(150, 220)
    $btnCloseTools.Size = New-Object System.Drawing.Size(100, 30)
    $btnCloseTools.Add_Click({ $toolsForm.Close() })
    $toolsForm.Controls.Add($btnCloseTools)
    
    $toolsForm.ShowDialog()
}

# Row 3 - Utility buttons
$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Clear Output"
$btnClear.Location = New-Object System.Drawing.Point(10, 90)
$btnClear.Size = New-Object System.Drawing.Size(100, 25)
$btnClear.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$btnClear.Add_Click({ Clear-Output })
$buttonsPanel.Controls.Add($btnClear)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Exit"
$btnExit.Location = New-Object System.Drawing.Point(670, 90)
$btnExit.Size = New-Object System.Drawing.Size(100, 25)
$btnExit.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$btnExit.Add_Click({ $form.Close() })
$buttonsPanel.Controls.Add($btnExit)

# =============================================================================
# INITIALIZE AND SHOW FORM
# =============================================================================

# Load system info
$systemInfo = Get-SystemInfo
$infoText = "System: $($systemInfo.OSName) | Version: $($systemInfo.Version) | Build: $($systemInfo.Build)`n"
$infoText += "Architecture: $($systemInfo.Architecture) | RAM: $($systemInfo.TotalMemory) GB`n"
$infoText += "Hardware: $($systemInfo.Manufacturer) $($systemInfo.Model)"
$infoLabel.Text = $infoText

# Initial output
Clear-Output

# Show form
$form.Add_Shown({$form.Activate()})
[System.Windows.Forms.Application]::Run($form)