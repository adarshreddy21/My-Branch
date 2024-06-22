/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-05-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-05-2022   Suresh Beniwal   Initial Version
**/
@isTest(SeeAllData=false)
public class AccountDAOTest {
    
    /**
    * @description 
    * @author Suresh Beniwal | 08-05-2022 
    **/
    @testSetup static void setupmethod() {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HR_Talent_Pools').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Farheen';
        acc.RecordTypeId = recordTypeIdAccount;
        acc.Organization_Status__c ='Draft';
        acc.ShippingStreet = '123';
        acc.ShippingCity = 'Jaipur';
        acc.ShippingState = 'Rajasthan';
        acc.ShippingCountry = 'US';
        acc.ShippingPostalCode = '302012';

        Test.startTest();
          insert acc;
        Test.stopTest();
    }

    /**
    * @description 
    * @author Suresh Beniwal | 08-05-2022 
    **/
    @IsTest static void testDynamicQueryGetListOfAccounts(){

        Test.startTest();
            List<Account> listOfAccount = AccountDAO.dynamicQueryGetListOfAccounts('Organization_Status__c != Null', new List<String>());
        Test.stopTest();

        System.assertEquals(false, listOfAccount.isEmpty(), 'Account data should be return !!');
    } 

    @IsTest static void testgetListOfAccountByIdSets(){
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Account> listOfAccount = AccountDAO.getListOfAccountByIdSets(new Set<Id> {accountRecord.Id}, new Set<Id> {accountRecord.Id});
        Test.stopTest();

        System.assertEquals(false, listOfAccount.isEmpty(), 'Account data should be return !!');
    } 
}