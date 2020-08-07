# Check a users configuration
The aim of this script is to check the users configuration and highlight any issues that may be preventing the user from using Microsoft Teams Phone System

This script can be used to:
- Troubleshoot a users that isn't working
- Verify a newly deployed user is correctly configured

## Usage
Copy and paste the script into a new PowerShell window. You will be prompted for the users UPN name.
The Skype for Business Online PowerShell module is required. If not installed, you can obtain it from 🌐 [Here](https://www.microsoft.com/en-us/download/details.aspx?id=39366)

## PowerShell script
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

    return $UserUPN
}

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

#Check we're connected - exit if not
If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -ne 'Opened') {write-host "Unable to connect to online services. Please try the connection again." -BackgroundColor Red -ForegroundColor White; pause; break}

#Confirm you’re logged into the correct tenant - Is it the correct name?
$tenant = Get-CsTenant | Select DisplayName
$tenantName = $tenant.DisplayName
Write-Host ""
Write-Host "The tenant you've connected to is: $tenantName" -BackgroundColor Yellow -ForegroundColor Black
$tenantCorrect = Read-Host "Is this the correct tenant? (y/n)"
while("y","n" -notcontains $tenantCorrect )
{
 $tenantCorrect = Read-Host "Is this the correct tenant? (y/n)"
}
if ($tenantCorrect -eq 'n') {exit}

$UserUPN = Get-UserUPN

$UserDetail = $null
$UserDetail = Get-CSOnlineUser -Identity "$UserUPN" | Select UserPrincipalName, EnterpriseVoiceEnabled, HostedVoiceMail, OnPremLineURI, OnPremEnterpriseVoiceEnabled, DisplayName, TeamsUpgradeEffectiveMode, HostedVoicemailPolicy, OnlineVoiceRoutingPolicy 

While ($UserDetail -eq $null)
{
    write-host "Unable to find user. Please try again." -BackgroundColor Red -ForegroundColor White
    $UserUPN = Get-UserUPN
    $UserDetail = $null
    $UserDetail = Get-CSOnlineUser -Identity "$UserUPN" | Select UserPrincipalName, EnterpriseVoiceEnabled, HostedVoiceMail, OnPremLineURI, OnPremEnterpriseVoiceEnabled, DisplayName, TeamsUpgradeEffectiveMode, HostedVoicemailPolicy, OnlineVoiceRoutingPolicy 
}

Write-Host ""
Write-Host "-----------------"
Write-Host "DisplayName: $($UserDetail.DisplayName)"
Write-Host "Username: $($UserDetail.UserPrincipalName)"
Write-Host "Hosted Voicemail Policy: $($UserDetail.HostedVoicemailPolicy)"
Write-Host "DID Number: $($UserDetail.OnPremLineURI)"
Write-Host "Online Voice Routing Policy: $($UserDetail.OnlineVoiceRoutingPolicy)"

if ($UserDetail.OnPremEnterpriseVoiceEnabled -eq $true) {Write-Host "ERROR: OnPremEnterpriseVoiceEnabled = TRUE - User must be migrated to an Online only User to use Teams" -BackgroundColor Red -ForegroundColor White} else {Write-Host "PASS: OnPremEnterpriseVoiceEnabled = FALSE" -BackgroundColor Green -ForegroundColor Black}
if ($UserDetail.EnterpriseVoiceEnabled -eq $true) {Write-Host "PASS: EnterpriseVoiceEnabled = TRUE" -BackgroundColor Green -ForegroundColor Black} else {Write-Host "ERROR: EnterpriseVoiceEnabled = FALSE - Run Set-CsUser with the '-EnterpriseVoiceEnabled $true' option to resolve" -BackgroundColor Red -ForegroundColor White}

switch ($UserDetail.TeamsUpgradeEffectiveMode){
	"TeamsOnly" {Write-Host "PASS: TeamsUpgradeEffectiveMode = TeamsOnly" -BackgroundColor Green -ForegroundColor Black}
	default {Write-Host "ERROR: TeamsUpgradeEffectiveMode = $($UserDetail.TeamsUpgradeEffectiveMode) - Users may be unable to receive calls from Call Queues and Auto Attendants. User must be in TeamsOnly mode" -BackgroundColor Red -ForegroundColor White}
}

switch ($UserDetail.HostedVoicemail){
	"True" {Write-Host "PASS: HostedVoicemail = True" -BackgroundColor Green -ForegroundColor Black}
	default {Write-Host "ERROR: HostedVoicemail = $($UserDetail.HostedVoicemail) - Users voicemail not hosted online. Run Set-CsUser with the '-HostedVoiceMail $true' option to resolve" -BackgroundColor Red -ForegroundColor White}
}

Write-Host "-----------------"

pause
````
