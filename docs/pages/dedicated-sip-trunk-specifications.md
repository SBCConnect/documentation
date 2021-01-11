# SBC Connect platform dedicated SIP Trunk Specifications

## Compatibility
The SIP trunk has been tested with the following platforms:
- 3CX V16.0.7.1078 (JAN 2021)

## Number Formats - Inbound
The platform accepts inbound numbers in the following formats
- +E.164 (IE: +61258585858)
- E.164 / CC-NDC-SN (IE: 61258585858)
- FNN / 0-NDC-S (IE: 0258585858)
- 0NSN (IE: 001161258585858)

## Number Formats - Outbound
The platform will provide calls to subscribers in full +E.164 format
IE: +61258585858

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
