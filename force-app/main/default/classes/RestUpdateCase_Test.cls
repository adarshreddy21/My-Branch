@isTest
public class RestUpdateCase_Test {

    private static testmethod void sendCaseDetailsTest(){
        
        Case caseObj = new Case();
        caseObj.Status = CHConstants.CASE_STATUS_NEW;
        caseObj.WIN_Id__c = 'TEST23';
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non Standard Billing WIN').getRecordTypeId();
        insert caseObj;
        
        TestMockHttpResponseGenerator fakeResponse = new TestMockHttpResponseGenerator(200,'Complete',JSON.serialize('Success'));
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        caseObj.Status = 'In Progress';
        update caseObj;
        
        Test.stopTest();
    }
}