public without sharing class QueueProcessingService {
    public static void processQueueItem(String field1, String field2, String field3, String context) {
        // Call the helper class methods
        if(context == 'BaseProcessHelper'){
            BaseProcessHelper.process(field1, field2, field3);
        }
        //if(context == 'EmailProcessHelper'){
            //EmailProcessHelper.process(field1, field2, field3);
        //}
        //if(context == 'RecordLockedProcessHelper'){
            //RecordLockedProcessHelper.process(field1, field2, field3);
        //}
        //if(context == 'DataSyncProcessHelper'){
            //DataSyncProcessHelper.process(field1, field2, field3);
        //}
    }
}