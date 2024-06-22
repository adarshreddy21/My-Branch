/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 10-04-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   10-04-2022   Suresh Beniwal   Initial Version
**/
@isTest
public class DeleteSchedulesAndEditPriceTest {
	@testSetup
    public static void setup(){
        Trigger_Process__c tp_lobcs = new Trigger_Process__c(Name='LOB Cross Sell',canProcess__c=false);
            Trigger_Process__c tp_rs = new Trigger_Process__c(Name='Revenue Schedule',canProcess__c=false);   
            
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
            
            
            // Create 2 test accounts
            Account a = new Account(Name='Test Account',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555556555',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator');
            insert a;
            
            Account a2 = new Account(Name='Test Account2',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555556555',CS_EPA_ID__c='200',Generator_Status__c='Large Quantity Generator');
            insert a2;
            
            
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
            //insert o;
            
            Opportunity o2 = new Opportunity(Name='Test Opportunity5',AccountId=a2.id,Business_Type__c='NEW-One Time',CloseDate=closeDate2,Job_Start_Date__c=lastdayofmonth,StageName='1 - Prospecting',amount=110000);
            //insert o2; 
            
            Opportunity o3 = new Opportunity(Name='Test Opportunity4',AccountId=a2.id,Business_Type__c='NEW-One Time',CloseDate=closeDate3,Job_Start_Date__c=febdt,StageName='1 - Prospecting',amount=260000);
            //insert o3; 
            
            oppList.add(o);
            oppList.add(o2);
            oppList.add(o3);
            
            insert oppList;
            
            // Opportunity opp = new Opportunity(Name='Test Opportunity4',AccountId=a2.id,Business_Type__c='NEW-One Time',opp.Ownerid.u.Primary_Business__c='Safety-Kleen',amount=500000,CloseDate=closeDate3,Job_Start_Date__c=febdt,StageName='1 - Prospecting');
            // insert opp;
            
            
            
            // Get standard price book id
            Id pricebookId = Test.getStandardPricebookId();  
            
            //Id allCHPBId = [select id,name from PriceBook2 where Name='All Clean Harbors'].Id;
            
            Pricebook2 customPB = new Pricebook2(Name='All Products', isActive=true);
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
            String PriceBook2Id = pricebookId;
            oppList[0].pricebook2Id = PriceBook2Id;
            update oppList[0];
            

            /*OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=oppList[0].id,PriceBookEntryId=PriceBook2Id , Quantity=1,UnitPrice=100);
            insert oli1;*/
            
            
            
            oppList[0].amount= 260000;
            oppList[1].amount= 160000;
            oppList[2].amount= 260000;
            update oppList;
        
        	System.debug('customPB.Id ' + oppList[0].pricebook2Id);
        
        	/*OpportunityLineItem opportunitylineitem = new OpportunityLineItem(
            OpportunityId=oppList[0].Id,
                PriceBookEntryId=prBkList[0].Id,
            Quantity = 1.0,
            UnitPrice = 10.0,
            Product_Gallons__c = 0.0,
            Product_Pounds__c = 0.0,
            Service_Term__c = 52.0,
            Installment_Period__c = 'Monthly',
            No_Account_Revenue_in_12_Months__c = false,
            No_LOB_Revenue_in_12_Months__c = true,
            Number_of_Months__c = '1',
            Schedule_Type__c = 'Divide Amount into multiple installments',
            isClone__c = false,
            DIY_tank_subscription_fee__c = false,
            DIY_tank_installation_fee__c = false);
        
        INSERT opportunitylineitem;*/

    }
    
    @isTest
    public static void unitTest(){
        DeleteSchedulesAndEditPrice.getOppLineItemDetails(null);
        DeleteSchedulesAndEditPrice.deleteSchedules(new List<Id>());
    }
}