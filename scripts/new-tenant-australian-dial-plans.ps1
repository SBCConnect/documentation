############################
# THIS SCRIPT CAN ONLY BE RUN ON A TENANT THAT DOESN'T ALREADY HAVE THE DIAL PLANS INSTALLED
#############################
#
# Script version 1.1
# Script last updated 2nd Decemeber 2021
# Script by Jay Antoney - 5G Networks (5gn.com.au)
#
# CHANGES
# - 1.1   - Update to support Microsoftteams Powershell module V3.0.0
# 
# Required Changes at a later date
# - {nill}
#
# Any issues running script, try run the script on Windows 10 V20H2 or higher
#
#############################


# $ErrorActionPreference can be set to SilentlyContinue, Continue, Stop, or Inquire for troubleshooting purposes
$Error.Clear()
$ErrorActionPreference = 'SilentlyContinue'

# $UrlRegex = "^[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$"
$SBCConnectIDRegex = "^[5-9][5-9][0-9][0-9]$"

#Clear the screen
Clear-Host

function Show-ScriptExit {
    Clear-Host
    write-host
    Write-Host "Thanks for using this script" -ForegroundColor Yellow
    Write-Host
    Write-Host "For bug, feedback and comments, please see the SBC Connect GitHub"
    Write-Host "https://github.com/sbcconnect"
    Write-Host
    pause
    # $global:mainLoop = $false
    Clear-Host
    break Script
}

