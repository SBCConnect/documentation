############################
# THERE IS LOTS WRONG WITH THIS AROUND THE PSTN GATEWAY SELECTION
# DO - NOT - RUN
############################

clear
Write-Host
Write-Host "THERE IS LOTS WRONG WITH THIS AROUND THE PSTN GATEWAY SELECTION" -foregroundcolor Yellow
Write-Host "DO - NOT - RUN"
Write-Host
Write-Host
pause
break

# The above lines are to stop you copying and pasting it to run it

# $ErrorActionPreference can be set to SilentlyContinue, Continue, Stop, or Inquire for troubleshooting purposes
$Error.Clear()
$ErrorActionPreference = 'SilentlyContinue'

$UrlRegex = "^[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$"

#Clear the screen
clear

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
    while($UserUPN -notmatch $EmailRegex)
    {
     Write-Host "$UserUPN isn't a valid UPN" -BackgroundColor Red -ForegroundColor White
     $UserUPN = Read-Host "Please enter in the users full UPN"
    }

    Clear-Variable OverrideAdminDomain

    $msOnlineRegex = '^([\w-\.]+)@([a-zA-Z0-9]+)\.onmicrosoft\.com$'
    If($UserUPN -notmatch $msOnlineRegex) 
    {
        Write-Host "It seems you've entered a UPN not ending in onmicrosoft.com. This is OK, however we need to get that domain to be able to login" -ForegroundColor Yellow
        $OverrideAdminDomain = Read-Host "Please enter in your ______.onmicrosoft.com prefix"
        $checkDomain = $true

        while ($checkDomain)
        {
            If($OverrideAdminDomain -like '*.onmicrosoft.com')
            {
                $rootDomain = $OverrideAdminDomain.Substring(0, ($OverrideAdminDomain.Length - 16))
                If($rootDomain -inotmatch '^[a-zA-Z0-9]+$')
                {
                    Write-Host "Prefix not valid" -ForegroundColor Yellow
                } else {
                    $checkDomain = $false
                }
            } else {
                If($OverrideAdminDomain -notmatch '^[a-zA-Z0-9]+$')
                {
                    Write-Host "Prefix not valid" -ForegroundColor Yellow
                } else {
                    $checkDomain = $false
                    $OverrideAdminDomain = "$OverrideAdminDomain.onmicrosoft.com"
                }
            }

            If($checkDomain -ne $false) {$OverrideAdminDomain = Read-Host "Please enter in your ______.onmicrosoft.com prefix"}
        }

        while($OverrideAdminDomain -match $msOnlineRegex)
        {
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
$UserLoginUPN = Get-UserUPN

If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened') {
	Write-Host 'Using existing session credentials'}
Else {
	if($OverrideAdminDomain)
    {
        $skypeConnection = New-CsOnlineSession -UserName $UserLoginUPN -OverrideAdminDomain $OverrideAdminDomain
    } else {
        $skypeConnection = New-CsOnlineSession -UserName $UserLoginUPN
    }
	Import-PSSession $skypeConnection -AllowClobber
}

#Check we're connected - exit if not
if ($skypeConnection.Availability -ne 'Available') {write-host "Unable to connect to online services. Please try the script again." -BackgroundColor Red -ForegroundColor White; pause; break}




################################################################
################################################################
################################################################
################################################################
#Check a PSTN Online Gateway is present, if not then we might be deploying a Derived Trunk, so ask
$PSTNGW = Get-CsOnlinePSTNGateway
#Set the array variable for storing the PSTN Gateways
$PSTNGWList = @()
$inputRouteType = $null
while($inputRouteType -ne 1 -and $inputRouteType -ne 2) {
    clear
    Write-Host
    Write-Host "PSTN Gateway Selection" -ForegroundColor Yellow
    If (($PSTNGW.Identity -eq $NULL) -and ($PSTNGW.Count -eq 0)) {
        Write-Host "INFO: No PSTN gateway's were found in your tenancy"
    } else {
        Write-Host "INFO: You currently have $($PSTNGW.count) PSTN Gateways setup in your tenancy"
        $i = 0
        $outputGW = $null
        While ($i -lt $PSTNGW.count) {$outputGW += $PSTNGW[$i].Identity; if ($i -lt $PSTNGW.count-1){$outputGW += ", "}; $i++}
        Write-Host $outputGW
    }
    Write-Host
    Write-Host
    Write-Host "Are you using..."
    Write-Host "1  Derived Trunk"
    Write-Host "2  Non-Derived Trunk"
    Write-Host
    Write-Host "e  Exit"
    Write-Host
    $inputRouteType = Read-Host "Please make a selection [1-2]"
    if ($inputRouteType -eq 'e') {Clear; Write-Host; Write-Host "You've selected EXIT and no changes were made" -ForegroundColor Yellow; Write-Host; pause; break}
}

Switch ($inputRouteType) {
    1{
        Clear
        Write-Host
        Write-Host "PSTN Gateway Selection - Derived Trunk" -ForegroundColor Yellow
        Write-Host
        $PSTNGW = $null;
        If (($PSTNGW.Identity -eq $NULL) -and ($PSTNGW.Count -eq 0)) {
            $inputPstnGateway = $null
            While ($inputPstnGateway -ne 'c') {
                Clear
                Write-Host
                Write-Host "PSTN Gateway Selection - Derived Trunk" -ForegroundColor Yellow
                Write-Host
                Write-Host "WARNING: No PSTN gateway's were found in your tenancy" -ForegroundColor Red
                Write-Host "This script will setup your OUTBOUND gateways, but you won't be able to receive calls until you setup your INBOUND PSTN Gateways"
                Write-Host
                Write-Host "Please enter in the FQDN of the PSTN Gateway's you're wanting to use in order of preference" -ForegroundColor Yellow
                if ($PSTNGWList.Count -gt 0){
                    Write-Host
                    Write-Host "Current PSTN Gateway List"
                    Write-Host
                    Write-Host "ID    DOMAIN"
                    Write-Host "--    ------"
                    $igwl = 1
                    foreach ($gwl in $PSTNGWList) {
                        Write-Host "$igwl     $gwl"
                        $igwl++
                    }
                    Write-Host
                    Write-Host "Type c once all are complete"
                }
                Write-Host "Type e to Exit"
                Write-Host
                $inputPstnGateway = $null
                $inputPstnGateway = Read-Host "Please enter the FQDN"
                # Exit if E is selected
                if ($inputPstnGateway -eq 'e') {Clear; Write-Host; Write-Host "You've selected EXIT and no changes were made" -ForegroundColor Yellow; Write-Host; pause; break}
                if ($inputPstnGateway -ne 'c') {
                    if ($inputPstnGateway -notmatch $UrlRegex) {
                        Write-Host
                        Write-Host "The URL entered $($inputPstnGateway) isn't a valid URL" -ForegroundColor Red
                        Write-Host
                        Write-Host
                        pause
                    } else {
                        $PSTNGWList += $inputPstnGateway
                        $inputPstnGateway = $null
                    }
                }
            }
        
       Write-Host
       Write-Host
       Write-Host "--DONE--"
       Write-Host
       Write-Host
       $PSTNGWList
        }
    }
}





        
        Clear
        Write-Host
        Write-Host "PSTN Gateway Selection - Derived Trunk" -ForegroundColor Yellow
        Write-Host
        If (($PSTNGW.Identity -eq $NULL) -and ($PSTNGW.Count -eq 0)) {
            Write-Host "WARNING: No PSTN gateway's were found in your tenancy" -ForegroundColor Red
            Write-Host "This script will setup your OUTBOUND gateways, but you won't be able to receive calls until you setup your INBOUND PSTN Gateways"
            Wriet-Host
        }
        Write-Host
        Write-Host "You're using the SBC Connect and Voice Bridge One platform SBC's"
        Write-Host "The PSTN Gateway we're
        Write-Host "1  Yes"
        Write-Host "2  No"
        Write-Host
        Write-Host "e  Exit"
        Write-Host
     }
    2{
        Clear
        Write-Host
        Write-Host "PSTN Gateway Selection - Non-Derived Trunk" -ForegroundColor Yellow
        Write-Host "22"
     }
}


    Write-Host
    Write-Host "No PSTN gateway's were found in your tenant. If you want to configure Direct Routing, you have to define at least one PSTN gateway Using the New-CsOnlinePSTNGateway command.' -ForegroundColor Yellow
    Write-Host 'The script will now exit.' -ForegroundColor Yellow
    Pause
    Break
}


