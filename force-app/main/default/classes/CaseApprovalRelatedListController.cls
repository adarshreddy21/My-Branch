/**
* @description       : 
* @author            : Vikram Simha (Yerabov)
* @group             : 
* @last modified on  : 04-03-2024
* @last modified by  : Vikram Simha
**/
public class CaseApprovalRelatedListController {
    private static final string NO_USER_ACCESS_MESSAGE = 'You dont have access to manage child cases please contact MDM Team.';
    @AuraEnabled
    public static ChildCasesWrapper getChildCaseRecords(String parentId){ 
        ChildCasesWrapper childCasesWrapperObj = new ChildCasesWrapper();
        if(checkUserAccess())
        {
            childCasesWrapperObj.hasUserAccess = true;
            childCasesWrapperObj.childCasesData =  getChildCasesDataTableWrapper(parentId);
            childCasesWrapperObj.message =  '';
        }
        else{
            childCasesWrapperObj.hasUserAccess = false;
            childCasesWrapperObj.childCasesData =  null;
            childCasesWrapperObj.message =  NO_USER_ACCESS_MESSAGE;
        }
        return childCasesWrapperObj;         
    }
    private static boolean checkUserAccess(){
        User loggedInuser = [select Id,Profile.Name, Name from User where Id = :UserInfo.getUserId()];
        if(loggedInuser.profile.Name == 'System Administrator' || loggedInuser.profile.Name =='Integration' )
        {
            return true;
        }
        List<GroupMember> groupMembers= [Select UserOrGroupId,GroupId From GroupMember where GroupId in (Select Id from Group where type='Queue' and DeveloperName  = 'MDM_Case_Queue') and UserOrGroupId=:UserInfo.getUserId()];
        if(groupMembers !=null && !groupMembers.IsEmpty())
        {
            return true;
        }        
        return false;
    }
    @AuraEnabled
    public static List<DataTableWrapper> approveRejectCaseRecords(String selectedChildRecordIds ,String parentId,String status){
        List<String> recordIds = selectedChildRecordIds.split(',');
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId In :recordIds 
        ];
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            req.setAction(status);
            req.setComments('NA.');
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
        return getChildCasesDataTableWrapper(parentId);  
    }
    
    private static List<DataTableWrapper> getChildCasesDataTableWrapper(Id parentId)
    {
        List<DataTableWrapper> responseChildCaseRecs = new List<DataTableWrapper>();
        for(Case caseRecord : [select id,casenumber,Status, Account_Field_Changed__c, Old_Value__c, New_Value__c, Subject from case where ParentId = :parentId and status = 'Awaiting Manager Approval']){
            DataTableWrapper wrapperObj = new DataTableWrapper();
            wrapperObj.id = caseRecord.Id;
            wrapperObj.caseNumber = caseRecord.casenumber;
            wrapperObj.caseNumberUrl = '/'+caseRecord.Id;
            wrapperObj.status = caseRecord.status;
            wrapperObj.accountFieldChanged = caseRecord.account_Field_Changed__c;
            wrapperObj.oldValue = caseRecord.old_Value__c;
            wrapperObj.subject = caseRecord.subject;
            wrapperObj.newValue = caseRecord.new_Value__c;
            responseChildCaseRecs.add(wrapperObj);
        }
        return responseChildCaseRecs;
    }
    public class ChildCasesWrapper {
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public boolean hasUserAccess {get;set;}
        @AuraEnabled
        public List<DataTableWrapper> childCasesData {get;set;}
    }
    public class DataTableWrapper {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String caseNumber {get;set;}
        @AuraEnabled
        public String caseNumberUrl {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String accountFieldChanged {get;set;}
        @AuraEnabled
        public String oldValue {get;set;}
        @AuraEnabled
        public String newValue {get;set;}
        @AuraEnabled
        public String subject {get;set;}
    }
    
}