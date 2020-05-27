# Microsoft Teams Voice Mailboxes

## User Voice Mailboxes


## Common Voice mailboxes
Common Voicemails are refered to as a voice emailbox that isn't attached to a user.
For example a company might need a common voice mailbox for the geenral receipt of voicemails as an overflow option during the day and for
capturing calls after hours. This could be one common voice mailbox.

Calls can be transfered to a common voice mailboxes from within an Auto Attendant. Transfers from a Call Queue are not possible.

## Setup a common voice mailbox
- Create an Office 365 Group
  - This group can be the same as a group used for call queue members
- Add members to the group that you wish to have access to the voicemails
- In an Auto Attendant, Select **Redirect to** > **Voice Mail** then select the Office 365 group
