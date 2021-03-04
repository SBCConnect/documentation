# Getting started deploying SBC Connect to a new Microsoft 365 Tenant - Customer

## Overview
This document outlines the process for deploying a new customer to the SBC Connect calling platform.

The high level steps are:
- Obtain the following settings from the SBC Connect platform team
  - Customer Domain Name (DNS)
  - Assigned PSTN number ranges
  - Trunk type
    - Derived Trunk; OR
    - Non-Derived Trunk
  - Port number (non-Derived trunk only)
  - Trunk capacity (non-Derived trunk only)
- Add and Verify the DNS name in the Microsoft 365 tenant
  - [Add Domain Name to Tenant](add-domain-name-to-tenant.md)
  - Use TXT record verification
  - Verification codes need to get entered by the SBC Connect platform team to the DNS
  - Select add your own DNS records
  - Untick Exchange and Exchange Online Protection
- Activate the domain name for the tenant
  - Add a new user to the tenant with the primary UPN domain being the new domain
  - Assign the user a license that includes Microsoft Teams (Basically any license)
  - Repeat the process and create one user for each domain
  - Name the user Delete1 and Delete2, these only need to be active for 10 mins then can be deleted after the SBC's are added
- Obtain any required additional licenses for the end users
  - Including
    - **Microsoft Phone System**; or
    - **Microsoft 365 Business Voice (without calling plan)**
- Obtain required **Microsoft 365 Phone System - Virtual User** licenses\
  These are free and you can request a minimum of 25 per tenancy
- Make sure the general users are licensed for Teams
- Setup Holidays (if requested)
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
