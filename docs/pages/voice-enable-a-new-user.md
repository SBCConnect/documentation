> The PowerShell scripts on this page have been updated to include managing reseouce accounts. Please use the same script to add/remove numbers for Resource Accounts

## How to voice enable a new or existing user
Users in Microsoft 365 require several licenses and setting changes before they are able to call using Direct Routing in Microsoft Teams

## Requirements
- Users require a **Microsoft 365 Phone System** license.\
Refer to 🌐 [License requriements for Microsoft Teams Direct Routing](License-Requirements.md#license-requirements-for-microsoft-teams-direct-routing) for more information.
- Voice Routing Policy\
  By default, the plan **AU-National-1300** should be used when provisioning a user.\
  The other common plan is **AU-International-1300** where the user has expressed that they require international calling.\
  Any Premium plans shouldn't be selected unless the customer expressly states that they accept, in writing, that users would be able to call expensive numbers like the time service without any cost caps.
- Dial Plan\
  Dial Planss should be assigned to users based on their DID number. For example, where the number starts with 07, allocate the Queensland policy.\
  **AU-CentralEast** = **02** - Sydney & Canberra\
  **AU-SouthEast** = **03** - Melbourne & Tasmania\
  **AU-Queensland** = **07** - Queensland\
  **AU-CentralandWest** = **08** - South Australia & Northern Territory & Western Australia\

## Modifying an existing user?
If you're looking to modify an existing user, you can re-run the same on-boarding script as below.


## Troubleshooting
⚠ Information on **troubleshooting user provisioning errors** can be found [here](troubleshooting-user-provisioning-issues.md)

## PowerShell
<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````PowerShell
######## DO NOT CHANGE BELOW THIS LINE - THE SCRIPT WILL PROMT FOR ALL VARIABLES ########
#
# Script version 1.1.0
#
# - Updates to include Resource Account Management
# - V1.1.0 - Update to LuneURI from OnPremLineURI
#
# TO DO
# - Confirm if this line is still required - Somewhere around line 631
#   $UserNumberToAssign = $UserDID
#
# Written by Jay Antoney
# 5G Networks
# 14 December 2021
#
#####################

function Get-UserUPN {
    #Regex pattern for checking an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    #Set variable to loop through the Get User UPN function
    $UserUPNloop = 'y'
    while($UserUPNloop -eq 'y') {
        $UserUPN = $null
        while($UserUPN -notmatch $EmailRegex -and $UserUPN -notmatch "ra")
        {
            Write-Host "ERROR: $error"
            $error.Clear()
            clear-Host
            Write-Host ""
            Write-Host "The tenant you've connected to is: " -NoNewline
            Write-Host "$($global:tenantDisplayName)"
            Write-Host
            if($UserUPN -ne $null) {Write-Host "$UserUPN isn't a valid UPN. A UPN looks like an email address" -ForegroundColor Yellow; Write-Host}
            Write-Host
            Write-Host "Please enter in the users full UPN that you're trying to edit"
            Write-Host "- OR - type RA for a resource account"
            $UserUPN = Read-Host "Users UPN or RA"
            $UserUPN = $UserUPN.trim()
        }
        
        if ($UserUPN -eq "ra") {
            $UserUPN = (Get-sbcResourceAccounts).UserPrincipalName
        }
        
        #Test to make sure the user is real
        $usrDetail = $null
        $error.Clear()
        Write-Host "Getting user details..." -ForegroundColor Yellow
        try {$usrDetail = Get-CsOnlineUser -Identity "$($UserUPN)" -ErrorAction Stop}
        Catch {Write-Host; Write-Host "No username found with username $UserUPN or the users calling licenses have been removed. Please try again" -ForegroundColor Yellow; pause}
        if (-not $error) {$UserUPNloop = 'n'}
    }

    $Global:isResourceAccount = $null
    #Write-Host "DEBUG BEFORE isResourceAccount [$($UserUPN) | $($Global:isResourceAccount)]" -ForegroundColor Magenta
    if ($usrDetail.UserPrincipalName -in $Global:ResourceAccList.UserPrincipalName) {$Global:isResourceAccount = $true} else {$Global:isResourceAccount = $false}
    #if ($userDetail.UserPrincipalName -in $Global:ResourceAccList.UserPrincipalName) {$Global:isResourceAccount = $true; Write-Host "TRUE-2"} else {$Global:isResourceAccount = $false; Write-Host "FALSE-2"}
    #Write-Host "DEBUG AFTER isResourceAccount [$($UserUPN) | $($Global:isResourceAccount)]" -ForegroundColor Magenta
    #pause
    return $usrDetail
}



function Display-UserDetails {
    $UserDetail = $Global:UserDetail
    Write-Host "User Selected: $($UserDetail.DisplayName) - $($UserUPN)"
    if ($UserDetail.EnterpriseVoiceEnabled -eq $true){
        Write-Host "User is already voice enabled" -ForegroundColor Green
        Write-Host "DisplayName: $($UserDetail.DisplayName)"
        Write-Host "Is a resource account? " -NoNewline
        if ($Global:isResourceAccount) {Write-Host "Yes" -ForegroundColor Yellow} else {Write-Host "No"}
        Write-Host "DID Number: $($UserDetail.LineURI)"
        Write-Host "Hosted Voicemail Policy: $($UserDetail.HostedVoicemailPolicy)"
        if ([string]::IsNullOrWhiteSpace($UserDetail.OnlineVoiceRoutingPolicy)){
            Write-Host "Online Voice Routing Policy: {NONE SET}" -foregroundcolor Yellow
        } else {
            Write-Host "Online Voice Routing Policy: $($UserDetail.OnlineVoiceRoutingPolicy)"
        }
        if ([string]::IsNullOrWhiteSpace($UserDetail.TenantDialPlan)){
            Write-Host "Tenant Dial Plan: {NONE SET}" -foregroundcolor Yellow
        } else {
            Write-Host "Tenant Dial Plan: $($UserDetail.TenantDialPlan)"
        }
    } else {
        Write-Host "User not currently voice enabled"
    }
    
}

function Get-sbcResourceAccounts {
    # Get all the resource accounts
    Clear-Host
    Write-host "Select a resource account" -ForegroundColor Yellow
    Write-Host
    $ResourceAcc = $Global:ResourceAccList
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

    Return $ResourceAccList
}

function Get-UserDID {
    #Regex pattern for checking an email address
    $DIDRegex = '^\+[1-9]\d{1,14}$'
    $UserDID = $null
    $UserDetail = $Global:UserDetail

    #Get the users DID
    while($UserDID -notmatch $DIDRegex -and $UserDID -ne 'rem' -and $UserDID -ne 'off' -and $UserDID -ne 'n' -and $UserDID -ne 'e')
    {
        Clear
        Write-Host
        Display-UserDetails
        if ($UserDID -ne $null) {
            Write-Host
            Write-Host "------------------------------------"
            Write-Host
            Write-Host "Invalid Selection" -ForegroundColor Yellow
            Write-Host "$UserDID isn't a valid DID number, or is not in the correct format." -ForegroundColor Yellow
        }
        Write-Host
        Write-Host "------------------------------------"
        Write-Host
        Write-Host "Please enter in the users DID number" -ForegroundColor Yellow
        Write-Host "A DID must be in E.164 Format. IE: +61299995555"
        Write-Host
        Write-Host "-or enter-"
        Write-Host "rem      Remove the number from the user but leave calling capabilites enabled"
        Write-Host "off      Remove all calling capabilities and numbers from the user"
        Write-Host "n        Next User"
        Write-Host "e        Exit"
        Write-Host
        $UserDID = Read-Host "Please enter the DID number to assign"
        $UserDID = $UserDID.trim()
        Write-Host
    }
    return $UserDID
}

function Display-ScriptExit {
    clear
    write-host
    Write-Host "Thanks for using this script" -ForegroundColor Yellow
    Write-Host
    Write-Host "For bug, feedback and comments, please see the SBC Connect GitHub"
    Write-Host "https://github.com/sbcconnect"
    Write-Host
    pause
    $global:mainLoop = $false
    clear
}

function Get-UserEXT {
    #Regex pattern for checking an email address
    $EXTRegex = '^[1-9]\d{2,3}$'
    $UserEXT = "TBA"
    $UserDetail = $Global:UserDetail

    #Get the users Extension Number
    while($UserEXT -notmatch $EXTRegex -and $UserEXT -ne 'e' -and $UserEXT -ne $null -and $Global:isResourceAccount -eq $false)
    {
        if ($UserEXT = "TBA") {$UserEXT = $null}
        Clear
        Write-Host
        Display-UserDetails
        if (-not [string]::IsNullOrEmpty( $UserEXT )) {
            Write-Host
            Write-Host "------------------------------------"
            Write-Host
            Write-Host "Invalid Selection" -ForegroundColor Yellow
            Write-Host "$UserEXT isn't a valid extension number, or is not in the correct format." -ForegroundColor Yellow
        }
        Write-Host
        Write-Host "------------------------------------"
        Write-Host
        Write-Host "Please enter in the users extenation number" -ForegroundColor Yellow
        Write-Host "An extension number can be between 3-4 digits and can not start with a 0"
        Write-Host
        Write-Host "-or enter-"
        Write-Host "{ENTER}  Leave blank to skip and not use an extension"
        Write-Host "e        Exit and not assign any number to the user"
        Write-Host
        $UserEXT = Read-Host "Please enter the extension number"
        $UserEXT = $UserEXT.trim()
        if ([string]::IsNullOrEmpty( $UserEXT )) {$UserEXT = $null}
        Write-Host
    }
    if ($UserEXT = "TBA") {$UserEXT = $null}
    return $UserEXT
}


#Start script checks and output "MAIN LOOP"
$mainLoop = $true
while ($mainLoop -eq $true) {
    clear
    Write-Host
    Write-Host "Loading tenant details..." -ForegroundColor Yellow

    #Check we're logged into the Skype for Business Online PowerShell Module
    try {
        $global:tenantDisplayName = (Get-CsTenant | Select DisplayName).DisplayName
        Write-Host "The tenant you're connected to is $($global:tenantDisplayName)" -ForegroundColor Green
    } catch {
        $activeTeamsSessions = Get-PSSession | Where-Object -FilterScript {$_.Name -like 'SfBPowerShellSessionViaTeamsModule*'}
        Write-Host
        Write-Host "You're not logged into any Microsoft Teams - Skype for Business Online powershell modules" -ForegroundColor Yellow
        Write-Host
        if ($activeTeamsSessions.Count -gt 0) {
            Write-Host "We're logging you out of the following sessions:"
            $activeTeamsSessions
            $activeTeamsSessions | Remove-PSSession
            Write-Host 
        }
        Write-Host "Please back into the Microsoft Teams - Skype for Business Online powershell module using the full script on the SBC Connect website"
        Write-Host "https://sbcconnect.com.au/pages/connecting-to-sfbo-ps-module.html"
        Write-Host
        Pause
        Break
        $mainLoop = $false
    }

    Clear-Host
    Write-Host "Getting a list of all Resource Accounts..." -ForegroundColor Yellow
    $Global:ResourceAccList = Get-CsOnlineApplicationInstance

    #Get the user's UPN
    $Global:UserDetail = Get-UserUPN
    $UserUPN = $UserDetail.UserPrincipalName
    
    #Get the user's DID
    $UserDID = Get-UserDID

    # Switch the output of the $UserDID selection in case it's REM or OFF
    switch($UserDID){
        'n' {
                $mainLoop = $true 
        }
        'e' {
                $mainLoop = $false
                break
        }
        'rem' {
               $remconfirm = $null
               while ($remconfirm -ne "yes" -and $remconfirm -ne "no") {
                    Clear-Host
                    Write-Host
                    Write-Host
                    Write-Host "Removing the users phone number: $($UserDetail.LineURI)" -ForegroundColor Yellow
                    Write-Host
                    Write-Host "Are you sure you want to remove this accounts number?" -ForegroundColor Yellow
                    $remconfirm = Read-Host "yes/no"
                }


                if ($remconfirm -eq "yes") {
                    $error.Clear()
                    if ($Global:isResourceAccount) {
                        try {Set-CsOnlineApplicationInstance -Identity $UserDetail.UserPrincipalName -OnpremPhoneNumber $null -ErrorAction Stop}
                        catch {write-host "Unable to remove the number $($UserDetail.LineURI) from the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                    } else {
                        try {Set-CsUser -Identity $UserDetail.UserPrincipalName -LineURI $null -ErrorAction Stop}
                        catch {write-host "Unable to remove the number $($UserDetail.LineURI) from the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                    }
                    Write-Host "OK" -ForegroundColor Green
                    Write-Host
                    Write-Host
                    Write-Host "Script Complete" -ForegroundColor Green
                    Write-Host
                    Write-Host
                    Pause
                }
                
                $nextConfirm = $null
                while ($nextConfirm -ne 'n' -and $nextConfirm -ne 'e') {
                    Clear-Host
                    Write-Host
                    Write-Host "What would you like to do now?"
                    Write-Host
                    Write-Host "n     Next user"
                    Write-Host "e     Exit"
                    Write-Host
                    $nextConfirm = Read-Host "Please confirm all OK [n/e]"
                }
                if ($nextConfirm -eq 'e') {$mainLoop = $false; break}
        }
        'off' {
                if ($Global:isResourceAccount) {
                    Write-Host "Sorry there is no OFF for a resource account. Please run the REM command" -ForegroundColor Yellow
                    Pause
                } else {
                    $remSelection = $null
                    while ($remSelection -ne 'yes' -and $remSelection -ne 'e') {
                        clear
                        Write-Host
                        Write-Host "-- FINAL CHECK --"
                        Write-Host
                        Write-Host "User UPN Selected: $($UserUPN)"
                        Write-Host "DisplayName: $($UserDetail.DisplayName)"
                        Write-Host "DID Number: $($UserDetail.LineURI)"
                        Write-Host "Hosted Voicemail Policy: $($UserDetail.HostedVoicemailPolicy)"
                        Write-Host "Online Voice Routing Policy: $($UserDetail.OnlineVoiceRoutingPolicy)"
                        Write-Host "Tenant Dial Plan: $($UserDetail.TenantDialPlan)"
                        Write-Host
                        Write-Host "Are you sure you want to off-board this user from Teams Calling?" -ForegroundColor Yellow
                        Write-Host
                        Write-Host "yes    Remove all calling capabilities and numbers from the user"
                        Write-Host "n      Select a different user"
                        Write-Host "e      Exit script with no changes"
                        Write-Host
                        $remSelection = Read-Host "Please enter selection"
                        $remSelection = $remSelection.trim()
                    }
                    # Switch the output of the $UserDID selection in case it's REM or OFF
                    switch($remSelection){
                        'e' {
                                $mainLoop = $false
                                break
                        }
                        'n' {
                                $mainLoop = $true
                        }
                                                                                                                                                                                                                                                                                                            'yes' {
                            clear
                            Write-Host
                            Write-Host "Removing all calling capabilities and numbers from the user"
                            
                            Write-Host
                            Write-Host
                            Write-Host "[1/3] | Remove the users Voice Routing Policy" -ForegroundColor Yellow
                            $error.Clear()
                            try {Grant-CsOnlineVoiceRoutingPolicy -Identity $UserDetail.UserPrincipalName -PolicyName $null -ErrorAction Stop}
                            catch {write-host "Unable to remove the Voice Routing Policy from the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                            Write-Host "OK" -ForegroundColor Green

                            Write-Host
                            Write-Host "[2/3] | Remove the Dial Plan" -ForegroundColor Yellow
                            $error.Clear()
                            try {Grant-CsTenantDialPlan -Identity $UserDetail.UserPrincipalName -PolicyName $null -ErrorAction Stop}
                            catch {write-host "Unable to remove the Dial Plan from the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                            Write-Host "OK" -ForegroundColor Green
                            
                            Write-Host "[3/3] | Removing the users phone number and disabling Enterprise Voice" -ForegroundColor Yellow
                            $error.Clear()
                            Try {Set-CsUser -Identity $UserDetail.UserPrincipalName -LineURI $null -EnterpriseVoiceEnabled $false -HostedVoiceMail $false -ErrorAction Stop}
                            catch {write-host "Unable to remove the number from the user or Disable Enterprise Voice" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                            Write-Host "OK" -ForegroundColor Green
                            Write-Host
                            Write-Host

                            #Confirm that voice services have been removed
                            Write-Host "Waiting 4 seconds for scripts to complete..."
                            Start-Sleep -Seconds 4
                            Write-Host "Confirming users voice services have been disabled"
                            Write-Host
                            
                            #Get the user's UPN
                            $Global:UserDetail = Get-CsOnlineUser -Identity $UserUPN
                            
                            #Check enterprisevoiceenabled is $false
                            if ($Global:UserDetail.enterprisevoiceenabled -eq $true) {
                                #enterprisevoiceenabled is still enabled
                                $ievecheck = 0;
                                while ($Global:UserDetail.enterprisevoiceenabled -eq $true -and $ievecheck -lt 2) {
                                    Write-Host "Scripts not complete - Waiting a further 4 seconds for scripts to complete..."
                                    Start-Sleep -Seconds 4
                                    $Global:UserDetail = Get-CsOnlineUser -Identity $UserUPN
                                    Write-Host
                                    $ievecheck++
                                }
                                if ($ievecheck -gt 2) {Write-Host "Scripts have been run but are taking longer than expected to complete. Please wait 20 minutes for the platform to remove the calling capabilities from the user" -ForegroundColor Yellow; Write-Host;}
                            } else {
                                #enterprisevoiceenabled has been disabled
                                Write-Host "The users voice services have been disabled and numbers removed" -ForegroundColor Green
                                Write-Host
                            }

                            Write-Host
                            Write-Host "Script Complete" -ForegroundColor Green
                            Write-Host
                            
                            #Check with the user what to do now                                            
                            $nextConfirm = $null
                            while ($nextConfirm -ne 'n' -and $nextConfirm -ne 'e') {
                                clear
                                Write-Host
                                Write-Host "What would you like to do now?"
                                Write-Host
                                Write-Host "n     Next user"
                                Write-Host "e     Exit"
                                Write-Host
                                $nextConfirm = Read-Host "Please confirm all OK [n/e]"
                            }
                            if ($nextConfirm -eq 'e') {$mainLoop = $false; break}


                    }
                    }#end switch $remSelection
                        
                }
        }
        default {
                            ##############
                #Get the users Extension number
                $UserEXT = $null
                $UserEXT = Get-UserEXT

                if ($UserEXT -eq 'e') {$mainLoop = $false; break}

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
                    if (-not $Global:isResourceAccount) {Write-Host "User DID: $($UserDID)"}
                    if ($userEXT) {Write-Host "User EXT: $($UserEXT)"}
                    if ($Global:isResourceAccount) {Write-Host "Account is a resource account" -ForegroundColor Yellow}
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
                        Switch ($dialPlanName) {
                            "AU-CentralEast" {$dialPlanName = "$($dialPlanName)      |  NSW & ACT"}
                            "AU-Queensland" {$dialPlanName = "$($dialPlanName)       |  QLD"}
                            "AU-CentralandWest" {$dialPlanName = "$($dialPlanName)   |  SA, NT & WA"}
                            "AU-SouthEast" {$dialPlanName = "$($dialPlanName)        |  VIC & TAS"}
                        }

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
                    Write-Host "What Voice Routing Policy should we assign to the user?"
                    Write-Host "User UPN: $($UserUPN)"
                    Write-Host "User DID: $($UserDID)"
                    if ($userEXT) {Write-Host "User EXT: $($UserEXT)"}
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
                    
                    $finalDialPlanName = $selectedDialPlan.Identity.Substring(4)
                    Switch ($finalDialPlanName) {
                            "AU-CentralEast" {$finalDialPlanName = "$($finalDialPlanName)      |  NSW & ACT"}
                            "AU-Queensland" {$finalDialPlanName = "$($finalDialPlanName)       |  QLD"}
                            "AU-CentralandWest" {$finalDialPlanName = "$($finalDialPlanName)   |  SA, NT & WA"}
                            "AU-SouthEast" {$finalDialPlanName = "$($finalDialPlanName)        |  VIC & TAS"}
                        }
                    
                    clear
                    Write-Host
                    Write-Host "Lets check we're all ready to go!" -ForegroundColor Yellow
                    Write-Host
                    Write-Host "-----------------------------------------------------"
                    Write-Host "User UPN: $($UserUPN)"
                    Write-Host "User DID: $($UserDID)"
                    if ($userEXT) {Write-Host "User EXT: $($UserEXT)"}
                    Write-Host "Dial Plan: $($finalDialPlanName)"
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
                if ($userEXT) {Write-Host "User EXT: $($UserEXT)"}
                Write-Host "Dial Plan: $($selectedDialPlan.Identity.Substring(4))"
                Write-Host "Voice Routing Policy: $($selectedVrp.Identity.Substring(4))"
                Write-Host "-----------------------------------------------------"
                Write-Host
                Write-Host
                
                if ($userEXT) {
                    $UserNumberToAssign = "tel:$($UserDID);ext=$($UserEXT)"
                } else {
                    $UserNumberToAssign = "tel:$($UserDID)"
                }
                

                $currentStep = 1

                #Give the user a DID number and Voice Enable the user 
                if (-not $Global:isResourceAccount) { #Skip this if the account is a resource account
                    $numOfSteps = 3
                    Write-Host "[$($currentStep)/$($numOfSteps)] | Assigning the number to the user and Voice Enabling the user" -ForegroundColor Yellow
                    $error.Clear()
                    Try {Set-CsUser -Identity "$UserUPN" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -LineURI $UserNumberToAssign -ErrorAction Stop}
                    catch {write-host "Unable to assign the number to the user or Voice Enable the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                    Write-Host "OK" -ForegroundColor Green
                } else {
                    $numOfSteps = 3
                    $UserNumberToAssign = $UserDID #This line is here because there is a bug in MS Teams PS Module V2.3.0 where it wont accept the TEL:+000000000 format
                    Write-Host "[$($currentStep)/$($numOfSteps)] | Assigning the number to the Resource Account" -ForegroundColor Yellow
                    $error.Clear()
                    Try {Set-CsOnlineApplicationInstance -Identity "$UserUPN" -OnpremPhoneNumber $UserNumberToAssign | Out-Null}
                    catch {write-host "Unable to assign the number to the user or Voice Enable the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                    Write-Host "OK" -ForegroundColor Green
                    #pause
                }
                $currentStep++

                Write-Host
                Write-Host "[$($currentStep)/$($numOfSteps)] | Assigning the Voice Routing Policy" -ForegroundColor Yellow
                $error.Clear()
                try {
                    if ($selectedDialPlan.Identity -eq 'Global')
                    {
                        Write-Host "Global policy selected"
                        Grant-CsOnlineVoiceRoutingPolicy -Identity "$UserUPN" -PolicyName $null -ErrorAction Stop
                    } else {
                        Grant-CsOnlineVoiceRoutingPolicy -Identity "$UserUPN" -PolicyName $selectedVrp.Identity -ErrorAction Stop
                    }
                }
                catch {write-host "Unable to assign the Voice Routing Policy to the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                Write-Host "OK" -ForegroundColor Green
                $currentStep++

                Write-Host
                Write-Host "[$($currentStep)/$($numOfSteps)] | Assigning the Dial Plan" -ForegroundColor Yellow
                $error.Clear()
                try {
                    if ($selectedDialPlan.Identity -eq 'Global')
                    {
                        Write-Host "Global policy selected"
                        Grant-CsTenantDialPlan -Identity "$UserUPN" -PolicyName $null -ErrorAction Stop
                    } else {
                        Grant-CsTenantDialPlan -Identity "$($UserUPN)" -PolicyName $selectedDialPlan.Identity -ErrorAction Stop
                    }
                }
                catch {write-host "Unable to assign the Dial Plan to the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
                Write-Host "OK" -ForegroundColor Green

                Write-Host
                Write-Host
                Write-Host "Script Complete" -ForegroundColor Green
                Write-Host
                Write-Host
                pause
                
                $nextConfirm = $null
                while ($nextConfirm -ne 'n' -and $nextConfirm -ne 'e') {
                    clear
                    Write-Host
                    Write-Host "What would you like to do now?"
                    Write-Host
                    Write-Host "n     Next user"
                    Write-Host "e     Exit"
                    Write-Host
                    $nextConfirm = Read-Host "Please confirm all OK [n/e]"
                }
                if ($nextConfirm -eq 'e') {$mainLoop = $false; break}
        }
    }
}#End MainLoop
Display-ScriptExit
````
