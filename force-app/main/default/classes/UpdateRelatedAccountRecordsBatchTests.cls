@isTest
private class UpdateRelatedAccountRecordsBatchTests{
    @testSetup
    private static void setup(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration']; 
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        Bypass_Account_Validation__c accountValidation = new Bypass_Account_Validation__c();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false;
        insert accountValidation; 
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        List<User> userList = new List<User>();
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@safety-kleen.com', 
            EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+i+'@safety-kleen.com'));
        }
        insert userList; 
        
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
                                   Generator_Status__c='Small Quantity Generator', Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   Primary_Service_Provider_New__c = 'SK BPS')); //
        }
        insert accList;
        /*Territory__c t = new Territory__c();
        t.name = 'TS-AM-Camarillo-CA-01';
        t.Territory_OwnerID__c = UserInfo.getUserId();
        insert t;
        Territory_Master__c tm = new Territory_Master__c();
        tm.ZIP_Master__c = zipMasterList[0].Id;
        tm.Sales_Business_Unit__c = 'BPS';
        tm.Name = 'SK BPS IS';
        tm.Territory_ID__c = t.Id;
        INSERT tm;
        test.startTest();
        accList[0].ZIP_Master__c = zipMasterList[0].Id;
        insert accList;
        test.stopTest();*/
        List<COUNTRY_CODES__c> countryCodes = new List<COUNTRY_CODES__c> {new Country_Codes__c(Name='CA'), new Country_Codes__c(Name='US') };
        insert countryCodes;
    }
    private static Account getChildAccountRecordForOwnerUpdate(Account accRec)
    {
        Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        Account accChildRec = new Account(Name = 'Test Child', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = customerLocationAccountRecordType,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                 Generator_Status__c='Small Quantity Generator',  Primary_Service_Provider_New__c = 'SK BPS', ParentId=accRec.Id);
        insert accChildRec;
        return accChildRec;                             
    }
    private static void createIntegrationProcessRecords(Account accChildRec, String processType)
    {
        Integration_process__c  integProcess= new Integration_process__c();
        integProcess.Status__c='Pending';
        integProcess.Account__c= accChildRec.Id;
        integProcess.Process_Type__c= processType;
        insert integProcess;
    }
    
    private static Account getBrokerParentAccount(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker').getRecordTypeId();
        Account parentAcc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',
                                 Generator_Status__c='Small Quantity Generator', ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street');
        insert parentAcc;
        return parentAcc;
    }
    
    private static Account getChildCustomerLocationAccount(Account parentAcc){
        Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get('Customer_Location').getRecordTypeId();
        Account accChildRec = new Account(Name = 'Test Child', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = customerLocationAccountRecordType,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production', ParentId = parentAcc.Id,
									Generator_Status__c='Small Quantity Generator',ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street');
                                 //  Primary_Service_Provider_New__c = 'SK BPS', ParentId = parentAcc.Id, Status__c='Active');
        Database.DMLOptions dml = new Database.DMLOptions(); 
		dml.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(accChildRec, dml);
        return accChildRec;
    }
    
    @isTest
    private static void ownerUpdateTest(){
    
        Account accRec = [
            SELECT Id, OwnerId 
            FROM Account
            LIMIT 1
        ];
        
        Account accChildRec = getChildAccountRecordForOwnerUpdate(accRec);
        createIntegrationProcessRecords(accChildRec, CHConstants.Ownerupdate);  

        Test.startTest();
        Database.executeBatch(new UpdateRelatedAccountRecordsBatch(CHConstants.Ownerupdate));
        Test.stopTest();

        accChildRec = [SELECT Id, OwnerId FROM Account WHERE Id = :accChildRec.Id];
        System.assertEquals(accChildRec.OwnerId, accRec.OwnerId,'Owner successfully updated on children');
    }

    @isTest
    private static void updateRecordTypeUpdateTest(){
        
        Account parentAcc = getBrokerParentAccount();
       Account accChildRec = getChildCustomerLocationAccount(parentAcc);
        createIntegrationProcessRecords(accChildRec, CHConstants.BrokerRecordTypeUpdate);
        
       Test.startTest();
        Database.executeBatch(new UpdateRelatedAccountRecordsBatch(CHConstants.BrokerRecordTypeUpdate));
        Test.stopTest();
        
        Id accRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker_Location').getRecordTypeId();
        accChildRec = [SELECT Id, RecordTypeId FROM Account WHERE Id = :accChildRec.Id];
        System.assertEquals(accChildRec.RecordTypeId, accRecTypeId2, 'Customer location record type should changed to broker location.');
    }
}