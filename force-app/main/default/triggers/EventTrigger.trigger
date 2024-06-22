trigger EventTrigger on Event (before insert, before update, after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert ){
            EventCRUDHandler.InsertNewCallNote(trigger.new);
            EventCRUDHandler.UpdateLatestSalesEventDate(trigger.new,null);  
        }
        
        if(Trigger.isUpdate){
            EventCRUDHandler.UpdateLatestSalesEventDate(trigger.new,trigger.oldMap);  
        }
    }
	    if(Trigger.isBefore){
        if(Trigger.IsInsert || Trigger.IsUpdate){
            EventCRUDHandler.PopulateContactName(trigger.new);
            EventCRUDHandler.validateEvents(trigger.new);
        }
    }
}