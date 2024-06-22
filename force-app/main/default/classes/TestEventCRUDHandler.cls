/**
* @description       : 
* @author            : Suresh Beniwal
* @group             : 
* @last modified on  : 01-12-2023
* @last modified by  : Irfan Khan
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   10-04-2022   Suresh Beniwal   Initial Version
**/
@isTest
public class TestEventCRUDHandler {
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
    static testMethod void method1(){
        
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
            for(Integer i = 0; i < 2; i++){
                accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                        Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor'
                                       ));
            }
            
            Account acc3 = new Account (Name = 'Test 3', OwnerId = usr.id, RecordTypeId = accRecTypeId, Status__c = 'Active', win_id__c = 'AB1234',ShippingPostalCode = '45204',
                                        ShippingCountry = 'US',
                                        ShippingState = 'OR',
                                        ShippingStreet= 'Test Street',
                                        ShippingCity= 'Brookings',
                                        BillingPostalCode = '45204',
                                        BillingCountry = 'US',
                                        BillingState = 'OR',
                                        BillingStreet= 'Test Street',
                                        BillingCity = 'Brookings');
            Account acc4 = new Account (Name = 'Test 4', OwnerId = usr.id, RecordTypeId = accRecTypeId, Status__c = 'Active', win_id__c = 'CD2345',ShippingPostalCode = '45204',
                                        ShippingCountry = 'US',
                                        ShippingState = 'OR',
                                        ShippingStreet= 'Test Street',
                                        ShippingCity= 'Brookings',
                                        BillingPostalCode = '45204',
                                        BillingCountry = 'US',
                                        BillingState = 'OR',
                                        BillingStreet= 'Test Street',
                                        BillingCity = 'Brookings');
            
            accList.add(acc3);
            accList.add(acc4);
            insert accList;
            account acc = accList[0];
            
            list<event> evt=new list<event>{ new event(
                whatId=acc.Id,
                // Call_Type__c='  Add Line Item',
                Description='Testing Commentst Testing CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting Commentst',
                Subject='Call',
                Event_Type__c='Face to Face',
                StartDateTime=system.today(),
                EndDateTime=system.today()+5
            ),
                new event(//inside sales latest event
                    whatId=acc3.Id,
                    ownerid = usr.id,
                    Description='Testing Commentst Testing CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting Commentst',
                    Subject='Call',
                    Event_Type__c='Face to Face',
                    Event_Classifcation__c = 'Prospecting',
                    StartDateTime=system.today(),
                    EndDateTime=system.today()+1
                    
                )};
				
               Database.DMLOptions dml = new Database.DMLOptions(); 
		       dml.DuplicateRuleHeader.AllowSave = true;
		       Database.SaveResult[] sr = Database.insert(evt, dml);
            
            //Inside Sales Activity Rank
            evt[1].whatId=acc4.Id;
              Database.DMLOptions dml1 = new Database.DMLOptions(); 
		       dml1.DuplicateRuleHeader.AllowSave = true;
		       Database.SaveResult[] sr1 = Database.update(evt, dml1);
            
            List<Task> lt=new List<Task> {new task(
                WhatID = acc.Id,
                Caller_First_Name__c='Test',
                Caller_Last_Name__c='Task',
                Description='Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments Testing CommentsTesting Comments Testing Comments',
                Type='Call',
                status='In Progress',
                Priority='Normal',
                Lead_Company_Name__c='test',
                Lead_Country__c='US'
            )};
                insert lt;
        }
        
    } 
}