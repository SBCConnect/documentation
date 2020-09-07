# Explanation of Voice Routing Policies

Voice Routing Policies (VRP) are what tells Microsoft Teams who that user is allowed to call.\
For example, if John is assigned an **International** VRP and Kate is assigned a **National** VRP, then Kate would be unable to call any international numbers.

VRP's have been designed to be additive in nature, so a VRP with a higher cost call type will contain all call types below it.\
Each VRP contains one or more of the following call types

> Custom VRP's can be created as required. Please reach out to the SBC Connect team for more information.

## Call Types
|     Call Type    |                         Description                         |                                            Notes                                           |
|------------------|-------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| AU-National      | - All Australian landline numbers<br>- Emergency Calls      |                                                                                            |
| AU-Mobile        | - All Australian mobiles                                    |                                                                                            |
| AU-International | - All international numbers outside of the +61 country code |                                                                                            |
| AU-1300          | - Calls to 1300 xxx xxx numbers                             |                                                                                            |
| AU-Service       | - Calls to numbers like the time and weather services       | CAUTION: These calls can be very expensive and are not recommended to be assigned to users |
| AU-Premium       | - Calls to 19xxxxxx numbers                                 | CAUTION: These calls can be very expensive and are not recommended to be assigned to users |

## Voice Routing Policy Vs Call Type Matrix
|      Voice Routing Policy     |                                       Call Types Included                                       |                    Notes                    |
|-------------------------------|-------------------------------------------------------------------------------------------------|---------------------------------------------|
| AU-National                   | - AU-National<br>- AU-Mobile                                                                    |                                             |
| AU-National-1300              | - AU-National<br>- AU-Mobile<br>- AU-1300                                                       |                                             |
| AU-National-1300-Premium      | - AU-National<br>- AU-Mobile<br>- AU-1300<br>- AU-Service<br>- AU-Premium                       | CAUTION: Includes Premium and Service Calls |
| AU-International              | - AU-National<br>- AU-Mobile<br>- AU-International                                              |                                             |
| AU-International-1300         | - AU-National<br>- AU-Mobile<br>- AU-1300<br>- AU-International                                 |                                             |
| AU-International-1300-Premium | - AU-National<br>- AU-Mobile<br>- AU-1300<br>- AU-Service<br>- AU-Premium<br>- AU-International | CAUTION: Includes Premium and Service Calls |
