# Create an Auto Attendant
#### Requirements
-	You should setup the required Resource Account before starting this process
-	You should setup all nested CQ’s and AA’s before setting up your top level AA as these nested ones will need to be selected as part of the process
-	You should setup any required Holiday periods first

#### Steps

##### General Info

1. Log into the Teams Admin Portal 
   - https://admin.teams.microsoft.com/ 

1. Navigate to **Voice** > **Auto Attendants**
1. Select **+** Add 
1. Enter in a **Display name**. 
   - It’s recommended to start *display names* with either RAAA_ (Auto Attendant) to align with the resource accounts.
1. Select an Operator if required. 
   - *(Operator will not be selected unless there is a receptionist at this location)*
1. Set the **Time Zone** and **Language** this Auto Attendant will use.
   - *Make sure **Enable Voice Inputs** is not ticked unless needed.*
1. Select **Next** at the bottom of the page.

##### Call Flow

1. Under **First play a greeting message**, select **No greeting**.
   - *Avoid using a greeting in this section as it can cause issues if DTMF are recieved while playing this greeting*.
1. Under **Then route the call** and select **Play menu options**
1. If you are using an audio file, click **Upload file**. 
   - *To use the Microsoft Voice, select **Type in a greeting message** and enter the script that will be said.*
1. Under **Set menu options**, click **+** Assign a dial key.
   There are 4 options to redirect the call on number press. 
   - **Operator**  *Person in the organisation specified previously* 
   - **Person in organisation**  *A specific person in the organisation* 
   - **Voice app**  *Resource accounts (Call Queues, Auto Attendants, etc.)* 
   - **Voicemail**  *Desired Voicemail*
1. Turn off **Dial by name** under **Directory Search**
1. Select **Next** at the bottom of the page.
   - *You can jump to **Resource Accounts** at this point if you are not wanting to set **Business Hours**, **Call Flows for After Hours**, **Call Flows during Holidays**, and **Dial Scopes***

##### Call flow for after hours

1. Set the business hours as required.
1. If setting the **after hours call flow**, follow the steps above.
   - *You can use an **Audio File** here before disconnecting/redirecting the call if desired.*
1. Select **Next** at the bottom of the page.
   - *You can jump to **Resource Accounts** at this point if you are not wanting to set **Call Flows during Holidays** or **Dial Scopes***

##### Call flow for during Holidays

1. To add a Holiday, click **+** Add.
1. Enter a **Holiday Name** for the call setting.
1. Select the **Holiday** from the drop down menu.
1. Set the **Greeting** and **Actions** as per above.
1. Select **Save** at the bottom of the page.

##### Dial Scope

1. Select any user groups that are allowed to be searched for under **Dial By Name**
   - *If turned off above, then this step won’t have an impact*

##### Resource Accounts

1. Select the **Resource Account** desired.
   - *This should already be created similar to RAAA_%name% as per 🌐 [Setup a Resource Account](https://sbcconnect.com.au/pages/create-a-resource-account-user.html)*
1. Select **Submit** at the bottom of the page.


## PowerShell
The script will prompt for a name to use for the new Auto Attendant and will auto-format the name as required

> ⚠ This script assumes you've already connected to the Skype for Business Online PowerShell Module. See [Here](connecting-to-sfbo-ps-module.md) to connect

````PowerShell
#Get the name of the new Auto Attendant from the user
Write-Host "This script will create a new Resource Account and create the Auto Attendant" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "The only allowed symbols are - and _"
$AaName = Read-Host "Please enter the name for the new Auto Attendant"

#Create the username for the Resource Account by removing all spaces and adding RAAA_ to the start
$AaDisplayName = $AaName -replace '[`~!@#$%^&\*()+={}|\[\]\;:\''",/<>?]',''
$RaAaUserName = $AaName -replace '\s','' -replace '[`~!@#$%^&\*()+={}|\[\]\;:\''",/<>?]',''
$RaAaUserName = "RAAA_$RaAaUserName{DOMAIN_NAME}"
$RaAaDisplayName = $AaName -replace '[`~!@#$%^&\*()+={}|\[\]\;:\''",/<>?]',''
$RaAaDisplayName = "RAAa_$RaAaDisplayName"

#Create a new Auto Attendant
New-CsOnlineApplicationInstance -UserPrincipalName $RaAaUserName -DisplayName $RaAaDisplayName -ApplicationId “ce933385-9390-45d1-9512-c8d228074e07”
````

### Assign a PSTN phone number to the Resource Account
<i class="fas fa-terminal"></i> **Raw PowerShell Code**
````PowerShell
$RaUPN = Read-Host "Please enter UPN for the Resource Account"
Write-Host "The PSTN number must be in E.164 format - IE: +61299995555" -BackgroundColor Yellow -ForegroundColor Black
$RaPSTN = Read-Host "Please enter PSTN number to assign to the Resource Account"

Set-CsOnlineApplicationInstance -Identity $RaUPN -OnpremPhoneNumber $RaPSTN
`````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> The full script has now been included in the User Onboarding script [here](voice-enable-a-new-user.md)
