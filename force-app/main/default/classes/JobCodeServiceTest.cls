/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : Irfan Khan 
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   08-08-2022   Irfan Khan   Initial Version
**/
@isTest 

private class JobCodeServiceTest {
    private final static string TEST_JOB_CATEGORY_GROUP = 'Chemists';
@testSetup static void setupmethod() {
     Organization_Job_Code_Mapping__c OrgMap = new Organization_Job_Code_Mapping__c ();
    OrgMap.Job_Category_Group__c = TEST_JOB_CATEGORY_GROUP;
    
    insert OrgMap;
      
    Organization_Job_Code__c OrgJobCode = new Organization_Job_Code__c ();
    OrgJobCode.Job_Code_Mapping__c = OrgMap.Id ;
    
        
    Test.startTest();
           insert OrgJobCode;
        Test.stopTest();
    }
    @IsTest static void TestJobCategories(){
        List<Organization_Job_Code__c> OrgList = [SELECT ID,Name,Job_Category_Group__c,Sub_Group__c,Organization__r.Name,Location__r.Name FROM Organization_Job_Code__c WHERE Job_Category_Group__c = 'Chemists' ];
       
        Test.startTest();
            List<JobCodeService.JobCodeWrapper> listOfJobCodeWrapper = JobCodeService.getListOfJobCodes(OrgList);
        Test.stopTest();
        
        System.assertEquals(false, listOfJobCodeWrapper.isEmpty(), 'Wrapper data should be return !!');
}
}