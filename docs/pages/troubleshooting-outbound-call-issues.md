# Troubleshooting Outbound Call Issues

## "No Routes Found" is spoken when making a call
This means that the platform wasn't able to find a route for your call and/or the number is malformed.
If you've checked the number and it's correct, try to include an area code and then the country code.
Possible issues are
- Dial Plan not assigned to the user in the [Teams Admin Center](https://admin.teams.microsoft.com)
- The device or Teams client, hasn't yet received the Dial Plan information
  - Ensure that the Teams Client is up to date; or
  - Ensure that the device has the most recent software under the [Teams Admin Center - Device Management page](https://admin.teams.microsoft.com/devices/ipphones)
- Check the users configuration from PowerShell - [Check a single user's account for provisioning issues](pages/check-user-configuration.md)
- There is a platform configuration issue for the customer - See SBC Connect support team


## The number is automatically changed into an invalid format after clicking call
This means that the platform wasn't able to find a route for your call and/or the number is malformed.
If you've checked the number and it's correct, try to include an area code and then the country code.
Possible issues are
- Dial Plan not assigned to the user in the [Teams Admin Center](https://admin.teams.microsoft.com)
- The device or Teams client, hasn't yet received the Dial Plan information
  - Ensure that the Teams Client is up to date; or
  - Ensure that the device has the most recent software under the [Teams Admin Center - Device Management page](https://admin.teams.microsoft.com/devices/ipphones)
- Check the users configuration from PowerShell - [Check a single user's account for provisioning issues](pages/check-user-configuration.md)
- There is a platform configuration issue for the customer - See SBC Connect support team
