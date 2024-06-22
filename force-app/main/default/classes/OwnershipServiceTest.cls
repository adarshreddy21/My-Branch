/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 09-09-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-25-2022   Suresh Beniwal   Initial Version
**/
@isTest
public class OwnershipServiceTest {

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
        User sysAdmin = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(sysAdmin) {
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Super Recruiter' LIMIT 1].Id,
                LastName = 'sunamilast',
                Email = 'susnTEST@cleanharbors.com',
                Username = 'susnTEST@cleanharbors.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Primary_Business__c = 'Thermo Fluids'
            );
            insert u;

        }
        
    }
    
    @isTest
    static void testGetListOfOwnerships() {
        Account acc = [SELECT Id,RecordType.Name FROM Account LIMIT 1];
        
        OrganizationOwnersServiceHandler.recordType = acc.RecordType.Name;
        
        Organization_Owners__c owner = new Organization_Owners__c();
        owner.Organization__c = acc.Id;
        owner.Owner_Type__c = 'Executive Sponsor';
        owner.User__c = [SELECT Id FROM User WHERE Profile.Name = 'Super Recruiter' AND LastName = 'sunamilast' LIMIT 1].Id;
        insert owner;
        OwnershipService.getListOfOwnerships(new List<Organization_Owners__c> {owner});
    }
    
    @isTest
    static void testGetListOfOwnershipsForPartnershipOwner() {
        Account acc = [SELECT Id,RecordType.Name FROM Account LIMIT 1];
        
        OrganizationOwnersServiceHandler.recordType = acc.RecordType.Name;
        
        Organization_Owners__c owner = new Organization_Owners__c();
        owner.Organization__c = acc.Id;
        owner.Owner_Type__c = 'Partnership Owner';
        owner.User__c = [SELECT Id FROM User WHERE Profile.Name = 'Super Recruiter' AND LastName = 'sunamilast' LIMIT 1].Id;
        insert owner;
        Test.startTest();
        	List<OwnershipService.OwnershipWrapper> wrapperList = OwnershipService.getListOfOwnerships(new List<Organization_Owners__c> {owner});
        test.stopTest();
        System.assertEquals(true, !wrapperList.isEmpty(), 'wrapper list is returned');
    }
    
    @isTest
    static void testGetListOfOwnershipsForContributor() {
        Account acc = [SELECT Id,RecordType.Name FROM Account LIMIT 1];
        
        OrganizationOwnersServiceHandler.recordType = acc.RecordType.Name;
        
        Organization_Owners__c owner = new Organization_Owners__c();
        owner.Organization__c = acc.Id;
        owner.Owner_Type__c = 'Contributor';
        owner.User__c = [SELECT Id FROM User WHERE Profile.Name = 'Super Recruiter' AND LastName = 'sunamilast' LIMIT 1].Id;
        insert owner;
        Test.startTest();
        	List<OwnershipService.OwnershipWrapper> wrapperList = OwnershipService.getListOfOwnerships(new List<Organization_Owners__c> {owner});
        test.stopTest();
        System.assertEquals(true, !wrapperList.isEmpty(), 'wrapper list is returned');
    }
    
}