#Select the PSTN Gateway

	If ($PSTNGW.Count -gt 1) {
		$PSTNGWList = @()
		Write-Host
		Write-Host "ID    PSTN Gateway"
		Write-Host "==    ============"
		For ($i=0; $i -lt $PSTNGW.Count; $i++) {
			$a = $i + 1
			Write-Host ($a, $PSTNGW[$i].Identity) -Separator "     "
		}

		$Range = '(1-' + $PSTNGW.Count + ')'
		Write-Host
		$Select = Read-Host "Select a primary PSTN gateway to apply routes" $Range

		If (($Select -gt $PSTNGW.Count) -or ($Select -lt 1)) {
			Write-Host 'Invalid selection' -ForegroundColor Red
			Exit
		}
		Else {
			$PSTNGWList += $PSTNGW[$Select-1]
		}

		$Select = Read-Host "OPTIONAL - Select a secondary PSTN gateway to apply routes (or 0 to skip)" $Range

		If (($Select -gt $PSTNGW.Count) -or ($Select -lt 0)) {
			Write-Host 'Invalid selection' -ForegroundColor Red
			Exit
		}
		ElseIf ($Select -gt 0) {
			$PSTNGWList += $PSTNGW[$Select-1]
		}
	}
	Else { # There is only one PSTN gateway
		$PSTNGWList = Get-CSOnlinePSTNGateway
	}


