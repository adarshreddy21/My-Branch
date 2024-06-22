@isTest
public class Q2COppotuniyDataAPITest {
	@testSetup
    private static void setupDate(){
        User_Primary_Business__c bps = new User_Primary_Business__c();
        bps.Name = 'Safety-Kleen';
        bps.Primary_Business__c = 'Safety-Kleen';
        insert bps;
        
        Trigger_Process__c tp_lobcs = new Trigger_Process__c(
            Name='LOB Cross Sell',
            canProcess__c=true
        );
        Trigger_Process__c tp_rs = new Trigger_Process__c(
            Name='Revenue Schedule',
            canProcess__c=true
        );   
        
        insert tp_lobcs;
        
        insert tp_rs;
        
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
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        Id accRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPORATE).getRecordTypeId();
        User activeUser = [select Id from User where isActive = True Limit 1];
        Account accRec = new Account();
        accRec.Name = 'Parent Corporate Account';
		accRec.dunbrdst__c = '12345';
        accRec.ShippingCountry = 'US';
        accRec.ShippingState = 'NY';
        accRec.ShippingStreet = 'Test Street';
        accRec.ShippingCity = 'Ashburn';
        accRec.ShippingPostalCode = '12345';
        accRec.KAM_Manager__c = activeUser.id;
        accRec.KAM_Support__c = activeUser.id;
        accRec.RecordTypeId = accRecTypeId;
        accRec.Buying_Decision__c = 'Central Buying';
        accRec.Account_Assign_Override__c = false;
        accRec.Status__c = 'Active';
        accRec.WIN_ID__c = '1234';
        INSERT accRec;
        
        Id pricebookId = Test.getStandardPricebookId();  
        
        Pricebook2 customPB = new Pricebook2(
            Name='Safety-Kleen / BPS', 
            isActive=true,
            CurrencyISOCode = 'USD'
        );
        insert customPB;
        
        Product2 prod = new Product2(
            Name = 'Bulk Services',
            isActive=true,
            CanUseRevenueSchedule=true,
            Business_Unit__c='Field Services',
            Product_Hierarchy_Number__c = '3000',
            CurrencyIsoCode = 'USD'
        );
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        PricebookEntry customPBEnt = new PricebookEntry(
            Pricebook2Id = customPB.Id, 
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        customPBEnt.CurrencyIsoCode = 'USD';
        
        System.debug('customPBEnt ' + customPBEnt);
        
        List<PricebookEntry> prBkList = new List<PricebookEntry>();
        prBkList.add(standardPrice);
        prBkList.add(customPBEnt);
        
        insert prBkList;
        
        Test.startTest();
        Opportunity oppRec = new Opportunity();		  
        oppRec.Name = 'SK Driver';
        oppRec.CloseDate = Date.today().addMonths(1);
        oppRec.Job_Start_Date__c = Date.today().addMonths(1);
        oppRec.StageName = '1 - Prospecting';
        oppRec.Creator_Username__c = 'test';
        oppRec.Creator_ID__c = '33356';
        oppRec.Opp_Strength__c = 'Interest level high - Quote needed';
        oppRec.Description = 'Test Comments';
        oppRec.Services_Discussed__c = '3000';
        oppRec.OwnerId = UserInfo.getUserId();
        oppRec.Parts_Cleaner_Type__c = 'None';
        oppRec.AccountId = accRec.Id; 
        oppRec.Pricebook2Id = customPB.Id;
        oppRec.CurrencyIsoCode = 'USD';
        oppRec.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Safety_Kleen_BPS_Opportunity').getRecordTypeId();
        INSERT oppRec;
        
        oppRec.Pricebook2Id = customPB.Id;
        UPDATE oppRec;
        
        System.debug('sdd ' + [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :oppRec.Id]);
        
        OpportunityLineItem oppLineItemObj = new OpportunityLineItem();
        oppLineItemObj.OpportunityId = oppRec.Id;
        oppLineItemObj.Product2Id = prod.Id;
        oppLineItemObj.PricebookEntryId = customPBEnt.Id;
        INSERT oppLineItemObj;
        Test.stopTest();
    }
    
    @isTest
    private static void unitTest(){
        Account accountRec = [
            SELECT Id, WIN_ID__c
            FROM Account
            LIMIT 1
        ];
        Q2COppotuniyDataAPI.Q2COpportunityDataRequest Q2cDataReq = new Q2COppotuniyDataAPI.Q2COpportunityDataRequest();
        Q2cDataReq.OpportunityGeneratorCoCd = accountRec.WIN_ID__c;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Q2COppotuniyData/*';
        req.httpMethod = 'POST';
        
        req.requestBody = Blob.ValueOf(JSON.serialize(Q2cDataReq));
        RestContext.request = req;
        RestContext.response = res;
        Q2COppotuniyDataAPI.getQ2COppData();
        
        System.assert(res != NULL);
    }
}