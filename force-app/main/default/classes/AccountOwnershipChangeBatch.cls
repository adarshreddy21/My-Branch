/**
* @description       : Account Owner Update/WIN Sync Batch Job (587807)
* @author            : Vikram simha
* @group             : 
* @last modified on  : June-26-2022
* @last modified by  : Vikram simha
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-30-2022   Suresh Beniwal   Initial Version
**/
public class AccountOwnershipChangeBatch implements Database.Batchable<sObject>{
    String query = '';
    String SKENV='SK ENV';
    String SKBPS='SK BPS';
    public AccountOwnershipChangeBatch(String query)
    {
        this.query = query;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime startDate ;
        DateTime endDate ;
        Integer monthNum = Date.today().month();
        Integer yearNum = Date.today().year();
        if(monthNum < =3 )
        {
            startDate = DateTime.newInstance(yearNum, 01, 01);
            endDate = DateTime.newInstance(yearNum, 03, 31);
            
        }
        else if(monthNum > 3 &&  monthNum <= 6)
        {
            startDate = DateTime.newInstance(yearNum, 04, 01);
            endDate = DateTime.newInstance(yearNum, 06, 30);
        }
        else if(monthNum > 6 && monthNum <= 9)
        {
            startDate = DateTime.newInstance(yearNum, 07, 01);
            endDate = DateTime.newInstance(yearNum, 09, 30);
        }
        else
        {
            startDate = DateTime.newInstance(yearNum, 10, 01);
            endDate = DateTime.newInstance(yearNum, 12, 31);
        }
        startDate = DateTime.valueof(String.escapeSingleQuotes((String.valueofGmt(startDate))));
        endDate = DateTime.valueof(String.escapeSingleQuotes((String.valueofGmt(endDate))));
        if(query=='')
        {
            query = 'SELECT Id, Name, Account__c, Account_Owner_del__c,Account_Operating_Segment_Text__c,Requested_Owner_Territory_Id__c, Account_Operating_Segment__c,Account_Primary_Service_Provider_Text__c, Account_Primary_Service_Provider__c,'+
                'Current_Account_Owner__c, Requested_Account_Owner__c, New_Owner__c, Justification__c, New_Owner_s_Manager__c, New_Owner_s_VP__c, Existing_Owner_s_Manager__c, Existing_Owner_s_VP__c, Effective_Date__c, Status__c, New_Operating_Segment__c, New_Primary_Service_Provider__c, Prior_year_s_revenue__c, Need_Existing_Manager_Approval__c, Account_Owner_Managers_Same__c,'+
                'Account_Owner_Vps_Same__c, Reason_for_Change__c FROM Ownership_Change_Request__c where Status__c = \'Approved-Pending\' and Effective_Date__c >= '+startDate.format('yyyy-MM-dd') +' and Effective_Date__c <= '+endDate.format('yyyy-MM-dd');
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accounts = new List<Account>();
        Map<id,Ownership_Change_Request__c> ownershipChangeRequestsMap = new Map<Id,Ownership_Change_Request__c>();
        List<Integration_Process__c> integrationRecordsToErrorLog = new List<Integration_Process__c>();
        Set<id> accountIdSet = new Set<id>();
        Set<string> territoryNameSet = new Set<string>();
        Map<string,Territory__c> territoryNameAvailable = new Map<string,Territory__c>();
        for(Ownership_Change_Request__c changeRequestObj : (List<Ownership_Change_Request__c>)scope)
        {
            territoryNameSet.add(changeRequestObj.Requested_Owner_Territory_Id__c);
            if((changeRequestObj.New_Operating_Segment__c == SKENV||changeRequestObj.New_Operating_Segment__c == SKBPS)
               &&(changeRequestObj.New_Operating_Segment__c!=changeRequestObj.Account_Operating_Segment_Text__c || changeRequestObj.New_Primary_Service_Provider__c!=changeRequestObj.Account_Primary_Service_Provider_Text__c))
                
            {
                accountIdSet.add(changeRequestObj.Account__c); 
            }
        }
        Map<Id,Account> accountsMap = new Map<Id,Account>([select id,name,Primary_SK_Branch_Override__c,Primary_SK_Branch__c from account where id in:accountIdSet and Primary_SK_Branch_Override__c=true]);
        List<Territory__c> territoryList= [select id,name from Territory__c where name in :territoryNameSet];
        for(Territory__c  territory : territoryList)
        {
            territoryNameAvailable.put(territory.Name,territory);
        }
        for(Ownership_Change_Request__c changeRequestObj : (List<Ownership_Change_Request__c>)scope)
        {
            if(territoryNameAvailable.ContainsKey(changeRequestObj.Requested_Owner_Territory_Id__c))
            {
                Account acc = new Account();
                acc.id = changeRequestObj.Account__c;
                if(accountsMap.containsKey(changeRequestObj.Account__c))
                {
                    if(accountsMap.get(changeRequestObj.Account__c).Primary_SK_Branch__c!='OAC' && accountsMap.get(changeRequestObj.Account__c).Primary_SK_Branch__c!='RMS')
                    {
                        acc.Primary_SK_Branch_Override__c = false;
                    }
                }
                acc.OwnerId = changeRequestObj.New_Owner__c;
                acc.Primary_Service_Provider_New__c = changeRequestObj.New_Operating_Segment__c;
                acc.Primary_Business__c = changeRequestObj.New_Primary_Service_Provider__c;
                acc.Territory_Override__c = true;
                acc.Territory_ID_SK__c = territoryNameAvailable.get(changeRequestObj.Requested_Owner_Territory_Id__c).Id;
                changeRequestObj.Status__c = 'Executed';
                accounts.add(acc);
            }
            else
            {
                Integration_Process__c integProcess = new Integration_Process__c();
                integProcess.Status__c= 'Error';
                integProcess.Process_Type__c= CHConstants.OCRBatchUpdate;
                integProcess.Account__c= changeRequestObj.Account__c;
                integProcess.Error_Message__c= 'Requested Owner Territory Id Not Found.';
                changeRequestObj.Status__c = 'Failed';
                integrationRecordsToErrorLog.add(integProcess);
            }
            ownershipChangeRequestsMap.put(changeRequestObj.Account__c,changeRequestObj);
        } 
        if(!accounts.Isempty()){
            AccountCRUDHandler.SKIP_ONOwnerChangeBatch = True;
            Database.SaveResult[] ocrList = Database.update(accounts, false);
            for (Database.SaveResult sr : ocrList) {
                Integration_Process__c integProcess = new Integration_Process__c();
                if (sr.isSuccess()) {
                    integProcess.Status__c= 'Processed';
                    integProcess.Process_Type__c= CHConstants.OCRBatchUpdate;
                    integProcess.Account__c= sr.getId();
                } else {
                    for(Database.Error objErr : sr.getErrors()) {
                        integProcess.Status__c= 'Error';
                        integProcess.Process_Type__c= CHConstants.OCRBatchUpdate;
                        integProcess.Account__c= sr.getId();
                        ownershipChangeRequestsMap.get(integProcess.Account__c).Status__c = 'Failed';
                        integProcess.Error_Message__c= objErr.getMessage();
                    }
                }
                integrationRecordsToErrorLog.add(integProcess);
            }
        }
        
        if(!ownershipChangeRequestsMap.IsEmpty())
        {
            Database.SaveResult[] ocrrequestList = Database.update(ownershipChangeRequestsMap.values(), false);
            for (Database.SaveResult sr : ocrrequestList) {
                Integration_Process__c integProcess = new Integration_Process__c();
                if (sr.isSuccess()) {
                    
                } else {
                    for(Database.Error objErr : sr.getErrors()) {
                        integProcess.Status__c= 'Error';
                        integProcess.Process_Type__c= CHConstants.OCRBatchUpdate;
                        integProcess.Error_Message__c= 'Ownership Chage Request Object '+' |'+sr.getId()+'| '+objErr.getMessage();
                        integrationRecordsToErrorLog.add(integProcess);
                    }
                }
            }
        }
        insert integrationRecordsToErrorLog;
    }
    public void finish(Database.BatchableContext BC){
        
    } 
}