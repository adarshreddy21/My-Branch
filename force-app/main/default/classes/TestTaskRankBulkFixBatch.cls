/**
* @description       : 
* @author            : Suresh Beniwal
* @group             : 
* @last modified on  : 10-04-2022
* @last modified by  : Suresh Beniwal 
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   10-04-2022   Suresh Beniwal   Initial Version
**/
@isTest
public class TestTaskRankBulkFixBatch {
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
    
    private static testmethod void EventRankBulkTest(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Inside Sales Agent'];//Inside Sales Latest Event
        UserRole R1 = [Select Id From UserRole where DeveloperName = 'SK_INS_BPS_AM'];
        
        //Inside sales latest event
        User usr =new User(Alias = 'standt'+ 1, Email='standarduser'+1+'@cleanharbors.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing '+ 1, LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p1.Id, UserRoleId = R1.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+1+'@cleanharbors.com');
        insert usr;
        
        System.runAs(usr) {
            TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
            territoryMgmt.Name = 'TERRITORY_MGMT_SETTING'; 
            territoryMgmt.TM_FLAG__c = true;
            insert territoryMgmt;
            
            SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
            sicValidation.Name = 'SIC_VALIDATION_SETTING';
            sicValidation.SIC_VALIDATION_FLAG__c = true;
            insert sicValidation;
            
            List<Account> accList = new List<Account>();
            
            Account acc1 = new Account (Name = 'Test 3', OwnerId = usr.id, RecordTypeId = accRecTypeId, Status__c = 'Active', win_id__c = 'AB1234',ShippingPostalCode = '45204',ShippingCountry = 'US', ShippingState = 'OR',ShippingStreet= 'City',ShippingCity= 'Brookings',BillingPostalCode = '45204',
                                        BillingCountry = 'US',BillingState = 'OR',BillingStreet= 'City',BillingCity = 'Brookings');
            
            accList.add(acc1);
            insert accList;
            Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
            
            List<Task> lt=new List<Task> {new task(
                recordTypeId=taskRecordTypeId,
                WhatID = acc1.Id,
                Subject='Test',
                ownerid = usr.id,
                Description='Testing Comments 123456789 123456789 1231456478 1234567897 123456798 1234564897',
                ActivityDate = system.today()
            )};
                
                Test.startTest();
            insert lt;
            TaskRankBulkFixBatch tskBatch = new TaskRankBulkFixBatch();
            Database.executeBatch(tskBatch);
            Test.stopTest();
        }
        
    }
    
}