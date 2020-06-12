# Setup a Resource Account
> Licensing requirements avaliable 🌐 [Here](License-Requirements.md#auto-attendants-and-call-queues)

Resource accounts are used in Call Queues and Auto Attendants and are how you attach a PSTN phone number to a Call Queue or Auto Attendant.
Each CQ and AA require a Resource Account, but 

## Steps
1. Log into the Teams Admin Portal 
   - https://admin.teams.microsoft.com/ 
1. Navigate to **Org-wide settings** > **Resource accounts** 
1. Select **+** Add 
1. Enter in a **Display name**, **Username** and **Resource account type** 
   - It’s recommended to start *display names* and *usernames* with either RACQ_ (Call Queue) or RAAA_ (Auto Attendant) so they are grouped together and identifiable in large user lists. 
1. Select the domain name associated with the Direct Routing provider as the username’s domain name (EG `@customer.sbcconnect.com.au`)
   - The Call Queue called 'Accounts' for the customer `CONTOSO` would have the following details
     - Name: `RACQ_Accounts`
     - Username: `RACQ_Accounts@contoso.sbcconnect.com.au`
1. Click Save 
