# Teams networking best practises

There are multiple things you can do to assist the operation of Microsoft Teams. Below is a check list to follow to:

1. Try to avoid proxy servers\
   While technically supported, Teams creates lots of traffic that proxy servers we're really designed for and this could introduce unstable results
1. If users use a VPN connection, make sure they have a split-tunnel connection\
   It's important that all Microsoft 365 traffic isn't sent over a VPN connection. By default, all Teams traffic is already encrypted, and a secondary encryption over a VPN could introduce additional delaies into calls, meetings and other real-time communications.
1. Allow the correct firewall ports for communication\
   By default, the required ports for Teams clients talking to Microsoft 365 services are
   - TCP 80
   - TCP 443
   - UDP 3478-3481\
   If your firewall requires exact IP ranges, then these can be found on the Microsoft website at: [Microsoft 365 URL's and IP address ranges](https://docs.microsoft.com/en-us/microsoft-365/enterprise/urls-and-ip-address-ranges?view=o365-worldwide)
1. Ensure users have the ability to make geographicaly local and external DNS lookups\
   Use the senario - There is a user on a VPN connection sitting in Australia and their VPN terminates in England. They make a DNS request to teams.microsoft.com from their computer and the DNS request is made over the VPN from England. The Microsoft 365 network will return IP addresses for services local to England, not Australia, and so requests to the Teams services will need to traverse the internet to get to England, instead of traversing a much shorter path to the Teams services in Australia.
1. Avoid network Hairpins\
   A typical senario would be a branch office location where their internet traverses a connection so all internet traffic exits the corporate network in a fixed location instead of sending all Microsoft 365 traffic direct to the internet from the branch office location. Note that DNS requests should also aim to be delivered locally as well, instead of from a central office DNS server.\
   Ideally all traffic to Microsoft 365 services should hit the physically cloests Point-Of-Presence (POP) to the users currnet location as possible.
1. Configure QoS (Quality of Service)
   Prioritise the Audio traffic over everything else, followed by video followed by the **best effort services** like Web, Email and File transfers.\
   By default, the port ranges and tagging of traffic is as follows. Default can be changed in the [Teams Admin Center](https://admin.teams.microsoft.com) under **Meetings** > **Metting Settings**
   - Audio | 50,000-50,019 TCP/UDP | DSCP Value = 46 | DSCP Class = Expedited Forwarding (EF)
   - Video | 50,020-50,039 TCP/UDP | DSCP Value = 34 | DSCP Class = Assured Forwarding (AF41)
   - Application/Screen Sharing | 50,040-50,059 TCP/UDP | DSCP Value = 18 | DSCP Class = Assured Forwarding (AF21)

   Imporant notes
   - The Teams client is configured to **NOT** insert QoS Markers and this must be enabled in the Teams Admin Center as above
   - Apple Macs will always hardcode audio as (EF) and video as (AF41) and it cannot be change.
   - If using Application Name QoS tagging via Group Policy, you must add Teams.exe as the name

## Testing your configuration
Refer to the [Testing your network configuration](testing-local-network-connection.md) page for more information