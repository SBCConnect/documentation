# License Requirements for Microsoft Teams Direct Routing
> Applies to: Direct Routing only

## User Licenses
> 🌐 [Microsoft: Direct Routing Licensing](https://docs.microsoft.com/en-us/microsoftteams/direct-routing-plan#licensing-and-other-requirements)\
> 🌐 [Microsoft Business Voice License Requreiements](https://docs.microsoft.com/en-us/MicrosoftTeams/business-voice/whats-business-voice)

> **Microsoft 365 Business Voice (without calling plan)** provides the same features as the **Microsoft Phone System** add-on, however it includes a provisioning wizard for the 365 portal and was released into the Australian market in JULY 2020. The price of the **Business Voice** add-on is higher than the **Phone System** add-on.

Users require a valid license which is available as an add-on or included in:
- Microsoft 365 Business Basic + Microsoft 365 Business Voice (without calling plan) add-on; OR
- Microsoft 365 Business Standard + Microsoft 365 Business Voice (without calling plan) add-on; OR
- Microsoft 365 Business Premium + Microsoft 365 Business Voice (without calling plan) add-on; OR
- Microsoft 365 F1 + Microsoft Phone System add-on; OR
- Microsoft 365 F3 + Microsoft Phone System add-on; OR
- Office 365 F3 + Microsoft Phone System add-on; OR
- Microsoft and Office 365 Enterprise E1, E3 + Microsoft Phone System add-on; OR
- Microsoft and Office 365 Enterprise E5; OR
- Microsoft 365 and Office 365 Education A1, A3 + Microsoft Phone System add-on; OR
- Microsoft 365 and Office 365 Education A5; OR
- Microsoft 365 and Office 365 Government G1, G3 (GCC only) + Microsoft Phone System add-on; OR
- Microsoft 365 and Office 365 Government G5 (GCC only); OR
- Microsoft 365 Nonprofit Business Basic + Microsoft 365 Business Voice (without calling plan) add-on; OR
- Microsoft 365 Nonprofit Business Standard + Microsoft 365 Business Voice (without calling plan) add-on; OR
- Microsoft 365 and Office 365 Nonprofit E1, E3 + Microsoft Phone System add-on; OR
- Microsoft 365 and Office 365 Nonprofit E5.

Other Considerations
- The SBC Connect platform uses **Microsoft Direct Routing** and not **Microsoft Call Packs** \
  Therefore, if looking at documentation on the Microsoft website, please ignore any references to Microsoft Call Packs


## Common Voice mailboxes
> 🌐 [Voicemail Setup Reference](cloud-voicemail.md#microsoft-teams-cloud-voicemail)
Voicemails received to a Common Voice Mailboxe are delivered to an Office 365 Group and therefore don't require a Microsoft Teams license for Voice.

### Delivering common voicemails to user or shared mailboxes
However if you forward these emails to a User or Shared Mailbox, then this needs to be done using Microsoft Power Automate and therefore requires a user account with an included Microsoft Power Automate Standard license. These are included in most Office 365 and Microsoft 365 subscriptions. Separate Microsoft Power Automate Per-User or Per-Flow license is not required. \
It's recommended to use a service type account for this instead of an employee incase the use leaves or the account is changed in any way.\
The minimum required license for this account is **Microsoft 365 Business Basic**. No **Microsoft 365 Business Voice (without calling plan)** is required for this account

## Auto Attendants and Call Queues
> 🌐 [Microsoft: Virtual User License](https://docs.microsoft.com/en-us/microsoftteams/teams-add-on-licensing/virtual-user)

Auto Attendants and Call Queues that need a DID number assigned to it require a free **Microsoft 365 Phone System - Virtual User** license.

These can be obtained through the Microsoft Admin Portal
- Navigate to the Microsoft Admin Portal
  - https://admin.microsoft.com
- Click **Billing** > **Purchase Services**
- Search for and purchase the free **Microsoft 365 Phone System - Virtual User** license

Every Microsoft 365 tenant that includes a minimum of 1 **Microsoft 365 Phone System** license is allowed up to 25 free **Microsoft 365 Phone System - Virtual User** licenses.
For every 10 additional phone system licenses purchased, the tenant is eligible for an additonal 1 free **Microsoft 365 Phone System - Virtual User** license.
