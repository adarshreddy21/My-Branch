public class ChangeRecordTypeForBrokerChildren implements Database.Batchable<sObject>{
    private Id parentAccId;
    
    public ChangeRecordTypeForBrokerChildren(Id parentAccId){
        this.parentAccId = parentAccId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
         Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = true; 
        UPDATE accountValidation;
        Id accId = this.parentAccId;
        String query = 'select id from account where parentid =:accId AND RecordType.DeveloperName != \'Broker_Location\' and Status__c=\'Active\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        Id brokerLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker Location').getRecordTypeId();
        List<Account> childAccountsToBeUpdated = new List<Account>();
        for(Account accRec: scope){
            accRec.RecordTypeId = brokerLocationRecordTypeId;
            accRec.Type='Brok/Gen';
            accRec.WIN_Validated__c=true;
            childAccountsToBeUpdated.add(accRec);
        }
if(!childAccountsToBeUpdated.isEmpty()){
            List<Database.SaveResult> saveResultLst = Database.update(childAccountsToBeUpdated, false);
            
            for (Database.SaveResult saveResultObj : saveResultLst) {
                if (!saveResultObj.isSuccess()) {
                    String errorMsg = '';
                    for(Database.Error err : saveResultObj.getErrors()) {
                        errorMsg += err.getMessage() + '\n';
                    }
                    
                    if(errorMsg.length() > 0)
                        errorMsg = errorMsg.substring(0, errorMsg.length() - 2); 
                }
            }
        } 
        
    }
    
    public void finish(Database.BatchableContext BC){
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false; 
        UPDATE accountValidation;
    }
}