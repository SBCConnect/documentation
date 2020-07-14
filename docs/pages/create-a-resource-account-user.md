# Create a Resource Account
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



## Assign a PSTN phone number to the Resource Account
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
