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
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````PowerShell
# Function to get and check the entered PSTN number
function Get-UserDID {
    #Regex pattern for checking an email address
    $DIDRegex = '^\+?[1-9]\d{1,14}$'

    #Get the users DID
    Write-Host ""
    $UserDID = Read-Host "Please enter in the DID number to assign to the resource account"
    while($UserDID -notmatch $DIDRegex)
    {
     Write-Host "$UserDID isn't a valid DID number, or is not in the correct format. A DID must be in E.164 Format. IE: +61299995555" -ForegroundColor Yellow
     $UserDID = Read-Host "Please re-enter in the DID number to assign to the resource account"
    }
    return $UserDID
}

# Check there is a valid login first
Write-Host "Checking for a connection to the Skype for Business Online Powershell Module" -ForegroundColor Green
If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened')
{
	$tenant = Get-CsTenant | Select DisplayName
  Write-Host "Using existing session credentials for $($tenant.DisplayName)" -ForegroundColor Green
} Else {
	Write-Host
	Write-Host "You're not connected to any tenant." -ForegroundColor Yellow
	Write-Host "Please run the connect script before running this script" -ForegroundColor Yellow
	pause
	Break #Exit script but don't close PowerShell
}

# Get all the resource accounts
Write-Host
Write-Host "Getting a list of all Resource Accounts..." -ForegroundColor Green
$ResourceAcc = Get-CsOnlineApplicationInstance
    If (($ResourceAcc.UserPrincipalName -eq $NULL) -and ($ResourceAcc.Count -eq 0)) {
        $tenant = Get-CsTenant | Select DisplayName
        Write-Host
        Write-Host "No resource accounts were found. Please login to a tenant that has resource accounts before running this script." -ForegroundColor Yellow
        Write-Host "The tenant you're connected to is: $($tenant.DisplayName)" -ForegroundColor Yellow
        pause
        Break #Exit script but don't close PowerShell to keep the logged in session
    }

# List all the Resource accounts and prompt the user to select them
    If ($ResourceAcc.Count -gt 1) {
        $ResourceAccList = @()
        Write-Host
        If ($ResourceAcc.Count -gt 10) {
          Write-Host "ID     Phone Number        Type               Resource Account"
          Write-Host "==     ============        ====               ============"
        } else {
          Write-Host "ID    Phone Number        Type               Resource Account"
          Write-Host "==    ============        ====               ============"
        }
        For ($i=0; $i -lt $ResourceAcc.Count; $i++) {
            $a = $i + 1
            
            #Check what the account type is
            Switch ($ResourceAcc[$i].ApplicationId)
            {
                ce933385-9390-45d1-9512-c8d228074e07 {$type = "Auto Attendant"}
                11cd3e2e-fccb-42ad-ad00-878b93575e07 {$type = "Call Queue    "}
                default {$type = "              "}
            }
            
            #Check if there is already a phone number on the account
            if ($ResourceAcc[$i].PhoneNumber)
            {
              $phoneNumber = ($ResourceAcc[$i].PhoneNumber).SubString(4)
              #Pad the phone number to 15 characters
              while ($phoneNumber.length -lt 15) {$phoneNumber = "$phoneNumber "}
            } else {
              $phoneNumber = "               "
            }
            #add a space infront of the phone number if it's below 10
            If ($i -lt 9) {$phoneNumber = " $phoneNumber";}
            
            Write-Host ($a, $phoneNumber, $type, $ResourceAcc[$i].UserPrincipalName) -Separator "     "
        }
        $Range = '(1-' + $ResourceAcc.Count + ')'
        Write-Host
        $Select = Read-Host "Select a Resource Account to Assign number to" $Range
        $ResourceAccList += $ResourceAcc[$Select-1]
    }
    Else { # There is only one Resource Account
        $ResourceAccList = Get-CsOnlineApplicationInstance
    }

# Prompt for Direct Routing PSTN Number
Write-host "Editing resource account: $($ResourceAccList.UserPrincipalName)"
$ResourceAccNumber = Get-UserDID

#Assign number to Resouce Account
$error.clear()
Write-host "Setting number for resource account: $($ResourceAccList.UserPrincipalName)"
Write-Host
Write-Host
Set-CsOnlineApplicationInstance -Identity $ResourceAccList.UserPrincipalName -OnpremPhoneNumber $ResourceAccNumber | Out-Null
if($error -ne $null)
{
  Write-Host "Opps. Looks like there was an error!" -ForegroundColor Yellow
  Write-Host "Any errors may indicate that the resource account doesn't have a license OR the number is already in use."
  Write-Host "Refer to this site for information on licensing resouce accounts" -ForegroundColor Yellow
  Write-Host "https://sbcconnect.com.au/pages/license-a-phone-system-resource-account.html" -ForegroundColor Yellow
  Pause
  Break #Exit script but don't close PowerShell to keep the logged in session
} else {
  # Wait for 2 seconds for changes to sync
  Start-Sleep -s 2
  # Lets get the new number now it's updated
  $ResourceAccUpdated = Get-CsOnlineApplicationInstance -Identity $ResourceAccList.UserPrincipalName
  Write-Host "Yep - That looks good! Here are the changes" -ForegroundColor Green
  Write-Host "Resource Account: $($ResourceAccList.UserPrincipalName)"
  Write-Host "NEW number is:    $($ResourceAccUpdated.PhoneNumber)"
  Write-Host "OLD number was:   $($ResourceAccList.PhoneNumber)" -ForegroundColor Gray
  pause
  Break #Exit script but don't close PowerShell to keep the logged in session
}
````
