/**
* @description       : 
* @author            : Gantla Adarsh Reddy
* @group             : 
* @last modified on  : 
* @last modified by  :  
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   02-05-2024   Gantla Adarsh Reddy  Initial Version 
**/
@isTest
public class AutomatePostRefreshActivitiesTests {
@isTest
    static void testMySandboxPrep() {
        
        Test.startTest();
        
        //Execute test script with RunAsAutoProcUser set to true
        Test.testSandboxPostCopyScript(
            new AutomatePostRefreshActivities(), UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(), UserInfo.getOrganizationName(), true);
        
        Test.stopTest();
        
        // Query to validate that a batch job has been scheduled
        AsyncApexJob[] jobs = [
            SELECT Id, Status, ApexClass.Name 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'CreateWinIdsAccountsBatch'
        ];
        PushTopic[] pushTopics = [
            SELECT Id, Name, Query, ApiVersion, NotifyForOperationCreate, NotifyForOperationUpdate,
            NotifyForFields FROM PushTopic WHERE Name = 'ContactUpdates1'];

        System.assertEquals(1, pushTopics.size(), 'Expected one PushTopic to exist.');
        System.assertEquals(1, jobs.size(), 'Expected one batch job to be scheduled.');
        System.assertEquals('CreateWinIdsAccountsBatch', jobs[0].ApexClass.Name, 'Unexpected batch class name.');
    }
}