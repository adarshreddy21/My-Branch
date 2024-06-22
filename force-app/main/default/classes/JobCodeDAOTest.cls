/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-10-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-10-2022   Suresh Beniwal   Initial Version
**/
@isTest
private class JobCodeDAOTest {
    private final static string TEST_NAME='Farheen';
    private final static string TEST_RECORDTYPE_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
    private final static string TEST_ORGANISATION_STATUS = 'Draft';
    private final static string TEST_SHIPPING_STREET = 'Tolichowki';
    private final static string TEST_SHIPPING_CITY = 'Hyderabad';
    private final static string TEST_SHIPPING_STATE = 'Telangana';
    private final static string TEST_SHIPPING_COUNTRY = 'India';
    private final static string TEST_SHIPPING_POSTAL_CODE = '500001';
    private final static string TEST_JOB_CATEGORY = 'Chemists';
    
    @testSetup static void setupmethod() {
        Account acc = new Account(Name = TEST_NAME, RecordTypeId =TEST_RECORDTYPE_ID,
                               Organization_Status__c = TEST_ORGANISATION_STATUS,
                               ShippingStreet = TEST_SHIPPING_STREET, ShippingCity = TEST_SHIPPING_CITY,
                               ShippingState = TEST_SHIPPING_STATE, ShippingCountry = TEST_SHIPPING_COUNTRY,
                               ShippingPostalCode = TEST_SHIPPING_POSTAL_CODE );
        insert acc;
        Organization_Job_Code_Mapping__c orgJobMgr = new Organization_Job_Code_Mapping__c(Job_Category_Group__c =TEST_JOB_CATEGORY );
        insert orgJobMgr;
    }
          
    @IsTest static void TestListOfJobCodeByOrganizationId(){
        
        Account acc = [SELECT ID, Name FROM Account WHERE Name=:TEST_NAME LIMIT 1];
        JobCodeDAO.getListOfJobCodeByOrganizationIds(new set<id> {acc.id});
        Account acc1 = [SELECT ID, Name FROM Account WHERE Name=:TEST_NAME LIMIT 1];
        system.assertequals(acc.Name, acc1.Name, 'Organization is returned successfully')  ; 
        system.assertNotEquals(acc.Name, NULL, 'Organization Can Not Be Null');
        Organization_Job_Code_Mapping__c orgJobList = [SELECT ID, Job_Category_Group__c FROM Organization_Job_Code_Mapping__c
                                                  WHERE Job_Category_Group__c=:TEST_JOB_CATEGORY LIMIT 1];
        JobCodeDAO.dynamicQueryGetListOfJobCodeByOrganizationIds(new List<String>{orgJobList.Job_Category_Group__c});
    }
}