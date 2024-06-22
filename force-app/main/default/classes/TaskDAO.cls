/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-18-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-14-2022   Suresh Beniwal   Initial Version
**/
public without sharing class TaskDAO {
    /**
    * @description 
    * @author Suresh Beniwal | 07-14-2022 
    * @param Set<Id> setOfContactId 
    * @return List<Task> 
    **/
    public static List<Task> getContactActivities(Set<Id> setOfContactId) {
        return [
            SELECT Id, WhoId, Who.Name, Subject, WhatId, What.Name, What.Type, Status, Priority, 
                Description, Type, CallType, CallDisposition, TaskSubtype, CreatedDate,
				Department__r.Name,Job_Categories__r.Job_Category_Group__c,Location__r.Location_Id__c,Location__r.Name
            FROM Task 
            WHERE WhoId != NULL AND WhoId IN: setOfContactId
                ORDER BY LastModifiedDate DESC
        ];
    }

    /**
    * @description 
    * @author Suresh Beniwal | 07-18-2022 
    * @param Set<Id> setOfAccountId 
    * @return List<Task> 
    **/
    public static List<Task> getAccountActivities(Set<Id> setOfAccountId) {
        return [
            SELECT Id, WhoId, Who.Name, Subject, WhatId, What.Name, What.Type, Status, Priority, 
                Description, Type, CallType, CallDisposition, TaskSubtype, CreatedDate,
                Department__r.Name,Job_Categories__r.Job_Category_Group__c,Location__r.Location_Id__c,Location__r.Name				
            FROM Task 
            WHERE WhatId != NULL AND WhatId IN: setOfAccountId
                ORDER BY LastModifiedDate DESC
        ];
    }
}