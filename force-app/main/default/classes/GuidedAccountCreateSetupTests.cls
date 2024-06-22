/**
* @description       : 
* @author            : Gantla Adarsh Reddy
* @group             : 
* @last modified on  : 
* @last modified by  :  
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   02-07-2024   Gantla Adarsh Reddy  Initial Version 
**/
@isTest
public class GuidedAccountCreateSetupTests {
     private final static string ERROR_MESSAGE = 'Accounts should not be null';
     private final static string TEST_SHIPPING_POSTALCODE = '45204';
     private final static string TEST_SHIPPING_COUNTRY = 'US';
     private final static string TEST_SHIPPING_STATE = 'OR';
     private final static string TEST_SHIPPING_CITY = 'Brookings';
     private final static string TEST_SHIPPING_STREET = 'Test Street';
     private final static string TEST_NAME = 'Gillette Company';
     private final static string TEST_PHONE = '799856414';
     private final static string TEST_TYPE =  'Customer';
     private final static string TEST_TYPE1 = 'ShipTo/Gen';
     private final static string TEST_BUSINESS_TYPE = 'Base'; 
     private final static string TEST_RANK = 'CH A Large >200K';
     private final static string TEST_INDUSTRY_SEGMENT = 'Chemical';
     private final static string TEST_INDUSTRY_SEGMENT1 = 'Machinery Manufacturing';
     private final static string TEST_CURRENCYISOCODE = 'USD';
     private final static string TEST_CS_EPA_ID = 'PENDING';
     private final static string TEST_GENERATOR_STATUS = 'Large Quantity Generator'; 
     private final static string TEST_MISSING_CONTACT_TYPE = 'MAIN';
     private final static string TEST_STATUS = 'Active';
     private final static string TEST_ZIP = '45204';
     private final static string TEST_SALES_BUSINESS_UNIT = 'lodging';  
     private final static string TEST_CASE_TYPE = 'New';
     private final static string TEST_CASE_POSTAL_CODES = '02061';
     private final static string TEST_CASE_WIN_ID = 'ECOMT2';
     private final static string TEST_CASE_FIRST_NAME = 'ABC';
     private final static string TEST_CASE_DESCRIPTION = 'Test';
     private final static string TEST_CASE_UNEXPIRE_REASON = 'Account needs to be serviced';
     private final static string TEST_CASE_CALL_CENTER_ACTIVITY_ID = 'ASDE234';
     private final static string TEST_CASE_COMEENT_BODY = 'This is closed because no need of service';
     private final static string TEST_FIRST_NAME = 'Test'; 
     private final static string TEST_LAST_NAME = 'Test';
     private final static string TEST_SALUTATION = 'Mr';    
     private final static string TEST_TITLE = 'title';
     private final static string TEST_EMAIL = 'Test1@testemail.com';
     private final static string TEST_REQUEST_TYPE1 = 'Inactivation Request';
    @testSetup static void setupRecords() {
       
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration'];  
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        EPA_SERVICE__c endpoint = new EPA_SERVICE__c();
        endpoint.Name = 'EPA_SERVICE_ENDPOINT';
        endpoint.ENDPOINT_URL__c = 'https://websvctest.cleanharbors.com/CrmServices/Api/Epa/Rules';
        insert endpoint;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        List<User> userList = new List<User>();
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@safety-kleen.com', 
            EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+i+'@safety-kleen.com'));
        }
        insert userList; 
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY'));
            zipMasterList.add(new ZIP_Master__c(Zip__c = 'A1A 1A1',Country__c = 'CA', State__c = 'ON'));
        }
        insert zipMasterList;
        
        Set<Id> sicCodesSet = new Set<Id>();
        List<SIC_Codes__c> sicCodesList = new List<SIC_Codes__c>();
        for(Integer i = 0; i < 10; i++){
            sicCodesList.add(new SIC_Codes__c(SIC_Code__c =  '011' + i, Class__c = 'Agricultural Production'));
        }
        insert sicCodesList;
        
        for(SIC_Codes__c sicCodesLoop : sicCodesList){
            sicCodesSet.add(sicCodesLoop.Id);
        }
        
        sicCodesList.clear();
        
        for(SIC_Codes__c sicCodesLoop : [SELECT Name,SIC_Code__c from SIC_Codes__c WHERE Id IN :sicCodesSet ]){
            sicCodesList.add(sicCodesLoop);
        }

        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 10; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   Primary_Service_Provider_New__c = 'SK BPS')); //
        }
        Territory__c t = new Territory__c();
        t.name = 'TS-AM-Camarillo-CA-01';
        t.Territory_OwnerID__c = UserInfo.getUserId();
        insert t;
        Territory_Master__c tm = new Territory_Master__c();
        tm.ZIP_Master__c = zipMasterList[0].Id;
        tm.Sales_Business_Unit__c = 'BPS';
        tm.Name = 'SK BPS IS';
        tm.Territory_ID__c = t.Id;
        insert tm;
        test.startTest();
        accList[0].ZIP_Master__c = zipMasterList[0].Id;
        insert accList;
        test.stopTest();
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
		
		 COUNTRY_CODES__c countrycodes11 = new COUNTRY_CODES__c();	
         countrycodes11.Name = 'CA';	
         insert countrycodes11;	
         	
         COUNTRY_CODES__c countrycodes12 = new COUNTRY_CODES__c();	
         countrycodes12.Name = 'US';	
         insert countrycodes12;	
         	
         ZIP_Master__c zpObj = new ZIP_Master__c();	
        zpObj.zip__c = TEST_ZIP;	
        zpObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        zpObj.Country__c = TEST_SHIPPING_COUNTRY;	
        zpObj.State__c = TEST_SHIPPING_STATE;	
        insert zpObj;	
        	
        Territory_Master__c tmObj = new Territory_Master__c();	
        tmObj.name = 'Test TM';	
        tmObj.ZIP_Master__c = zpObj.id;	
        tmObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        tmObj.Sales_business_unit__C = 'lodging';        	
        insert tmObj;
        
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account a = new Account(Name='Test Account',RecordTypeId=branchRecTypeId,Branch_Opportunity_Allowed__c =true ,AccountSource='Web',Rank__c=TEST_RANK, Industry_Segment__c='Other',Phone='5555555675',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',Branch_Call_Origin_Flag__c=TRUE,CurrencyIsoCode='USD');
        insert a;
        
        
        
       
    }
    @isTest
	private static void testgetDuplicateAccountsRecords() {
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
        
       Account accObj = new Account();
        accObj.Name = TEST_NAME;
		accObj.ShippingPostalCode = TEST_SHIPPING_POSTALCODE;	
        accObj.ShippingCountry = TEST_SHIPPING_COUNTRY;	
        accObj.ShippingState = TEST_SHIPPING_STATE;	
        accObj.ShippingCity = TEST_SHIPPING_CITY;	
        accObj.ShippingStreet = TEST_SHIPPING_STREET;	
        accObj.Same_as_Corp_Address__c =true;	
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c = TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert accObj;
        
        Test.startTest();
            Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
            case casobj = new case();
            casobj.Type = TEST_CASE_TYPE;
            casobj.Effective_Date__c = system.today();
            casobj.AccountId = accObj.Id;
            casobj.Proposed_Owner__c = UserInfo.getUserId();
            casobj.List_of_Postal_Codes__c = TEST_CASE_POSTAL_CODES;
            casobj.List_of_WIN_IDs__c = TEST_CASE_WIN_ID;
            casobj.Branch_Account__c = accRec.Id;
            casObj.Caller_s_First_Name__c = TEST_CASE_FIRST_NAME;
            casobj.Caller_s_Phone_Number__c = TEST_PHONE;
            casobj.Include_all_locations__c = false;
            casobj.Description = TEST_CASE_DESCRIPTION;
            casobj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Customer Request').getRecordTypeId();
            insert casobj;
        
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = false;
            update casObj;
        Test.stopTest();
        List<Account> accs = GuidedAccountCreateSetup.getDuplicateAccountsRecords(casObj.id);
         System.assertNotEquals(null, accs, ERROR_MESSAGE);
    }
	@isTest
	private static void testgetDuplicateAccountsRecordsCustGen() {
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj; 
		insertDuplicateAccounts();
        Account accObj1 = new Account();
            accObj1.Name = TEST_NAME;
            accObj1.ShippingPostalCode = TEST_SHIPPING_POSTALCODE;	
            accObj1.ShippingCountry = TEST_SHIPPING_COUNTRY;	
            accObj1.ShippingState = TEST_SHIPPING_STATE;	
            accObj1.ShippingCity = TEST_SHIPPING_CITY;	
            accObj1.ShippingStreet = TEST_SHIPPING_STREET;	
            accObj1.Same_as_Corp_Address__c =true;	
            accObj1.Phone = TEST_PHONE;
            accObj1.WIN_Id__c = 'TT10655';
            accObj1.Status__c = 'active';
            accObj1.Type = TEST_TYPE;
            accObj1.Business_Type__c = TEST_BUSINESS_TYPE; 
            accObj1.Rank__c = TEST_RANK;
            accObj1.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj1.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj1.CS_EPA_ID__c = TEST_CS_EPA_ID;
            accObj1.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObj1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert accObj1;
        Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.ParentId = accObj1.Id;
		accObj.ShippingPostalCode = TEST_SHIPPING_POSTALCODE;	
        accObj.ShippingCountry = TEST_SHIPPING_COUNTRY;	
        accObj.ShippingState = TEST_SHIPPING_STATE;	
        accObj.ShippingCity = TEST_SHIPPING_CITY;	
        accObj.ShippingStreet = TEST_SHIPPING_STREET;	
        accObj.Same_as_Corp_Address__c =true;	
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Status__c = 'active';
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c = TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
        insert accObj;
        List<AbbreviationMapping__mdt> abbrList = AbbreviationMapping__mdt.getAll().values();
        List<AccountTokenisation__c> recordsToInsert= new List<AccountTokenisation__c>();
        List<Account> accountList =[SELECT Id,shippingpostalcode,shippingstreet,ShippingCity,shippingcountry,name FROM Account where  status__c in ('active','inactive')  and ShippingStreet <>null and ShippingPostalCode<> null and ShippingCountry<>null];
        for(Account acc:accountList){
                    AccountTokenisation__c accountTokenisationRecord;
                    string tokenisedValue = Accounts.tokeniseAccountFields(acc.ShippingStreet, abbrList); 
					string tokenisedPostalCodeValue= acc.ShippingPostalCode.normalizeSpace().trim();
					if(acc.ShippingCountry.equalsIgnoreCase('US') && tokenisedPostalCodeValue.contains('-')){
					    tokenisedPostalCodeValue= tokenisedPostalCodeValue.split('-')[0];
                    }					
                           
                                    accountTokenisationRecord= new AccountTokenisation__c();
                                    accountTokenisationRecord.Account__c=acc.Id;
                                    accountTokenisationRecord.TokenisedStreet__c=tokenisedValue;
									accountTokenisationRecord.TokenisedShippingPostalCode__c= tokenisedPostalCodeValue;
                                    recordsToInsert.Add(accountTokenisationRecord);
                               
                    
                }
                if(!recordsToInsert.isempty()){
                    insert recordsToInsert;
                }
             
        Test.startTest();
            Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
            case casobj = new case();
            casobj.Type = TEST_CASE_TYPE;
            casobj.Effective_Date__c = system.today();
            casobj.AccountId = accObj.Id;
            casobj.Proposed_Owner__c = UserInfo.getUserId();
            casobj.List_of_Postal_Codes__c = TEST_CASE_POSTAL_CODES;
            casobj.List_of_WIN_IDs__c = TEST_CASE_WIN_ID;
            casobj.Branch_Account__c = accRec.Id;
            casObj.Caller_s_First_Name__c = TEST_CASE_FIRST_NAME;
            casobj.Caller_s_Phone_Number__c = TEST_PHONE;
            casobj.Include_all_locations__c = false;
            casobj.Description = TEST_CASE_DESCRIPTION;
            casobj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Customer Request').getRecordTypeId();
            insert casobj;
        
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = false;
            update casObj;
        Test.stopTest();
        List<Account> accs = GuidedAccountCreateSetup.getDuplicateAccountsRecords(casObj.id);
         System.assertNotEquals(null, accs, ERROR_MESSAGE);
    }
    public static void insertDuplicateAccounts()
    {
        List<Account> accObjList = new List<Account>();
        for(integer i=0;i <10;i++){
            Account accObj1 = new Account();
            if(i==0){
                accObj1.Name = 'Test Name';
                accObj1.ShippingStreet = 'Street';
            }
            else if(i==1){
                accObj1.Name = 'Testame';
                accObj1.ShippingStreet = 'Testreet';
            }
            else if(i==2){
                accObj1.Name = 'NameName';
                accObj1.ShippingStreet = 'TestStreet';
            }
            else if(i==3){
                accObj1.Name = 'Testme';
                accObj1.ShippingStreet = 'Street Test Street';
            }
            else if(i==4){
                accObj1.Name = 'Test Test Name';
                accObj1.ShippingStreet = 'Street';
            }
            else if(i==5){
                accObj1.Name = 'Name Test Name';
                accObj1.ShippingStreet = 'Test 123 Street';
            }
            else if(i==6){
                accObj1.Name = 'TestName';
                accObj1.ShippingStreet = '123 Test Street';
            }
            else{
                accObj1.Name = 'TestName'+i;
                accObj1.ShippingStreet = '123 Test Street'+i;
            }
            
            accObj1.ShippingPostalCode = TEST_SHIPPING_POSTALCODE;	
            accObj1.ShippingCountry = TEST_SHIPPING_COUNTRY;	
            accObj1.ShippingState = TEST_SHIPPING_STATE;	
            accObj1.ShippingCity = TEST_SHIPPING_CITY;
            accObj1.Same_as_Corp_Address__c =true;	
            accObj1.Phone = TEST_PHONE;
            accObj1.WIN_Id__c = 'TT1066'+i;
            accObj1.Status__c = 'active';
            accObj1.Type = TEST_TYPE;
            accObj1.Business_Type__c = TEST_BUSINESS_TYPE; 
            accObj1.Rank__c = TEST_RANK;
            accObj1.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj1.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj1.CS_EPA_ID__c = TEST_CS_EPA_ID;
            accObj1.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObj1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            accObjList.add(accObj1);
        }
        insert accObjList;
        
    }

    @isTest
	private static void testGetAccounts() {
        AccountSetupWrappers.AccountWrapper wrapper = new AccountSetupWrappers.AccountWrapper(); 
        wrapper.accountName = 'Test Account';
        AccountSetupWrappers.CorporateAddressWrapper corpAddress = new AccountSetupWrappers.CorporateAddressWrapper();
        corpAddress.ShippingStreet = '123 Test St';
        corpAddress.ShippingCity = 'Newyork';
        corpAddress.ShippingState = 'NY';
        corpAddress.ShippingPostalCode = '12345';
        corpAddress.ShippingCountry = 'US';
        wrapper.CorporateAddress = corpAddress;
        List<Account> accounts = GuidedAccountCreateSetup.getAccounts(JSON.serialize(wrapper));
        System.assertNotEquals(null, accounts, ERROR_MESSAGE);
    } 
    
   
    @isTest
    private static void testCheckAddressinZipMaster() {
        Zip_Master__c zipMasterUS = [select id, Country__c from Zip_Master__c where Country__c = 'US' Limit 1];
        Zip_Master__c zipMasterCA = [select id, Country__c from Zip_Master__c where Country__c = 'CA' Limit 1];
            
        AccountSetupWrappers.OperationResult resultUS = GuidedAccountCreateSetup.checkAddressinZipMaster('US', 'NY', 'City', '12345', 'US', 'NY', 'City', '12345', false);
        System.assertEquals('Success', resultUS.status, 'Expected result status is Success for US addresses');
        
        AccountSetupWrappers.OperationResult resultCA = GuidedAccountCreateSetup.checkAddressinZipMaster('CA', 'ON', 'City', 'A1A 1A1', 'CA', 'ON', 'City', 'A1A 1A1', false);
        System.assertEquals('Success', resultCA.status, 'Expected result status is Success for CA addresses');
        
        AccountSetupWrappers.OperationResult resultInvalidCorp = GuidedAccountCreateSetup.checkAddressinZipMaster('US', 'NY', 'City', '54321', 'US', 'NY', 'City', '12345', false);
        System.assertEquals('Error', resultInvalidCorp.status, 'Expected result status is Error for invalid corporate address');
        
        AccountSetupWrappers.OperationResult resultInvalidBill = GuidedAccountCreateSetup.checkAddressinZipMaster('US', 'NY', 'City', '12345', 'US', 'NY', 'City', '54321', false);
        System.assertEquals('Error', resultInvalidBill.status, 'Expected result status is Error for invalid billing address');
    }
    
    @isTest
    private static void testCheckManiAddressinZipMaster() {
        Zip_Master__c zipMasterUS = [select id, Country__c from Zip_Master__c where Country__c = 'US' Limit 1];
        Zip_Master__c zipMasterCA = [select id, Country__c from Zip_Master__c where Country__c = 'CA' Limit 1];
        
        AccountSetupWrappers.OperationResult resultUS = GuidedAccountCreateSetup.checkManiAddressinZipMaster('US', 'NY', 'City', '12345');
        System.assertEquals('Success', resultUS.status, 'Expected result status is Success for valid US address');
        
        AccountSetupWrappers.OperationResult resultCA = GuidedAccountCreateSetup.checkManiAddressinZipMaster('CA', 'ON', 'City', 'A1A 1A1');
        System.assertEquals('Success', resultCA.status, 'Expected result status is Success for valid CA address');
        
        AccountSetupWrappers.OperationResult resultInvalid = GuidedAccountCreateSetup.checkManiAddressinZipMaster('US', 'NY', 'City', '54321');
        System.assertEquals('Error', resultInvalid.status, 'Expected result status is Error for invalid address');
    }
    
    @isTest
	private static void testCheckEPAIdIsValid() { 
        AccountSetupWrappers.AccountDataWrapper testData = new AccountSetupWrappers.AccountDataWrapper();
        testData.country = 'US';
        testData.epaId = 'CESQG';
        testData.genRegId = '1234';
        testData.generatorStatus = 'Undetermined';
        testData.stateEpaId = 'pending';
        testData.shippingStreet = '123 Main St';
        testData.shippingState = 'NY';
        testData.shippingCity = 'Newyork';
        testData.primaryServiceProvider = 'SK ENV';
       
        EPAIdMock epaMock=new EPAIdMock(true);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, epaMock);
            AccountSetupWrappers.AccountResponseWrapper result = GuidedAccountCreateSetup.checkEPAIdIsValid(testData);
        	System.assertNotEquals(True, result.isEPAValid, 'EPA should be valid'); 
        Test.stopTest();
    }
    
    @isTest
    private static void testCreateAccountd() {
        Id customerAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        AccountSetupWrappers.AccountWrapper accWrapper = new AccountSetupWrappers.AccountWrapper();
        accWrapper.accountName = 'Test Account';
        accWrapper.primaryServiceProviderNew = 'SK ENV';
        accWrapper.generatorStatus = 'Undetermined';
        accWrapper.sameAsCorpAddress = true;
        accWrapper.epaId = 'pending';
        accWrapper.recordTypeId = customerAccountRecTypeId;

        AccountSetupWrappers.BillingAddressWrapper billingAddress = new AccountSetupWrappers.BillingAddressWrapper();
        billingAddress.BillingStreet = '123 Test St';
        billingAddress.BillingCity = 'Newyork';
        billingAddress.BillingState = 'NY';
        billingAddress.BillingPostalCode = '12345';
        billingAddress.BillingCountry = 'US';
        billingAddress.BillingAddress2 = 'BillingAddress2';
        accWrapper.billingAddress = billingAddress;

        AccountSetupWrappers.CorporateAddressWrapper corporateAddress = new AccountSetupWrappers.CorporateAddressWrapper();
        corporateAddress.ShippingStreet = '123 Test St';
        corporateAddress.ShippingCity = 'Newyork';
        corporateAddress.ShippingState = 'NY';
        corporateAddress.ShippingPostalCode = '12345';
        corporateAddress.ShippingCountry = 'US';
        corporateAddress.CorporateAddress2 = 'CorporateAddress2';
        accWrapper.corporateAddress = corporateAddress;

        AccountSetupWrappers.ContactsWrapper contact = new AccountSetupWrappers.ContactsWrapper();
        contact.salutation = 'Mr';
        contact.contactType = new List<String>{'MAIN'};
        contact.firstName = 'John';
        contact.lastName = 'Doe';
        contact.phone = '9437433774';
        contact.email = 'john.doe@example.com';
        contact.rltContact = false;
        contact.phoneExtension = '';
        contact.accountId = null;

        accWrapper.contacts = new List<AccountSetupWrappers.ContactsWrapper>{contact};

        Test.startTest();
        	Id accountId = GuidedAccountCreateSetup.createAccountAndRelatedInfoRecords(accWrapper);
        Test.stopTest();
      
        System.assert(accountId != null, 'Account should have been created');
        Account createdAccount = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        System.assertEquals('Test Account', createdAccount.Name, 'Account name should match');
        List<Contact> createdContacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId = :accountId];
        System.assertEquals(1, createdContacts.size(), 'There should be one contact created');
        Contact createdContact = createdContacts[0];
        System.assertEquals('John', createdContact.FirstName, 'Contact first name should match');
        System.assertEquals('Doe', createdContact.LastName, 'Contact last name should match');
        System.assertEquals('john.doe@example.com', createdContact.Email, 'Contact email should match');
    }
}