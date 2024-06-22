public class KAMSupportProcessBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Set<Id> KAMSupportAccountIds;
    private Set<Id> successKAMSupportAccountIds = new Set<Id>();
    private Map<Id, String> failedAccRecordMap = new Map<Id, String>();
    
    public KAMSupportProcessBatch(Set<Id> KAMSupportAccountIds){
        this.KAMSupportAccountIds = KAMSupportAccountIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id customerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
    	Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        Set<Id> KAMSupportAccountIds = KAMSupportAccountIds;
        
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = true; 
        UPDATE accountValidation;
        
        String query = 'SELECT Id, Key_Account_Support_Person__c ';
        query += 'FROM Account ';
        query += 'WHERE ParentId IN :KAMSupportAccountIds ';
        query += 'AND Key_Account_Assign_Override__c = FALSE ';
        query += 'AND Status__c != \'Inactive\' ';
        query += 'AND Status__c != \'Archive\' ';
        query += 'AND Key_Account_Support_Person__c != NULL ';
        query += 'AND Key_Buying_Decision__c = \'Central Buying\' ';
        query += 'AND ( RecordTypeId = :customerLocationAccountRecordType OR RecordTypeId = :customerAccountRecordType )'; 
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        Map<String, User> UserbyName = new Map<String, User>();
        Set<String> CASNames = new Set<String>();
        
        for(Account accountRec : scope){
            CASNames.add(accountRec.Key_Account_Support_Person__c);
        }
        
        for(User Obj : [Select Id, Name from User where isActive = TRUE and Name IN : CASNames]){
            UserbyName.put(Obj.Name, Obj);
        }
        
        List<Account> updateChildAccounts = new List<Account>();
        
        for(Account childAccount : scope){
            if(UserByName.ContainsKey(childAccount.Key_Account_Support_Person__c)){
                childAccount.OwnerId = UserByName.get(childAccount.Key_Account_Support_Person__c).Id;
                updateChildAccounts.add(childAccount);
            }
        }  
        
        if(updateChildAccounts.size() > 0){
            List<Database.SaveResult> saveResultLst = Database.update(updateChildAccounts, false);
            
            for (Database.SaveResult saveResultObj : saveResultLst) {
                if (!saveResultObj.isSuccess()) {
                    //saveResultObj.getId();
                    String errorMsg = '';
                    for(Database.Error err : saveResultObj.getErrors()) {
                        errorMsg += err.getMessage() + '\n';
                    }
                    
                    if(errorMsg.length() > 0)
                        errorMsg = errorMsg.substring(0, errorMsg.length() - 2); 
                    //failedAccRecordMap.put(key, value)
                }else{
                    this.successKAMSupportAccountIds.add(saveResultObj.getId());
                }
            }
        }   
    }
    
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new ChildKAMSupportProcessBatch(this.successKAMSupportAccountIds), 50);
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false; 
        UPDATE accountValidation;
    }
}