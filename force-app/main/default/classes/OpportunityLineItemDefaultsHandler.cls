/**
    Name: OpportunityLineItemDefaultsHandler
    Author: Vertex Computer Systems Inc
    Date: 03/28/2017
    Description: If the Number of Months Picklist on an Opportunity Line Item, is set to default, this class populates the picklist
    with the number of Revenue Installments specified at the Product level.
**/

public class OpportunityLineItemDefaultsHandler {

    public static void handleInsertUpdate(){
        Id[] pbEntryIds = new Id[]{};
        OpportunityLineItem[] opLineItmsToUpdate = new OpportunityLineItem[]{};
        for(OpportunityLineItem item: (OpportunityLineItem[])Trigger.new){
            if(item.Number_Of_Months__c=='Default' || item.Number_of_Months__c==null){
                pbEntryIds.add(item.PricebookEntryId);
                opLineItmsToUpdate.add(item);
            }
        }
        if(opLineItmsToUpdate.size()>0){
            Map<Id,PriceBookEntry> pbEntryMap = new Map<Id,PriceBookEntry>([Select Product2.NumberOfRevenueInstallments from PricebookEntry where Id in :pbEntryIds]);
            for(OpportunityLineItem item: opLineItmsToUpdate){
                Decimal numOfInstallments = pbEntryMap.get(item.PriceBookEntryId).Product2.NumberOfRevenueInstallments;
                if(numOfInstallments==null)
                    item.Number_Of_Months__c='1';
                else
                    item.Number_Of_Months__c = String.valueOf(numOfInstallments);
                
            }
        }
    }
}