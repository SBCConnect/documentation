## How to voice enable a new or existing user
Users in Microsoft 365 require several licenses and setting changes before they are able to call using Direct Routing in Microsoft Teams

## Requirements
- Users require a **Microsoft 365 Phone System** license.\
Refer to 🌐 [License requriements for Microsoft Teams Direct Routing](License-Requirements.md#license-requirements-for-microsoft-teams-direct-routing) for more information.

## Modifying an existing user?
If you're looking to modify an existing user, you can re-run the same on-boarding script as below.


## PowerShell
**You need to update the following details in the two (2) lines below**
- {UPN} - User 
- {DID_NUMBER} - The number for the user in E.164 format (eg: +61255558888)

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````PowerShell
######## DO NOT CHANGE BELOW THIS LINE - THE SCRIPT WILL PROMT FOR ALL VARIABLES ########

function Get-UserUPN {
    #Regex pattern for checking an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    #Get the users UPN
    $UserUPN = Read-Host "Please enter in the users full UPN"
    $UserUPN = $UserUPN.trim()
    while($UserUPN -notmatch $EmailRegex)
    {
     Write-Host "$UserUPN isn't a valid UPN. A UPN looks like an email address" -ForegroundColor Red
     $UserUPN = Read-Host "Please enter in the users full UPN"
    }
    return $UserUPN
}

function Get-UserDID {
    #Regex pattern for checking an email address
    $DIDRegex = '^\+?[1-9]\d{1,14}$'

    #Get the users DID
    $UserDID = Read-Host "Please enter in the users DID number"
    $UserDID = $UserDID.trim()
    while($UserDID -notmatch $DIDRegex)
    {
     Write-Host "$UserDID isn't a valid DID number, or is not in the correct format. A DID must be in E.164 Format. IE: +61299995555" -ForegroundColor Red
     $UserDID = Read-Host "Please re-enter in the users full UPN"
    }
    return $UserDID
}

clear
Write-Host

#Check we're logged into the Skype for Business Online PowerShell Module
If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened') {
	Write-Host 'SFB Logged in - Using existing session credentials'}
Else {
	Write-Host 'Skype for Business NOT Logged in - Please connect and try run the script again' -ForegroundColor Yellow; pause; break
}

#Confirm you’re logged into the correct tenant - Is it the correct name?
$tenant = Get-CsTenant | Select DisplayName
$tenantName = $tenant.DisplayName
Write-Host "The tenant you've connected to is: $tenantName" -BackgroundColor Yellow -ForegroundColor Black

#Get the user's UPN
Write-Host "We're logged in and ready to go!"
Write-Host
Write-Host
$UserUPN = Get-UserUPN

clear
Write-Host
Write-Host "User UPN: $($UserUPN)"
Write-Host
Write-Host
Write-Host "We now need the Users NEW DID number you want to assign in E.164 format. IE: +61299995555" -ForegroundColor Yellow
Write-Host
$UserDID = Get-UserDID

##############
# List and select the dial plan to assign to the user
clear
Write-Host
Write-Host "Getting a list of all Dial Plans..." -ForegroundColor Yellow
$gotDialPlan = get-CsTenantDialPlan

$dialPlanRegex = "^[1-$($gotDialPlan.Count)]$"
$selectDialPlan = $null

while ($selectDialPlan -notmatch $dialPlanRegex) {
    clear
    Write-Host
    Write-Host "What dial plan should we assign to the user?"
    Write-Host "User UPN: $($UserUPN)"
    Write-Host "User DID: $($UserDID)"
    Write-Host
    If ($gotDialPlan.Count -gt 10) {
        Write-Host "ID     PLAN NAME"
        Write-Host "--     ---------"
    } else {
        Write-Host "ID    PLAN NAME"
        Write-Host "--    ---------"
    }
    For ($i=0; $i -lt $gotDialPlan.Count; $i++) {
        $a = $i + 1
            
        #Check if there is already a phone number on the account
        if ($gotDialPlan[$i].identity.Substring(0,4) -eq 'Tag:') {
            $dialPlanName = $gotDialPlan[$i].identity.Substring(4)
        } else {
            $dialPlanName = $gotDialPlan[$i].identity
        }

        #add a space infront of the phone number if it's below 10
        If ($i -lt 9) {$dialPlanName = " $dialPlanName";}
            
        Write-Host ($a, $dialPlanName) -Separator "    "
    }
    $Range = '(1-' + $gotDialPlan.Count + ')'
    Write-Host
    $selectDialPlan = Read-Host "Select dial plan to assign " $Range
    $selectedDialPlan = $gotDialPlan[$selectDialPlan-1]
}


##############
# List and select the Voice Routing Policy to assign to the user

