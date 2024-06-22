/**
* @description       : 
* @author            : Irfan Khan
* @group             : 
* @last modified on  : 01-12-2023
* @last modified by  : Irfan Khan
**/
@isTest
public class ContactRelatedListControllerTest{
    private final static string TEST_CURRENCYISOCODE = 'USD';
    private final static string TEST_ZIP = '45204';
    private final static string TEST_Shipping_PostalCode = '45204'; 
    private final static string TEST_Shipping_Country = 'US';
    private final static string TEST_Shipping_State = 'OR';
    
    @testSetup
    static void testDataSetup(){
        SIC_VALIDATION_SETTING__c svs = new SIC_VALIDATION_SETTING__c();
        svs.Name = 'SIC_VALIDATION_SETTING';
        svs.SIC_VALIDATION_FLAG__c = false;
        insert svs;
        
        TERRITORY_MANAGEMENT__c tm = new TERRITORY_MANAGEMENT__c();
        tm.Name = 'TERRITORY_MGMT_SETTING';
        tm.TM_FLAG__c = false;
        insert tm;
        
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
    } 
    
    static testMethod void testMethod1() 
        
    {
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Account acc = new Account(Name = 'Test ', WIN_ID__c ='D1234',Business_Type__c = 'Base', AccountSource = 'Phone', 
                                  CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', 
                                  Class__c = 'Agricultural Production',
                                  ShippingPostalCode = '45204',
                                  ShippingCountry = 'US',
                                  ShippingState = 'OR',
                                  ShippingStreet= 'Test Street',
                                  ShippingCity= 'Brookings',
                                  BillingPostalCode = '45204',
                                  BillingCountry = 'US',
                                  BillingState = 'OR',
                                  BillingStreet= 'Test Street',
                                  BillingCity = 'Brookings'); 
        System.debug('@@@@@@@test'+acc);
        //lstacc.add(acc);
        //insert lstacc;
        insert acc;
        
        list<Contact> lstcon=new list<Contact>();
        Contact cont = new Contact();
        cont.LastName ='Test';
        cont.FirstName ='Test';
        cont.title='test';
        cont.Contact_Type__c='AP';
        cont.Phone='8745263535';
        cont.Email='test@gmail.com';
        cont.Salutation='Mr';
        cont.Accountid = acc.id;
        cont.Expired__c = false;
        lstcon.add(cont);
        insert lstcon;
        System.assert(cont.Id != null, 'Error Inserting Contact');
        Contact cont1 = new Contact();
        cont1.LastName ='Test1';
        cont1.FirstName ='Test1';
        cont1.title='test1';
        //cont1.Expired__c='true';
        cont1.Contact_Type__c='PO';
        cont1.Phone='8545263535';
        cont1.Email='test1@gmail.com';
        cont1.Salutation='Mr';
        cont1.Accountid = acc.id;
        cont1.Expired__c = false;
        insert cont1;
        cont1.title='notest';
        update cont1;
        System.assert(cont1.Id != null, 'Error Inserting Contact1');
        
        Contact cont2 = new Contact();
        cont2.LastName ='Test2';
        cont2.FirstName ='Test2';
        cont2.title='test2';
        cont2.Contact_Type__c='ACCT';
        cont2.Phone='8545723535';
        cont2.Email='test2@gmail.com';
        cont2.Salutation='Mr';
        cont2.Accountid = acc.id;
        cont2.Expired__c = false;
        insert cont2;
        cont2.title='test12';
        update cont2;
        System.assert(cont2.Id != null, 'Error Inserting Contact2');
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.ContactDataDisplay;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc.id);            
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ContactRelatedListController contest = new ContactRelatedListController(sc);
        contest.newContact();
        contest.showHideConTypeDef();
        System.assert(contest.primaryContactTypes.size() != 0, 'No Primary Contact Types Set');
        System.assert(contest.additionalContactTypes.size() != 0, 'No Additional Contact Types');
        contest.contactsWrap.get(0).isUpdated = true;
        contest.contactsWrap.get(0).selectedContactId = cont2.Id;
        contest.save();
        contest.contactsOWrap.get(0).isUpdated = true;
        contest.save();
        contest.Cancel();
        contest.getContactDesc(cont2);
        contest.createNewContactType();
        Test.StopTest();
        
    }
    
    private static testmethod void testHttpCallout(){
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Account acc = new Account(Name = 'Test ', WIN_ID__c ='D1234',Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production'
                                 ); 
        insert acc;
        
        TestMockHttpResponseGenerator fakeResponse = new TestMockHttpResponseGenerator(200,'Complete','<string xmlns="http://schemas.microsoft.com/2003/10/Serialization/">diniscop@gmail.com</string>');
        
        Test.StartTest(); 
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        PageReference pageRef = Page.ContactDataDisplay;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc.id);            
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ContactRelatedListController contest = new ContactRelatedListController(sc);
        
        contest.getEmailAddressAPI();
        
        Test.stopTest();
    }
}