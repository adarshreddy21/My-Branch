@isTest
public class TerritoryTriggerHandler_Test {

    private static testMethod void method1(){
        
        Territory__c t = new Territory__c();
        t.name = 'TS-AM-Camarillo-CA-01';
        
        INSERT t;
        
        Test.startTest();
        
        t.Territory_OwnerID__c = UserInfo.getUserId();
        update t;
        
        Test.stopTest();
        
    }
}