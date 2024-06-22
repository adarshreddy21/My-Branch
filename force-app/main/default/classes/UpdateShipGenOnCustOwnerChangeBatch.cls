public class UpdateShipGenOnCustOwnerChangeBatch implements Database.Batchable<sObject>{
	public Map<Id, Id> accountIdToOwnerIdMap;
    
    public UpdateShipGenOnCustOwnerChangeBatch(Map<Id, Id> accountIdToOwnerIdMap){
        this.accountIdToOwnerIdMap = accountIdToOwnerIdMap;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> accountIds = accountIdToOwnerIdMap.keySet();
        Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        String query = 'SELECT Id, ParentId FROM Account WHERE ParentId IN :accountIds AND RecordTypeId = :customerLocationAccountRecordType';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        for(Account accRec : scope){
            accRec.OwnerId = accountIdToOwnerIdMap.get(accRec.ParentId);
        }
        
        if(scope.size() > 0){
            Database.update(scope, false);
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}