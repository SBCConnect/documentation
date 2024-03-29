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
Connect-MicrosoftTeams
````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
````PowerShell
####
# Login script Version 0.5.0
# 2022/06/28 - Jay Antoney
#
# Changes
# - 0.4 - Update to use the new Connect-MicrosoftTeams login action
# - 0.4 - Now checks for an ExecutionPolicy = Bypass
# - 0.4.1 - Update for MicrosoftTeams module version check
# - 0.4.2 - Update to remove several checks blocking the login
# - 0.4.3 - Force to use MicrosoftTeams PS module version 2.0.0
# - 0.4.4 - Add in additional error message
# - 0.4.5 - Update to new Teams PS module v2.3.0
# - 0.4.6 - Update to new Teams PS module v2.3.1
# - 0.4.7 - Update to new Teams PS module v3.0.0
# - 0.5.0 - Update to new Teams PS module v4.1.1
# 
# Required Changes at a later date
# - {nill}
#
# Any issues running script, try run the script on Windows 10 V20H2 or higher
#
####

$requiredMSTeamsPSModuleVersion = "4.4.1"

#################################
#
#
#       START SCRIPT HERE
#
#
#################################
Clear
#Check the ExecutionPolicy is set to Bypass
    write-host
    Write-Host "Checking the computers Execution Policy..." -ForegroundColor Yellow
    Write-Host
    $currentExecutionPolicy = Get-ExecutionPolicy
    $counter = 0
    while ($currentExecutionPolicy -ne 'Bypass') {
        if ($counter -gt 2) {
            clear
            write-host
            Write-Host "We've tried several times to update the Execution Policy on this PowerShell instance but was unable to" -ForegroundColor Yellow
            Write-Host "The script will now exit" -ForegroundColor Yellow
            Write-Host
            pause
            $global:mainLoop = $false
            break
        }
        Write-Host "The Execution Policy is currently set to '$($currentExecutionPolicy)' and should be set to 'Bypass'"
        Write-Host "You may be prompted to accept a pop up prompt to change the policy"
        Write-Host
        Pause
        Set-ExecutionPolicy -ExecutionPolicy Bypass
        $counter++
        $currentExecutionPolicy = Get-ExecutionPolicy
    }


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


$installedMSTAllVersions = (Get-Module MicrosoftTeams -ListAvailable).version
#Check the Microsoft Teams Powershell Module is installed
#if(-not (Get-Module MicrosoftTeams -ListAvailable)) { #This line is for when we can stay current
if($installedMSTAllVersions -notcontains $requiredMSTeamsPSModuleVersion) {
    Write-host "The MicrosoftTeams PowerShell module is not installed or at the wrong version and must be installed before continuing!" -ForegroundColor Yellow -BackgroundColor Red
    Write-Host "Required version: $($requiredMSTeamsPSModuleVersion)"
    Write-Host
    Write-Host "We'll attempt to install the module now..." -ForegroundColor Yellow
    Pause
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host "Installing - Please hold..." -ForegroundColor Yellow
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module MicrosoftTeams -Confirm:$false -Force -RequiredVersion $requiredMSTeamsPSModuleVersion
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
    Write-Host
    Write-Host
    if(-not (Get-Module MicrosoftTeams -ListAvailable)) {
        Write-host "The MicrosoftTeams PowerShell module seems to not be installing correctly" -ForegroundColor Yellow -BackgroundColor Red
        Write-host "Please try to install the module manually by running the following command in an elevated PowerShell screen" -ForegroundColor Yellow
        Write-host "" -ForegroundColor Yellow -BackgroundColor Red
    }
    Write-Host "Complete" -foregroundcolor Green
    Write-Host 
    Write-Host 
    Write-Host -----------------------------------------------------
    Write-Host - YOU MUST RESTART POWERSHELL AND RE-RUN THE SCRIPT -
    Write-Host -----------------------------------------------------
    Write-Host
    Write-Host
    Pause
    Exit
}

