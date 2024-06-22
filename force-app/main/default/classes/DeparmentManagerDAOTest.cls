/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-23-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-10-2022   Suresh Beniwal   Initial Version
**/
@isTest
private class DeparmentManagerDAOTest {
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

        Organization_Department_Mgr__c departMentManager = new Organization_Department_Mgr__c();
        departMentManager.MGR_LVL_1_DESCR__c = 'Administrative';
        departMentManager.MGR_LVL_3_DESCR__c = 'Corporate';
        insert departMentManager;

        Organization_Department__c organizationDeparments = new Organization_Department__c();
        organizationDeparments.Location__c = locationRecord.Id;
        organizationDeparments.Dept_ID__c = departMentManager.Id;
        insert organizationDeparments;
    }

    @IsTest 
    static void testJobCodeMappingForMgrLevelDescSet(){
        
        Test.startTest();
        List<Organization_Department_Mgr__c> listOfDepartmentManager = DeparmentManagerDAO.getListOfDepartmentManagers();
        Test.stopTest();

        System.assertEquals(false, listOfDepartmentManager.isEmpty(), 'Department managers returned successfully!!'); 
    }
}