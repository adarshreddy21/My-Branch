public class UpdateAccountTerritoryBatchHandler {
    public static Set<Id> updateAccountTerritory(List<Account> corporateAccountLst, Boolean isParent){
        Id currentUserId = UserInfo.getUserId();
        User userRec = [
            SELECT Id, Sales_Person_Type__c, Profile.Name, Territory__c
            FROM User
            WHERE Id =:currentUserId
        ];   
        
        List<Territory__c> territorys;
        if(userRec.Territory__c != NULL){ 
           territorys = [
                SELECT Id, Territory_OwnerID__c
                FROM Territory__c
                WHERE Name = :userRec.Territory__c
                LIMIT 1
            ];
        }
        
        Map<Id, List<Account>> nonSalesPersonFilteredAccountMap = new Map<Id, List<Account>>();
        
        for(Account newAccRecord : corporateAccountLst){
            if(nonSalesPersonFilteredAccountMap.containsKey(newAccRecord.ZIP_Master__c)){
                nonSalesPersonFilteredAccountMap.get(newAccRecord.ZIP_Master__c).add(newAccRecord);
            }else{
                nonSalesPersonFilteredAccountMap.put(newAccRecord.ZIP_Master__c, new List<Account>{newAccRecord});
            }
        }
        
        List<Territory_Master__c> territoryLst = [
            SELECT Id, ZIP_Master__c, Territory_ID__r.Territory_OwnerID__c, Sales_Business_Unit__c, Name, Territory_ID__c
            FROM Territory_Master__c
            WHERE (
                ZIP_Master__c IN :nonSalesPersonFilteredAccountMap.keySet()
            )
        ];
        
        List<Account> updatedAccount = new List<Account>();
        for(Territory_Master__c territoryRec : territoryLst){
            if(nonSalesPersonFilteredAccountMap.containsKey(territoryRec.ZIP_Master__c)){
                for(Account accountRec : nonSalesPersonFilteredAccountMap.get(territoryRec.ZIP_Master__c)){
                    if(((accountRec.Primary_Service_Provider_New__c == 'SK ENV' || accountRec.Primary_Service_Provider_New__c == 'SK BPS')
                        && (territoryRec.Sales_Business_Unit__c == accountRec.Primary_Business__c ))
                       && !territoryRec.Name.endsWith('IS')){
                           
                           if(territoryRec.Territory_ID__c != NULL && territoryRec.Territory_ID__r.Territory_OwnerID__c != NULL
                              && userRec.Sales_Person_Type__c != 'Senior Account Manager' && userRec.Sales_Person_Type__c != 'Account Manager'){
                                  System.debug('territoryRec.Territory_ID__c ' + territoryRec.Territory_ID__c);
                                  accountRec.OwnerId = territoryRec.Territory_ID__r.Territory_OwnerID__c;
                                  accountRec.Territory_Override__c = True;
                                  updatedAccount.add(accountRec);
                              }else if(territorys.size() > 0){
                                  accountRec.OwnerId = UserInfo.getUserId();
                                  accountRec.Territory_Override__c = True;
                                  updatedAccount.add(accountRec);
                              }
                           
                       }
                }
            }
        }
        
        Set<Id> corporateAccountIdsSet = new Set<Id>();
        if(updatedAccount.size() > 0){
       		List<Database.SaveResult> saveResultLst = Database.update(updatedAccount, false);
            
            for (Database.SaveResult sr : saveResultLst) {
                if (sr.isSuccess()) {
                    if(isParent)
                    	corporateAccountIdsSet.add(sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    
    	return corporateAccountIdsSet;
    }
}