# Trouleshooting user provisioning issues

## Management object not found for identity {USERNAME}
This is often a fault found when using an on-prem server and syncing Active Directory to Azure Active Directory.\
The fault is caused by either:
- The users account hasn't correctly updated in the On-Prem AD when migrating from Skype for Business to Teams\
  This can be verified by [Logging onto the Skype for Business Online Powershell Module](connecting-to-sfbo-ps-module.md) then running the following command, replacing the variable "USERNAME" with the users UPN.\
  The output of the command will explain an issue with the setting **msRTCSIP-DeploymentLocator** property in your local Active Directory if this is the cause of the error.\
  An example of the error is
  > <ErrorDescription>Cannot generate SIP address. Reason=[The value of the msRTCSIP-DeploymentLocator property in your local Active Directory is set to [SRV:] but the value of the msRTCSIP-PrimaryUserAddress property is NULL. Correct the value of the msRTCSIP-PrimaryUserAddress property in your local Active Directory for this user and ensure the property is being synced via Azure Active Directory Connect]</ErrorDescription>
  
  PowerShell script to run
  ````PowerShell
  Get-CsOnlineUser -Identity "USERNAME" | Select-Object DisplayName, UserPrincipalName, MCOValidationError | Format-List
  ````
  - Open AD Users and Computers On-Prem
  - Ensure that **View** > **Advanced Features** is selected
  - Locate and open the user account
  - Select the **Attribute Editor** tab
  - Locate the line item **msRTCSIP-DeploymentLocator**
    - This property is possibly set to **SRV:** already and you'll need to remove this
  - Update this to **sipfed.online.lync.com**
  - After updateing this, you may have to wait 6-24 hours for changes to sync from on-prem to the cloud and update in the Teams Online services
- OR The user doesn't have a skype license. You may need to remove the license, wait 5 minutes then re-add the license

When setting a number on a **Resource Account** and you get this error, then you'll need to:
- convert the account back to a user account
- remove any meeting room licenses
- assign a user Office/Microsoft 365 license with the Microsoft Phone System entitlement
- assign the phone number
- convert the account back to a meeting room
- re-assign any meeting room licenses to the account




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
````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````powershell
## TO BE BUILT
````