#Enclose in TRY loop to detect if the machine has an older version of the PowerShellget command that doesn't include the -AllowPrerelase parameter, This is generally Windows 10 V1903 or older
Clear
Write-Host
Write-Host "Checking the current and installed versions of PowerShellGet Module..."
Write-Host
Try {$MPTVersionList = Find-Module PowerShellGet -AllowPrerelease -Allversions}
Catch [System.Management.Automation.ParameterBindingException]{
    if ((Get-Module PowerShellGet).Version -lt "1.6.0") {
        $currentMPSGVersion = (Find-Module PowerShellGet).Version
        Clear
        Write-Host
        Write-Host "-------------------------------------------------------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "An old version of PowerShellGet has been detected - Installed version is $($(Get-Module PowerShellGet).Version) - Minimum required is 1.6.0" -ForegroundColor Yellow
        Write-Host "We're going to attempt to install a new version of the PowerShellGet module" -ForegroundColor Yellow
        Write-Host "If there are any issues, please upgrade your computer to Windows 10 v1909 or higher, then re-run this script" -ForegroundColor Yellow
        Write-Host "-------------------------------------------------------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host
        Pause
        Write-Host
        Write-Host "**************************************" -ForegroundColor Yellow
        Write-Host "Updating module to version $($currentMPSGVersion)" -ForegroundColor Yellow
        Write-Host "This may take 2-3 minutes" -ForegroundColor Yellow
        Write-Host "**************************************" -ForegroundColor Yellow
        Write-Host
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        Install-Module PowerShellGet -Force -AllowClobber
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
        $installedMPSGVersion = Get-Module PowerShellGet -ListAvailable | Sort-Object -Property Version -Descending
        if ($installedMPSGVersion[0].Version -ne $currentMPSGVersion) {
            Write-Host
            Write-Host
            Write-Host "An unknown error has occured trying update the Microsoft PowerShellGet Powershell Module. The script cannot continue." -ForegroundColor Red
            Write-Host
            Pause
            Break
        } else {
            #Module installed
            Clear
            Write-Host
            Write-Host
            Write-Host
            Write-Host
            Write-Host
            Write-Host
            Write-Host
            Write-Host "The PowerShell module PowerShellGet has been updated, however this requires a restart of PowerShell" -ForegroundColor Yellow
            Write-Host "Please close and re-open PowerShell, then re-run the script" -ForegroundColor Yellow
            Write-Host
            pause
            Clear
            Write-Host 
            Write-Host 
            Write-Host -----------------------------------------------------
            Write-Host - YOU MUST RESTART POWERSHELL AND RE-RUN THE SCRIPT -
            Write-Host -----------------------------------------------------
            Write-Host
            Write-Host
            Pause
            Exit
        }
    } else {
        Write-Host "An unknown error has occured trying to get the current Microsft PowerShellGet module version. The script cannot continue." -ForegroundColor Red
        Write-Host
        Pause
        Break
    }
}
Catch {Write-Host "An unknown error has occured trying to get the current Microsft PowerShellGet module version. The script cannot continue." -ForegroundColor Red; Write-Host; Pause; Break}


#Importing the current Microsoft Teams Version 
Write-Host
Write-Host "Importing the Microsoft Teams PowerShell module version $($requiredMSTeamsPSModuleVersion)..."
Write-Host
Import-Module -Name MicrosoftTeams -RequiredVersion $requiredMSTeamsPSModuleVersion

clear
#$userLogin = Get-UserUPN

#Check first, then connect to the Skype for Business PowerShell module 
Write-Host
Write-Host "Checking for an active connection to Microsoft Teams PowerShell module..."
Write-Host


Try
{
    Write-Host
    Write-Host "Please complete the login using the pop-up login dialog box"
    #$skypeConnection = New-CsOnlineSession -ErrorAction SilentlyContinue
    #Write-Host "Importing your session..."
    #Import-PSSession $skypeConnection -OutVariable null -AllowClobber
    Connect-MicrosoftTeams
}
Catch
{
    Write-Host 
    Write-Host "Login failed" -BackgroundColor Red -ForegroundColor Yellow
    Write-Host
    Write-Host "Please try and re-run the script" -ForegroundColor Yellow
    Write-Host
    Pause
    break
}

$tenant = Get-CsTenant | Select DisplayName
Write-Host
Write-Host
Write-Host "The tenant you've connected to is: $($tenant.DisplayName)" -BackgroundColor Yellow -ForegroundColor Black
Write-Host
Write-Host "You're ready to run any further scripts from the SBC Connect website now"
Write-Host
````