function New-PstnTrunk {
    $newTrunk = $true
    while ($newTrunk) {
        $newTrunkSelect = $null
        while ($newTrunkSelect -ne 'y' -and $newTrunkSelect -ne 'n' -and $newTrunkSelect -ne 'e') {
            Clear-Host
            Write-Host
            Write-Host "Create a new PSTN Trunk" -ForegroundColor Yellow
            Write-Host
            Write-Host "Do you want to setup the default SBC Connect PSTN trunks?"
            Write-Host "Y    Yes"
            Write-Host "N    No"
            Write-Host
            Write-Host "E    Exit"
            Write-Host
            if ($null -ne $newTrunkSelect) {
                Write-Host "$($newTrunkSelect) isn't a valid selection" -ForegroundColor Red
                Write-Host
            }
            $newTrunkSelect = Read-Host "Please enter your selection [Y/N/E]"
        }
        switch ($newTrunkSelect) {
            "n" {
                Write-Host "This script doesn't yet support custom PSTN gateways" -ForegroundColor Red
                Pause
                Show-ScriptExit
            }
            "e" {
                Show-ScriptExit
            }
            "y" {
                $sbcCustomerId = $null
                while ($sbcCustomerId -notmatch $SBCConnectIDRegex -and $sbcCustomerId -ne 'e') {
                    Clear-Host
                    Write-Host
                    Write-Host "Customer Details" -ForegroundColor Yellow
                    Write-Host
                    Write-Host "Please enter in the assigned SBC Connect customer ID"
                    Write-Host "This is the 4 digit number at the start of the customers domain"
                    Write-Host "EG: XXXX-sdc.sbcconnect.com.au"
                    Write-Host
                    Write-Host "E    Exit"
                    Write-Host
                    if ($null -ne $sbcCustomerId) {
                        Write-Host "$($sbcCustomerId) isn't a valid entry" -ForegroundColor Red
                        Write-Host
                    }
                    $sbcCustomerId = Read-Host "Customer ID [4 digits]"
                }
                if ($sbcCustomerId -eq 'e') { Show-ScriptExit }
                
                $newPstnGwsToCheck = "$($sbcCustomerId)-sdc.sbcconnect.com.au", "$($sbcCustomerId)-mdc.sbcconnect.com.au"

                $newPstnConfirm = $null
                while ($newPstnConfirm -ne 'y' -and $newPstnConfirm -ne 'e') {
                    Clear-Host
                    Write-Host
                    Write-Host "Final Confirmation" -ForegroundColor Yellow
                    Write-Host
                    Write-Host "Please confirm that these are the PSTN Gateway's you want to configure"
                    Write-Host
                    for ($c = 0; $c -lt $newPstnGwsToCheck.Length; $c++) {
                        Write-Host "-    $($newPstnGwsToCheck[$c])"
                    }
                    Write-Host
                    Write-Host "Y    Yes"
                    Write-Host "E    Exit"
                    Write-Host
                    if ($null -ne $newPstnConfirm) {
                        Write-Host "$($newPstnConfirm) isn't a valid entry" -ForegroundColor Red
                        Write-Host
                    }
                    $newPstnConfirm = Read-Host "Ready to proceed [Y/E]"
                }
                
                if ($newPstnConfirm -eq 'e') { Show-ScriptExit }

                $addedPstnGWs = @()
                Clear-Host
                Write-Host "Checking all domains exist..." -ForegroundColor Yellow
                $newPstnGws = @(Get-SBCPstnDomainName $newPstnGwsToCheck)
                if ($newPstnGws.Length -gt 0) {
                    for ($c = 0; $c -lt $newPstnGws.Length; $c++) {
                        # Write-Host "Adding      $($newPstnGws[$c])" -ForegroundColor Yellow
                        $Error.Clear()
                        try { New-CsOnlinePSTNGateway -Fqdn $newPstnGws[$c] -SipSignalingPort $newPstnGws[$c].SubString(0, 4) -MaxConcurrentSessions 50 -ForwardCallHistory $true -Enabled $true -ErrorAction Stop | Out-Null }
                        catch {
                            Write-Host
                            Write-Host "Failed to add the PSTN gateway $($newPstnGws[$c])"
                            Write-Host
                            Write-Host "---------- ERROR ----------"
                            Write-Host $Error
                            Write-Host "-------- END ERROR --------"
                            Write-Host
                            Write-Host "The following PSTN gateways were added to the tenant"
                            if ($addedPstnGWs.Length -gt 0) {
                                foreach ($g in $addedPstnGWs) { Write-Host "-    $($g)" }
                            }
                            else {
                                Write-Host "-NONE-"
                            }
                            Write-Host
                            Write-Host "This script will now exit"
                            Pause
                            Show-ScriptExit
                        }
                        $addedPstnGWs += $newPstnGws[$c]
                        Write-Host "[ADDED]     $($newPstnGws[$c])" -ForegroundColor Green
                    }
                    $global:PSTNGW = Get-CsOnlinePSTNGateway
                }
                $Error.Clear()
                Write-Host
            }
        }
        $newTrunk = $false
    }
}
function Get-SBCPstnDomainName ($domains) {
    #Check that the domain exists in the tenant
    [System.Collections.ArrayList]$result = @()
    $issue = $false
    $returnDomains = @()
    $existingDomainList = @()
    $global:PSTNGW = Get-CsOnlinePSTNGateway
    $listVerifiedDomains = Get-CsTenant | select -ExpandProperty VerifiedDomains
    foreach ($d in $domains) {
        Write-host "Processing domain $($d)" -ForegroundColor Yellow
        #$value = (Get-CsOnlineSipDomain -Domain $d).status  #Old depricated command - tested PS v3.0.0
          
        #Search if domain is enabled
        $dmresult = $null
        #$d = "thestaffshop.com.au"
        $dmresult = $listVerifiedDomains | Where-Object {$_.Name -eq $d}
        if ($dmresult) {
            
            $result.add($dmresult) | Out-Null
            if ($dmresult.Status -ne 'Enabled') { $issue = $true; Write-host "- Domain is NOT a valid domain" -ForegroundColor Red } else { Write-host "- Domain is a valid domain" -ForegroundColor Green}
            if ($PSTNGW.Identity -match $d) {
                $issue = $true
                Write-Host "- Doamin is already configured as a PSTN Gateway in the tenant" -foregroundcolor Red
                $existingDomainList += $d
            }
            else {
                Write-Host "- Doamin is not already configured as a PSTN Gateway in the tenant" -ForegroundColor Green
                $returnDomains += $d
            }
        } 
    }
    

    if ($issue -ne $true) {
        return $returnDomains
    }
    else {
        Clear-Host
        Write-Host
        Write-Host "The followng domains aren't active in the tenant." -foregroundcolor Red
        Write-Host
        foreach ($d in $result) {
            if ($d.result -ne 'Enabled') { Write-Host "-    $($d.domain)" -foregroundcolor Red }
        }
        Write-Host
        Write-Host "The followng domains are already configured as a PSTN Gateway in the tenant." -foregroundcolor Red
        Write-Host
        foreach ($d in $existingDomainList) {
            Write-Host "-    $($d)" -foregroundcolor Red
        }
        Write-Host
        Write-Host "If you've recently added the domain, then you may need to either:"
        Write-Host "- Assign the domain as a primary UPN domain to a licensed user; OR"
        Write-Host "- Wait at least 2 hours after assigning the domain to a user as their Primary UPN Domain."
        Write-Host
        Write-Host
        Write-Host "Sorry, but we can't continue the script until you've completed all the following steps:"
        Write-Host "- Setup and veryify the domain"
        Write-Host "- Assign the domain as a primary UPN domain to a licensed user"
        Write-Host "- Wait at least 2 hours after completing the above steps"
        Write-Host
        Write-Host "The script will now exit"
        Pause
        Show-ScriptExit
    }
}


