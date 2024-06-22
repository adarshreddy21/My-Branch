trigger OpportunityTrigger on Opportunity (before insert, before update, after update, after insert) { 
Trigger_Process__c tp_rs = Trigger_Process__c.getInstance('Revenue Schedule');
Boolean canProcess = tp_rs.canProcess__c;
    if(Trigger.isUpdate){
        if((Trigger.isAfter && canProcess) || test.isRunningTest()){
            OpportunityTriggerHandler.handleUpdate();
            
        }
        if(Trigger.isAfter)
        { 
                //OpportunityTriggerHandler.FSTSBigOpportunityEmail(trigger.new,trigger.oldMap);
            	OpportunityTriggerHandler.UpdateAccountOppRank(trigger.new, trigger.oldMap);
    }
      }
     if(Trigger.isBefore){
            if(Trigger.isInsert ){  
              /*  for(opportunity o : trigger.new){
                    if(o.SK_Cross_Sell__c){
                        o.addError('Cannot check');
                    }
                }*/
                 //OpportunityTriggerHandler.InsertNewTPMCase(trigger.new,trigger.oldMap);
            }
            
            if(Trigger.isUpdate ){  
             if(checkRecursive_OpportunityTrigger.check()){ 
                 //OpportunityTriggerHandler.InsertNewTPMCase(trigger.new,trigger.oldMap);
                //OpportunityTriggerHandler.SKCrossSell(trigger.new,trigger.oldMap);
               // OpportunityTriggerHandler.updatePreviousOwner(trigger.new, trigger.oldMap);
            }
            
        }
        }
    
      if(Trigger.isAfter){
        if(Trigger.isInsert ){           
            OpportunityTriggerHandler.UpdateCallCenterActivity(trigger.new);
        }
}
    
}