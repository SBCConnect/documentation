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
####
# Login script Version 0.2
#
# Changes
# - Migrate to MicrosoftTeams PowerShell module instead of Skype for Business Online
# - Check MicrosoftTeams PowerShell Version
# - Check if Skype For Business Module is installed and prompt to uninstall it
# 
# Required Changes at a later date
# - Check for ExecutionPolicy = Restricted
# - Set ExecutionPolicy = RemoteSigned
#
# Any issues installing Powershell Module. Try to update PowerShell Get command
# > Install-Module -Name PowerShellGet -Repository PSGallery -Force
# Then close and re-open PowerShell
#
####

#Check the Skype for Business Online PowerShell Module is NOT installed
if(Get-Module SkypeOnlineConnector -ListAvailable)
    {
        Write-Host
        Write-host "The Skype for Business Online Powershell Module has been depreciated and must be uninstalled!" -ForegroundColor Yellow -BackgroundColor Red
        Write-Host
        Write-Host "Please go to Add/Remove programs and remove the Skype for Business Online Powershell Module" -ForegroundColor Yellow
        write-host "Then restart PowerShell and re-run this script" -ForegroundColor Yellow
        write-host "Any new required modules will be installed after re-running the scripts" -ForegroundColor Yellow
        Pause
        Break
    }

#Check the Microsoft Teams Powershell Module is installed
if(-not (Get-Module MicrosoftTeams -ListAvailable)) {
    Write-host "The MicrosoftTeams PowerShell module is not installed and must be installed before continuing!" -ForegroundColor Yellow -BackgroundColor Red
    Write-Host
    Write-Host "We'll attempt to install the module now..." -ForegroundColor Yellow
    Pause
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module MicrosoftTeams -Confirm:$false -Force
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
    Write-Host
    Write-Host
    if(-not (Get-Module MicrosoftTeams -ListAvailable)) {
        Write-host "The MicrosoftTeams PowerShell module seems to not be installing correctly" -ForegroundColor Yellow -BackgroundColor Red
        Write-host "Please try to install the module manually by running the following command in an elevated PowerShell screen" -ForegroundColor Yellow
        Write-host "" -ForegroundColor Yellow -BackgroundColor Red
    }
}

#Check for multiple MicrosoftTeams module versions
Clear
Write-Host "Checking for the newest version of the Microsoft Teams PowerShell module... Please hold"
$currentMSPVersion = (Find-Module MicrosoftTeams).version
Clear-Variable MTPVersionRemoveID -ErrorAction SilentlyContinue
$MPTVersionList = Find-Module MicrosoftTeams -AllowPrerelease -Allversions
while ((Get-Module MicrosoftTeams -ListAvailable).count -gt 1) {
    clear
    $installedMTP = Get-Module MicrosoftTeams -ListAvailable
    Write-Host
    Write-Host "There are $($installedMTP.count) MicrosoftTeams PowerShell module versions installed" -ForegroundColor Yellow
    Write-Host "You'll need to remove older versions to continue" -ForegroundColor Yellow
    Write-Host 
    #Write-Host "Installed versions"
    Write-Host "ID    VERSION"
    Write-Host "--    -------"
    
    for ($i = 0; $i -lt $installedMTP.count; $i++) {
        $lineMTPVersion = ($MPTVersionList | Where-Object ({$_.Version -like "$(($installedMTP[$i].Version))*"})).Version
        if ((Get-Module MicrosoftTeams -ListAvailable)[$i].version -eq $currentMSPVersion) {
            Write-Host "$($i)     $($lineMTPVersion) (Recommended Version to keep - Current stable version)"
        } else {
            Write-Host "$($i)     $($lineMTPVersion)"
        }
    }
    Write-Host
    Write-Host
    if ($MTPVersionRemoveID) {
        Write-Host "$($MTPVersionRemoveID) isn't a valid entry" -ForegroundColor Yellow
        Write-Host
    }
    Clear-Variable MTPVersionRemoveID -ErrorAction SilentlyContinue
    $MTPVersionRemoveID = Read-Host "Please enter the ID of the module version to remove [0-$($installedMTP.count-1)]"
    if ($MTPVersionRemoveID -ge 0 -and $MTPVersionRemoveID -le $installedMTP.count) {
        $MTPRealVersion = ($MPTVersionList | Where-Object ({$_.Version -like "$(($installedMTP[$MTPVersionRemoveID].Version))*"})).Version
        Write-Host
        Write-Host "Removing version $($MTPRealVersion)..."
        #Check the version and if it's a preview or not
        
        Uninstall-Module MicrosoftTeams -Confirm:$false -Force -RequiredVersion $MTPRealVersion -AllowPrerelease
        Write-Host
        Write-Host "Complete" -ForegroundColor Green
        Pause
        $MTPVersionRemoveID = $null
    }
}

