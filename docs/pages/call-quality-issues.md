# Tracking down call quality issues
Call quality issues can come in many forms from jittery audio to complete loss of service.
There are several processes we can work through to check call quality and the configuration used during that call.

````mermaid
graph TD
	Start[fa:fa-user Single User Call Quality Issue] -->|Record Note: Inbound or Outbound call| 2ndcall{Make a second call to another number <br> If issue on mobile, try a landline - etc <br> Does the issues still exist?}
	2ndcall -->|No| 2ndcallNo{Possibly the receiving party, <br> but you can try the Yes path if you want}
	2ndcall -->|Yes <br> Record Date & Time of call| audio{What audio issues were there?}
    audio -->|1-way Audio| hardware[Is the user using a Physical handset <br> or Teams PC application?]
	hardware -->|Physical| hardwarePhysical[Things to check <br> - Check the handset is plugged into the fa:fa-phone phone port<br> and not the headset port <br><br> - Is the phone firmware up-to-date? <br> Check Teams admin portal & start Upgrade]
	hardwarePhysical --> hardwareReplicateFault(Can you replicate the fault with a Teams Client? <br> Try the fault flow again using the Teams Client on a PC)
	hardware -->|Teams| softphone[fa:fa-headset Check the headset/device used from <br> the Teams Admin portal <br> Was it the expected one?]
	softphone --> softphonehardwareTestCall[Make a call to the Teams Voice Test Service <br> Is this working?]
	softphonehardwareTestCall -->|Record the Yes or No result| softphoneTestCallresultNo(Confirm no fault with the PC by trying another <br> If it conntinues, then log a fault with SBC Connect Platform team <br> They will enable call logging and will need to <br> capture 3 faulting calls)
    audio -->|No Audio| media[fa:fa-wifi Was the correct WiFi or Ethernet connection <br> used on the call?]
	media --> latency{What was the latency on the<br>Inbound and Outbound legs? <br> Over: 80 = Possible audio Issues <br> Under: 80 = Call should be OK}
	latency -->|Latency issues on <br> Customers leg| checkCustomerSelection{Where was the issue}
	latency -->|Latency issues on <br> 3rd parties leg| check3rdPartiesSelection[Fault seems to be with the receiving party]
	latency -->|Latency OK on customers side <br> no latency listed on 3rd party| check3rdPartiesSelection
	checkCustomerSelection -->|On upload leg| checkCustomerUpload[Check customers upload <br> Speed test result?]
	checkCustomerSelection -->|On download leg| checkCustomerDownload[Check customers download speed <br> Is there anything unusal happening? <br> Speed test result?]
````