################################################################
################################################################
################################################################
################################################################
#Functions
function Get-UserUPN {
    #Regex pattern for checking an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    #Get the users UPN
    Write-Host ""
    $UserUPN = Read-Host "Please enter in the users full UPN"
    while ($UserUPN -notmatch $EmailRegex) {
        Write-Host "$UserUPN isn't a valid UPN" -BackgroundColor Red -ForegroundColor White
        $UserUPN = Read-Host "Please enter in the users full UPN"
    }

    Clear-Variable OverrideAdminDomain

    $msOnlineRegex = '^([\w-\.]+)@([a-zA-Z0-9]+)\.onmicrosoft\.com$'
    If ($UserUPN -notmatch $msOnlineRegex) {
        Write-Host "It seems you've entered a UPN not ending in onmicrosoft.com. This is OK, however we need to get that domain to be able to login" -ForegroundColor Yellow
        $OverrideAdminDomain = Read-Host "Please enter in your ______.onmicrosoft.com prefix"
        $checkDomain = $true

        while ($checkDomain) {
            If ($OverrideAdminDomain -like '*.onmicrosoft.com') {
                $rootDomain = $OverrideAdminDomain.Substring(0, ($OverrideAdminDomain.Length - 16))
                If ($rootDomain -inotmatch '^[a-zA-Z0-9]+$') {
                    Write-Host "Prefix not valid" -ForegroundColor Yellow
                }
                else {
                    $checkDomain = $false
                }
            }
            else {
                If ($OverrideAdminDomain -notmatch '^[a-zA-Z0-9]+$') {
                    Write-Host "Prefix not valid" -ForegroundColor Yellow
                }
                else {
                    $checkDomain = $false
                    $OverrideAdminDomain = "$OverrideAdminDomain.onmicrosoft.com"
                }
            }

            If ($checkDomain -ne $false) { $OverrideAdminDomain = Read-Host "Please enter in your ______.onmicrosoft.com prefix" }
        }

        while ($OverrideAdminDomain -match $msOnlineRegex) {
            Write-Host "$UserUPN isn't a valid UPN" -BackgroundColor Red -ForegroundColor White
            $UserUPN = Read-Host "Please enter in the users full UPN"
        }
    }

    return $UserUPN
}


################################################################
################################################################
################################################################
################################################################
#Check if we're already signed in to Skype for Business Online




################################################################
################################################################
################################################################
################################################################
#Check a PSTN Online Gateway is present, if not then we might be deploying a Derived Trunk, so ask
$PSTNGW = $null
Clear-Host
Write-Host "Getting a list of PSTN Online Gateways..."
$PSTNGW = Get-CsOnlinePSTNGateway


if (!$PSTNGW) {
    $pstnTypeSelect = $null
    while ($pstnTypeSelect -ne 'e' -and $pstnTypeSelect -ne '1' -and $pstnTypeSelect -ne '2') {
        Clear-Host
        Write-Host
        Write-Host "PSTN Gateway Setup" -ForegroundColor Yellow
        Write-Host
        Write-Host "No PSTN Gateways are setup on this tenant. You'll need to configure one before continuing"
        Write-Host
        Write-Host "Do you want to setup a Derived or Non-Derived trunk type?"
        Write-Host "1    Derived"
        Write-Host "2    Non-Derived"
        Write-Host
        Write-Host "E    Exit"
        Write-Host
        if ($null -ne $pstnTypeSelect) {
            Write-Host "$($pstnTypeSelect) isn't a valid selection" -ForegroundColor Red
            Write-Host
        }
        $pstnTypeSelect = Read-Host "What type do you want to setup? [1/2/E]"
    }
    switch ($pstnTypeSelect) {
        "1" {
            Write-Host "This script doesn't yet support Derived Trunk configurations" -ForegroundColor Red
            Pause
            Show-ScriptExit
        }
        "2" {
            $anotherTrunk = 'y'
            $anotherTrunkInput = $null
            while ($anotherTrunk -eq 'y') {
                New-PstnTrunk
                while ($anotherTrunkInput -ne 'y' -and $anotherTrunkInput -ne 'n') {
                    Write-Host "Do you want to add another PSTN Gateway?" -ForegroundColor Yellow
                    Write-Host
                    Write-Host "Curent PSTN Gateways are"
                    foreach ($p in $PSTNGW) {
                        Write-Host "-    $($p.Identity)"
                    }
                    Write-Host
                    if ($null -ne $anotherTrunkInput) {
                        Write-Host "$($anotherTrunkInput) isn't a valid selection" -ForegroundColor Yellow
                        Write-host
                    }
                    $anotherTrunkInput = Read-Host "Do you want to add another PSTN Gateway [Y/N]"
                    Clear-Host
                }
                $anotherTrunk = $anotherTrunkInput
            }
        }
        "E" {
            Show-ScriptExit
        }
        default {
            Write-Host "Looks like you've hit an issue in the script excecution. Sorry but we need to exit" -ForegroundColor Red
            Pause
            Show-ScriptExit
        }
    }
}


