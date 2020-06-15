# Connecting to the Skype for Business Online PowerShell Module
> <i class="fas fa-clipboard"></i> This module is used to manage the Microsoft Teams environment as well as Skype for Business Online

Multiple scripts on this site assume you've already connected to the Skype for Business Online PowerShell Module. This code will connect you to the service and allow you to check you're connected to the correct tenant


## Usage
Copy the full script into a new PowerShell window to connect.

We recommend you use the **SBC-Easy** code where possible on the site

## PowerShell
PowerShell will prompt for the username and password of the 365 tenant administrator account. The script supports MFA Authentication.

<i class="fas fa-terminal"></i> **Raw PowerShell Code**
````PowerShell
$skypeConnection = New-CsOnlineSession -ErrorAction SilentlyContinue
Import-PSSession $skypeConnection -AllowClobber -ErrorAction SilentlyContinue
````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
````PowerShell
#Check the Skype for Business Online PowerShell Module is installed

if(Get-Module SkypeOnlineConnector -ListAvailable)
    {
        Import-Module SkypeOnlineConnector
    } else {
        Write-host "The Skype for Business Online Powershell Module isn't installed!" -ForegroundColor Yellow -BackgroundColor Red
        Write-Host "We're opening the download page now for you!" -ForegroundColor Yellow -BackgroundColor Red
        write-host "URL: https://www.microsoft.com/en-us/download/details.aspx?id=39366" -ForegroundColor Yellow -BackgroundColor Red
        write-host "After installing, you'll need to close and re-open the PowerShell window, then re-run the PowerShell script" -ForegroundColor Yellow -BackgroundColor Red
        Pause
        Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
        Break
    }

#Connect to the Skype for Business PowerShell module 
Write-Host "Logging onto Skype for Business Online Powershell Module" -BackgroundColor Yellow -ForegroundColor Black
$skypeConnection = New-CsOnlineSession -ErrorAction SilentlyContinue
Import-PSSession $skypeConnection -AllowClobber -ErrorAction SilentlyContinue

$tenant = Get-CsTenant | Select DisplayName
Write-Host ""
Write-Host "The tenant you've connected to is: $($tenant.DisplayName)" -BackgroundColor Yellow -ForegroundColor Black
````
