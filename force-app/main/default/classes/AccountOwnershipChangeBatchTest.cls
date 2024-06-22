@isTest(SeeAllData=false)
public class AccountOwnershipChangeBatchTest {
    @testSetup static void setupmethod() {
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration']; 
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@safety-kleen.com', IsActive=true,
            EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+i+'@safety-kleen.com'));
        }
        insert userList; 
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
        
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
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Test.startTest();
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 1; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = recordTypeIdAccount,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                    Primary_Service_Provider_New__c = 'Clean Harbors ENV'));
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
        accList[0].ZIP_Master__c = zipMasterList[0].Id;
        insert accList;
        Test.stopTest();
        List<Account> listOfAccount = [select id,name from Account];
        List<user> users = [select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c from user where isActive=true and Profile.Name = 'Integration' and Primary_Business__c!=''];
        Ownership_Change_Request__c oCR = new Ownership_Change_Request__c();
        oCR.Reason_for_Change__c = 'Primary Business Change';
        oCR.Account__c = listOfAccount[0].id;
        oCR.New_Owner__c = users[0].id;
        oCR.Requested_Owner_Territory_Id__c ='TS-AM-Camarillo-CA-01';
        insert oCR;
    }
    @IsTest static void testInvokeBatch(){
        string query = 'SELECT Id, Name, Account__c, Account_Owner_del__c, Account_Operating_Segment__c, Account_Primary_Service_Provider__c,'+
            'Current_Account_Owner__c, Requested_Account_Owner__c, New_Owner__c, Justification__c, New_Owner_s_Manager__c, New_Owner_s_VP__c, Existing_Owner_s_Manager__c, Existing_Owner_s_VP__c, Effective_Date__c, Status__c, New_Operating_Segment__c, New_Primary_Service_Provider__c, Prior_year_s_revenue__c, Need_Existing_Manager_Approval__c, Account_Owner_Managers_Same__c,'+
            'Account_Owner_Vps_Same__c,  Reason_for_Change__c,Requested_Owner_Territory_Id__c,Account_Operating_Segment_Text__c FROM Ownership_Change_Request__c';
        AccountOwnershipChangeBatch aoc = new AccountOwnershipChangeBatch(query);
        Id batchJobId = Database.executeBatch(aoc, 1);
    }
}