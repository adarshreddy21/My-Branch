public without sharing class Accounts {
    private  final string ERROR_MESSAGE= 'External Id already exists';
    private  final string ERROR= 'Error';
    public final static string ACCOUNT_STATUS_INACTIVE = 'Inactive'; 
    private Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    private Id customerLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
    private Id rfooAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_RFOO).getRecordTypeId();
    private Id competitorAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_COMPETITOR_DeveloperName).getRecordTypeId();
	
    private  void setIntegrationProcessRecordStatus(Integration_Process__c integrationProcess, string status, string message){
        integrationProcess.Status__c= status;
        integrationProcess.Error_Message__c= message;
		integrationProcess.Attempts__c= integrationProcess.Attempts__c==null ? 1 : integrationProcess.Attempts__c+1;
    }
     
    public void processIntegrationRecordsToCreateWinId(List<Integration_Process__c> integrationProcesses){
        List<Account> accountsForGeneratingWin= new List<Account>();
        Map<Id, string> erroredAccountIdsMessageMap=new Map<Id, string>();
        Set<string> existingWinIds= new Set<string>();	
        Map<string,string> sfIdWinMapping = new Map<string,string>();
        List<Account> accountsToUpdateForWinIds= new List<Account>();
        Set<Id> accountsUpdatedbyWINIdsFromInternalLogic= new Set<Id>();
        string message;
        Integer hpcCustomerSequenceNumber=-1;
        Integer hpcCustomerLocationSequenceNumber=-1;
		Integer rfoocompetitorSequenceNumber=-1;
        try{
            for(Integration_Process__c integrationProcess: integrationProcesses)
            {
                if(integrationProcess.Account__r.Primary_Business__c=='HPC Industrial'){
                    if(integrationProcess.Account__r.RecordTypeId== customerRecordTypeId && String.isBlank(integrationProcess.Account__r.Win_Id__c)){
                        generateAndMapWinIdAndSeqNumberforHPCCustomer(integrationProcess.Account__r, hpcCustomerSequenceNumber);  
                        hpcCustomerSequenceNumber= Integer.valueOf(integrationProcess.Account__r.WIN_ID_Sequence_Number__c);
                        accountsToUpdateForWinIds.add(new Account(Id= integrationProcess.Account__c, WIN_Id__c= integrationProcess.Account__r.Win_Id__c, WIN_ID_Sequence_Number__c= hpcCustomerSequenceNumber));	
                        sfIdWinMapping.put(integrationProcess.Account__c, integrationProcess.Account__r.Win_Id__c);
                        accountsUpdatedbyWINIdsFromInternalLogic.Add(integrationProcess.Account__c);
                    }
                    else if(integrationProcess.Account__r.RecordTypeId== customerLocationRecordTypeId && String.isBlank(integrationProcess.Account__r.Win_Id__c)){
                        generateAndMapWinIdAndSeqNumberforHPCCustomerLocation(integrationProcess.Account__r, hpcCustomerLocationSequenceNumber);  
                        hpcCustomerLocationSequenceNumber= Integer.valueOf(integrationProcess.Account__r.WIN_ID_Sequence_Number__c);
                        accountsToUpdateForWinIds.add(new Account(Id= integrationProcess.Account__c, WIN_Id__c= integrationProcess.Account__r.Win_Id__c, WIN_ID_Sequence_Number__c= hpcCustomerLocationSequenceNumber));	
                        sfIdWinMapping.put(integrationProcess.Account__c, integrationProcess.Account__r.Win_Id__c);
                        accountsUpdatedbyWINIdsFromInternalLogic.Add(integrationProcess.Account__c);
                    }
                }
				else if((integrationProcess.Account__r.RecordTypeId== rfooAccountRecordType || integrationProcess.Account__r.RecordTypeId== competitorAccountRecordType) 
                       && String.isBlank(integrationProcess.Account__r.Win_Id__c))
                    {
                        createWinIdForCompetitorOrRFOO(integrationProcess.Account__r, rfoocompetitorSequenceNumber);
                        rfoocompetitorSequenceNumber= Integer.valueOf(integrationProcess.Account__r.WIN_ID_Sequence_Number__c);
                        accountsToUpdateForWinIds.add(new Account(Id= integrationProcess.Account__c, WIN_Id__c= integrationProcess.Account__r.Win_Id__c, WIN_ID_Sequence_Number__c= rfoocompetitorSequenceNumber));	
                        sfIdWinMapping.put(integrationProcess.Account__c, integrationProcess.Account__r.Win_Id__c);
                        accountsUpdatedbyWINIdsFromInternalLogic.Add(integrationProcess.Account__c);
                    } 
                else{
                    accountsForGeneratingWin.Add(new Account(Id= integrationProcess.Account__c, Name= integrationProcess.Account__r.Name, Type= integrationProcess.Account__r.Type));
                }
            }
            if(!accountsForGeneratingWin.isEmpty()){
                List<RestAccountClient.WinResponse> responseData= RestAccountClient.generateWinIds(accountsForGeneratingWin);
                for(RestAccountClient.WinResponse response: responseData){
                    if(String.isBlank(response.Message)){
                        sfIdWinMapping.put(response.SFID,response.WinID);
                    }
                    else{
                        message= response.Message;
                    }
                }
            }
            if(sfIdWinMapping.values()!=null && !sfIdWinMapping.values().isEmpty()){
                for(Account acc: [SELECT Id,Win_Id__c from Account where Win_Id__c in : sfIdWinMapping.values()]){	
                    existingWinIds.Add(acc.Win_Id__c); 	
                }
            }
            for(Integration_Process__c integrationProcess: integrationProcesses){
                if(sfIdWinMapping.containsKey(integrationProcess.Account__c)){
                    if(!existingWinIds.contains(sfIdWinMapping.get(integrationProcess.Account__c))){	
                        setIntegrationProcessRecordStatus(integrationProcess, 'Processed', null);
                        if(!accountsUpdatedbyWINIdsFromInternalLogic.contains(integrationProcess.Account__c)){					
                            accountsToUpdateForWinIds.add(new Account(Id= integrationProcess.Account__c, WIN_Id__c= sfIdWinMapping.get(integrationProcess.Account__c)));	
                        }
                    }	
                    else{
                        setIntegrationProcessRecordStatus(integrationProcess, ERROR, ERROR_MESSAGE+ ':'+ sfIdWinMapping.get(integrationProcess.Account__c));
                    }
                }
                else{
                    setIntegrationProcessRecordStatus(integrationProcess, ERROR,message);
                }
            }
            AccountCRUDHandler.SKIP_VALIDATION = true;
            if(!accountsToUpdateForWinIds.isEmpty()){
                Database.SaveResult[] results= Database.update(accountsToUpdateForWinIds, false);
                for(Database.SaveResult result: results){
                    if(!result.isSuccess()){
                        erroredAccountIdsMessageMap.put(result.Id, result.getErrors()[0].getMessage());
                    }
                }
            }
            for(Integration_Process__c integrationProcess: integrationProcesses){
                if(erroredAccountIdsMessageMap.containsKey(integrationProcess.Account__c)){
                    setIntegrationProcessRecordStatus(integrationProcess, ERROR, erroredAccountIdsMessageMap.get(integrationProcess.Account__c));
                }
            }
        }catch(Exception exceptionObj){
            for(Integration_Process__c integrationProcess: integrationProcesses){
                setIntegrationProcessRecordStatus(integrationProcess, ERROR, exceptionObj.getMessage());
            } 
        }
        
        if(!integrationProcesses.isEmpty()){
            update integrationProcesses; 
        }
    }
    
    private void generateAndMapWinIdAndSeqNumberforHPCCustomer(Account acc, Integer seqNumber){
        List<Account> lastAcc = new List<Account>();
        Integer currentSequenceNumber= 0;
        if(seqNumber>-1){
            currentSequenceNumber= seqNumber+1;
        }
        else{
            lastAcc= [Select Id, Name, WIN_ID__c, Win_ID_Sequence_Number__c 
                      from Account 
                      where RecordTypeId =: customerRecordTypeId 
                      AND  Win_ID_Sequence_Number__c != NULL 
                      AND Primary_Business__c = 'HPC Industrial' 
                      Order by Win_ID_Sequence_Number__c Desc];
            
            
            if(!lastAcc.isEmpty()){
                currentSequenceNumber = Integer.ValueOf(lastAcc[0].Win_ID_Sequence_Number__c) + 1;
            }
        }
        acc.WIN_ID__c = 'A' + String.valueOf(currentSequenceNumber).leftPad(4, '0') + 'AD' + String.valueOf(currentSequenceNumber).leftPad(3, '0').subString(0, 3);
        acc.WIN_ID_Sequence_Number__c = currentSequenceNumber;
    }
    
    private void generateAndMapWinIdAndSeqNumberforHPCCustomerLocation(Account acc, Integer seqNumber){
        List<Account> lastAcc = new List<Account>();
        Integer currentSequenceNumber= 0;
        if(seqNumber>-1){
            currentSequenceNumber= seqNumber+1;
        }
        else{
            lastAcc= [Select Id,  WIN_ID__c, Win_ID_Sequence_Number__c
                      from Account 
                      where RecordTypeId =: customerLocationRecordTypeId AND Win_ID_Sequence_Number__c != NULL
                      AND Primary_Business__c = 'HPC Industrial' Order by Win_ID_Sequence_Number__c Desc];  
            if(!lastAcc.isEmpty()){
                currentSequenceNumber = Integer.ValueOf(lastAcc[0].Win_ID_Sequence_Number__c) + 1;
            }
        }
        String accCustomerName = acc.Parent.WIN_ID__c;
        acc.WIN_ID__c = accCustomerName.subString(0, 5).trim().toUppercase() + String.valueOf(currentSequenceNumber).leftPad(3, '0').subString(0, 3);
        acc.WIN_ID_Sequence_Number__c = currentSequenceNumber;
    }
	
	private void createWinIdForCompetitorOrRFOO(Account accountRec, Integer seqNumber){
         List<Account> lastAcc = new List<Account>();
        Integer currentSequenceNumber= 0;
        if(seqNumber>-1){
            currentSequenceNumber= seqNumber+1;
        }
         else{
             lastAcc = [Select Id, Name, WIN_ID__c, Win_ID_Sequence_Number__c, CS_EPA_ID__c FROM Account 
                        WHERE RecordTypeId =: accountRec.RecordTypeId AND Win_ID_Sequence_Number__c != NULL 
                        ORDER BY Win_ID_Sequence_Number__c DESC Limit 1]; 
             
             if(!lastAcc.isEmpty()){
                 currentSequenceNumber = Integer.ValueOf(lastAcc[0].Win_ID_Sequence_Number__c) + 1;
             }
             else{
                 currentSequenceNumber = Integer.ValueOf(Label.Win_ID_Initial_Sequence_Number);
             }
         }
         
         String accountType;
         
         if(accountRec.RecordTypeId == competitorAccountRecordType){
             accountType = 'COMP';
         }else if(accountRec.RecordTypeId == rfooAccountRecordType){
             accountType = 'RFOO';
         }
         
         String nameChar = accountRec.Name.replace(' ','').subString(0,2).toUpperCase();
         accountRec.WIN_ID__c = nameChar + accountType + currentSequenceNumber;
         accountRec.WIN_ID_Sequence_Number__c = currentSequenceNumber;            
         //accountRec.Win_Validate_New__c = True;
         
         if(accountRec.CS_EPA_ID__c == NULL){
             accountRec.CS_EPA_ID__c = 'PENDING';
             
         }
    }
    
    public static Map<Id, String> validateAccount(Set<Id> accountIds, Boolean validateWinCompliance){
        Profile currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        Map<Id, List<Contact>> contactListMap = new Map<Id, List<Contact>>();
        Map<Id, String> accountIdErrorMessageMapping = new Map<Id, String>();
        List<Account> lockAccountRecLst = new List<Account>();
        List<Account> updateAccountRecLst = new List<Account>();
        Map<Id, List<Tax_Document__c>> taxDocumentMap = new Map<Id, List<Tax_Document__c>>();
        List<Account> accountRecLst = [
            SELECT Id, RecordTypeId, RecordType.DeveloperName, Type, Name,Division__c, Business_Type__c, AccountSource, Reporting_Vertical__c,
            Industry_Segment__c, Class__c, Sic, Rank__c, Risk_Category__c, CurrencyISOCode, ShippingState, ShippingStreet, ShippingCountry, 
            ShippingCity, ShippingPostalCode, BillingState, Inactivate_Reactivate_In_Progress__c, BillingStreet, BillingCountry, BillingCity, BillingPostalCode, Tax_Exemption_Type__c, 
            Primary_Business__c, ParentId, WIN_ID__c, Primary_Service_Provider_New__c, Status__c, WIN_Validated__c, Win_Validate_New__c, 
            High_Priority__c, WIN_Compliance_Errors__c, New_Customer_validated__c, Parent.WIN_ID__c, CS_EPA_ID__c, Accounts_with_WINID__c, Toggle_Me_to_Bypass_Validation__c,
            (
                SELECT Id, Accountid, Contact_Type__c, Email 
                FROM Contacts
                WHERE Contact_Type__c Includes('MAIN') and Expired__c = false
            )
            FROM Account 
            WHERE Id IN :accountIds
        ];                
        if(validateWinCompliance){
            for(Account accountRec : accountRecLst){
                contactListMap.put(accountRec.Id, accountRec.Contacts);
            }    
        }
        if(validateWinCompliance){
            for(Tax_Document__c taxDocumentRec : [
                SELECT Id, Account__c, (
                    SELECT Id 
                    FROM Attachments 
                    LIMIT 1
                ), (
                    SELECT Id 
                    FROM ContentDocumentLinks
                )
                FROM Tax_Document__c 
                WHERE Account__c IN: accountRecLst
            ]){
                if(taxDocumentMap.containsKey(taxDocumentRec.Account__c)){
                    taxDocumentMap.get(taxDocumentRec.Account__c).add(taxDocumentRec);
                }else{
                    taxDocumentMap.put(taxDocumentRec.Account__c, new List<Tax_Document__c>{taxDocumentRec});
                }
            }    
        }
        
        for(Account accountRec : accountRecLst){
            if(
                (
                    accountRec.recordTypeId == AccountCRUDHandler.KeyAccountRecordType || accountRec.RecordTypeId == AccountCRUDHandler.customerAccountRecordType 
                    || accountRec.RecordTypeId == AccountCRUDHandler.brokerAccountRecordType || accountRec.RecordTypeId == AccountCRUDHandler.distributorAccountRecordType) && 
                accountRec.Status__c != ACCOUNT_STATUS_INACTIVE && (
                    accountRec.BillingState == NULL || accountRec.BillingStreet == NULL ||
                    accountRec.BillingCountry == NULL || accountRec.BillingCity == NULL || accountRec.BillingPostalCode == NULL
                ) 
            ){ 
                setErrorMessageForAccount(accountRec.Id, accountIdErrorMessageMapping, Label.BILLING_ADDRESS_VALIDATION);
            }  
			
			if(accountRec.RecordTypeId == AccountCRUDHandler.customerAccountRecordType && String.isBlank(accountRec.CS_EPA_ID__c)){
			
                setErrorMessageForAccount(accountRec.Id, accountIdErrorMessageMapping, Label.EPA_ID_MANDATORY);
            }  
                if(validateWinCompliance){
                    List<Tax_Document__c> taxDocumentLst = taxDocumentMap.get(accountRec.Id);
                  if(
                      accountRec.Tax_Exemption_Type__c != 'Non Exempt'
                      && (
                        accountRec.recordTypeId == AccountCRUDHandler.KeyAccountRecordType 
                        || accountRec.RecordTypeId == AccountCRUDHandler.customerAccountRecordType 
                        || accountRec.RecordTypeId == AccountCRUDHandler.customerLocationAccountRecordType
                    )
                ){
                    Boolean hasAttachmentError = true;
                    if(taxDocumentLst != NULL){
                        for(Tax_Document__c taxObj : taxDocumentLst){
                            if(!taxObj.Attachments.isEmpty() || !taxObj.ContentDocumentLinks.isEmpty()){
                                hasAttachmentError =  false;
                            }
                        }
                    }
                    
                    if(hasAttachmentError)
                        setErrorMessageForAccount(accountRec.Id, accountIdErrorMessageMapping, Label.TAX_Exempt_ERROR);
                }
            }
            String validationMsg = validateWINCompliance(accountRec, contactListMap.get(accountRec.Id), validateWinCompliance,currentUserProfile);
            if(String.isNotBlank(validationMsg)){
                validationMsg = validationMsg.replaceFirst('\\$\\$', ''); 
                setErrorMessageForAccount(accountRec.Id, accountIdErrorMessageMapping, 'Win Compliance: '+ validationMsg);
            }
        }
        return accountIdErrorMessageMapping;
    }
    
    private static String validateWINCompliance(Account accountRec, List<Contact> contactList, Boolean validateWinCompliance, Profile currentUserProfile){
        Boolean isValidated = true;
        Boolean isSkipEPAValidationRec = FALSE;
        Boolean corporateAddressValidated = true;
        List<Contact> beaconContactListEmail = new List<Contact>();
        Boolean isMain = false;
        
        Set<String> prfSet = new Set<String>{'System Administrator', 'Integration', 'Customer Service Light-EOC'};  
            Set<String> prfSetMDM = new Set<String>{'Master Data Management'};
                accountRec.WIN_Compliance_Errors__c = '';
        if(
            accountRec.RecordType.DeveloperName == CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_DEVELOPER_NAME ||
            accountRec.RecordType.DeveloperName == CHConstants.ACCOUNT_RECORD_TYPE_BROKER_LOCATION_DEVELOPER_NAME ||
            accountRec.RecordType.DeveloperName == CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR_LOCATION_DEVELOPER_NAME ||
            accountRec.RecordType.DeveloperName == CHConstants.ACCOUNT_RECORD_TYPE_PROSPECT_GEN_DEVELOPER_NAME
        ){
            if(accountRec.ParentId != null){
                if(accountRec.Parent.WIN_ID__c == null){
                    accountRec.WIN_Compliance_Errors__c = accountRec.WIN_Compliance_Errors__c + '$$' + Label.WIN_ID_ON_PARENT_VALIDATION;
                    corporateAddressValidated = false;
                    isValidated = false;
                }
            }
        }
        
        if(validateWinCompliance){
            isMain = contactList.size() > 0;
            
            for(Contact con : contactList){
                if(String.isNotBlank(con.Email)){
                    beaconContactListEmail.add(con);
                }
            }
        }
        
        if(corporateAddressValidated && (accountRec.ShippingCountry == null || accountRec.ShippingState == null || 
                                         accountRec.ShippingPostalCode == null || accountRec.ShippingStreet == null || accountRec.ShippingCity == null) && 
           (accountRec.Status__c != ACCOUNT_STATUS_INACTIVE))
        { 
            accountRec.WIN_Compliance_Errors__c = accountRec.WIN_Compliance_Errors__c + '$$' + Label.CORPORATE_ADDRESS_VALIDATION;
            isValidated = false;
        }
        if((!String.isBlank(accountRec.ShippingStreet) && accountRec.ShippingStreet.length() > 60)||
           (!String.isBlank(accountRec.BillingStreet) && accountRec.BillingStreet.length() > 60))
        {
            accountRec.WIN_Compliance_Errors__c = accountRec.WIN_Compliance_Errors__c + '$$' + Label.ADDRESS_LENGTH_VALIDATION;
            isValidated = false;
        }
        if(validateWinCompliance && corporateAddressValidated && !isMain && !prfSet.contains(currentUserProfile.Name)) 
        {
            accountRec.WIN_Validated__c = false;
            String errorTypes = '';
            if(!isMain){
                errorTypes = 'MAIN';
            }
            String errMsg = Label.WIN_BEACON_CONTACT_VALIDATION;
            errMsg = errMsg.replace('conTypes', errorTypes);
            accountRec.WIN_Compliance_Errors__c = accountRec.WIN_Compliance_Errors__c + '$$' + errMsg;
            isValidated = false;
        }
        if(validateWinCompliance && corporateAddressValidated && isMain && beaconContactListEmail.size() == 0){
            accountRec.WIN_Validated__c = false;
            accountRec.WIN_Compliance_Errors__c = accountRec.WIN_Compliance_Errors__c + '$$' + Label.WIN_BEACON_CONTACT_EMAIL;
            isValidated = false;
        }
        return isValidated ? '' : accountRec.WIN_Compliance_Errors__c;
    }
    
    public static Boolean checkIfBulkProcess() {
        return (System.isBatch() || System.isQueueable() || System.isScheduled()) || !(URL.getCurrentRequestUrl().toExternalForm().contains('aura'));
        
    }
	
    public static string tokeniseAccountFields(String expressionToCheck,List<AbbreviationMapping__mdt> abbrList){
        expressionToCheck= expressionToCheck.replaceAll('[^a-zA-Z0-9\\s+]', '').normalizeSpace().trim().toUpperCase();
        for(AbbreviationMapping__mdt abbreviation:abbrList ){
            expressionToCheck = expressionToCheck.replaceAll('\\b'+abbreviation.Abbreviation__c+'\\b', abbreviation.Actual_Name__c);
        }
        return expressionToCheck;
    }
    
    private static void setErrorMessageForAccount(Id accountId, Map<Id, String> accountIdErrorMessageMapping, String errorMsg){
        if(accountIdErrorMessageMapping.containsKey(accountId)){
            accountIdErrorMessageMapping.put(accountId, accountIdErrorMessageMapping.get(accountId) + '$$' + errorMsg);
        }
        else{
            accountIdErrorMessageMapping.put(accountId, errorMsg);
        }
    }

    
 	/************************************************************************************** 
 
       * @Description  This method fires platform events
       * @Param    AccountCRUDHandler.firePlatformEvents(accountIds,highPriority); 
    **************************************************************************************/ 
    public static List<Database.SaveResult> firePlatformEvents(Set<Id> accIds, Boolean highPriority){
        List<Account> accounts = AccountDAO.getAccountsByIds(accIds);
        List<AccountChangeNotification__e> accountNotifications = new List<AccountChangeNotification__e>();
        List<AccountChangeNotificationLowPrio__e> accountNotificationsLow = new List<AccountChangeNotificationLowPrio__e>();
		Integer iteration = 0;
        List<Exception_Log__c> exceptionLogs = new List<Exception_Log__c>();
        List<Database.SaveResult> platformResults= null;
        for(Account acc : accounts){
             if(highPriority){
                accountNotifications.Add(new AccountChangeNotification__e(AccountSource__c = acc.AccountSource,
                Billing_City__c= acc.BillingCity, Billing_Country__c= acc.BillingCountry, Billing_Postal_Code__c= acc.BillingPostalCode,
                Billing_State__c= acc.BillingState, Billing_Street__c=  acc.BillingStreet, CS_EPA_ID__c= acc.CS_EPA_ID__c, Corporate_Address_2__c= acc.Corporate_Address_2__c,
                CurrencyIsoCode__c= acc.CurrencyIsoCode, Employee_Number__c= acc.Owner.EmployeeNumber, Id__c= acc.Id,
                Name__c= acc.Name, Operating_Segment__c= acc.Primary_Service_Provider_New__c, Phone__c= acc.Phone, Primary_Service_Provider__c= acc.Primary_Service_Provider__c,
                Shipping_City__c= acc.ShippingCity, Shipping_Country__c= acc.ShippingCountry, Shipping_Postal_Code__c= acc.ShippingPostalCode,
                Shipping_State__c= acc.ShippingState, Shipping_Street__c=acc.ShippingStreet, Type__c= acc.Type, WIN_ID__c= acc.WIN_ID__c, Fax__c= acc.Fax,
                Website__c= acc.Website, Sic__c= acc.Sic, CreatedDate__c= acc.CreatedDate, CreatedById__c= acc.CreatedBy.FederationIdentifier,
                LastModifiedDate__c= acc.LastModifiedDate, LastModifiedById__c= acc.LastModifiedBy.FederationIdentifier, Billing_Address_2__c= acc.Billing_Address_2__c,
                Business_Type__c= acc.Business_Type__c, Chain_Code__c= acc.Chain_Code__c, Class__c= acc.Class__c,Industry_Segment__c= acc.Industry_Segment__c,
                Division__c= acc.Division__c, Status__c= acc.Status__c, State_EPA_ID__c= acc.State_EPA_ID__c, Rank__c= acc.Rank__c, Manifest_Address1__c= acc.Manifest_Address1__c,
                Manifest_Address2__c=acc.Manifest_Address2__c, Manifest_Address_ID__c= acc.Manifest_Address_ID__c, Manifest_Country_Code__c= acc.Manifest_Country_Code__c, Manifest_Locality1__c= acc.Manifest_Locality1__c,
                Manifest_Post_Code__c= acc.Manifest_Post_Code__c, Manifest_Region_Code__c= acc.Manifest_Region_Code__c, PayTo_Address1__c= acc.PayTo_Address1__c,
                PayTo_Address2__c= acc.PayTo_Address2__c, Pay_To_Address_3__c= acc.Pay_To_Address_3__c, Pay_To_Address_ID__c= acc.Pay_To_Address_ID__c, Pay_To_Country_Code__c= acc.Pay_To_Country_Code__c,
                Pay_To_Locality1__c= acc.Pay_To_Locality1__c, Pay_To_Post_Code__c= acc.Pay_To_Post_Code__c, Pay_To_Region_Code__c= acc.Pay_To_Region_Code__c, Primary_SK_Branch__c= acc.Primary_SK_Branch__c,
                Risk_Category__c= acc.Risk_Category__c, Secondary_ID__c= acc.Secondary_ID__c, ParentWinId__c=  (acc.Parent.RecordType.DeveloperName <>'Key_Account'?acc.Parent.Win_Id__c :''), Consolidated_Bill_To__c= acc.Consolidated_Bill_To__c, Credit_Status__c= acc.Credit_Status__c,
                Credit_Terms__c= acc.Credit_Terms__c, Email_Invoices__c= acc.Email_Invoices__c, GENREG__c= acc.GENREG__c, Generator_Status__c=acc.Generator_Status__c, Insite__c= acc.Insite__c, Language__c= acc.Language__c,
                Lost_Reason__c= acc.Lost_Reason__c, Lost_To__c= acc.Lost_To__c, Previous_Type__c= acc.Previous_Type__c, Site_ID__c= acc.Site_ID__c, Territory_Override__c= acc.Territory_Override__c, Waste_Oil__c= acc.Waste_Oil__c,
                Broker_Group__c= acc.Broker_Group__c, Territory_ID_SK__c= acc.Territory_ID_SK__c, LastUpdate_CRM__c= acc.LastUpdate_CRM__c, Billing_expired__c= acc.Billing_expired__c,
                Manifest_expired__c= acc.Manifest_expired__c, SRP__c= acc.SRP__c, Milkrun_Zone__c= acc.Milkrun_Zone__c, Milkrun_Service_Type__c= acc.Milkrun_Service_Type__c, Origin__c= (String.isBlank(acc.Origin__c)?'Salesforce':acc.Origin__c), Dunbrdst_Reference__c= acc.Dunbrdst_Reference__c, High_Priority__c= highPriority, Key_Buying_Decision__c= acc.Key_Buying_Decision__c,
                Credit_Cut_Off__c= acc.Credit_Cutoff__c,Credit_Limit__c=acc.Credit_Limit__c, Customer_Engagement_Manager__c= acc.Customer_Engagement_Manager__r.FederationIdentifier,
				Group_3_UMO__c=acc.Group_3_UMO__c, Dual_Corp_Account_Owner__c = acc.Dual_Corp_Account_Owner__r.FederationIdentifier, PO_Management_Support__c = acc.PO_Management_Support__r.FederationIdentifier,
				Account_Headline__c=acc.Account_Headline__c,RecordTypeId__c = acc.RecordTypeId,KAM_Manager__c = acc.KAM_Manager__r.FederationIdentifier,KAM_Support__c=acc.KAM_Support__r.FederationIdentifier,Dunbrdst__c= acc.dunbrdst__c, Headline_Expiration_Date__c=(DateTime)acc.Headline_Expiration__c));
            } 
            else{ 
                accountNotificationsLow.Add(new AccountChangeNotificationLowPrio__e(AccountSource__c = acc.AccountSource,
                Billing_City__c= acc.BillingCity, Billing_Country__c= acc.BillingCountry, Billing_Postal_Code__c= acc.BillingPostalCode,
                Billing_State__c= acc.BillingState, Billing_Street__c=  acc.BillingStreet, CS_EPA_ID__c= acc.CS_EPA_ID__c, Corporate_Address_2__c= acc.Corporate_Address_2__c,
                CurrencyIsoCode__c= acc.CurrencyIsoCode, Employee_Number__c= acc.Owner.EmployeeNumber, Id__c= acc.Id,
                Name__c= acc.Name, Operating_Segment__c= acc.Primary_Service_Provider_New__c, Phone__c= acc.Phone, Primary_Service_Provider__c= acc.Primary_Service_Provider__c,
                Shipping_City__c= acc.ShippingCity, Shipping_Country__c= acc.ShippingCountry, Shipping_Postal_Code__c= acc.ShippingPostalCode,
                Shipping_State__c= acc.ShippingState, Shipping_Street__c=acc.ShippingStreet, Type__c= acc.Type, WIN_ID__c= acc.WIN_ID__c, Fax__c= acc.Fax,
                Website__c= acc.Website, Sic__c= acc.Sic, CreatedDate__c= acc.CreatedDate, CreatedById__c= acc.CreatedBy.FederationIdentifier,
                LastModifiedDate__c= acc.LastModifiedDate, LastModifiedById__c= acc.LastModifiedBy.FederationIdentifier, Billing_Address_2__c= acc.Billing_Address_2__c,
                Business_Type__c= acc.Business_Type__c, Chain_Code__c= acc.Chain_Code__c, Class__c= acc.Class__c,Industry_Segment__c= acc.Industry_Segment__c,
                Division__c= acc.Division__c, Status__c= acc.Status__c, State_EPA_ID__c= acc.State_EPA_ID__c, Rank__c= acc.Rank__c, Manifest_Address1__c= acc.Manifest_Address1__c,
                Manifest_Address2__c=acc.Manifest_Address2__c, Manifest_Address_ID__c= acc.Manifest_Address_ID__c, Manifest_Country_Code__c= acc.Manifest_Country_Code__c, Manifest_Locality1__c= acc.Manifest_Locality1__c,
                Manifest_Post_Code__c= acc.Manifest_Post_Code__c, Manifest_Region_Code__c= acc.Manifest_Region_Code__c, PayTo_Address1__c= acc.PayTo_Address1__c,
                PayTo_Address2__c= acc.PayTo_Address2__c, Pay_To_Address_3__c= acc.Pay_To_Address_3__c, Pay_To_Address_ID__c= acc.Pay_To_Address_ID__c, Pay_To_Country_Code__c= acc.Pay_To_Country_Code__c,
                Pay_To_Locality1__c= acc.Pay_To_Locality1__c, Pay_To_Post_Code__c= acc.Pay_To_Post_Code__c, Pay_To_Region_Code__c= acc.Pay_To_Region_Code__c, Primary_SK_Branch__c= acc.Primary_SK_Branch__c,
                Risk_Category__c= acc.Risk_Category__c, Secondary_ID__c= acc.Secondary_ID__c, ParentWinId__c=  (acc.Parent.RecordType.DeveloperName <>'Key_Account'?acc.Parent.Win_Id__c :''), Consolidated_Bill_To__c= acc.Consolidated_Bill_To__c, Credit_Status__c= acc.Credit_Status__c,
                Credit_Terms__c= acc.Credit_Terms__c, Email_Invoices__c= acc.Email_Invoices__c, GENREG__c= acc.GENREG__c, Generator_Status__c=acc.Generator_Status__c, Insite__c= acc.Insite__c, Language__c= acc.Language__c,
                Lost_Reason__c= acc.Lost_Reason__c, Lost_To__c= acc.Lost_To__c, Previous_Type__c= acc.Previous_Type__c, Site_ID__c= acc.Site_ID__c, Territory_Override__c= acc.Territory_Override__c, Waste_Oil__c= acc.Waste_Oil__c,
                Broker_Group__c= acc.Broker_Group__c, Territory_ID_SK__c= acc.Territory_ID_SK__c, LastUpdate_CRM__c= acc.LastUpdate_CRM__c, Billing_expired__c= acc.Billing_expired__c,
                Manifest_expired__c= acc.Manifest_expired__c, SRP__c= acc.SRP__c, Milkrun_Zone__c= acc.Milkrun_Zone__c, Milkrun_Service_Type__c= acc.Milkrun_Service_Type__c, 
				Origin__c= (String.isBlank(acc.Origin__c)?'Salesforce':acc.Origin__c), Dunbrdst_Reference__c= acc.Dunbrdst_Reference__c, 
				High_Priority__c= highPriority, Key_Buying_Decision__c= acc.Key_Buying_Decision__c, Credit_Cut_Off__c= acc.Credit_Cutoff__c,Credit_Limit__c=acc.Credit_Limit__c, 
				Customer_Engagement_Manager__c= acc.Customer_Engagement_Manager__r.FederationIdentifier, Group_3_UMO__c=acc.Group_3_UMO__c,
				Account_Headline__c=acc.Account_Headline__c,RecordTypeId__c = acc.RecordTypeId,KAM_Manager__c = acc.KAM_Manager__r.FederationIdentifier,
				Dual_Corp_Account_Owner__c = acc.Dual_Corp_Account_Owner__r.FederationIdentifier, PO_Management_Support__c = acc.PO_Management_Support__r.FederationIdentifier, KAM_Support__c=acc.KAM_Support__r.FederationIdentifier, Dunbrdst__c= acc.dunbrdst__c, Headline_Expiration_Date__c=(DateTime)acc.Headline_Expiration__c));
            
            }
        }
        
        if(!accountNotifications.isEmpty()){
			iteration= 0;
            platformResults= EventBus.publish(accountNotifications); 
			for(Database.SaveResult saveResult : platformResults){
                if(!saveResult.isSuccess()){
                    for(Database.Error err : saveResult.getErrors()) {
                        exceptionLogs.add(new Exception_Log__c(
                            Error_Message__c = err.getMessage(),
                            Apex_Class_Trigger__c = AccountCRUDHandler.class.getName(),
                            Apex_Method_Event__c = 'createAccountPlatformEvents',
                            Record_Id__c = accountNotifications[iteration].Id__c)); 
                    }                            
                }
                iteration++;
            }
        }
        if(!accountNotificationsLow.isEmpty()){
		    iteration= 0;
            platformResults= EventBus.publish(accountNotificationsLow); 
			for(Database.SaveResult saveResult : platformResults){
                if(!saveResult.isSuccess()){
                    for(Database.Error err : saveResult.getErrors()) {
                        exceptionLogs.add(new Exception_Log__c(
                            Error_Message__c = err.getMessage(),
                            Apex_Class_Trigger__c = AccountCRUDHandler.class.getName(),
                            Apex_Method_Event__c = 'createAccountPlatformEvents',
                            Record_Id__c = accountNotificationsLow[iteration].Id__c));
                    }                            
                }
                iteration++;
            }
        }
        if(!exceptionLogs.isEmpty()){
            insert exceptionLogs;
        }
         return platformResults;
    }

    @InvocableMethod(callout=true label='Construct Data For CompanySync Retrial')
   	public static void constructDataForCompanySyncRetrial(List<List<Id>> accountIds){
        List<Database.SaveResult> results = null;
        Set<Id> accIds = new Set<Id>();
        for(List<Id> accId : accountIds){
             accIds.addAll(accId);
         }
        if(!accIds.isEmpty()){
            results = firePlatformEvents(accIds, true);
        }
    }
}