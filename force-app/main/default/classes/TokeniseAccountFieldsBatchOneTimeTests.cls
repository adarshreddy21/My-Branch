@isTest(SeeAllData=false)
public class TokeniseAccountFieldsBatchOneTimeTests {
    private final static string Error_Message = 'Accounts should not be null';
    private final static string TEST_Shipping_PostalCode = '45204';
    private final static string TEST_Shipping_Country = 'US';
    private final static string TEST_Shipping_State = 'OR';
    private final static string TEST_Shipping_City = 'Brookings';
    private final static string TEST_Shipping_Street = 'Test Street';
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
    @testSetup static void setupmethod() {
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
        zpObj.Country__c = TEST_Shipping_Country;	
        zpObj.State__c = TEST_Shipping_State;	
        insert zpObj;	
        
        Territory_Master__c tmObj = new Territory_Master__c();	
        tmObj.name = 'Test TM';	
        tmObj.ZIP_Master__c = zpObj.id;	
        tmObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        tmObj.Sales_business_unit__C = 'lodging';       	
        insert tmObj;
        
        Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.ShippingPostalCode = TEST_Shipping_PostalCode;	
        accObj.ShippingCountry = TEST_Shipping_Country;	
        accObj.ShippingState = TEST_Shipping_State;	
        accObj.ShippingCity = TEST_Shipping_City;	
        accObj.ShippingStreet = TEST_Shipping_Street;	
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
    }
    @IsTest static void testInvokeBatch(){
        
        TokeniseAccountFieldsBatchOneTime tab = new TokeniseAccountFieldsBatchOneTime();
        Id batchJobId = Database.executeBatch(tab, 20);
        List<AccountTokenisation__c> AccTokens = [Select id from AccountTokenisation__c limit 1];
        System.assertNotEquals(null, AccTokens, 'No Acount Tokens Inserted');
    }
    
}