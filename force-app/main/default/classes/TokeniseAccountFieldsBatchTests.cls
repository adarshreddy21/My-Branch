@isTest
private class TokeniseAccountFieldsBatchTests {
    @testSetup
    static void setup(){
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
        
         COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();    
         countrycodes.Name = 'CA';  
         insert countrycodes;   
            
         COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();   
         countrycodes1.Name = 'US'; 
         insert countrycodes1;  
            
         ZIP_Master__c zpObj = new ZIP_Master__c(); 
        zpObj.zip__c = '45204';    
        zpObj.Country__c = 'US';
        zpObj.State__c = 'OR';   
        insert zpObj; 

        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
			zipMasterList.add(new ZIP_Master__c(Zip__c = '10047',Country__c = 'US', State__c = 'NY',City__c = 'New York'));
         
        }
        insert zipMasterList;
        
        Account testAccount = new Account(Name = 'Test Account ', Phone = '7994902391',Type = 'Customer',Business_Type__c='Base',Rank__c='CH A Large >200K',Industry_Segment__c='Chemical',
                                        CS_EPA_ID__c='PENDING',Generator_Status__c='Large Quantity Generator',ShippingPostalCode='45204',ShippingCountry='US',
                                        ShippingState='OR',ShippingCity='Brookings',ShippingStreet='Test Street');
        
        insert testAccount;

    }
    private static AccountHistory getAccountHistoryRecord(){
        AccountHistory accHistory= new AccountHistory();
        accHistory.AccountId= [SELECT id,shippingstreet from account Limit 1].Id;
        return accHistory;
    }   
    @isTest
    static void testProcessRecords() {
       
        Test.startTest();
            AccountHistory accHistoryRecord= getAccountHistoryRecord();
            TokeniseAccountFieldsBatch batch = new TokeniseAccountFieldsBatch(1);
            batch.shippingStreetMock='Test Street';
			Database.executeBatch(new TokeniseAccountFieldsBatch(1), 50);
            batch.processRecords(new List<AccountHistory>{accHistoryRecord});
            batch.processRecords(new List<AccountHistory>{accHistoryRecord});  
        Test.stopTest();

        List<AccountTokenisation__c> tokenisedRecords = [SELECT Id, TokenisedStreet__c FROM AccountTokenisation__c where Account__c=:accHistoryRecord.AccountId];
        System.assertEquals(1, tokenisedRecords.size(), 'Tokenised Record created/updated successfully');
    }

    
}