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
function Get-UserUPN {
    #Regex pattern for checking an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    #Get the users UPN
    Write-Host ""
    $UserUPN = Read-Host "Please enter in the users full UPN"
    while($UserUPN -notmatch $EmailRegex)
    {
     Write-Host "$UserUPN isn't a valid UPN" -BackgroundColor Red -ForegroundColor White
     $UserUPN = Read-Host "Please enter in the users full UPN"
    }

    Clear-Variable OverrideAdminDomain

    $msOnlineRegex = '^([\w-\.]+)@([a-zA-Z0-9]+)\.onmicrosoft\.com$'
    If($UserUPN -notmatch $msOnlineRegex) 
    {
        Write-Host "It seems you've entered a UPN not ending in onmicrosoft.com. This is OK, however we need to get that domain to be able to login" -ForegroundColor Yellow
        $OverrideAdminDomain = Read-Host "Please enter in your ______.onmicrosoft.com prefix"
        $checkDomain = $true

        while ($checkDomain)
        {
            If($OverrideAdminDomain -like '*.onmicrosoft.com')
            {
                $rootDomain = $OverrideAdminDomain.Substring(0, ($OverrideAdminDomain.Length - 16))
                If($rootDomain -inotmatch '^[a-zA-Z0-9]+$')
                {
                    Write-Host "Prefix not valid" -ForegroundColor Yellow
                } else {
                    $checkDomain = $false
                }
            } else {
                If($OverrideAdminDomain -notmatch '^[a-zA-Z0-9]+$')
                {
                    Write-Host "Prefix not valid" -ForegroundColor Yellow
                } else {
                    $checkDomain = $false
                    $OverrideAdminDomain = "$OverrideAdminDomain.onmicrosoft.com"
                }
            }

            If($checkDomain -ne $false) {$OverrideAdminDomain = Read-Host "Please enter in your ______.onmicrosoft.com prefix"}
        }

        while($OverrideAdminDomain -match $msOnlineRegex)
        {
         Write-Host "$UserUPN isn't a valid UPN" -BackgroundColor Red -ForegroundColor White
         $UserUPN = Read-Host "Please enter in the users full UPN"
        }
    }

    return $OverrideAdminDomain
}

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

$OverrideAdminDomain = Get-UserUPN

#Check first, then connect to the Skype for Business PowerShell module 
Write-Host "Logging onto Skype for Business Online Powershell Module" -BackgroundColor Yellow -ForegroundColor Black
If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened') {
	Write-Host 'Using existing session credentials'}
Else {
	if($OverrideAdminDomain) {
        	$skypeConnection = New-CsOnlineSession -OverrideAdminDomain $OverrideAdminDomain
    	} else {
        	$skypeConnection = New-CsOnlineSession
    	}
	Import-PSSession $skypeConnection -AllowClobber
}

$tenant = Get-CsTenant | Select DisplayName
Write-Host ""
Write-Host "The tenant you've connected to is: $($tenant.DisplayName)" -BackgroundColor Yellow -ForegroundColor Black
````
