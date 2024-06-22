public class ProspectAccountActivationHandler {
	@InvocableMethod
    public static void updateProspectAccountActivationOwner(List<Account> accountLst){
        Map<Id, List<Account>> ISAMFilteredAccountMap = new Map<Id, List<Account>>();
        
        for(Account accRec : accountLst){
            if(accRec.ZIP_Master__c != NULL && (accRec.Primary_Service_Provider_New__c == 'SK ENV' || accRec.Primary_Service_Provider_New__c == 'SK BPS')){
                if(ISAMFilteredAccountMap.containsKey(accRec.ZIP_Master__c)){
                	ISAMFilteredAccountMap.get(accRec.ZIP_Master__c).add(accRec);
                }else{
                    ISAMFilteredAccountMap.put(accRec.ZIP_Master__c, new List<Account>{accRec});
                }
            }
        }
        
        List<Territory_Master__c> territoryLst = [
        	SELECT Id, ZIP_Master__c, Territory_ID__r.Territory_OwnerID__c, Sales_Business_Unit__c, Name, Territory_ID__c
            FROM Territory_Master__c
            WHERE (
                ZIP_Master__c IN :ISAMFilteredAccountMap.keySet()
                AND (
                    Sales_Business_Unit__c = 'BPS'
                    OR Sales_Business_Unit__c = 'Safety-Kleen'
                )
            )
            AND Territory_ID__r.Territory_OwnerID__c != NULL
        ];
        
        List<Account> updatedAccountLst = new List<Account>();
        for(Territory_Master__c territoryRec : territoryLst){
            if(ISAMFilteredAccountMap.containsKey(territoryRec.ZIP_Master__c)){
                for(Account accountRec : ISAMFilteredAccountMap.get(territoryRec.ZIP_Master__c)){
                    if(((territoryRec.Sales_Business_Unit__c == 'BPS' && accountRec.Primary_Service_Provider_New__c == 'SK BPS')
                      || (territoryRec.Sales_Business_Unit__c == 'Safety-Kleen' && accountRec.Primary_Service_Provider_New__c == 'SK ENV'))
                      && territoryRec.Name.endsWith('IS')){
                          updatedAccountLst.add(new Account(
                          	Id = accountRec.Id,
                            OwnerId = territoryRec.Territory_ID__r.Territory_OwnerID__c,
                            Territory_Override__c = TRUE
                          ));
                    }
                }
            }
        }
        
        if(!updatedAccountLst.isEmpty()){
        	UPDATE updatedAccountLst;    
        }
    }
}