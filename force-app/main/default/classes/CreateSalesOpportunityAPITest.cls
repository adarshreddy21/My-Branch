@isTest
public class CreateSalesOpportunityAPITest {
	@testSetup
    private static void setupDate(){
        User_Primary_Business__c bps = new User_Primary_Business__c();
        bps.Name = 'Safety-Kleen';
        bps.Primary_Business__c = 'Safety-Kleen';
        insert bps;
        
        user activeUser =[select id from user where IsActive = True limit 1];
        
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
        accRec.OwnerId = activeUser.id;
        accRec.RecordTypeId = accRecTypeId;
        accRec.Buying_Decision__c = 'Central Buying';
        accRec.Primary_Business__c = 'Safety-Kleen';
        accRec.Primary_Service_Provider_New__c = 'SK ENV';
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
            Product_Hierarchy_Number__c = '3000'
        );
        insert prod;
        
        Product2 prod2 = new Product2(
            Name = 'Catalyst Services',
            isActive=true,
            CanUseRevenueSchedule=true,
            Create_Single_Revenue_Schedule__c=true,
            Product_Hierarchy_Number__c = '6000'
        );
        insert prod2;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod2.Id,
            UnitPrice = 200, 
            IsActive = true
        );
        
        PricebookEntry customPBEnt = new PricebookEntry(
            Pricebook2Id = customPB.Id, 
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        
        PricebookEntry customPBEnt1 = new PricebookEntry(
            Pricebook2Id = customPB.Id,
            Product2Id = prod2.Id,
            UnitPrice = 200, 
            IsActive = true
        );
        
        List<PricebookEntry> prBkList = new List<PricebookEntry>();
        prBkList.add(standardPrice);
        prBkList.add(standardPrice2);
        prBkList.add(customPBEnt);
        prBkList.add(customPBEnt1);
        
        insert prBkList;
    }
    
    @isTest
    private static void createOpportunityUnitTest(){
        Account accountRec = [
            SELECT Id, WIN_ID__c
            FROM Account
            LIMIT 1
        ];
        CreateSalesOpportunityAPI.CreateSalesOpportunityRequest createSalesOppReq = new CreateSalesOpportunityAPI.CreateSalesOpportunityRequest();
        createSalesOppReq.OpportunityGeneratorCoCd = accountRec.WIN_ID__c;
        createSalesOppReq.OpportunityCreatorUsername = 'ABC';
        createSalesOppReq.OpportunityCreatorID = '33351';
        createSalesOppReq.OpportunityStrengthId = 'Interest level high - Quote needed';
        createSalesOppReq.OpportunityPHNumber = new List<String>{'3000', '6000', '4000'};
        createSalesOppReq.OpportunityComments = 'Test Comments';
        //createSalesOppReq.OpportunityPartsCleanerType = 'Aqueous';
        
        CreateSalesOpportunityAPI.SalesOpportunityRequest salesOppReq = new CreateSalesOpportunityAPI.SalesOpportunityRequest();
        salesOppReq.SaveOpportunityData = createSalesOppReq;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/CreateSalesOpportunity/*';
        req.httpMethod = 'POST';
        
        req.requestBody = Blob.ValueOf(JSON.serialize(salesOppReq));
        RestContext.request = req;
        RestContext.response = res;
        CreateSalesOpportunityAPI.createOpportunity();
        
        System.assert(res != NULL);
    }
}