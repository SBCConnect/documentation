# Assign a device Configuration Profile
> <i class="fas fa-clipboard"></i> NOTE: There are a few important considerations to take into account when assigning a Confiugration Profile.\
Please read **[Notes on the process](#notes-on-the-process)** towards the bottom of the page for detailed steps

After [creating a device Configuration Profile](pages/new-deivce-configuration-profile.md), you're able to assign the profile to a device in order to configure the device using these settings.

1. Navigate to the Microsoft Teams Admin Portal
   - [https://admin.teams.microsoft.com](https://admin.teams.microsoft.com)
1. Click **Devices** > **Phones**
1. Select the **Confiugration Profiles** tab
1. Select the required *Configuration Profile*
1. Click **Asign to device**
1. Search for and select the device you want
1. Click **Apply**

## Notes on the process
- This assignment is a one time operation and further changes to the profile will not push through to devices
  - We think this is a bug and changes should auto-update, but in testing they don't
- You're able to re-assign the profile to the device in order for changes to the profile to apply to the device
