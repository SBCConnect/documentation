## How to voice enable a new or existing user
Users in Microsoft 365 require several licenses and setting changes before they are able to call using Direct Routing in Microsoft Teams

## Requirements
- Users require a **Microsoft 365 Phone System** license.\
Refer to 🌐 [License requriements for Microsoft Teams Direct Routing](License-Requirements.md#license-requirements-for-microsoft-teams-direct-routing) for more information.

## Modifying an existing user?
If you're looking to modify an existing user, see [Modify an existing users account](modify-exsiting-user-account.md)\
Example modifications include:
- Enable or disable hosted voicemail
- Change their DID phone number
- Add/remove/change an extention for their account

## PowerShell
**You need to update the following details in the two (2) lines below**
- {UPN} - User 
- {DID_NUMBER} - The number for the user in E.164 format (eg: +61255558888)

<i class="fas fa-terminal"></i> **Raw PowerShell Code**

````PowerShell
#Give the user a DID number and Voice Enable the user 
#$UserDID must be in the E.164 format. IE: +61299995555
Set-CsUser -Identity "$UserUPN" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$UserDID

#Grant the user a Voice Policy 
Grant-CsOnlineVoiceRoutingPolicy -Identity "$UserUPN" -PolicyName Australia 
````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

```powershell
#Variables to change
#DID number must be in E.164 format. IE: +61299995555
$UserUPN = "INSERT_USER_UPN_HERE"
$UserDID = "INSERT_USER_DID_NUMBER_HERE"

######## DO NOT CHANGE BELOW THIS LINE ########

function Get-UserUPN {
    #Regex pattern for checking an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    #Get the users UPN
    Write-Host ""
    $UserUPN = Read-Host "Please enter in the users full UPN"
    while($UserUPN -notmatch $EmailRegex)
    {
     Write-Host "$UserUPN isn't a valid UPN. A UPN looks like an email address" -BackgroundColor Red -ForegroundColor White
     $UserUPN = Read-Host "Please enter in the users full UPN"
    }
    return $UserUPN
}

function Get-UserDID {
    #Regex pattern for checking an email address
    $DIDRegex = '^\+?[1-9]\d{1,14}$'

    #Get the users DID
    Write-Host ""
    $UserDID = Read-Host "Please enter in the users DID number"
    while($UserDID -notmatch $DIDRegex)
    {
     Write-Host "$UserDID isn't a valid DID number, or is not in the correct format. A DID must be in E.164 Format. IE: +61299995555" -ForegroundColor Yellow
     $UserDID = Read-Host "Please re-enter in the users full UPN"
    }
    return $UserDID
}

#Check we're logged into the Skype for Business Online PowerShell Module
If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened') {
	Write-Host 'SFB Logged in - Using existing session credentials'}
Else {
	Write-Host 'Skype for Business NOT Logged in - Please connect and try run the script again' -ForegroundColor Yellow; pause; exit
}

#Confirm you’re logged into the correct tenant - Is it the correct name?
$tenant = Get-CsTenant | Select DisplayName
$tenantName = $tenant.DisplayName
Write-Host "The tenant you've connected to is: $tenantName" -BackgroundColor Yellow -ForegroundColor Black

#Get the user's UPN
Write-Host "We're ready to go!" -ForegroundColor Green
$UserUPN = Get-UserUPN

Write-Host "We now need the Users NEW DID number you want to assign in E.164 format. IE: +61299995555"
$UserDID = Get-UserDID

#Give the user a DID number and Voice Enable the user 
Set-CsUser -Identity "$UserUPN" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$UserDID
```
