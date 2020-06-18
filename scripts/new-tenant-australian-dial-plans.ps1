# $ErrorActionPreference can be set to SilentlyContinue, Continue, Stop, or Inquire for troubleshooting purposes
$Error.Clear()
$ErrorActionPreference = 'SilentlyContinue'

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
if ($skypeConnection.Availability -ne 'Available') {write-host "Unable to connect to online services. Please try the script again." -BackgroundColor Red -ForegroundColor White; pause; exit}

################################################################
################################################################
################################################################
################################################################
#Before we start making changes, let's check a few things

#Check a PSTN Online Gateway is present

$PSTNGW = Get-CsOnlinePSTNGateway
If (($PSTNGW.Identity -eq $NULL) -and ($PSTNGW.Count -eq 0)) {
    Write-Host
    Write-Host 'No PSTN gateway found. If you want to configure Direct Routing, you have to define at least one PSTN gateway Using the New-CsOnlinePSTNGateway command.' -ForegroundColor Yellow
    Write-Host 'The script will now exit.' -ForegroundColor Yellow
    Pause
    Exit
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
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[38]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia"

Set-CsTenantDialPlan -Identity $DPParent -NormalizationRules @{add=$NR}

################################################################
#Setup the Central and West (08) Dial Plans

$DPParent = "AU-CentralandWest"

Write-Host "Creating Central and West (08) normalization rules"
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-CentralandWest-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+618$1' -InMemory -Description "Local number normalization for Central and West, Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[38]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"

Set-CsTenantDialPlan -Identity $DPParent -NormalizationRules @{add=$NR}

################################################################
#Setup the Central East (02) Dial Plans

$DPParent = "AU-CentralEast"

Write-Host "Creating Central East (02) normalization rules"
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-CentralEast-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+612$1' -InMemory -Description "Local number normalization for Central East, Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[38]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"

Set-CsTenantDialPlan -Identity $DPParent -NormalizationRules @{add=$NR}

################################################################
#Setup the South East (03) Dial Plans

$DPParent = = "AU-SouthEast"

Write-Host "Creating normalization rules"
$NR = @()
$NR += New-CsVoiceNormalizationRule -Name "AU-SouthEast-Local" -Parent $DPParent -Pattern '^([2-9]\d{7})$' -Translation '+613$1' -InMemory -Description "Local number normalization for South East, Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-TollFree' -Parent $DPParent -Pattern '^(1[38]\d{4,8})\d*$' -Translation '+61$1' -InMemory -Description "TollFree number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Premium' -Parent $DPParent -Pattern '^(19\d{4,8})$' -Translation '+61$1' -InMemory -Description "Premium number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Mobile' -Parent $DPParent -Pattern '^0(([45]\d{8}))$' -Translation '+61$1' -InMemory -Description "Mobile number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-National' -Parent $DPParent -Pattern '^0([23578]\d{8})\d*(\D+\d+)?$' -Translation '+61$1' -InMemory -Description "National number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-Service' -Parent $DPParent -Pattern '^(000|1[0125]\d{1,8})$' -Translation '$1' -InMemory -Description "Service number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"
$NR += New-CsVoiceNormalizationRule -Name 'AU-International' -Parent $DPParent -Pattern '^(?:\+|0011)(1|7|2[07]|3[0-46]|39\d|4[013-9]|5[1-8]|6[0-6]|8[1246]|9[0-58]|2[1235689]\d|24[013-9]|242\d|3[578]\d|42\d|5[09]\d|6[789]\d|8[035789]\d|9[679]\d)(?:0)?(\d{6,14})(\D+\d+)?$' -Translation '+$1$2' -InMemory -Description "International number normalization for Australia`r`n`r`nGenerated by UCDialPlans.com v.14.40 on 2020-Jun-18`r`nCopyright Â© 2020  Ken Lasko (klasko@ucdialplans.com)`r`nhttps://www.ucdialplans.com`r`nhttps://ucken.blogspot.com`r`nYou must read and abide by the terms of service at https://www.ucdialplans.com/termsofservice.htm"

Set-CsTenantDialPlan -Identity $DPParent -NormalizationRules @{add=$NR}

################################################################
################################################################
################################################################
################################################################
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
