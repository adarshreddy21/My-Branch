trigger TaskTrigger on Task (after insert, before insert, before update, after Update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert ){
            TaskCRUDHandler.InsertNewCallCenterCase(trigger.new, trigger.oldMap);
            TaskCRUDHandler.InsertNewCallCenterLead_ExistingAccount(trigger.new, trigger.oldMap);
            TaskCRUDHandler.InsertNewCallCenterOpportunity(trigger.new, trigger.oldMap);
            TaskCRUDHandler.InsertNewCallNote(trigger.new);
            TaskCRUDHandler.UpdateLatestSalesTaskDate(trigger.new,null);
            TaskCRUDHandler.InsertNewPartsWasherPullCase(trigger.new); 
        }
     
     	if(Trigger.isUpdate ){
         	TaskCRUDHandler.UpdateLatestSalesTaskDate(trigger.new,trigger.oldMap);
     	}     
    }
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate || Trigger.isInsert){
            
            TaskCRUDHandler.UpdateTaskType(trigger.new);
			TaskCRUDHandler.populateContactName(trigger.new) ; 
			TaskCRUDHandler.validateEvents(trigger.new); 
            
        }
        
    }
}