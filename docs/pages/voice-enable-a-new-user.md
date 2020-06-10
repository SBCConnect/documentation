## How to voice enable a new or existing user
Users in Microsoft 365 require several licenses and setting changes before they are able to call using Direct Routing in Microsoft Teams

## Requirements
- Users require a **Microsoft 365 Phone System** license. Refer [Here](https://github.com/SBCConnect/documentation/blob/master/docs/pages/License-Requirements.md#license-requirements-for-microsoft-teams-direct-routing) for more information.

## PowerShell
**You need to update the following details in the two (2) lines below**
- {UPN} - User 
- {DID_NUMBER} - The number for the user in E.164 format (eg: +61255558888)

```powershell
#Connect to the Skype for Business PowerShell module 
$skypeConnection = New-CsOnlineSession 
Import-PSSession $skypeConnection -AllowClobber 

#Confirm you’re logged into the correct tenant - Is it the correct name?
Get-CsTenant | Select DisplayName 

#Give the user a DID number and Voice Enable the user 
Set-CsUser -Identity "{UPN}" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:{DID_NUMBER} 

#Grant the user a Voice Policy 
Grant-CsOnlineVoiceRoutingPolicy -Identity "{UPN}" -PolicyName Australia 
```
