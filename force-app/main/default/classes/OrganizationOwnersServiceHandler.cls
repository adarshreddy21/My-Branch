/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-26-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   05-30-2022   Suresh Beniwal   Initial Version
**/
public without sharing class OrganizationOwnersServiceHandler {
    public static String recordType;
    /**
    * @description 
    * @author Suresh Beniwal | 05-30-2022 
    * @param List<Organization_Owners__c> newItems 
    **/
    public static void beforeInsert(List<Organization_Owners__c> newItems) {
        checkNumberOfRelatedRecords(newItems, null);
        checkPotentialDuplicate(newItems, null);
    }

    /**
    * @description 
    * @author Suresh Beniwal | 05-30-2022 
    * @param Map<Id SObject> newItems 
    * @param Map<Id SObject> oldItems 
    **/
    public static void afterInsert(Map<Id, SObject> newItems) {
        
    }

    /**
    * @description 
    * @author Suresh Beniwal | 05-30-2022 
    * @param Map<Id Organization_Owners__c> newItems 
    * @param Map<Id Organization_Owners__c> oldItems 
    **/
    public static void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        checkNumberOfRelatedRecords((List<Organization_Owners__c>) newItems.values(), (Map<Id, Organization_Owners__c>) oldItems);
        checkPotentialDuplicate((List<Organization_Owners__c>)newItems.values(), (Map<Id, Organization_Owners__c>) oldItems);
    }
 

    /**
    * @description 
    * @author Suresh Beniwal | 05-30-2022 
    * @param List<Organization_Owners__c> newItems 
    * @param Map<Id Organization_Owners__c> oldItems 
    **/
    public static void checkNumberOfRelatedRecords(List<Organization_Owners__c> newItems,  Map<Id, Organization_Owners__c> oldItems) {
        Set<Id> setOfOranization = new Set<Id>();
        Map<String, List<Organization_Owners__c>> mapOfRelatedOranizationOwners = new Map<String, List<Organization_Owners__c>>();

        // Adding newly related record to map
        for (Organization_Owners__c organizationOwnerRecord : newItems) {
            if (( organizationOwnerRecord.Owner_Type__c != null && organizationOwnerRecord.User__c !=null && 
                (oldItems == null || 
                (oldItems != null && organizationOwnerRecord.Organization__c != oldItems.get(organizationOwnerRecord.Id).Organization__c)))) {
               
                setOfOranization.add(organizationOwnerRecord.Organization__c);

                if (!mapOfRelatedOranizationOwners.containsKey(organizationOwnerRecord.Organization__c)) {
                    mapOfRelatedOranizationOwners.put(organizationOwnerRecord.Organization__c, new List<Organization_Owners__c>());
                }
                mapOfRelatedOranizationOwners.get(organizationOwnerRecord.Organization__c).add(organizationOwnerRecord);
            }
        }

        if (!mapOfRelatedOranizationOwners.isEmpty()) {

            // Adding existing related Records to the map
            for (Organization_Owners__c organizationOwnerRecord : [
                SELECT Id, Organization__c 
                FROM Organization_Owners__c 
                WHERE Organization__c IN: setOfOranization WITH SECURITY_ENFORCED]) { 

                mapOfRelatedOranizationOwners.get(organizationOwnerRecord.Organization__c).add(organizationOwnerRecord);
            }

            // throwing exception in case multiple records added
            for (Organization_Owners__c organizationOwnerRecord : newItems) {
                if (mapOfRelatedOranizationOwners.containsKey(organizationOwnerRecord.Organization__c) 
                    && mapOfRelatedOranizationOwners.get(organizationOwnerRecord.Organization__c).size() > 3) {
                        
                    organizationOwnerRecord.Organization__c.addError(system.label.Organization_Owners_Size);
                }
            }
        }
    }

    /**
    * @description 
    * @author Suresh Beniwal | 05-30-2022 
    * @param List<Organization_Owners__c> newItems 
    * @param Map<Id Organization_Owners__c> oldItems 
    **/
    public static void checkPotentialDuplicate(List<Organization_Owners__c> newItems,  Map<Id, Organization_Owners__c> oldItems) {
        Set<Id> setOfOranization = new Set<Id>();
        Map<String, Organization_Owners__c> mapOfRelatedOranizationOwners = new Map<String, Organization_Owners__c>();
        String uniqueKey = '';

        for (Organization_Owners__c organizationOwnerRecord : newItems) {
            if ((organizationOwnerRecord.Owner_Type__c != null && organizationOwnerRecord.User__c !=null && (
                oldItems == null || 
                (oldItems != null && (organizationOwnerRecord.Organization__c != oldItems.get(organizationOwnerRecord.Id).Organization__c 
                    || organizationOwnerRecord.Owner_Type__c != oldItems.get(organizationOwnerRecord.Id).Owner_Type__c 
                    || organizationOwnerRecord.User__c != oldItems?.get(organizationOwnerRecord.Id).User__c ))))) {

                setOfOranization.add(organizationOwnerRecord.Organization__c);
            }
        }

        if (!setOfOranization.isEmpty()) {

            // Adding existing related Records to the map
            for (Organization_Owners__c organizationOwnerRecord : [
                SELECT Id, Organization__c, Owner_Type__c, User__c
                FROM Organization_Owners__c 
                WHERE Organization__c IN: setOfOranization WITH SECURITY_ENFORCED]) { 
                
                // Combination of Organization, Owner Type, User
                uniqueKey = organizationOwnerRecord.Organization__c + '-' + organizationOwnerRecord.Owner_Type__c + '-' + organizationOwnerRecord.User__c;
                if (!mapOfRelatedOranizationOwners.containsKey(uniqueKey)) {
                    mapOfRelatedOranizationOwners.put(uniqueKey, organizationOwnerRecord);
                }

                // Combination of Organization, Owner Type
                uniqueKey = organizationOwnerRecord.Organization__c + '-' + organizationOwnerRecord.Owner_Type__c;
                if (!mapOfRelatedOranizationOwners.containsKey(uniqueKey)) {
                    mapOfRelatedOranizationOwners.put(uniqueKey, organizationOwnerRecord);
                }

                // Combination of Organization, User
                uniqueKey = organizationOwnerRecord.Organization__c + '-' + organizationOwnerRecord.User__c;
                if (!mapOfRelatedOranizationOwners.containsKey(uniqueKey)) {
                    mapOfRelatedOranizationOwners.put(uniqueKey, organizationOwnerRecord);
                }
            }

            // throwing exception in case multiple records added
            for (Organization_Owners__c organizationOwnerRecord : newItems) {
                uniqueKey = organizationOwnerRecord.Organization__c + '-' + organizationOwnerRecord.Owner_Type__c + '-' + organizationOwnerRecord.User__c;
                String uniqueKey1 = organizationOwnerRecord.Organization__c + '-' + organizationOwnerRecord.Owner_Type__c;
                // String uniqueKey2 = organizationOwnerRecord.Organization__c + '-' + organizationOwnerRecord.User__c;
                //   ||  mapOfRelatedOranizationOwners.containsKey(uniqueKey2)
                if (mapOfRelatedOranizationOwners.containsKey(uniqueKey) 
                    || mapOfRelatedOranizationOwners.containsKey(uniqueKey1)) {
                    organizationOwnerRecord.Organization__c.addError(system.label.Organization_Owners_Duplicate_Record);
                }
            }
        }
    }
    
    @InvocableMethod(label = 'setHRAccountStatusFromFlow' description = 'This sets the status to Prospect')
    public static void setHRAccountStatusFromFlow(List<SObject> relatedList){
      recordType=CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS;
      setOrgStatusToProspect(relatedList);
    }

    /**
    * @description update the organization status to prospect if required related lists are populated.
    * @author Sravani
    * @param List<SObject> relatedList 
    * 
    **/
     public static void setOrgStatusToProspect(List<SObject> relatedList){
        recordType=CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS;
        set<Id> orgIds = new set<Id>();
        for(SObject obj : relatedList ){
             if(obj.getSObjectType().getDescribe().getName() == CHConstants.CONTACT_OBJNAME){
               orgIds.add((String)obj.get('AccountId'));
             }
             else
             orgIds.add((String)obj.get('Organization__c'));       
         }
        Map<Id,Boolean> mapOrgs = new Map<Id,Boolean>();
        if(orgIds.size() >0 ){
            mapOrgs=checkAllRelatedListsForOrg(orgIds);
        }
        List<Account> updateOrgs = new List<Account>();
        for(String orgId : mapOrgs.keySet()){
            if(mapOrgs.get(orgId)){
                Account acct = new Account(Id = orgId);
                acct.Organization_Status__c	 = CHConstants.ACCOUNT_PROSPECT_STATUS;
                updateOrgs.add(acct);
            }
        }
        Database.update(updateOrgs,false);
    }
    /**
    * @description check if all the related records are present for the org
    * @author Sravani
    * @param Set<Id> setorgnizationIds 
    * 
    **/
    public static Map<Id,Boolean> checkAllRelatedListsForOrg(Set<Id> setOrganizationId){
        Map<Id,Boolean> mapOrgOwners = new Map<Id,Boolean>();
        List<Account> orgs = [Select Id,RecordType.DeveloperName,(select Id, Owner_Type__c  FROM Organization_Owners__r),
        (Select Id FROM Departments__r),(Select Id FROM Organization_Job_Codes__r),
        (Select Id FROM Contacts ), (SELECT Id FROM Locations__r)  FROM Account where Id = :setOrganizationId AND 
        Organization_Status__c = :CHConstants.ACCOUNT_DRAFT_STATUS AND RecordType.DeveloperName = :recordType ];

        for(Account org: orgs){
           if(setOrganizationId.contains(org.id)){
                Integer ownerCount = 0;
                for (Organization_Owners__c ownerRecord : org?.Organization_Owners__r) {
                    if (ownerRecord.Owner_Type__c == 'Partnership Owner' || ownerRecord.Owner_Type__c == 'Contributor' ) {
                        ownerCount = ownerCount + 1;
                    }
                }

               if( ownerCount >= 2 && org.Departments__r.size()>=1 
               && org.Organization_Job_Codes__r.size()>=1 &&  org.Contacts.size()>=1 ){
                mapOrgOwners.put(org.Id , true);
               }else{
                mapOrgOwners.put(org.Id , false);   
               }
           }
        }
           return mapOrgOwners;

    }

}