# Testing your network configuration

## Online connectivity test to Microsoft 365 services
Testing your internet and connectivity to the Microsoft 365 services can be done using the [Office 365 Network Onboarding Tool](https://connectivity.office.com)\
Note that you're able to enter in your email domain and during the test, you'll be prompted to download and run a file so the conectivity test can perform additional advance tests.\
This entire test should take around 5 minutes

## Skype for Business - Network Assesment Tool
This tool runs on Windows PowerShell and is designed to run several test & dummy calls in the background while you're working and doing other tasks on your computer and network. Other tools generally only test point in time network connectivity and you'll often pause everything while the test runs, where as this tool will run in the background while someone is playing online games on their XBOX and another is streaming a Netflix show in the background.\
The test will return metrics like:
- Your current connectivity performace between the test device and the office 365 edge servers; and
- If the required ports and protocols are open on your firewall

While this is a **Skype for Business** tool, the same metrics and tests still apply for the Microsoft Teams calling platform

After running the tool, you can then pass the results into the **Results Analyzer Tool** that will give you a pass or fail result on the initial test results

**Download the tool from**
[Skype for Business Network Assessment Tool](https://www.microsoft.com/en-us/download/details.aspx?id=53885)


## Testing your QoS Configuration
You can confirm that the Teams client is inserting the QoS markers for real-time media traffic by downloading and running the [Microsoft Network Monitor Tool](https://www.microsoft.com/en-us/download/details.aspx?id=4865)\
An example configuration of this tool is:\
**Display Filter** = Source == "192.168.137.201" AND IPv4.DifferentiatedServiceField == 0xb8

Under the **Frame Details** you see the packet is tagged **Ipv4** > **DifferentiatedServiceField** > **DSCP** will have a codepoint 46 on audio frames


## Test the number of hops between the user and the Microsoft Network
From a command prompt or powershell window, run a **tracert teams.microsoft.com** to display the number of hops between the user and the Microsoft 365 services.\
This should be less than or around a maximum of 5 hops