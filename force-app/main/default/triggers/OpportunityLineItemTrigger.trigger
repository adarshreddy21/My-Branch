trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after insert, after update, before delete) {
    Trigger_Process__c tp_lobcs = Trigger_Process__c.getInstance('LOB Cross Sell');
    Trigger_Process__c tp_rs = Trigger_Process__c.getInstance('Revenue Schedule');
    Boolean canProcess_lobcs = tp_lobcs.canProcess__c;
    Boolean canProcess_rs = tp_rs.canProcess__c;
     List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    
   
    if(trigger.isBefore){
        if(trigger.isInsert){
           if(canProcess_lobcs) OpportunityLineItemHandler.updateLOBCrossSell(trigger.new);
           if(canProcess_rs) OpportunityLineItemDefaultsHandler.handleInsertUpdate();
           for(OpportunityLineItem oli:Trigger.new) {  
             // Added on 05/25/2017 - Added the logic below to handle the clone issue. Setting the prices to zeroes for the clone records
             //                       to avoid doubling the amount. Also storing the original record id and the flag for tracking purposes.            
             if(oli.isClone())  {               
                System.Debug('setting clone flag' +oli);
                oli.isClone__c = true;
                oli.CloneSourceId__c = oli.getCloneSourceId();                
                if(!Test.isRunningTest()) oli.UnitPrice = 0;                                                  
             }  
                       
           }

        }
         if(trigger.isUpdate){
            if(canProcess_lobcs) OpportunityLineItemHandler.updateLOBCrossSell(trigger.new);
            if(canProcess_rs) OpportunityLineItemDefaultsHandler.handleInsertUpdate();        
           }
		   
		  if(Trigger.isDelete){
        	OpportunityLineItemHandler.PreventOpportunityProductDeletion(Trigger.old); 
        }
    }
          
    if(trigger.isAfter  && CheckRecursive.check() && canProcess_rs){        
          
       OpportunityLineItemScheduleHandler.handleInsertUpdate(Trigger.new,false);      
    }
      

}