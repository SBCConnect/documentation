<# 
This script is an ever evolving script to deploy users into a Microsoft 365 tenancy.
The script will
- prompt for a CSV file to import from
- If the CSV user doesn't have a Voice Routing Policy tagged, then it will look at and prompt for the Voice Routing Policy to use
- If the CSV user doesn't have a Dial Plan tagged, then it will look at and prompt for the Dial Plan to use
- Will check if there is an ext extention in the CSV and use that if required 
** NOTES **
- If there are users without a Voice Routing Policy, then the prompted VRP will be applied to all users with an invalid or blank VRP in the CSV
- The script can be run as many times as you like for the same users, it will just over write the current information
The Imported CSV should have the following named columns
- UserPrincipalName
- DID
- EXT
- VoiceRoutingPolicy
- DialPlan
The CSV file should be formatted so
- The DID is in E.164 format (IE: +61255556666)
- The EXT is between 3-5 digits long
- The EXT is not 000, 112, or 911
Script written by Jay Antoney - 5G Networks
https://5gn.com.au
jaya@5gn.com.au
Script version v1.2 - 2020/09/22
TO DO / BROKEN
- Nill outstanding
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

    #Check we're logged into the Skype for Business Online PowerShell Module
    try {
        $tenantDisplayName = (Get-CsTenant | Select DisplayName).DisplayName
        Write-Host "The tenant you're connected to is $($tenantDisplayName)" -ForegroundColor Green
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
        Write-Host "Please log back into the Microsoft Teams - Skype for Business Online powershell module using the full script on the SBC Connect website"
        Write-Host "https://sbcconnect.com.au/pages/connecting-to-sfbo-ps-module.html"
        Write-Host
        Pause
        Break fullscript
    }

    #logged in
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


############################
# Function Validate-CSVData is used to confirm that the CSV data is valid and basic checks on the tenant
#
# - Check all the required columns are there
# - Check the UPN is in a valid format
# - Check the DID number is in a valid format
# - Check the EXT is in a valid format and between 3-5 digits long
# - Check the EXT is not 000, 112 or 911

