public without sharing class GuidedAccountCreateSetup {
    private static Map<Id, Profile> prfMap = new Map<Id, Profile>([SELECT id FROM Profile WHERE name IN ('Salesforce API Only System Integrations', 'Integration', 'Customer Service Light-EOC')]);
    private static Map<Id, Profile> prfMapMDM = new Map<Id, Profile>([SELECT id FROM Profile WHERE name IN ('Master Data Management')]);
    private final static string OPPORTUNITY_STAGE_PROSPECTING = '1 - Prospecting'; 

    @AuraEnabled 
    public static List<Account> getAccounts(String strAccountData) {
        AccountSetupWrappers.AccountWrapper  accWrapper =(AccountSetupWrappers.AccountWrapper ) System.JSON.deserialize(strAccountData, AccountSetupWrappers.AccountWrapper.class);
        AccountDuplicateSearch accountDupicateSearchObj = new AccountDuplicateSearch();
        Account[] duplicateMatchAccounts = accountDupicateSearchObj.classifyAndGetDuplicateAccounts(accWrapper);
        return duplicateMatchAccounts;
    } 
    @AuraEnabled 
    public static List<account> getDuplicateAccountsRecords(Id caseId) {
        Id childCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Field Change Request').getRecordTypeId();
        AccountSetupWrappers.AccountWrapper  accWrapper = new AccountSetupWrappers.AccountWrapper();
        Case caseRec = [Select id,recordTypeId,Accountid,Account.Name,Account.ShippingAddress,Account.recordTypeId,Account.parentId,ParentId from Case where id =: caseId];
        if(caseRec.recordTypeId== childCaseRecordTypeId)
        {
            caseRec = [Select id,Accountid,Account.Name,Account.ShippingAddress,Account.recordTypeId,Account.parentId from Case where id =: caseRec.ParentId];
        }
        AccountSetupWrappers.CorporateAddressWrapper corpAddress = new AccountSetupWrappers.CorporateAddressWrapper(); 
        corpAddress.ShippingStreet = caseRec.Account.ShippingAddress.getStreet();
        corpAddress.ShippingCity = caseRec.Account.ShippingAddress.getCity();
        corpAddress.ShippingState = caseRec.Account.ShippingAddress.getState();
        corpAddress.ShippingPostalCode = caseRec.Account.ShippingAddress.getPostalCode();
        corpAddress.ShippingCountry = caseRec.Account.ShippingAddress.getCountry();
        accWrapper.CorporateAddress = corpAddress;
        accWrapper.accountName = caseRec.Account.Name;
        accWrapper.recordTypeId =caseRec.Account.recordTypeId;
        accWrapper.parentId =caseRec.Account.parentId;
        AccountDuplicateSearch accountDupicateSearchObj = new AccountDuplicateSearch();
        Map<Id, Account> duplicateAccountMap = new Map<Id, Account>(accountDupicateSearchObj.classifyAndGetDuplicateAccounts(accWrapper));
        duplicateAccountMap.remove(caseRec.AccountId);
        return duplicateAccountMap.Values();
    }
     
    @AuraEnabled
    public static AccountSetupWrappers.OperationResult checkAddressinZipMaster(String corpCountry,String corpState,String corpCity, String corpPostalCode,
                                                 String billCountry,String billState,String billCity, String billPostalCode, Boolean hasCustomerOrBrokerParentAccount) {
        Set<String> corporateZips = new Set<String>();
        Set<String> billingZips = new Set<String>();
        List<Zip_Master__c> corpZipList = new List<Zip_Master__c>();     
        List<Zip_Master__c> billingZipList = new List<Zip_Master__c>();
        AccountSetupWrappers.OperationResult operationRes = new AccountSetupWrappers.OperationResult(); 		
    
        if(corpPostalCode != null){
            if(corpCountry == 'US') {
                corporateZips.add(corpPostalCode.trim().left(5));
            } else if(corpCountry == 'CA'){
                corporateZips.add(corpPostalCode.trim());
            }
        }
         // Checks if Billing zip code is populated
        if(billPostalCode != null) {
            if(billCountry == 'US') { 
                billingZips.add(billPostalCode.trim().left(5)); 
            } else if(billCountry == 'CA'){   
                billingZips.add(billPostalCode.trim());                                                                                                                                                      
            }
        }
        corpZipList = ZipMasterDAO.getZipMastersByPostalCodeCountryState(corporateZips, corpCountry, corpState);
        billingZipList = ZipMasterDAO.getZipMastersByPostalCodeCountryState(billingZips, billCountry, billState);
		if(!hasCustomerOrBrokerParentAccount)  
        if(corpZipList.isEmpty()){
            operationRes.status = 'Error';
            operationRes.message = 'The Corporate State/Province and Country codes are not in the zip code entered. (Check state and country codes again please)';
        } 
        else if(!hasCustomerOrBrokerParentAccount && billingZipList.isEmpty() ){
            operationRes.status = 'Error';
            operationRes.message = 'The Billing State/Province and Country codes are not in the zip code entered. (Check state and country codes again please)';
        }
        else{
            operationRes.status = 'Success';
            operationRes.message = 'Address found';
        }        
        return operationRes;       
    }

    @AuraEnabled
    public static AccountSetupWrappers.OperationResult checkManiAddressinZipMaster(String maniCountry,String maniState,String maniCity, String maniPostalCode) {
        Set<String> maniZips = new Set<String>();
        List<Zip_Master__c> maniZipList = new List<Zip_Master__c>(); 
        if(maniPostalCode != null){
            if(maniCountry == 'US') {
                maniZips.add(maniPostalCode.trim().left(5));
            } else if(maniCountry == 'CA'){
                maniZips.add(maniPostalCode.trim());
            }
        } 
        maniZipList = ZipMasterDAO.getZipMastersByPostalCodeCountryState(maniZips, maniCountry, maniState);
        AccountSetupWrappers.OperationResult operationRes = new AccountSetupWrappers.OperationResult();
        if(maniZipList.isEmpty()){
            operationRes.status = 'Error';
            operationRes.message = 'The Manifest State/Province and Country codes are not in the zip code entered. (Check state and country codes again please)';
        }
        else{
            operationRes.status = 'Success';
            operationRes.message = 'MANI Address found';
        }
        return operationRes;
    } 
 
    @AuraEnabled
    public static AccountSetupWrappers.AccountResponseWrapper checkEPAIdIsValid(AccountSetupWrappers.AccountDataWrapper accountDataWrapperObj) {
        AccountSetupWrappers.AccountResponseWrapper accountResWrapper = new AccountSetupWrappers.AccountResponseWrapper();
        if (accountDataWrapperObj != null && accountDataWrapperObj.country!='CA'
            && !prfMap.containsKey(userinfo.getProfileId())  
            && !prfMapMDM.containsKey(userinfo.getProfileId())) {
                Account accountRec = new Account(
                    CS_EPA_ID__c=accountDataWrapperObj.epaId,
                    GENREG__c = accountDataWrapperObj.genRegId,
                    ShippingCountry = accountDataWrapperObj.country,
                    Generator_Status__c = accountDataWrapperObj.generatorStatus,
                    State_EPA_ID__c = accountDataWrapperObj.stateEpaId,
                    ShippingStreet = accountDataWrapperObj.shippingStreet,
                    ShippingState = accountDataWrapperObj.shippingState,
                    ShippingCity = accountDataWrapperObj.shippingCity,
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_TYPE_CUSTOMER).getRecordTypeId(),
                    RecordType = new RecordType(DeveloperName=CHConstants.ACCOUNT_TYPE_CUSTOMER)
                );
                String tempPrimaryProvider;
                List<Old_New_Primary_Service_Provider_Mapping__mdt> primaryServiceProvMtdList = Old_New_Primary_Service_Provider_Mapping__mdt.getAll().values();
                for(Old_New_Primary_Service_Provider_Mapping__mdt primaryServiceProvObj : primaryServiceProvMtdList){
                    if(primaryServiceProvObj.Primary_Business__c == accountDataWrapperObj.primaryServiceProvider){
                        tempPrimaryProvider = primaryServiceProvObj.Primary_Service_Provider__c;
                        break;
                    } 
                }
                accountRec.Primary_Service_Provider__c = tempPrimaryProvider;
                accountResWrapper.response = AccountValidatorController.validateEPAId(accountRec);
            }
        else{
            accountResWrapper.isEPAValid = true;
        }
        
        return accountResWrapper;  
    }
  
    @AuraEnabled
    public static boolean deleteCustomDocument(String documentId) {
        try{
            ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Id = :documentId];
            delete contentDoc;
            return true;
        }
        Catch(exception e)
        {
            return false;
        }
    }
     
    @AuraEnabled
      public static Id createAccountAndRelatedInfoRecords(AccountSetupWrappers.AccountWrapper accWrapper) {
        List<Contact> contacts = new List<Contact>();
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
        AccountSetupWrappers.BillingAddressWrapper BillingAddress = accWrapper.BillingAddress;
        AccountSetupWrappers.CorporateAddressWrapper CorporateAddress = accWrapper.CorporateAddress;
        Account acc = new Account();
        acc.Name = accWrapper.accountName;
        acc.RecordTypeId = accWrapper.recordTypeId;
        acc.ShippingStreet = CorporateAddress.ShippingStreet;
        acc.ShippingCity = CorporateAddress.ShippingCity;
        acc.ShippingState = CorporateAddress.ShippingState;
        acc.ShippingPostalCode = CorporateAddress.ShippingPostalCode;
        acc.ShippingCountry = CorporateAddress.ShippingCountry;
        acc.Corporate_Address_2__c = CorporateAddress.CorporateAddress2;
        acc.BillingStreet = BillingAddress.BillingStreet; 
        acc.BillingCity = BillingAddress.BillingCity; 
        acc.BillingState = BillingAddress.BillingState;
        acc.BillingPostalCode = BillingAddress.BillingPostalCode;
        acc.BillingCountry = BillingAddress.BillingCountry;
        acc.Billing_Address_2__c = BillingAddress.BillingAddress2;
        acc.Primary_Service_Provider_New__c = accWrapper.primaryServiceProviderNew;
        acc.Same_as_Corp_Address__c = accWrapper.sameAsCorpAddress == true;
        acc.Primary_Business__c = accWrapper.primaryBusiness;
        acc.ParentId = String.isNotBlank(accWrapper.parentId) ? accWrapper.parentId : NULL;
		acc.Chain__c = String.isNotBlank(accWrapper.chainId) ? accWrapper.chainId : NULL;
        acc.CS_EPA_ID__c = accWrapper.epaId;
		acc.CurrencyIsoCode=accWrapper.currencyCode;
        acc.Generator_Status__c = accWrapper.generatorStatus;
        acc.State_EPA_ID__c = accWrapper.stateEpaId;
        acc.GENREG__c = accWrapper.genRegId;
        acc.Manifest_Address_Same_As_Corp__c = accWrapper.manifestAddressSameAsCorp != NULL ? accWrapper.manifestAddressSameAsCorp : false ;
        acc.Manifest_Address1__c = accWrapper.manifestAddress1;
        acc.Manifest_Locality1__c = accWrapper.manifestLocality1;
        acc.Manifest_Region_Code__c = accWrapper.manifestRegionCode;
        acc.Manifest_Post_Code__c = accWrapper.manifestPostalCode;
        acc.Manifest_Country_Code__c = accWrapper.manifestCountryCode;
        acc.Manifest_Address2__c = accWrapper.manifestAddress2;
        acc.SicDesc = accWrapper.sicDesc;
		acc.Sic_Code_Description__c = accWrapper.sicCodeDescription;
        acc.Tax_Exemption_Type__c = accWrapper.taxExemptionType;
        acc.AccountSource = accWrapper.accountSource;
        acc.Industry_Segment__c = accWrapper.industrySegment;
        acc.Class__c = accWrapper.accountClass;
        acc.Duplicate_Reason__c=accWrapper.duplicateReason;
        acc.Duplicate_Justification__c=accWrapper.duplicateJustification;
        acc.Phone= accWrapper.accountPhone;
        acc.Rank__c = accWrapper.rank;
        acc.SKO_Sales_Segment__c = accWrapper.skoSalesSegment;
        acc.Is_Created_Through_New_Account_Setup__c = true;
        acc.Broker_Group__c = accWrapper.brokergroup;

        try{
            Database.DMLOptions dml = new Database.DMLOptions(); 
			dml.DuplicateRuleHeader.AllowSave = true;
            Database.SaveResult sr = Database.insert(acc, dml);
            if(!sr.isSuccess())
            {
                String errorMessage = '';
                for(Database.Error err : sr.getErrors()) {
                    errorMessage += err.getMessage();                    
                }
                throw new AuraHandledException(errorMessage);
            }
            if(accWrapper.documentId != null && accWrapper.documentId !='')
            {
                List<Tax_Document__c> taxDocs =[Select Id from Tax_Document__c where Account__c =:acc.Id];
                if(taxDocs!=null && !taxDocs.IsEmpty())
                {
                    ContentDocumentLink cdl= new ContentDocumentLink();
                    cdl.ContentDocumentId = accWrapper.documentId;
                    cdl.LinkedEntityId = taxDocs[0].id;
                    insert cdl;
                }
            }
            if(accWrapper.contacts!= null){
                Contact con;
                for(AccountSetupWrappers.ContactsWrapper conRec : accWrapper.contacts){
                    if( conRec.contactType != null){
                        con = new Contact();
                        con.Salutation = conRec.salutation;
                        con.LastName = conRec.lastName;
                        con.FirstName = conRec.firstName;
                        con.Phone = conRec.phone;  
                        con.Title = conRec.title;                  
                        con.Email = conRec.email;
                        con.RLT_Contact__c = conRec.rltContact;
                        con.AccountId = acc.Id;
                        con.MobilePhone = conRec.mobile;
                        con.Phone_Extension__c = conRec.phoneExtension; 
                        List<String> contactTypeValues = conRec.contactType;
                        con.Contact_Type__c = String.join(contactTypeValues, ';');
                        contacts.add(con);
                    }
                }
                 try{
                        insert contacts;
                    }catch (Exception exe){
                        throw new AuraHandledException('Error while creating Contact:' + exe.getMessage());
                    }
                }
                if(accWrapper.autoCreateOpportunity == true){
                    Opportunity opp = new Opportunity();
                    opp.Name = accWrapper.accountName;
                    opp.AccountId = acc.Id;
                    if(!String.isBlank(accWrapper.opportunityRecordTypeId)){
                        opp.RecordTypeId = accWrapper.opportunityRecordTypeId;
                    }
                    opp.StageName = OPPORTUNITY_STAGE_PROSPECTING;
                    opp.CloseDate = Date.today().addMonths(3);
                    opp.Job_Start_Date__c = Date.today().addMonths(3);
                    try{
                        insert opp;
                    }catch (Exception exe){
                        throw new AuraHandledException('Error while creating Opportunity:' + exe.getMessage());
                    }
                }
                return acc.Id;
            } catch (Exception e){
            throw new AuraHandledException('Error while creating account:' + e.getMessage());
        }
    }
}