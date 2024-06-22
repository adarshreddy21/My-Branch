/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-18-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-09-2022   Suresh Beniwal   Initial Version
**/
public without sharing class OwnershipDAO {
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @param Set<Id> setOfId 
    * @return List<Organization_Owners__c> 
    **/
    public static List<Organization_Owners__c> getListOfOwnershipByOrganizationIds(Set<Id> setOfId) {
        return [
            SELECT Id, Name, Owner_Type__c, User__r.Name, Organization__r.Name, Organization__r.Organization_Id__c 
            FROM Organization_Owners__c 
            WHERE Organization__c IN: setOfId AND Organization__c != null 
            ORDER BY LastModifiedDate DESC
        ];
    }
}