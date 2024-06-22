/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 09-12-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-05-2022   Suresh Beniwal   Initial Version
**/
@isTest(SeeAllData=false)
public class AccountServiceTest {
    @testSetup static void setupmethod() {
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HR_Talent_Pools').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Farheen';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Organization_Status__c ='Draft';
        //acc.Organization_ID__c = acc.id;
        acc.Organization_Category__c = 'Driver School';
        acc.ShippingStreet = '123';
        acc.ShippingCity = 'Jaipur';
        acc.ShippingState = 'Rajasthan';
		acc.Generator_Status__c='Small Quantity Generator';
        acc.ShippingCountry = 'US';
        acc.ShippingPostalCode = '302012';
        insert acc;

        Account acc1 = new Account();
        acc1.Name = 'Farheen1';
        acc1.RecordTypeId = RecordTypeIdAccount;
        acc1.Organization_Status__c ='Draft';
        //acc1.Organization_ID__c = acc.id;
        acc1.Organization_Category__c = 'Driver School';
        acc1.ShippingStreet = '123';
        acc1.ShippingCity = 'Jaipur';
        acc1.ShippingState = 'Rajasthan';
		acc1.Generator_Status__c='Small Quantity Generator';  
        acc1.ShippingCountry = 'US';
        acc1.ShippingPostalCode = '302012';
        insert acc1;
        acc.Organization_Status__c = 'Prospect';

        Test.startTest();
       
            try {
                update acc;
            } catch(Exception ex) {}
           
                
        Test.stopTest();
    }

    @IsTest static void TestOrganizationOwner(){
        List<Account> accList = [SELECT Id, Name, ParentId, Parent.Name, Organization_Id__c, Organization_Status__c, Organization_Category__c, Diversity_Organization_Detail__c, Size_of_Candidate_Pool__c, Number_of_Hires__c, Active_Inactive__c, Status__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, Organization_Category_Detail__c FROM Account WHERE name = 'Farheen'];
        
        Test.startTest();
        	accList.get(0).Organization_Status__c = 'Draft';
        	update accList;
            List<AccountService.AccountWrapper> listOfAccountWrapper = AccountService.getListOfAccounts(accList);
        Test.stopTest();

        System.assertEquals(false, listOfAccountWrapper.isEmpty(), 'Wrapper data should be return !!');
    } 
    
    @IsTest static void TestOrganizationOwnerUpdate(){
        List<Account> accList = [SELECT Id FROM Account WHERE name = 'Farheen1' LIMIT 1];
        accList[0].Name = 'Farheen';
        
        Test.startTest();
            try {
                update accList;
            } catch (Exception ex) {}
        Test.stopTest();
    } 
    
}