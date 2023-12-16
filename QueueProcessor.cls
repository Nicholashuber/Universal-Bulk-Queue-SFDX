public class QueueProcessor implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Field1__c, Field2__c, Field3__c, Context__c, Status__c FROM Universal_Queue__c WHERE Status__c = 'New']);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Universal_Queue__c> queueItems = (List<Universal_Queue__c>)scope;

        for (Universal_Queue__c item : queueItems) {
            // Check if the record is already in progress or failed
            if (item.Status__c != 'Success' && item.Status__c != 'Failed') {
                // Update the status to 'In Progress' when picked up
                //item.Status__c = 'In Progress';
                //update item;

                // Your logic to process the queue item (update records, perform actions, etc.)
                try {
                    System.debug('Just starting going to call processQueueItem method');
                    processQueueItem(item);
                    // Update the status to 'Success' when processing is successful
                    item.Status__c = 'Success';
                } catch (Exception e) {
                    System.debug('Exception Caught!!!!' + e);
                    // Handle exceptions, including record locking issues
                    // Update the status to 'Failed' if retry attempts exceed the limit
                    if (isRecordLockedException(e) && retryWithBackoff(item)) {
                        System.debug('Status Failed after checks');
                        item.Status__c = 'Failed';
                    } else {
                        // Handle other exceptions
                        System.debug('Error processing queue item: ' + e.getMessage());
                    }
                }

                // Update the record with the final status
                update item;
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        // Reset the custom setting
        BatchJobStatus__c batchJobStatus = BatchJobStatus__c.getOrgDefaults();
        batchJobStatus.BatchJobStarted__c = false;
        update batchJobStatus;

        // Check if there are any new records to process
        Integer recordCount = [SELECT COUNT() FROM Universal_Queue__c WHERE Status__c = 'New'];

        // If there are new records, start the batch job again
        if (recordCount > 0) {
            QueueProcessor batchJob = new QueueProcessor();
            Database.executeBatch(batchJob);
            // Update the custom setting
            batchJobStatus.BatchJobStarted__c = true;
            update batchJobStatus;
        }
    }

    private void processQueueItem(Universal_Queue__c item) {
        System.debug('processQueueItem then BaseProcessHelper called');
        QueueProcessingService.processQueueItem(item.Field1__c, item.Field2__c, item.Field3__c, item.Context__c);
    }

    private Boolean retryWithBackoff(Universal_Queue__c item) {
        System.debug('retryWithBackoff called1');
        Integer maxAttempts = 3;
        Integer attempts = 0;
        Integer retryDelayMilliseconds = 1000; // Initial retry delay (1 second)

        System.debug('retryWithBackoff called');
        while (attempts < maxAttempts) {
            try {
                System.debug('About to try calling processQueueItem');
                processQueueItem(item);
                System.debug('After calling processQueueItem');
                // Update the status to 'Success' when processing is successful
                item.Status__c = 'Success';
                return true; // Successful processing, exit the retry loop
            } catch (Exception e) {
                attempts++;
                // Double the retry delay with each attempt
                retryDelayMilliseconds *= 2;

                // Log the retry attempt
                System.debug('Retrying after record locking issue (Attempt ' + attempts + ')');

                // Wait before retrying (simulate delay)
                simulateDelay(retryDelayMilliseconds);
            }
        }

        return false; // Retry attempts exceeded, update the status to 'Failed'
    }

    private void simulateDelay(Integer milliseconds) {
        System.debug('Simulating Delay');
        Long endTime = System.currentTimeMillis() + milliseconds;
        while (System.currentTimeMillis() < endTime) {
            // Consume CPU time to simulate a delay
        }
    }

    private Boolean isRecordLockedException(Exception e) {
        // Check if the exception is due to record locking
        System.debug('Error checking?');
        return e.getMessage() != null;
    }
}