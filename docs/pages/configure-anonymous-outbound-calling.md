# Configure outbound anonymous calling policies
Outbound anonymous calling can be configured in multiple ways

- **Anonymous Per-User Forced**
  - This policy can be provisioned per user and set's their outbound number to Anonymous/Private. As a result, the user is unable to configure if their number is shown or not when making an outboud call
- **Anonymous Per-User User Selected**
  - This policy can be provisioned per user and allows the user to choose to set their outbound number to Anonymous/Private. The user is able to change this setting under **Settings** > **Calls** within their Microsoft Teams client.
- **Anonymous Globally forced**
  - This policy is applied to all users by default that don't have another **per user** policy applied to them individually. When applicable to a user, the user is unable to configure if their number is shown or not when making an outboud call
- **Anonymous Globally User Selected**
  - This policy is applied to all users by default that don't have another **per user** policy applied to them individually. When applicable to a user, this policy allows the user to choose to set their outbound number to Anonymous/Private. The user is able to change this setting under **Settings** > **Calls** within their Microsoft Teams client.

The options can be set via the Teams interface or through PowerShell.

## Via the Teams Interface
1. Navigate to https://admin.teams.microsoft.com
1. Click **Voice**
1. Click **Caller ID policies**

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
### Per-User Policies
It's safe to deploy this script to the tenant as a whole. This will allow selection and application of the policies against the users individual profiles within the Teams Admin Centre
````PowerShell
### Per user forced
# These policies set the options for the user, and restricts the user from changing the options
# Outbound number = anonymous
New-CsCallingLineIdentity -Identity "Anonymous Per-User Forced" -CallingIdSubstitute "Anonymous" -EnableUserOverride $false -Description "This policy can be provisioned per user and set's their outbound number to Anonymous/Private. As a result, the user is unable to configure if their number is shown or not when making an outboud call"
# Outbound number = Users phone number
New-CsCallingLineIdentity -Identity "Users Number Per-User Forced" -CallingIdSubstitute "LineUri" -EnableUserOverride $false -Description "This policy can be provisioned per user and set's their outbound number to their assigned PSTN dialing number. As a result, the user is unable to configure their outbound calling number within the Microsoft Teams client"

### Per user enabled
# These policies set the default options for the user, but allows the user to change options
# Outbound number = anonymous
New-CsCallingLineIdentity -Identity "Anonymous Per-User User Selected" -CallingIdSubstitute "Anonymous" -EnableUserOverride $true -Description "This policy can be provisioned per user and allows the user to choose to set their outbound number to Anonymous/Private. The user is able to change this setting under Settings > Calls within their Microsoft Teams client."
# Outbound number = Users phone number
New-CsCallingLineIdentity -Identity "Users Number Per-User User Selected" -CallingIdSubstitute "LineUri" -EnableUserOverride $true -Description "This policy can be provisioned per user and defaults their outbound number to their assigned PSTN dialing number. Where applicable within the tenant, the user may be able to select an alternate number as well."
````

### Global Policies
These policies apply as a default to all users that don't have a policy manually applied to them via the Teams Admin centre
> ⚠ Only 1 global policy can apply at once. Running subsiquent policies from below will result in the last one to be run as being the default.


**Globally forced**\
  The policy is applied to all users by default that don't have another per user policy applied to them individually. The user is unable to configure if their number is shown or not when making an outboud call
- Outbound number = anonymous
````PowerShell
Set-CsCallingLineIdentity -Identity Global -CallingIdSubstitute "Anonymous" -EnableUserOverride $false -Description "Users outbound caller ID is Anonmymous by default with no abilty for the user to change this setting. Applies unless a per-user policy is also applied to the user"
````
- Outbound number = Users phone number
````PowerShell
Set-CsCallingLineIdentity -Identity Global -CallingIdSubstitute "LineUri" -EnableUserOverride $false -Description "Users outbound caller ID is their assigned PSTN number by default with no abilty for the user to change this setting. Applies unless a per-user policy is also applied to the user"
````

**Globally enabled**\
  The policy is applied to all users by default that don't have another per user policy applied to them individually. The user has the option to enable or disable their number from showing when making an outboud call
- Outbound number = anonymous
````PowerShell
Set-CsCallingLineIdentity -Identity Global -CallingIdSubstitute "Anonymous" -EnableUserOverride $true -Description "Users outbound caller ID can be changed by the user between showing their number and Anonymous/Private using the Settings > Calling options within their Microsoft Teams client. Applies unless a per-user policy is also applied to the user"
````
- Outbound number = Users phone number
````PowerShell
Set-CsCallingLineIdentity -Identity Global -CallingIdSubstitute "LineUri" -EnableUserOverride $true -Description "Users outbound caller ID is set to their assigned PSTN number by default. Applies unless a per-user policy is also applied to the user"
````
