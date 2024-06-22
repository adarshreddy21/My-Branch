@isTest
private  class CreateWinIdsAccountsQueuableJobTests {
    @testSetup static void setupRecords() {
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        createSICValidationSetting();
        
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
    }
    private static Account createAccount(){
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(Name = 'Test', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = customerRecordTypeId,                               
                                Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                Primary_Service_Provider_New__c = 'SK BPS', Cycle__c = 'Committed'); 
        insert acc;
        return acc;
    }

    private static void createIntegrationProcessRecord(Id accId){
        Integration_Process__c integProcess=new Integration_Process__c();
        integProcess.Status__c= 'Pending';
        integProcess.Process_Type__c= CHConstants.ACCOUNT_WIN_VALIDATE_CREATE;
        integProcess.Account__c= accId;
        insert integProcess;
    }

    private static void createSICValidationSetting(){
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
    }

    @isTest
    private static void testCreateWinIdsAccountsBatchForSuccess(){
        createSICValidationSetting();
        Account acc= createAccount();
        Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(200,acc.Id));
        createIntegrationProcessRecord(acc.Id);
        List<Integration_Process__c> integrationProcessRecords= [SELECT Id from Integration_Process__c];
        Test.startTest();
            System.enqueueJob(new CreateWinIdsAccountsQueuableJob(new Map<Id, Integration_Process__c>(integrationProcessRecords).keySet()));
        Test.stopTest();

        Integration_Process__c integProcess = [SELECT Id,Status__c from Integration_Process__c LIMIT 1];
        System.assertEquals(integProcess.Status__c, 'Processed', 'WinId generated and mapped');
    }

    @isTest
    private static void testCreateWinIdsAccountsBatchForError(){
        Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(200));
        createSICValidationSetting();
        Account acc= createAccount();
        createIntegrationProcessRecord(acc.Id);
       
        List<Integration_Process__c> integrationProcessRecords= [SELECT Id from Integration_Process__c];
        Test.startTest();
            System.enqueueJob(new CreateWinIdsAccountsQueuableJob(new Map<Id, Integration_Process__c>(integrationProcessRecords).keySet()));
        Test.stopTest();

        Integration_Process__c integProcess = [SELECT Id,Status__c from Integration_Process__c LIMIT 1];
        System.assertEquals(integProcess.Status__c,'Error',  'Error in WINID generation and mapping');
    }
}