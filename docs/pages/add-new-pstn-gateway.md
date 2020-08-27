# Add a new PSTN Gateway for Direct Routing
A PSTN Gateway is a configuration item within Microsoft Teams that enables Teams to tell where to route inbound calls to and where to send calls when an outboud call is made.

There may be more than one PSTN gateway required by the platform. Please refer to the configuration information supplied by the platform team.

## Required Information
- PSTN gateway FQDN
- Gateway port
- Maximum concurrent channels

## PowerShell
**You need to update the following details in the three (3) lines below**
- {GATEWAY} - The FQDN of the gateway
- {PORT} - The port used by the gateway
- {CHANNELS} - The maximum number of channels supported by the gateway

<i class="fas fa-terminal"></i> **Raw PowerShell Code**

````PowerShell
#Give the user a DID number and Voice Enable the user 
New-CsOnlinePSTNGateway -Fqdn {GATEWAY} -SipSignallingPort {PORT} -MaxConcurrentSessions {CHANNELS} -ForwardCallHistory $true -Enabled $true 
````

<i class="fas fa-keyboard"></i> **SBC-Easy PowerShell Code**
> ⚠ These scripts assume that you've already connected to the **Skype for Business Online PowerShell Module**.\
Need to connect? See [Connecting to Skype for Business Online PowerShell Module](connecting-to-sfbo-ps-module.md)

````powershell
# Placeholder
````
