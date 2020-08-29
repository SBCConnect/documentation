# Configure outbound anonymous calling
Outbound anonymous calling can be configured in multiple ways

- Per user forced
  The policy is applied per user and the user is unable to configure if their number is shown or not when making an outboud call
- Per user enabled
  The policy is applied per user and the user has the option to enable or disable their number from showing when making an outboud call
- Globally forced
  The policy is applied to all users by default that don't have another **per user** policy applied to them individually. The user is unable to configure if their number is shown or not when making an outboud call
- Globally enabled
  The policy is applied to all users by default that don't have another **per user** policy applied to them individually. The user has the option to enable or disable their number from showing when making an outboud call

The options can be set via the Teams interface or through PowerShell.

## Via the Teams Interface
1. Navigate to https://admin.teams.microsoft.com
1. Click **Voice**
1. Click **Caller ID policies

### To configure the Global Policy
- Click **Global (Org-wide default)**
- Set the values
  - **Override the caller ID policy** to
    - **On** = Users are able to turn the features on and off
    - **Off** = Users are unable to configure their own settings
  - **Replace the caller ID with**
    - **User's number** to set the outbound number to the users own number by default
    - **Anonymous** to set the users number to anonymous by default
- Click **Save**
    
    
 ### To configure the Per-User Policy
 After creating the policy below, you'll need to indivudally assign this to users
- Click **+ Add**
- Name the policy
- Set the values
  - **Override the caller ID policy** to
    - **On** = Users are able to turn the features on and off
    - **Off** = Users are unable to configure their own settings
  - **Replace the caller ID with**
    - **User's number** to set the outbound number to the users own number by default
    - **Anonymous** to set the users number to anonymous by default
- Click **Save**


## Via PowerShell
````PowerShell
# Per user forced
# The policy is applied per user and the user is unable to configure if their number is shown or not when making an outboud call
# Outbound number = anonymous
New-CsCallingLineIdentity -Identity "Anonymous Per-User Forced" -CallingIdSubstitute "Anonymous" -EnableUserOverride $false
# Outbound number = Users phone number
New-CsCallingLineIdentity -Identity "Anonymous Per-User Forced" -CallingIdSubstitute "LineUri" -EnableUserOverride $false

# Per user enabled
# The policy is applied per user and the user has the option to enable or disable their number from showing when making an outboud call
# Outbound number = anonymous
New-CsCallingLineIdentity -Identity "Anonymous Per-User User Selected" -CallingIdSubstitute "Anonymous" -EnableUserOverride $true
# Outbound number = Users phone number
New-CsCallingLineIdentity -Identity "Anonymous Per-User User Selected" -CallingIdSubstitute "LineUri" -EnableUserOverride $true

# Globally forced
# The policy is applied to all users by default that don't have another **per user** policy applied to them individually. The user is unable to configure if their number is shown or not when making an outboud call
# Outbound number = anonymous
Set-CsCallingLineIdentity -Identity Global -CallingIdSubstitute "Anonymous" -EnableUserOverride $false
# Outbound number = Users phone number
Set-CsCallingLineIdentity -Identity Global -CallingIdSubstitute "LineUri" -EnableUserOverride $false

# Globally enabled
#The policy is applied to all users by default that don't have another **per user** policy applied to them individually. The user has the option to enable or disable their number from showing when making an outboud call
# Outbound number = anonymous
Set-CsCallingLineIdentity -Identity Global -CallingIdSubstitute "Anonymous" -EnableUserOverride $true
# Outbound number = Users phone number
Set-CsCallingLineIdentity -Identity Global -CallingIdSubstitute "LineUri" -EnableUserOverride $true
````
