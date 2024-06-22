/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-24-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-24-2022   Suresh Beniwal   Initial Version
**/
public with sharing class LocationServiceHandler {
    public static Id hrTalentPoolsLocationRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
    
    /**
    * @description 
    * @author Suresh Beniwal | 08-24-2022 
    * @param List<Schema.Location> listOfLocation 
    * @param Map<Id Schema.Location> oldMap 
    **/
    public static void duplicateValidation(List<Schema.Location> listOfLocation, Map<Id, Schema.Location> oldMap) {
        DuplicateValidationWrapper duplicateWrapperInstance = new DuplicateValidationWrapper();
        for (Schema.Location locationRecord : listOfLocation) {
            if (oldMap == null || (
                oldMap != null && (
                locationRecord.Name != oldMap.get(locationRecord.Id).Name
                || locationRecord.Address__City__s != oldMap.get(locationRecord.Id).Address__City__s
                || locationRecord.Address__StateCode__s != oldMap.get(locationRecord.Id).Address__StateCode__s
                || locationRecord.Address__CountryCode__s != oldMap.get(locationRecord.Id).Address__CountryCode__s
                || locationRecord.Address__Street__s != oldMap.get(locationRecord.Id).Address__Street__s
                || locationRecord.Address__PostalCode__s != oldMap.get(locationRecord.Id).Address__PostalCode__s
                || locationRecord.Organization__c != oldMap.get(locationRecord.Id).Organization__c
                ))) {

                duplicateWrapperInstance.setOfName.add(locationRecord.Name);
                duplicateWrapperInstance.setOfCity.add(locationRecord.Address__City__s);
                duplicateWrapperInstance.setOfState.add(locationRecord.Address__StateCode__s);
                duplicateWrapperInstance.setOfCountry.add(locationRecord.Address__CountryCode__s);
                duplicateWrapperInstance.setOfStreet.add(locationRecord.Address__Street__s);
                duplicateWrapperInstance.setOfPostalCode.add(locationRecord.Address__PostalCode__s);
                duplicateWrapperInstance.setOfOrganizationName.add(locationRecord.Organization__c);
            }
        }

        if (duplicateWrapperInstance != null && !duplicateWrapperInstance.setOfCity.isEmpty()) {
            Map<String, Schema.Location> mapOfLocation = new Map<String, Schema.Location>();
            for (Schema.Location locationRecord : [
                SELECT Id, Name, Address__Street__s, Address__City__s, Address__StateCode__s, Address__CountryCode__s, Address__PostalCode__s, 
                    Organization__c
                FROM Location
                WHERE Organization__r.RecordTypeId =: hrTalentPoolsLocationRecordType
                    AND Name IN: duplicateWrapperInstance.setOfName
                    AND Address__City__s IN: duplicateWrapperInstance.setOfCity
                    AND Address__StateCode__s IN: duplicateWrapperInstance.setOfState
                    AND Address__CountryCode__s IN: duplicateWrapperInstance.setOfCountry
                    AND Address__Street__s IN: duplicateWrapperInstance.setOfStreet
                    AND Address__PostalCode__s IN: duplicateWrapperInstance.setOfPostalCode
                    AND Organization__c IN: duplicateWrapperInstance.setOfOrganizationName]) {

                String key = locationRecord.Name + locationRecord.Address__Street__s + locationRecord.Address__City__s 
                        + locationRecord.Address__StateCode__s + locationRecord.Address__CountryCode__s + locationRecord.Address__PostalCode__s
                        + locationRecord.Organization__c;
                key = key.toLowerCase();
                mapOfLocation.put(key, locationRecord);
            }

            for(Schema.Location locationRecord : listOfLocation) { 
                String key = locationRecord.Name + locationRecord.Address__Street__s + locationRecord.Address__City__s 
                        + locationRecord.Address__StateCode__s + locationRecord.Address__CountryCode__s + locationRecord.Address__PostalCode__s
                        + locationRecord.Organization__c;
                key = key.toLowerCase();
                if (locationRecord.Organization__c != null  && mapOfLocation.containsKey(key)) {
                    locationRecord.addError('Duplicate Location Exist with record Id ' + mapOfLocation.get(key).Id);
                }
            }
        }
    }

    /**
    * @description 
    * @author Suresh Beniwal | 08-24-2022 
    * @param List<Schema.Location> listOfLocation 
    * @param Map<Id Schema.Location> oldMap 
    **/
    public static void updateLocationPhoneOnContact(List<Schema.Location> listOfLocation, Map<Id, Schema.Location> oldMap) {
        Map<Id, String> mapOfLocationPhone = new Map<Id, String>();

        for (Schema.Location locationRecord : listOfLocation) {
            if (locationRecord.Location_Phone_Number__c != null && (oldMap == null || (oldMap != null 
                && locationRecord.Location_Phone_Number__c != oldMap.get(locationRecord.Id).Location_Phone_Number__c))) {

                mapOfLocationPhone.put(locationRecord.Id, locationRecord.Location_Phone_Number__c);
            }
        }

        if (!mapOfLocationPhone.isEmpty()) {
            List<Contact> listOfContactUpdate = new List<Contact>();

            for (Contact contactRecord : ContactDAO.getContactsByLocationIds(mapOfLocationPhone.keySet())) {
                String oldPhoneValue = oldMap.get(contactRecord.Locations__c).Location_Phone_Number__c;
                if (contactRecord.Phone1__c == null || contactRecord.Phone1__c == oldPhoneValue) {
                    contactRecord.Phone1__c = mapOfLocationPhone.get(contactRecord.Locations__c);
                    contactRecord.Type1__c = 'Office';
                    listOfContactUpdate.add(contactRecord);
                }
            }

            if (!listOfContactUpdate.isEmpty()) {
                Database.update(listOfContactUpdate, false);
            }
        }
    }

    public class DuplicateValidationWrapper {
        public Set<String> setOfName = new Set<String>();
        public Set<String> setOfCity = new Set<String>();
        public Set<String> setOfState = new Set<String>();
        public Set<String> setOfCountry = new Set<String>();
        public Set<String> setOfStreet = new Set<String>();
        public Set<String> setOfPostalCode = new Set<String>();
        public Set<String> setOfOrganizationName = new Set<String>();
    }
}