/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-14-2022   Suresh Beniwal   Initial Version
**/
public without sharing class TaskService { 
    /**
    * @description 
    * @author Suresh Beniwal | 07-14-2022 
    * @param Set<Id> setOfAccountId 
    * @return List<TaskWrapper> 
    **/
    public static List<TaskWrapper> getTaskDetails(Set<Id> setOfAccountId) {
        Map<String, Task> mapOfContactTask = new Map<String, Task>();
        Map<String, String> mapOfUniqueTask = new Map<String, String>();
        Map<Id, Sobject> mapOfContactIdWithAccountName = new Map<Id, Sobject>();
        List<TaskWrapper> listOfTasks = new List<TaskWrapper>();
        Set<Id> setOfContactId = new Set<Id>();
        Set<Id> setOfContactIds = new Set<Id>();

        for (Contact contactRecord : ContactDAO.getListOfContactByOrganizationIds(setOfAccountId)) {
            setOfContactId.add(contactRecord.Id);
        }

        for (Account accountRecord : AccountDao.getAccountsByIdSet(setOfAccountId)) {
            mapOfContactIdWithAccountName.put(accountRecord.Id, accountRecord);
        }
        

        for (Task taskRecord : TaskDAO.getContactActivities(setOfContactId)) {
            if (!mapOfContactTask.containsKey(taskRecord.WhoId)) {
                if (!mapOfUniqueTask.containsKey(taskRecord.Id)) {
                    mapOfUniqueTask.put(taskRecord.Id, taskRecord.Id);
                    mapOfContactTask.put(taskRecord.WhoId, taskRecord);
                    setOfContactIds.add(taskRecord.WhoId);
                }
            }
        }

        for (Task taskRecord : TaskDAO.getAccountActivities(setOfAccountId)) {
            if (taskRecord.WhoId == null && !mapOfContactTask.containsKey(taskRecord.WhatId)) {
                if (!mapOfUniqueTask.containsKey(taskRecord.Id)) {
                    mapOfUniqueTask.put(taskRecord.Id, taskRecord.Id);
                    mapOfContactTask.put(taskRecord.WhatId, taskRecord);
                }
            }
        }

        for (Contact contactRecord: ContactDAO.getListOfContactWithAccountByIds(setOfContactIds)) {
            mapOfContactIdWithAccountName.put(contactRecord.Id, contactRecord);
        }

        
        for (Task taskRecord : mapOfContactTask.values()) {
            
            TaskWrapper taskWrapperRecord = new TaskWrapper();
            if (mapOfContactTask.containsKey(taskRecord.WhoId)) {
                Contact contactRecord = (Contact) mapOfContactIdWithAccountName.get(taskRecord.WhoId);
                taskWrapperRecord.organizationId = contactRecord.Account.Organization_Id__c;
                taskWrapperRecord.relatedName = taskRecord.What?.Type == 'Account' ? contactRecord.Account.Name : contactRecord.Account.Name;
                taskWrapperRecord.contactId = contactRecord.Contact_Id__c;
                taskWrapperRecord.relatedContactName = taskRecord.Who.Name;
            } else if (mapOfContactTask.containsKey(taskRecord.WhatId)) {
                Account accountRecord = (Account) mapOfContactIdWithAccountName.get(taskRecord.WhatId);
                taskWrapperRecord.organizationId = accountRecord.Organization_Id__c;
                taskWrapperRecord.relatedName = taskRecord.What.Name;
            }
            taskWrapperRecord.subject = taskRecord.Subject;
            taskWrapperRecord.type = taskRecord.Type;
            taskWrapperRecord.subtype = taskRecord.TaskSubtype;
            taskWrapperRecord.description = taskRecord.Description;
            taskWrapperRecord.status = taskRecord.Status;
            taskWrapperRecord.createdDate = taskRecord.CreatedDate;
		    taskWrapperRecord.DepartmentId = taskRecord.Department__r.Name;
            taskWrapperRecord.JobCategory = taskRecord.Job_Categories__r.Job_Category_Group__c;
            taskWrapperRecord.locationName = taskRecord.Location__r.Name;
            taskWrapperRecord.locationCode = taskRecord.Location__r.Location_Id__c;

            listOfTasks.add(taskWrapperRecord);
        }

        return listOfTasks;
    }

    public class TaskWrapper {
        @AuraEnabled public String organizationId;
        @AuraEnabled public String locationCode;
        @AuraEnabled public String locationName;
        @AuraEnabled public String relatedName;
        @AuraEnabled public String contactId;
        @AuraEnabled public String relatedContactName;
        @AuraEnabled public String subject;
        @AuraEnabled public String type;
        @AuraEnabled public String subtype;
        @AuraEnabled public String description;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String status;
        @AuraEnabled public String DepartmentId;
        @AuraEnabled public String JobCategory;
    }
}