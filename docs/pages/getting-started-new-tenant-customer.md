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
