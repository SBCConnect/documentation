<# 

This script is an ever evolving script to deploy users into a Microsoft 365 tenancy.
The script will
- prompt for a CSV file to import from
- look at and prompt for the Voice Routing Policy to use

** NOTES **
- All users imported by this script will have the same voice routing policy applied to them
- The script can be run as many times as you like for the same users

Script written by Jay Antoney - 5G Networks
https://5gn.com.au
jaya@5gn.com.au

Script version v1.0 - 22/6/2020

#>

#$DebugPreference = "Continue" #< Show all the debug messages
$DebugPreference = "SilentlyContinue" #< Hide all debug messages

function Get-UserCreds()
{
    Write-Debug "Enter Get-UserCreds"
    #Check if we already have creds
    if ($global:userOverAdmin -eq $null) {
        #Regex pattern for checking an email address
        $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'
        $msOnlineRegex = '^([\w-\.]+)@([a-zA-Z0-9]+)\.onmicrosoft\.com$'

        #Get the users UPN
        Write-Host ""

        $UserUPN = Read-Host "Please enter in your Username"
        while($UserUPN -notmatch $EmailRegex)
        {
         Write-Host "$UserUPN isn't a valid UPN" -ForegroundColor Red
         $UserUPN = Read-Host "Please enter in your Username"
        }
    
        #Set the global creds var to the username just entered
        $global:userCreds = $UserUPN

        #Clear the local function Override Admin variable
        Set-Variable -Name 'OverrideAdminDomain' -Value $Null

        If($global:userCreds -notmatch $msOnlineRegex) 
        {
            Write-Host "It seems you've entered a UPN not ending in onmicrosoft.com. This is OK, however we need to get that domain to be able to login correctly" -ForegroundColor Yellow
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
                        $OverrideAdminDomain = "$rootDomain.onmicrosoft.com"
                        write-debug "OverrideAdminDomain = $OverrideAdminDomain"
                    }
                } else {
                    If($OverrideAdminDomain -notmatch '^[a-zA-Z0-9]+$')
                    {
                        Write-Host "Prefix not valid" -ForegroundColor Yellow
                    } else {
                        $checkDomain = $false
                        $OverrideAdminDomain = "$OverrideAdminDomain.onmicrosoft.com"
                        write-debug "OverrideAdminDomain = $OverrideAdminDomain"
                    }
                }

                If($checkDomain -ne $false) {$OverrideAdminDomain = Read-Host "Please re-enter in your ______.onmicrosoft.com prefix"}
            }

        } else {
            $OverrideAdminDomain = $UserUPN.Substring(($UserUPN.IndexOf("@")+1))
        }

        $global:userCreds = $UserUPN
        $global:userOverAdmin = $OverrideAdminDomain
        Write-Debug "Set Variables global:userCreds ($global:userCreds) & global:userOverAdmin ($global:userOverAdmin)"
    }

    Write-Debug "Exit Get-UserCreds"
    return $true
}

Function Check-AzureADLogin()
{
    Write-Debug "Enter Check-AzureAD"
    #Connect to AzureAD
    Write-Host "We're checking if you're already connected to Azure AD..."

    try {Get-AzureADTenantDetail -ErrorAction Stop} 
    catch
    {
        Write-Host "OK, you're not logged into Azure AD - Let's try get you connected!"
        Get-UserCreds | Out-Null
        
        try {$azureConnection = Connect-AzureAD -ErrorAction Stop}
        catch 
        {
            #Error logging into the tenant
            $Title3 = "Azure AD Login Failed"
            $Info3 = "Something went wrong during login to Azure AD. Did you want to try again?"
            $options3 = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&Quit")
            [int]$defaultchoice3 = 1
            $opt3 = $host.UI.PromptForChoice($Title3 , $Info3 , $Options3,$defaultchoice3)

            #If no, then logout and re-prompt
            if($opt3 -eq 1)
            {
                Disconnect-AllSessions
                #Exit
                Break
            } Else {
                Write-Host "As you wish, trying to login to Azure AD again..."
                Disconnect-AllSessions
                Write-Debug "Entering nested Check-AzureADLogin"                
                return(Check-AzureADLogin)
            }
        }
    }

    #Logged IN
    #Check we're working on the correct AzureAD Tennant
    $global:tenantName = $null
    Try {Get-AzureADTenantDetail -ErrorAction Stop}
    Catch {Write-Host "It seems we're somehow still not logged in. Please close the script and re-open to try it again" -ForegroundColor Yellow -BackgroundColor Red; Disconnect-AllSessions; Pause; break} #We're not logged in... WHAT!
    $global:tenantName = (Get-AzureADTenantDetail).DisplayName
    $Title2 = "Is this correct?"
    $Info2 = "Is this the correct Azure AD Tenant? " + $global:tenantName
    $options2 = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
    [int]$defaultchoice2 = 0
    $opt2 = $host.UI.PromptForChoice($Title2 , $Info2 , $Options2,$defaultchoice2)

    #If no, then logout and re-prompt
    if($opt2 -eq 1)
    {
        Write-Host "Wrong tenant it seems..."
        Disconnect-AllSessions
        Check-AzureADLogin
    }
    
    Write-Debug "Exit Check-AzureAD"
}

