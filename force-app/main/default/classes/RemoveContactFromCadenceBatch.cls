/**
* @description       : Remove Cadence From Contact Batch Job (672699)
* @author            : Vikram simha
* @group             : 
* @last modified on  : 
* @last modified by  : 
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   Sep-04-2023   Vikram simha   Initial Version
**/
public class RemoveContactFromCadenceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    @testvisible
	private List<AccountHistory> accountHistoryRecsMock = new List<AccountHistory>();
    @testvisible
	private List<ActionCadenceTracker> actionCadenceTrackersMock = new List<ActionCadenceTracker>();
    private final String completionReasonCode = 'ManuallyRemoved';
    List<Id> contactIds; 
    Integer hours = 0;
    Integer batchSize = 5;
    public RemoveContactFromCadenceBatch(List<Id> contactIds)
    {
        this.contactIds = contactIds;
    } 
    public RemoveContactFromCadenceBatch()
    {
    } 
    public RemoveContactFromCadenceBatch(Integer hours,Integer batchSize)
    {
        this.hours = hours;
        this.batchSize = batchSize;
    }
    public RemoveContactFromCadenceBatch(Integer hours)
    {
        this.hours = hours;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> finalContactIds=new Set<Id>();
        if(contactIds == null || contactIds.IsEmpty())
        {
            List<AccountHistory> accHistoryRecs ;
            if(hours == 0)
            {
                DateTime rightNow =  DateTime.now();
                DateTime d6hAgo = rightNow.addHours(-6);
                accHistoryRecs  = [Select id,AccountId,CreatedDate from AccountHistory where (((account.Status__c='Inactive' and field='Status__c') OR field='Owner') and CreatedDate >= :d6hAgo ) order by createddate desc ];
            }
            else
            {
                DateTime rightNow =  DateTime.now();
                DateTime nhrsAgo = rightNow.addHours(-hours);
                accHistoryRecs  = [Select id,AccountId,createddate from AccountHistory where (((account.Status__c='Inactive' and field='Status__c') OR field='Owner') and CreatedDate >= :nhrsAgo) order by createddate desc ];
            }
            if(Test.isRunningTest())
            {
                accHistoryRecs =  accountHistoryRecsMock;
            }
            Map<Id,DateTime> accountIdMaxAccountOwnerStatusChangeDate = new Map<Id,DateTime>();
            for(AccountHistory ah :accHistoryRecs)
            {
                if(!accountIdMaxAccountOwnerStatusChangeDate.ContainsKey(ah.AccountId))
                {
                    accountIdMaxAccountOwnerStatusChangeDate.put(ah.AccountId,ah.createddate);
                }
            }
            Map<Id,DateTime> contactIdMaxAccountOwnerStatusChangeDate=new Map<Id,DateTime>();
            List<contact> initalContacts=[select id,AccountId from contact where accountid in :accountIdMaxAccountOwnerStatusChangeDate.keySet()];
            for(Contact c:initalContacts)
            {
                contactIdMaxAccountOwnerStatusChangeDate.put(c.Id,accountIdMaxAccountOwnerStatusChangeDate.get(c.AccountId));
            }
            List<ActionCadenceTracker> actionCadenceTrackers = [select targetid,createddate from  ActionCadenceTracker where State ='Running' and targetid in:contactIdMaxAccountOwnerStatusChangeDate.keySet()];
            if(Test.isRunningTest())
            {
                actionCadenceTrackers =  actionCadenceTrackersMock;
            }
            for(ActionCadenceTracker ac: actionCadenceTrackers)
            {
                if(ac.Createddate <= contactIdMaxAccountOwnerStatusChangeDate.get(ac.targetId))
                {
                    finalContactIds.add(ac.targetId);
                }
            }
        }
        else
        {
            List<ActionCadenceTracker> actionCadenceTrackers= [select targetid,createddate from  ActionCadenceTracker where State ='Running' and targetid in: contactIds];
            if(Test.isRunningTest())
            {
                actionCadenceTrackers =  actionCadenceTrackersMock;
            }
            for(ActionCadenceTracker ac: actionCadenceTrackers)
            {
                finalContactIds.add(ac.targetId);
            } 
        }
        return Database.getQueryLocator('Select Id,name from Contact where Id in :finalContactIds');
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        String token = '';
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint('callout:Cadence_Removal_Endpoint');
        req.setBody('{!$Credential.Password}');
        req.setMethod('POST');
        Http http = new Http();
        If(!Test.isRunningTest()){
            HTTPResponse response = http.send(req);
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            if(response.getStatusCode() == 200){
                token = (String)results.get('access_token');
            }
        }
        String sessionId = token;
        String removeTargetRESTUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v45.0/actions' + '/standard/removeTargetFromSalesCadence';
        CadenceInputWrapper cadenceInputWrapperObj = new CadenceInputWrapper();
        cadenceInputWrapperObj.Inputs = new List<Inputs>();
        for(sObject contact : scope) 
        {
            Inputs inputsObj = new Inputs();
            inputsObj.completionReasonCode=completionReasonCode;
            inputsObj.targetId= contact.id;
            cadenceInputWrapperObj.Inputs.add(inputsObj);
        }
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setHeader('Authorization', 'OAuth ' + sessionId);
        httpReq.setHeader('Authorization', 'Bearer ' + sessionId);
        httpReq.setEndpoint(removeTargetRESTUrl);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setBody(JSON.serialize(cadenceInputWrapperObj));
        try 
        { 
            http = new Http();
            HttpResponse httpResponse = http.send(httpReq);
            if (httpResponse.getStatusCode() == 200) 
            {
                CadenceOutputWrapper coW= new CadenceOutputWrapper();
                this.InsertExceptionLog(coW.parse(httpResponse.getBody()),scope);
            } 
            else 
            {
                CadenceOutputWrapper coW= new CadenceOutputWrapper();
                this.InsertExceptionLog(coW.parse(httpResponse.getBody()),scope);
            }
        } 
        catch (System.Exception e) 
        {
            List<Exception_Log__c> logExceptionList = new List<Exception_Log__c>();
            logExceptionList.add(new Exception_Log__c(
                Error_Message__c = e.getMessage(),
                Apex_Class_Trigger__c = RemoveContactFromCadenceBatch.class.getName(),
                DML_Object__c = 'Cadence Removal',
                Record_Id__c = ''));  
            if(!logExceptionList.IsEmpty())
            {
                ExceptionLogDAO.logException(logExceptionList);
            }
        }
    }
    public void finish(Database.BatchableContext BC)
    {        
        
    } 
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new RemoveContactFromCadenceBatch(hours,batchSize), batchSize);
    }
    
    private void InsertExceptionLog(List<CadenceOutputWrapper> cadenceOutputWrappers,List<sObject> scope)
    {
        integer i=0;
        List<Exception_Log__c> logExceptionList = new List<Exception_Log__c>();
        for(CadenceOutputWrapper outputWrapper : cadenceOutputWrappers)
        {
            if(!outputWrapper.isSuccess)
            {
                
                logExceptionList.add(new Exception_Log__c(
                    Error_Message__c = outputWrapper.OutputValues.error,
                    Apex_Class_Trigger__c = RemoveContactFromCadenceBatch.class.getName(),
                    DML_Object__c = 'Cadence Removal',
                    Record_Id__c = scope[i].id)); 
            }
            i++;
        }
        if(!logExceptionList.IsEmpty())
        {
            ExceptionLogDAO.logException(logExceptionList);
        }
    }
    public class CadenceOutputWrapper {
        public String actionName;
        public List<Errors> errors;
        public Boolean isSuccess;
        public OutputValues outputValues;
        public Integer version;
        public  List<CadenceOutputWrapper> parse(String json) {
            return (List<CadenceOutputWrapper>) System.JSON.deserialize(json, List<CadenceOutputWrapper>.class);
        }
    }
    public class Errors {
        public String statusCode;
        public String message; 
        public List<Fields> fields;
    }
    public class Fields {
    }
    public class OutputValues {
        public String error;
    }
    public class CadenceInputWrapper {
        public List<Inputs> inputs{get;set;}
    }
    public class Inputs{
        public String targetId{get;set;}
        public String completionReasonCode{get;set;}
    }
}