# Adding required domain names to the Microsoft 365 tenant
Each SBC Connect customer requires 1 or more domain names added into the customers Microsoft 365 tenant.

These domains will be provided by the SBC Connect platform team as needed.\
For the:
- Derived trunk model - 1 domain
- Non-Derived trunk model - multiple domains

## Steps
1. Log into the Microsoft Admin Portal
   - https://admin.microsoft.com/
1. Navigate to **Settings** > **Domains**
   - You may need to select **Show All** in order to see the correct menu options
1. Select **+ Add Domain**
1. Enter in the first domain as supplied by the SBC Connect team and click **Use this domain**
1. Select **Add your own records** for the verification option and click **Continue**
   This is selected by default
1. If verification is required, you'll receive a TXT= value record to add into DNS. Please pass this onto the SBC Connect team

## After Verification from the SBC Connect Platform Team
After the SBC Connect platform team has added in the **TXT=** record value
1. Navigate back to the domain in the Microsoft Admin Portal
1. Complete verification of the domain
1. On the **Add DNS Records** page, untick all records as no Exchange, Teams, etc records are required
1. The domain should complete adding without issues and have a status of *Healthy*
