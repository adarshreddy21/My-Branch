public class UpdateAccountTerritoryBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Set<Id> corporateAccountIdsSet;
    private Set<Id> corporateAccountIdsNewSet = new Set<Id>();
    private Boolean isParent;
    
    public UpdateAccountTerritoryBatch(Set<Id> corporateAccountIdsSet, Boolean isParent){
        this.corporateAccountIdsSet = corporateAccountIdsSet;
        this.isParent = isParent;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id customerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
    	Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        
        Set<Id> corporateAccountIdsSet = corporateAccountIdsSet;
        
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = true; 
        UPDATE accountValidation;
        
        String query = 'SELECT Id, Key_Account_Support_Person__c, ZIP_Master__c, Primary_Service_Provider_New__c, Primary_Business__c ';
        query += 'FROM Account ';
        query += 'WHERE ParentId IN :corporateAccountIdsSet ';
        query += 'AND Status__c != \'Inactive\' ';
        query += 'AND Status__c != \'Archive\' ';
        query += 'AND (Primary_Service_Provider_New__c = \'SK ENV\' OR Primary_Service_Provider_New__c = \'SK BPS\') ';
        query += 'AND (RecordTypeId = :customerLocationAccountRecordType OR RecordTypeId = :customerAccountRecordType) ';
        query += 'AND ZIP_Master__c != NULL';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        this.corporateAccountIdsNewSet.addAll(UpdateAccountTerritoryBatchHandler.updateAccountTerritory(scope, this.isParent));
    }
    
    public void finish(Database.BatchableContext BC){
        if(this.isParent){
            Database.executeBatch(new UpdateAccountTerritoryBatch(this.corporateAccountIdsNewSet, false), 50);
        }
        
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false; 
        UPDATE accountValidation;
    }
}