Function Check-SkypeLogin()
{
    Write-Debug "Enter Check-SkypeLogin"
    #Connect to Skype for Business Online
    Write-Host "We're checking if you're already connected to Skype Online..." -ForegroundColor Black -BackgroundColor Cyan
    
    [int]$loginCounterSFB = 0

    while ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -ne 'Opened') {
        #No current SFB Session is open
        Write-Host "OK, you're not logged into Skype Online - Let's try get you connected!"
        
        Write-Debug "SFB: Hand off to Get-UserCreds"
        Get-UserCreds | Out-Null
        Write-Debug "SFB: Return from Get-UserCreds"

        try {$global:skypeConnection = New-CsOnlineSession -OverrideAdminDomain $global:userOverAdmin -ErrorAction Stop}
        catch 
        {
            Write-Debug "Skype Login Failed."
            #Check we're working on the correct AzureAD Tennant
            $Title3 = "Skype Login Failed?"
            $Info3 = "Something went wrong during login. Did you want to try again?"
            $options3 = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
            [int]$defaultchoice3 = 0
            $opt3 = $host.UI.PromptForChoice($Title3 , $Info3 , $Options3,$defaultchoice3)

            #If no, then logout and re-prompt
            if($opt3 -eq 1)
            {
                Disconnect-AllSessions
                #Exit
                Write-Debug "Break Check-SkypeLogin"   
                Break fullScript
            } Else {
                Write-Host "As you wish, trying to login again..."
                Disconnect-AllSessions
                Write-Debug "Entering nested Check-SkypeLogin"
            }
        }
    }

    #logged in
    Import-PSSession $global:skypeConnection -AllowClobber | out-null
    #Check this is the same tenant as AzureAD
    $skypeTenantName = Get-CsTenant | Select DisplayName
    
    if($global:tenantName -ne $skypeTenantName.DisplayName)
    {
        Write-Host "The Skype for Business Online tenant we connected to isn't the same as the Azure AD tenant... Whoops! - Let's try that again" -ForegroundColor Red
        Write-Debug "Tenant name mismatch. Logging out and entering nested Check-AzureADLogin to re-login in full" 
        Disconnect-AllSessions
        pause
        Write-Debug "Return Check-SkypeLogin"              
        return(Check-AzureADLogin)
    }
    Write-Debug "Exit Check-SkypeLogin"
}

Function Get-UsersFromCsv()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = "$env:userprofile\Downloads"
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $inputfile = $OpenFileDialog.filename
    [int]$inputfileLen = $inputfile.Length
    $global:inputdata = $null
    Write-Debug "`$inputfile length is: $inputfileLen"
    if ($inputfileLen -le 1)
    {
        Write-Debug "`$inputfile length is less than 1 - return False"
        return $false
    } else {
        $global:inputdata = import-csv $inputfile -ErrorAction SilentlyContinue
        Write-Debug "CSV Imported"

        if($global:inputdata -ne $null)
        {
            Write-Debug "Start Validate-CSVData"
            return(Validate-CSVData)
        } else {
            Write-Debug "No data imported - return False"
            return($false)
        }
    }
}

