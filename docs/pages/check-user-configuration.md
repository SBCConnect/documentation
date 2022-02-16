# Check a users configuration
The aim of this script is to check the users configuration and highlight any issues that may be preventing the user from using Microsoft Teams Phone System

This script can be used to:
- Troubleshoot a users that isn't working
- Verify a newly deployed user is correctly configured

## Usage
Copy and paste the script into a new PowerShell window. You will be prompted for the users UPN name.
The Skype for Business Online PowerShell module is required. If not installed, you can obtain it from 🌐 [Here](https://www.microsoft.com/en-us/download/details.aspx?id=39366)

## PowerShell
<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

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

Clear-Host
Write-Host "Check a single user account for provisioning issues" -ForegroundColor Yellow
Write-Host
$UserUPN = Get-UserUPN

$UserDetail = $null
write-host "Checking for a user account with UPN: $($UserUPN)" -ForegroundColor Yellow
$UserDetail = Get-CSOnlineUser -Identity "$UserUPN" | Select UserPrincipalName, EnterpriseVoiceEnabled, HostedVoiceMail, OnPremLineURI, OnPremEnterpriseVoiceEnabled, DisplayName, TeamsUpgradeEffectiveMode, HostedVoicemailPolicy, OnlineVoiceRoutingPolicy, TenantDialPlan

While ($UserDetail -eq $null)
{
    write-host "Unable to find user. Please try again." -BackgroundColor Red -ForegroundColor White
    write-host
    $UserUPN = Get-UserUPN
    $UserDetail = $null
    write-host "Checking for a user account with UPN: $($UserUPN)" -ForegroundColor Yellow
    $UserDetail = Get-CSOnlineUser -Identity "$UserUPN" | Select UserPrincipalName, EnterpriseVoiceEnabled, HostedVoiceMail, OnPremLineURI, OnPremEnterpriseVoiceEnabled, DisplayName, TeamsUpgradeEffectiveMode, HostedVoicemailPolicy, OnlineVoiceRoutingPolicy, TenantDialPlan
}

Clear-Host

Write-Host "User troubleshooting result" -ForegroundColor Magenta
Write-Host
Write-Host "-----------------"
Write-Host "DisplayName: $($UserDetail.DisplayName)"
Write-Host "Username: $($UserDetail.UserPrincipalName)"
Write-Host "Hosted Voicemail Policy: $($UserDetail.HostedVoicemailPolicy)"
Write-Host "DID Number: $($UserDetail.OnPremLineURI)"

Write-Host "Online Voice Routing Policy    = $($UserDetail.OnlineVoiceRoutingPolicy)" -NoNewline
if ($UserDetail.OnlineVoiceRoutingPolicy) {Write-Host " - " -NoNewline; Write-Host "Pass" -ForegroundColor Green} else {Write-Host "BLANK - " -NoNewline; Write-Host "FAIL" -ForegroundColor Red}

Write-Host "Tenant Dial Plan               = $($UserDetail.TenantDialPlan)" -NoNewline
if ($UserDetail.TenantDialPlan) {Write-Host " - " -NoNewline; Write-Host "Pass" -ForegroundColor Green} else {Write-Host "BLANK - " -NoNewline; Write-Host "FAIL" -ForegroundColor Red}

Write-Host "OnPremEnterpriseVoiceEnabled   = $($UserDetail.OnPremEnterpriseVoiceEnabled) - " -NoNewline
if ($UserDetail.OnPremEnterpriseVoiceEnabled -eq $false) {Write-Host "Pass" -ForegroundColor Green} else {Write-Host "FAIL" -ForegroundColor Red; Write-Host "  User must be migrated to an Online only User to use Teams" -ForegroundColor Yellow}

Write-Host "EnterpriseVoiceEnabled         = $($UserDetail.EnterpriseVoiceEnabled) - " -NoNewline
if ($UserDetail.EnterpriseVoiceEnabled -eq $true) {Write-Host "Pass" -ForegroundColor Green} else {Write-Host "FAIL" -ForegroundColor Red; Write-Host "  Users voicemail not hosted online. Run Set-CsUser with the '-EnterpriseVoiceEnabled `$true' option to resolve" -ForegroundColor Yellow}

Write-Host "TeamsUpgradeEffectiveMode      = $($UserDetail.TeamsUpgradeEffectiveMode) - " -NoNewline
if ("TeamsOnly" -eq $UserDetail.TeamsUpgradeEffectiveMode) {Write-Host "Pass" -ForegroundColor Green} else {Write-Host "FAIL" -ForegroundColor Red; Write-Host "  Users may be unable to receive calls from Call Queues and Auto Attendants. User must be in TeamsOnly mode" -ForegroundColor Yellow}

Write-Host "HostedVoicemail                = $($UserDetail.HostedVoicemail) - " -NoNewline
if ($UserDetail.HostedVoicemail -eq $true) {Write-Host "Pass" -ForegroundColor Green} else {Write-Host "FAIL" -ForegroundColor Red; Write-Host "  Users voicemail not hosted online. Run Set-CsUser with the '-HostedVoiceMail `$true' option to resolve" -ForegroundColor Yellow}

Write-Host "-----------------"

Write-Host "User's Call Forward Settings... loading"
Write-Host

Get-CsUserCallingSettings -Identity $UserDetail.UserPrincipalName

Write-Host
Write-Host "-----------------"


    write-host
    write-host
    write-host
    Write-Host "Thanks for using this script" -ForegroundColor Yellow
    Write-Host
    Write-Host "For bug, feedback and comments, please see the SBC Connect GitHub"
    Write-Host "https://github.com/sbcconnect"
    Write-Host
    pause


````
