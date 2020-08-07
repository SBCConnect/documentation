# Remove a number from a Teams User Account
When a Teams enabled user leaves the business, you need to remove the phone number from the user account, then remove the license.

## Steps
To remove the license, use the following powershell scripts

<i class="fas fa-terminal"></i> **Raw PowerShell Code**

````PowerShell
########################
# <UPN> = Users username
########################

Set-CsUser -Identity <UPN> -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$UserDID
````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

```powershell
######## DO NOT CHANGE BELOW THIS LINE - THE SCRIPT WILL PROMT FOR ALL VARIABLES ########

function Get-UserUPN {
    #Set a variable to check if we have a user or not
    $gotUser = $false

    #Regex pattern for checking an email address
    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    while ($gotUser -eq $false)
    {
        #Get the users UPN
        Write-Host ""
        $UserUPN = Read-Host "Please enter in the users full UPN who you're trying to remove the phone number from"
        while($UserUPN -notmatch $EmailRegex)
        {
         Write-Host "$UserUPN isn't a valid UPN. A UPN looks like an email address" -ForegroundColor Red
         $UserUPN = Read-Host "Please enter in the users full UPN who you're trying to remove the phone number from"
        }
        #Get the users current details just to confirm
        Try {$UserDetail = Get-CsOnlineUser -Identity $UserUPN}
        Catch {$gotUser = $false}
        if ($UserDetail) {$gotUser = $true}
    }
    return $UserDetail
}

#Check we're logged into the Skype for Business Online PowerShell Module
If ((Get-PSSession | Where-Object -FilterScript {$_.ComputerName -like '*.online.lync.com'}).State -eq 'Opened') {
	Write-Host 'SFB Logged in - Using existing session credentials' -ForegroundColor Green}
Else {
	Write-Host 'Skype for Business NOT Logged in - Please connect and try run the script again' -ForegroundColor Yellow
    pause
    break
}

#Confirm you’re logged into the correct tenant - Is it the correct name?
$tenant = Get-CsTenant | Select DisplayName
$tenantName = $tenant.DisplayName
Write-Host "The tenant you've connected to is: $tenantName" -BackgroundColor Yellow -ForegroundColor Black

#Get the user's UPN
Write-Host "We're ready to go!" -ForegroundColor Green
$UserDetail = Get-UserUPN

Write-Host ""
Write-Host ""
Write-Host " CONFIRM THIS IS THE CORRECT USER "
Write-Host "-----------------"
Write-Host "DisplayName: $($UserDetail.DisplayName)"
Write-Host "Username: $($UserDetail.UserPrincipalName)"
Write-Host "Hosted Voicemail Policy: $($UserDetail.HostedVoicemailPolicy)"
Write-Host "DID Number: $($UserDetail.OnPremLineURI)"
Write-Host "Online Voice Routing Policy: $($UserDetail.OnlineVoiceRoutingPolicy)"
Write-Host ""
$confirmYES = Read-Host "Type YES to remove the number from this user"
while ($confirmYES -ne 'YES')
{
    if ($confirmYES -eq 'NO') {
        write-host "You've chosen not to continue. The script will now exit" -foregroundcolor Yellow
        pause
        break
    }
    write-host "Please type YES in full to confirm, else type NO to exit" -foregroundcolor Yellow
    $confirmYES = Read-Host "Type YES to remove the number from this user"
}

#Remove the number from the user
Set-CsUser -Identity $UserDetail.UserPrincipalName -OnPremLineURI ""

Write-Host "Number $($UserDetail.OnPremLineURI) has beed removed from user $($UserDetail.DisplayName)"
```
