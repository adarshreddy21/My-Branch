public without sharing class AccountValidatorController {
    private final static Id keyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_REGIONAL_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();
    private final static Id rfooAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_RFOO).getRecordTypeId();
    private final static Id competitorAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_COMPETITOR_DeveloperName).getRecordTypeId();
    private final static Set<String> prfSet = new Set<String>{'Integration', 'Customer Service Light-EOC'};  
    private final static Set<String> prfSetMDM = new Set<String>{'Master Data Management'};   
    private final static string ACCOUNT_STATUS_INACTIVE = 'Inactive'; 
    private final static List<string> AccountTypeNewCustomer= new List<string>{CHConstants.ACCOUNT_TYPE_CUSTOMER, CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR, CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_DEVELOPER_NAME, CHConstants.ACCOUNT_RECORD_TYPE_BROKER, CHConstants.ACCOUNT_RECORD_TYPE_BROKER_LOCATION_DEVELOPER_NAME}; 
    private final static List<string> EligibleEPAIDRecordTypes= new List<string>{CHConstants.ACCOUNT_TYPE_CUSTOMER,CHConstants.ACCOUNT_RECORD_TYPE_BROKER, CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR, CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_DEVELOPER_NAME, CHConstants.ACCOUNT_RECORD_TYPE_BROKER_LOCATION_DEVELOPER_NAME,CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR_LOCATION_DEVELOPER_NAME,CHConstants.ACCOUNT_RECORD_TYPE_PROSPECT_DEVELOPER_NAME,CHConstants.ACCOUNT_RECORD_TYPE_PROSPECT_GEN_DEVELOPER_NAME};  

    @AuraEnabled  
    public static ValidateResponse validateAccount(string accountId){  
        Boolean iskeyAccount = false;
         
        ValidateResponse validateResObj = new ValidateResponse();
        
        try{
            Account accountRec = AccountDAO.getAccountsByIds(new Set<Id>{accountId})[0];
            
            Map<Id, String> accountIdErrorMessageMapping = Accounts.validateAccount(new Set<Id>{accountRec.Id}, true);
	        Map<Id,Profile> prfMap =  new Map<Id,Profile>([SELECT id from profile where name in ('Salesforce API Only System Integrations','Integration','Customer Service Light-EOC')]);//'System Administrator',
            Map<Id,Profile> prfMapMDM =  new Map<Id,Profile>([SELECT id from profile where name in ('Master Data Management')]);
            
            if(accountIdErrorMessageMapping.containsKey(accountRec.Id)){
                validateResObj.isSuccess = false; 
                validateResObj.message = accountIdErrorMessageMapping.get(accountRec.Id);
                accountRec.WIN_Compliance_Errors__c = accountIdErrorMessageMapping.get(accountRec.Id);
                UPDATE accountRec;
                return validateResObj;
            }
            if(Test.isRunningTest()  || (!prfMap.containsKey(userinfo.getProfileId())  
               && !prfMapMDM.containsKey(userinfo.getProfileId()))) {            // call the EPA REST API from here and based on this set the WIN validation and error details
                   EPAIdResponse epaResponse = validateEPAId(accountRec);
                   if(epaResponse != null && (epaResponse.validEpa != null || !epaResponse.validEpa)) {
                       if(epaResponse.messageCode == 0) {
                           validateResObj.isSuccess = true;
                           validateResObj.message = epaResponse.message; 
                       } else {
                           validateResObj.isSuccess = false;
                           validateResObj.message = epaResponse.exceptionMessage != null ? epaResponse.message + '$$' + epaResponse.exceptionMessage : epaResponse.message;
                           accountRec.WIN_Compliance_Errors__c = epaResponse.message;
                           update accountRec; 
                           return validateResObj;
                       }   
                   } 
               }
             
            Profile currentUserProfile = UserDAO.getProfileDetailsById(new Set<Id>{UserInfo.getProfileId()})[0];
            
            
            if(!accountRec.WIN_Validated__c  && !accountRec.Win_Validate_New__c && !accountRec.New_Customer_validated__c &&
               (accountRec.WIN_ID__c == null && (AccountTypeNewCustomer.contains(accountRec.RecordType.DeveloperName))) && (!prfSetMDM.contains(currentUserProfile.Name) || 
               (prfsetMDM.contains(currentUserProfile.Name) && accountRec.Primary_Business__c == CHConstants.ACCOUNT_PRIMARY_SERVICE_PROVIDER_HPC_INDUSTRIAL)))
            {
                AccountCRUDHandler.isAfterAccount = true;
                accountRec.New_Customer_validated__c = true;
                accountRec.WIN_Compliance_Errors__c='';
                AccountCRUDHandler.lockAccountRecord(accountRec,true);
               
            }
            if(!AccountTypeNewCustomer.contains(accountRec.RecordType.DeveloperName) && !accountRec.New_Customer_validated__c && accountRec.WIN_ID__c == null ) {
                // clear the WIN fields
                if(accountRec.type != 'Key Account')
                {
                    accountRec.WIN_Validated__c = true;
                    accountRec.High_Priority__c=true;
                }
                accountRec.Cycle__c = 'Committed';
                accountRec.WIN_Compliance_Errors__c = '';
			if(accountRec.WIN_Validated__c == true || accountRec.Win_Validate_New__c==true){
                	AccountCRUDHandler.lockAccountRecord(accountRec,true);
				}
				else{
					update accountRec;
				} 
			}
            if(String.isBlank(accountRec.WIN_ID__c)){
                if(accountRec.RecordTypeId == keyRecordTypeId){
                    iskeyAccount = true;
                    createWinIdForKeyAccount(accountRec);
                    update accountRec;								
                }
            } 
            
            if(iskeyAccount){
                updateWinValidateNoRollupChildAccounts(accountRec);
            }
            
            validateResObj.isSuccess = true;
        }catch(Exception exceptionObj){
            validateResObj.isSuccess = false;
            validateResObj.message = exceptionObj.getMessage();
			return validateResObj;
        }
        
        return validateResObj;
    }
    
    public static void updateWinValidateNoRollupChildAccounts(Account accountRec){
        List<Account> childAcct = new List<Account>();
        for(Account acc: [SELECT Id, Win_Validation_NonRollupAccount__c FROM Account 
                          WHERE Parentid =: accountRec.id and Status__c = 'Active'])
        {
            if(!acc.Win_Validation_NonRollupAccount__c){
                acc.Win_Validation_NonRollupAccount__c=true;
                childAcct.add(acc);
            }
        }
        
        if(!childAcct.isEmpty()){ 
            Database.SaveResult[] srResults= Database.update(childAcct, false);
            List<Integration_process__c> integrationProcesses = new List<Integration_process__c>();
            for(Database.SaveResult sr : srResults){
                if(!sr.isSuccess()){
                    Integration_process__c  integProcess= new Integration_process__c();
                    integProcess.Status__c = 'Error';
                    integProcess.Account__c = sr.Id;
                    integProcess.Process_Type__c = CHConstants.KeyAccountUpdate;
                    integProcess.Error_Message__c = sr.getErrors()[0].getMessage();
                    integrationProcesses.Add(integProcess);
                }
            }
            
            if(!integrationProcesses.isEmpty()){
                INSERT integrationProcesses;
            }
        }
    }
    
    private static void createWinIdForKeyAccount(Account accobj){
        Account lastAcc = new Account();
        
        List<Account> lastAccountLst = [Select Id, Win_ID_Sequence_Number__c FROM Account 
            WHERE RecordTypeId =: keyRecordTypeId AND Win_ID_Sequence_Number__c != NULL 
            ORDER BY Win_ID_Sequence_Number__c DESC LIMIT 1];
        
        if(!lastAccountLst.isEmpty()){
            lastAcc = lastAccountLst[0];
        }
            
        Integer currentSeqNumber =0;
        if(lastAcc.Id != NULL){
            currentSeqNumber = Integer.ValueOf(lastAcc.Win_ID_Sequence_Number__c) + 1;
        }
        
        String nameChar = accObj.Name.replace(' ', '').subString(0,2).toUpperCase();
        nameChar = nameChar.replace('.', '');
        accObj.WIN_ID__c = nameChar  + 'KEY' + String.valueOf(currentSeqNumber).leftPad(4, '0');
        accObj.WIN_ID_Sequence_Number__c = currentSeqNumber;
        accObj.Win_Validate_New__c = false;
        accObj.Win_Validation_NonRollupAccount__c = true; 
    }
       
    
    public class ValidateResponse{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
    }

    /**
* This method takes care of validating the EPA Id entered on the Account.
* Makes a RESTFUL callout to the EPA Service. Uses JSON as request and response.
* 
* @param account   the account record for which the validation is required
* @return true or false baesd on the valid EPA Id
*/ 
    public static EPAIdResponse validateEPAId(Account account) {
        Boolean isEPAIDValid = false;
        String tempGenStatus = '';
        String tempPrimaryProvider = '';
        String tempStateEpaid ='';
        String tempGenreg = '';
        EPAIdResponse response = null;
        
        // Construct the JSON Request
        JSONGenerator gen = JSON.createGenerator(true);
        
        if(EligibleEPAIDRecordTypes.contains(account.RecordType.DeveloperName)){
                //return null;

            // Check if there is null values and make them empty strings
            if(account.Generator_Status__c == null){   
                tempGenStatus = '';
            }
            if(account.Primary_Service_Provider__c == null){
                tempPrimaryProvider = '';
            }
              if(account.State_EPA_ID__c == null){
                tempStateEpaid = '';
            } else {
                tempStateEpaid = account.State_EPA_ID__c;
            }
             if(account.GENREG__c == null){
                tempGenreg ='';
             } else {
                 tempGenreg = account.GENREG__c;
             }
          
            if(account.Generator_Status__c == CHConstants.ACCOUNT_GEN_STATUS_LARGE_QTY_GENERATOR){
                tempGenStatus = CHConstants.ACCOUNT_GEN_STATUS_ABV_LARGE_QTY_GENERATOR;
            }
            else if(account.Generator_Status__c == CHConstants.ACCOUNT_GEN_STATUS_SMALL_QTY_GENERATOR){
                tempGenStatus = CHConstants.ACCOUNT_GEN_STATUS_ABV_SMALL_QTY_GENERATOR;
            }
            else if(account.Generator_Status__c == CHConstants.ACCOUNT_GEN_STATUS_CONDITIONALLY_QTY_GENERATOR){
                tempGenStatus = CHConstants.ACCOUNT_GEN_STATUS_ABV_CONDITIONALLY_QTY_GENERATOR;
            }
             else if(String.isBlank(account.Generator_Status__c) || account.Generator_Status__c == CHConstants.ACCOUNT_GEN_STATUS_NULL || account.Generator_Status__c == CHConstants.ACCOUNT_GEN_STATUS_UNDETERMINED){
                tempGenStatus = CHConstants.ACCOUNT_GEN_STATUS_ABV_NULL;
            }
            List<Old_New_Primary_Service_Provider_Mapping__mdt> primaryServiceProvMtdList = Old_New_Primary_Service_Provider_Mapping__mdt.getAll().values();
                for(Old_New_Primary_Service_Provider_Mapping__mdt primaryServiceProvObj : primaryServiceProvMtdList){
                    if(primaryServiceProvObj.Primary_Service_Provider__c == account.Primary_Service_Provider__c){
                        tempPrimaryProvider = primaryServiceProvObj.Primary_Service_Provider_ABV__c;
                        break;
                    } 
            }
            
            gen.writeStartObject();
            gen.writeStringField(CHConstants.EPA_JSON_REQ_EPA_ID, account.CS_EPA_ID__c);
            gen.writeStringField(CHConstants.EPA_JSON_REQ_ADDRESS_LINE_1, account.ShippingStreet);
            gen.writeStringField(CHConstants.EPA_JSON_REQ_CITY, account.ShippingCity);
            gen.writeStringField(CHConstants.EPA_JSON_REQ_STATE, account.ShippingState);
            gen.writeStringField(CHConstants.EPA_JSON_REQ_COUNTRY_CODE, account.ShippingCountry);
            gen.writeStringField(CHConstants.EPA_JSON_REQ_GENERATOR_STATUS, tempGenStatus);
            gen.writeStringField(CHConstants.EPA_JSON_REQ_PRIMARY_SERVICE_PROVIDER, tempPrimaryProvider);
            gen.writeStringField(CHConstants.EPA_JSON_RES_STATE_EPA_ID, tempStateEpaid);
            gen.writeStringField(CHConstants.EPA_JSON_RES_GENREG_ID, tempGenreg);
            gen.writeEndObject();
            String jsonString = gen.getAsString();
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setEndpoint(EPA_SERVICE__c.getInstance('EPA_SERVICE_ENDPOINT').ENDPOINT_URL__c);
            req.setHeader('Content-Type','application/json');
            req.setHeader('Content-Length',String.valueof(jsonString.length()));
            req.setMethod('POST');
            req.setBody(jsonString);
            
            try{
                HTTPResponse res = new HTTPResponse();
                response = new EPAIdResponse();
                res = http.send(req);
                return response.parse(res.getBody());
            }catch(Exception e){
                account.WIN_Compliance_Errors__c = Label.EPA_VALIDATION_EXCEPTION + e.getMessage();
            } 

        }
     
        return response;
    }  
    
    public class EPAIdResponse{
        @AuraEnabled public Boolean validEpa;
        @AuraEnabled public String message;
        @AuraEnabled public String exceptionMessage;
        @AuraEnabled public Integer messageCode;
        public EPAIdResponse parse(String json){
            return (EPAIdResponse) System.JSON.deserialize(json, EPAIdResponse.class);
 
        }
    }
}