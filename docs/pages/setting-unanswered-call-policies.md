# Changing a Calling Policy in Microsoft Teams.

## Change policy settings
````PowerShell
#Check policy name
Get-CsTeamsCallingPolicy

#Change the policy
Set-CsTeamsCallingPolicy -Identity "{POLICY NAME}" -BusyOnBusyEnabledType unanswered

#Check 1 policy
Get-CsTeamsCallingPolicy -Identity "{POLICY NAME}"
````
## Assign policy to users

1. Log into the **Microsoft Teams Admin Portal**.
   - https://admin.teams.microsoft.com/
1. Go to **Users** > ***{selected user}***.
1. Go to **Policies** and click **Edit**.
1. Under **Calling policy**, select the policy required.
1. Click **Apply**
