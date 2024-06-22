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
public class UpdateAccountTerritoryQueueHandlerTest {
    @testSetup
    private static void setupData(){
        Id accRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPORATE).getRecordTypeId();
        Id customerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration']; 
        User activeUser = [Select id from User where isActive = True Limit 1];
		
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        Bypass_Account_Validation__c accountValidation = new Bypass_Account_Validation__c();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false;
        INSERT accountValidation;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
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
        
        Account accRec = new Account();
        accRec.Name = 'Parent Corporate Account';
		accRec.dunbrdst__c = '12345';
        accRec.KAM_Manager__c = activeUser.id;
        accRec.KAM_Support__c = activeUser.id;
        accRec.RecordTypeId = accRecTypeId;
        accRec.Buying_Decision__c = 'Central Buying';
        accRec.Account_Assign_Override__c = false;
        accRec.Status__c = 'Active';
        accRec.ShippingPostalCode = '12345';
        accRec.ShippingCountry = 'US';
        accRec.ShippingState = 'NY';
		accRec.ShippingStreet= 'Street 1'; 
		accRec.ShippingCity= 'BR';
        INSERT accRec;
        
        List<User> userList = new List<User>();
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@cleanharbors.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+i+'@cleanharbors.com'));
        }
        insert userList; 
        
        
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
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = customerAccountRecordType,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                    Primary_Service_Provider_New__c = 'SK BPS', KAM_Support__c=userList[0].Id,
                                    Status__c='Active', ParentId=accRec.Id, Account_Assign_Override__c = false, Buying_Decision__c = 'Central Buying', Primary_Business__c='BPS')); //
        }
        Territory__c t = new Territory__c();
        t.name = 'TS-AM-Camarillo-CA-01';
        t.Territory_OwnerID__c = UserInfo.getUserId();
        INSERT t;
        Territory_Master__c tm = new Territory_Master__c();
        tm.ZIP_Master__c = zipMasterList[0].Id;
        tm.Sales_Business_Unit__c = 'BPS';
        tm.Name = 'SK BPS';
        tm.Territory_ID__c = t.Id;
        INSERT tm;
        test.startTest();
        accList[0].ZIP_Master__c = zipMasterList[0].Id;
        insert accList;
        test.stopTest();
        
        Account grandChildRec = new Account(Name = 'Test Child', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = customerAccountRecordType,                               
                                            Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                            Primary_Service_Provider_New__c = 'SK BPS', KAM_Support__c=userList[0].Id,
                                            Status__c='Active', ParentId=accList[0].Id, Primary_Business__c='BPS');
        INSERT grandChildRec;
    }
    
    @isTest
    private static void updateAccountTerritoryUnitTest(){
        Account accountRec = [SELECT Id FROM Account WHERE Name = 'Parent Corporate Account' LIMIT 1];
        accountRec.Buying_Decision__c = 'Locally Managed';
        UPDATE accountRec;
    }
}