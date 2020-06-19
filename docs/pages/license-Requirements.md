# License Requirements for Microsoft Teams Direct Routing
> Applies to: Direct Routing only

## User Licenses
> 🌐 [Microsoft: Direct Routing Licensing](https://docs.microsoft.com/en-us/microsoftteams/direct-routing-plan#licensing-and-other-requirements)

> Microsoft Business Voice is a different product aimed at lower license types, is not avaliable in Australia and out-of-scope for this platform and documentation.

Users require a **Microsoft Phone System** license which is available as an add-on or included in:
- Office 365 E1 + Microsoft Phone System add-on; OR
- Office 365 E3 + Microsoft Phone System add-on; OR
- Office 365 E5; OR
- Microsoft 365 E1 + Microsoft Phone System add-on; OR
- Microsoft 365 E3 + Microsoft Phone System add-on; OR
- Microsoft 365 E5.

Other Considerations
- Users do not require a Call Pack for Direct Routing voice 


## Common Voice mailboxes
> 🌐 [Voicemail Setup Reference](cloud-voicemail.md#microsoft-teams-cloud-voicemail)

Voicemails received to a Common Voice Mailboxe are delivered to an Office 365 Group and therefore don't require a Microsoft Teams license for Voice.

### Delivering common voicemails to user or shared mailboxes
However if you forward these emails to a User or Shared Mailbox, then this needs to be done using Microsoft Power Automate and therefore requires a user account with an included Microsoft Power Automate Standard license. These are included in most Office 365 and Microsoft 365 subscriptions. Separate Microsoft Power Automate Per-User or Per-Flow license is not required.\
It's recommended to use a service type account for this instead of an employee incase the use leaves or the account is changed in any way.

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
