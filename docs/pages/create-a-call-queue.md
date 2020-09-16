# Create a Call Queue

## Licensing
- Each Call Queue requires a resource account setup in the Microsoft 365 tenancy. These accounts are free and setup in the steps below.
- If the Call Queue is only going to be an option from an Auto Attendant, then no ruther licensing is required.
- If the Call Queue requires a phone number attached to it for direct inbound calls to the Call Queue, then you require a **Microsoft 365 Phone System - Virtual User** license. These are free and more information can be found here: 🌐 [Here](obtain-free-virtual-phone-system-licenses.html)

## Overview
To create a Call Queue, you need to
1. Create a Resource Account
1. License the Resource Account (Optional)
1. Create the Call Queue

## Steps
1. Create a Resource Account
   - [Link to create a Resource Account](create-a-resource-account-user.md)
1. Assign the Resource account a license
   - [License a resource account](license-a-phone-system-resource-account.md)
1. [Optional] If wanting to forward an unanswered call to a Voice Mail, then you'll need to:
   - Need a service account with a Microsoft Flow license
   - Create an Office 365 Group to receive the Voice Mails (recommend to start the name of the account with VM. IE: VM Finance)
   - Assign the service account as an owner and member of the new Microsoft 365 group
   - Create a flow to get the email and pass it to a destination email address (See Jay for template)
1. Create the Call Queue

## PowerShell
The script will prompt for a name to use for the new Call Queue and will auto-format the name as required

> ⚠ These scripts assume that you've already connected to the Skype for Business Online PowerShell Module. See [Here](connecting-to-sfbo-ps-module.md) to connect

### Create the Resource Account
````PowerShell
#Get the name of the new Call Queue from the user
Write-Host "This script will create a new Resource Account and create the Call Queue" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "The only allowed symbols are - and _"
$CqName = Read-Host "Please enter the name for the new Call Queue"

#Create the username for the Resource Account by removing all spaces and adding RACQ_ to the start
$CqDisplayName = $CqName -replace '[`~!@#$%^&\*()+={}|\[\]\;:\''",/<>?]',''
$RaCqUserName = $CqName -replace '\s','' -replace '[`~!@#$%^&\*()+={}|\[\]\;:\''",/<>?]',''
$RaCqUserName = "RACQ_$RaCqUserName{DOMAIN_NAME}"
$RaCqDisplayName = $CqName -replace '[`~!@#$%^&\*()+={}|\[\]\;:\''",/<>?]',''
$RaCqDisplayName = "RACQ_$RaCqDisplayName"

#Create a new Call Queue
New-CsOnlineApplicationInstance -UserPrincipalName $RaCqUserName -DisplayName $RaCqDisplayName -ApplicationId “11cd3e2e-fccb-42ad-ad00-878b93575e07”
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
  Write-Host "Refer to the following site for information on licensing resource accounts" -ForegroundColor Yellow
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
