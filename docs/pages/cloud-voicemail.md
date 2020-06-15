# Microsoft Teams Cloud Voicemail
<i class="fas fa-link"></i> [Skip to Common Voice Mailboxes](#common-voice-mailboxes)

## User Voice Mailboxes
A user voice mailbox is inlcuded in a correctly licensed Microsoft Phone System user. The Hosted Voicemail is off by default, however is inlcuded in the SBC Connect user configuration scripts 🌐 [Here](voice-enable-a-new-user.html).

### PowerShell
To confirm that the user is already enabled, or to enable it for a user where it's disable, you can use the following PowerShell commands.

<i class="fas fa-clipboard"></i> To enable a Voice mailbox for a user, the user must already be Enterprise Voice Enabled

<i class="fas fa-terminal"></i> Raw PowerShell Code

````PowerShell
Set-CsUser -Identity {USER_UPN} -HostedVoiceMail $true
````

<i class="fas fa-keyboard"></i> SBC-Easy PowerShell Code
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**. <br>Connection details are [Here](connecting-to-sfbo-ps-module.md)

````PowerShell
function Get-UserUPN {
    #Regex pattern for checking an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    #Get the users UPN
    Write-Host ""
    $UserUPN = Read-Host "Please enter in the users full UPN"
    while($UserUPN -notmatch $EmailRegex)
    {
     Write-Host "$UserUPN isn't a valid UPN. A UPN looks like an email address" -BackgroundColor Red -ForegroundColor White
     $UserUPN = Read-Host "Please enter in the users full UPN"
    }
    return $UserUPN
}

Write-Host "This script will confirm a user is Enterprice Voice Enabled and will enable Hosted Voicemail" -BackgroundColor Yellow -ForegroundColor Black
$UserUPN = Get-UserUPN

# Check the user is enabled for Enterprise Voice
$usr = Get-CsOnlineUser -Identity $UserUPN | Select DisplayName, HostedVoiceMail, EnterpriseVoiceEnabled
if ($usr.EnterpriseVoiceEnabled -eq $false) {write-host "ERROR: User $($usr.DisplayName) is not Enterprise Voice Enabled. User must be Enterprise Voice Enabled before you can enable them for Hosted Voicemail" -BackgroundColor -Red -ForegroundColor White; pause; exit}

#Enable for Hosted Voicemail
Set-CsUser -Identity $UserUPN -HostedVoiceMail $true -erroraction SilentlyContinue

#Check it enabled
clear-variable usr
Start-Sleep -s 2
$usr = Get-CsOnlineUser -Identity $UserUPN | Select DisplayName, HostedVoiceMail, EnterpriseVoiceEnabled
if ($usr.HostedVoiceMail -eq $true)
  {write-host "PASS: User $($usr.DisplayName) is now Hosted Voicemail Enabled. It might take a few minutes for the service to provision." -BackgroundColor Green -ForegroundColor Black; pause; exit}
else
  {write-host "ERROR: User $($usr.DisplayName) is not Enterprise Voice Enabled. User must be Enterprise Voice Enabled before you can enable them for Hosted Voicemail" -BackgroundColor Red -ForegroundColor White; pause; exit}
````

## Common Voice mailboxes
Common Voicemails in the SBC Platform are refered to as a voice mailbox that isn't attached to a user.
For example a company might need a common voice mailbox for the general receipt of voicemails as an overflow option during the day or 
for capturing calls after hours.

Both scenarious could be a delivered as a single common voice mailbox or multiple common voice mailboxes.

Calls can only be transfered to a common voice mailboxes from within an Auto Attendant. Transfers from a Call Queue or from a user initiated transfer are not possible.

### Requirements
A Common Voice Mailbox is delivered using a Microsoft 365 Group. After configuring a Microsoft 365 Group, you're able to select it as a Voicemail routing option from an Auto Attendant.

### Setup a common voice mailbox
- Create a Microsoft 365 Group from the Microsoft Admin Portal
  - 🌐 https://admin.microsoft.com
  - This group can be the same as a group used for call queue members
- Add members to the group that you wish to have access to the voicemails
- In an Auto Attendant, Select **Redirect to** > **Voice Mail** then select the Microsoft 365 group

### Licensing
License requirements are listed under **Common Voice Mailboxes** 🌐 [Here](pages/License-Requirements.md#common-voice-mailboxes)
