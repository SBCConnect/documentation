## How to voice enable a new or existing user
Users in Microsoft 365 require several licenses and setting changes before they are able to call using Direct Routing in Microsoft Teams

## Requirements
- Users require a **Microsoft 365 Phone System** license.\
Refer to 🌐 [License requriements for Microsoft Teams Direct Routing](License-Requirements.md#license-requirements-for-microsoft-teams-direct-routing) for more information.

## Modifying an existing user?
If you're looking to modify an existing user, you can re-run the same on-boarding script as below.


## PowerShell
<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````PowerShell
######## DO NOT CHANGE BELOW THIS LINE - THE SCRIPT WILL PROMT FOR ALL VARIABLES ########
#
# Script version 0.1
# Jay Antoney
# 19 October 2020
#
#####################

function Get-UserUPN {
    #Regex pattern for checking an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    #Set variable to loop through the Get User UPN function
    $UserUPNloop = 'y'
    while($UserUPNloop -eq 'y') {
        $UserUPN = $null
        while($UserUPN -notmatch $EmailRegex)
        {
            Write-Host "ERROR: $error"
            $error.Clear()
            clear
            Write-Host
            Write-Host "The tenant you've connected to is: $tenantName" -BackgroundColor Yellow -ForegroundColor Black
            Write-Host
            if($UserUPN -ne $null) {Write-Host "$UserUPN isn't a valid UPN. A UPN looks like an email address" -ForegroundColor Yellow; Write-Host}
            $UserUPN = Read-Host "Please enter in the users full UPN that you're trying to edit"
            $UserUPN = $UserUPN.trim()
        }
        #Test to make sure the user is real
        $usrDetail = $null
        $error.Clear()
        try {$usrDetail = Get-CsOnlineUser -Identity $UserUPN -ErrorAction Stop}
        Catch {Write-Host; Write-Host "No username found with username $UserUPN or the users calling licenses have been removed. Please try again" -ForegroundColor Yellow; pause}
        if (-not $error) {$UserUPNloop = 'n'}
    }

    return $usrDetail
}

function Display-UserDetails {
    $UserDetail = $Global:UserDetail
    Write-Host "User Selected: $($UserDetail.DisplayName) - $($UserUPN)"
    if ($UserDetail.EnterpriseVoiceEnabled -eq $true){
        Write-Host "User is already voice enabled" -ForegroundColor Green
        Write-Host "DisplayName: $($UserDetail.DisplayName)"
        Write-Host "DID Number: $($UserDetail.OnPremLineURI)"
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
        Write-Host "rem    Remove the number from the user but leave calling capabilites enabled"
        Write-Host "off    Remove all calling capabilities and numbers from the user"
        Write-Host "n      New User"
        Write-Host "e      Exit"
        Write-Host
        $UserDID = Read-Host "Please enter your selection"
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


#Start script checks and output "MAIN LOOP"
$mainLoop = $true
while ($mainLoop -eq $true) {
    clear
    Write-Host

    #Check we're logged into the Skype for Business Online PowerShell Module
    If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened') {
	    Write-Host 'SFB Logged in - Using existing session credentials'
        Write-Host 'Loading tenant details...'
        #Get the currently connected tenant
        $tenant = Get-CsTenant | Select DisplayName
        $tenantName = $tenant.DisplayName
    } Else {
	    Write-Host 'Skype for Business NOT Logged in - Please connect and try run the script again' -ForegroundColor Yellow; pause; break
    }



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
                Write-Host
                Write-Host
                Write-Host "Remove the users phone number: $($UserDetail.OnPremLineURI)" -ForegroundColor Yellow
                $error.Clear()
                try {Set-CsUser -Identity $UserDetail.UserPrincipalName -OnPremLineURI $null -ErrorAction Stop}
                catch {write-host "Unable to remove the number $($UserDetail.OnPremLineURI) from the user" -ForegroundColor Red; write-host;write-host "---- ERROR ----"; write-host $Error; write-host "---- END ERROR ----"; write-host; write-host "The script will now exit. Please note that changes may have been made" -ForegroundColor Red; write-host; write-host; pause; break}
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
                    Write-Host "n     New user"
                    Write-Host "e     Exit"
                    Write-Host
                    $nextConfirm = Read-Host "Please confirm all OK [n/e]"
                }
                if ($nextConfirm -eq 'e') {$mainLoop = $false; break}
        }
        'off' {
                $remSelection = $null
                while ($remSelection -ne 'yes' -and $remSelection -ne 'e') {
                    clear
                    Write-Host
                    Write-Host "-- FINAL CHECK --"
                    Write-Host
                    Write-Host "User UPN Selected: $($UserUPN)"
                    Write-Host "DisplayName: $($UserDetail.DisplayName)"
                    Write-Host "DID Number: $($UserDetail.OnPremLineURI)"
                    Write-Host "Hosted Voicemail Policy: $($UserDetail.HostedVoicemailPolicy)"
                    Write-Host "Online Voice Routing Policy: $($UserDetail.OnlineVoiceRoutingPolicy)"
                    Write-Host "Tenant Dial Plan: $($UserDetail.TenantDialPlan)"
                    Write-Host
                    Write-Host "Are you sure you want to off-board this user from Teams Calling?" -ForegroundColor Yellow
                    Write-Host
                    Write-Host "yes    Remove all calling capabilities and numbers from the user"
                    Write-Host "n      Select a new user"
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
                            Try {Set-CsUser -Identity $UserDetail.UserPrincipalName -OnPremLineURI $null -EnterpriseVoiceEnabled $false -HostedVoiceMail $false -ErrorAction Stop}
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
                                Write-Host "n     New user"
                                Write-Host "e     Exit"
                                Write-Host
                                $nextConfirm = Read-Host "Please confirm all OK [n/e]"
                            }
                            if ($nextConfirm -eq 'e') {$mainLoop = $false; break}


                    }
                }#end switch $remSelection

        }
        default {
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
                
                $nextConfirm = $null
                while ($nextConfirm -ne 'n' -and $nextConfirm -ne 'e') {
                    clear
                    Write-Host
                    Write-Host "What would you like to do now?"
                    Write-Host
                    Write-Host "n     New user"
                    Write-Host "e     Exit"
                    Write-Host
                    $nextConfirm = Read-Host "Please confirm all OK [n/e]"
                }
                if ($nextConfirm -eq 'e') {$mainLoop = $false; break}
        }
    }
}#End MainLoop
Display-ScriptExit
```
