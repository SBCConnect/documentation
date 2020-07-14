# General platform FAQ questions

## When a user calls in, they can hear the skype ring tone
The feature is refered to as the **Ringback bot for Direct Routing** by Microsoft and more information [can be found here](https://docs.microsoft.com/en-us/microsoftteams/direct-routing-ringback-bot)

This feature can be enabled or disabled using powershell on the tenant.\
After running the powershell command, the change can take up to one hour to apply

````PowerShell
#List the PSTN gateways on the tenant
Get-CsOnlinePSTNGateway

#Enable the feature - Replace {IDENTITY} with the identity found above
Set-CsOnlinePSTNGateway -Identity {IDENTITY} -GenerateRingingWhileLocatingUser $true

#Disable the feature - Replace {IDENTITY} with the identity found above
Set-CsOnlinePSTNGateway -Identity {IDENTITY} -GenerateRingingWhileLocatingUser $false
````
