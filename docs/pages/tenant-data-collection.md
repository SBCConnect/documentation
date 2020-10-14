# Tenant Data Collection
This script aims to collect key information about your Microsoft 365 tenant that the SBC Connect platform team may require to onboard you into the platform.

> ⚠ Please only run this script when requested by your SBC Connect contact

## PowerShell
````Powershell
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

    Clear-Variable OverrideAdminDomain -ErrorAction SilentlyContinue
    
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
    
    $returnstring = @{}

    $returnString.username = $UserUPN
    $returnString.overrideAdminDomain = $OverrideAdminDomain

    return $returnString
}

#Check the Skype for Business Online PowerShell Module is installed

if(Get-Module SkypeOnlineConnector -ListAvailable)
    {
        Import-Module SkypeOnlineConnector
    } else {
        Write-host "The Skype for Business Online Powershell Module isn't installed!" -ForegroundColor Yellow -BackgroundColor Red
        Write-Host "We're opening the download page now for you!" -ForegroundColor Yellow -BackgroundColor Red
        write-host "URL: https://www.microsoft.com/en-us/download/details.aspx?id=39366" -ForegroundColor Yellow -BackgroundColor Red
        write-host "After installing, you'll need to close and re-open the PowerShell window, then re-run the PowerShell script" -ForegroundColor Yellow -BackgroundColor Red
        Pause
        Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
        Break
    }
clear
$userLogin = Get-UserUPN

#Check first, then connect to the Skype for Business PowerShell module 
Write-Host "Logging onto Skype for Business Online Powershell Module" -BackgroundColor Yellow -ForegroundColor Black
If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened') {
	Write-Host 'Using existing session credentials'}
Else {
	if($OverrideAdminDomain) {
        	$skypeConnection = New-CsOnlineSession -Username $userLogin.username -OverrideAdminDomain $userLogin.overrideAdminDomain
    	} else {
        	$skypeConnection = New-CsOnlineSession -Username $userLogin.username
    	}
	Import-PSSession $skypeConnection -AllowClobber
}

$tenant = Get-CsTenant | Select DisplayName
Write-Host ""
Write-Host "The tenant you've connected to is: $($tenant.DisplayName)" -BackgroundColor Yellow -ForegroundColor Black
Write-Host
Write-Host

$folder = join-path $env:USERPROFILE "Downloads\SBC_Connect"
if(-not ( test-path -Path $folder)) {write-host "Creating folder $($folder)"; new-item $folder -ItemType directory}
$try = 1
while (-not ( test-path -Path $folder) -and $try -lt 3) {
    write-host "Creating folder $($folder)  |  Attempt $($try)"
    new-item $folder -ItemType directory
    $try++
}
if ($try -gt 3) {Write-Host "Seems we weren't able to create the folder $($folder). Saving to $($env:USERPROFILE)\Downloads" -ForegroundColor Yellow; $folder = join-path $env:USERPROFILE "Downloads"}
Write-Host "Getting PSTN Gateways"
get-CsOnlinePSTNGateway | export-csv "$($folder)\PSTNgateway.csv" -NoTypeInformation
Write-Host "Getting Voice Routing Policies"
get-CsOnlineVoiceRoutingPolicy | export-csv "$($folder)\VoiceRoutingPolicy.csv" -NoTypeInformation
Write-Host "Getting Voice Routing Policies"
get-CsOnlineVoiceRoutingPolicy | export-csv "$($folder)\VoiceRoutingPolicy.csv" -NoTypeInformation
Write-Host "Getting Calling Line Identity"
get-CsCallingLineIdentity | export-csv "$($folder)\CallingLineIdentity.csv" -NoTypeInformation
Write-Host "Getting Voice Normalization Rules"
get-CsVoiceNormalizationRule | export-csv "$($folder)\VoiceNormalizationRule.csv" -NoTypeInformation
Write-Host "Getting PSTN Usage"
get-CsOnlinePSTNUsage | export-csv "$($folder)\PSTNUsage.csv" -NoTypeInformation
Write-Host "Getting Voice Route"
get-CsOnlineVoiceRoute | export-csv "$($folder)\VoiceRoute.csv" -NoTypeInformation
Write-Host "Getting Teams Translation Rule"
get-CsTeamsTranslationRule | export-csv "$($folder)\TeamsTranslationRule.csv" -NoTypeInformation

Write-Host
Write-Host
Write-Host "We're all done!. Please email these files we created to your SBC Connect contact"
Write-Host "The files are sitting in $($folder)"
Write-Host
Write-Host
Break
````
