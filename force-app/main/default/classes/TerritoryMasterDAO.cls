public without sharing class TerritoryMasterDAO {
	public static List<Territory_Master__c> getTerritoryMasterBasedonZipMaster(Set<Id> zipMasterIds) {
        return [
           SELECT Id, ZIP_Master__c, Territory_ID__r.Territory_OwnerID__c,Territory_ID__r.Territory_Type__c, Sales_Business_Unit__c, Name, Territory_ID__c
                FROM Territory_Master__c
                WHERE ZIP_Master__c IN :zipMasterIds
        ];
    }
}