/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   11-28-2022   Suresh Beniwal   Initial Version
**/
@isTest
public class AccountSearchControllerTest {
    
    static testMethod void AccountSearchControllerTest1() {  
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 10; i++){
            accList.add(new Account(Name = 'Testing' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                   Generator_Status__c='Small Quantity Generator', Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor'
                                    /*Manifest_Post_Code__c = '12345', ShippingPostalCode = '02345', BillingPostalCode = '02345'*/));
        }
        insert accList;
        
        account acc = accList[0];
        List<Task> lt=new List<Task> {new task(
            WhatID = acc.Id,
            Caller_First_Name__c='Test95',
            Caller_Last_Name__c='Task91',
            Description='Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments',
            Call_Type__c='  Add Line Item',
            status='In Progress',
            Priority='Normal',
            Lead_Company_Name__c='test',
            Lead_Country__c='US'
        )};
            insert lt;
        list<event> evt=new list<event>{ new event(
            whatId=acc.Id,
            Call_Type__c='  Add Line Item',
            Description='Testing Commentst Testing CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting Commentst',
            Subject='Call',
            OwnerId='0054Q00000FKCl4',
            StartDateTime=system.today(),
            EndDateTime=system.today()+5
            
        )};
            insert evt;
        
        Test.StartTest();
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '1234'+i,Country__c = 'US', State__c = 'NY'));
            if(i > 5){
                zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'CA', State__c = 'PR'));
            } 
        }
        insert zipMasterList;
        
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
        
        Account account1 = new Account(ShippingCity = 'Las Vegas', ShippingPostalCode = '12345', ShippingCountry = 'US', ShippingStreet = 'testStreet', ShippingState='NY', Name = 'Testt08', Type='Customer', Status__c = 'Active',Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                    Generator_Status__c='Small Quantity Generator', Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor');
        insert account1;
        Account account2 = new Account(ShippingCity = 'Las Vegas', ShippingPostalCode = '12343', ShippingCountry = 'US', ShippingStreet = 'testStreet1', ShippingState='NY', Name = 'Testt09', Type='Customer', Status__c = 'Active',Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                    Generator_Status__c='Small Quantity Generator', Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor');
        insert account2;
        
        list<Contact> lstcon=new list<Contact>();
        Contact cont = new Contact();
        cont.LastName ='Test92';
        cont.FirstName ='Test91';
        cont.title='test2';
        cont.Contact_Type__c='AP';
        cont.Phone='8745263537';
        cont.Email='test45@gmail.com';
        cont.Salutation='Mr';
        cont.Accountid = account1.id;
        cont.Expired__c = false;
        lstcon.add(cont);
        
        insert lstcon;
        
        
        
        Apexpages.StandardController stdController = new Apexpages.StandardController(acc);
        AccountSearchController acc1=new AccountSearchController(stdController);
        Account accRec = new Account();
        acc1.currAccId = account1.Id;
        account2.ParentId = account1.Id;
        account2.Type = 'ShipTo/Gen';
        update account2;
        
        Task testTask = new Task();
        testTask.Subject = 'Subject Test';
        testTask.Priority = 'Normal';
        testTask.Status = 'Completed';
        testTask.WhatId = account2.Id;
        insert testTask;
        Event e = new Event();
        e.WhatId= account2.Id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.Description='Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments Testing CommentsTesting Comments Testing Comments';
        insert e;
        System.debug(' acc1.currAccId ' +  acc1.currAccId ); 
        acc1.accrec.OwnerId= Userinfo.getUserId();
        acc1.accrec.ShippingCity='Las Vegas';
        acc1.accrec.ShippingState='NY';
        
        // acc1.accrec.Status__c='Active'; 
        acc1.search();      
        acc1.showDetail();
        acc1.currAccId = account2.Id;
        
        acc1.nextAccount();
        acc1.clear();
        acc1.getAccount();
        acc1.save();
        
        // acc1.accId = lstcon[0].Id;
        // acc1.deletecontact();
        
        Test.StopTest();  
        
    }
    
    static testMethod void AccountSearchControllerTest2() {
        Test.StartTest();
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 2; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                   Generator_Status__c='Small Quantity Generator', Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor'
                                    /*Manifest_Post_Code__c = '12345', ShippingPostalCode = '12345', BillingPostalCode = '12345'*/));
        }
        insert accList; 
        
        account acc = accList[0];
        
        list<event> evt=new list<event>{ new event(
            whatId=acc.Id,
            Call_Type__c='  Add Line Item',
            Description='Testing Commentst Testing CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting CommentstTesting Commentst',
            Subject='Call',
            
            StartDateTime=system.today(),
            EndDateTime=system.today()+5
            
        )};
            insert evt;
        
        List<Task> lt=new List<Task> {new task(
            WhatID = acc.Id,
            Caller_First_Name__c='Test',
            Caller_Last_Name__c='Task',
            Description='Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments Testing CommentsTesting Comments Testing Comments',
            Call_Type__c='  Add Line Item',
            status='In Progress',
            Priority='Normal',
            Lead_Company_Name__c='test',
            Lead_Country__c='US'
        )};
            insert lt;
        
        List<Account> accList1 = new List<Account>();  
        for(Integer i = 0; i < 5; i++){
            accList1.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                     Generator_Status__c='Small Quantity Generator', Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor'
                                     /*Manifest_Post_Code__c = '12345', ShippingPostalCode = '12345', BillingPostalCode = '12345'*/));
        }
        insert accList1;
        
        Apexpages.StandardController stdController = new Apexpages.StandardController(acc);
        AccountSearchController acc1=new AccountSearchController(stdController);
        Id str1 = [SELECT ID FROM account LIMIT 1].Id;
        Event e = new Event();
        e.WhatId=str1;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.Description='Testing Comments Testing Comments Testing Comments Testing Comments Testing Comments Testing CommentsTesting Comments Testing Comments';
        insert e;
        acc1.currAccId = str1;
        AccountSearchController.getdataforWrapper((String)str1);
        acc1.accId = evt[0].Id;
        acc1.delettask();
        
        
        
        Case c = new case();
        c.accountId = [SELECT ID FROM account LIMIT 1].Id;
        c.Status = 'New';
        c.Model_Number__c = 'Model 14';
        c.Solvent__c = 'QSOLV 220';
        insert c;
        acc1.accId = [SELECT ID FROM Case LIMIT 1].Id;
        //acc1.deletecase();
        
        
        
        Beacon_Call_Notes__c boc=new Beacon_Call_Notes__c();
        
        boc.Assigned_To__c='0054Q00000FKCl4';
        boc.Call_Note_Account__c=[SELECT ID FROM account LIMIT 1].Id;
        boc.Color__c='Orange - Resolution';
        boc.Contact_Method__c='E-Mail';
        boc.Type__c='Phone';
        boc.Services_Discussed__c='Directional Boring Services';
        boc.Next_Action__c='Call';
        boc.Account_Class__c='Base';
        insert boc;
        //acc1.accId = [SELECT ID FROM Beacon_Call_Notes__c LIMIT 1].Id;
        //acc1.deletedata();
        
        
        Test.StopTest(); 
        
    } 
}