Function Validate-CSVData()
{
    clear
    Write-Host
    Write-Debug "Enter Validate-CSVData"
    Write-Host "Validating data in the CSV file..."

    #Confirm that the CSV has the minumum required fields UserPrincipalName & DID
    if($global:inputdata.UserPrincipalName -eq $null) {write-host; write-host "The imported CSV doesn't contain a UserPrincipalName field. This is required for correct script operation" -ForegroundColor red; return $false}
    if($global:inputdata.DID -eq $null) {write-host; write-host "The imported CSV doesn't contain a DID field. This is required for correct script operation" -ForegroundColor red; return $false}
       
    #RegEx pattern for an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'
    #Regex pattern for a DID number with or without the + symbol (accept either)
    $DIDRegex = '^\+?[1-9]\d{1,14}$'
    #Regex pattern for the EXT number
    $EXTRegex = '^[1-9]\d{2,4}$'

    [bool]$importError = $false
    foreach($csvUserValidate in $global:inputdata)
    {
        [string]$comment = $null
        write-host "$($csvUserValidate.UserPrincipalName) - $($csvUserValidate.VoiceRoutingPolicy)"

        #Check the UPN is in a valid format
        if($csvUserValidate.UserPrincipalName -notmatch $EmailRegex)
        {
            Write-Host "ERROR: UPN $($csvUserValidate.UserPrincipalName) is not formatted correctly." -ForegroundColor Red
            $comment = "UPN not formatted Correctly"
        }
        
        #Check the DID number is valid
        if ($csvUserValidate.DID -notmatch $DIDRegex) {
            #DID doesn't match RegEx pattern
            if($comment) {$comment += " & DID incorrectly formatted"} else {$comment = "DID incorrectly formatted"}
            Write-Host "ERROR: $($csvUserValidate.UserPrincipalName) - The number entered '$($csvUserValidate.DID)' is incorrectly formatted" -ForegroundColor Red
            
        } else {
            #DID does match RegEx pattern - Check if first char is a plus [+], if not, then add it
            if ($csvUserValidate.DID.SubString(0,1) -ne "+") {$csvUserValidate.DID = "+" + $csvUserValidate.DID}
        }

        #Check the EXT of the user
        if ($csvUserValidate.EXT -ne $null -and $csvUserValidate.EXT -notmatch $EXTRegex) {
            if($comment) {$comment += " & EXT incorrectly formatted"} else {$comment = "EXT incorrectly formatted"}
            Write-Host "ERROR: $($csvUserValidate.UserPrincipalName) - The EXT entered '$($csvUserValidate.EXT)' is incorrectly formatted" -ForegroundColor Red
        }

        #Check the Voice Routing Policy of the user actually matches something in the tenant
        if ($csvUserValidate.VoiceRoutingPolicy -ne $null -and $csvUserValidate.VoiceRoutingPolicy -ne '') {
            if(-not $global:UsagePolicy.identity.tolower().Contains("tag:$($csvUserValidate.VoiceRoutingPolicy.tolower())")) {
                if($comment) {$comment += " & Voice Routing Policy doesn't exist in the tenant"} else {$comment = "Voice Routing Policy doesn't exist in the tenant"}
                Write-Host "ERROR: $($csvUserValidate.UserPrincipalName) - The Voice Routing Policy '$($csvUserValidate.VoiceRoutingPolicy)' doesn't exist in the tenant" -ForegroundColor Red
            }
        } else {
            $global:noVrpUsers += $csvUserValidate
        }

        #Check the Dial Plan of the user actually matches something in the tenant
        if ($csvUserValidate.DialPlan -ne $null -and $csvUserValidate.DialPlan -ne '') {
            if(-not $global:DialPlan.identity.tolower().Contains("tag:$($csvUserValidate.DialPlan.tolower())")) {
                if($comment) {$comment += " & Dial Plan doesn't exist in the tenant"} else {$comment = "Dial Plan doesn't exist in the tenant"}
                Write-Host "ERROR: $($csvUserValidate.UserPrincipalName) - The Dial Plan '$($csvUserValidate.DialPlan)' doesn't exist in the tenant" -ForegroundColor Red
            }
        } else {
            $global:noDialPlanUsers += $csvUserValidate
        }

        #If the $comment variable has anything in it, then there was an error so we need to record it
        if ($comment) {
            $importError = $true
            $global:invalidUsers += @([pscustomobject]@{UserPrincipalName=$csvUserValidate.UserPrincipalName;Comment=$comment})
            $global:invalidUsers | export-csv -Path c:\temp\Failed_user_import.csv -NoTypeInformation
        }
    }

    #Check if there was an error in the process and display it
    if ($importError) {
        Write-Host
        Write-Host "Errors were found during the import of users that must be corrected before we can continue." -ForegroundColor Yellow
        Write-Host "Please correct the CSV and re-import the CSV when ready" -ForegroundColor Yellow
        Write-Host
        Write-Host
        Write-Debug "Exit Validate-CSVData"
        return $false
    } else {
        #If we got this far, then everything is good - return true
        Write-Host "Data in the CSV has been verified" -ForegroundColor Green
        Write-Debug "Exit Validate-CSVData"
        return $true
    }
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

$global:invalidUsers = $null
$global:noVrpUsers = @()
$global:noDialPlanUsers = @()
$global:csvimportCheck = $false
$csvUser = $null
#Set the SKU for the Microsoft Phone System License. Other wise refered to as MCOEV and MicrosoftCommunicationsOnline
$phoneSystemLicenseSKU = '4828c8ec-dc2e-4779-b502-87ac9ce28ab7'

Clear

###########################################################

#Check the Azure Login and that it's the correct tenant
Check-AzureADLogin
Check-SkypeLogin
Clear
Write-Host
Write-Host "---- You're logged into ----"
Write-Host "Azure AD Tenant: $((Get-AzureADTenantDetail).DisplayName)" -ForegroundColor Yellow
Write-Host "Skype for Business Online Tenant: $((Get-CsTenant).DisplayName)" -ForegroundColor Yellow
Write-Host "----------------------------"
Write-Host
Write-Host

###########################################################

Write-Host "Loading tenant data..."
#Get the CSOnlineVoiceRoutingPolicies used through the script
$global:UsagePolicy = Get-CsOnlineVoiceRoutingPolicy
Write-Host "$($global:UsagePolicy.count) Voice Routing Policies loaded"

#Check if there are any Voice Usage Policies in the tenant
If (($UsagePolicy.Identity -eq $NULL) -and ($UsagePolicy.Count -eq 0)) {
    clear		
    Write-Host
    Write-Host 'No Voice Usage Policies were found in the tenant. Before we can configure users for Calling, you have to define at least one voice usage policy.' -ForegroundColor Red
    Write-Host "https://sbcconnect.com.au/pages/getting-started-new-tenant-customer.html" -ForegroundColor Yellow
    Write-Host "Sorry, we can't continue" -ForegroundColor Yellow
    pause
    Break #Break to maintain the login connection
}


#Get the CSOnlineVoiceRoutingPolicies used through the script
$global:DialPlan = Get-CsTenantDialPlan
Write-Host "$($global:DialPlan.count) Tenant Dial Plans loaded"
Write-Host

#Check if there are any Tenant Dial Plans in the tenant
If (($DialPlan.Identity -eq $NULL) -and ($DialPlan.Count -eq 0)) {
    clear		
    Write-Host
    Write-Host 'No Tenant Dial Plans were found in the tenant. Before we can configure users for Calling, you have to define at least one Tenant Dial Plan.' -ForegroundColor Red
    Write-Host "https://sbcconnect.com.au/pages/getting-started-new-tenant-customer.html" -ForegroundColor Yellow
    Write-Host "Sorry, we can't continue" -ForegroundColor Yellow
    pause
    Break #Break to maintain the login connection
}

###########################################################

#get the CSV list of users & validate the data
Write-Host "Loading CSV file..."
while($global:csvimportCheck -ne $true){$global:csvimportCheck = Get-UsersFromCsv; Write-Debug "ImportCheck = $csvimportcheck"; if($global:csvimportCheck -ne $true){Pause}}
$numUsers = ($global:inputdata | Measure-Object).Count


###########################################################
###########################################################

#Check if we need to prompt the user for a selection of the default Voice Routing Policies
#This will only run if during CSV verification we decided that a user didn't have a Voice Routing Policy applied
if ($global:noVrpUsers.count -gt 0) {
    #We've already checked that there are polices in the tenant. Now prompt for a default
    $UsagePolicyList = @()

	If ($UsagePolicy.Count -gt 1) {
		$select = $null
        While ($UsagePolicyList.Count -ne 1) {
            $UsagePolicyList = @()		
            Clear
            Write-Host
            Write-Host "$($numUsers) users were imported from the CSV"
            Write-Host "$($global:noVrpUsers.count) user(s) don't have any Voice Routing Policies assigned to them on the imported CSV" -ForegroundColor Yellow
            Write-Host
            Write-Host "Please select a Voice Routing Policy to apply to them"

            if ($select -eq 'u') {
                Write-Host
                Write-Host "Users affected by this selection are:" -ForegroundColor Green
                Write-Host "$($noVrpUsers.UserPrincipalName)"
            }

            Write-Host
		    Write-Host "ID    Voice Routing Policy"
		    Write-Host "==    ============"
		    For ($i=0; $i -lt $UsagePolicy.Count; $i++) {
			    $a = $i + 1
			    $name = $UsagePolicy[$i].Identity
                if ($name -like "Tag:*"){$name = $name.SubString(4)}
                $forColor = "white"
                if ($name -eq "AU-National-1300") {$name = $name + "  [Recommended]"; $forColor = "Green"}
                Write-Host ($a, $name) -Separator "     " -ForegroundColor $forColor
		    }
            
            Write-Host
            Write-Host "u     List users that this policy will apply to"

		    $Range = '(1-' + $UsagePolicy.Count + '|u)'
		    Write-Host
		    $Select = Read-Host "Select a Voice Routing Policy to apply to $($noVrpUsers.count) user(s) " $Range

		    #If $Select = 'u' then loop back to the start of the menu
            if ($select -ne 'u') {
                If (([System.Convert]::ToDecimal($Select) -gt $UsagePolicy.Count) -or ([System.Convert]::ToDecimal($Select) -lt 1)) {
                    Write-Host			        
                    Write-Host 'Invalid selection' -ForegroundColor Red
                    Write-Host
                    Pause
		        }
		        Else {
			        $UsagePolicyList += $UsagePolicy[$Select-1]
		        }
            }
        }

	}
	Else { # There is only one PSTN gateway
		$UsagePolicyList = Get-CsOnlineVoiceRoutingPolicy
	}
}

$UsagePolicyName = $UsagePolicyList.Identity
if ($UsagePolicyName -like "Tag:*"){$UsagePolicyName = $UsagePolicyName.SubString(4)}
if ($UsagePolicyName -eq "Global"){$UsagePolicyName = $null}

Write-Debug "Voice Routing Policy Identity Selected: $($UsagePolicyList.Identity)"

###########################################################
###########################################################

#Check if we need to prompt the user for a selection of the default Tenant Dial Plan
#This will only run if during CSV verification we decided that a user didn't have a Dial Plan applied
if ($global:noDialPlanUsers.count -gt 0) {
    #We've already checked that there are polices in the tenant. Now prompt for a default
    $tenantDialPlanList = @()

	If ($DialPlan.Count -gt 1) {
		$select = $null
        While ($tenantDialPlanList.Count -ne 1) {
            $tenantDialPlanList = @()		
            Clear
            Write-Host
            Write-Host "$($numUsers) users were imported from the CSV"
            Write-Host "$($global:noDialPlanUsers.count) user(s) don't have any Tenant Dial Plans assigned to them on the imported CSV" -ForegroundColor Yellow
            Write-Host
            Write-Host "Please select a Voice Routing Policy to apply to them"

            if ($select -eq 'u') {
                Write-Host
                Write-Host "Users affected by this selection are:" -ForegroundColor Green
                Write-Host "$($noDialPlanUsers.UserPrincipalName)"
            }

            Write-Host
		    Write-Host "ID    Tenant Dial Plan"
		    Write-Host "==    ============"
		    For ($i=0; $i -lt $DialPlan.Count; $i++) {
			    $a = $i + 1
			    $name = $DialPlan[$i].Identity
                if ($name -like "Tag:*"){$name = $name.SubString(4)}
                Write-Host ($a, $name) -Separator "     "
		    }
            
            Write-Host
            Write-Host "u     List users that this policy will apply to"

		    $Range = '(1-' + $DialPlan.Count + '|u)'
		    Write-Host
		    $Select = Read-Host "Select a Tenant Dial Plan to apply to $($noDialPlanUsers.count) user(s) " $Range

		    #If $Select = 'u' then loop back to the start of the menu
            if ($select -ne 'u') {
                If (([System.Convert]::ToDecimal($Select) -gt $DialPlan.Count) -or ([System.Convert]::ToDecimal($Select) -lt 1)) {
                    Write-Host			        
                    Write-Host 'Invalid selection' -ForegroundColor Red
                    Write-Host
                    Pause
		        }
		        Else {
			        $tenantDialPlanList += $DialPlan[$Select-1]
		        }
            }
        }

	}
	Else { # There is only one PSTN gateway
		$tenantDialPlanList = Get-CsOnlineVoiceRoutingPolicy
	}
}

$tenantDialPlanName = $tenantDialPlanList.Identity
if ($tenantDialPlanName -like "Tag:*"){$tenantDialPlanName = $UsagePolicyName.SubString(3)}
if ($tenantDialPlanName -eq "Global"){$tenantDialPlanName = $null}

Write-Debug "Tenant Dial Plan Identity Selected: $($tenantDialPlanName.Identity)"

###########################################################
###########################################################

<# 
Now we need to test
- If the user is licensed 
- If the tenant has spare licenses
#>

clear
Write-Host
Write-Host "$($numUsers) users were imported from the CSV"
Write-Host

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

Write-Host
Write-Host

    foreach($csvUserDetail in $global:inputdata)
    {
        Write-Host "Setting up user: $($csvUserDetail.UserPrincipalName)" -ForegroundColor Green   

        #Check user is a Skype for Business ONLINE user and not On-Prem
        Try {$checkRP = Get-CsOnlineUser -Identity $csvUserDetail.UserPrincipalName -ErrorAction Stop}
        Catch {Write-Host "Something is wrong with this user. Please check the UPN is correct. $ErrorMsg" -ForegroundColor Red; $checkRP.RegistrarPool = "NOTHING"; Write-Host; Pause}
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
                #Try {Set-AzureADUser -ObjectID $csvUserDetail.UserPrincipalName -UsageLocation "AU" -ErrorAction Stop}
                #Catch {Write-Host "We're unable to set the users usage Location to Australia. $ErrorMsg" -ForegroundColor Yellow -BackgroundColor Red; Pause}
                
            } else {
                Write-Host "Location: $($checkRP.UsageLocation)"
            }
            

            #Check if user has a Phone System license
            if((Get-AzureADUserLicenseDetail -objectid $csvUserDetail.UserPrincipalName | Select -Expand ServicePlans | where ServicePlanId -eq $phoneSystemLicenseSKU).length)
            {
                $alreadyAssigned++
            } else {
                $missingLicense++
                Write-Host "User doesn't have a license. Please assign a license and re-run script" -ForegroundColor Red
                pause
                break fullscript
            }

            # Finish assigning licenses and setting up the user
            #####################################
            #If the user has a EXT, then add it now
            if ($csvUserDetail.EXT -ne $null -and $csvUserDetail.EXT -ne '') {
                $pstnNumber = "tel:$($csvUserDetail.DID);ext=$($csvUserDetail.EXT)"
            } else {
                $pstnNumber = "tel:$($csvUserDetail.DID)"
            }

            #Enable Enterprise Voice, Enable Hosted Voicemail or Add the users PSTN Number
            Write-Host "[1/3] | Assigning the number $($csvUserDetail.DID) to the user and Voice Enabling the user"
            $error.Clear()
            Try {Set-CsUser -Identity $csvUserDetail.UserPrincipalName -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI $pstnNumber -ErrorAction Stop}
            Catch {Write-Host "Unable to either Enable Enterprise Voice, Enable Hosted Voicemail or Add the users PSTN Number. $ErrorMsg" -ForegroundColor Yellow -BackgroundColor Red; Write-Host "------------------"; Write-Host $error; Write-Host "------------------"; Write-Host; Pause}

            #####################################
            #If the user does NOT a Voice Routing Policy, then add the selected default now
            if ([string]::IsNullOrWhiteSpace($csvUserDetail.VoiceRoutingPolicy)) {
                $cusVRP = $UsagePolicyList.identity
            } else {
                $cusVRP = $csvUserDetail.VoiceRoutingPolicy
            }
            
            # Set the calling policy to Australia
            $error.Clear()
            Write-Host "[2/3] | Assigning the Voice Routing Policy - $($cusVRP)"
            Try {Grant-CsOnlineVoiceRoutingPolicy -Identity $csvUserDetail.UserPrincipalName -PolicyName $cusVRP -ErrorAction Stop}
            Catch {Write-Host "Unable Set the users Voice Calling policy to $($cusVRP). $ErrorMsg" -ForegroundColor Red; Write-Host "------------------"; Write-Host $error; Write-Host "------------------"; Write-Host; Pause}



            #####################################
            #If the user does NOT a Tenant Dial Plan, then add the selected default now
            if ([string]::IsNullOrWhiteSpace($csvUserDetail.DialPlan)) {
                $cusDP = $tenantDialPlanList.identity
            } else {
                $cusDP = $csvUserDetail.DialPlan
            }
            
            # Set the Tenant Dial Plan
            $error.Clear()
            Write-Host "[3/3] | Assigning the Dial Plan - $($cusDP)"
            Try {Grant-CsTenantDialPlan -Identity $csvUserDetail.UserPrincipalName -PolicyName $cusDP -ErrorAction Stop}
            Catch {Write-Host "Unable Set the users Tenant Dial Plan to $($cusDP). $ErrorMsg" -ForegroundColor Red; Write-Host "------------------"; Write-Host $error; Write-Host "------------------"; Write-Host; Pause}



        } else {
            if($checkRP.RegistrarPool -ne "NOTHING") {
                Write-Host "User "$csvUserDetail.UserPrincipalName" isn't correctly setup and isn't homed in Office 365. Maybe it's an On-Prem user? We can't continue with this user" -ForegroundColor Red
                Write-Host
                Pause
            }
        }
        Write-Host
    }

Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Write-Host "Users that had licenses already assigned: "$alreadyAssigned 
if ($missingLicense -gt 0) {Write-Host "Users that had missing licenses: "$newlyAssigned -ForegroundColor Red}
Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
Write-Host "OK, We're all done!" -ForegroundColor Black -BackgroundColor Green
Write-Host "                   " -ForegroundColor Black -BackgroundColor Green
write-host
write-host
Write-Host "Thanks for using this script" -ForegroundColor Yellow
Write-Host
Write-Host "For bug, feedback and comments, please see the 5G Networks GitHub"
Write-Host "https://github.com/sbcconnect"
Write-Host
Write-Host "5G Networks"
Write-Host "+61 1300 10 11 12"
Write-Host "5gnetworks.com.au"
write-host
Pause
