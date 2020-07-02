# Teams Client Issues - Local Desktop

## One-way audio on a call
1. Check the device settings on the:
   - Local computer; and
   - In the Microsoft Teams client.
1. Check from another device
   This will isolate the issues to being a platform issue or a Microsoft Teams client issue
1. Log a fault with the SBC Connect platform team

## Headset not muting or un-muting a call
1. Ensure any required software is installed onto the desktop PC
   - For Jabra headsets this should be the **Jabra Direct** software
1. Update the device firmware
   - For Jabra devices
     - Install the **Jabra Direct** software
       - If using the LINK USB adaptor or a USB cable, update the firmware from within the software
       - Is using a Bluetooth connection, connect the device by a USB cable before trying to update the firmware

## No dial pad
1. Check the user is Voice Enabled by:
   - Run the [PowerShell script to check user configuration issues](pages/check-user-configuration.md); OR
   - Check the the **Phone System** value is **On** for the user in the [Teams Admin Centre](https://admin.teams.microsoft.com)
1. Check the user has a valid **Voice routing policy** in the [Teams Admin Centre](https://admin.teams.microsoft.com) and that the selected **Voice routing policy** has valid **PSTN usage records** assigned to it