$tenant = Get-CsTenant | Select-Object DisplayName
$tenantName = $tenant.DisplayName

#Set the array variable for storing the PSTN Gateways to use
$PSTNGWList = @()
$inputRouteType = $null
while ($inputRouteType -ne 1 -and $inputRouteType -ne 2) {
    Clear-Host
    Write-Host
    Write-Host "-----------------------------" -ForegroundColor Yellow
    Write-Host "Connected Tenant: $($tenantName)" -ForegroundColor Green
    Write-Host "-----------------------------" -ForegroundColor Yellow
    Write-Host
    Write-Host "Tenant Routing Type" -ForegroundColor Yellow
    Write-Host "INFO: There are $($PSTNGW.count) PSTN Gateways setup in your tenancy"
    # $i = 0
    # $outputGW = $null
    # While ($i -lt $PSTNGW.count) { $outputGW += $PSTNGW[$i].Identity; if ($i -lt $PSTNGW.count - 1) { $outputGW += ", " }; $i++ }
    # Write-Host $outputGW
    Write-Host
    Write-Host "Are you using..."
    Write-Host "1  Derived Trunk"
    Write-Host "2  Non-Derived Trunk"
    Write-Host
    Write-Host "e  Exit"
    Write-Host
    $inputRouteType = Read-Host "Please make a selection [1-2]"
    if ($inputRouteType -eq 'e') { Show-ScriptExit }
}

