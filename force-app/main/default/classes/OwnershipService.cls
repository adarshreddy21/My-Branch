/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 07-27-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-10-2022   Suresh Beniwal   Initial Version
**/
public without sharing class OwnershipService {

    /**
    * @description 
    * @author Suresh Beniwal | 06-10-2022 
    * @param List<Organization_Owners__c> listOfOwnerships 
    * @return List<OwnershipWrapper> 
    **/
    public static List<OwnershipWrapper> getListOfOwnerships(List<Organization_Owners__c> listOfOwnerships) {
        List<OwnershipWrapper> listOfOwnershipWrapper = new List<OwnershipWrapper>();
        Map<Id, List<Organization_Owners__c>> mapOfOrganizationOwners = new Map<Id, List<Organization_Owners__c>>();

        for (Organization_Owners__c ownershipRecord: listOfOwnerships) {
            if (!mapOfOrganizationOwners.containsKey(ownershipRecord.Organization__c)) {
                mapOfOrganizationOwners.put(ownershipRecord.Organization__c, new List<Organization_Owners__c>());
            }
            mapOfOrganizationOwners.get(ownershipRecord.Organization__c).add(ownershipRecord);
        }

        for (String key: mapOfOrganizationOwners.keySet()) {
            OwnershipWrapper ownershipWrapperRecord = new OwnershipWrapper();
            for (Organization_Owners__c ownershipRecord : mapOfOrganizationOwners.get(key)) {
                ownershipWrapperRecord.organizationId = ownershipRecord.Organization__r.Organization_Id__c;

                if (ownershipRecord.Owner_Type__c == 'Executive Sponsor') {
                    ownershipWrapperRecord.executiveId = ownershipRecord.Name;
                    ownershipWrapperRecord.executive = ownershipRecord.User__r.Name;
                } else if (ownershipRecord.Owner_Type__c == 'Partnership Owner') {
                    ownershipWrapperRecord.partnershipId = ownershipRecord.Name;
                    ownershipWrapperRecord.partnership = ownershipRecord.User__r.Name;
                } else if (ownershipRecord.Owner_Type__c == 'Contributor') {
                    ownershipWrapperRecord.contributerId = ownershipRecord.Name;
                    ownershipWrapperRecord.contributer = ownershipRecord.User__r.Name;
                }
                ownershipWrapperRecord.organizationName = ownershipRecord.Organization__r.Name;
            }
            listOfOwnershipWrapper.add(ownershipWrapperRecord);
        }

        return listOfOwnershipWrapper;
    }

    public class OwnershipWrapper {
        @AuraEnabled public String organizationId;
        @AuraEnabled public String executiveId;
        @AuraEnabled public String executive;
        @AuraEnabled public String partnershipId;
        @AuraEnabled public String partnership;
        @AuraEnabled public String contributerId;
        @AuraEnabled public String contributer;
        @AuraEnabled public String organizationName;
    }
}