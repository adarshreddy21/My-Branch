/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 01-12-2023
 * @last modified by  : Irfan Khan
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   10-18-2022   Suresh Beniwal   Initial Version
**/
@isTest 
private class TestOpportunityTriggerController {    
    private final static string TEST_CURRENCYISOCODE = 'USD';
    private final static string TEST_ZIP = '45204';
    private final static string TEST_Shipping_PostalCode = '45204'; 
    private final static string TEST_Shipping_Country = 'US';
    private final static string TEST_Shipping_State = 'OR';
    
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
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();	
        countrycodes.Name = 'CA';	
        insert countrycodes;	
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();	
        countrycodes1.Name = 'US';	
        insert countrycodes1;	
        
        ZIP_Master__c zpObj = new ZIP_Master__c();	
        zpObj.zip__c = TEST_ZIP;	
        zpObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        zpObj.Country__c = TEST_Shipping_Country;	
        zpObj.State__c = TEST_Shipping_State;	
        insert zpObj;	
        
        Territory_Master__c tmObj = new Territory_Master__c();	
        tmObj.name = 'Test TM';	
        tmObj.ZIP_Master__c = zpObj.id;	
        tmObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        tmObj.Sales_business_unit__C = 'lodging';       	
        insert tmObj;
        
        Id accRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPORATE).getRecordTypeId();
        User activeUser = [Select id from User where isActive = True Limit 1];
        Account accRec = new Account();
        accRec.Name = 'Parent Corporate Account';
		accRec.dunbrdst__c = '12345';
        accRec.ShippingCountry = TEST_Shipping_Country;
        accRec.ShippingState = TEST_Shipping_State;
        accRec.ShippingStreet = 'Test Street';
        accRec.ShippingCity = 'Ashburn';
        accRec.ShippingPostalCode = TEST_ZIP;
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
    
    static testMethod void testSingle() {
        
        // TEST SUMMARY : This method tests the functionalities of the trigger for single record insert/update/delete of opportunity and opportunity product.
        
        // Declare local variables 
        List<User> userList = new List <User>();
         
        
        Profile p = [Select id from Profile where name = 'Integration'];
        Profile p1 = [Select id from Profile where name = 'Inside Sales Agent'];
        UserRole R1 = [Select Id From UserRole where DeveloperName = 'SK_INS_BPS_AM'];
        
        // Create test integration user
        User u = new User(Alias = 'iuser', Email='iuser@cleanharbors.com', 
                          EmailEncodingKey='UTF-8', LastName='Integration User', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='integrationuser@cleanharbors.com',Primary_Business__c='Safety-Kleen');
        userList.add(u);
        
        User u1 = new User(Alias = 'isduser', Email='insidesalesuser@cleanharbors.com', 
                          EmailEncodingKey='UTF-8', LastName='Inside Sales User', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id,UserRoleId = R1.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='insidesalesuser@cleanharbors.com',Primary_Business__c='Safety-Kleen');
        userList.add(u1);
        
        insert userList;
        
        // Run the single test as integration user. This is done to reduce the # of soql calls called by the AccountCRUD trigger
        
        System.runAs(u) {      
            // Insert the custom settings with the checkbox enabled to true to ensure that the trigger allows the revenue schedule updates
            // and LOB field updates.
            Trigger_Process__c tp_lobcs = new Trigger_Process__c(Name='LOB Cross Sell',canProcess__c=true);
            Trigger_Process__c tp_rs = new Trigger_Process__c(Name='Revenue Schedule',canProcess__c=true);   
            
            insert tp_lobcs;
            
            insert tp_rs;
            
            //Insert the custom settings with validation set to false to skip validation of business rules and checks on account fields called in the account trigger.       
            SIC_VALIDATION_SETTING__c svc = new SIC_VALIDATION_SETTING__c(Name='SIC_VALIDATION_SETTING',SIC_VALIDATION_FLAG__c=false);
            insert svc;
            
            //Insert the custom settings with TM flag set to false to skip account owner assignment by territory
            TERRITORY_MANAGEMENT__c tm = new TERRITORY_MANAGEMENT__c(name='TERRITORY_MGMT_SETTING',TM_FLAG__c = false);
            insert tm;
            
            Date dt = System.today().toStartOfMonth().addDays(7);
            
            Date closeDate2 = Date.parse('02/07/2020');
            Date closeDate3 = Date.parse('02/07/2020');
            Date lastdayofmonth =  Date.parse('02/28/2020');
            Date febdt = Date.parse('02/28/2020');
            User_Primary_Business__c bps = new User_Primary_Business__c();
            bps.Name = 'Safety-Kleen';
            bps.Primary_Business__c = 'Safety-Kleen';
            insert bps;
            
            Id AccountRTId = [Select id from RecordType where DeveloperName='Customer'].Id;
            List <account> accList = new List<account>();
            // Create 2 test accounts
            Account a = new Account(Name='Test Account',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555555',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator');
            accList.add(a);
            
            Account a2 = new Account(Name='Test Account2',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555555',CS_EPA_ID__c='200',Generator_Status__c='Large Quantity Generator');
            accList.add(a2);
            
            Account a3 = new Account(Name='Test Account3',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555555',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',
                                    ownerid = u1.id, Status__c ='Active', WIN_ID__c = 'TS1234', RecordTypeId = AccountRTId, IS_Opportunity_Rank__c =9,
                                    ShippingPostalCode = '45204',
                ShippingCountry = 'US',
                ShippingState = 'OR',
                ShippingStreet= 'Test Street',
                ShippingCity= 'Brookings',
                BillingPostalCode = '45204',
                BillingCountry = 'US',
                BillingState = 'OR',
                BillingStreet= 'Test Street',
                BillingCity = 'Brookings');
            accList.add(a3);
            insert accList;
            
            // Get revenue record type to be assigned when creating new financial record
            Id RevenueRT = [Select id from RecordType where DeveloperName='Revenue'].Id;
            
            // Create test financial record for testing the updateCrossLOBSell method. This record will have a related account and line of business matching matching an existing product
            Financials__c financial = new Financials__c(RecordTypeId=RevenueRT,Account__c = a.id,Type__c ='Revenue',Line_of_business__c='Bulk Services',Month__c = System.today().toStartOfMonth().addDays(-15));
            insert financial;
            
            // Create test financial record for testing the updateCrossLOBSell method. This record will have a related account and line of business unrelated to existing product(s)
            Financials__c financial1 = new Financials__c(RecordTypeId=RevenueRT,Account__c = a2.id,Type__c ='Revenue',Line_of_business__c='Dummy Product',Month__c = System.today().toStartOfMonth().addDays(-15));
            insert financial1;
            
            
            
            //  Create  3 test opportunities.
            //  Test Opportunity =  Test opportunity with an account which has a related financial revenue record with a matching line of business with the related opportunity product
            //  Test Opportunity2 = Test opportunity with an account which has a related financial revenue record with a line of business not related to the related opportunity product. 
            //                      This opportunity has a job start date set to last day of the month (04/30/2016)
            //  Test Opportunity3 = Test opportunity with an account which has a related financial revenue record with a line of business not related to the related opportunity product.
            //                      This opportunity has a job start date of 02/28/2016.
            List<Opportunity> oppList = new List<Opportunity>();
            
            Opportunity o = new Opportunity(Name='Test Opportunity1',AccountId=a.id,Business_Type__c='NEW-One Time',CloseDate=dt.addDays(-1),Job_Start_Date__c=dt,StageName='1 - Prospecting',amount=210000);
            
            Opportunity o2 = new Opportunity(Name='Test Opportunity5',AccountId=a2.id,Business_Type__c='NEW-One Time',CloseDate=closeDate2,Job_Start_Date__c=lastdayofmonth,StageName='1 - Prospecting',amount=110000);
            
            Opportunity o3 = new Opportunity(Name='Test Opportunity4',AccountId=a2.id,Business_Type__c='NEW-One Time',CloseDate=closeDate3,Job_Start_Date__c=febdt,StageName='1 - Prospecting',amount=260000);
            
            Opportunity o4 = new Opportunity(Name='Test Opportunity4',AccountId=a3.id,Business_Type__c='NEW-One Time',CloseDate=closeDate3,Job_Start_Date__c=febdt,StageName='1 - Prospecting',OwnerId = u1.id);
            
            oppList.add(o);
            oppList.add(o2);
            oppList.add(o3);
            oppList.add(o4);
            
            insert oppList;
            
            //Opportunity rank test
            String oppJSON = '{"attributes":{"url":"/services/data/v25.0/sobjects/Opportunity/600E0000002nH2fIAE"},"Id": "'+o4.id +'","LastModifiedDate":"2021-06-11T17:54:26.000+0000"}'; 
            o4 = (Opportunity) JSON.deserialize(oppJSON, Opportunity.class);
            List<FormulaRecalcResult> formularesults = Formula.recalculateFormulas(new List<Opportunity>{o4});
            system.debug('Opportunity_Rank__c--'+o4.Opportunity_Rank__c);
        	o4.StageName = '7 - Closed Won'; 
        	update o4;        


            // Opportunity opp = new Opportunity(Name='Test Opportunity4',AccountId=a2.id,Business_Type__c='NEW-One Time',opp.Ownerid.u.Primary_Business__c='Safety-Kleen',amount=500000,CloseDate=closeDate3,Job_Start_Date__c=febdt,StageName='1 - Prospecting');
            // insert opp;
            
            
            
            // Get standard price book id
            Id pricebookId = Test.getStandardPricebookId();  
            
            //Id allCHPBId = [select id,name from PriceBook2 where Name='All Clean Harbors'].Id;
            
            Pricebook2 customPB = new Pricebook2(Name='All Clean Harbors2', isActive=true);
            insert customPB;
            
            
            
            // Insert 2 test products with revenue schedule enabled. 1 product with no default and 1 product with single revenue schedule enabled
            // Product = Bulk Services, Active = true , DefaultRevenueSchedule = true (NO DEFAULT revenue installments)
            // Product = Catalyst Services, Active = true, DefaultRevenueSchedule = true, SingleRevenueSchedule = true
            Product2 prod = new Product2(Name = 'Bulk Services',isActive=true,CanUseRevenueSchedule=true,Business_Unit__c='Field Services');
            insert prod;
            
            Product2 prod2 = new Product2(Name = 'Catalyst Services',isActive=true,CanUseRevenueSchedule=true,Create_Single_Revenue_Schedule__c=true);
            insert prod2;
            
            
            // Insert 2 test pricebook entries one for each product as defined above
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 100, IsActive = true);
            //insert standardPrice;
            
            
            PricebookEntry standardPrice2 = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod2.Id,
                UnitPrice = 200, IsActive = true);
           // insert standardPrice2;
            List<PricebookEntry> prBkList = new List<PricebookEntry>();
            prBkList.add(standardPrice);
            prBkList.add(standardPrice2);
            
            insert prBkList;
            
            
            Test.startTest();
            
            
            // TEST SCENARIO : Insert new opportunity line item with number of months = null. The account of the opportunity has an existing financial 
            //                 revenue record with line of business matching with the related opportunity product.
            // EXPECTED RESULT: 1 revenue schedule will be created as default as the trigger assigns value of 1 as there is no defined default monthly 
            //                  installment schedule for the related product. 
            String PriceBook2Id = Test.getStandardPricebookId();
            oppList[0].pricebook2Id = PriceBook2Id;
            update oppList[0];
            

            /*OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=oppList[0].id,PriceBookEntryId=PriceBook2Id , Quantity=1,UnitPrice=100);
            insert oli1;*/
            
            
            
            oppList[0].amount= 260000;
            oppList[1].amount= 160000;
            oppList[2].amount= 260000;
            update oppList;
            // OpportunityTriggerHandler.testclasscodecoverage();
            Test.stopTest();
            // Reset the recursive flag 
            CheckRecursive.reset();
            
            //TEST SCENARIO: Update the Job start date of an existing opportunity to 10 days from the start of the current month. 
            //EXPECTED RESULT: For this opportunity (which has one  opportunity line item created on line 204 above) the existing 6 revenue schedules are deleted 
            
            
            //TEST SCENARIO: Insert new opportunity line item for an opportunity with a related account having 2 financial revenue records
            //               with one of them having line of business matching an existing product. This particular line item that is being
            //               inserted has a product which will not match against the line of business in the financial record.
            //EXPECTED RESULT: The flag No_LOB_Revenue_in_12_Months__c is set to true (no matching product)        
            //                 The flag No_Account_Revenue_in_12_Months__c is unchanged (false)  (has matching account from last year financial) 
            
          
            
            
            //TEST SCENARIO: Clone an opportunity and related products
            //EXPECTED RESULT: The cloned opportunity products must have the same sales price as the original
            //                 The new revenue records for the clone opportunity products must have the same revenue and duration as its original 
            
            CheckRecursive.reset();
            // First create new opportunity and add a related opportuniy product
            
            
            
           
            
            
        }
        
    }
    
    static testMethod void testBulk() {
        
        // TEST SUMMARY : This method tests the functionalities of the trigger for bulk record insert/update/delete of opportunity and opportunity product.
        //                The test data created in this method is limited to 200 as Apex trigger processes the records in batches of 200
        
        // Insert test data here    
        
        Trigger_Process__c tp_lobcs = new Trigger_Process__c(Name='LOB Cross Sell',canProcess__c=true);
        Trigger_Process__c tp_rs = new Trigger_Process__c(Name='Revenue Schedule',canProcess__c=true);   
        
        insert tp_lobcs;
        
        insert tp_rs; 
        
        SIC_VALIDATION_SETTING__c svc = new SIC_VALIDATION_SETTING__c(Name='SIC_VALIDATION_SETTING',SIC_VALIDATION_FLAG__c=false);
        insert svc;
        
        TERRITORY_MANAGEMENT__c tm = new TERRITORY_MANAGEMENT__c(name='TERRITORY_MGMT_SETTING',TM_FLAG__c = false);
        insert tm;
        
              
        //Date jd = Date.newInstance(today_dt.year(),today_dt.month(),today_dt.day());
        // Date jd = Date.parse('04/04/2016');
        //Date cd = Date.parse('03/04/2016');
        
               
        // Insert test account and opportunity 
        
        Id branchRT = [Select id from RecordType where DeveloperName='Branch'].Id;
        Account a = new Account(Name='Test Account',RecordTypeId=branchRT,Branch_Opportunity_Allowed__c =true ,AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='7885456978',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',CurrencyIsoCode='USD');
        insert a;
        
        Account a2 = new Account(Name='Test Account2',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='7885456978',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',CurrencyIsoCode='USD');
        insert a2;
        
        /*Account a3 = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', 
Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',
ShippingPostalCode = '02155', ShippingCountry = 'US' , ShippingState = 'MA', ShippingCity = 'Test City' , ShippingStreet = 'Test Street');
insert a3;*/
        
        /*   Opportunity o = new Opportunity(Name='Test Opportunity',AccountId=a2.id,Business_Type__c='NEW-One Time',CloseDate=dt,Job_Start_Date__c=jd,StageName='Prospecting',CurrencyIsoCode='USD');
insert o;

Opportunity o2 = new Opportunity(Name='Test Opportunity2',AccountId=a2.id,Business_Type__c='NEW-One Time',CloseDate=dt,Job_Start_Date__c=lastdayofmonth,StageName='Prospecting',CurrencyIsoCode='USD');
insert o2;
/*
Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPM Opportunity').getRecordTypeId();
Opportunity o3 = new Opportunity(Name='Test Opportunity3',recordtypeId=devRecordTypeId,AccountId=a3.id,TPM_Quote_Request__c=false,TPM_Quote_Request_To_Business__c = 'Field Services',Business_Type__c='NEW-One Time',CloseDate=dt,Job_Start_Date__c=lastdayofmonth,StageName='Prospecting',CurrencyIsoCode='USD');
insert o3;

o3.TPM_Quote_Request__c = true;
update o3;
*/
        
        // Get standard price book id
        /*  Id pricebookId = Test.getStandardPricebookId();

Pricebook2 customPB = new Pricebook2(Name='All Clean Harbors', isActive=true);
insert customPB;

// Insert test product with revenue schedule enabled
Product2 prod = new Product2(Name = 'Bulk Services',isActive=true,CanUseRevenueSchedule=true);
insert prod;

Product2 prod2 = new Product2(Name = 'Catalyst Services',isActive=true,CanUseRevenueSchedule=true,Create_Single_Revenue_Schedule__c=true);
insert prod2; 


// Insert test pricebook entry
PricebookEntry standardPrice = new PricebookEntry(
Pricebook2Id = priceBookId, Product2Id = prod.Id,
UnitPrice = 100, IsActive = true);
insert standardPrice;


PricebookEntry standardPrice2 = new PricebookEntry(
Pricebook2Id = pricebookId, Product2Id = prod2.Id,
UnitPrice = 200, IsActive = true);
insert standardPrice2;


List<OpportunityLineItemSchedule> olischList;
Integer sch_count;

// TEST SCENARIO: Create 200 opportunity line items in bulk with each line item having quantity = 2, unitprice = 100 and number of months =  6
// EXPECTED RESULT: The total revenue schedules created should equal 1200 (200*6)


Test.startTest();

List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

// Prepare and insert 200 opportunity line items. 
for(Integer intCount = 0 ;intCount <100 ; intCount++)
oliList.add(new OpportunityLineItem(Branch__c = a.id ,OpportunityId=o.id,PriceBookEntryId=standardPrice.id,    Quantity=2, UnitPrice=100,Number_of_Months__c='6'));

insert oliList; 


// Assert total revenues schedules created = 1200 = 200*6
// Assert that the revenue and schedule date matches as expected 
// Expected Revenue Value = 33.3333333333333333333333333333333 (Unit Price = 100, Quantity = 3 , Number of Months = 6) = (100/6)*3
// Expected Schedule Date = Date of the job start date for each corresponding month


//Integer sch_count = [Select count() from  OpportunityLineItemSchedule where OpportunityLineItemID = :oliList and Description='Created by Trigger'];
olischList = [Select Revenue,ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItemId = :oliList order by OpportunityLineItemId,ScheduleDate asc  ];
System.assertEquals(600,olischList.size());
jd=System.today().toStartofMonth().addDays(7);
// jd = Date.parse('04/04/2016');
Integer intCt = 0;

for(OpportunityLineItemSchedule olis :olischList) {
System.Debug('in bulk debug '+olis+' '+intCt+' '+jd); 
System.assertEquals(33.3333333333333333333333333333333,olis.Revenue);
System.assertEquals(jd,olis.ScheduleDate);

if(intCt >=5) {
intCt = 0;
// jd = Date.parse('04/04/2016');
jd=System.today().toStartofMonth().addDays(7);
continue;
}
jd = jd.addMonths(1);
intCt++;
}

// TEST SCENARIO:   Delete existing opportunity line items 
// EXPECTED RESULT: The related revenue schedules are deleted by the trigger.
CheckRecursive.reset();

delete [select id from OpportunityLineItem where id = :oliList];

// Assert that the related revenue schedules are removed from the database.
sch_count = [Select count() from  OpportunityLineItemSchedule where OpportunityLineItemID = :oliList ];
System.assertEquals(0,sch_count);


oliList.clear();
CheckRecursive.reset();

// TEST SCENARIO: Insert opportunity line items in bulk with no duration (number of months)
// EXPECTED RESULT: 1 revenue schedule is created for each line item as the trigger will default to number of months to 1  
for(Integer intCount = 0 ;intCount <200 ; intCount++)
oliList.add(new OpportunityLineItem(Branch__c = a.id ,OpportunityId=o.id,PriceBookEntryId=standardPrice.id,    Quantity=2, UnitPrice=100));

insert oliList;

//Assert that 200 revenue schedules are created in total (1 revenue schedule per line item)
sch_count = [Select count() from  OpportunityLineItemSchedule where OpportunityLineItemID = :oliList ];
System.assertEquals(200,sch_count);

CheckRecursive.reset(); 
//oliList = [Select OpportunityId,Quantity,UnitPrice,Number_Of_Months__c from OpportunityLineItem where id = :oliList ];


// TEST SCENARIO: update opportunity line items in bulk with number of months = 4
// EXPECTED RESULT: 800 (=200*4) revenue schedules are created with expected revenue and schedule date 
for(OpportunityLineItem oli:oliList) {

oli.Number_Of_Months__c = '4';
}      

update oliList;

// Assert total revenues schedules created = 800 = 200*4
// Assert that the revenue and schedule date matches as expected 
// Expected Revenue Value = 50 (Unit Price = 100, Quantity = 2 , Number of Months = 4) = (100/4)*2
// Expected Schedule Date = Date of the job start date for each corresponding month


olischList = [Select Revenue,ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItemId = :oliList order by OpportunityLineItemId,ScheduleDate asc  ];
System.assertEquals(800,olischList.size()); 

jd=System.today().toStartofMonth().addDays(7);
for(OpportunityLineItemSchedule olis:olischList) {

System.assertEquals(50.00,olis.Revenue);
System.assertEquals(jd,olis.ScheduleDate);

if(intCt >=3) {
intCt = 0;
// jd = Date.parse('04/04/2016');
jd=System.today().toStartofMonth().addDays(7);
continue;
}
jd = jd.addMonths(1);
intCt++;
}



Test.stopTest();
} */
    }

    @isTest 
    static void tesJobStartChange() {

        Test.startTest();
            Opportunity oppRecord = [SELECT Id FROM Opportunity LIMIT 1];
            oppRecord.Job_start_date__c = Date.today().addMonths(2);
            oppRecord.CloseDate = Date.today().addMonths(2);
            update oppRecord;
        Test.stopTest();

        System.assertEquals(Date.today().addMonths(2), oppRecord.Job_start_date__c, 'Job start date should be today only.');
    }


    @isTest 
    static void testUpdateCallCenterActivity() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Pricebook2 customPB = [SELECT Id,Name FROM Pricebook2 WHERE Name = 'Safety-Kleen / BPS' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry customPBEnt = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name = 'Safety-Kleen / BPS' LIMIT 1];

        Test.startTest();
            Task tObj = new Task(WhatId =accRec.id, Subject='Test task Subject',Description='This is a test This is a test This is a test This is a test This is a testThis is a test This is a testThis is a testThis is a testThis is a test');
            insert tObj;
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
            oppRec.Call_Center_Activity_ID__c = tObj.Id;
            oppRec.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Safety Kleen / BPS Opportunity').getRecordTypeId();
            INSERT oppRec;

            oppRec.Pricebook2Id = customPB.Id;
            oppRec.Job_start_date__c = Date.today().addMonths(1);
            UPDATE oppRec;
            
            System.debug('sdd ' + [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :oppRec.Id]);
            
            OpportunityLineItem oppLineItemObj = new OpportunityLineItem();
            oppLineItemObj.OpportunityId = oppRec.Id;
            oppLineItemObj.Product2Id = prod.Id;
            oppLineItemObj.PricebookEntryId = customPBEnt.Id;
            INSERT oppLineItemObj;
        Test.stopTest();

        System.assertEquals(Date.today().addMonths(1), oppRec.Job_start_date__c, 'Job start date should be today only.');
    }

    @isTest
    static void testPreventOpportunityProductDeletion_PartsCleaners() {
        Test.startTest();
        Product2 partsCleaners = new Product2(Name = 'Parts Cleaners');
        insert partsCleaners;

        OpportunityLineItem oliPartsCleaners = new OpportunityLineItem();
        oliPartsCleaners.Product2Id = partsCleaners.Id;
        OpportunityLineItemHandler.PreventOpportunityProductDeletion(new List<OpportunityLineItem>{oliPartsCleaners});
        Test.stopTest();

        System.assertEquals(1, oliPartsCleaners.getErrors().size(), 'To preserve Q2C sync, this opportunity line item cannot be deleted.');
    }	
}
//}