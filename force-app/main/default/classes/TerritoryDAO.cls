public without sharing class TerritoryDAO {
 	public static List<Territory__c> getUserTerritoryDetails(Set<String> userTerritory) {
        return [
            SELECT Id, Name, Territory_OwnerID__c, Territory_Type__c, Territory_Language__c
                FROM Territory__c
                WHERE Name IN :userTerritory
        ];
    }
}