Switch ($inputRouteType) {
    1 {
        Clear-Host
        Write-Host
        Write-Host "Derived Trunk isn't a supported configuration by this script yet" -ForegroundColor Red
        Write-Host
        Write-Host "The script will now exit"
        Pause
        Show-ScriptExit
        # Write-Host
        # Write-Host "PSTN Gateway Selection - Derived Trunk" -ForegroundColor Yellow
        # Write-Host
        # $PSTNGW = $null;
        # If (($NULL -eq $PSTNGW.Identity) -and ($PSTNGW.Count -eq 0)) {
        #     $inputPstnGateway = $null
        #     While ($inputPstnGateway -ne 'c') {
        #         Clear-Host
        #         Write-Host
        #         Write-Host "PSTN Gateway Selection - Derived Trunk" -ForegroundColor Yellow
        #         Write-Host
        #         Write-Host "WARNING: No PSTN gateway's were found in your tenancy" -ForegroundColor Red
        #         Write-Host "This script will setup your OUTBOUND gateways, but you won't be able to receive calls until you setup your INBOUND PSTN Gateways"
        #         Write-Host
        #         Write-Host "Please enter in the FQDN of the PSTN Gateway's you're wanting to use in order of preference" -ForegroundColor Yellow
        #         if ($PSTNGWList.Count -gt 0) {
        #             Write-Host
        #             Write-Host "Current PSTN Gateway List"
        #             Write-Host
        #             Write-Host "ID    DOMAIN"
        #             Write-Host "--    ------"
        #             $igwl = 1
        #             foreach ($gwl in $PSTNGWList) {
        #                 Write-Host "$igwl     $gwl"
        #                 $igwl++
        #             }
        #             Write-Host
        #             Write-Host "Type c once all are complete"
        #         }
        #         Write-Host "Type e to Exit"
        #         Write-Host
        #         $inputPstnGateway = $null
        #         $inputPstnGateway = Read-Host "Please enter the FQDN"
        #         # Exit if E is selected
        #         if ($inputPstnGateway -eq 'e') { Clear-Host; Write-Host; Write-Host "You've selected EXIT and no changes were made" -ForegroundColor Yellow; Write-Host; pause; break }
        #         if ($inputPstnGateway -ne 'c') {
        #             if ($inputPstnGateway -notmatch $UrlRegex) {
        #                 Write-Host
        #                 Write-Host "The URL entered $($inputPstnGateway) isn't a valid URL" -ForegroundColor Red
        #                 Write-Host
        #                 Write-Host
        #                 pause
        #             }
        #             else {
        #                 $PSTNGWList += $inputPstnGateway
        #                 $inputPstnGateway = $null
        #             }
        #         }
        #     }
        
        #     Write-Host
        #     Write-Host
        #     Write-Host "--DONE--"
        #     Write-Host
        #     Write-Host
        #     $PSTNGWList
        # }
    }
    2 {
        # $PSTNGW = $null; #TESTING LINE
        [Collections.Generic.List[Object]]($inputPstnGateway)
        $PSTNGWList = @()
        $inputPstnGateway = $null
        While ($inputPstnGateway -ne 'c') {
            Clear-Host
            Write-Host
            Write-Host "PSTN Gateway Selection - Non-Derived Trunk" -ForegroundColor Yellow
            Write-Host
            Write-Host "ID    SELECTED    DOMAIN"
            Write-Host "--    --------    ------"
            $gwlen = 0
            foreach ($n in $PSTNGW) {$gwlen++}
            for ($i = 0; $i -lt $gwlen; $i++) {
                if ($PSTNGWList.count -gt 0) {
                    if ($PSTNGWList.Identity -match $PSTNGW[$i].Identity ) {
                        $selectedId = $null
                        $list = [Collections.Generic.List[Object]]($PSTNGWList)
                        $selectedId = $list.FindIndex( { $args[0].Identity -eq $PSTNGW[$i].Identity } )
                        $gwSelected = "Yes-$($selectedId+1)   "
                    }
                    else {
                        $gwSelected = "        "
                    }
                }
                else {
                    $gwSelected = "        "
                }
                Write-Host "$($i)     $($gwSelected)    $($PSTNGW[$i].Identity)"
            }

            Write-Host
            Write-Host "Type c once all are complete"
            Write-Host "Type n to create a new PSTN gateway"
            Write-Host "Type e to Exit"
            Write-Host
            if ($null -ne $inputPstnGateway) { Write-Host "$($inputPstnGateway) isn't a valid selection" -foregroundcolor Red; Write-Host }
            $inputPstnGateway = Read-Host "Please enter the ID of the next gateway in order of preference"
            # Exit if E is selected
            if ($inputPstnGateway -eq 'e') { Show-ScriptExit }
            if ($inputPstnGateway -eq 'c') { 
                if ($PSTNGWList.count -eq 0) {
                    $inputPstnGateway = "-- NO SELECTION --"
                }
            }
            if ($inputPstnGateway -eq 'n') { New-PstnTrunk; pause; $inputPstnGateway = $null }
            if ($inputPstnGateway -ne 'c') {
                if ([int]$inputPstnGateway -ge 0 -and [int]$inputPstnGateway -le $gwlen - 1) {
                    if ($PSTNGWList.Identity -match $PSTNGW[$inputPstnGateway].Identity ) {
                        $inputPstnGateway = "Duplicate of ID $($inputPstnGateway)"
                    }
                    else {
                        $PSTNGWList += [Collections.Generic.List[Object]]($PSTNGW[[int]$inputPstnGateway])
                        $inputPstnGateway = $null
                    }
                }
            }
        }
    }
}

$finalConfirm = $null
while ($finalConfirm -ne 'y' -and $finalConfirm -ne 'e') {
    Clear-Host
    Write-Host
    Write-Host "--- FINAL CHECK ---" -ForegroundColor Yellow
    Write-Host
    Write-Host "The following PSTN gateways will be used for the routes we're about to create"
    Write-Host
    foreach ($d in $PSTNGWList) {
        Write-Host "$($d.Identity)"
    }
    Write-Host
    Write-Host "Y    Yes"
    Write-Host "E    Exit"
    Write-Host
    if ($null -ne $finalConfirm) { Write-Host "$($finalConfirm) is not a valid selection" -ForegroundColor Red; Write-Host }
    $finalConfirm = Read-Host "Are you ready to proceed? [Y/E]"
    if ($finalConfirm -eq 'e') { Show-ScriptExit }
} 

# Write-Host
# Write-Host
# Write-Host "THATS IT" -ForegroundColor Green
# pause
# break script
        
######### No idea what this is - old code??
# Clear-Host
# Write-Host
# Write-Host "PSTN Gateway Selection - Derived Trunk" -ForegroundColor Yellow
# Write-Host
# If (($NULL -eq $PSTNGW.Identity) -and ($PSTNGW.Count -eq 0)) {
#     Write-Host "WARNING: No PSTN gateway's were found in your tenancy" -ForegroundColor Red
#     Write-Host "This script will setup your OUTBOUND gateways, but you won't be able to receive calls until you setup your INBOUND PSTN Gateways"
#     Write-Host
# }
# Write-Host
# Write-Host "You're using the SBC Connect and Voice Bridge One platform SBC's"
# Write-Host "The PSTN Gateway we're
#         Write-Host "1  Yes"
#         Write-Host "2  No"
#         Write-Host
#         Write-Host "e  Exit"
#         Write-Host
#      }
#     2{
#         Clear
#         Write-Host
#         Write-Host "PSTN Gateway Selection - Non-Derived Trunk" -ForegroundColor Yellow
#         Write-Host "22"
#      }
# }


