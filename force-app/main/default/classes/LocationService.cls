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
public without sharing class LocationService { 
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-10-2022 
    * @param List<Schema.Location> listOfLocations 
    * @return List<LocationWrapper> 
    **/
    public static List<LocationWrapper> getListOfLocations(List<Schema.Location> listOfLocations) {
        List<LocationWrapper> listOfLocationWrapper = new List<LocationWrapper>();

        for (Schema.Location locationRecord: listOfLocations) {
            LocationWrapper locationWrapperRecord = new LocationWrapper();
            locationWrapperRecord.locationCode = locationRecord.Location_Id__c;
            locationWrapperRecord.locationName = locationRecord.Name__c;
            locationWrapperRecord.locationPhoneNumber = locationRecord.Location_Phone_Number__c;
            locationWrapperRecord.status = locationRecord.Status__c;
            locationWrapperRecord.sizeOfCandidatePool = locationRecord.Size_of_Candidate_Pool__c;
            locationWrapperRecord.numberOfHires = locationRecord.Number_of_Hires__c;
            locationWrapperRecord.organizationName = locationRecord.Organization__r.Name;
            locationWrapperRecord.organizationCode = locationRecord.Organization__r.Organization_Id__c;
            locationWrapperRecord.address = locationRecord.Address__Street__s != null ? (locationRecord.Address__Street__s + ' , ' + locationRecord.Address__City__s + ' , ' + locationRecord.Address__StateCode__s + ' , ' + locationRecord.Address__CountryCode__s + ' ' + locationRecord.Address__PostalCode__s) : '';
            locationWrapperRecord.street = locationRecord.Address__Street__s;
            locationWrapperRecord.city = locationRecord.Address__City__s;
            locationWrapperRecord.state = locationRecord.Address__StateCode__s;
            System.Address address = locationRecord.Address__c;
            locationWrapperRecord.country = address?.country;
            locationWrapperRecord.zipcode = locationRecord.Address__PostalCode__s;

            listOfLocationWrapper.add(locationWrapperRecord);
        }

        return listOfLocationWrapper;
    }

    public class LocationWrapper {
        @AuraEnabled public String locationCode;
        @AuraEnabled public String organizationCode;
        @AuraEnabled public String locationName;
        @AuraEnabled public String locationPhoneNumber;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal sizeOfCandidatePool;
        @AuraEnabled public Decimal numberOfHires;
        @AuraEnabled public String organizationName;
        @AuraEnabled public String address;
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String country;
        @AuraEnabled public String zipcode;
    }
}