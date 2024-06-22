/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-09-2022   Suresh Beniwal   Initial Version
**/
public without sharing class JobCodeDAO { 
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @param Set<Id> setOfId 
    * @return List<Organization_Job_Code__c> 
    **/
    public static List<Organization_Job_Code__c> getListOfJobCodeByOrganizationIds(Set<Id> setOfId) {
        return [
            SELECT Id, Name, Job_Category_Group__c, Sub_Group__c, Organization__r.Name, Location__c, Location__r.Name, Location__r.Location_Id__c, Organization__r.Organization_Id__c 
            FROM Organization_Job_Code__c 
            WHERE Organization__c != null AND Organization__c IN: setOfId ORDER BY LastModifiedDate DESC NULLS FIRST
        ];
    }

    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @param String optionValue 
    * @return List<Organization_Job_Code__c> 
    **/
    public static List<Organization_Job_Code__c> dynamicQueryGetListOfJobCodeByOrganizationIds(List<String> optionValue) {
         return Database.query('SELECT Id, Organization__c, Location__r.Location_Id__c, Organization__r.Organization_Id__c FROM Organization_Job_Code__c WHERE Job_Category_Group__c  != null AND Job_Category_Group__c IN: optionValue ORDER BY LastModifiedDate DESC');  
    }

    /**
    * @description 
    * @author Suresh Beniwal | 07-21-2022 
    * @param Set<Id> setOfId 
    * @param List<String> optionValue 
    * @return List<Organization_Job_Code__c> 
    **/
    public static List<Organization_Job_Code__c> getDynamicListOfJobCodeByOrganizationIds(Set<Id> setOfId, List<String> optionValue) {
        String dynamicQuery = 'SELECT Id, Name, Job_Category_Group__c, Sub_Group__c, Organization__r.Name, Location__c, Location__r.Name, Location__r.Location_Id__c, Organization__r.Organization_Id__c ' +
            ' FROM Organization_Job_Code__c ' +
            ' WHERE Organization__c != null AND Organization__c IN: setOfId ORDER BY LastModifiedDate DESC NULLS FIRST ';

         if (!optionValue.isEmpty()) {
            dynamicQuery = 'SELECT Id, Name, Job_Category_Group__c, Sub_Group__c, Organization__r.Name, Location__c, Location__r.Name, Location__r.Location_Id__c, Organization__r.Organization_Id__c ' +
            ' FROM Organization_Job_Code__c ' +
            ' WHERE Organization__c != null AND Organization__c IN: setOfId AND Job_Category_Group__c  != null AND Job_Category_Group__c IN: optionValue ' +
            ' ORDER BY LastModifiedDate DESC NULLS FIRST ';
        } 

        System.debug('setOfId : ' + setOfId);
        System.debug('optionValue : ' + optionValue);
        System.debug('dynamicQuery : ' + dynamicQuery);
        return Database.query(dynamicQuery);
    }
}