Function Check-InstalledModules()
{
    if(Get-Module SkypeOnlineConnector -ListAvailable)
    {
        Import-Module SkypeOnlineConnector
    } else {
        Write-host "The Skype for Business Online Powershell Module isn't installed!" -ForegroundColor Yellow -BackgroundColor Red
        Write-Host "We're opening the download page now for you!" -ForegroundColor Yellow -BackgroundColor Red
        write-host "URL: https://www.microsoft.com/en-us/download/details.aspx?id=39366" -ForegroundColor Yellow -BackgroundColor Red
        write-host "After installing, you'll need to re-run the PowerShell script after first closing the PowerShell Window" -ForegroundColor Yellow -BackgroundColor Red
        Pause
        Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=39366"
        Break
    }

    if(-Not (Get-Module AzureAD -ListAvailable))
    {
        Write-host "The AzureAD Powershell Module isn't installed!" -ForegroundColor Yellow -BackgroundColor Red
        Write-Host "We're going to try install it for you!" -ForegroundColor Yellow -BackgroundColor Red
        write-host "Please EXIT the script now if you don't want to install it" -ForegroundColor Yellow -BackgroundColor Red
        Pause
        Try{Install-Module AzureAD -AllowClobber -ErrorAction Stop}
        Catch{Write-Host "Unable to install the AzureAD PowerShell Module!"; Write-Host "Please try run 'Install-Module AzureAD -AllowClobber' from an elevated PowerShell window..." -ForegroundColor Yellow -BackgroundColor Red}
        write-host "After installing, you'll need to re-run the PowerShell script after first closing the PowerShell Window" -ForegroundColor Yellow -BackgroundColor Red
        Pause
        break
    }

}

Function Disconnect-AllSessions()
{
    Write-Debug "Enter Disconnect-AllSessions"
    Get-PSSession | Remove-PSSession | out-null
    $global:skypeConnection = $null
    $global:userOverAdmin = $null
    $loginerror = $null
    $global:userCreds = $null
    if(($global:tenantName).length -gt 1) {write-host "We've logged you out of: "$global:tenantName}
    $global:tenantName = $null
    $global:inputdata = $null
    $global:csvimportCheck = $false
    $global:userCredsCheck = $False
    $ErrorMsg = $null
    try{Disconnect-AzureAD -ErrorAction SilentlyContinue}
    Catch{Write-Debug "Disconnect-AzureAD Failed. $ErrorMsg"}
    Write-Debug "Exit Disconnect-AllSessions"

}

Function Validate-CSVData()
{
    Write-Debug "Enter Validate-CSVData"
    Write-Host "Validating data in the CSV file"

    #RegEx pattern for an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'
    #Regex pattern for a DID number MINUS the + symbol
    $DIDRegex = '^\+?[1-9]\d{1,14}$'

    foreach($csvUser in $global:inputdata)
    {
        #Check there is an @ symbol in the UPN. If not then exit
        if($csvUser.UserPrincipalName -notmatch $EmailRegex)
        {
            Write-Host "The UPN for "$csvUser.UserPrincipalName" is not formatted correctly. Others may also be incorrectly formatted. Please correct and re-run script" -ForegroundColor Red
            Disconnect-AllSessions
            return $false
        }
        
        if ($csvUser.DID -notmatch $DIDRegex) {
            #DID doesn't match RegEx pattern
            #No idea what is wrong, just exit
            Write-Host "User number in an invalid format [$($csvUser.UserPrincipalName)] - Number Entered: [$($csvUser.DID)]" -BackgroundColor Red
            Write-Host "Please check other users, then re-run the script" -BackgroundColor Red
            Disconnect-AllSessions
            return $false

        } else {
            #DID does match RegEx pattern - Check if first char is a plus [+], if not, then add it
            if ($csvUser.DID.SubString(0,1) -ne "+") {$csvUser.DID = "+" + $csvUser.DID}
        }

    }

    #if we got this far, then everything is good!
    Write-Host "Data in the CSV all looks good" -ForegroundColor Green
    Write-Debug "Exit Validate-CSVData"
    return $true
}

Check-InstalledModules
#Disconnect-AllSessions
#Clear

<###########################
# -- BYPASSING this message now because the script doesn't set the country anymore

#Initial Warning Message
$Title1 = "User Location Warning"
$Info1 = "This script is for users located in AUSTRALIA only and will set all users usage locations to AUSTRALIA. Are you sure you want to continue?"
$options1 = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&Quit")
[int]$defaultchoice1 = 1
$opt1 = $host.UI.PromptForChoice($Title1 , $Info1 , $Options1,$defaultchoice1)


