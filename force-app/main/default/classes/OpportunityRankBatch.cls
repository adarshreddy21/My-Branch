public class OpportunityRankBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            String query = 'SELECT Id,Opportunity_Rank__c, accountid, account.IS_Opportunity_Rank__c FROM Opportunity where LastModifiedDate <= LAST_N_DAYS:15 AND Opportunity_Rank__c!= null AND account.IS_Opportunity_Rank__c = null AND account.Status__c = \'Active\' AND account.win_id__c != null AND (account.RecordType.DeveloperName = \'Customer\' OR account.RecordType.DeveloperName = \'Customer_Location\')';
            return Database.getQueryLocator(query);
        }else if(Test.isRunningTest()){
            String query = 'SELECT Id,Opportunity_Rank__c, accountid, account.IS_Opportunity_Rank__c FROM Opportunity where LastModifiedDate = Today AND Opportunity_Rank__c = null AND account.IS_Opportunity_Rank__c = null AND account.Status__c = \'Active\' AND account.win_id__c != null AND (account.RecordType.DeveloperName = \'Customer\' OR account.RecordType.DeveloperName = \'Customer_Location\')';
            return Database.getQueryLocator(query);
        }
        return null;
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        map<Id, decimal> accoppMap = new map<Id, decimal>();
        List<account> updateAccountList = new List<account>();
        List<Opportunity> oppList = (List<Opportunity>)scope;
        for (Opportunity o:oppList){
            if(accoppMap.isEmpty() || !accoppMap.containsKey(o.accountid)){
                accoppMap.put(o.accountid, o.Opportunity_Rank__c);
            }  
        }
        
        for(id accid: accoppMap.keyset()){
            Account newAcc = new Account();
            newAcc.id = accid;
            newAcc.IS_Opportunity_Rank__c = accoppMap.get(accid);
            updateAccountList.add(newAcc);
        }
        if(updateAccountList.size() > 0){
            List <Database.SaveResult> SaveResultList = Database.update(updateAccountList,false);
            ExceptionLogHelper.logException(true, SaveResultList, 'Account', updateAccountList, 'OpportunityRankBatch', 'execute');
            
        } 
    }
    
    public void finish(Database.BatchableContext BC){
        
    } 
    
    
}