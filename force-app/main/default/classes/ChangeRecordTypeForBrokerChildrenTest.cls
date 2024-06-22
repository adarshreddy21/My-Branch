@isTest
public class ChangeRecordTypeForBrokerChildrenTest {
    @testSetup
    private static void setup(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration']; 
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
         Bypass_Account_Validation__c accountValidation = new Bypass_Account_Validation__c();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false;
        INSERT accountValidation;  
        
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
        for(Integer i = 0; i < 10; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                    Primary_Service_Provider_New__c = 'SK BPS')); //
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
        test.startTest();
        accList[0].ZIP_Master__c = zipMasterList[0].Id;
        insert accList;
        test.stopTest();
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
    }
    
    @isTest
    private static void unitTest(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'last',
            FirstName='First',
            Email = 'TEST@safety-kleen.com',
            Username = 'TEST@safety-kleen.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Primary_Business__c = 'Safety-Kleen'
        );
        insert u;
        
        Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id, Primary_Service_Provider_New__c='SK ENV'); 
        
        insert acc;
        
        Account acc1 = new Account(Name = 'Test2', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = branchRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id, parentid=acc.Id, ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street'); 
        
        insert acc1;
        
        Test.startTest();
        Database.executeBatch(new ChangeRecordTypeForBrokerChildren(acc.Id));
        Test.stopTest();
        
        Account accCh = [SELECT Id, RecordType.Name FROM Account WHERE Id = :acc1.Id];
        System.assert(accCh.RecordType.Name == 'Broker Location');
    }
}