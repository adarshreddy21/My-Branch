@isTest
public class EPAIdUpdateControllerTests {
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
    @testsetup
    static void setup(){
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
        
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

        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
			zipMasterList.add(new ZIP_Master__c(Zip__c = '10047',Country__c = 'US', State__c = 'NY',City__c = 'New York'));
         
        }
        insert zipMasterList;
            
        Territory_Master__c tmObj = new Territory_Master__c();  
        tmObj.name = 'Test TM'; 
        tmObj.ZIP_Master__c = zpObj.id; 
        tmObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;   
        tmObj.Sales_business_unit__C = 'lodging';           
        insert tmObj;
        
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account a = new Account(Name='Test Account',RecordTypeId=branchRecTypeId,Branch_Opportunity_Allowed__c =true ,AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555675',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',Branch_Call_Origin_Flag__c=TRUE,CurrencyIsoCode='USD');
        insert a;
        user activeUser =[select id from user where IsActive = True limit 1];
        Account accObj = new Account();
        accObj.Name =  TEST_NAME;
        accObj.dunbrdst__c = '12345';
        accObj.KAM_Manager__c = activeUser.id;
        accObj.KAM_Support__c = activeUser.id;
        accObj.OwnerId = activeUser.id;
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE;
        accObj.Rank__c = TEST_RANK;
        accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =  TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
        accObj.ShippingPostalCode = TEST_SHIPPING_POSTALCODE;
        accObj.ShippingCountry = TEST_SHIPPING_COUNTRY;
        accObj.ShippingState = TEST_SHIPPING_STATE;
        accObj.ShippingCity = TEST_SHIPPING_CITY;
        accObj.ShippingStreet = TEST_SHIPPING_STREET;
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        insert accObj;
        
        Account accObjCust = new Account();
        accObjCust.Name = TEST_NAME;
        accObjCust.Phone = TEST_PHONE;
        accObjCust.Type = TEST_TYPE;
        accObjCust.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObjCust.Rank__c = TEST_RANK;
        accObjCust.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObjCust.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObjCust.CS_EPA_ID__c = TEST_CS_EPA_ID;
         accObjCust.State_EPA_ID__c=TEST_CS_EPA_ID;
        accObjCust.Generator_Status__c = TEST_GENERATOR_STATUS;
        accObjCust.ShippingPostalCode = TEST_SHIPPING_POSTALCODE;
        accObjCust.ShippingCountry = TEST_SHIPPING_COUNTRY;
        accObjCust.ShippingState = TEST_SHIPPING_STATE;
        accObjCust.ShippingCity = TEST_SHIPPING_CITY;
        accObjCust.ShippingStreet = TEST_SHIPPING_STREET;
         
        accObjCust.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        accObjCust.ParentId = accObj.Id;
        insert accObjCust;
        
        Account gens = new Account();
        gens.ParentId = accObjCust.id;
        gens.Name = TEST_NAME;
        gens.Phone = TEST_PHONE;
        gens.Type = TEST_TYPE1; 
        gens.Business_Type__c = TEST_BUSINESS_TYPE;
        gens.Rank__c =  TEST_RANK;
        gens.WIN_ID__c = 'GI11503';
        gens.Industry_Segment__c = TEST_INDUSTRY_SEGMENT; 
        gens.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        gens.CS_EPA_ID__c = TEST_CS_EPA_ID;
        gens.Generator_Status__c = TEST_GENERATOR_STATUS;
        gens.Missing_Contact_Type__c=  TEST_MISSING_CONTACT_TYPE;
        gens.Status__c = TEST_STATUS;
        gens.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
        
        insert gens;
        EPA_SERVICE__c setting = new EPA_SERVICE__c();
        setting.Name = 'EPA_SERVICE_ENDPOINT';
        setting.ENDPOINT_URL__c = 'https:///websvcdev.cleanharbors.com//crmservices//api//epa//rules';

        insert setting;
    }
    @isTest
    private static void updateEPAIDTest(){

        Test.startTest();
            List<EPAIdUpdateController.EPAIdRequest> epaIdList = new List<EPAIdUpdateController.EPAIdRequest>();
            Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Customer'];
		    EPAIdMock epaMock=new EPAIdMock(false);
            Test.setMock(HttpCalloutMock.class, epaMock);
            EPAIdUpdateController.EPAIdRequest upAcc =new EPAIdUpdateController.EPAIdRequest();
            upAcc.accId = accRec.id;
            upAcc.epaIDValue = 'CS023';
            epaIdList.add(upAcc);
            EPAIdUpdateController.updateEPAID(epaIdList);
            Account updatedAccRec = [Select id,WIN_Compliance_Errors__c from Account where Id = :accRec.Id];
        Test.stopTest();

        Assert.areEqual(updatedAccRec.WIN_Compliance_Errors__c, null); 
    }
}