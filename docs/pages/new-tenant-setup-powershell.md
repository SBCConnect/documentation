# Setup a new Microsoft 365 tenant from scratch

````PowerShell
#Create Online PSTN Gateway (MNF Enterprise to Advise TLS Port) 
New-CsOnlinePSTNGateway -Fqdn <customer.pstnconnect.com> -SipSignallingPort <TLS Port> -MaxConcurrentSessions <channels> -ForwardCallHistory $true -Enabled $true 

#Create PSTN Usage 
Set-CsOnlinePstnUsage -Identity Global -Usage @{Add="Australia"} 

#Create Voice Routes and Associate with PSTN Usage 
New-CsOnlineVoiceRoute -Identity "AU-Emergency" -NumberPattern "^+000$" -OnlinePstnGatewayList <customer.pstnconnect.com> -Priority 1 -OnlinePstnUsages "Australia" 
New-CsOnlineVoiceRoute -Identity "AU-Service" -NumberPattern "^\+61(1\d{2,8})$" -OnlinePstnGatewayList <customer.pstnconnect.com> -Priority 1 -OnlinePstnUsages "Australia" 
New-CsOnlineVoiceRoute -Identity "AU-National" -NumberPattern "^\+61\d{9}$" -OnlinePstnGatewayList <customer.pstnconnect.com> -Priority 1 -OnlinePstnUsages "Australia" 
New-CsOnlineVoiceRoute -Identity "AU-International" -NumberPattern "^\+(?!(61190))([1-9]\d{9,})$" -OnlinePstnGatewayList <customer.pstnconnect.com> -Priority 1 -OnlinePstnUsages "Australia" 

#Create Voice Routing Policy 
New-CsOnlineVoiceRoutingPolicy "Australia" -OnlinePstnUsages "Australia" 

#Anonymous Caller ID Policy for Outbound Calls 
New-CsCallingLineIdentity  -Identity Anonymous -Description "Anonymous policy" -CallingIDSubstitute Anonymous -EnableUserOverride $false 
````
