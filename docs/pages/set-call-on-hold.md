# Call on Hold / Busy on Busy Status

Microsoft Teams allows 2 different settings for configuring Call on Hold or Busy on Busy settings.
> 🌐 [Microsoft Docs - Set-CsTeamsCallingPolicy](https://docs.microsoft.com/en-us/powershell/module/skype/set-csteamscallingpolicy?view=skype-ps)\
> Reference: **-BusyOnBusyEnabledType**

Setting this parameter lets you configure how incoming calls are handled when a user is already in a call or conference or has a call placed on hold.
Valid options are:
  - **Enabled**
    - With a Direct call direct to the users DID number, the call will be rejected with a busy signal.
    - When a call comes in via a Call Queue, the call will be {NEED TO UPDATE}
  - **Unanswered**
    - With a Direct call direct to the users DID number, the user's unanswered settings will take effect, such as routing to voicemail or forwarding to another user.
    - When a call comes in via a Call Queue, the call will be {NEED TO UPDATE}
  - **Disabled**
    - Calls will be presented to the user.
    - Also applies if the value is set to UserOverride.
  
## Calling Policy
> The name of a **Calling Policy** within the tenancy can be obtained under the [Microsoft Teams Admin Centre]{https://admin.teams.microsoft.com) under **Voice** > **Calling policies**.\
These settings apply to a **Calling policy** withing the tenant and not individual users. For example you may want Call Waiting enabled for all users except the receiptionist.\
In this case you would
  - **Disable** the **BusyOnBusyEnabledType** for the **Global** policy; then
  - Create a new policy with the setting **Enabled** or **Unanswered** and assign that new policy to the receptionist users.


## Microsoft Teams Admin Centre (GUI)
These settings are able to be updated through the [Microsoft Teams Admin Centre]{https://admin.teams.microsoft.com) under **Voice** > **Calling policies**.\
Changes may take up to 60 minutes to push out to users


## PowerShell
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````PowerShell
Set-CsTeamsCallingPolicy -Identity <PolicyName> -BusyOnBusyEnabledType <Enabled or Unanswered or Disabled>
````
