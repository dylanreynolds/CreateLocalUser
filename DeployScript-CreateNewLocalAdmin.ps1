# Edit the URL to your blob storage path
$PSurl= "https://raw.githubusercontent.com/dylanreynolds/CreateLocalUserUsingMachineCredentials/main/CreateLocalUserviaIntunewithLoggingRequiresMachineKey.ps1"

# Location where we will add the script to run on logon
$regKeyLocation ="HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"

# Command for the registry
$psCommand = "PowerShell.exe -ExecutionPolicy Bypass -Command $PSurl"

# Check if the registry location exist, if not create it.
if (-not(Test-Path -Path $regKeyLocation)) {
    New-ItemProperty -Path $regKeyLocation -Force
}

# Create / Update the registry to reflect the powershell command.
$psCommand = "PowerShell.exe -ExecutionPolicy Bypass -Windowstyle hidden -command $([char]34)& {(Invoke-RestMethod '$PSurl') | Invoke-Expression}$([char]34)"

# Deploy PowerShell script immediately
Invoke-Expression $psCommand
