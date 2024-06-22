/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-06-2022
 * @last modified by  : Irfan Khan
**/
@isTest
public class TestCaseCrudHandler { 
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
            
        Territory_Master__c tmObj = new Territory_Master__c();  
        tmObj.name = 'Test TM'; 
        tmObj.ZIP_Master__c = zpObj.id; 
        tmObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;   
        tmObj.Sales_business_unit__C = 'lodging';           
        insert tmObj;
        
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account a = new Account(Name='Test Account',RecordTypeId=branchRecTypeId,Branch_Opportunity_Allowed__c =true ,AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555675',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',Branch_Call_Origin_Flag__c=TRUE,CurrencyIsoCode='USD');
        insert a;
        user activeUser =[Select id from user where IsActive = True limit 1];
        Account accObj = new Account();
        accObj.Name =  TEST_NAME;
        accObj.Phone = TEST_PHONE;
        accObj.dunbrdst__c = '12345';
        accObj.ShippingCountry = TEST_Shipping_Country;
        accObj.ShippingState = TEST_Shipping_State;
        accObj.ShippingStreet = 'Test Street';
        accObj.ShippingCity = 'Ashburn';
        accObj.ShippingPostalCode = TEST_ZIP;
        accObj.KAM_Manager__c = activeUser.id;
        accObj.KAM_Support__c = activeUser.id;
        accObj.OwnerId = activeUser.id;
        accObj.Type = TEST_TYPE;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE;
        accObj.Rank__c = TEST_RANK;
        accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =  TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
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
        accObjCust.Generator_Status__c = TEST_GENERATOR_STATUS;
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
    }
    
 @isTest
    private static void Case(){
        
        Account a = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch'];
        Territory__c ter = new Territory__c();
        ter.Active_Territory__c = true;
        ter.Primary_Branch__c = a.Id;
        ter.Sales_Director__c = UserInfo.getUserId();
        ter.Territory_OwnerID__c = UserInfo.getUserId();
        insert ter;
        
        List<Product2>prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Create_Single_Revenue_Schedule__c = True;
        prod1.Name = 'Field Services';
        prodList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Create_Single_Revenue_Schedule__c = True;
        prod2.Name = 'Emergency Response Services';
        prodList.add(prod2);
        insert prodList;
        user activeUser =[select id from user where IsActive = True limit 1];
        Test.startTest();
            Account accObj = new Account();
            accObj.Name = TEST_NAME;
            accObj.Phone = TEST_PHONE;
            accObj.dunbrdst__c = '12345';
            accObj.ShippingCountry = TEST_Shipping_Country;
            accObj.ShippingState = TEST_Shipping_State;
            accObj.ShippingStreet = 'Test Street';
            accObj.ShippingCity = 'Ashburn';
            accObj.ShippingPostalCode = TEST_ZIP;
            accObj.KAM_Manager__c = activeUser.id;
            accObj.KAM_Support__c = activeUser.id;
            accObj.OwnerId = activeUser.id;
            accObj.Type = TEST_TYPE;
            accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
            accObj.Rank__c = TEST_RANK;
            accObj.WIN_ID__c = 'GIL310';
            accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj.CS_EPA_ID__c = TEST_CS_EPA_ID;
            accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
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
            accObjCust.CS_EPA_ID__c =  TEST_CS_EPA_ID;
            accObjCust.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObjCust.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            accObjCust.ParentId = accObj.Id;
            insert accObjCust;
        
            Account gens = new Account();
            gens.ParentId = accObjCust.id;
            gens.Name = 'Gillette';
            gens.Phone = TEST_PHONE;
            gens.Type = TEST_TYPE1;
            gens.Business_Type__c = TEST_BUSINESS_TYPE;
            gens.Rank__c =  TEST_RANK;
            gens.WIN_ID__c = 'GI11603';
            gens.Industry_Segment__c = 'Machinery Manufacturing';
            gens.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            gens.CS_EPA_ID__c = 'MP6174632383';
            gens.Generator_Status__c = TEST_GENERATOR_STATUS;
            gens.Missing_Contact_Type__c=TEST_MISSING_CONTACT_TYPE;
            gens.Status__c = TEST_STATUS;
            gens.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
            insert gens;
        
            Contact c = new Contact();
            c.Salutation = TEST_SALUTATION;
            c.FirstName = TEST_FIRST_NAME;
            c.LastName = TEST_LAST_NAME;
            c.Title = TEST_TITLE;
            c.Phone = TEST_PHONE;
            c.Email = TEST_EMAIL;
            c.AccountId = accObj.id;
            c.Department_Code__c = 'SALE';
            c.Contact_Type__c = 'SALE';             
            insert c;
        
            Beacon_Contact__c bc = new Beacon_Contact__c();
            bc.title__c = TEST_TITLE;
            bc.Phone__c = TEST_PHONE;
            bc.Email__c = TEST_EMAIL;
            bc.Department_Code__c = 'Sale';
            bc.Department__c = 'Sales';
            bc.Account_ID__c = accObjCust.Id;
            bc.Contact__c = c.id;
            insert bc;
               
            Technical_Sales_Expert__c tse = new Technical_Sales_Expert__c();
            tse.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            tse.Account__c = accobj.Id;
            tse.Technical_Sales_Expert_lookup__c = UserInfo.getUserId();
            tse.Product__c = prod1.id;
            insert tse;
            system.debug('accobj.Id-->'+accobj.Id);
            case casobj = new case();
            casobj.Type = TEST_CASE_TYPE;
            casobj.Effective_Date__c = system.today();
            casobj.AccountId = accobj.Id;
            casobj.Include_all_locations__c = true;
            casobj.Description = TEST_CASE_DESCRIPTION;
            casobj.CurrencyIsoCode =  TEST_CURRENCYISOCODE;
            casobj.Proposed_Specialist__c = UserInfo.getUserId();
            casobj.Specialist_Business__c = 'Field Services';
            casobj.Specialist_Products__c = 'Emergency Response Services';
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TSE - Add Case').getRecordTypeId();
       
           try{
            insert casobj;
        }catch(Exception exc){}
         Test.stopTest(); 
 
 }          

 @isTest    
    private static void method2(){
        
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
        accObj.ShippingPostalCode = TEST_Shipping_PostalCode;   
        accObj.ShippingCountry = TEST_Shipping_Country; 
        accObj.ShippingState = TEST_Shipping_State; 
        accObj.ShippingCity = TEST_Shipping_City;   
        accObj.ShippingStreet = TEST_Shipping_Street;   
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
   
    }  
    
 @isTest     
    private static void method3(){
        
        Test.startTest();
            Account accObj = new Account();
            accObj.Name = TEST_NAME;
            accObj.ShippingPostalCode = TEST_Shipping_PostalCode;   
            accObj.ShippingCountry = TEST_Shipping_Country; 
            accObj.ShippingState = TEST_Shipping_State; 
            accObj.ShippingCity = TEST_Shipping_City;   
            accObj.ShippingStreet = TEST_Shipping_Street;   
            accObj.Phone = TEST_PHONE;
            accObj.Type = TEST_TYPE;
            accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
            accObj.Rank__c = TEST_RANK;
            accObj.WIN_ID__c = 'GIL311';
            accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj.CS_EPA_ID__c = TEST_CS_EPA_ID;
            accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObj.Toggle_Me_to_Bypass_Validation__c = true;
            accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            insert accObj;
        
            Account accRec = [SELECT Id, OwnerId FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
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
			casobj.Proposed_Owner_Case_Approver__c=accRec.OwnerId;
            casobj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
			casObj.Is_Submitted_for_Approval__c = false;
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Update Validations').getRecordTypeId();
            insert casobj;
        
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = false;
            casObj.Unexpire_Reason__c = TEST_CASE_UNEXPIRE_REASON;
			casObj.Is_Submitted_for_Approval__c = true;
            update casObj;
        
            casObj.Old_Account_Name__c = 'test';
            casObj.status = 'Closed - Rejected';
			casObj.Is_Submitted_for_Approval__c = false;
            update casObj;
            
            accObj.ShippingPostalCode = TEST_Shipping_PostalCode;   
            accObj.ShippingCountry = TEST_Shipping_Country; 
            accObj.ShippingState = TEST_Shipping_State; 
            accObj.ShippingCity = TEST_Shipping_City;   
            accObj.ShippingStreet = TEST_Shipping_Street;   
            update accObj;
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = true;
			casObj.Is_Submitted_for_Approval__c = true;
            update casObj;
       Test.stopTest();
    
    } 
    
  @isTest
   private static void accountInactivateReactivateTest(){
        
        Test.startTest();
            Account accObj = new Account();
            accObj.Name = TEST_NAME;
            accObj.ShippingPostalCode = TEST_Shipping_PostalCode;   
            accObj.ShippingCountry = TEST_Shipping_Country; 
            accObj.ShippingState = TEST_Shipping_State; 
            accObj.ShippingCity = TEST_Shipping_City;   
            accObj.ShippingStreet = TEST_Shipping_Street;   
            accObj.Phone = TEST_PHONE;
            accObj.Type = TEST_TYPE;
            accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
            accObj.Rank__c = TEST_RANK;
            accObj.WIN_ID__c = 'GIL311';
            accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj.CS_EPA_ID__c = TEST_CS_EPA_ID;
            accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            insert accObj;
         
            Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
            case casobj = new case(); 
            casobj.Type = TEST_CASE_TYPE;
            casobj.Effective_Date__c = system.today();
            casobj.AccountId = accObj.Id;
            casobj.Current_Owner_Case_Approver__c = UserInfo.getUserId();
            casobj.Proposed_Owner__c = UserInfo.getUserId();
       		casobj.Proposed_Owner_Case_Approver__c = UserInfo.getUserId();     
            casobj.List_of_Postal_Codes__c = TEST_CASE_POSTAL_CODES;
            casobj.List_of_WIN_IDs__c = TEST_CASE_WIN_ID;
            casobj.Branch_Account__c = accRec.Id;
            casObj.Caller_s_First_Name__c = TEST_CASE_FIRST_NAME;
            casobj.Caller_s_Phone_Number__c = TEST_PHONE;
            casobj.Include_all_locations__c = false;
            casobj.Description = TEST_CASE_DESCRIPTION;
            casobj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inactivate Account').getRecordTypeId();
            insert casobj;
        
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = false;
            casObj.Request_Type__c = TEST_REQUEST_TYPE1;
            casObj.Unexpire_Reason__c = TEST_CASE_UNEXPIRE_REASON;
            casObj.No_Co_links_Active__c = True;
            casObj.No_Open_Opportunities__c = True;
            casObj.No_Open_Order_in_Order_Management_OM__c = True;
            casObj.No_Asset_Association_Services__c = True;
            casObj.No_Open_Orders_in_Account_Details__c = True;
            casObj.No_Invoice_Orders_in_Account_Details__c = True;
            casObj.No_Service_Master_listing__c = True;
            update casObj;
        
            casObj.Old_Account_Name__c = 'test';
            casObj.status = 'Closed - Rejected';
            casObj.Request_Type__c =TEST_REQUEST_TYPE1;
            update casObj;
        
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = true;
            update casObj;
       Test.stopTest();
       
} 
    
 @isTest
    private static void testNewCustomerRequest(){
              
    Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.ShippingPostalCode = TEST_Shipping_PostalCode;   
        accObj.ShippingCountry = TEST_Shipping_Country; 
        accObj.ShippingState = TEST_Shipping_State; 
        accObj.ShippingCity = TEST_Shipping_City;   
        accObj.ShippingStreet = TEST_Shipping_Street;
		accObj.BillingPostalCode =TEST_Shipping_PostalCode;
        accObj.BillingCountry = TEST_Shipping_Country;
        accObj.BillingState =TEST_Shipping_State;
        accObj.Billingcity=TEST_Shipping_City;
        accObj.BillingStreet =TEST_Shipping_Street;
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE ;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS ;
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
            casObj.Approve_with_Corrections__c = true;
            update casObj;
            casObj = [select id,recordTypeId, status from case WHERE Id = : casObj.Id ];
            System.assertEquals('Approved', casObj.status, 'Status should be Matched !!');
        Test.stopTest();
            
    }  
    
 @isTest
    private static void testNewCustomerRequest1(){
              
    Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE ;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS ;
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
            
            casObj.status =  'Closed - Rejected';
            update casObj;
            casObj = [select id,recordTypeId, status from case WHERE Id = : casObj.Id ];
            System.assertEquals( 'Closed - Rejected', casObj.status, 'Status should be Matched !!');
        Test.stopTest();
            
    }  
    
  @isTest
       private static void testCustomerMasterChangeShipToGenToCustomer(){
        
     Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.ShippingPostalCode = TEST_Shipping_PostalCode;   
        accObj.ShippingCountry = TEST_Shipping_Country; 
        accObj.ShippingState = TEST_Shipping_State; 
        accObj.ShippingCity = TEST_Shipping_City;   
        accObj.ShippingStreet = TEST_Shipping_Street;
		accObj.BillingPostalCode =TEST_Shipping_PostalCode;
        accObj.BillingCountry = TEST_Shipping_Country;
        accObj.BillingState =TEST_Shipping_State;
        accObj.Billingcity=TEST_Shipping_City;
        accObj.BillingStreet =TEST_Shipping_Street;		
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE ;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS ;
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
            casobj.Country__c = TEST_Shipping_Country;
            casobj.State__c = TEST_Shipping_State;
            casobj.Address_Line_1__c = TEST_Shipping_Street;
            casobj.City__c = TEST_Shipping_City;
            casobj.Postal_Code__c = TEST_Shipping_PostalCode;
            casobj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master - Change ShipTo/Gen To Customer').getRecordTypeId();
            casObj.Unexpire_Reason__c = TEST_CASE_UNEXPIRE_REASON;
            insert casobj;  
           
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = true;
            update casObj;
            casObj = [select id,recordTypeId, status from case WHERE Id = : casObj.Id ];
            System.assertEquals('Approved', casObj.status, 'Status should be Matched !!');
        Test.stopTest();
           
    }
  
 @isTest
     private static void testCustomerServiceCaseNew(){
        
     Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE ;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS ;
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
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Service Case(New)').getRecordTypeId();
            casObj.Unexpire_Reason__c = TEST_CASE_UNEXPIRE_REASON;
            insert casobj;  
         
            casObj.status = 'Closed';
            CaseComment   tComment = new CaseComment();
            tComment.ParentId = casobj.Id;
            tComment.CommentBody = TEST_CASE_COMEENT_BODY; 
            TestMockHttpResponseGenerator fakeResponse = new TestMockHttpResponseGenerator(200,'Complete',JSON.serialize('Success'));
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            INSERT tComment;
            update casObj; 
            casObj = [select id,recordTypeId, status from case WHERE Id = : casObj.Id ];
            system.assertEquals('Closed',  casObj.status, 'Status should be Matched !!');
        Test.stopTest(); 
         
    } 
    
 @isTest
    private static void testApprovewithCorrections(){
        
       Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS ;
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert accObj;
           
        Test.startTest();           
            Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];    
            case casobj = new case();
            casobj.AccountId = accObj.Id;
            casobj.New_Account_Name__c = 'Test Account';
            casobj.New_Business_Type__c = ' Base';
            casobj.New_EPA_ID__c = 'WERT';
            casobj.New_State_EPA_ID__c = 'WSDE12';
            casobj.New_GenReg_Id__c = 'ASWE12';
            casobj.New_Vertical__c = 'Automotive';
            casobj.New_Class__c = 'Airlines';
            casobj.New_SIC__c = 'ASWER';
            insert casobj; 
            casObj = [select id,New_EPA_ID__c from case WHERE Id = : casObj.Id ];
            system.assertEquals('WERT',  casObj.New_EPA_ID__c, 'New EPA ID should be Matched !!');
        Test.stopTest();
       
   }
    
  @isTest
     private static void testCustomerMasterReactivateAccount(){
        
       Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.ShippingPostalCode = TEST_Shipping_PostalCode;   
        accObj.ShippingCountry = TEST_Shipping_Country; 
        accObj.ShippingState = TEST_Shipping_State; 
        accObj.ShippingCity = TEST_Shipping_City;   
        accObj.ShippingStreet = TEST_Shipping_Street;   
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE ;
        accObj.WIN_ID__c=TEST_CASE_WIN_ID;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS ;
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert accObj;
        Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
        user us = [SELECT Id From User Limit 1];
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
        casObj.status = 'New';
        casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master - Reactivate Account').getRecordTypeId();
        casObj.Unexpire_Reason__c = TEST_CASE_UNEXPIRE_REASON;
        casObj.To_Be_Assigned_Account_Owner_ID__c = UserInfo.getUserId();
       
        Test.startTest();           
            insert casobj;    
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = true;
            update casObj;
            casObj = [select id,recordTypeId, status from case WHERE Id = : casObj.Id ];
            System.assertEquals('Approved', casObj.status, 'Status should be Matched !!');         
        Test.stopTest();  
    }  
       
  @isTest
       private static void testTSEAddCase(){
        
     Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE ;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS ;
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
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TSE - Add Case').getRecordTypeId();
            casObj.Unexpire_Reason__c = TEST_CASE_UNEXPIRE_REASON;
            casObj.Specialist_Products__c= 'Field Services';
            casObj.Specialist_Business__c = 'Field Services';
            insert casobj;
           
            casObj.Specialist_Business__c = 'Field Services';
            casObj.Specialist_Products__c = 'Emergency Response Services';
            update casObj;
            casObj = [select id,recordTypeId, Specialist_Business__c from case WHERE Id = : casObj.Id ];
            System.assertEquals('Field Services', casObj.Specialist_Business__c, 'Specialist Business should be Matched !!');
        Test.stopTest();
           
    } 
    
 @isTest        
    private static void method6(){
            Id customerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        Account acc = [SELECT Id FROM Account WHERE RecordTypeId = :customerId LIMIT 1];
            
        Test.startTest();            
            case casobj = new case();
            casobj.Type = 'Legal';
            casobj.Effective_Date__c = system.today();
            casobj.AccountId = acc.Id;
            casobj.WIN_Id__c = 'GIL210';
            casobj.Description = 'Test';
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();
            insert casobj;          
        Test.stopTest();
            
    }
    
     @isTest
     private static void method7(){
              
        List<User> userList = new List <User>();
        Profile p1 = [Select id from Profile where name = 'Inside Sales Agent'];
        UserRole R1 = [Select Id From UserRole where DeveloperName = 'SK_INS_BPS_AM'];
        User u1 = new User(Alias = 'isduser', Email='insidesalesuser@cleanharbors.com', 
                          EmailEncodingKey='UTF-8', LastName='Inside Sales User', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id, UserRoleId = R1.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='insidesalesuser@cleanharbors.com',Primary_Business__c='Safety-Kleen');
        userList.add(u1);
        insert userList;
        
       System.runAs(u1){
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
        Account accRank = new Account(Name='Rank Account',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='7885698747',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',
                                    ownerid = u1.id, Status__c ='Active', WIN_ID__c = 'TS1234',ShippingPostalCode = '45204',
                ShippingCountry = 'US',
                ShippingState = 'OR',
                ShippingStreet= 'Test Street123',
                ShippingCity= 'Brookings',
                BillingPostalCode = '45204',
                BillingCountry = 'US',
                BillingState = 'OR',
                BillingStreet= 'Test Street',
                BillingCity = 'Brookings');
        accRank.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        case caseRank = new case();
        caseRank.Status = 'New';
        caseRank.OwnerId = u1.id;
        
        caseRank.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();
       
        Test.startTest();           
            insert accRank;
            caseRank.AccountId = accRank.Id;
            insert caseRank;
            caseRank.Status = 'Closed - Completed';
            caseRank.IS_User_PO_Case_Queue_Member__c = !caseRank.IS_User_PO_Case_Queue_Member__c;
            update caseRank;           
        Test.stopTest();
           
       }
    }
    
 @isTest
    private static void testAccountControllerMethodsHPCCust() {
        Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.Phone = TEST_PHONE;
        accObj.Primary_business__c = 'Hpc Industrial';
        accObj.Type = TEST_TYPE;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.WIN_ID__c = 'A0002AD001';
        accObj.Toggle_Me_to_Bypass_Validation__c = true;
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
        
    }
    
  @isTest
     private static void testAccountControllerMethodsHPCCustLoc() {
         
         Test.startTest();        
            Account accObj1 = new Account();
            accObj1.Name = TEST_NAME;
            accObj1.Primary_Service_Provider_New__c = 'CHES Industrial';
            accObj1.Phone = TEST_PHONE;
            accObj1.Primary_business__c = 'Hpc Industrial';
            accObj1.Type = TEST_TYPE;
            accObj1.Business_Type__c = TEST_BUSINESS_TYPE; 
            accObj1.Rank__c = TEST_RANK;
            accObj1.WIN_ID__c = 'A0002AD003';
            accObj1.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj1.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj1.CS_EPA_ID__c = TEST_CS_EPA_ID;
            accObj1.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObj1.Toggle_Me_to_Bypass_Validation__c = true;
            accObj1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            insert accObj1;
         
            Account accObj = new Account();
            accObj.Name = 'Test Location';
            accObj.Phone = TEST_PHONE;
            accObj.ParentId = accObj1.id;
            accObj.Primary_business__c = 'Hpc Industrial';
            accObj.Type = 'Customer Location';
            accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
            accObj.Rank__c = TEST_RANK;
            accObj.WIN_ID__c = 'A0000034';
            accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj.CS_EPA_ID__c = TEST_CS_EPA_ID;
            accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObj.Toggle_Me_to_Bypass_Validation__c = true;
            accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
            insert accObj;       
        
            Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
            case casobj = new case();
            casobj.Type = 'New';
            casobj.Effective_Date__c = system.today();
            casobj.AccountId = accObj.Id;
            casobj.Proposed_Owner__c = UserInfo.getUserId();
            casobj.List_of_Postal_Codes__c = TEST_CASE_POSTAL_CODES;
            casobj.List_of_WIN_IDs__c = 'ECOMT2';
            casobj.Branch_Account__c = accRec.Id;
            casObj.Caller_s_First_Name__c = TEST_CASE_FIRST_NAME ;
            casobj.Caller_s_Phone_Number__c = TEST_PHONE;
            casobj.Include_all_locations__c = false;
            casobj.Description =TEST_CASE_DESCRIPTION;
            casobj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Customer Request').getRecordTypeId();
            insert casobj;
        
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = false;
            update casObj;         
        Test.stopTest();
         
    }   
    
  @isTest    
    private static void testAutoCloseCase() {
        Account accObj = new Account();
        accObj.Name = TEST_NAME;
        accObj.Phone = TEST_PHONE;
        accObj.Primary_business__c = 'Hpc Industrial';
        accObj.Type = TEST_TYPE;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObj.Rank__c = TEST_RANK;
        accObj.WIN_ID__c = 'A0002AD001';
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c = TEST_CS_EPA_ID;
        accObj.Toggle_Me_to_Bypass_Validation__c = true;
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
            casobj.List_of_WIN_IDs__c = 'ECOMT2';
            casobj.Branch_Account__c = accRec.Id;
            casObj.Caller_s_First_Name__c = TEST_CASE_FIRST_NAME;
            casobj.Caller_s_Phone_Number__c = TEST_PHONE;
            casobj.Include_all_locations__c = false;
            casobj.Description = TEST_CASE_DESCRIPTION;
            casobj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer PO Case').getRecordTypeId();
            insert casobj;
        Test.stopTest();
        
    } 
    @isTest    
    private static void testremoveAccountRelatedContactsfromCadence() {
        Test.startTest();
            Account accObj = new Account();
            accObj.Name = TEST_NAME;
            accObj.ShippingPostalCode = TEST_Shipping_PostalCode;	
            accObj.ShippingCountry = TEST_Shipping_Country;	
            accObj.ShippingState = TEST_Shipping_State;	
            accObj.ShippingCity = TEST_Shipping_City;	
            accObj.ShippingStreet = TEST_Shipping_Street;	
            accObj.Phone = TEST_PHONE;
            accObj.Type = TEST_TYPE;
            accObj.Business_Type__c = TEST_BUSINESS_TYPE; 
            accObj.Rank__c = TEST_RANK;
            accObj.WIN_ID__c = 'GIL311';
            accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj.CS_EPA_ID__c = TEST_CS_EPA_ID;
            accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            insert accObj;
        
            Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
            case casobj = new case();
            casobj.Type = TEST_CASE_TYPE;
            casobj.Effective_Date__c = system.today();
            casobj.AccountId = accObj.Id;
            casobj.Current_Owner_Case_Approver__c = UserInfo.getUserId();
            casobj.Proposed_Owner__c = UserInfo.getUserId();
       		casobj.Proposed_Owner_Case_Approver__c = UserInfo.getUserId();       
            casobj.List_of_Postal_Codes__c = TEST_CASE_POSTAL_CODES;
            casobj.List_of_WIN_IDs__c = TEST_CASE_WIN_ID;
            casobj.Branch_Account__c = accRec.Id;
            casObj.Caller_s_First_Name__c = TEST_CASE_FIRST_NAME;
            casobj.Caller_s_Phone_Number__c = TEST_PHONE;
            casobj.Include_all_locations__c = false;
            casobj.Description = TEST_CASE_DESCRIPTION;
            casObj.Request_Type__c = TEST_REQUEST_TYPE1;
            casobj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inactivate_Account').getRecordTypeId();
            insert casobj;
        
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = false;
            casObj.Request_Type__c = TEST_REQUEST_TYPE1;
            casObj.Unexpire_Reason__c = TEST_CASE_UNEXPIRE_REASON;
            casObj.No_Co_links_Active__c = True;
            casObj.No_Open_Opportunities__c = True;
            casObj.No_Open_Order_in_Order_Management_OM__c = True;
       	    casObj.No_Asset_Association_Services__c = True;
            casObj.No_Open_Orders_in_Account_Details__c = True;
            casObj.No_Invoice_Orders_in_Account_Details__c = True;
            casObj.No_Service_Master_listing__c = True;
            update casObj;
        
            casObj.Old_Account_Name__c = 'test';
            casObj.status = 'Closed - Rejected';
            casObj.Request_Type__c =TEST_REQUEST_TYPE1;
            update casObj;
        
            casObj.status = 'Approved';
            casObj.Approve_with_Corrections__c = true;
            update casObj;
       Test.stopTest();
        
    } 
	
	@isTest
    private static void testvalidateCPGCaseSubmission() {
        
        List<Account> accounts = [Select Id,name from Account where  Win_Id__c ='GI11503'];
        List<User> users =[select id,name from user where isActive = True and EmployeeNumber!=null];
        List<Case> lstCase = new List<Case>();
        case newcase = new case ();
        Id cpgCaseRecordType = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('CPG_Request').getRecordTypeId();
        newcase.Subject = 'CPG Case';
        newCase.AccountId = accounts[0].id;
        newCase.Profile_Number__c = '45687';
        newCase.RecordTypeId = cpgCaseRecordType;
        newCase.Waste_Description__c = 'Test Description';
        newCase.CPG_Owner__c = users[0].Id;
        newCase.Incomplete_Profile_Comments__c = 'Test Profile Instructions.';
        insert newcase;
        lstCase.add(newCase);
        
        Test.startTest();
        	CaseCRUDHandler.validateCPGCaseSubmission(lstCase);
        Test.stopTest();
        System.assertEquals(0, lstCase[0].getErrors().size(), 'CPG Case is not allowed to Submit for Approval');
    }

}