################################################################
################################################################
################################################################
################################################################
#Setup the Queensland (07) Dial Plans

$DPParent = "AU-Queensland"

Write-Host "Creating Queensland (07) normalization rules"
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-Queensland-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+617$1' -InMemory -Description "Local number normalization for Queensland, Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[8]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-1300' -Parent $DPParent -Pattern '^(1[3]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "1300 number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"
New-CsTenantDialPlan $DPParent -Description "Normalization rules for Queensland, Australia" -NormalizationRules @{add=$NR}

################################################################
#Setup the Central and West (08) Dial Plans

$DPParent = "AU-CentralandWest"

Write-Host "Creating Central and West (08) normalization rules"
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-CentralandWest-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+618$1' -InMemory -Description "Local number normalization for Central and West, Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[8]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-1300' -Parent $DPParent -Pattern '^(1[3]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "1300 number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"
New-CsTenantDialPlan $DPParent -Description "Normalization rules for Central and West, Australia" -NormalizationRules @{add=$NR}

################################################################
#Setup the Central East (02) Dial Plans

$DPParent = "AU-CentralEast"

Write-Host "Creating Central East (02) normalization rules"
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-CentralEast-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+612$1' -InMemory -Description "Local number normalization for Central East, Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[8]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-1300' -Parent $DPParent -Pattern '^(1[3]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "1300 number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"
New-CsTenantDialPlan $DPParent -Description "Normalization rules for Central East, Australia" -NormalizationRules @{add=$NR}

################################################################
#Setup the South East (03) Dial Plans

$DPParent = "AU-SouthEast"

Write-Host "Creating South East (03) normalization rules"
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-SouthEast-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+613$1' -InMemory -Description "Local number normalization for South East, Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[8]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-1300' -Parent $DPParent -Pattern '^(1[3]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "1300 number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"
New-CsTenantDialPlan $DPParent -Description "Normalization rules for SouthEast, Australia" -NormalizationRules @{add=$NR}


