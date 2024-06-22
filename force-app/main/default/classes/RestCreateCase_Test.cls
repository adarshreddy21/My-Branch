@isTest
public class RestCreateCase_Test {
    private final static string TEST_CURRENCYISOCODE = 'USD';
    private final static string TEST_ZIP = '45204';
    private final static string TEST_Shipping_PostalCode = '45204'; 
    private final static string TEST_Shipping_Country = 'US';
    private final static string TEST_Shipping_State = 'OR';     
    @testSetup 
    private static void setup(){
        Bypass_Account_Validation__c accountValidation = new Bypass_Account_Validation__c();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false;
        INSERT accountValidation;
		
		Group testGroup = new Group(Name='queue', Type='Queue');
        insert testGroup;
        
        Group testGroup1 = new Group(Name='squeue', Type='Queue');
        insert testGroup1;
		
		System.runAs(new User(Id=UserInfo.getUserId())){
            List<QueueSobject> qs = new List<QueueSobject>();
            
            qs.add(new QueueSobject (
                SobjectType='Case',
                QueueId = testGroup1.Id
            ));
            
            Database.insert( qs );
			GroupMember queMem = new GroupMember();
            queMem.GroupId = testGroup1.Id;
            queMem.UserOrGroupId = UserInfo.getUserId();
            INSERT queMem;
        }
        
        Branch_Queue_Map__c branchQueueMap = new Branch_Queue_Map__c();
        branchQueueMap.Name = 'AA123';
		branchQueueMap.Branch_Queue__c = 'queue';
        INSERT branchQueueMap;
		
		Branch_Queue_Map__c branchQueueMap1 = new Branch_Queue_Map__c();
        branchQueueMap1.Name = 'S123';
        branchQueueMap1.Branch_Queue__c = 'squeue';
        INSERT branchQueueMap1;
        
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();	
        countrycodes.Name = 'CA';	
        insert countrycodes;	
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();	
        countrycodes1.Name = 'US';	
        insert countrycodes1;	
        
        ZIP_Master__c zpObj = new ZIP_Master__c();	
        zpObj.zip__c = TEST_ZIP;	
        zpObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        zpObj.Country__c = TEST_Shipping_Country;	
        zpObj.State__c = TEST_Shipping_State;	
        insert zpObj;	
        
        Territory_Master__c tmObj = new Territory_Master__c();	
        tmObj.name = 'Test TM';	
        tmObj.ZIP_Master__c = zpObj.id;	
        tmObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        tmObj.Sales_business_unit__C = 'lodging';       	
        insert tmObj;
        
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = false;
        insert sicValidation;
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id accCorporateRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        Test.startTest();
        Account corAcc = new Account(
            Name = 'Test ',       
            Business_Type__c = 'Base', 
            AccountSource = 'Phone',
            CS_EPA_ID__c = '12345', 
            ShippingCountry = TEST_Shipping_Country,
            ShippingState = TEST_Shipping_State,
        	ShippingStreet = 'Test Street',
       	    ShippingCity = 'Ashburn',
            ShippingPostalCode = TEST_ZIP,
            Sic = '0111', 
            dunbrdst__c = '12345',
        	KAM_Manager__c = UserInfo.getUserId(),
            RecordTypeId = accCorporateRecTypeId,                               
            Rank__c = 'CH A Large >200K',
            Reporting_Vertical__c = 'Automotive',
            Industry_Segment__c = 'Automotive',
            Class__c = 'Agricultural Production',
            ownerId = UserInfo.getUserId(), 
            Tax_Exemption_Type__c = 'Non Exempt',
            Primary_Service_Provider_New__c='SK ENV',
            KAM_Support__c = UserInfo.getUserId(),
            Buying_Decision__c = 'Central Buying'
        ); 
        
        INSERT corAcc; 
        
        
        Account acc = new Account(
            Name = 'Test ',       
            Business_Type__c = 'Base', 
            AccountSource = 'Phone',
            CS_EPA_ID__c = '12345', 
            Sic = '0111', 
            ShippingPostalCode = '45204',
            ShippingCountry = 'US',
            ShippingState = 'OR',
            ShippingStreet= 'Test Street',
            ShippingCity= 'Brookings',
            BillingPostalCode = '45204',
            BillingCountry = 'US',
            BillingState = 'OR',
            BillingStreet= 'Test Street',
            BillingCity = 'Brookings',
            RecordTypeId = accRecTypeId, 
            Tax_Exemption_Type__c = 'Non Exempt',
            Rank__c = 'CH A Large >200K',
            Reporting_Vertical__c = 'Automotive',
            Industry_Segment__c = 'Automotive',
            Class__c = 'Agricultural Production',
            ownerId = UserInfo.getUserId(), 
            Primary_Service_Provider_New__c='SK ENV',
            WIN_ID__c = '1234',
            ParentId = corAcc.Id
        ); 
        
        insert acc;
        
        Account acc1 = new Account(
            Name = 'Test ',       
            Business_Type__c = 'Base', 
            AccountSource = 'Phone',
            CS_EPA_ID__c = '12345', 
            Sic = '0111', 
            ShippingPostalCode = '45204',
            ShippingCountry = 'US',
            ShippingState = 'OR',
            ShippingStreet= 'Test Street',
            ShippingCity= 'Brookings',
            BillingPostalCode = '45204',
            BillingCountry = 'US',
            BillingState = 'OR',
            BillingStreet= 'Test Street',
            BillingCity = 'Brookings',
            Tax_Exemption_Type__c = 'Non Exempt',
            RecordTypeId = accRecTypeId,                               
            Rank__c = 'CH A Large >200K',
            Reporting_Vertical__c = 'Automotive',
            Industry_Segment__c = 'Automotive',
            Class__c = 'Agricultural Production',
            ownerId = UserInfo.getUserId(), 
            Primary_Service_Provider_New__c='SK ENV',
            Primary_Service_Provider__c='Safety Kleen',
            WIN_ID__c = '333'
        ); 
        
        insert acc1;
        
        Contact con = new Contact(AccountId = acc1.id);
        con.LastName = 'Contact';
        con.FirstName = 'Main';
        con.Salutation = 'Mr';
        con.Title = 'Default Mgr';
        con.Email = 'Main@default.com';
        con.Phone = '781-792-5000';
        con.Contact_Type__c = 'MAIN';
        insert con;
        Test.stopTest();
    }
    
