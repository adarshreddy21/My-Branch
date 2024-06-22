/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 10-04-2022
 * @last modified by  : Suresh Beniwal 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   10-04-2022   Suresh Beniwal   Initial Version
**/
@isTest
Private class TestBudgetdashboardController {
 
    private static testMethod void testbudgetcontrollermethod() {
 	test.startTest();    
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'last',
            Email = 'TEST@cleanharbors.com',
            Username = 'TEST@cleanharbors.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            is_the_Sales_Manager__c = true,
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Primary_Business__c = 'Healthcare Services'
        );
        insert u;
        System.runAs(u){
        BudgetdashboardController cls = new BudgetdashboardController();
        cls.openDashBoard();
        }
        test.stopTest();       
    }

}