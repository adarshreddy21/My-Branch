@isTest
public class AccountValidatorControllerTest {
    @testSetup 
    private static void setupRecords() {
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id keyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Key Account').getRecordTypeId(); 
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
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY',City__c = 'Newyork'));
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
            accList.add(
                new Account(
                    Name = 'Test ' + i, 
                    Business_Type__c = 'Base',
                    AccountSource = 'Phone',
                    CS_EPA_ID__c = '12345',
                    Sic = '0111', 
                    RecordTypeId = accRecTypeId, 
                    Rank__c = 'CH A Large >200K', 
                    Reporting_Vertical__c = 'Automotive', 
                    Industry_Segment__c = 'Automotive', 
                    Class__c = 'Agricultural Production', 
                    Primary_Service_Provider_New__c = 'SK ENV',
                    Primary_Business__c = 'SK ENV',
                    ShippingPostalCode = '12345-0000',
                    ShippingCountry = 'US',
                    ShippingState = 'NY',
                    ShippingStreet= 'Street 1',
                    ShippingCity= 'Newyork'
                )
            );
                accList.add(
                 new Account(
                    Name = 'Test ',
                    Business_Type__c = 'Base',
                    AccountSource = 'Phone', 
                    CS_EPA_ID__c = 'PENDING', 
                    Sic = '0111',
                    RecordTypeId = keyRecordTypeId,
                    Rank__c = 'CH A Large >200K',
                    Reporting_Vertical__c = 'Automotive', 
                    Industry_Segment__c = 'Automotive',
                    Class__c = 'Agricultural Production',
                    Type = 'Key Account',
                    Generator_Status__c = 'Small Quantity Generator',
                    Primary_Service_Provider__c = 'Safety Kleen',
                    Primary_Business__c = 'SK ENV',
                    Primary_Service_Provider_New__c = 'SK ENV',
                    ShippingPostalCode = '12345-0000',
                    ShippingCountry = 'US',
                    ShippingState = 'NY',
                    ShippingStreet= 'Street 1',
                    ShippingCity= 'Newyork'
                )
            );
        }
        Territory__c t = new Territory__c();
        t.name = 'TS-AM-Camarillo-CA-01';
        t.Territory_OwnerID__c = UserInfo.getUserId();
        INSERT t;
        Territory_Master__c tm = new Territory_Master__c();
        tm.ZIP_Master__c = zipMasterList[0].Id;
        tm.Sales_Business_Unit__c = 'BPS';
        tm.Name = 'SK BPS IS';
        tm.Territory_ID__c = t.Id;
        INSERT tm;
        accList[0].ZIP_Master__c = zipMasterList[0].Id;
        insert accList;
        
    }
    
    @isTest
    private static void testValidateAccountUnitForValidEPAId(){
        
        Account acc = [Select Id from Account where recordType.Name = 'Key Account' limit 1];
        AccountValidatorController.validateAccount(acc.Id);
        
        acc.BillingCountry = 'CA';
        acc.BillingState = 'NJ';
        acc.BillingPostalCode = '12345';
        acc.BillingStreet= 'Street 1';
        acc.BillingCity = 'BR'; 
        acc.GENREG__c = 'abc';
		acc.Cycle__c = 'Committed';
        acc.ShippingPostalCode = '12345';
        acc.ShippingCountry = 'US';
        acc.ShippingState = 'NY';
		acc.ShippingStreet= 'Street 1';
		acc.ShippingCity= 'BR';
        acc.Manifest_Post_Code__c = '12345';
        acc.Manifest_Country_Code__c = 'US';
        acc.Manifest_Region_Code__c = 'NY';
		acc.Manifest_Locality1__c = 'Street 1';
		acc.Manifest_Address1__c = 'Street 2';
        acc.WIN_ID__c = '';
        acc.Win_Validation_NonRollupAccount__c = false;
        update acc;
        
        Tax_Document__c taxDoc = new Tax_Document__c();
        taxDoc.Account__c = acc.Id;
        INSERT taxDoc;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = taxDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        Contact con = new Contact(AccountId = acc.Id);
        con.LastName = 'Contact';
        con.FirstName = 'Main';
        con.Salutation = 'Mr';
        con.Title = 'Default Mgr';
        con.Email = 'Main@default.com';
        con.Phone = '781-792-5000';
        con.Contact_Type__c = 'MAIN';
        insert con;

        EPAIdMock epaMock=new EPAIdMock(true);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, epaMock);
            AccountValidatorController.ValidateResponse validateRes = AccountValidatorController.validateAccount(acc.Id);
        Test.stopTest();
        
        System.assertEquals(true, validateRes.isSuccess);
    }

    @isTest
    private static void testValidateAccountUnitForInvalidEPAId(){

        Account acc = [Select Id from Account where recordType.Name = 'Customer' Limit 1];
        AccountValidatorController.validateAccount(acc.Id);
        
        acc.BillingCountry = 'CA';
        acc.BillingState = 'NJ';
        acc.BillingPostalCode = '12345';
        acc.BillingStreet= 'Street 1';
        acc.BillingCity = 'BR'; 
        acc.GENREG__c = 'abc';
        acc.ShippingPostalCode = '12345';
        acc.ShippingCountry = 'US';
        acc.ShippingState = 'NY';
		acc.ShippingStreet= 'Street 1';
		acc.ShippingCity= 'BR';
        acc.Manifest_Post_Code__c = '12345';
        acc.Manifest_Country_Code__c = 'US';
        acc.Manifest_Region_Code__c = 'NY';
		acc.Manifest_Locality1__c = 'Street 1';
		acc.Manifest_Address1__c = 'Street 2';
        acc.WIN_ID__c = '';
        acc.Win_Validation_NonRollupAccount__c = false;
        update acc;
        
        Tax_Document__c taxDoc = new Tax_Document__c();
        taxDoc.Account__c = acc.Id;
        INSERT taxDoc;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = taxDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        Contact con = new Contact(AccountId = acc.Id);
        con.LastName = 'Contact';
        con.FirstName = 'Main';
        con.Salutation = 'Mr';
        con.Title = 'Default Mgr';
        con.Email = 'Main@default.com';
        con.Phone = '781-792-5000';
        con.Contact_Type__c = 'MAIN';
        insert con;

        EPAIdMock epaMock=new EPAIdMock(false);
        Test.setMock(HttpCalloutMock.class, epaMock);
        
        Test.startTest();      
            AccountValidatorController.ValidateResponse validateRes = AccountValidatorController.validateAccount(acc.Id);
        Test.stopTest();
        
        System.assertEquals(false, validateRes.isSuccess);
    }
    @isTest
    private static void validateCompetitorRFOOAccountUnitTest(){
        Id competitorAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_COMPETITOR_DeveloperName).getRecordTypeId();
    
        user u = [select id from user where profile.name='System administrator' limit 1];
		
        Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = competitorAccountRecordType,
                                      Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',Type = 'Key Account',
                                      ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street',
                                      billingPostalCode = '12345', billingCountry = 'US' , billingState = 'NY', billingCity = 'Test City' , billingStreet = 'Test Street'
                                     );
        INSERT acc;
        
        acc.BillingCountry = 'CA';
        acc.BillingState = 'NJ';
        acc.BillingPostalCode = '12345';
        acc.BillingStreet= 'Street 1';
        acc.BillingCity = 'BR'; 
        acc.GENREG__c = 'abc';
        acc.ShippingPostalCode = '12345';
        acc.ShippingCountry = 'US';
        acc.ShippingState = 'NY';
		acc.ShippingStreet= 'Street 1';
		acc.ShippingCity= 'BR';
        acc.Manifest_Post_Code__c = '12345';
        acc.Manifest_Country_Code__c = 'US';
        acc.Manifest_Region_Code__c = 'NY';
		acc.Manifest_Locality1__c = 'Street 1';
		acc.Manifest_Address1__c = 'Street 2';
        acc.WIN_ID__c = '';
        update acc;
        
        Tax_Document__c taxDoc = new Tax_Document__c();
        taxDoc.Account__c = acc.Id;
        INSERT taxDoc;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = taxDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        Account accountObj = [SELECT Id FROM Account LIMIT 1];
        
        accountObj.ParentId = acc.Id;
        accountObj.Win_Validation_NonRollupAccount__c = false;
        accountObj.Status__c = 'Active';
        UPDATE accountObj;
        
        EPAIdMock epaMock=new EPAIdMock(false);
        Test.setMock(HttpCalloutMock.class, epaMock);
        
        Test.startTest();
			AccountValidatorController.updateWinValidateNoRollupChildAccounts(acc);
            AccountValidatorController.ValidateResponse validateRes = AccountValidatorController.validateAccount(acc.Id);
        Test.stopTest();
        
        System.assertEquals(true, validateRes.isSuccess);
    } 
}