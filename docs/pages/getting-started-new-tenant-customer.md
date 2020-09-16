# Getting started deploying SBC Connect to a new Microsoft 365 Tenant - Customer
> These are the deployment instructions for confiuring the Microsoft 365 tenant.
<br> For SBC Connect platform deployment instructions, please see [Here](getting-started-new-tenant-platform.md)

## Overview
This document outlines the process for deploying a new customer to the SBC Connect calling platform.

The high level steps are:
- Obtain the following settings from the SBC Connect platform team
  - Customer Domain Name (DNS)
  - Number range
  - Port number (non-Derived trunk only)
  - Trunk capacity (non-Derived trunk only)
  - Trunk type
    - Derived Trunk; OR
    - Non-Derived Trunk
- Add and Verify the DNS name in the Microsoft 365 tenant
  - [Add Domain Name to Tenant](pages/add-domain-name-to-tenant.md)
  - Add domains to https://admin.microsoft.com
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
  - Non-Derived Trunk
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
