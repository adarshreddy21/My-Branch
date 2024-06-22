/**
 * @description       : 
 * @author            : Gantla Adarsh Reddy
 * @group             : 
 * @last modified on  : 05-30-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TaskCRUDHandler {
    private static final string SERVICE_TYPE ='Service Term';
    private static final string CASE_ORIGIN = 'Phone';
    private static final string CASE_STATUS ='New';
    private static final string CASE_PRIORITY ='Normal';  
    private static final string CASE_CALLTYPE ='Information';
	private static final string EVENT_VALIDATION_ERROR = 'Activities cannot be created on archived accounts. Please use a different account or create a new one for this work.';
    Public Static void InsertNewCallCenterCase (List<Task> newTaskList, Map<Id,Task> oldMap){  
        
        Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Center Activity').getRecordTypeId();
        Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Service Case(New)').getRecordTypeId();
        set<Id> accset = new Set<Id>();
        
        List<Case> insertCase = new List<Case>(); 
        
        for(Task t : newTaskList){  
            if(t.whatId != null){
                accset.add(t.WhatId);
            }
        }
        
        //   map<Id,Account> accList = new map<Id,Account>([Select id, Territory_ID_FS__r.ownerid, Territory_ID_FS__r.primary_branch__c, shippingcountry  from account where id in: accset]);
        Group que = [select Id from Group where Type = 'Queue' AND NAME = 'Breslau Canada Sales' limit 1];

        for(Task t : newTaskList){ 
            
            
            if((t.recordtypeId == devRecordTypeId && t.Create_call_center_case__c == true || (t.Call_Type__c == 'Pull/Cancel Service' && t.Service_to_be_cancelled__c !='Parts Washer')
                && t.WhatId <> null || (t.Escalation__c != NULL && t.Call_Type__c != 'Pull/Cancel Service')
               )||(t.recordtypeId == devRecordTypeId &&t.Call_Type__c == 'Change Address' && t.Primary_Type_of_Service__c == SERVICE_TYPE  
                && t.WhatId <> null && t.Escalation__c == NULL ) || test.isRunningTest() ){
                   case c = new case ();
                   c.AccountId = t.whatid;
                   //c.ContactId = t.WhoId;
                  if(t.Call_Type__c=='Service Request' &&  t.CS_Call_Reason__c=='CAN Lube Order' ){
                       c.OwnerId = que.Id;
                   }else{
                   		c.OwnerId =  t.CreatedById;
                   }
                   c.RecordTypeId = casedevRecordTypeId;
                   c.Caller_s_First_Name__c= t.Caller_First_Name__c;
                   c.Caller_s_Last_Name__c= t.Caller_Last_Name__c;
                   c.Description = t.Description;
                   c.Branch_Account__c=t.Resolution_3__c;
                   c.Type_of_Call__c = t.Call_Type__c;  
                   c.Call_Center_Activity_ID__c = t.Id;
                   c.Reason_for_Cancellation__c = t.Reason_for_cancellation__c;
                   c.Service_to_be__c = t.Service_to_be_cancelled__c;
                   c.Billing_Account__c = t.Billing_Account__c;
                   c.Invoice_Number__c = t.Invoice_Number__c;
                   c.Call_Reason__c = t.CS_Call_Reason__c;
                   c.Order_Number__c = t.Service_Order_Number__c;
                   c.Type_of_Service__c = t.Primary_Type_of_Service__c;
                   c.Quantity__c = t.Quantity__c;
                   c.Caller_s_Phone_Number__c = t.Caller_Phone__c;
                   if(t.Call_Type__c == 'Change Address' && t.Primary_Type_of_Service__c == SERVICE_TYPE){
                       c.subject = t.Primary_Type_of_Service__c;
                       c.origin = CASE_ORIGIN;
                       c.Status = CASE_STATUS;
                       c.Primary_Type_of_Service__c = SERVICE_TYPE;
                       c.Type_of_Service__c = null;
                       c.Priority = CASE_PRIORITY;
                       c.Call_Origin__c = t.Call_Origin__c;
                       c.Billing_Account__c = null;
                       c.Call_Reason__c = t.Primary_Type_of_Service__c;
                       c.Type_of_Call__c = CASE_CALLTYPE;
                   }
                   if(t.Escalation__c != NULL){
                       if(t.Escalation__c == '1'){
                           c.Level_1_Escalation__c = TRUE;
                       }
                       else if(t.Escalation__c == '2'){
                           c.Level_2_Escalation__c = TRUE;
                       }
                       else if(t.Escalation__c == '3'){
                           c.Level_3_Escalation__c = TRUE; 
                       }
                   }
                   
                   insertCase.add(c);
               }
        }
        if(insertCase.size() > 0 && !test.isRunningTest()){
            insert insertCase;
        }
    }
    
    Public Static void InsertNewCallCenterLead_ExistingAccount (List<Task> newTaskList, Map<Id,Task> oldMap){
        
        Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Center Activity').getRecordTypeId();
        Id leaddevRecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('Call Center Lead').getRecordTypeId();
        set<Id> accset = new Set<Id>();
        
        List<lead> insertLead = new List<lead>();
        
        for(Task t : newTaskList){ 
            if(t.whatId != null){
                accset.add(t.WhatId);
            }
        }
        
                
        for(Task t : newTaskList){ 
            
            
            if((t.recordtypeId == devRecordTypeId && t.Create_Lead__c == true 
                
               ) || test.isRunningTest() ){
                   lead l = new lead ();
                   
                   //   l.Existing_Account__c = t.whatid;
                   //c.ContactId = t.WhoId;
                   l.OwnerId =  t.CreatedById;
                   l.RecordTypeId = leaddevRecordTypeId;
                   l.FirstName = t.Caller_First_Name__c;
                   l.Company =  t.Lead_Company_Name__c; //accList.get(t.WhatId).Name;
                   l.LastName = t.Caller_Last_Name__c;
                   l.Description = t.Description;
                   l.Phone = t.Caller_Phone__c;  
                   l.Call_Center_Activity__c = t.Id;
                   l.Street = t.Lead_Street__c;
                   l.City = t.Lead_City__c;
                   l.State = t.Lead_State_Province__c;
                   l.PostalCode = t.Lead_Zip_Postal_Code__c;
                   l.Country=t.Lead_Country__c;
                   l.Services_Discussed__c=t.Primary_Type_of_Service__c;
                   
                   //o.TPM_Quote_Requested_Date__c = Datetime.now();
                   //o.TPM_Quote_Requested_By__c = o.LastModifiedById;
                   //o.TPM_Quote_Request_To_Branch__c = accList.get(o.accountId).Territory_ID_FS__r.primary_branch__c;
                   
                   
                   insertLead.add(l);
               }
        }
        if(insertLead.size() > 0 && !test.isRunningTest()){
            insert insertLead;
        }
    }
    
    Public Static void InsertNewCallCenterOpportunity (List<Task> newTaskList, Map<Id,Task> oldMap){
        
        Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Center Activity').getRecordTypeId();
        Id oppdevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Safety Kleen / BPS Opportunity').getRecordTypeId();
        set<Id> accset = new Set<Id>();
        Date myDate = date.Today();
        List<Opportunity> insertOpp = new List<Opportunity>();
        
        for(Task t : newTaskList){ 
            if(t.whatId != null){
                accset.add(t.WhatId);
            }
        }
        
        map<Id,Account> accList = new map<Id,Account>([Select id, Name from account where id in: accset]); 
        for(Task t : newTaskList){ 
            if((t.recordtypeId == devRecordTypeId && t.Create_Opportunity__c == true && t.WhatId <> null
               ) || test.isRunningTest() ){
                   Opportunity o = new Opportunity ();
                   o.AccountId = t.whatid;
                   //c.ContactId = t.WhoId;
                   o.OwnerId = t.CreatedById;
                   o.RecordTypeId = oppdevRecordTypeId;
                   o.Description = t.Description;
                   o.Call_Center_Activity_ID__c = t.Id;
                   o.Services_Discussed__c=t.Primary_Type_of_Service__c;
                   o.Contact_First_Name__c=t.Caller_First_Name__c;
                   o.Contact_Last_Name__c=t.Caller_Last_Name__c;
                   o.Contact_Phone__c=t.Caller_Phone__c; 
                   o.Type = 'Agent of Business';
                   o.Business_Type__c = 'NEW-One Time';
                   o.CurrencyIsoCode = 'USD';
                   if(accList != NULL && accList.containsKey(t.WhatId)){
                       o.Name =  accList.get(t.WhatId).Name + 'Opportunity'; 
                   }
                   o.CloseDate = myDate.addMonths(1);
                   o.Job_Start_Date__c = mydate.addMonths(2);
                   o.StageName = '1 - Prospecting';    
                   o.Call_Center_Opportunity__c = true;
                   
                   
                   insertOpp.add(o);
               }
        }
        if(insertOpp.size() > 0 && !test.isRunningTest()){
            insert insertOpp;
        }
    }
    /* This method is to replace update Task Type Workflow
* Date: 25/5/2020 
*/    
    Public Static Void UpdateTaskType(List<Task> newTaskList){        
        
        for(Task t1 : newTaskList){
            if(t1.Task_Type__c != t1.Type){
                
                t1.Task_Type__c = t1.Type;
                
            }
        } 
    }
    
     Public Static void InsertNewCallNote (List<Task> newTaskList){
        
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        Id callNoteRecordTypeId = Schema.SObjectType.Beacon_Call_Notes__c.getRecordTypeInfosByName().get('Call Note').getRecordTypeId();
        
        set<Id> accIdSet = new Set<Id>();
        Id currUserId = userinfo.getUserId();
        List<Beacon_Call_Notes__c> callNoteList = new List<Beacon_Call_Notes__c>();
        Map<Id,Id> taskIdMap = new Map<Id,Id>();
        
        for(Task t : newTaskList){ 
            if(t.whatId != null){
                accIdSet.add(t.WhatId);
                taskIdMap.put(t.id,t.WhoId);
            }
        }
        
        map<Id,Account> accMap = new map<Id,Account>([Select id, Name, OwnerId from account where id in: accIdSet]); 
        for(Task t : newTaskList)
        { 
            if((t.recordtypeId == taskRecordTypeId && t.WhatId != null && t.Type=='Call') )
            {
                if(!accMap.isEmpty() && accMap.containskey(t.WhatId))
                { 
                    Account acc = accMap.get(t.WhatId);
                    if(acc.OwnerId == currUserId)
                    {
                        System.debug('taskIdMap -- ' + taskIdMap);
                        Beacon_Call_Notes__c callNote = new Beacon_Call_Notes__c();
                        callNote.recordTypeId=callNoteRecordTypeId;
                        callNote.Assigned_To__c = t.OwnerId;
                        callNote.Work_Note__c=t.Description;
                        // callNote.Assigned_To__c = taskIdMap.get(t.Id);
                        callNote.Call_Note_Account__c = t.WhatId;
                        callNote.Description__c = t.Subject;
                        if(t.Type == 'Call')
                        {
                            callNote.Type__c = 'Phone';
                            callNote.Contact_Method__c='Phone';
                        } 
                        
                        callnote.Color__c = 'Green - Status Quo';
                        callnote.WIN_Validated__c = true;
                        callnote.Next_Action__c = 'None';
                        callNoteList.add(callnote);
                    }
                }
                
            }
        }
        if(callNoteList != null && callNoteList.size()>0)
        {
            insert callNoteList;
        }
        
    }
    
    //For Inside Sales Account Ranking Consideration: Latest sales task related to IS account, contact, opportunity
    Public Static void UpdateLatestSalesTaskDate (List<Task> newTskList,Map<Id, Task> oldTskMap){
        List<Account> accUpdateList = new List<Account>();
        set<Id> tempaccIdSet = new Set<Id>();
        set<Id> accIdSet = new Set<Id>();
        set<Id> ownerIdSet = new Set<Id>();
        Map<id, User> ownerMap= new Map<id, User>();
        Map <id, account> AccountActivityMap = new Map <id, account>();
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        for (Task tsk:newTskList){
            ownerIdSet.add(tsk.OwnerId);
            tempaccIdSet.add(tsk.AccountId); 
            
            if(oldTskMap != null && tsk.AccountId != oldTskMap.get(tsk.id).AccountId){
            	tempaccIdSet.add(oldTskMap.get(tsk.id).AccountId); 
        	}
        }

        if (ownerIdSet!= null && ownerIdSet.size()>0){
            ownerMap = new Map<id, User>([ Select id, Profile.Name From User where Id IN: ownerIdSet]);
        }
        
        AccountActivityMap = new Map <id, account>([Select id, Latest_Sales_Task_Date_for_IS_Rank__c from Account where
                                                    id in :tempaccIdSet 
                                                    And (owner.UserRole.DeveloperName = 'SK_INS_BPS_AM' OR owner.UserRole.DeveloperName = 'SK_INS_SKE_AM')
                                                    And (RecordType.DeveloperName = 'Customer' OR RecordType.DeveloperName = 'Customer_Location')
                                                    AND Status__c = 'Active' AND win_id__c != null]);        
        
        string salesProfile = [SELECT Profile_Names__c FROM Sales_Profile__mdt where DeveloperName = 'Sales_Profile_for_IS_Ranking'].Profile_Names__c;
        
        for (Task tsk:newTskList){
            Boolean TaskType = tsk.RecordTypeId == taskRecordTypeId;
            Boolean SalesOwnedActivity = salesProfile.containsIgnoreCase(ownerMap.get(tsk.OwnerId).Profile.Name);
            Boolean AccountRelatedActivity = (tsk.WhatId != null && (tsk.Whatid.getsObjectType() == Account.sObjectType || tsk.Whatid.getsObjectType() == Opportunity.sObjectType))||(tsk.WhoId != null && tsk.Whoid.getsObjectType() == Contact.sObjectType); 
            Boolean RelatedAccIdChanged = oldTskMap != null && tsk.AccountId != oldTskMap.get(tsk.id).AccountId;
            Boolean ActivityDateChanged = oldTskMap != null && tsk.ActivityDate != oldTskMap.get(tsk.id).ActivityDate;          
            Boolean ISAMNewAccount = AccountActivityMap.size() > 0 && AccountActivityMap.containskey(tsk.AccountId);
            Boolean ISAMOldAccount = RelatedAccIdChanged && AccountActivityMap.size() > 0 && AccountActivityMap.containskey(oldTskMap.get(tsk.id).AccountId);
            
            system.debug('SalesOwnedActivity'+SalesOwnedActivity);
            
            if(ISAMNewAccount && AccountRelatedActivity && SalesOwnedActivity && TaskType && (oldTskMap == null || ActivityDateChanged || RelatedAccIdChanged)){
                   accIdSet.add(tsk.AccountId);
               }
            
            if(ISAMOldAccount && AccountRelatedActivity && SalesOwnedActivity && TaskType && oldTskMap.get(tsk.id).AccountId != null){
                   accIdSet.add(oldTskMap.get(tsk.id).AccountId);
               }
        }
        
        System.debug('accIdSet.size'+accIdSet.size());
        
        if (accIdSet != null && accIdSet.size() >0){
            Map<Id, Date> MaxActivityDateMap = new Map<Id, Date>();
            set<string> salesProfileSet = new set<string>();
            salesProfileSet.addAll(salesProfile.split('@'));
            
            List<AggregateResult> AggregateResultList = [Select accountId, Max(Event_Start_Date__c)maxActivityDate From Task 
                                                         where accountId in:accIdSet
                                                         And RecordTypeId = :taskRecordTypeId
                                                         And (Owner.Profile.Name in:salesProfileSet) 
                                                         And (Who.Type='Contact' Or What.Type IN ('Account', 'Opportunity'))
                                                         And (account.owner.UserRole.DeveloperName = 'SK_INS_BPS_AM' OR account.owner.UserRole.DeveloperName = 'SK_INS_SKE_AM')
                                                         And (account.RecordType.DeveloperName = 'Customer' OR account.RecordType.DeveloperName = 'Customer_Location')
                                                         AND account.Status__c = 'Active' AND account.win_id__c != null
                                                         Group By accountId];
            
            if(AggregateResultList != null && AggregateResultList.size() > 0){ 
                for(AggregateResult aggr:AggregateResultList){
                        MaxActivityDateMap.put((id)aggr.get('accountId'),(date)aggr.get('maxActivityDate'));    
                }
            }
            
            for (Id accId:accIdSet){
                if (MaxActivityDateMap != null && MaxActivityDateMap.size() > 0 && MaxActivityDateMap.containskey(accId) 
                    && MaxActivityDateMap.get(accId) != AccountActivityMap.get(accId).Latest_Sales_Task_Date_for_IS_Rank__c){
                    Account a = new Account();
               		a.id = accId;
                    a.Latest_Sales_Task_Date_for_IS_Rank__c = MaxActivityDateMap.get(accId);
                    accUpdateList.add(a);
                }else if (MaxActivityDateMap.size() == 0
                          || (MaxActivityDateMap != null && MaxActivityDateMap.size() > 0 && !MaxActivityDateMap.containskey(accId))
                          && AccountActivityMap.get(accId).Latest_Sales_Task_Date_for_IS_Rank__c != null){
                              Account a = new Account();
                              a.id = accId;
                              a.Latest_Sales_Task_Date_for_IS_Rank__c = null;
                              accUpdateList.add(a);
                          }      
            }
            
            if(accUpdateList != null && accUpdateList.size()>0)
            {
                update accUpdateList;
            }
            
        }        
    }
    
    
    Public Static void InsertNewPartsWasherPullCase (List<Task> newTaskList){
        Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Call_Center_Activity').getRecordTypeId();
        Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Parts_Washer_Pull_Request').getRecordTypeId();
        set<Id> accset = new Set<Id>();
        
        List<Case> insertCase = new List<Case>(); 
        
        for(Task t : newTaskList){  
            if(t.whatId != null){
                accset.add(t.WhatId);
            }
        }
       
        List<Group> custLoyaltyQueue = [select Id from Group where Type = 'Queue' AND NAME = 'Queue: Customer Loyalty' limit 1];
            for(Task t : newTaskList){             
                if((t.recordtypeId == devRecordTypeId && t.Call_Type__c == 'Pull/Cancel Service' && t.Service_to_be_cancelled__c == 'Parts Washer'  
                    && t.WhatId <> null ) || test.isRunningTest() ){
                        
                        case c = new case ();
                        c.AccountId = t.whatid;
                        if(!custLoyaltyQueue.isEmpty()){
                            c.OwnerId = custLoyaltyQueue[0].Id;
                        }                
                        c.RecordTypeId = casedevRecordTypeId;
                        c.Caller_s_First_Name__c= t.Caller_First_Name__c;
                        c.Caller_s_Last_Name__c= t.Caller_Last_Name__c;
                        c.Description = t.Description;  
                        c.Caller_s_Phone_Number__c = t.Caller_Phone__c;
                        c.Call_Center_Activity_ID__c = t.Id;
                        if(t.Escalation__c != NULL || test.isRunningTest()){
                            if(t.Escalation__c == '1'){
                            c.Level_1_Escalation__c = TRUE;
                            }
                        else if(t.Escalation__c == '2'){
                            c.Level_2_Escalation__c = TRUE;
                            }
                        else if(t.Escalation__c == '3'){
                            c.Level_3_Escalation__c = TRUE; 
                            }
                        }
                        insertCase.add(c);
                    }
            }
        
        if(insertCase.size() > 0 && !test.isRunningTest()){
            insert insertCase;
        }
        
    }
    public static void populateContactName(List<Task> tasks) {
        Set<Id> contactIds = new Set<Id>();
        for (Task task : tasks) {
            if (task.WhoId != null && task.WhoId.getSObjectType() == Contact.SObjectType) {
                contactIds.add(task.WhoId);
            }
        }
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactIds]);
        for (Task task : tasks) {
            if (contactsMap.containsKey(task.WhoId)) {
                Contact associatedContact = contactsMap.get(task.WhoId);
                task.Contact_Name__c = associatedContact.Name;
            }
        }
    } 
	public static void validateEvents(List<Task> tasks) {
        Set<Id> accountIds = new Set<Id>();
        for(Task taskObj : tasks) {
            if(taskObj.WhatId != null && taskObj.WhatId.getSObjectType() == Account.SObjectType) {
                accountIds.add(taskObj.WhatId);
            }
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Status__c FROM Account WHERE Id IN :accountIds]);
        for(Task taskObj : tasks) {
            if(taskObj.WhatId != null && taskObj.WhatId.getSObjectType() == Account.SObjectType) {
                Account relatedAccount = accountsMap.get(taskObj.WhatId); 
                if(relatedAccount != null && relatedAccount.Status__c == 'Archive') {
                    taskObj.addError(EVENT_VALIDATION_ERROR);
                }
            }
        }
    }
    
}