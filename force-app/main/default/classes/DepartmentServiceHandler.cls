/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-12-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-28-2022   Suresh Beniwal   Initial Version
**/
public with sharing class DepartmentServiceHandler {
    /**
    * @description 
    * @author Suresh Beniwal | 06-28-2022 
    * @param List<Organization_Department__c> listOfSobject 
    **/
    public static void updateOrganization(List<Organization_Department__c> listOfSobject) {
        Map<Id, Schema.Location> mapOfLocation = new Map<Id, Schema.Location>();
        for (Organization_Department__c sobjectRecord: listOfSobject) {
            if (sobjectRecord.Location__c != null) {
                mapOfLocation.put(sobjectRecord.Location__c, null);
            }
        }

        mapOfLocation = new Map<Id, Schema.Location>(LocationDAO.getLocationsBySetOfId(mapOfLocation.keySet()));

        for (Organization_Department__c sobjectRecord: listOfSobject) {
            String organizationLocation = sobjectRecord.Location__c != null && mapOfLocation.get(sobjectRecord.Location__c) != null ? mapOfLocation.get(sobjectRecord.Location__c).Organization__c : null;
            if (sobjectRecord.Organization__c == null && mapOfLocation.containsKey(sobjectRecord.Location__c) && mapOfLocation.get(sobjectRecord.Location__c) != null) {
                sobjectRecord.Organization__c = mapOfLocation.get(sobjectRecord.Location__c).Organization__c;
            }

            if (organizationLocation != null && organizationLocation != sobjectRecord.Organization__c) {
                sobjectRecord.addError('Location is not associated with the selected Organization');
            }
        }
    }
}