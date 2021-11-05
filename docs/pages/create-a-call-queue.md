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
> The full script has now been included in the User Onboarding script [here](voice-enable-a-new-user.md)
