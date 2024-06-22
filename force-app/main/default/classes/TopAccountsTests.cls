/**
* @description       : 
* @author            : Gantla Adarsh Reddy
* @group             : 
* @last modified on  : 
* @last modified by  :  
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   03-21-2024   Gantla Adarsh Reddy  Initial Version 
**/ 
@isTest
public class TopAccountsTests {
    @testSetup 
    static void setupmethod() { 
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
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY'));
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
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Key_Account').getRecordTypeId();
        accList.add(new Account(Name = 'Test567', CS_EPA_ID__c = 'PENDING',Win_Id__c = 'TES123', RecordTypeId = recordTypeIdAccount, Sic = '0111',                              
                                Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                Primary_Service_Provider_New__c = 'SK ENV', Primary_Business__c = 'Safety-Kleen',ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street',
                                billingPostalCode = '12345', billingCountry = 'US' , billingState = 'NY', billingCity = 'Test City' , billingStreet = 'Test Street'
                               ));
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
        
        List<Financials__c> financialList = new List<Financials__c>();
        Financials__c financialRecord = new Financials__c(Account__c = accList[0].id, Customer_Amount__c = 100,Customer_Oil_Gallons_Collected__c = 100,
                                                          Amount__c =100, Location_Oil_Gallons_Collected__c =100);
        financialList.add(financialRecord);
        insert financialList; 
    }
    
    @isTest
    private static void testGetTopAccountsByLocation() {
        
        List<Account> accList = [select id, Name,CurrencyIsoCode from Account where Win_id__c = 'TES123'];
        
        Test.startTest();
        	List<List<WrapperForCAM>> result = TopAccounts.getTopAccountsByLocation(accList);
        Test.stopTest();
        
        List<WrapperForCAM> innerList = result[0];
        System.assertEquals(1, innerList.size(), 'Child accounts revenue grouped by city related to Corp account returned successfully');
    }
}