    @isTest
    private static void createNewCaseTestNSB(){
        
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_NSB;
        reqObj.CUST_ID = '1234';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234';
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.CASE_TYPE = CHConstants.CASE_TYPE_SERVICE;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RestCreateCase.createnewcase();
        Test.stopTest();
        
        List<Case> caseLst = [SELECT Id from Case];
        System.assertEquals(caseLst.size(), 1);
    }
    
    @isTest
    private static void createNewCaseTestNSBCHES(){
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_NSB;
        reqObj.CUST_ID = '1234';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234';
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.CASE_TYPE = CHConstants.CASE_TYPE_SERVICE;
        reqObj.USER_ID = [SELECT Id, Alias FROM User WHERE Id = :UserInfo.getUserId()][0].Alias;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RestCreateCase.createnewcase();
        Test.stopTest();
        
        List<Case> caseLst = [SELECT Id from Case];
        System.assertEquals(caseLst.size(), 1);
    }
    
    private static testmethod void createNewCaseTestCOWB(){
        
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_COWB;
        reqObj.CUST_ID = '1234';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234';
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.CASE_TYPE = 'NOPO';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        RestCreateCase.createnewcase();
        
        List<Case> caseLst = [SELECT Id from Case];
        System.assertEquals(caseLst.size(), 1);
    }
    
    private static testmethod void createNewCaseTestInvDel(){
        
        Account accRec = [
            SELECT Id 
            FROM Account
            WHERE RecordType.Name = 'Corporate'
        ];
        
        accRec.KAM_Support__c = UserInfo.getUserId();
        UPDATE accRec;
        
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_INV_DEL;
        reqObj.CUST_ID = '1234';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234';
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.CASE_TYPE = 'NOPO';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RestCreateCase.createnewcase();
        Test.stopTest();
        
        List<Case> caseLst = [SELECT Id from Case];
        System.assertEquals(caseLst.size(), 1);
    }
    
