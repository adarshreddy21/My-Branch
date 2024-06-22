/**
* @description       : 
* @author            : Raghav
* @group             : 
* @last modified on  : 
* @last modified by  :  
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   01-10-2024   Raghav   Initial Version 
**/  
public class FinancialHandler { 
    private static OwnershipChangeRequestHandler ownershiptriggerreq = new OwnershipChangeRequestHandler();
    public void updateOCRQuarterFlipEligibility(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Set<Id> accountIds=new Set<Id>();
        for(Financials__c financial: (List<Financials__c>)newItems.values()){
            accountIds.Add(financial.Account__c);
        }
        List<Ownership_Change_Request__c> ownershipChangeRequests=[Select Id, Account__c, EligibileForIntraQuarterFlip__c from Ownership_Change_Request__c where Account__c in :accountIds and  Status__c in ('Draft','Submitted')];
        if(!ownershipChangeRequests.isEmpty()){
            ownershiptriggerreq.updateOCRQuarterFlipEligibility(ownershipChangeRequests);
            update ownershipChangeRequests;
        }  
    }
}