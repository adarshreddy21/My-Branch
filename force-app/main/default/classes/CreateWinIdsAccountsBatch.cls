public with sharing class CreateWinIdsAccountsBatch implements Database.Batchable<sObject>, Database.AllowsCallOuts, Schedulable{
    private Set<Id> integrationProcessIds = new Set<Id>();
    private static Accounts accountsObject= new Accounts();
    public CreateWinIdsAccountsBatch(){
    }

    public CreateWinIdsAccountsBatch(Set<Id> integrationProcessIds) {
        this.integrationProcessIds= integrationProcessIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = true;
		AccountCRUDHandler.isValidationDisable = false;
        upsert accountValidation Bypass_Account_Validation__c.Id;
        string processType = CHConstants.ACCOUNT_WIN_VALIDATE_CREATE;
        Datetime oldercreatedDate= System.Now().addHours(-1); 
        string query= '';
        if(integrationProcessIds.isEmpty()){
             query = 'SELECT Account__c,Account__r.Name, Account__r.Type, Account__r.RecordTypeId, Account__r.Win_Id__c, Account__r.WIN_ID_Sequence_Number__c,Account__r.Primary_Business__c, Account__r.Parent.WIN_ID__c, Account__r.CS_EPA_ID__c, Attempts__c from Integration_Process__c where (Status__c=\'Pending\' OR (Status__c=\'Error\' AND Attempts__c<>NULL AND Attempts__c<2)) and Process_Type__c=:processType and Account__r.Class__c!=\'Ecommerce\' AND (Account__r.High_Priority__c = false OR (Account__r.High_Priority__c = true AND createddate<=:olderCreatedDate)) order by Createddate ASC';
        }
        else{
            Set<Id> integrationProcessIds= this.integrationProcessIds; 
            query = 'SELECT Account__c,Account__r.Name, Account__r.Type, Account__r.RecordTypeId, Account__r.Win_Id__c, Account__r.WIN_ID_Sequence_Number__c,Account__r.Primary_Business__c, Account__r.Parent.WIN_ID__c, Account__r.CS_EPA_ID__c from Integration_Process__c where Status__c=\'Pending\' and Process_Type__c=:processType and Id in:integrationProcessIds order by Createddate ASC';
        } 
        return Database.getQueryLocator(query);  
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        accountsObject.processIntegrationRecordsToCreateWinId((List<Integration_Process__c>)scope);
    }
    
    public void finish(Database.BatchableContext BC){
       Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false;
		AccountCRUDHandler.isValidationDisable = true;
        upsert accountValidation Bypass_Account_Validation__c.Id;
        if(!Test.isRunningTest()){
            System.scheduleBatch(new CreateWinIdsAccountsBatch(), 'CreateWinIdsLowPriority', 30, 150);
        }
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CreateWinIdsAccountsBatch(), 50);
    }	
}