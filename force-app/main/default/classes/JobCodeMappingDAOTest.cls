@isTest
private class JobCodeMappingDAOTest {
    private static final string TEST_Job_Category_Group ='Chemists';
    private static final string TEST_Sub_Category ='lab Chemists';
    
    @testSetup  private static void setupmethod(){
        Organization_Job_Code_Mapping__c OrgJobCode = new Organization_Job_Code_Mapping__c
        (Job_Category_Group__c = TEST_Job_Category_Group, Sub_Category__c = TEST_Sub_Category);
        insert OrgJobCode;
    }
    @IsTest static void TestJobCodeMappingForJobCategorySet(){
        Organization_Job_Code_Mapping__c jobCodeMapping = [SELECT ID, Job_Category_Group__c FROM Organization_Job_Code_Mapping__c
                                                           WHERE Job_Category_Group__c =: TEST_Job_Category_Group];
        JobCodeMappingDAO.getListOfJobCodeMappings();
        Organization_Job_Code_Mapping__c jobCode = [SELECT ID,Job_Category_Group__c FROM Organization_Job_Code_Mapping__c
                                                    WHERE Job_Category_Group__c =:jobCodeMapping.Job_Category_Group__c ];
        System.AssertEquals(jobCodeMapping.Job_Category_Group__c,jobCode.Job_Category_Group__c,'Organisation JobCode mapping returned successfully');   
    }
    
    @IsTest static void TestJobCodeMappingForJobCategoryNotSet(){                                                           
        JobCodeMappingDAO.getListOfJobCodeMappings();
        Organization_Job_Code_Mapping__c jobCode = [SELECT ID,Job_Category_Group__c FROM Organization_Job_Code_Mapping__c LIMIT 1];
                                                   
        System.AssertNotEquals(jobCode.Job_Category_Group__c,null,'Job Category Group cannot be null');   
    }
}