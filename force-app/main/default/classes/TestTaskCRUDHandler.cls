/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
**/
@isTest
public class TestTaskCRUDHandler {
     private final static string TEST_CURRENCYISOCODE = 'USD';
 private final static string TEST_ZIP = '45204';
 private final static string TEST_Shipping_PostalCode = '45204'; 
 private final static string TEST_Shipping_Country = 'US';
 private final static string TEST_Shipping_State = 'OR';
    
    @testSetup 
    private static void setupReords() {
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration'];
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Inside Sales Agent'];
        UserRole R1 = [Select Id From UserRole where DeveloperName = 'SK_INS_BPS_AM'];
        
        
        
        List<User> userList = new List<User>();
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@cleanharbors.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+i+'@cleanharbors.com'));
        }
        
        // Inside sales user latest task for account rankning
        userList.add(new User(Alias = 'standt'+ 11, Email='standarduser'+11+'@cleanharbors.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing '+ 11, LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p1.Id, UserRoleId = R1.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+11+'@cleanharbors.com'));
        
        
        insert userList;
        
       System.runAs(userList[0]) {
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;    
       
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
        test.startTest();
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 10; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production')); //
        }
        Account acc3 = new Account (Name = 'Test 11', OwnerId = userList[10].id, RecordTypeId = accRecTypeId, Status__c = 'Active', win_id__c = 'AB1234',ShippingPostalCode = '45204',
                ShippingCountry = 'US',
                ShippingState = 'OR',
                ShippingStreet= 'Test Street',
                ShippingCity= 'Brookings',
                BillingPostalCode = '45204',
                BillingCountry = 'US',
                BillingState = 'OR',
                BillingStreet= 'Test Street',
                BillingCity = 'Brookings');
        Account acc4 = new Account (Name = 'Test 12', OwnerId = userList[10].id, RecordTypeId = accRecTypeId, Status__c = 'Active', win_id__c = 'CD2345',ShippingPostalCode = '45204',
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
        test.stopTest();
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
     }
    }
    
    static testMethod void method1(){
        
        Account accObj = new Account();
        accObj.Name = 'Gillette Company';
        accObj.Phone = '7885696515';
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base';
        accObj.ShippingPostalCode = '45204';
                accObj.ShippingCountry = 'US';
                accObj.ShippingState = 'OR';
                accObj.ShippingStreet= 'Test Street';
                accObj.ShippingCity= 'Brookings';
                accObj.BillingPostalCode = '45204';
                accObj.BillingCountry = 'US';
                accObj.BillingState = 'OR';
                accObj.BillingStreet= 'Test Street';
                accObj.BillingCity = 'Brookings';
        accObj.Rank__c = 'CH A Large >200K';
        //accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert accObj;
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        
        User u = [Select id, name, profile.name From User where LastName='Testing 11' limit 1];//inside sales latest task
        List<Account> InsideSalesAcc = [Select id From Account where Name = 'Test 11'];
            SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
            svsObj.name = 'SIC_VALIDATION_SETTING';
            svsObj.SIC_VALIDATION_FLAG__c = true;
            insert svsObj;
            
            TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
            tmgObj.name = 'TERRITORY_MGMT_SETTING';
            tmgObj.TM_FLAG__c = true; 
            insert tmgObj;
            List<Task> lt=new List<Task> {new task(
                WhatID = accObj.Id,
                Caller_First_Name__c='Test',
                Caller_Last_Name__c='Task',
                Description='Testing Comments 123456789 123456789 1231456478 1234567897 123456798 1234564897',
                Call_Type__c='  Add Line Item',
                status='In Progress',
                Priority='Normal',
                Service_Order_Number__c ='34567887',
                Primary_Type_of_Service__c ='UMO',
                Lead_Company_Name__c='test',
                Lead_Country__c='US'
            ),new task(
                recordTypeId=taskRecordTypeId,
                WhatID = accObj.Id,
                Caller_First_Name__c='Test',
                Caller_Last_Name__c='Task',
                Description='Testing Comments 123456789 123456789 1231456478 1234567897 123456798 1234564897',
                Call_Type__c='  Add Line Item',
                status='In Progress',
                Service_Order_Number__c ='34567887',
                Primary_Type_of_Service__c ='UMO',
                Priority='Normal',
                Lead_Company_Name__c='test',
                Lead_Country__c='US'
            ), 
                new task(//inside sales latest task for Inside Sales Activity Rank
                    recordTypeId=taskRecordTypeId,
                    WhatID = InsideSalesAcc[0].Id,
                    Subject='Test',
                    ownerid = u.id,
                    Description='Testing Comments 123456789 123456789 1231456478 1234567897 123456798 1234564897',
                    ActivityDate = system.today()
                )};
                    
                    test.startTest();
            insert lt;
            
             test.stopTest();
        }
        
        private static  void  testAutoCreateCase(){
       Account accObj = new Account();
        accObj.Name = 'Gillette Company';
        accObj.Phone = '9674849333';
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base'; 
        accObj.Rank__c = 'CH A Large >200K';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert accObj;
       
       Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account a = new Account(Name='Test Account',RecordTypeId=branchRecTypeId,Branch_Opportunity_Allowed__c =true ,AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555675',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',Branch_Call_Origin_Flag__c=TRUE,CurrencyIsoCode='USD');
        insert a;
       Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Center Activity').getRecordTypeId();
        Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Service Case(New)').getRecordTypeId();
               task t = new task();
                t.recordTypeId=devRecordTypeId;
                t.WhatID = accObj.Id;
                t.Caller_First_Name__c='Test';
                t.Caller_Last_Name__c='Task';
                t.Description='Testing Comments 123456789 123456789 1231456478 1234567897 123456798 1234564897';
               t.Call_Type__c='Change Address';
                t.status='New';
                t.Priority='Normal';
                t.Resolution_3__c = a.id;
                t.Primary_Type_of_Service__c ='Service Term';
                t.Escalation__c = '1';
               t.subject= 'Service Term';
               t.Caller_Phone__c ='9573839333';
              insert t;

           Test.starttest();

                 Case c = new case();
              c.Call_Center_Activity_ID__c= t.id;
              c.Caller_s_First_Name__c='Test';
              c.Caller_s_Last_Name__c='Task';
              c.origin ='Phone';
              c.Status = 'New';
              c.Priority = 'Normal';
              c.Call_Reason__c = 'Service Term';
              c.Branch_Account__c=t.Resolution_3__c;
              c.Type_of_Call__c ='Change Address';
              c.Subject = 'Service Term';
              c.Caller_s_Phone_Number__c ='9573839333';
              c.Level_1_Escalation__c = true;
              c.Description ='Testing Comments 123456789 123456789 1231456478 1234567897 123456798 1234564897';
             Insert c;

            Test.stoptest();
       
    } 

}