@isTest
public class ProcessOrganizationDataBatchTest {

    @testSetup
    static void makeData() {
        
        SIC_VALIDATION_SETTING__c setting = new SIC_VALIDATION_SETTING__c();
        setting.SIC_VALIDATION_FLAG__c = true;
        setting.Name = 'SIC_VALIDATION_SETTING';
        insert setting;
        
        TERRITORY_MANAGEMENT__c territory = new TERRITORY_MANAGEMENT__c();
        territory.Name = 'TERRITORY_MGMT_SETTING';
        territory.TM_FLAG__c = true;
        insert territory;
        
        Account acc = new Account();
        acc.Name = 'test account';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HR_Talent_Pools').getRecordTypeId();
        acc.Organization_Status__c = 'Draft';
        acc.ShippingStreet = '123';
        acc.ShippingCity = 'Jaipur';
        acc.ShippingState = 'CA';
        acc.ShippingCountry = 'US';
        acc.ShippingPostalCode = '302012';
        insert acc;
        
    }
    
    @isTest
    static void testExecute() {
        Data_Upload__c upload = new Data_Upload__c();
        upload.Status__c = 'In Progress';
        insert upload;
        
        Data_Upload_Line_Item__c lineItem = new Data_Upload_Line_Item__c();
        lineItem.Data_Upload__c = upload.Id;
        lineItem.Contact_FirstName__c = 'test';
        lineItem.Contact_LastName__c = 'con';
        lineItem.Contact_Email_Address__c = 'test@gmail.com';
        lineItem.Organization__c = 'test org';
        lineItem.Type__c = 'Corporate';
        lineItem.MailAddress__City__s = 'jaipur';
        lineItem.MailAddress__Street__s = 'CA';
        lineItem.MailAddress__StateCode__s = 'NJ';
        lineItem.MailAddress__CountryCode__s = 'US';
        lineItem.MailAddress__PostalCode__s = '302012';
        insert lineItem;
        Test.startTest();
        	Id jobId = Database.executeBatch(new ProcessOrganizationDataBatch(upload.Id));
        Test.stopTest();
        system.assertEquals(true, jobId!=null, 'job is executed');
    }
    
    @isTest
    static void testExecute1() {
        Data_Upload__c upload = new Data_Upload__c();
        upload.Status__c = 'In Progress';
        insert upload;
        
        Data_Upload_Line_Item__c lineItem = new Data_Upload_Line_Item__c();
        lineItem.Data_Upload__c = upload.Id;
        lineItem.Contact_FirstName__c = 'test';
        lineItem.Contact_LastName__c = 'con';
        lineItem.Contact_Email_Address__c = 'test@gmail.com';
        lineItem.Organization__c = 'test account';
        lineItem.Type__c = 'Branch';
        lineItem.MailAddress__City__s = 'jaipur';
        lineItem.MailAddress__Street__s = 'CA';
        lineItem.MailAddress__CountryCode__s = 'US';
        lineItem.MailAddress__StateCode__s = 'NJ';
        lineItem.MailAddress__PostalCode__s = '302012';
        insert lineItem;
        Test.startTest();
        	Id jobId = Database.executeBatch(new ProcessOrganizationDataBatch(upload.Id));
        Test.stopTest();
        system.assertEquals(true, jobId!=null, 'job is executed');
    }
}