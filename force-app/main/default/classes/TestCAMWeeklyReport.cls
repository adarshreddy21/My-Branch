@isTest
public class TestCAMWeeklyReport {
    
    @testSetup static void setupRecords() {     
        
        //Insert the custom settings with validation set to false to skip validation of business rules and checks on account fields called in the account trigger.       
        SIC_VALIDATION_SETTING__c svc = new SIC_VALIDATION_SETTING__c(Name='SIC_VALIDATION_SETTING',SIC_VALIDATION_FLAG__c=false);
        insert svc;
        
        //Insert the custom settings with TM flag set to false to skip account owner assignment by territory
        TERRITORY_MANAGEMENT__c tm = new TERRITORY_MANAGEMENT__c(name='TERRITORY_MGMT_SETTING',TM_FLAG__c = false);
        insert tm;
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
        
        User_Primary_Business__c bps = new User_Primary_Business__c(Name = 'Safety-Kleen',Primary_Business__c = 'Safety-Kleen');
        insert bps;
        Date dt = System.today().toStartOfMonth();
        
        Territory__c terri = new Territory__c(Name = 'Test Terri', Territory_OwnerID__c = UserInfo.getUserId());
        insert terri;
        List <Account> accList = new List <Account> ();
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        
        for (integer i = 0; i < 2; i++){
            Account acc = new Account(Name = 'Test Account'+ i, WIN_ID__c = '1234'+ i, Phone = '1234567891', Territory_ID_SK__c = terri.id, RecordTypeId = accRecTypeId, X2020_Corp_Budget_Q1__c = 100,X2020_Corp_Budget_Q2__c = 200,X2020_Corp_Budget_Q3__c = 300,X2020_Corp_Budget_Q4__c= 400,
            dunbrdst__c = '12345',KAM_Manager__c = UserInfo.getUserId(),KAM_Support__c = UserInfo.getUserId(),OwnerId = UserInfo.getUserId(),ShippingCountry = 'US',
            ShippingState = 'NY',
        	ShippingStreet = 'Test Street',
       	    ShippingCity = 'Ashburn',
            ShippingPostalCode = '12345');
            accList.add(acc);
        }
        
        insert accList;
        
        
        // Insert the custom settings with the checkbox enabled to true to ensure that the trigger allows the revenue schedule updates
        // and LOB field updates.
        Trigger_Process__c tp_lobcs = new Trigger_Process__c(Name='LOB Cross Sell',canProcess__c=true);
        Trigger_Process__c tp_rs = new Trigger_Process__c(Name='Revenue Schedule',canProcess__c=true);   
        
        insert tp_lobcs;
        
        insert tp_rs;
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Bulk Services',isActive=true,CanUseRevenueSchedule=true);
        insert prod;
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        
        List<Technical_Sales_Expert__c> tseList = new List<Technical_Sales_Expert__c>();
        for(Integer i = 0; i < 2; i++){
            tseList.add(new Technical_Sales_Expert__c (Name = 'Test TSE',Account__c = accList[i].id,Technical_Sales_Expert_lookup__c = UserInfo.getUserId(), Product__c =prod.id));
        } 
        insert tseList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < 4; i++){
            if(i < 2){
                oppList.add(new Opportunity(Name='Test Opportunity' + i, AccountId=accList[0].id, Amount = 200,Business_Type__c='NEW-One Time',CloseDate=dt,Job_Start_Date__c=dt,StageName='7 - Closed Won', Description = 'Test', ownerid = UserInfo.getUserId(), Deal_LOB__c = 'Bulk Services'));
            }else{
                oppList.add(new Opportunity(Name='Test Opportunity' + i, AccountId=accList[1].id, Amount = 200,Business_Type__c='NEW-One Time',CloseDate=dt,Job_Start_Date__c=dt,StageName='8 - Closed Lost', Lost_Category__c = 'System', Lost_Reason__c = 'User Error - Created in Error', Description = 'Test', ownerid = UserInfo.getUserId(), Deal_LOB__c = 'Bulk Services'));
            }
        }
        insert oppList;
        
        List<Sales_Manager_Summary_Note__c> SNList = new List<Sales_Manager_Summary_Note__c>();
        for(Integer i = 0; i < 4; i++){
            if(i < 2){
                SNList.add(new Sales_Manager_Summary_Note__c(Account__c = accList[0].id,Opportunity__c = oppList[i].id,Note__c = 'Test',Type__c = 'Sales Summary'));
            }else{
                SNList.add(new Sales_Manager_Summary_Note__c(Account__c = accList[1].id,Opportunity__c = oppList[i].id,Note__c = 'Test',Type__c = 'Sales Summary'));
            }
        }
        insert SNList;
        for(Sales_Manager_Summary_Note__c SN:SNList){
            Test.setCreatedDate(SN.Id, System.today().toStartOfWeek() - 8);
        }
    }
    
    public static testMethod void testCreateViewWeeklyReport() {
        
        List<Sales_Manager_Summary_Note__c> SNList = new List<Sales_Manager_Summary_Note__c>();
        PageReference pageRef = new PageReference('CAMWeeklyReport');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController stdset= new ApexPages.StandardSetController(SNList);
        CAMWeeklyReportController CAMReport = new CAMWeeklyReportController(stdset);
        CAMReport.getSummaryNotes();
        CAMReport.getWonOpportunities();
        CAMReport.getLostOpportunities();
        for (Sales_Manager_Summary_Note__c SN:CAMReport.SNList){
            SN.Note__c = 'Test';
            SN.Issues_Obstacles__c = 'Test';
            SN.Forecast__c = 100;
        }
        
        CAMReport.CustomSave();
        CAMReport.dateFrom.closedate = System.today().toStartOfWeek() - 8;
        CAMReport.EndDate();
        CAMReport.SearchRecords();
         for (Sales_Manager_Summary_Note__c SN:CAMReport.SNList){
            SN.Note__c = 'Test';
            SN.Issues_Obstacles__c = 'Test';
            SN.Forecast__c = 100;
        } 
        CAMReport.CustomSave();
        
       	pageRef = new PageReference('ViewMyCAMTeamWeeklyReport');
        Test.setCurrentPage(pageRef);
        CAMWeeklyReportController CAMViewReport = new CAMWeeklyReportController(stdset);
        CAMViewReport.getSummaryNotes();
        CAMViewReport.getWonOpportunities();
        CAMViewReport.getLostOpportunities();
        CAMViewReport.dateFrom.closedate = System.today().toStartOfWeek() - 8;
        CAMViewReport.dateTo.closedate = CAMViewReport.dateFrom.closedate + 6;
        CAMViewReport.SearchRecords();
        
    } 
}