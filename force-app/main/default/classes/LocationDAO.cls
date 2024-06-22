/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-28-2022   Suresh Beniwal   Initial Version
**/
public with sharing class LocationDAO {
    public static Id hrTalentPoolsContactRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();

    /**
    * @description 
    * @author Suresh Beniwal | 06-28-2022 
    * @param Set<Id> setOfId 
    * @return List<Schema.Location> 
    **/
    public static List<Schema.Location> getLocationsBySetOfId(Set<Id> setOfId) {
        return [
            SELECT Id, Name, Location_Id__c, Organization__c, Name__c, Location_Phone_Number__c , Address__c, Status__c, Organization__r.Name, Organization__r.Organization_Id__c,
                Address__Street__s, Address__PostalCode__s, Address__City__s, Address__StateCode__s, Address__CountryCode__s, Size_of_Candidate_Pool__c, Number_of_Hires__c
            FROM Location 
            WHERE Id IN: setOfId AND Organization__c != null 
                AND Organization__r.RecordTypeId =: hrTalentPoolsContactRecordType ORDER BY LastModifiedDate DESC NULLS FIRST];
    }

    /**
    * @description 
    * @author Suresh Beniwal | 07-01-2022 
    * @param Set<Id> setOfId 
    * @return List<Schema.Location> 
    **/
    public static List<Schema.Location> getLocationsByOrganizationIds(Set<Id> setOfId) { 
        return [
            SELECT Id, Name, Location_Id__c, Organization__c, Name__c, Location_Phone_Number__c , Address__c, Status__c, Organization__r.Name, Organization__r.Organization_Id__c,
                Address__Street__s, Address__PostalCode__s, Address__City__s, Address__StateCode__s, Address__CountryCode__s, Size_of_Candidate_Pool__c, Number_of_Hires__c
            FROM Location 
            WHERE Organization__c IN: setOfId AND Organization__c != null 
                AND Organization__r.RecordTypeId =: hrTalentPoolsContactRecordType ORDER BY LastModifiedDate DESC NULLS FIRST];
    }
}