#Check Teams module version
clear
Write-Host
Write-Host "Checking your installed version of the MicrosoftTeams PowerShell module is up-to-date"
if ((Get-Module MicrosoftTeams -ListAvailable).version -lt $currentMSPVersion) {
    Write-Host
    Write-Host "Your MicrosoftTeams PowerShell module is not up-to-date" -ForegroundColor Yellow -BackgroundColor Red
    Write-Host
    Write-Host "We'll attempt to update the module version now"
    pause
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host "**************************************" -ForegroundColor Yellow
    Write-Host "Updating module to version $($currentMSPVersion)" -ForegroundColor Yellow
    Write-Host "This may take 2-3 minutes" -ForegroundColor Yellow
    Write-Host "**************************************" -ForegroundColor Yellow
    Write-Host
    Write-Host "Removing old module version $((Get-Module MicrosoftTeams -ListAvailable).version)..."
    Uninstall-Module MicrosoftTeams -AllVersions -Confirm:$false -Force -AllowPrerelease
    Write-Host "Complete" -ForegroundColor Green
    Write-Host "Installing module version $($currentMSPVersion)..."
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module MicrosoftTeams -Confirm:$false -Force
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
    Write-Host "Complete" -ForegroundColor Green
}


clear
#$userLogin = Get-UserUPN

#Check first, then connect to the Skype for Business PowerShell module 
Write-Host
Write-Host "Logging onto the Microsoft Teams - Skype For Business Powershell Module"

$activeTeamsSessions = Get-PSSession | Where-Object -FilterScript {$_.Name -like 'SfBPowerShellSessionViaTeamsModule*'}

if ($activeTeamsSessions.count -gt 1) {
    Write-Host 
    Write-Host "We've found $($activeTeamsSessions.count) sessions logged in already. Closing all sessions before continuing" -ForegroundColor Yellow
    $activeTeamsSessions | Remove-PSSession
    Write-Host "Sessions closed" -for Green
    Write-Host
}

If ((Get-PSSession | Where-Object -FilterScript {$_.Name -like 'SfBPowerShellSessionViaTeamsModule*'}).State -eq 'Opened') {
	Write-Host 'Using existing session credentials'}
Else {
    Try
    {
        Write-Host
        Write-Host "Please complete the login using the pop-up login dialog box"
        $skypeConnection = New-CsOnlineSession
        Write-Host "Importing your session..."
	    Import-PSSession $skypeConnection -OutVariable null -AllowClobber
    }
    Catch
    {
        Write-Host ""
        Write-Host "Login failed" -BackgroundColor Red -ForegroundColor Yellow
        Write-Host
        Write-Host "Please try and re-run the script" -ForegroundColor Yellow
        Write-Host
        Pause
        break
    }
}

$tenant = Get-CsTenant | Select DisplayName
Write-Host
Write-Host
Write-Host "The tenant you've connected to is: $($tenant.DisplayName)" -BackgroundColor Yellow -ForegroundColor Black
Write-Host
Write-Host "You're ready to run any further scripts from the SBC Connect website now"
Write-Host
````
