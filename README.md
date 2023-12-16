# Salesforce Universal Queue

This project includes a Salesforce trigger and batch class that work together to process records from a custom object named `Universal_Queue__c`. The trigger starts a batch job whenever a new record is inserted into the `Universal_Queue__c` object. The batch job processes the records and updates their status. The `Universal_Queue__c` object is a staging object of sorts before any business logic takes place. This ensures we have a copy of the request to try again later.

## Components

1. **UniversalQueueTrigger:** This trigger fires after a record is inserted into the `Universal_Queue__c` object. It checks a custom setting named `BatchJobStatus__c` to see if a batch job is already running. If not, it starts a new batch job and sets a flag in the custom setting.

2. **QueueProcessor:** This is a batch class that processes records from the `Universal_Queue__c` object. In the `finish` method, it resets the flag in the `BatchJobStatus__c` custom setting and checks if there are any new records to process. If there are, it starts itself again.

3. **BatchJobStatus__c:** This is a list custom setting that tracks whether a batch job is currently running. It has a boolean field named `BatchJobStarted__c`. The trigger sets this field to `true` when it starts a batch job, and the batch class sets it to `false` when it finishes.

## How It Works

When a record is inserted into the `Universal_Queue__c` object, the `UniversalQueueTrigger` fires. It retrieves the `BatchJobStatus__c` custom setting and checks the `BatchJobStarted__c` field. If the field is `false` or null, the trigger starts a new `QueueProcessor` batch job and sets the `BatchJobStarted__c` field to `true`.

The `QueueProcessor` batch job processes the records from the `Universal_Queue__c` object. When it finishes, it retrieves the `BatchJobStatus__c` custom setting and sets the `BatchJobStarted__c` field to `false`. It then counts the number of new records in the `Universal_Queue__c` object. If there are any new records, it starts itself again and sets the `BatchJobStarted__c` field to `true`.

This ensures that only one `QueueProcessor` batch job is running at any given time, regardless of the number of transactions inserting records into the `Universal_Queue__c` object. It also ensures that all records are processed, even if they are inserted while a batch job is running.

## Note

