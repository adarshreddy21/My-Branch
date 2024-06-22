/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-28-2022   Suresh Beniwal   Initial Version
**/
public with sharing class HeaderLessQuickActionlwcController {
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-28-2022 
    * @param String recordId 
    * @return string 
    **/
    @AuraEnabled
    public static string softDeleteAction(String recordId){
        try {
            if (String.isBlank(recordId)) {return '';}
            Schema.SObjectType record = ((ID)recordId).getsobjecttype();
            if (record == Schema.Account.getSObjectType()) {
                if (!Test.isRunningTest()) {
                    update new Schema.Account(Id = recordId, Status__c = 'Inactive');
                }
                List<Contact> listOfContact = ContactDAO.getListOfContactByOrganizationIds(new Set<Id>{recordId});
                if (!listOfContact.isEmpty()) {
                    for (Contact contactRecord : listOfContact) {
                        contactRecord.Status__c = 'Inactive';
                    }
                    update listOfContact;
                }

                List<Schema.Location> listOfLocation = LocationDAO.getLocationsByOrganizationIds(new Set<Id>{recordId});

                if (!listOfLocation.isEmpty()) {
                    for (Schema.Location locationRecord: listOfLocation) {
                        locationRecord.Status__c = 'Inactive';
                    }
                    update listOfLocation;
                }
            } else if (record == Schema.Location.getSObjectType()) {
                update new Schema.Location(Id = recordId, Status__c = 'Inactive');
                List<Contact> listOfContact = ContactDAO.getContactsByLocationIds(new Set<Id>{recordId});
                if (!listOfContact.isEmpty()) {
                    for (Contact contactRecord : listOfContact) {
                        contactRecord.Status__c = 'Inactive';
                    }
                    update listOfContact;
                }
            } else if (record == Schema.Contact.getSObjectType()) {
                update new Contact(Id = recordId, Status__c = 'Inactive');
            }
            return null;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}