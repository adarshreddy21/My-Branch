/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-10-2022   Suresh Beniwal   Initial Version
**/
public without sharing class JobCodeService {
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-10-2022 
    * @param List<Organization_Job_Code__c> listOfJobCodes 
    * @return List<JobCodeWrapper> 
    **/
    public static List<JobCodeWrapper> getListOfJobCodes(List<Organization_Job_Code__c> listOfJobCodes) {
        List<JobCodeWrapper> listOfJobCodeWrapper = new List<JobCodeWrapper>();

        for (Organization_Job_Code__c jobCodeRecord: listOfJobCodes) { 
            JobCodeWrapper jobCodeWrapperRecord = new JobCodeWrapper();
            jobCodeWrapperRecord.jobCategoryCode = jobCodeRecord.Name;
            jobCodeWrapperRecord.locationCode = jobCodeRecord.Location__r.Location_Id__c;
            jobCodeWrapperRecord.organizationCode = jobCodeRecord.Organization__r.Organization_Id__c;
            jobCodeWrapperRecord.jobCategories = jobCodeRecord.Job_Category_Group__c;
            jobCodeWrapperRecord.jobCodeTitles = jobCodeRecord.Sub_Group__c;
            jobCodeWrapperRecord.organizationName = jobCodeRecord.Organization__r.Name;
            jobCodeWrapperRecord.location = jobCodeRecord.Location__r.Name;

            listOfJobCodeWrapper.add(jobCodeWrapperRecord);
        }

        return listOfJobCodeWrapper;
    }

    public class JobCodeWrapper {
        @AuraEnabled public String jobCategoryCode;
        @AuraEnabled public String locationCode;
        @AuraEnabled public String organizationCode;
        @AuraEnabled public String jobCategories;
        @AuraEnabled public String jobCodeTitles;
        @AuraEnabled public String organizationName;
        @AuraEnabled public String location;
    }
}