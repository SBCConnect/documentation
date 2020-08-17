# Trouleshooting user provisioning issues

## Management object not found for identity {USERNAME}
This is often a fault found when using an on-prem server and syncing Active Directory to Azure Active Directory.\
The fault is caused by the users **Logon Name** and **pre-Windows 2000 logon name** being different.
**FIX PENDING**


## No dial pad for a voice enabled user
- Ensure that the user is correctly licensed and a number assigned
  This can be done by running the [check a users configuration](check-user-configuration.md) scripts on the SBC Connect website
- Using PowerShell, remove and re-add the Voice Routing Policy

**You need to update the following details in the two (2) lines below**
- {UPN} - User 
- {POLICY_NAME} - The name of the Voice Routing Policy to apply to the user

<i class="fas fa-terminal"></i> **Raw PowerShell Code**

````PowerShell
  # Remove the voice routing policy from the user
  Grant-CsOnlineVoiceRoutingPolicy -Identity {UPN} -PolicyName $Null
  
  # Add in the 
  Grant-CsOnlineVoiceRoutingPolicy -Identity {UPN} -PolicyName {POLICY_NAME}
```

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

```powershell
## TO BE BUILT
```
