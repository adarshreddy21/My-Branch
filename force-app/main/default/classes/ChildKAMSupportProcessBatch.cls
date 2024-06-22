public class ChildKAMSupportProcessBatch implements Database.Batchable<sObject>{
	private Set<Id> successKAMSupportAccountIds;    
    private Map<Id, String> failedAccRecordMap = new Map<Id, String>();
    
    public ChildKAMSupportProcessBatch(Set<Id> successKAMSupportAccountIds){
        this.successKAMSupportAccountIds = successKAMSupportAccountIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id customerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
    	Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        Set<Id> successKAMSupportAccountIds = successKAMSupportAccountIds;
        
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Manifest_Address_Requirement__c = true; 
        UPDATE accountValidation;
        
        String query = 'SELECT Id, Key_Account_Support_Person__c ';
        query += 'FROM Account ';
        query += 'WHERE Key_Account_Assign_Override__c = FALSE AND Status__c != \'Inactive\' ';
        query += 'AND ParentId IN :successKAMSupportAccountIds ';
        query += 'AND Status__c != \'Archive\' AND Key_Account_Support_Person__c != NULL ';
        query += 'AND Key_Buying_Decision__c = \'Central Buying\' ';
        query += 'AND (RecordTypeId = :customerLocationAccountRecordType OR RecordTypeId = :customerAccountRecordType)';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        Map<String, User> UserbyName = new Map<String, User>();
        Set<String> CASNames = new Set<String>();
        
        for(Account childAccountRec : scope){
            CASNames.add(childAccountRec.Key_Account_Support_Person__c);
        }
        
        for(User Obj : [Select Id, Name from User where isActive = TRUE and Name IN : CASNames]){
            UserbyName.put(Obj.Name, Obj);
        }
        
        List<Account> updateChildAccounts = new List<Account>();
        
        for(Account childAccountRec : scope){
            if(UserByName.ContainsKey(childAccountRec.Key_Account_Support_Person__c)){
                childAccountRec.OwnerId = UserByName.get(childAccountRec.Key_Account_Support_Person__c).Id;
                updateChildAccounts.add(childAccountRec);
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