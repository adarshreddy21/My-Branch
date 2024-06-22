/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-09-2022   Suresh Beniwal   Initial Version
**/
public without sharing class ContactDAO { 
    public static Id hrTalentPoolsContactRecordType = Schema.Sobjecttype.Contact.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
    
    /**
    * @description
    * @author Suresh Beniwal | 06-09-2022 
    * @param Set<Id> setOfId 
    * @return List<Contact> 
    **/
    public static List<Contact> getListOfContactByOrganizationIds(Set<Id> setOfId) {
        
        return [
            SELECT Id, AccountId, LastName, FirstName, Name, Email, Status__c,
            Contact_Status__c, Contact_Title__c, Account.Name, Locations__c, Locations__r.Name, Locations__r.Location_Id__c,
            Contributor__c, Partnership_Owner__c, Executive_Sponsor__c, Contributor__r.Name,  Partnership_Owner__r.Name,
            Executive_Sponsor__r.Name, Contact_Id__c, Account.Organization_Id__c,
            Type1__c, Type2__c, Phone2__c, Phone1__c, Org_Contact_Type__c
            FROM Contact 
            WHERE AccountId != null AND AccountId IN: setOfId
                AND RecordTypeId =: hrTalentPoolsContactRecordType ORDER BY LastModifiedDate DESC NULLS FIRST
        ];
    }
    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @param Set<Id> setOfId 
    * @return List<Contact> 
    **/
    public static List<Contact> getContactsByLocationIds(Set<Id> setOfId) {
        
        return [
            SELECT Id, Locations__c,AccountId, LastName, FirstName, Name, Email, Status__c,
            Contact_Status__c, Contact_Title__c, Account.Name,Locations__r.Name, Contributor__c, Locations__r.Location_Id__c,
            Partnership_Owner__c, Executive_Sponsor__c, Contributor__r.Name,  Partnership_Owner__r.Name, Executive_Sponsor__r.Name, 
            Type1__c, Type2__c, Phone2__c, Phone1__c, Org_Contact_Type__c, Contact_Id__c, Account.Organization_Id__c
            FROM Contact 
            WHERE Locations__c != null AND Locations__c IN: setOfId
                AND RecordTypeId =: hrTalentPoolsContactRecordType ORDER BY LastModifiedDate DESC NULLS FIRST
        ];
    }

    /**
    * @description 
    * @author Suresh Beniwal | 07-21-2022 
    * @param Set<Id> setOfContactIds 
    * @return List<Contact> 
    **/
    public static List<Contact> getListOfContactWithAccountByIds(Set<Id> setOfContactIds) {
        return [
            SELECT Id, Account.Name, Contact_Id__c, Account.Organization_Id__c, Locations__r.Location_Id__c, Locations__r.Name__c
            FROM Contact 
            WHERE AccountId != NULL AND Id IN: setOfContactIds
            ORDER BY LastModifiedDate DESC
        ];
    }

    /**
    * @description 
    * @author Raghav Kumar | 10-18-2022 
    * @param Set<String> emails 
    * @return List<Contact> 
    **/
    public static List<Contact> getContactsByEmail(Set<String> emails) {
        return [
            SELECT Id, FirstName, LastName
            FROM Contact 
            WHERE Email in :emails
        ];
    }

    public static List<Contact> getContactsByAccountIdsAndEmails(Set<String> emailstoVerify, Set<Id> accIdsToVerify) {
        return [
            SELECT Id, Email, AccountId from Contact 
            WHERE AccountId in :accIdsToVerify and Email in :emailstoVerify and Expired__c = false
        ];
    }
}