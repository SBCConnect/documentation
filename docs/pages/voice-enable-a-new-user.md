## How to voice enable a new or existing user
Users in Microsoft 365 require several licenses and setting changes before they are able to call using Direct Routing in Microsoft Teams

## Requirements
- Users require a **Microsoft 365 Phone System** license. Refer [Here](https://github.com/SBCConnect/documentation/blob/master/docs/pages/License-Requirements.md#license-requirements-for-microsoft-teams-direct-routing) for more information.

#### Steps
1. Log into the Microsoft Admin Center 
   - https://admin.microsoft.com 
1. Navigate to **Users** > **Active users** 
1. Locate and select the resource account 
1. Select **Licenses and Apps** 
1. Select **Australia** from the **Select location** drop down list 
1. Tick the license **Phone System – Virtual User**
1. Click **Save changes** 

## PowerShell

```powershell
write-host "Demo Code"
```
