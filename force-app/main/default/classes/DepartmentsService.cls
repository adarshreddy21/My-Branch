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
public without sharing class DepartmentsService {
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-10-2022 
    * @param List<Organization_Department__c> listOfDepartments 
    * @return List<DepartmentsWrapper> 
    **/
    public static List<DepartmentsWrapper> getListOfDepartments(List<Organization_Department__c> listOfDepartments) {
        List<DepartmentsWrapper> listOfDepartmentsWrapper = new List<DepartmentsWrapper>();

        for (Organization_Department__c departmentRecord: listOfDepartments) {
            DepartmentsWrapper departmentsWrapperRecord = new DepartmentsWrapper();
            departmentsWrapperRecord.departmentCode = departmentRecord.Name;
            departmentsWrapperRecord.locationCode = departmentRecord.Location__r.Location_Id__c; 
            departmentsWrapperRecord.organizationCode = departmentRecord.Organization__r.Organization_Id__c;
            departmentsWrapperRecord.deptId = departmentRecord.Dept_ID__r.Dept_ID__c;
            departmentsWrapperRecord.organizationName = departmentRecord.Organization__r.Name;
            departmentsWrapperRecord.mgr_level_1 = departmentRecord.Dept_ID__r.MGR_LVL_1_DESCR__c;
            departmentsWrapperRecord.mgr_level_2 = departmentRecord.Dept_ID__r.MGR_LVL_2_DESCR__c;
            departmentsWrapperRecord.mgr_level_3 = departmentRecord.Dept_ID__r.MGR_LVL_3_DESCR__c;
            departmentsWrapperRecord.mgr_level_4 = departmentRecord.Dept_ID__r.MGR_LVL_4_DESCR__c;
            departmentsWrapperRecord.mgr_level_5 = departmentRecord.Dept_ID__r.MGR_LVL_5_DESCR__c;
            departmentsWrapperRecord.mgr_level_6 = departmentRecord.Dept_ID__r.MGR_LVL_6_DESCR__c;
            departmentsWrapperRecord.mgr_level_7 = departmentRecord.Dept_ID__r.MGR_LVL_7_DESCR__c;
            departmentsWrapperRecord.location = departmentRecord.Location__r.Name;

            listOfDepartmentsWrapper.add(departmentsWrapperRecord);
        }

        return listOfDepartmentsWrapper;
    }

    public class DepartmentsWrapper {
        @AuraEnabled public String departmentCode;
        @AuraEnabled public String locationCode;
        @AuraEnabled public String organizationCode;
        @AuraEnabled public String deptId;
        @AuraEnabled public String organizationName;
        @AuraEnabled public String mgr_level_1;
        @AuraEnabled public String mgr_level_2;
        @AuraEnabled public String mgr_level_3;
        @AuraEnabled public String mgr_level_4;
        @AuraEnabled public String mgr_level_5;
        @AuraEnabled public String mgr_level_6;
        @AuraEnabled public String mgr_level_7;
        @AuraEnabled public String location;
    }
}