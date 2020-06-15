# Typical inbound call flow - Provider: Access 4
This is a typical call flow and outlines the important SIP messages

|Direction | Inbound |
| ---: | :--- |
|Carrier | Access 4|

> Because SBC Connect is connected to multiple providers, you'll need to select the inbound call flow relivant to your call flow.
More examples can be found: 🌐 [Here](typical-call-flows.md)

### Notes on Access 4
Because the Access 4 SIP trunk is internet authenticated, then there is an additional *401 Unauthorized* in the SIP ladder that isn't nromally present in other providers, for example AAPT. This is normal and a second INVITE is used to authenticate the call.

````mermaid
sequenceDiagram
    participant C as Customer <br> A-Party
    participant S as SBCconnect
    participant P as Upstream Provider <br> Access 4 <br> B-Party
    Note over C,P: Typical Outbound Call <br> from A-Party to B-Party <br> Upstream Provider: Access 4
    C->>S: Invite
    S->>C: 100 Trying
    S->>P: Invite
    P->>S: 100 Trying
    P->>S: 401 Unauthorized
    S->>P: ACK
    S->>P: Invite
    P->>S: 100 Trying
    P->>S: 200 OK
    S->>C: 200 OK
    S->>P: ACK
    C->>S: ACK
    C-->P: Media Flow
    loop During the call
        C->P: 183 Session Progress (both ways)
    end
    alt A-Party Disconnects Call
        C->>S: BYE
        S->>P: BYE
        P->>S: 200 OK
        S->>C: 200 OK
    else B-Party Disconnects Call
        P->>S: BYE
        S->>C: BYE
        C->>S: 200 OK
        S->>P: 200 OK
    end
````
