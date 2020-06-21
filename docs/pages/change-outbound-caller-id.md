# Change the caller ID (DID Number) on outbound calls
By default, the outbound caller ID will be displaied as the users DID assigned number. For the most part this is OK, however there are legitimate business use cases where the outbound caller ID should display the companies main number. In this case there are several options:
- [Modify the outbound caller ID for all users to display antoher number](#modify-the-outbound-caller-id-for-all-users-to-display-another-number); or
- [Modify an individual users caller ID to display another number](#modify-an-individual-users-caller-id-to-display-another-number); or
- [Set the outbound caller ID to anonymous](#set-the-outbound-caller-id-to-anonymous) (often refered to as private).

## Outbound number types
There are several outbound number types that you're able to assign to end users including:
- Microsoft Teams Service Numbers
  - These numbers are purchased and managed through the Microsoft Teams admin portal
- User Numbers
  - These numbers are purchased and managed on the SBC Connect platform

## Modify the outbound caller ID for all users to display another number
Depending on the type of number, this scenario requires configuration on either the Microsoft 365 tenant or the SBC Connect platform.
- Service Number
  - Create a **Caller ID Policy** through the Microsoft Teams Admin Center
    https://admin.teams.microsoft.com > Select **Voice** > **Caller ID Policies**
  - Assign the policy to a user
    https://admin.teams.microsoft.com > Select **Users** > **Policies** > **Caller ID policy**
- User Number
  - Replacing any outbound caller ID with a **User Number** hosted on the SBC Connect platform must be provisioned on the SBC platform it's self.
    Please log a ticket with the platform team with the following information
    - Phone number (or range) you're trying to change
    - Phone number that you want displayed

## Modify an individual users caller ID to display another number
- Service Number
  - Create a **Caller ID Policy** through the Microsoft Teams Admin Center
    https://admin.teams.microsoft.com > Select **Voice** > **Caller ID Policies**
  - Assign the policy to a user
    https://admin.teams.microsoft.com > Select **Users** > **Policies** > **Caller ID policy**
- User Number
  - Replacing any outbound caller ID with a **User Number** hosted on the SBC Connect platform must be provisioned on the SBC platform it's self.
    Please log a ticket with the platform team with the following information
    - Phone number (or range) you're trying to change
    - Phone number that you want displayed

## Set the outbound caller ID to anonymous
This can be completed within the Microsfot Teams platform it's self
  - Create a **Caller ID Policy** through the Microsoft Teams Admin Center
    https://admin.teams.microsoft.com > Select **Voice** > **Caller ID Policies**
  - Assign the policy to a user
    https://admin.teams.microsoft.com > Select **Users** > **Policies** > **Caller ID policy**
