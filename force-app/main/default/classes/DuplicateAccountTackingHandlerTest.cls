@isTest(SeeAllData=false)
public class DuplicateAccountTackingHandlerTest {
    @testSetup static void setupmethod() {
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration']; 
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@safety-kleen.com', IsActive=true,
                                  EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles',Territory__c='ISAM-01-WER', UserName=datetime.now().millisecond()+'standardusertest'+i+'@safety-kleen.com'));
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
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 5; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = recordTypeIdAccount,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                    Primary_Service_Provider_New__c = 'Clean Harbors ENV'));
        }
        insert accList;
        
    }
    
    
    @IsTest static void testSetUserLookupFields(){
        
        
        List<Account> listOfAccount = [select id,name from Account limit 5];
        List<Duplicate_Account_Tracking__c> DATList = new List<Duplicate_Account_Tracking__c>();
        for(Account acc : listOfAccount){
            for(Account acc1 : listOfAccount){
                if(acc.id!=acc1.Id){
                    Duplicate_Account_Tracking__c DAT = new Duplicate_Account_Tracking__c();
                    DAT.Account__c = acc.Id;
                    DAT.Matched_Account__c = acc1.Id;
                    DATList.add(DAT);
                }
                
            }
            
        }
        insert DATList;
         
    }
   
}