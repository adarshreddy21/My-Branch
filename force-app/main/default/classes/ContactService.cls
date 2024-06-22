/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-10-2022   Suresh Beniwal   Initial Version
**/
public without sharing class ContactService { 
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-10-2022 
    * @param List<Contact> listOfContact 
    * @return List<ContactWrapper> 
    **/
    public static List<ContactWrapper> getListOfContacts(List<Contact> listOfContact) {
        List<ContactWrapper> listOfContactWrapper = new List<ContactWrapper>();

        for (Contact contactRecord: listOfContact) {
            ContactWrapper contactWrapperRecord = new ContactWrapper();
            contactWrapperRecord.contactId = contactRecord.Contact_Id__c;
            contactWrapperRecord.locationCode = contactRecord.Locations__r.Location_Id__c;
            contactWrapperRecord.organizationCode = contactRecord.Account.Organization_Id__c;
            contactWrapperRecord.name = contactRecord.Name;
            contactWrapperRecord.firstName = contactRecord.FirstName;
            contactWrapperRecord.lastName = contactRecord.LastName;
            contactWrapperRecord.email = contactRecord.Email;
            contactWrapperRecord.phone1 = contactRecord.Phone1__c;
            contactWrapperRecord.phone2 = contactRecord.Phone2__c;
            contactWrapperRecord.type1 = contactRecord.Type1__c;
            contactWrapperRecord.type2 = contactRecord.Type2__c;
            contactWrapperRecord.contactType = contactRecord.Org_Contact_Type__c;
            contactWrapperRecord.contactStatus = contactRecord.Contact_Status__c;
            contactWrapperRecord.executiveSponsor = contactRecord.Executive_Sponsor__r.Name;
            contactWrapperRecord.contributor = contactRecord.Contributor__r.Name;
            contactWrapperRecord.partnershipOwner = contactRecord.Partnership_Owner__r.Name;
            contactWrapperRecord.status = contactRecord.Status__c;
            contactWrapperRecord.location = contactRecord.Locations__r.Name;
            contactWrapperRecord.organizationName = contactRecord.Account.Name;

            listOfContactWrapper.add(contactWrapperRecord);
        }

        return listOfContactWrapper;
    }

    public class ContactWrapper {
        @AuraEnabled public String contactId;
        @AuraEnabled public String locationCode;
        @AuraEnabled public String organizationCode;
        @AuraEnabled public String name;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone1;
        @AuraEnabled public String phone2;
        @AuraEnabled public String type1;
        @AuraEnabled public String type2;
        @AuraEnabled public String contactType;
        @AuraEnabled public String contactStatus;
        @AuraEnabled public String executiveSponsor;
        @AuraEnabled public String contributor;
        @AuraEnabled public String partnershipOwner;
        @AuraEnabled public String status;
        @AuraEnabled public String location;
        @AuraEnabled public String organizationName;
    }
}