## How to voice enable a new or existing user
Users in Microsoft 365 require several licenses and setting changes before they are able to call using Direct Routing in Microsoft Teams

## Requirements
- Users require a **Microsoft 365 Phone System** license. Refer 🌐 [Here](License-Requirements.md#license-requirements-for-microsoft-teams-direct-routing) for more information.

## PowerShell
**You need to update the following details in the two (2) lines below**
- {UPN} - User 
- {DID_NUMBER} - The number for the user in E.164 format (eg: +61255558888)

```powershell
#Variables to change
#DID number must be in E.164 format. IE: +61299995555
$UserUPN = "INSERT_USER_UPN_HERE"
$UserDID = "INSERT_USER_DID_NUMBER_HERE"

######## DO NOT CHANGE BELOW THIS LINE ########

#Connect to the Skype for Business PowerShell module 
$skypeConnection = New-CsOnlineSession 
Import-PSSession $skypeConnection -AllowClobber 

#Confirm you’re logged into the correct tenant - Is it the correct name?
$tenant = Get-CsTenant | Select DisplayName
$tenantName = $tenant.DisplayName
Write-Host "The tenant you've connected to is: $tenantName" -BackgroundColor Yellow -ForegroundColor Black

#Give the user a DID number and Voice Enable the user 
Set-CsUser -Identity "$UserUPN" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$UserDID

#Grant the user a Voice Policy 
Grant-CsOnlineVoiceRoutingPolicy -Identity "$UserUPN" -PolicyName Australia 
```