#     Write-Host
#     Write-Host "No PSTN gateway's were found in your tenant. If you want to configure Direct Routing, you have to define at least one PSTN gateway Using the New-CsOnlinePSTNGateway command.' -ForegroundColor Yellow
# Write-Host 'The script will now exit.' -ForegroundColor Yellow
# Pause
# Break
# # }


#Select the PSTN Gateway

# If ($PSTNGW.Count -gt 1) {
#     $PSTNGWList = @()
#     Write-Host
#     Write-Host "ID    PSTN Gateway"
#     Write-Host "==    ============"
#     For ($i = 0; $i -lt $PSTNGW.Count; $i++) {
#         $a = $i + 1
#         Write-Host ($a, $PSTNGW[$i].Identity) -Separator "     "
#     }

#     $Range = '(1-' + $PSTNGW.Count + ')'
#     Write-Host
#     $Select = Read-Host "Select a primary PSTN gateway to apply routes" $Range

#     If (($Select -gt $PSTNGW.Count) -or ($Select -lt 1)) {
#         Write-Host 'Invalid selection' -ForegroundColor Red
#         Exit
#     }
#     Else {
#         $PSTNGWList += $PSTNGW[$Select - 1]
#     }

#     $Select = Read-Host "OPTIONAL - Select a secondary PSTN gateway to apply routes (or 0 to skip)" $Range

#     If (($Select -gt $PSTNGW.Count) -or ($Select -lt 0)) {
#         Write-Host 'Invalid selection' -ForegroundColor Red
#         Exit
#     }
#     ElseIf ($Select -gt 0) {
#         $PSTNGWList += $PSTNGW[$Select - 1]
#     }
# }
# Else {
#     # There is only one PSTN gateway
#     $PSTNGWList = Get-CSOnlinePSTNGateway
# }


#TODO need to check that none of these plans we're about to add aren't already in the platform



$ErrorActionPreference = 'Stop'



################################################################
################################################################
################################################################
################################################################
#Setup the Queensland (07) Dial Plans

$DPParent = "AU-Queensland"
Clear-Host
Write-Host
Write-Host "Creating Queensland (07) normalization rules" -foregroundcolor Yellow
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-Queensland-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+617$1' -InMemory -Description "Local number normalization for Queensland, Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[8]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-1300' -Parent $DPParent -Pattern '^(1[3]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "1300 number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"
New-CsTenantDialPlan $DPParent -Description "Normalization rules for Queensland, Australia - QLD" -NormalizationRules @{add = $NR }

################################################################
#Setup the Central and West (08) Dial Plans

$DPParent = "AU-CentralandWest"

Write-Host "Creating Central and West (08) normalization rules" -foregroundcolor Yellow
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-CentralandWest-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+618$1' -InMemory -Description "Local number normalization for Central and West, Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[8]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-1300' -Parent $DPParent -Pattern '^(1[3]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "1300 number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"
New-CsTenantDialPlan $DPParent -Description "Normalization rules for Central and West - SA/NT/WA, Australia" -NormalizationRules @{add = $NR }

################################################################
#Setup the Central East (02) Dial Plans

$DPParent = "AU-CentralEast"

Write-Host "Creating Central East (02) normalization rules" -foregroundcolor Yellow
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-CentralEast-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+612$1' -InMemory -Description "Local number normalization for Central East, Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[8]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-1300' -Parent $DPParent -Pattern '^(1[3]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "1300 number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"
New-CsTenantDialPlan $DPParent -Description "Normalization rules for Central East - NSW/ACT, Australia" -NormalizationRules @{add = $NR }

################################################################
#Setup the South East (03) Dial Plans

$DPParent = "AU-SouthEast"

Write-Host "Creating South East (03) normalization rules" -foregroundcolor Yellow
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-SouthEast-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+613$1' -InMemory -Description "Local number normalization for South East, Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[8]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-1300' -Parent $DPParent -Pattern '^(1[3]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "1300 number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"
New-CsTenantDialPlan $DPParent -Description "Normalization rules for SouthEast - VIC/TAS, Australia" -NormalizationRules @{add = $NR }


