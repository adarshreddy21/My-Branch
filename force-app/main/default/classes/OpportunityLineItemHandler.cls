public class OpportunityLineItemHandler {
    
    Public static void updateLOBCrossSell (List<OpportunityLineItem> newOpportunityLineItemList ){
        List<String> prodIds = new List<String>();
        List<id> oppIds = new List<id>();
        List<Id> accIds = new List<Id>();
        for(OpportunityLineItem oppLiTm : newOpportunityLineItemList){
            prodIds.add(oppLiTm.Product_Name__c);
            oppIds.add(oppLiTm.opportunityId);
        }
        Map<Id,Date> oppCloseDateMap = new Map<id,Date>();
        Map<id,opportunity> oppList = new Map<id,opportunity>([select id,accountId,closedate,Financial_Reference_Date__c,Job_Start_Date__c from opportunity where id in: oppIds]);
        for(Opportunity opp:oppList.values()){
            accIds.add(opp.AccountId);
            
            Integer yy = opp.Financial_Reference_Date__c.year();
            Date dt = Date.newInstance(yy-1, 1, 1);  
            oppCloseDateMap.put(opp.id,dt);
        }
        
        Map<Id,Account> acctFianancialsList = new Map<Id,Account>([
            Select Id,
            (select Account__c,Month__c, Line_of_business__c 
             from Budgets__r 
             where Type__c = 'Revenue') 
            from Account where Id in :accIds
        ]);
        system.debug('acctFianancialsList--->'+acctFianancialsList.size()+'::::'+acctFianancialsList);
        
        for(OpportunityLineItem oppLiTm : newOpportunityLineItemList){
            system.debug('oppLiTm--->'+oppLiTm.id+'::::'+oppLiTm);
            Boolean prodFlag = true;
            Boolean accFlag = true;
            
            for(Financials__c fin: acctFianancialsList.get(oppList.get(oppLiTm.opportunityId).AccountId).Budgets__r){
                system.debug('fin--->'+fin.id+'::::'+fin);
                if(fin.Month__c >= oppCloseDateMap.get(oppLiTm.opportunityId) && fin.month__c < oppList.get(oppLiTm.opportunityId).Financial_Reference_Date__c){
                    if(oppLiTm.Product_Name__c == fin.Line_of_business__c){
                        prodFlag = false;
                        if(accFlag==false)
                            break;
                    }
                    
                    if(oppList.get(oppLiTm.OpportunityId).accountId == fin.Account__c){
                        accFlag = false;
                        if(prodFlag==false)
                            break;
                    }
                }
            }
            
            if(prodFlag){
                oppLiTm.No_LOB_Revenue_in_12_Months__c = true;
            }
            
            else { 
                oppLiTm.No_LOB_Revenue_in_12_Months__c = false;
            } 
            
            if(accFlag){
                oppLiTm.No_Account_Revenue_in_12_Months__c = true;
            }
            
            else {
                oppLiTm.No_Account_Revenue_in_12_Months__c = false;
            }           
        }
    }
	
	public static void PreventOpportunityProductDeletion(List<OpportunityLineItem> newOpportunityLineItems) {
        List<Product2> partsCleanerProductLst = [
            SELECT Id
            FROM Product2
            WHERE Name = 'Parts Cleaners' limit 1
        ]; 
        
        if(!partsCleanerProductLst.isEmpty()){
            for (OpportunityLineItem oli : newOpportunityLineItems) {
                if(oli.Product2Id == partsCleanerProductLst[0].Id ){
                    oli.addError(Label.Prevent_Opportunity_Product_Deletion_Message);
                }
            }
        }
    }
}