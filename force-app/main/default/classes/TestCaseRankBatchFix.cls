@isTest
public class TestCaseRankBatchFix {
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
    private static testmethod void CaseRankBatchTestMethod (){
        
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
            
            Account accRank = new Account(Name='Rank Account',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555554',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',
                                          ownerid = u1.id, Status__c ='Active', WIN_ID__c = 'TS1234', ShippingPostalCode = '45204',
                                          ShippingCountry = 'US',
                                          ShippingState = 'OR',
                                          ShippingStreet= 'Test Street',
                                          ShippingCity= 'Brookings',
                                          BillingPostalCode = '45204',
                                          BillingCountry = 'US',
                                          BillingState = 'OR',
                                          BillingStreet= 'Test Street',
                                          BillingCity = 'Brookings');
            accRank.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            
            case caseRank1 = new case();
            caseRank1.Status = 'New';
            caseRank1.OwnerId = u1.id;
            caseRank1.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();
            
            Test.startTest();
            insert accRank;
            caseRank1.AccountId = accRank.Id;
            insert caseRank1;
            CaseRankBatchFix csBatch = new CaseRankBatchFix();
            Database.executeBatch(csBatch);
            Test.stopTest();    
        }
        
    }
    
}