################################################################
################################################################
################################################################
################################################################
#Setup Online PSTN Usages
Write-Host
Write-Host "Creating Online PSTN Usages" -foregroundcolor Yellow
$pstnUsagesList = @("AU-National", "AU-Mobile", "AU-Premium", "AU-International", "AU-1300", "AU-Service")
$pstnCurrentUsageList = get-CsOnlinePSTNUsage -Identity global | Select-Object -ExpandProperty Usage
$pstnAdditionalDomains = $null
#Check the current PSTN usages in the tenant and ask if to remove them first
foreach ($u in $pstnCurrentUsageList) {
    if ($pstnUsagesList -contains $u) {
        #do nothing
    } else {
        $pstnAdditionalDomains += @($u)
    }
}

if ($pstnAdditionalDomains) {
    Write-Host
    Write-Host "There are additional PSTN Usages in the tenanty that are't required by SBC Connect" -ForegroundColor Yellow
    Write-Host 
    foreach ($pu in $pstnAdditionalDomains) {
        Write-Host "- $($pu)"
    }
    Write-Host
    $pstnUsageConfirm = $null
    $pstnUsageConfirm = Read-Host "Do you want to remove these PSTN Usages? [Y/N]"
    if ($pstnUsageConfirm -eq 'y') {
        Set-CsOnlinePSTNUsage -Identity global -Usage @{Remove = $pu }
    }
}

#Add new PSTN Usage's to the tenant
write-host "Adding PSTN Usage:"
foreach ($p in $pstnUsagesList) {
    if (($pstnCurrentUsageList | Where-Object {$_.Usage -ne $p}) -or ([string]::IsNullOrEmpty($pstnCurrentUsageList))) {
        write-host "- $($p)"
        Set-CsOnlinePSTNUsage -Identity global -Usage @{Add = $p } -WarningAction:SilentlyContinue | Out-Null
    }
}



################################################################
################################################################
################################################################
################################################################
#Define PSTN Usage Policy Lists
Write-Host
Write-Host "Creating PSTN Usage Lists" -foregroundcolor Yellow
$AU_NationalList = "AU-National", "AU-Mobile"
$AU_National_1300List = "AU-National", "AU-Mobile", "AU-1300"
$AU_National_1300_PremiumList = "AU-National", "AU-Mobile", "AU-Premium", "AU-1300", "AU-Service"
$AU_InternationalList = "AU-National", "AU-Mobile", "AU-International"
$AU_International_1300List = "AU-National", "AU-Mobile", "AU-International", "AU-1300"
$AU_International_1300_PremiumList = "AU-National", "AU-Mobile", "AU-Premium", "AU-International", "AU-1300", "AU-Service"

Write-Host
Write-Host
Write-Host "********************" -ForegroundColor Yellow
Write-Host "We just need to pause here for 5 mins to allow the first half of the configuration to sync" -ForegroundColor Yellow
Write-Host "********************" -ForegroundColor Yellow
Start-Sleep -s 60 #60 = 1 mins
Write-Host "Waiting 4 more minutes..."
Start-Sleep -s 60 #60 = 1 mins
Write-Host "Waiting 3 more minutes..."
Start-Sleep -s 60 #60 = 1 mins
Write-Host "Waiting 2 more minutes..."
Start-Sleep -s 60 #60 = 1 mins
Write-Host "Waiting 1 more minute..."
Start-Sleep -s 60 #60 = 1 mins
Write-Host
Write-Host "... OK - Let's keep going" -ForegroundColor Green
Write-Host


################################################################
################################################################
################################################################
################################################################
#Setup Online Voice Routing Policy
Write-Host
Write-Host "Creating Online Voice Routing Policies" -foregroundcolor Yellow
New-CsOnlineVoiceRoutingPolicy "AU-National" -Description "Allows local/national calls from  Australia to National and Emergency numbers" -OnlinePstnUsages @{Add = $AU_NationalList }
New-CsOnlineVoiceRoutingPolicy "AU-National-1300" -Description "Allows local/national calls from  Australia to National, Emergency and 1300 numbers" -OnlinePstnUsages @{Add = $AU_National_1300List }
New-CsOnlineVoiceRoutingPolicy "AU-National-1300-Premium" -Description "Allows local/national calls from  Australia to National, Emergency, 1300 and Premium numbers" -OnlinePstnUsages @{Add = $AU_National_1300_PremiumList }
New-CsOnlineVoiceRoutingPolicy "AU-International" -Description "Allows local/national calls from Australia to National, Emergency and International numbers" -OnlinePstnUsages @{Add = $AU_InternationalList }
New-CsOnlineVoiceRoutingPolicy "AU-International-1300" -Description "Allows local/national calls from Australia to National, Emergency, International and 1300 numbers" -OnlinePstnUsages @{Add = $AU_International_1300List }
New-CsOnlineVoiceRoutingPolicy "AU-International-1300-Premium" -Description "Allows local/national calls from Australia to National, Emergency, International, 1300 and Premium numbers" -OnlinePstnUsages @{Add = $AU_International_1300_PremiumList }
 


