# Getting started deploying SBC Connect to a new Microsoft 365 Tenant - Customer

## Overview
This document outlines the process for deploying a new customer to the SBC Connect calling platform.

The high level steps are:
- Obtain the following settings from the SBC Connect platform team
  - Customer Domain Name (DNS)
  - Any new PSTN number ranges
  - Trunk type
    - Derived Trunk; OR
    - Non-Derived Trunk
  - Port number (non-Derived trunk only)
  - Trunk capacity (non-Derived trunk only)
- Add and Verify the DNS name in the Microsoft 365 tenant
  - [Add Domain Name to Tenant](add-domain-name-to-tenant.md)
  - Verification codes need to get entered by the SBC Connect platform team to the DNS
  - Use TXT record
  - Add your own DNS records
  - Untick Exchange and Exchange Online Protection
- Add a new user with a license for teams to the tenant with the primary UPN domain being the new domain.
  - One user for each domain
  - Name the user Delete1 and Delete2, these only need to be active for 30 mins then can be removed after the SBC's are added
- Make sure the users are licensed for Teams
- Make sure that the M365 tenant had Skype for Business Online DNS records active
- Setup Holidays
- Run the required base PowerShell configuration based on the type of trunk deployed
  - Derived Trunk; OR
  - [Non-Derived Trunk - New SBC](new-sbc-deployment-to-tenant.md)
- Complete user deployment configuration
  - Assign licenses
  - Assign DID
  - Voice Enable User
  - Enable Hosted Voice mailbox

Base (**THIS IS JUST A NOTE**)
- Dial Plans
- Gateway (non-Derived only)
- Normalization

## Requirements