clear
Write-Host
Write-Host "Getting a list of all Voice Routing Policies..." -ForegroundColor Yellow
$gotVRP = get-CsOnlineVoiceRoutingPolicy

$vrpPlanRegex = "^[1-$($gotVRP.Count)]$"
$selectvrp = $null

while ($selectvrp -notmatch $vrpPlanRegex) {
    clear
    Write-Host
    Write-Host "What dial plan should we assign to the user?"
    Write-Host "User UPN: $($UserUPN)"
    Write-Host "User DID: $($UserDID)"
    Write-Host "Dial Plan: $($selectedDialPlan.Identity.Substring(4))"
    Write-Host
    If ($gotVRP.Count -gt 10) {
        Write-Host "ID     PLAN NAME"
        Write-Host "--     ---------"
    } else {
        Write-Host "ID    PLAN NAME"
        Write-Host "--    ---------"
    }
    For ($i=0; $i -lt $gotVRP.Count; $i++) {
        $a = $i + 1
            
        #Check if there is already a phone number on the account
        if ($gotVRP[$i].identity.Substring(0,4) -eq 'Tag:') {
            $vrpPlanName = $gotVRP[$i].identity.Substring(4)
        } else {
            $vrpPlanName = $gotVRP[$i].identity
        }

        #add a space infront of the phone number if it's below 10
        If ($i -lt 9) {$vrpPlanName = " $vrpPlanName";}
            
        Write-Host ($a, $vrpPlanName) -Separator "    "
    }
    $Range = '(1-' + $gotDialPlan.Count + ')'
    Write-Host
    $selectvrp = Read-Host "Select dial plan to assign " $Range
    $selectedVrp = $gotVRP[$selectvrp-1]
}

$userReadyConfirm = $null
while ($userReadyConfirm -ne 'y' -and $userReadyConfirm -ne 'n' ) {
    clear
    Write-Host
    Write-Host "Lets check we're all ready to go!" -ForegroundColor Yellow
    Write-Host
    Write-Host "-----------------------------------------------------"
    Write-Host "User UPN: $($UserUPN)"
    Write-Host "User DID: $($UserDID)"
    Write-Host "Dial Plan: $($selectedDialPlan.Identity.Substring(4))"
    Write-Host "Voice Routing Policy: $($selectedVrp.Identity.Substring(4))"
    Write-Host "-----------------------------------------------------"
    Write-Host
    Write-Host "Is everything OK?"
    Write-Host "y = Yes"
    Write-Host "n = No"
    Write-Host
    $userReadyConfirm = Read-Host "Please confirm all OK [y/n]"
}
#If there was a 'n' then exit
if ($userReadyConfirm -eq 'n') {Write-Host; Write-Host; Write-Host "It seems you found an issue, so we'll exit the script now" -ForegroundColor Red; Write-Host "Please re-run the script to try again" -ForegroundColor Red; Write-Host; pause; break}


##############
# Assigning details to the user
clear
Write-Host
Write-Host "Setting up the user" -ForegroundColor Yellow
Write-Host
Write-Host "-----------------------------------------------------"
Write-Host "User UPN: $($UserUPN)"
Write-Host "User DID: $($UserDID)"
Write-Host "Dial Plan: $($selectedDialPlan.Identity.Substring(4))"
Write-Host "Voice Routing Policy: $($selectedVrp.Identity.Substring(4))"
Write-Host "-----------------------------------------------------"
Write-Host
Write-Host


#Give the user a DID number and Voice Enable the user 
Write-Host "[1/3] | Assigning the number to the user and Voice Enabling the user" -ForegroundColor Yellow
$error.Clear()
Try {Set-CsUser -Identity "$UserUPN" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$UserDID -ErrorAction Stop}
catch {write-host "Unable to assign the number to the user or Voice Enable the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
Write-Host "OK" -ForegroundColor Green

Write-Host
Write-Host "[2/3] | Assigning the Voice Routing Policy" -ForegroundColor Yellow
$error.Clear()
try {Grant-CsOnlineVoiceRoutingPolicy -Identity "$UserUPN" -PolicyName $selectedVrp.Identity -ErrorAction Stop}
catch {write-host "Unable to assign the Voice Routing Policy to the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
Write-Host "OK" -ForegroundColor Green

Write-Host
Write-Host "[3/3] | Assigning the Dial Plan" -ForegroundColor Yellow
$error.Clear()
try {Grant-CsTenantDialPlan -Identity "$UserUPN" -PolicyName $selectedDialPlan.Identity -ErrorAction Stop}
catch {write-host "Unable to assign the Dial Plan to the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
Write-Host "OK" -ForegroundColor Green

Write-Host
Write-Host
Write-Host "Script Complete" -ForegroundColor Green
Write-Host
Write-Host
pause
break
```
