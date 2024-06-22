/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 09-12-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-23-2022   Suresh Beniwal   Initial Version
**/
@isTest
public class JobCodeTriggerHandlerTest {
private final static string TEST_NAME='Mohammed'; 
    private final static string TEST_SALUTATION = 'Mr';
    private final static string TEST_FIRST_NAME='Farheen';
    private final static string TEST_LAST_NAME='Siddique';
    private final static string TEST_RECORDTYPE_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
    private final static string TEST_CONTACT_TYPE= 'Dean';
    private final static string TEST_EMAIL = 'irfan@gmail.com';
    private final static string TEST_ORGANISATION_STATUS = 'Draft';
    private final static string TEST_SHIPPING_STREET = 'Tolichowki';
    private final static string TEST_SHIPPING_CITY = 'Hyderabad';
    private final static string TEST_SHIPPING_STATE = 'Telangana';
    private final static string TEST_SHIPPING_COUNTRY = 'India';
    private final static string TEST_SHIPPING_POSTAL_CODE = '500001';
    
    @TestSetup
    static void makeData() {
        Id contactRecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HR_Talent_Pools').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Farheen';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Organization_Status__c ='Draft';
        //acc.Organization_ID__c = acc.id;
        acc.Organization_Category__c = 'Driver School';
        acc.ShippingStreet = '123';
        acc.ShippingCity = 'Jaipur';
        acc.ShippingState = 'CA';
        acc.ShippingCountry = 'US';
        acc.ShippingPostalCode = '302012';

        insert acc;

        Contact con = new Contact (RecordTypeId = contactRecordTypeId, AccountId = acc.Id, Org_Contact_Type__c =TEST_CONTACT_TYPE,salutation=TEST_SALUTATION, FirstName=TEST_FIRST_NAME, LastName=TEST_LAST_NAME, Email=TEST_EMAIL);
        insert con;

        Schema.Location locationRecord = new Schema.Location();
        locationRecord.Name = 'Test';
        locationRecord.Organization__c = acc.Id;
        locationRecord.Address__Street__s = '124';
        locationRecord.Address__City__s = 'Jaipur';
        locationRecord.Address__StateCode__s = 'CA';
        locationRecord.Address__CountryCode__s = 'US';
        locationRecord.Address__PostalCode__s = '303303';
        insert locationRecord;

        con.Locations__c = locationRecord.Id;
        update con;  

        JobCodeTriggerHandler jobCode = new JobCodeTriggerHandler();
        jobCode.AfterDelete(null);
        jobCode.AfterUndelete(null);
        jobCode.AfterUpdate(null, null);
        jobCode.BeforeDelete(null);
        jobCode.BeforeUpdate(null, null);
        jobCode.AfterInsert(null);
    }

    @IsTest 
    static void testupdateOrganization() {
        Schema.Location locationRecord = [SELECT Id FROM Location LIMIT 1];
        Organization_Job_Code_Mapping__c JobMapping = new Organization_Job_Code_Mapping__c();
        JobMapping.Job_Category_Group__c = 'Chemists';
        insert JobMapping;
        Organization_Job_Code__c organizationJobCode = new Organization_Job_Code__c();
        organizationJobCode.Location__c = locationRecord.Id;
        organizationJobCode.Job_Code_Mapping__c = JobMapping.Id;

        Test.startTest();
            insert organizationJobCode;
        Test.stopTest();

        System.assertEquals(false, [SELECT Id, Organization__c FROM Organization_Job_Code__c WHERE Id =: organizationJobCode.Id].isEmpty(), 'Deparment should be returned.');
    }
}