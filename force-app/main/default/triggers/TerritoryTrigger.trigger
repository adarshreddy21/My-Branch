trigger TerritoryTrigger on Territory__c (after update) {

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            
            TerritoryTriggerHandler.updateAccountOwner(Trigger.new, Trigger.oldMap);
        }
    }
}