#If the user selected to quit
if($opt1 -eq 1) {
    #Exit
    Write-Host "To confirm, you've selected that your users are NOT in AUSTRALIA." -ForegroundColor Yellow -BackgroundColor Red
    Write-Host "Sorry, but this script is only for AUSTRALIAN users" -ForegroundColor Yellow -BackgroundColor Red
    Pause
    Break fullScript
}
###########################>


#get the CSV list of users & validate the data
while($global:csvimportCheck -ne $true){$global:csvimportCheck = Get-UsersFromCsv; Write-Debug "ImportCheck = $csvimportcheck"; if($global:csvimportCheck -ne $true){Pause}}
#do {$global:csvimportCheck = Get-UsersFromCsv} until($global:csvimportCheck = $true) #### This line never worked
Write-host "We've got the users and all looks OK"
$numUsers = ($global:inputdata | Measure-Object).Count
Write-Host $numUsers" users were imported from the CSV"

###########################################################

#Check the Azure Login and that it's the correct tenant
Check-AzureADLogin
Check-SkypeLogin
Write-Host "Cool! We're all logged in" -ForegroundColor Green

###########################################################

# Check for existence of PSTN gateways and prompt to add PSTN usages/routes
	$UsagePolicy = Get-CsOnlineVoiceRoutingPolicy
    $UsagePolicyList = @()
	If (($UsagePolicy.Identity -eq $NULL) -and ($UsagePolicy.Count -eq 0)) {
		Write-Host
		Write-Host 'No Voice Usage Policies were found in the tenant. Before we can configure users for Calling, you have to define at least one voice usage policy.' -ForegroundColor Red
        Write-Host "https://sbcconnect.com.au/pages/getting-started-new-tenant-customer.html" -ForegroundColor Yellow
        Write-Host "Sorry, we can't continue" -ForegroundColor Yellow
        pause
		Exit
	}

	If ($UsagePolicy.Count -gt 1) {
		
        While ($UsagePolicyList.Count -ne 1) {
            $UsagePolicyList = @()		
            Write-Host
		    Write-Host "ID    Voice Routing Policy"
		    Write-Host "==    ============"
		    For ($i=0; $i -lt $UsagePolicy.Count; $i++) {
			    $a = $i + 1
			    $name = $UsagePolicy[$i].Identity
                if ($name -like "Tag:*"){$name = $name.SubString(4)}
                Write-Host ($a, $name) -Separator "     "
		    }

		    $Range = '(1-' + $UsagePolicy.Count + ')'
		    Write-Host
		    $Select = Read-Host "Select a Voice Routing Policy to apply to all Users in this CSV file" $Range

		    If (($Select -gt $UsagePolicy.Count) -or ($Select -lt 1)) {
			    Write-Host 'Invalid selection' -ForegroundColor Yellow
		    }
		    Else {
			    $UsagePolicyList += $UsagePolicy[$Select-1]
		    }
        }

	}
	Else { # There is only one PSTN gateway
		$UsagePolicyList = Get-CsOnlineVoiceRoutingPolicy
	}

$UsagePolicyName = $UsagePolicyList.Identity
if ($UsagePolicyName -like "Tag:*"){$UsagePolicyName = $UsagePolicyName.SubString(4)}
if ($UsagePolicyName -eq "Global"){$UsagePolicyName = $null}

Write-Debug "Voice Routing Policy Identity Selected: $($UsagePolicyList.Identity)"

###########################################################

<# 
Now we need to test
- If the user is licensed 
- If the tenant has spare licenses
#>

#Set the SKU for the Microsoft Phone System License. Other wise refered to as MCOEV and MicrosoftCommunicationsOnline
$phoneSystemLicenseSKU = '4828c8ec-dc2e-4779-b502-87ac9ce28ab7'

#Get all the enabled and consumed licenses in the tenant, then add them up.
$totalLicenseEnabled = 0
$totalLicenseConsumed = 0
$plans = Get-AzureADSubscribedSku
foreach ($p in $plans) {

    if (($p | Select -ExpandProperty ServicePlans | Where-Object -Property ServicePlanId -EQ -Value $phoneSystemLicenseSKU).length -gt 0)
    {
        $t = Get-AzureADSubscribedSku -ObjectId $p.ObjectId | Select -Property Sku*,ConsumedUnits -ExpandProperty PrepaidUnits
        Write-Debug "Enabled License from $($t.SkuPartNumber): $($t.Enabled)"
        Write-Debug "Consumed License from $($t.SkuPartNumber): $($t.ConsumedUnits)"
        $totalLicenseEnabled = $totalLicenseEnabled + $t.Enabled
        $totalLicenseConsumed = $totalLicenseConsumed + $t.ConsumedUnits
    }
}

