# Setup a new Microsoft 365 tenant from scratch

## Steps


## PowerShell
### Create the SBCs in Teams
This needs to be run for each SBC you're adding

<i class="fas fa-terminal"></i> **Raw PowerShell Code**

````PowerShell
#Create Online PSTN Gateway (SBC Connect platform team to Advise these details) 
New-CsOnlinePSTNGateway -Fqdn <customer.pstnconnect.com> -SipSignalingPort <TLS Port> -MaxConcurrentSessions <channels> -ForwardCallHistory $true -Enabled $true 
````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ This script assumes that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````PowerShell
#PLACEHOLDER
````

### Create the SBCs in Teams
This creates an anonymous call policy that can be later assigned to users for outbound calls
````PowerShell
#Anonymous Caller ID Policy for Outbound Calls 
New-CsCallingLineIdentity  -Identity Anonymous -Description "Anonymous policy" -CallingIDSubstitute Anonymous -EnableUserOverride $false 
````