################################################################
################################################################
################################################################
################################################################
#Creating voice routes
Write-Host
Write-Host "Creating Online Voice Routes" -foregroundcolor Yellow
New-CsOnlineVoiceRoute -Name "AU-Emergency" -Priority 0 -OnlinePstnUsages "AU-National" -OnlinePstnGatewayList $PSTNGWList.Identity -NumberPattern '^(000|911|112)$' -Description "Emergency call routing for Australia" | Out-Null
New-CsOnlineVoiceRoute -Name "AU-National" -Priority 1 -OnlinePstnUsages "AU-National" -OnlinePstnGatewayList $PSTNGWList.Identity -NumberPattern '^\+610?[23578]\d{8}' -Description "Local routing for Australia" | Out-Null
New-CsOnlineVoiceRoute -Name "AU-Mobile" -Priority 2 -OnlinePstnUsages "AU-Mobile" -OnlinePstnGatewayList $PSTNGWList.Identity -NumberPattern '^\+61([45]\d{8})$' -Description "Mobile routing for Australia" | Out-Null
New-CsOnlineVoiceRoute -Name "AU-1300" -Priority 3 -OnlinePstnUsages "AU-1300" -OnlinePstnGatewayList $PSTNGWList.Identity -NumberPattern '^\+611[3]\d{4,8}$' -Description "TollFree routing for Australia" | Out-Null
New-CsOnlineVoiceRoute -Name "AU-TollFree" -Priority 4 -OnlinePstnUsages "AU-National" -OnlinePstnGatewayList $PSTNGWList.Identity -NumberPattern '^\+611[8]\d{4,8}$' -Description "TollFree routing for Australia" | Out-Null
New-CsOnlineVoiceRoute -Name "AU-Premium" -Priority 5 -OnlinePstnUsages "AU-Premium" -OnlinePstnGatewayList $PSTNGWList.Identity -NumberPattern '^\+6119\d{4,8}$' -Description "Premium routing for Australia" | Out-Null
New-CsOnlineVoiceRoute -Name "AU-Service" -Priority 6 -OnlinePstnUsages "AU-Service" -OnlinePstnGatewayList $PSTNGWList.Identity -NumberPattern '^\+?(1[0125]\d{1,8})$' -Description "Service routing for Australia" | Out-Null
New-CsOnlineVoiceRoute -Name "AU-International" -Priority 7 -OnlinePstnUsages "AU-International" -OnlinePstnGatewayList $PSTNGWList.Identity -NumberPattern '^\+((1[2-9]\d\d[2-9]\d{6})|((?!(61))([2-9]\d{6,14})))' -Description "International routing for Australia" | Out-Null


################################################################
################################################################
################################################################
################################################################
#Creating outbound translation rules
Write-Host
Write-Host "Creating Outbound Translation Rules" -foregroundcolor Yellow
$OutboundTeamsNumberTranslations = New-Object 'System.Collections.Generic.List[string]'
$OutboundPSTNNumberTranslations = New-Object 'System.Collections.Generic.List[string]'
New-CsTeamsTranslationRule -Identity "SBCconnect-AllCalls" -Pattern '^\+(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(;ext=\d+)?$' -Translation '+$1$2' -Description "Outbound translation rules" | Out-Null
$OutboundTeamsNumberTranslations.Add("SBCconnect-AllCalls")

Write-Host
Write-Host "Adding translation rules to PSTN gateways" -foregroundcolor Yellow
ForEach ($PSTNGW in $PSTNGWList) {
    Set-CsOnlinePSTNGateway -Identity $PSTNGW.Identity -OutboundTeamsNumberTranslationRules $OutboundTeamsNumberTranslations -OutboundPstnNumberTranslationRules $OutboundPSTNNumberTranslations -ErrorAction SilentlyContinue
}


Write-Host
Write-Host
Write-Host
Write-Host "####    We're all done!    ####" -ForegroundColor Green
Write-Host "From here, you may wish to assign Calling ID policies to allow Anonymous calling outbound"
Write-Host "https://sbcconnect.com.au/pages/configure-anonymous-outbound-calling.html"
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host "The script will now exit"
Write-Host
pause
Show-ScriptExit
