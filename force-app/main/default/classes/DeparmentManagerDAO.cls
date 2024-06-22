/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 06-09-2022
 * @last modified by  : Suresh Beniwal 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-09-2022   Suresh Beniwal   Initial Version
**/
public without sharing class DeparmentManagerDAO {
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @return List<Organization_Department_Mgr__c> 
    **/
    public static List<Organization_Department_Mgr__c> getListOfDepartmentManagers() {
        return  [
            SELECT Id, Name, Dept_ID__c, MGR_LVL_3_DESCR__c, MGR_LVL_1_DESCR__c, MGR_LVL_2_DESCR__c, 
                MGR_LVL_4_DESCR__c, MGR_LVL_5_DESCR__c, MGR_LVL_6_DESCR__c, MGR_LVL_7_DESCR__c 
            FROM Organization_Department_Mgr__c
            WHERE MGR_LVL_3_DESCR__c != NULL
        ];
    }
}