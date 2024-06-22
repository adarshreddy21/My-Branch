public class CaseRankBatchFix implements Database.Batchable<sObject>,Database.Stateful{
    public integer total =0;
    public Database.QueryLocator start (database.BatchableContext BC){
        
        string openCaseRecordTypeQuery = '(RecordType.DeveloperName = \'Collector_PO_Case\' OR RecordType.DeveloperName = \'Customer_PO_Case\' OR RecordType.DeveloperName = \'Non_Standard_Billing_Closed_Order\' OR RecordType.DeveloperName = \'Non_Standard_Billing_WIN\' OR RecordType.DeveloperName = \'Invoice_Delivery\' OR RecordType.DeveloperName = \'Customer_Service_Case\' OR RecordType.DeveloperName = \'Customer_Service_Case_New\')';
        string closedCaseRecordTypeQuery = '(RecordType.DeveloperName = \'Customer_Service_Case\' OR RecordType.DeveloperName = \'Customer_Service_Case_New\')';
        string accountRecordQuery = 'account.Status__c = \'Active\' AND account.win_id__c != null AND (account.RecordType.DeveloperName = \'Customer\' OR account.RecordType.DeveloperName = \'Customer_Location\')';
        string openCaseQuery = '(Status = \'New\' OR Status = \'In Progress\') AND (owner.UserRole.DeveloperName = \'SK_INS_BPS_AM\' OR owner.UserRole.DeveloperName = \'SK_INS_SKE_AM\') AND '+openCaseRecordTypeQuery+' AND '+accountRecordQuery;
        string closedCaseQuery = 'Status = \'Resolved\' AND (Level_1_Escalation__c = true OR Level_2_Escalation__c = true OR Level_3_Escalation__c = true) AND ClosedDate = LAST_N_DAYS:10 AND '+closedCaseRecordTypeQuery+' AND '+accountRecordQuery;
        String Query = 'Select Id From Case where (('+openCaseQuery+') OR ('+closedCaseQuery+')) ORDER By AccountId';
        return Database.getQueryLocator(Query);  
    }
    
    public void Execute (Database.BatchableContext BC, List<sObject>Scope){
        total += Scope.size();
        Set<Id> caseId = new Set<Id> ();
        List<Case> updateCaseList = new List<case>();
        for (Case csl:(List<Case>)Scope){
            caseId.add(csl.id);
        }
        
        List<Case> csList = [Select Id, Case_Rank__c,OwnerId,Account.OwnerId,Status From Case where Id in :caseId FOR UPDATE];
        for (Case c:csList){
            if ((c.status == 'New' || c.Status == 'In Progress') && (c.Ownerid == c.Account.Ownerid)){
                Case cs = new case();
                cs.id = c.id; 
                cs.Case_Rank__c = 10;
                updateCaseList.add(cs);
            }else if(c.status == 'Resolved'){
                Case cs = new case();
                cs.id = c.id;
                cs.Case_Rank__c = 7;
                updateCaseList.add(cs);
            }
            
        }
        
        if(updateCaseList.size() >0){
            Database.SaveResult[] SaveResultList = Database.update(updateCaseList,false);
            ExceptionLogHelper.logException(true, SaveResultList, 'Case', updateCaseList, 'CaseRankBatchFix', 'execute');
        }
        
    }
    
    public void Finish (Database.BatchableContext BC){
        
    }
    

}