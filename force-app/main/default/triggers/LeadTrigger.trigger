trigger LeadTrigger on Lead (before insert, before update, after insert, after update){
  
     
    if(Trigger.isAfter){
        if(Trigger.isInsert ){           
            LeadHandler.UpdateCallCenterActivity(trigger.new);
        }
        
        
}
    
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LeadHandler.updateZipMaster(trigger.new);
            LeadHandler.updateTerritoryMaster(trigger.new);
            LeadHandler.updateExistingAccount(trigger.new); 
            LeadHandler.updateSICinfo(trigger.new);
            LeadHandler.CLHWebLeadMapping(trigger.new,true);
            LeadHandler.UpdateLeadOwnerSalesBranch(trigger.new);
        }
        if(Trigger.isUpdate){
            if(LeadHandler.isFirstTime){
        LeadHandler.isFirstTime = false;
            LeadHandler.updateZipMaster(trigger.new);
            LeadHandler.updateTerritoryMaster(trigger.new);
            LeadHandler.updateExistingAccount(trigger.new);
            LeadHandler.updateSICinfo(trigger.new);
            LeadHandler.CLHWebLeadMapping(trigger.new,false);
            LeadHandler.UpdateLeadOwnerSalesBranch(trigger.new);
        
        }
    }
    }
}