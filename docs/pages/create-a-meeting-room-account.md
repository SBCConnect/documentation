# How to create a Teams Meeting Room account
A Teams meeting room account is a normal user account that has been:
- Assigned a Meeting Room License
- Assigned a DID number (if using Direct Routing)
- Migrated to a Meeting Room account type

## Steps
Caution: Any PSTN/DID phone numbers must be assigned to the account before it's migrated to a room account. Failure to do so may result in an error.\
Error: Unable to set "LineURI". This parameter is restricted within Remote Tenant PowerShell.\
See troubleshooting on this page for further information

## PowerShell
<i class="fas fa-terminal"></i> **Raw PowerShell Code**

````PowerShell
####################################################
# There are multiple variables to replace here
# Code also includes setting up a teams meeting room group and assigning a room to it
#
# <UPN> - A username for the room
# <Name> - A name for the room
# <ALIAS> - A name, without spaces and special charactures, to be used as an alias for the room. (IE: start of the username before the @ symbol)
# <PASSWORD> - A password for the account
# <PHONE_NUMBER> - A DID number to use for the account in E.164 format (IE: +61399995555)
# <OFFICE> - Office Location. This is just a value in Azure AD and not linked to anything else
# <DIST_SMTP> - A valid, unused SMTP address to assign to the Distribution List
# <DIST_NAME> - The name of the room group (IE: HOBART - 31 JONES ST)
####################################################

## Connect to Exchange Online
Connect-ExchangeOnline
New-Mailbox -Name "<Name>" -Alias <ALIAS> -Room -EnableRoomMailboxAccount $true -MicrosoftOnlineServicesID <UPN> -RoomMailboxPassword (ConvertTo-SecureString -String '<PASSWORD>' -AsPlainText -Force)
Set-Mailbox -Identity <UPN> -Office <OFFICE>
Set-CalendarProcessing -Identity <UPN> -AutomateProcessing AutoAccept -AddOrganizerToSubject $false -DeleteComments $false -DeleteSubject $false -RemovePrivateProperty $false -AddAdditionalResponse $true -AdditionalResponse "<Name>"
New-DistributionGroup -Name "<DIST_NAME>" –PrimarySmtpAddress <DIST_SMTP> –RoomList
Add-DistributionGroupMember -Identity <DIST_SMTP> -Member <UPN>

## Connect Azure AD
Connect-AzureAD
Set-AzureADUser -ObjectID <UPN> -PasswordPolicies DisablePasswordExpiration -TelephoneNumber <PHONE_NUMBER>


## Connect to Microsoft Teams Powershell Module version 2.0.0
## THIS MUST BE VERSION 2.0.0 and no higher!
Import-Module -Name MicrosoftTeams -RequiredVersion 2.0.0
Write-Host
Write-Host "Did that Import-Module command work?" -ForegroundColor Yellow
Write-Host "If no, then you might need to install the required version of the Microsoft Teams module by running"
Write-Host "Install-Module MicrosoftTeams -Confirm:$false -Force -RequiredVersion 2.0.0"
Write-Host
Write-Host "Exit here if you need to install first, else..." -ForegroundColor Red
Pause
Write-Host
Write-Host
Connect-MicrosoftTeams
Write-host
Write-host "You must assign a Meeting Room license to the account and a phone number before continuing" -foregroundcolor yellow
Write-host
Write-host "1. Assign the License" -foregroundcolor yellow
Write-host "2. Assign a phone number by running: Set-CsUser -Identity <UPN> -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:<PHONE_NUMBER>" -foregroundcolor yellow
Write-host
Write-host ">> DO NOT CONTINUE UNTIL YOU HAVE DONE THIS <<" -foregroundcolor yellow
pause
$regPool = Get-CsOnlineUser -Identity <UPN> | Select -Expand RegistrarPool
Enable-CsMeetingRoom -Identity <UPN> -RegistrarPool $regPool -SipAddressType EmailAddress
````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ This script assumes that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````PowerShell
#Refer to the Raw Powershell Code for now
````
