/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
**/
@isTest
public class TestStrategicAccountPlanController {
    Strategic_Account_Plan__c plan = new Strategic_Account_Plan__c();
    
    @testSetup static void setupRecords() {
        Test.startTest();
        Profile p = [Select id from Profile where name = 'Integration'];
        
        
        // Create test integration user
        User u = new User(Alias = 'iuser', Email='iuser@cleanharbors.com', 
                          EmailEncodingKey='UTF-8', LastName='Integration User', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, Primary_Business__c = 'Sales Operation',
                          TimeZoneSidKey='America/Los_Angeles', UserName='integrationuser@cleanharbors.com');
        
        insert u;
        
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
        
        System.runAs(u) {
            Date dt = System.today().toStartOfMonth();
            
            Territory__c terri = new Territory__c(Name = 'Test Terri', Territory_OwnerID__c = u.id);
            insert terri;
            List <Account> accList = new List <Account> ();
            Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
            
            Account acc = new Account(Name = 'Test Account1',dunbrdst__c = '12345',ShippingCountry = 'US',ShippingState = 'NY',ShippingStreet = 'Test Street',ShippingCity = 'Ashburn',ShippingPostalCode = '12345', Phone = '1234567891', KAM_Support__c = u.id,KAM_Manager__c = u.id, Territory_ID_SK__c = terri.id, RecordTypeId = accRecTypeId);
            accList.add(acc);
            
            accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            acc = new Account(Name = 'Test Account2', Phone = '1234567891', KAM_Support__c = u.id,KAM_Manager__c = u.id, Territory_ID_SK__c = terri.id, RecordTypeId = accRecTypeId);
            accList.add(acc);
            
            insert accList;
            
            List<Contact> conList = new List<Contact>();
            for(integer i = 0; i< 4; i++){
                if(i < 2){
                    conList.add(new Contact(AccountId = accList[0].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.', Title = 'Manager', Phone = '1234567891', Contact_type__c = 'SALE', Relationship_Strength__c= 'Strong', Relationship_Development_Plan__c = 'Test',Strategic_Account_Plan__c = null));
                }else{
                    conList.add(new Contact(AccountId = accList[1].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.', Title = 'Manager', Phone = '1234567891', Contact_type__c = 'SALE', Relationship_Strength__c= 'Strong', Relationship_Development_Plan__c = 'Test',Strategic_Account_Plan__c = null));
                }
            }
            
            insert conList;
            // Insert the custom settings with the checkbox enabled to true to ensure that the trigger allows the revenue schedule updates
            // and LOB field updates.
            Trigger_Process__c tp_lobcs = new Trigger_Process__c(Name='LOB Cross Sell',canProcess__c=true);
            Trigger_Process__c tp_rs = new Trigger_Process__c(Name='Revenue Schedule',canProcess__c=true);   
            
            insert tp_lobcs;
            
            insert tp_rs;
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Lodging',isActive=true,CanUseRevenueSchedule=true);
            insert prod;
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 100, IsActive = true);
            insert standardPrice;
            
            
            List<Technical_Sales_Expert__c> tseList = new List<Technical_Sales_Expert__c>();
            for(Integer i = 0; i < 2; i++){
                tseList.add(new Technical_Sales_Expert__c (Name = 'Test TSE',Account__c = accList[i].id,Technical_Sales_Expert_lookup__c = u.id, Product__c =prod.id));
            } 
            insert tseList;
            
            User_Primary_Business__c SK = new User_Primary_Business__c();
            SK.Name = 'Safety-Kleen';
            SK.Primary_Business__c = 'Safety-Kleen';
            insert SK;
            
            List<Opportunity> oppList = new List<Opportunity>();
            for(Integer i = 0; i < 4; i++){
                if(i < 2){
                    oppList.add(new Opportunity(Name='Test Opportunity' + i, AccountId=accList[0].id, Amount = 200,Business_Type__c='NEW-One Time',CloseDate=dt,Job_Start_Date__c=dt,StageName='1 - Prospecting', Description = 'Test',NextStep = '', Strategic_Account_Plan__c = null, ownerid = u.id, Deal_LOB__c = 'Lodging'));
                }else{
                    oppList.add(new Opportunity(Name='Test Opportunity' + i, AccountId=accList[1].id, Amount = 200,Business_Type__c='NEW-One Time',CloseDate=dt,Job_Start_Date__c=dt,StageName='1 - Prospecting', Description = 'Test',NextStep = '', Strategic_Account_Plan__c = null, ownerid = u.id, Deal_LOB__c = 'Lodging'));
                }
            }
            insert oppList;
            
            
            List<Sales_Manager_Summary_Note__c> SNList = new List<Sales_Manager_Summary_Note__c>();
            for(Integer i = 0; i < 4; i++){
                if(i < 2){
                    SNList.add(new Sales_Manager_Summary_Note__c(Account__c = accList[0].id,Opportunity__c = oppList[i].id,Note__c = 'Test',Type__c = 'Sales Summary', Strategic_Account_Plan__c = null));
                }else{
                    SNList.add(new Sales_Manager_Summary_Note__c(Account__c = accList[1].id,Opportunity__c = oppList[i].id,Note__c = 'Test',Type__c = 'Sales Summary', Strategic_Account_Plan__c = null));
                }
            }
            insert SNList;
        }
        Test.stopTest();
    }
    
    public static testMethod void testEditStrategicPlan() {
        List<Strategic_Account_Plan__c> editPlanList = testStrategicPlan();
        for(Strategic_Account_Plan__c editPlan:editPlanList){
            PageReference pageRef = new PageReference('EditStrategicAccountPlan');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController std= new ApexPages.StandardController(editPlan);
            StrategicAccountPlanController EditStrategicCont = new StrategicAccountPlanController(std);
            EditStrategicCont.getAccountName();
            EditStrategicCont.forecastCmptr ='Forecast';
            EditStrategicCont.AddRowforcastplan();
            EditStrategicCont.forecastCmptr ='Competitor';
            EditStrategicCont.AddRowforcastplan();
            EditStrategicCont.next();
            EditStrategicCont.last();
            EditStrategicCont.previous();
            EditStrategicCont.first();
            EditStrategicCont.objectType = 'Contact';
            pageRef = EditStrategicCont.AddRecords();
            Test.setCurrentPage(pageRef);
            List <StrategicAccountPlanController.cObject> contactlist =  EditStrategicCont.getAllObject();
            system.assertNotEquals(null, contactlist);
            EditStrategicCont.selectedAllProperties = true;
            EditStrategicCont.isSelectedAll();
            for(StrategicAccountPlanController.cObject c:contactlist){
                EditStrategicCont.contextItem = c.obj.id;
                EditStrategicCont.doDeselectItem();
                EditStrategicCont.doSelectItem();
            }
            contactlist = EditStrategicCont.getAllObject();
            EditStrategicCont.selectedPropertyIds.add(contactlist[0].obj.id);
            pageRef = EditStrategicCont.processSelectedRecords();
            Test.setCurrentPage(pageRef);
            EditStrategicCont.getAllSelectedContacts(); 
            EditStrategicCont.CustomSave();
        }
        
        Strategic_Account_Plan__c editPlan1 = editPlanList[0];
        PageReference pageRef = new PageReference('EditStrategicAccountPlan');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController std1= new ApexPages.StandardController(editPlan1);
        StrategicAccountPlanController EditStrategicCont1 = new StrategicAccountPlanController(std1);
        EditStrategicCont1.selectedContactsDisplay[0].selected =true;
        EditStrategicCont1.objectType = 'Contact';
        EditStrategicCont1.processRemovedRecords();
        EditStrategicCont1.CustomSave();
    }
    
    
    private static List<Strategic_Account_Plan__c> testStrategicPlan() {
        
        List <Account> accList = [SELECT Id FROM Account];
        List<Strategic_Account_Plan__c> planList = new List<Strategic_Account_Plan__c>();
        for (integer i = 0; i < 2; i++){
            Strategic_Account_Plan__c plan = new Strategic_Account_Plan__c(Name = 'Test Plan'+ i,Account__c = accList[i].id);
            
            PageReference pageRef = new PageReference('StrategicAccountPlan');
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put(('retURL'),'F'+accList[i].id);
            system.debug(''+ApexPages.currentPage().geturl());
            
            ApexPages.StandardController std= new ApexPages.StandardController(plan);
            StrategicAccountPlanController StrategicCont = new StrategicAccountPlanController(std);
            StrategicCont.getAccountName();
            
            List<Strategy_Plan_Forecast_Competitor_Info__c> ForecastList = StrategicCont.getforcastplan();
            ForecastList[0] = new Strategy_Plan_Forecast_Competitor_Info__c(Name = 'Test Existing Forecast', Line_of_Business__c = 'Airborne Imaging',Current_New_LOB__c = 'Existing_LOB');
            
            List<Strategy_Plan_Forecast_Competitor_Info__c> CmpList = StrategicCont.getcmptrPlan();
            CmpList[0] = new Strategy_Plan_Forecast_Competitor_Info__c(Name = 'Test Existing compr', Line_of_Business__c = 'Airborne Imaging');
            
            StrategicCont.objectType = 'Contact';
            pageRef = StrategicCont.AddRecords();
            Test.setCurrentPage(pageRef);
            List <StrategicAccountPlanController.cObject> contactlist =  StrategicCont.getAllObject();
            system.assertNotEquals(null, contactlist);
            StrategicCont.SearchbyField = 'Last';
            StrategicCont.getSearchByFilter();
            contactlist =  StrategicCont.getAllObject();
            StrategicCont.selectedAllProperties = true;
            StrategicCont.isSelectedAll();
            for(StrategicAccountPlanController.cObject c:contactlist){
                StrategicCont.contextItem = c.obj.id;
                StrategicCont.doDeselectItem();
                StrategicCont.doSelectItem();
            }
            contactlist = StrategicCont.getAllObject();
            StrategicCont.selectedPropertyIds.add(contactlist[0].obj.id);
            pageRef = StrategicCont.processSelectedRecords();
            Test.setCurrentPage(pageRef);
            StrategicCont.getAllSelectedContacts();
            StrategicCont.selectedContactsDisplay[0].selected =true;
            StrategicCont.objectType = 'Contact';
            StrategicCont.processRemovedRecords();
            
            StrategicCont.objectType = 'Opportunity';
            pageRef = StrategicCont.AddRecords();
            Test.setCurrentPage(pageRef);
            StrategicCont.sortExpression = 'Owner.Name';
            StrategicCont.getalphaSearch();
            StrategicCont.getSortDirection();
            StrategicCont.getalphaSearch();
            List <StrategicAccountPlanController.cObject> opplist =  StrategicCont.getAllObject();
            StrategicCont.isSelectedAll();
            for(StrategicAccountPlanController.cObject o:opplist){
                StrategicCont.contextItem = o.obj.id;
                StrategicCont.doSelectItem();
            }
            opplist = StrategicCont.getAllObject();
            pageRef = StrategicCont.processSelectedRecords();
            Test.setCurrentPage(pageRef);
            List<StrategicAccountPlanController.cObject> selectedOpportunityDisplay = StrategicCont.getAllSelectedOpportunity();
            selectedOpportunityDisplay[0].selected =true;
            StrategicCont.objectType = 'Opportunity';
            StrategicCont.processRemovedRecords();
            
            StrategicCont.objectType = 'SummaryNotes';
            pageRef = StrategicCont.AddRecords();
            Test.setCurrentPage(pageRef);
            List <StrategicAccountPlanController.cObject> SNlist =  StrategicCont.getAllObject();
            StrategicCont.isSelectedAll();
            for(StrategicAccountPlanController.cObject SN:SNlist){
                StrategicCont.contextItem = SN.obj.id;
                StrategicCont.doSelectItem();
            }
            SNlist = StrategicCont.getAllObject();
            pageRef = StrategicCont.processSelectedRecords();
            Test.setCurrentPage(pageRef);
            List<StrategicAccountPlanController.cObject> selectedSummaryNotesDisplay = StrategicCont.getAllSelectedSummaryNotes();
            selectedSummaryNotesDisplay[0].selected =true;
            StrategicCont.objectType = 'SummaryNotes';
            StrategicCont.processRemovedRecords();
            
            StrategicCont.objectType = '';
            pageRef = StrategicCont.AddRecords();
            
            pageRef = new PageReference('StrategicAccountPlan');
            Test.setCurrentPage(pageRef);  
            StrategicCont.CustomSave();
            StrategicCont.CustomCancel();
            planList.add(plan);      
        }
        return planList;
    }
    
}