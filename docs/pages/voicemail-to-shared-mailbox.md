# Re-direct Voicemail to a Shared Mailbox 

## Steps 
1. Log into the Microsoft Flow Portal 
   - https://flow.microsoft.com/ 
1. Click  **+ Create** > **Automated Flow** 
1. Select **+** Add 
1. Enter in a **Display name** and select the trigger **When a new email arrives to a group** 
   - *It is best to search for **Group** and select from there.* 
1. Click **Create**. 
1. Set the Call Group in the dropdown such as **CQ Name**. 
1. Create another step and select **Variable** > **Initialize Variable**. 
1. Set the Name to **tid** and the Type to **String** 
1. Create another step and select **Variable** > **Initialize Variable**. 
1. Set the Name to **id** and the Type to **String** 
1. Create another step and select **Office 365 Groups Mail** > **Get a conversation thread (Preview)**. 
1. Select the Call Group name from above.
1. Select **Conversation thread id** under *When a new email arrives to a group* in Thread ID. 
1. Click Add an action under this step. 
1. Select **Set variable**. 
1. Under Name, select **tid**. 
1. Under Value, select **Conversation thread id**. 
1. Add another action, and select **Get a thread post (Preview)** from Office 365 Groups Mail. 
1. Under Group ID, select the group used in the above steps. 
1. Under Thread ID, select **Conversation thread id** 
1. Under Post ID, select Post ID under *when a new email arrives to a group* 
1. Click Add an action under this step. 
