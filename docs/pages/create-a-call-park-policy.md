# Create a Call Park Policy

## Steps
1. Log into the Teams Admin Portal 
   - https://admin.teams.microsoft.com/ 
1. Navigate to **Voice** > **Call park policies** 
1. Select **+** Add 
1. Enter in a **Display name** and **Description** 
   - It’s recommended to start *display names* with CPP_. 
1. Set **Allow call park** to On or Off as required.
1. Click Save 

## PowerShell
The script will prompt for a name to use for the new Call Park Policy and will auto-format the name as required

> ⚠ This script assumes you've already connected to the Skype for Business Online PowerShell Module. See [Here](connecting-to-sfbo-ps-module.md) to connect

````PowerShell
#Get the name of the new Call Park Policy from the user
Write-Host "This script will create a new Call Park Policy" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "The only allowed symbols are - and _"
$CppName = Read-Host "Please enter the name for the new Call Park Policy"

#Create the name for the Call Park Policy by removing all spaces and adding CPP_ to the start
$CppDisplayName = $CppName -replace '[`~!@#$%^&\*()+={}|\[\]\;:\''",/<>?]',''
$CppUserName = "CPP_$CppDisplayName

#Create a new Call Park Policy Queue
New-CsTeamsCallParkPolicy -Identity "$CppUserName" -AllowCallPark $true
````
