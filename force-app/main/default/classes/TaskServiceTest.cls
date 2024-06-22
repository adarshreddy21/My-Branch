/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-23-2022
 * @last modified by  : Suresh Beniwal 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-23-2022   Suresh Beniwal   Initial Version
**/
@isTest
public class TaskServiceTest {

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
    private static final string TEST_Job_Category_Group ='Chemists';
    private static final string TEST_Sub_Category ='lab Chemists';
    
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
    static void testGetTaskDetails() {
        Id contactRecordTypeId = Schema.Sobjecttype.Contact.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
        Account acc = [SELECT Id,RecordType.Name FROM Account LIMIT 1];
        Contact con = new Contact (
            RecordTypeId = contactRecordTypeId, AccountId = acc.Id, 
            Org_Contact_Type__c =TEST_CONTACT_TYPE,salutation=TEST_SALUTATION, 
            FirstName=TEST_FIRST_NAME, LastName=TEST_LAST_NAME, Email=TEST_EMAIL);
        insert con;
        Task taskRecord = new Task();
        taskRecord.WhoId = con.Id;
        taskRecord.WhatId = acc.Id;
        taskRecord.Description = 'test task';
        insert taskRecord;
        
        Task taskRecord1 = new Task();
        taskRecord1.WhoId = null;
        taskRecord1.WhatId = acc.Id;
        taskRecord1.Description = 'test task2';
        insert taskRecord1;
        
        Test.startTest();
        	List<TaskService.TaskWrapper> wrapper = TaskService.getTaskDetails(new Set<Id>{acc.Id});
        	TaskDAO.getAccountActivities(new Set<Id>{acc.Id});
        Test.stopTest();
        System.assertEquals(true, !wrapper.isEmpty(), 'wrapper with taks details is returned');
        
    }
}