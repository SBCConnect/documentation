# Create a Resource Account
> Licensing requirements avaliable 🌐 [Here](License-Requirements.md#auto-attendants-and-call-queues)

Resource accounts are used in Call Queues and Auto Attendants and are how you attach a PSTN phone number to a Call Queue or Auto Attendant.
Each CQ and AA require a Resource Account, but 

## Steps
1. Log into the Teams Admin Portal 
   - https://admin.teams.microsoft.com/ 
1. Navigate to **Org-wide settings** > **Resource accounts** 
1. Select **+** Add 
1. Enter in a **Display name**, **Username** and **Resource account type**\
   For **Auto Attendants**
   - It’s recommended to start the *display name* and *username* with RAAA_ (Auto Attendant) so they are grouped together and identifiable in large user lists.\
   For **Call Queue**
   - It’s recommended to start the *Username* with either RACQ_ (Call Queue) so they are grouped together and identifiable in large user lists. 
   - Leave the **Display Name** as the full english name of the queue as this is what is displaied on users phones to identify where the call is coming from
1. Select the domain name with **onmicrosoft.com** associated with the customers tenant 
1. Click Save 



## Assign a PSTN phone number to the Resource Account
<i class="fas fa-terminal"></i> **Raw PowerShell Code**
````PowerShell
$RaUPN = Read-Host "Please enter UPN for the Resource Account"
Write-Host "The PSTN number must be in E.164 format - IE: +61299995555" -BackgroundColor Yellow -ForegroundColor Black
$RaPSTN = Read-Host "Please enter PSTN number to assign to the Resource Account"

Set-CsOnlineApplicationInstance -Identity $RaUPN -OnpremPhoneNumber $RaPSTN
`````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> The full script has now been included in the User Onboarding script [here](voice-enable-a-new-user.md)
