public class DeleteSchedulesAndEditPrice {
	@AuraEnabled
    public static OpportunityLineItemDetailsWrapper getOppLineItemDetails(Id oppLineRecId){
        System.debug('recordId## ' +  oppLineRecId);
        List<OpportunityLineItem> oppLineItemRst = [
            SELECT Id, UnitPrice 
            FROM OpportunityLineItem 
            WHERE Id = :oppLineRecId
        ]; 
        
        List<OpportunityLineItemSchedule> oppLineItemSch = [
        	SELECT Id
            FROM OpportunityLineItemSchedule
            WHERE OpportunityLineItemID = :oppLineRecId
        ];
        
        OpportunityLineItemDetailsWrapper oppDetailWrap = new OpportunityLineItemDetailsWrapper();
        oppDetailWrap.oppLineItemRst = oppLineItemRst;
        oppDetailWrap.oppLineItemSch = oppLineItemSch;
        
        return oppDetailWrap;
    }
    
    @AuraEnabled
    public static OppSchDetailsWrapper deleteSchedules(List<Id> schIds){
        Database.DeleteResult[] drList = Database.delete(schIds, true);
        OppSchDetailsWrapper oschWrap = new OppSchDetailsWrapper();
        oschWrap.successCount = 0;
        oschWrap.errorCount = 0;
		oschWrap.errorMessages = new List<String>();
        
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                oschWrap.successCount++;
                System.debug('Successfully deleted account with ID: ' + dr.getId());
            }else {
                oschWrap.errorCount++;
                // Operation failed, so get all errors  
                oschWrap.errorMessages.add(dr.getErrors()[0].getMessage());
            }
		}
        
        return oschWrap;
    }
        
   	public class OpportunityLineItemDetailsWrapper{
        @AuraEnabled public List<OpportunityLineItem> oppLineItemRst;
    	@AuraEnabled public List<OpportunityLineItemSchedule> oppLineItemSch; 	       
    }
    
    public class OppSchDetailsWrapper{
    	@AuraEnabled public Integer successCount;
        @AuraEnabled public Integer errorCount;
        @AuraEnabled public List<String> errorMessages;
    }
}