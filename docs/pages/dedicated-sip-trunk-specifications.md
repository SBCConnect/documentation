# SBC Connect platform dedicated SIP Trunk Specifications

## Compatibility
The SIP trunk has been tested with the following platforms:
- 3CX V16.0.7.1078 (JAN 2021)

## Number Formats - Inbound
The platform accepts inbound numbers in the following formats
- +E.164 (IE: +61258585858)
- E.164 / CC-NDC-SN (IE: 61258585858)
- 0NSN / 0-NDC-S (IE: 0258585858)
- 001161258585858

## Number Formats - Outbound
The platform will provide calls to subscribers in 0NSN format by default
IE: 0258585858

## Emergency Calling
The emergency services calling number in Australia is 000 (Tripple Zero).\
The platform will accept calls to this service in the following formats:
- 000
- +61000
- 61000
- 001161000

## Authentication
The SBC Connect platform uses IP based authentication.\
All customers should provide the IP address (or range) that will connect to the platform to our platform team

## Codecs
The platform presents codecs in the following format and order
- G711-DEFAULT 
- SILK8_20ms

## SBC Connect SBC IP's
Where possible, resolve the FQDN instead of IP address
- Sydney = 01.sydney.au.sbcconnect.com.au = 202.59.45.120
- Melbourne = 01.melbourne.au.sbcconnect.com.au = 203.209.207.246
