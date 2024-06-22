@isTest
private class CreateWinIdsAccountsBatchTests {
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
    private static void testCreateWinIdsAccountsScheduleUnit(){
        Test.startTest();
        String cronExp = '0 0 * * * ?';
        Id jobId = System.schedule('Test', cronExp, new CreateWinIdsAccountsBatch());
        Test.stopTest();
        
        System.assert(jobId != NULL);
    }

    @isTest
    private static void testCreateWinIdsAccountsBatchForError(){
        Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(200));
        createSICValidationSetting();
        Account acc= createAccount();
        createIntegrationProcessRecord(acc.Id);
       
        Test.startTest();
            Database.executeBatch(new CreateWinIdsAccountsBatch(), 5);
        Test.stopTest();

        Integration_Process__c integProcess = [SELECT Id,Status__c from Integration_Process__c LIMIT 1];
        System.assertEquals(integProcess.Status__c,'Error',  'Error in WINID generation and mapping');
    }

    @isTest
    private static void testCreateWinIdsAccountsBatchForSuccess(){
        createSICValidationSetting();
        Account acc= createAccount();
        Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(200,acc.Id));
        createIntegrationProcessRecord(acc.Id);
       
        Test.startTest();
            Database.executeBatch(new CreateWinIdsAccountsBatch(), 5);
        Test.stopTest();

        Integration_Process__c integProcess = [SELECT Id,Status__c from Integration_Process__c LIMIT 1];
        System.assertEquals(integProcess.Status__c, 'Processed', 'WinId generated and mapped');
    }
    
    @isTest
    private static void testCreateCustomerWinIdsForHPCAccountsBatchForSuccess(){
        Account accObj = new Account();
        accObj.Name = 'Gillette Company';
        accObj.Phone = '799856414';
        accObj.Primary_business__c = 'Hpc Industrial';
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base'; 
        accObj.Rank__c = 'CH A Large >200K';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert accObj;
        
        createSICValidationSetting();
        Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(200,accObj.Id));
        createIntegrationProcessRecord(accObj.Id);
       
        Test.startTest();
            Database.executeBatch(new CreateWinIdsAccountsBatch(), 5);
        Test.stopTest();

        Integration_Process__c integProcess = [SELECT Id,Status__c from Integration_Process__c LIMIT 1];
        System.assertEquals(integProcess.Status__c, 'Processed', 'WinId generated and mapped');
    }
    
    @isTest
    private static void testCreateCustomerLocWinIdsForHPCAccountsBatchForSuccess(){
        Account accObj1 = new Account();
            accObj1.Name = 'Gillette Company';
            accObj1.Primary_Service_Provider_New__c = 'CHES Industrial';
            accObj1.Phone = '799856414';
            accObj1.Primary_business__c = 'Hpc Industrial';
            accObj1.Type = 'Customer';
            accObj1.Business_Type__c = 'Base'; 
            accObj1.Rank__c = 'CH A Large >200K';
            accObj1.WIN_ID__c = 'A0002AD003';
            accObj1.Industry_Segment__c = 'Chemical';
            accObj1.CurrencyIsoCode = 'USD';
            accObj1.CS_EPA_ID__c = 'PENDING';
            accObj1.Generator_Status__c = 'Large Quantity Generator';
            accObj1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            insert accObj1;
         
            Account accObj = new Account();
            accObj.Name = 'Test Location';
            accObj.Phone = '799856414';
            accObj.ParentId = accObj1.id;
            accObj.Primary_business__c = 'Hpc Industrial';
            accObj.Type = 'Customer Location';
            accObj.Business_Type__c = 'Base'; 
            accObj.Rank__c = 'CH A Large >200K';
            accObj.Industry_Segment__c = 'Chemical';
            accObj.CurrencyIsoCode = 'USD';
            accObj.CS_EPA_ID__c = 'PENDING';
            accObj.Generator_Status__c = 'Large Quantity Generator';
            accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
            insert accObj;
        
        createSICValidationSetting();
        Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(200,accObj.Id));
        createIntegrationProcessRecord(accObj.Id);
       
        Test.startTest();
            Database.executeBatch(new CreateWinIdsAccountsBatch(), 5);
        Test.stopTest();

        Integration_Process__c integProcess = [SELECT Id,Status__c from Integration_Process__c LIMIT 1];
        System.assertEquals(integProcess.Status__c, 'Processed', 'WinId generated and mapped');
    }
}