if (($totalLicenseEnabled - $totalLicenseConsumed) -le 0) {
    Write-Host "There may be an issue because the number of licenses in use in the tenant [$totalLicenseConsumed], is equal to or higher than the total available [$totalLicenseEnabled]" -ForegroundColor Yellow
}

if (($totalLicenseEnabled - $totalLicenseConsumed) -lt $numUsers) {
    Write-Host "CAUTION: There may not be enough licenses to cover all the users in imported CSV, We'll try anyway" -ForegroundColor Yellow
}


###########################################################

#Setup a few variables
[int]$alreadyAssigned = 0
[int]$missingLicense = 0

    foreach($csvUser in $global:inputdata)
    {}
        Write-Host "Setting up user: $($csvUser.UserPrincipalName)" -ForegroundColor Yellow -BackgroundColor Gray     

        #Check user is a Skype for Business ONLINE user and not On-Prem
        Try {$checkRP = Get-CsOnlineUser -Identity $csvUser.UserPrincipalName -ErrorAction Stop}
        Catch {Write-Host "Something is wrong with this user. Please check the UPN is correct. $ErrorMsg" -ForegroundColor Red; $checkRP.RegistrarPool = "NOTHING"; Pause}
        Write-Debug "variable checkRP.RegistrarPool is $($checkRP.RegistrarPool)"
        if($checkRP.RegistrarPool.Contains("infra.lync.com"))
        {
            #Check user's usage location is set
            if([string]::IsNullOrEmpty($checkRP.UsageLocation))
            {
                Write-Host "User $($checkRP.UserPrincipalName) does not have a usage location set. Please assign a usage location and re-run script" -ForegroundColor Red
                Write-Host "Script will now exit"
                pause
                exit
                #Try {Set-AzureADUser -ObjectID $csvUser.UserPrincipalName -UsageLocation "AU" -ErrorAction Stop}
                #Catch {Write-Host "We're unable to set the users usage Location to Australia. $ErrorMsg" -ForegroundColor Yellow -BackgroundColor Red; Pause}
                
            } else {
                Write-Host "Location: $($checkRP.UsageLocation)"
            }
            

            #Check if user has a Phone System license
            if((Get-AzureADUserLicenseDetail -objectid $csvUser.UserPrincipalName | Select -Expand ServicePlans | where ServicePlanId -eq $phoneSystemLicenseSKU).length)
            {
                $alreadyAssigned++
            } else {
                $missingLicense++
                Write-Host "User doesn't have a license. Please assign a license and re-run script" -ForegroundColor Red
                pause
                exit
            }

            # Finish assigning licenses and setting up the user
            $pstnNumber = "tel:"+$csvUser.DID
            Write-Host "Setting PSTN Number "$csvUser.DID
            #Enable Enterprise Voice, Enable Hosted Voicemail or Add the users PSTN Number
            Try {Set-CsUser -Identity $csvUser.UserPrincipalName -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI $pstnNumber -ErrorAction Stop}
            Catch {Write-Host "Unable to either Enable Enterprise Voice, Enable Hosted Voicemail or Add the users PSTN Number. $ErrorMsg" -ForegroundColor Yellow -BackgroundColor Red; Pause}
            # Set the calling policy to Australia
            Try {Grant-CsOnlineVoiceRoutingPolicy -Identity $csvUser.UserPrincipalName -PolicyName $UsagePolicyName -ErrorAction Stop}
            Catch {Write-Host "Unable Set the users Voice Calling policy to $UsagePolicyName. $ErrorMsg" -ForegroundColor Red}

        } else {
            if($checkRP.RegistrarPool -ne "NOTHING") {
                Write-Host "User "$csvUser.UserPrincipalName" isn't correctly setup and isn't homed in Office 365. Maybe it's an On-Prem user? We can't continue with this user" -ForegroundColor Red
            }
        }

Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Write-Host "Users that had licenses already assigned: "$alreadyAssigned 
if ($missingLicense -gt 0) {Write-Host "Users that had missing licenses: "$newlyAssigned -ForegroundColor Red}
Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Write-Host "OK, We're all done!" -ForegroundColor Black -BackgroundColor Green
Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Pause
