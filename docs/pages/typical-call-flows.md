#Typical Call Flows
There are 2 typical call flows - Inbound and Outbound.
The **Calling** party is called the **A-party**
The **Called** party is called the **B-party**

````mermaid
sequenceDiagram
    participant C as Customer <br> A-Party
    participant S as SBCconnect
    participant P as Upstream Provider <br> B-Party
    Note over C,P: Typical Outbound Call <br> from A-Party to B-Party
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
        C-->P: Check in loops
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