    private static testmethod void createCaseUnitTestSafetyCleanNSB(){
        Account accRec = [
            SELECT Id 
            FROM Account
            WHERE WIN_ID__c = '333'
        ];
        
        accRec.KAM_Support__c = NULL;
        accRec.Buying_Decision__c = 'Locally Managed';
        UPDATE accRec;
        
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_NSB;
        reqObj.CUST_ID = '333';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234';
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.CASE_TYPE = 'NOPO';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RestCreateCase.createnewcase();
        Test.stopTest();
        
        List<Case> caseLst = [SELECT Id from Case];
        System.assertEquals(caseLst.size(), 1);
    }
    
    private static testmethod void createCaseUnitTestSafetyCleanCOWB(){
        Account accRec = [
            SELECT Id 
            FROM Account
            WHERE WIN_ID__c = '333'
        ];
        
        accRec.KAM_Support__c = NULL;
        accRec.Buying_Decision__c = 'Locally Managed';
        UPDATE accRec;
        
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_COWB;
        reqObj.CUST_ID = '333';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234'; 
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.CASE_TYPE = 'NOPO';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RestCreateCase.createnewcase();
        Test.stopTest();
        
        List<Case> caseLst = [SELECT Id from Case];
        System.assertEquals(caseLst.size(), 1);
    }
    private static testmethod void createCaseUnitTestSafetyCleanNSB1(){
        Account accRec = [
            SELECT Id 
            FROM Account
            WHERE WIN_ID__c = '333'
        ];
        
        accRec.KAM_Support__c = NULL;
        accRec.Buying_Decision__c = 'Central Buying';
        accRec.Primary_Service_Provider__c = 'Clean Harbors';
        UPDATE accRec;
        
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_NSB;
        reqObj.CUST_ID = '333';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234';
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.CASE_TYPE = 'NOPO';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        RestCreateCase.createnewcase();
        
        List<Case> caseLst = [SELECT Id from Case];
        System.assertEquals(caseLst.size(), 1);
    }
	
	
	 private static testmethod void createCaseUnitPO(){
        Account accRec = [
            SELECT Id 
            FROM Account
            WHERE WIN_ID__c = '333'
        ];
        Test.startTest();
        accRec.KAM_Support__c = NULL;
        accRec.Buying_Decision__c = 'Central Buying';
       // accRec.Primary_Service_Provider__c = 'Clean Harbors';
        UPDATE accRec;
        
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_COWB;
        reqObj.CUST_ID = '333';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234';
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.PO_TIMING = CHConstants.PO_TIMING;
        reqObj.CASE_TYPE = CHConstants.CASE_TYPE_SERVICE;
        reqObj.SERVICING_BRANCH = 'S123';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        RestCreateCase.createnewcase();
        Test.stopTest();
	    List<Case> caseLst = [SELECT Id from Case];
        System.assertEquals(caseLst.size(), 1);
    }
    
    private static testmethod void createCaseExceptionHandling(){
        Account accRec = [
            SELECT Id 
            FROM Account
            WHERE WIN_ID__c = '333'
        ];
        
        accRec.KAM_Support__c = NULL;
        accRec.Buying_Decision__c = 'Locally Managed';
        UPDATE accRec;
        
        RestCreateCase.RquestWrapper reqObj = new RestCreateCase.RquestWrapper();
        reqObj.SOURCE_APP = CHConstants.INTEGRATION_SOURCE_APP_NSB;
        reqObj.CUST_ID = '333';
        reqObj.DESCRIPTION = 'This is a description';
        reqObj.INVOICE_NUM = '1234';
        reqObj.INVOICE_VAL = '33';
        reqObj.SALESORDER_NUM = '1234';
        reqObj.BRANCH_CODE = 'AA123';
        reqObj.CASE_TYPE = 'NOPO';
        reqObj.GENERATOR_CODE = '551';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RestCreateCase.createnewcase();
        Test.stopTest();
		List<Exception_Log__c> excepLst = [SELECT Id from Exception_Log__c];
        System.assertEquals(excepLst.size(), 1);
    }
}