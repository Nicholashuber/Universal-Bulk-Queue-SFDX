public without sharing class InitQueueExample {


    public void createQueueItem() {

        Universal_Queue__c queueItem = new Universal_Queue__c();
        queueItem.Field1__c = 'Field Value 1';
        queueItem.Field2__c = 'Field Value 2';
        queueItem.Field3__c = 'Field Value 3';
        queueItem.Status__c = 'New';
        queueItem.Context__c = 'BaseProcessHelper';
        insert queueItem;

    }
}