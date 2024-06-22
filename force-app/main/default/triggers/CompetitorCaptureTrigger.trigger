trigger CompetitorCaptureTrigger on Competitor_Capture__c (before insert, before update) {
	
    //Before trigger context
    if(Trigger.isBefore){
        
        //Insert trigger context
        if(Trigger.isInsert){
            
            
            CompetitorCaptureCRUDHandler.updateCreatedOwnerAlias(Trigger.New);
        }
        
        //Update trigger context
        if(Trigger.isUpdate){
            
        }
    }
}