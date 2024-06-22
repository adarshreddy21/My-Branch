trigger OwnershipChangeRequestTrigger on Ownership_Change_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new OwnershipChangeRequestTriggerHandler());
}  