public class AccountReceivableListController {
    public List<Accounts_Receivable__c> accRecList{get;set;} 
    
    //Constructor
    public AccountReceivableListController(ApexPages.StandardController controller) {
        
        String accId = ApexPages.currentPage().getParameters().get('id');
        accRecList = new List<Accounts_Receivable__c>();
        accRecList = [Select Id, Name,Credit_Limit__c, AR_Current__c, AR_1_30__c, AR_31_60__c, AR_61_90__c, AR_91_180__c, AR_181_365__c, AR_Over_365__c, AR_Total__c from Accounts_Receivable__c where Account__c =: accId];
        
    }
}