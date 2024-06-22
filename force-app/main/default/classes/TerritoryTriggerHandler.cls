public class TerritoryTriggerHandler {

    public static void updateAccountOwner(List<Territory__c> newList, Map<Id, Territory__c> oldMap){
        
        Set<Id> terrIds = new Set<Id>();
        
        for(Territory__c terr : newList){
            
            if(terr.Territory_OwnerID__c != oldMap.get(terr.Id).Territory_OwnerID__c){
                terrIds.add(terr.Id);
            }
        }
        
        if(!terrIds.isEmpty() && terrIds.size() > 0){
            
            TerritoryOwnerUpdateBatch batchObj = new TerritoryOwnerUpdateBatch(terrIds);
            Database.executeBatch(batchObj, 50);
        }
    }
}