################################################################
################################################################
################################################################
################################################################
#Setup Online PSTN Usages
Set-CsOnlinePSTNUsage -Identity global -Usage @{Add="AU-National"} -WarningAction:SilentlyContinue | Out-Null
Set-CsOnlinePSTNUsage -Identity global -Usage @{Add="AU-Mobile"} -WarningAction:SilentlyContinue | Out-Null
Set-CsOnlinePSTNUsage -Identity global -Usage @{Add="AU-Premium"} -WarningAction:SilentlyContinue | Out-Null
Set-CsOnlinePSTNUsage -Identity global -Usage @{Add="AU-International"} -WarningAction:SilentlyContinue | Out-Null
Set-CsOnlinePSTNUsage -Identity global -Usage @{Add="AU-1300"} -WarningAction:SilentlyContinue | Out-Null
Set-CsOnlinePSTNUsage -Identity global -Usage @{Add="AU-Service"} -WarningAction:SilentlyContinue | Out-Null


################################################################
################################################################
################################################################
################################################################
#Define PSTN Usage Policy Lists
$AU_NationalList = "AU-National", "AU-Mobile"
$AU_National_1300List = "AU-National", "AU-Mobile", "AU-1300"
$AU_National_1300_PremiumList = "AU-National", "AU-Mobile", "AU-Premium", "AU-1300","AU-Service"
$AU_InternationalList = "AU-National", "AU-Mobile", "AU-International"
$AU_International_1300List = "AU-National", "AU-Mobile", "AU-International", "AU-1300"
$AU_International_1300_PremiumList = "AU-National", "AU-Mobile", "AU-Premium", "AU-International", "AU-1300","AU-Service"



################################################################
################################################################
################################################################
################################################################
#Setup Online Voice Routing Policy
New-CsOnlineVoiceRoutingPolicy "AU-National" -Description "Allows local/national calls from  Australia to National and Emergency numbers" -OnlinePstnUsages @{Add=$AU_NationalList}
New-CsOnlineVoiceRoutingPolicy "AU-National-1300" -Description "Allows local/national calls from  Australia to National, Emergency and 1300 numbers" -OnlinePstnUsages @{Add=$AU_National_1300List}
New-CsOnlineVoiceRoutingPolicy "AU-National-1300-Premium" -Description "Allows local/national calls from  Australia to National, Emergency, 1300 and Premium numbers" -OnlinePstnUsages @{Add=$AU_National_1300_PremiumList}
New-CsOnlineVoiceRoutingPolicy "AU-International" -Description "Allows local/national calls from Australia to National, Emergency and International numbers" -OnlinePstnUsages @{Add=$AU_InternationalList}
New-CsOnlineVoiceRoutingPolicy "AU-International-1300" -Description "Allows local/national calls from Australia to National, Emergency, International and 1300 numbers" -OnlinePstnUsages @{Add=$AU_International_1300List}
New-CsOnlineVoiceRoutingPolicy "AU-International-1300-Premium" -Description "Allows local/national calls from Australia to National, Emergency, International, 1300 and Premium numbers" -OnlinePstnUsages @{Add=$AU_International_1300_PremiumList}
 


################################################################
################################################################
################################################################
################################################################
#Creating voice routes
Write-Host "Creating voice routes"
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
$OutboundTeamsNumberTranslations = New-Object 'System.Collections.Generic.List[string]'
$OutboundPSTNNumberTranslations = New-Object 'System.Collections.Generic.List[string]'
New-CsTeamsTranslationRule -Identity "SBCconnect-AllCalls" -Pattern '^\+(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(;ext=\d+)?$' -Translation '+$1$2' -Description "Outbound translation rules" | Out-Null
$OutboundTeamsNumberTranslations.Add("SBCconnect-AllCalls")

Write-Host 'Adding translation rules to PSTN gateways'
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
