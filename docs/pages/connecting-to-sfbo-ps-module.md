# Connecting to the Skype for Business Online PowerShell Module
> This module is used to manage the Microsoft Teams environment as well as Skype for Business Online

Multiple scripts on this site assume you've already connected to the Skype for Business Online PowerShell Module.

The below script will connect you and display the tenant name to confirm you've connected to the correct tenant

## Usage
Copy the full script into a new PowerShell window to connect

## PowerShell
PowerShell will prompt for the username and password of the 365 tenant administrator account
````PowerShell
#Connect to the Skype for Business PowerShell module 
Write-Host "Logging onto Skype for Business Online Powershell Module" -BackgroundColor Yellow -ForegroundColor Black
$skypeConnection = New-CsOnlineSession -ErrorAction SilentlyContinue
Import-PSSession $skypeConnection -AllowClobber -ErrorAction SilentlyContinue

$tenant = Get-CsTenant | Select DisplayName
Write-Host ""
Write-Host "The tenant you've connected to is: $($tenant.DisplayName)" -BackgroundColor Yellow -ForegroundColor Black
````
