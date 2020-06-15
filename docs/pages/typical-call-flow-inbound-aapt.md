# Typical inbound call flow - Provider: AAPT
This is a typical call flow and outlines the important SIP messages

|Direction | Inbound |
| ---: | :--- |
|Carrier | AAPT|

> Because SBC Connect is connected to multiple providers, you'll need to select the inbound call flow relivant to your call flow.
More examples can be found: 🌐 [Here](typical-call-flows.md)

````mermaid
sequenceDiagram
    participant C as Customer <br> A-Party
    participant S as SBCconnect
    participant P as Upstream Provider <br> AAPT <br> B-Party
    Note over C,P: Typical Outbound Call <br> from A-Party to B-Party <br> Upstream Provider: AAPT
    C->>S: Invite
    S->>P: Invite
    S->>C: 100 Trying
    P->>S: 180 Ringing
    S->>C: 180 Ringing
    P->>S: 200 OK
    S->>C: 200 OK
    C->>S: ACK
    S->>P: ACK
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
