# Tracking down call quality issues
Call quality issues can come in many forms from jittery audio to complete loss of service.
There are several processes we can work through to check call quality and the configuration used during that call.

````mermaid
graph TD
	Start[fa:fa-user Single User Call Quality Issue] -->|Record Note: Inbound or Outbound call| audio{What audio issues were there?}
    audio -->|1-way Audio| hardware[fa:fa-headset Check the headset used from <br> the Teams Admin portal]
	audio -->|No Audio| media[fa:fa-wifi Was the correct WiFi or Ethernet connection <br> used on the call?]
	media --> latency{What was the latency on the<br>Inbound and Outbound legs? <br> Over: XX = Possible audio Issues <br> Under: XX = Call should be OK}
	latency -->|Latency issues on <br> Customers leg| checkCustomerSelection{Where was the issue}
	latency -->|Latency issues on <br> 3rd parties leg| check3rdPartiesSelection[Fault seems to be with the receiving party]
	latency -->|Latency OK on customers side <br> no latency listed on 3rd party| check3rdPartiesSelection
	checkCustomerSelection -->|On upload leg| checkCustomerUpload[Check customers upload <br> Speed test result?]
	checkCustomerSelection -->|On download leg| checkCustomerDownload[Check customers download speed <br> Is there anything unusal happening? <br> Speed test result?]
````
