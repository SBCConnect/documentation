# Microsoft Teams Physical Device Management
> <i class="fas fa-clipboard"></i> NOTE: As at June 2020, there are no options to confiugre the Device Configuration Profiles by API or PowerShell.

There are a number of Microsoft Teams certified devices on the market from several different manufactures.\
These devices are listed on the Microsoft Teams Devices Page 🌐 [Here](https://www.microsoft.com/en-au/microsoft-365/microsoft-teams/across-devices)

Once a device is logged in and the user setup, the device is registered to the tenant and a policy applied against it from the *Configuration Profiles* listed in the *Microsoft Teams Admin Portal*.

These *Configuration Profiles* allow you to set options like the devices:
- Timeout and lock status
- Language
- Timezone
- Time format
- Screen saver
- Network settings; and
- To enable or disable the second PC port

If the Microsoft 365 tenant also has Intune setup, then the device is registered to Intune and any compliance policies are applied when the first user logs in.

Different Confiugration Profiles can be used to setup phones with common attributes 

## Device Configuration Management
- [Create a new device Configuration Profile](pages/new-deivce-configuration-profile.md)
- [Edit a device Configuration Profile](pages/edit-deivce-configuration-profile.md)
- [Assign a device Configuration Profile](pages/assign-deivce-configuration-profile.md)
- [Remove a device Configuration Profile](pages/remove-deivce-configuration-profile.md)

## Configuration Profile Settings
### Device Lock
- If you configure a Lock timeout with a PIN number from a Configuration Profile, then the device:
  - will lock at the time of the configured timeout period; and
  - will require a PIN number in order to make a call, check calendar items, etc; and
  - will allow the user to change the pre-configured pin number; and
  - will **NOT** allow the user to remove the pin lock requirement from the settings menu of the phone; and
  - will **NOT** require a PIN number in order to answer an incoming call.
  
## Microsoft Docs
[Manage your devices in Microsoft Teams](https://docs.microsoft.com/en-us/microsoftteams/devices/device-management)
