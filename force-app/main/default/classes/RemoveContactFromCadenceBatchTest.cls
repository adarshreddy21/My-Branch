@istest 
public class RemoveContactFromCadenceBatchTest {
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
            ShippingCountry = 'US',
            ShippingState = 'NY',
        	ShippingStreet = 'Test Street',
       	    ShippingCity = 'Ashburn',
            ShippingPostalCode = '12345',
            dunbrdst__c = '12345',
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
        
        List<Contact> conList = new List<Contact>();
        for(Integer i = 0; i < 1; i++){
            if(i < 0 ){
                conList.add(new Contact(AccountId = acc.Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.'));
            }
            else{
                conList.add(new Contact(AccountId = corAcc.Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.'));
            }
        }
        insert conList;
        
        acc.status__c = 'Inactive';
        update acc;
    }
    @isTest static void testcadencewithContactId(){
        List<Contact> conList = [Select id,name from Contact];
        List<id> conIds = new List<id>();
        for(Contact con : conList)
        {
            conIds.add(con.id);
        }
        
        Test.setMock(HttpCalloutMock.class, new RemoveContactFromCadenceMock(200));
        RemoveContactFromCadenceBatch cadenceRemoveObj = new RemoveContactFromCadenceBatch(conIds);
        Test.startTest();
        cadenceRemoveObj.accountHistoryRecsMock = returnAccountHistory();
        cadenceRemoveObj.actionCadenceTrackersMock = returnCadence();
        database.executeBatch(cadenceRemoveObj,200);
        List<Exception_Log__c> errormessage = [select id from Exception_Log__c];
        Assert.isNotNull(errormessage, 'Cadence Remove Failed');
        Test.stopTest();
    }
    @isTest static void testcadenceInactivateAccount(){       
        Test.setMock(HttpCalloutMock.class, new RemoveContactFromCadenceMock(200));
        RemoveContactFromCadenceBatch cadenceRemoveObj = new RemoveContactFromCadenceBatch();
        Test.startTest();
        cadenceRemoveObj.accountHistoryRecsMock = returnAccountHistory();
        cadenceRemoveObj.actionCadenceTrackersMock = returnCadence();
        database.executeBatch(cadenceRemoveObj,200);
        List<Exception_Log__c> errormessage = [select id from Exception_Log__c];
        Assert.isNotNull(errormessage, 'Cadence Remove Failed');
        Test.stopTest();
    }
    @isTest static void testcadencehoursAccount(){       
        Test.setMock(HttpCalloutMock.class, new RemoveContactFromCadenceMock(200));
        RemoveContactFromCadenceBatch cadenceRemoveObj = new RemoveContactFromCadenceBatch(12);
        Test.startTest();
        cadenceRemoveObj.accountHistoryRecsMock = returnAccountHistory();
        cadenceRemoveObj.actionCadenceTrackersMock = returnCadence();
        database.executeBatch(cadenceRemoveObj,200);
        List<Exception_Log__c> errormessage = [select id from Exception_Log__c];
        Assert.isNotNull(errormessage, 'Cadence Remove Failed');
        Test.stopTest();
    }
    @isTest static void testcadencehoursAccountException(){       
        List<Contact> conList = [Select id,name from Contact];
        List<id> conIds = new List<id>();
        for(Contact con : conList)
        {
            conIds.add(con.id);
        }
        Test.setMock(HttpCalloutMock.class, new RemoveContactFromCadenceMock(400));
        RemoveContactFromCadenceBatch cadenceRemoveObj = new RemoveContactFromCadenceBatch(conIds);
        Test.startTest();
        cadenceRemoveObj.accountHistoryRecsMock = returnAccountHistory();
        cadenceRemoveObj.actionCadenceTrackersMock = returnCadence();
        database.executeBatch(cadenceRemoveObj,200);
        List<Exception_Log__c> errormessage = [select id from Exception_Log__c];
        Assert.isNotNull(errormessage, 'Cadence Remove Failed');
        Test.stopTest();
    }
    private static List<ActionCadenceTracker> returnCadence(){
        List<Contact> conList = [Select id,name from Contact];
        List<id> conIds = new List<id>();
        for(Contact con : conList)
        {
            conIds.add(con.id);
        }
        String jsonObject = '[{'+
            '"attributes": {'+
            '"type": "ActionCadenceTracker",'+
            '"url": "/services/data/v56.0/sobjects/ActionCadenceTracker/0qB76000000GzO4EAK"'+
            '},'+
            '"Id": "0qB76000000GzO4EAK",'+
            '"OwnerId": "005760000010oRMAAY",'+
            '"CreatedDate": "2022-10-04T05:42:52.000+0000",'+
            '"CreatedById": "005760000010oRMAAY",'+
            '"ActionCadenceId": "77C760000004CBEEA2",'+
            '"TargetId": "'+conIds[0] +'"'+
            '}]';
        List<ActionCadenceTracker> cadenceList = (List<ActionCadenceTracker>)JSON.deserialize(jsonObject, List<ActionCadenceTracker>.class); 
        return cadenceList;
    } 
    private static List<AccountHistory> returnAccountHistory(){
        List<Contact> conList = [Select id,name,Account.Id from Contact];
        List<id> conIds = new List<id>();
        for(Contact con : conList)
        {
            conIds.add(con.id);
        }
        List<AccountHistory> ah; 
        ah = new List<AccountHistory>{}; 
        ah.add(new AccountHistory(AccountId=conList[0].Accountid, Field='Type'));
        return ah;
    }
    
}