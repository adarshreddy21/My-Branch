/* 
* @author    Vikram Simha
* @createddate  07-08-2023   
*/   
@isTest
public class TestCPGCaseCreation {
    @testSetup
    private static void setup(){
        User userRec = new User(Id=UserInfo.getUserId(), EmployeeNumber='333');
        UPDATE userRec;
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
			zipMasterList.add(new ZIP_Master__c(Zip__c = '20147',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
        }
        insert zipMasterList;
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = false;
        insert sicValidation;
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id accCorporateRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        Account corAcc = new Account(
            Name = 'Test ',       
            Business_Type__c = 'Base', 
            AccountSource = 'Phone',
            CS_EPA_ID__c = '12345', 
            Sic = '0111', 
            dunbrdst__c = '12345',
            ShippingCountry = 'US',
            ShippingState = 'NY',
        	ShippingStreet = 'Test Street',
       	    ShippingCity = 'Ashburn',
            ShippingPostalCode = '12345',
        	KAM_Manager__c = UserInfo.getUserId(),
            RecordTypeId = accCorporateRecTypeId,                               
            Rank__c = 'CH A Large >200K',
            Reporting_Vertical__c = 'Automotive',
            Industry_Segment__c = 'Automotive',
            Class__c = 'Agricultural Production',
            ownerId = UserInfo.getUserId(), 
            Primary_Service_Provider_New__c='SK ENV',
            KAM_Support__c = UserInfo.getUserId(),
            WIN_ID__c = 'DEL200',
            Buying_Decision__c = 'Central Buying'
        ); 
        insert corAcc; 
        Account acc = new Account(
            Name = 'Test1',       
            Business_Type__c = 'Base', 
            AccountSource = 'Phone',
            CS_EPA_ID__c = '12345', 
            Sic = '0111', 
            RecordTypeId = accRecTypeId,                               
            Rank__c = 'CH A Large >200K',
            Reporting_Vertical__c = 'Automotive',
            Industry_Segment__c = 'Automotive',
            Class__c = 'Agricultural Production',
            ownerId = UserInfo.getUserId(), 
            Primary_Service_Provider__c='Safety Kleen',
            WIN_ID__c = 'DEL201',
            ParentId = corAcc.Id
        ); 
        insert acc;
    }
    @isTest
    public static void testCreateNewCaseUpdate(){
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', EmployeeNumber='108182', UserName='standarduser@testorg.com', isActive = TRUE);
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accounts = [Select Id,name from Account where Win_Id__c ='DEL201'];
        List<User> users =[select id,name from user where isActive = True and EmployeeNumber!=null];
        List<case> lstcase=new List<Case>();
        case newcase = new case ();
        Id CPGCaseRecordType = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('CPG_Request').getRecordTypeId();
        newcase.Subject = 'CPG Case';
        newCase.AccountId = accounts[0].id;
        newCase.Profile_Number__c = '45687';
        newCase.RecordTypeId = CPGCaseRecordType;
        newCase.Waste_Description__c = 'Test Description';
        newCase.CPG_Owner__c = users[0].Id;
        newCase.Incomplete_Profile_Comments__c = 'Test Profile Instructions.';
        insert newcase;
        List<Case> cases =[ SELECT Id, casenumber,Profile_Number__c, 
                           ACCOUNT.WIN_ID__c,RecordType.Name,status FROM case 
                           where Id=:newcase.Id Limit 1];
        try{
            CPGCaseCreation.CaseRequestWrapper cWrapper = new CPGCaseCreation.CaseRequestWrapper();
            cWrapper.GeneratorCode ='DEL201';
            cWrapper.CPGOwnerID ='108182';
            cWrapper.ApprovalStatus='I';
            cWrapper.CurrentProfileDescription = 'Test Update';
            cWrapper.Profile = '45687';
            cWrapper.ProfileInstructions = 'Test Instructions';
            CPGCaseCreation.createnewcase(cWrapper);
            Case cs = [SELECT Id,Status FROM Case where Id = :newcase.Id];
        }
        catch (Exception e){}
        
        Test.stopTest();
    }
    @isTest
    public static void testCreateNewCaseInsert(){
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', EmployeeNumber='108182', UserName='standarduser@testorg.com', isActive = TRUE);
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accounts = [Select Id,name from Account where Win_Id__c ='DEL201'];
        List<User> users =[select id,name from user where isActive = True and EmployeeNumber!=null];
        List<case> lstcase=new List<Case>();
        case newcase = new case ();
        Id CPGCaseRecordType = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('CPG_Request').getRecordTypeId();
        newcase.Subject = 'CPG Case';
        newCase.AccountId = accounts[0].id;
        newCase.Profile_Number__c = '45687';
        newCase.RecordTypeId = CPGCaseRecordType;
        newCase.Waste_Description__c = 'Test Description';
        newCase.CPG_Owner__c = users[0].Id;
		newCase.OwnerId = users[0].Id;
        newCase.Incomplete_Profile_Comments__c = 'Test Profile Instructions.';
        insert newcase;
        List<Case> cases =[ SELECT Id, casenumber,Profile_Number__c, 
                           ACCOUNT.WIN_ID__c,RecordType.Name,status FROM case 
                           where Id=:newcase.Id Limit 1];
        try{
            CPGCaseCreation.CaseRequestWrapper cWrapper = new CPGCaseCreation.CaseRequestWrapper();
            cWrapper.GeneratorCode ='DEL201';
            cWrapper.CPGOwnerID ='108182';
            cWrapper.ApprovalStatus='I';
            cWrapper.CurrentProfileDescription = 'Test Update';
            cWrapper.Profile = '4568';
            cWrapper.ProfileInstructions = 'Test Instructions';
            CPGCaseCreation.createnewcase(cWrapper);
            Case cs = [SELECT Id,Status FROM Case where Id = :newcase.Id];
        }
        catch (Exception e){}
        
        Test.stopTest();
    }
    @isTest
    public static void testCreateNewCaseUpdate1(){
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', EmployeeNumber='108182', UserName='standarduser@testorg.com', isActive = TRUE);
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accounts = [Select Id,name from Account where Win_Id__c ='DEL201'];
        List<User> users =[select id,name from user where isActive = True and EmployeeNumber!=null];
        List<case> lstcase=new List<Case>();
        case newcase = new case ();
        Id CPGCaseRecordType = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('CPG_Request').getRecordTypeId();
        newcase.Subject = 'CPG Case';
        newCase.AccountId = accounts[0].id;
        newCase.Profile_Number__c = '45687';
        newCase.RecordTypeId = CPGCaseRecordType;
        newCase.Waste_Description__c = 'Test Description';
        newCase.CPG_Owner__c = users[0].Id;
        newCase.Incomplete_Profile_Comments__c = 'Test Profile Instructions.';
        insert newcase;
        List<Case> cases =[ SELECT Id, casenumber,Profile_Number__c, 
                           ACCOUNT.WIN_ID__c,RecordType.Name,status FROM case 
                           where Id=:newcase.Id Limit 1];
        try{
            CPGCaseCreation.CaseRequestWrapper cWrapper = new CPGCaseCreation.CaseRequestWrapper();
            cWrapper.GeneratorCode ='DEL201';
            cWrapper.CPGOwnerID ='108182';
            cWrapper.ApprovalStatus='A';
            cWrapper.CurrentProfileDescription = 'Test Update';
            cWrapper.Profile = '45687';
            cWrapper.ProfileInstructions = 'Test Instructions';
            CPGCaseCreation.createnewcase(cWrapper);
            Case cs = [SELECT Id,Status FROM Case where Id = :newcase.Id];
        }
        catch (Exception e){}
        
        Test.stopTest();
    }
    @isTest
    public static void testCreateNewCaseError(){
        
        Test.startTest();
        try{
            CPGCaseCreation.CaseRequestWrapper cWrapper = new CPGCaseCreation.CaseRequestWrapper();
            CPGCaseCreation.createnewcase(cWrapper);
        }
        catch (Exception e){}
        
        Test.stopTest();
    }
    
}