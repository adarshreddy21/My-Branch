public class ConvertRecTypeController {

    public Account acc {get;set;}
    public Account accObj {get;set;}
    
    public ConvertRecTypeController(ApexPages.StandardController stdController){
        
        acc = (account)stdController.getRecord();
        accObj = new Account();
    }
    
    public PageReference updateRecType(){
        
        List<Account> accToUpdate = new List<Account>();
        
        Map<String, RecordType> recTypeByNameMap = new Map<String, RecordType>();
        for(RecordType rec : [Select Id, DeveloperName, SobjectType from Recordtype where SobjectType = 'Account']){
            recTypeByNameMap.put(rec.DeveloperName, rec);
        } 
        
        accObj = [Select Id, Name, RecordTypeId, RecordType.DeveloperName, Type,Class__c,Credit_Terms__c, Credit_Status__c, ShippingCountry,Primary_Service_Provider__c, Toggle_Me_to_Bypass_Validation__c from Account where Id =: acc.Id LIMIT 1];
        if(accObj.RecordTypeId == recTypeByNameMap.get(CHConstants.ACCOUNT_RECORD_TYPE_PROSPECT_DEVELOPER_NAME).Id){
            
            accObj.RecordTypeId = recTypeByNameMap.get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).Id;
            accObj.Type = CHConstants.ACCOUNT_TYPE_CUSTOMER;
			accObj.Toggle_Me_to_Bypass_Validation__c = !accObj.Toggle_Me_to_Bypass_Validation__c;
			AccountCRUDHandler.updateAcctFromSTGtoCUST(new list<Account> {accObj});
            accToUpdate.add(accObj);
            
            for(Account childObj : [Select Id, RecordTypeId, Type from Account where ParentId =:accObj.Id]){
                
                childObj.RecordTypeId = recTypeByNameMap.get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_DEVELOPER_NAME).Id;
                childObj.Type = CHConstants.ACCOUNT_TYPE_SHIPTO_GEN;
                accToUpdate.add(childObj);
            }
        }
        else if(accObj.RecordTypeId == recTypeByNameMap.get(CHConstants.ACCOUNT_RECORD_TYPE_PROSPECT_GEN_DEVELOPER_NAME).Id){
            
            accObj.RecordTypeId = recTypeByNameMap.get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_DEVELOPER_NAME).Id;
            accObj.Type = CHConstants.ACCOUNT_TYPE_SHIPTO_GEN;
            //accObj.WIN_Validated__c = TRUE;
            accToUpdate.add(accObj);
        }
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.update(accToUpdate,dml); 
             
        PageReference acctPage = new PageReference('/' + accObj.Id+'/e?retURL='+ accObj.Id);
        acctPage.setRedirect(true);
        return acctPage;
    }
}