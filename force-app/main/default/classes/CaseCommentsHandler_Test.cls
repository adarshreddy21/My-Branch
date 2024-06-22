@isTest
public class CaseCommentsHandler_Test {

    private static testmethod void sendCaseDetailstoWINTest(){
        
        Case caseObj = new Case();
        caseObj.Status = CHConstants.CASE_STATUS_NEW;
        caseObj.WIN_Id__c = 'TEST23';
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non Standard Billing WIN').getRecordTypeId();
        insert caseObj;
        
        TestMockHttpResponseGenerator fakeResponse = new TestMockHttpResponseGenerator(200,'Complete',JSON.serialize('Success'));
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        CaseComment ccObj = new CaseComment();
        ccObj.ParentId = caseObj.Id;
        ccObj.CommentBody = 'This is a comments test';
        insert ccObj;
        Test.stopTest();
    }
}