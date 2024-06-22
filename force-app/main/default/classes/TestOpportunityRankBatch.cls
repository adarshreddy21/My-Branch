@isTest
private class TestOpportunityRankBatch {
    static testmethod void OpportunityRankScheduleTest(){
        Profile p1 = [Select id from Profile where name = 'Inside Sales Agent'];
        Profile p = [Select id from Profile where name = 'Integration'];
        UserRole R1 = [Select Id From UserRole where DeveloperName = 'SK_INS_BPS_AM'];
        List<User> userList = new List <User>();
        User u1 = new User(Alias = 'isduser', Email='insidesalesuser@cleanharbors.com', 
                           EmailEncodingKey='UTF-8', LastName='Inside Sales User', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p1.Id,UserRoleId = R1.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='insidesalesuser@cleanharbors.com',Primary_Business__c='Safety-Kleen');
        userList.add(u1);
        User u = new User(Alias = 'iuser', Email='iuser@cleanharbors.com', 
                          EmailEncodingKey='UTF-8', LastName='Integration User', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='integrationuser@cleanharbors.com',Primary_Business__c='Safety-Kleen');
        userList.add(u);
        insert userList;
        System.runAs(u){
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
            User_Primary_Business__c bps = new User_Primary_Business__c();
            bps.Name = 'Safety-Kleen';
            bps.Primary_Business__c = 'Safety-Kleen';
            insert bps;
            Id AccountRTId = [Select id from RecordType where DeveloperName='Customer'].Id;
            List <account> accList = new List<account>();
            Account a1 = new Account(Name='Test Account3',AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555555',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',
                                     ownerid = u1.id, Status__c ='Active', WIN_ID__c = 'TS1234', RecordTypeId = AccountRTId, IS_Opportunity_Rank__c = null);
            accList.add(a1);
            insert accList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity o1 = new Opportunity(Name='Test Opportunity',AccountId=a1.id,Business_Type__c='NEW-One Time',CloseDate=system.today(),Job_Start_Date__c=system.today(),StageName='1 - Prospecting',OwnerId = u1.id);
            
            oppList.add(o1);
            insert oppList;
            
            
            //Opportunity rank test
            String cronExpr = '0 0 23 * * ?';
            Test.startTest();
            OpportunityRankScheduler oppSched = new OpportunityRankScheduler();
            String jobId = System.schedule('myJobTestJobName', cronExpr, oppSched);
            Test.stopTest();
        }
    }
    
}