/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-09-2022   Suresh Beniwal   Initial Version
**/
public without sharing class DepartmentsDAO {
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @param Set<Id> setOfId 
    * @return List<Organization_Department__c> 
    **/
    public static List<Organization_Department__c> getListOfDepartmentByOrganizationIds(Set<Id> setOfId) {
        return [
            SELECT Id, Name, Dept_ID__r.Dept_ID__c, Organization__r.Name, Dept_ID__r.MGR_LVL_1_DESCR__c,
                Dept_ID__r.MGR_LVL_2_DESCR__c, Dept_ID__r.MGR_LVL_3_DESCR__c, Dept_ID__r.MGR_LVL_4_DESCR__c,
                Dept_ID__r.MGR_LVL_5_DESCR__c, Dept_ID__r.MGR_LVL_6_DESCR__c, Dept_ID__r.MGR_LVL_7_DESCR__c,
                Location__c, Location__r.Name, Location__r.Location_Id__c, Organization__r.Organization_Id__c 
            FROM Organization_Department__c 
            WHERE Organization__c IN: setOfId AND Dept_ID__c != null AND Organization__c != null
                ORDER BY Location__r.Name ASC NULLS FIRST
        ];
    }

    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @param String optionValue 
    * @return List<Organization_Department__c> 
    **/
    public static List<Organization_Department__c> dynamicQueryGetListOfDepartmentByOrganizationIds(List<String> optionValue) {
        return Database.query('SELECT Id, Organization__c, Location__r.Location_Id__c, Organization__r.Organization_Id__c FROM Organization_Department__c WHERE Dept_ID__c != null AND Dept_ID__r.MGR_LVL_3_DESCR__c IN: optionValue');
    }


    /**
    * @description 
    * @author Suresh Beniwal | 07-21-2022 
    * @param Set<Id> setOfId 
    * @param List<String> optionValue 
    * @return List<Organization_Department__c> 
    **/
    public static List<Organization_Department__c> getDynamicListOfDepartmentByOrganizationIds(Set<Id> setOfId, List<String> optionValue) {
        String dynamicQuery = 'SELECT Id, Name, Dept_ID__r.Dept_ID__c, Organization__r.Name, Dept_ID__r.MGR_LVL_1_DESCR__c, ' +
        '    Dept_ID__r.MGR_LVL_2_DESCR__c, Dept_ID__r.MGR_LVL_3_DESCR__c, Dept_ID__r.MGR_LVL_4_DESCR__c, ' +
        '    Dept_ID__r.MGR_LVL_5_DESCR__c, Dept_ID__r.MGR_LVL_6_DESCR__c, Dept_ID__r.MGR_LVL_7_DESCR__c, ' +
        '    Location__c, Location__r.Name, Location__r.Location_Id__c, Organization__r.Organization_Id__c ' +
        ' FROM Organization_Department__c ' +
        ' WHERE Organization__c IN: setOfId AND Dept_ID__c != null AND Organization__c != null ' +
        '    ORDER BY LastModifiedDate DESC NULLS FIRST ';

        if (!optionValue.isEmpty()) {
            dynamicQuery = 'SELECT Id, Name, Dept_ID__r.Dept_ID__c, Organization__r.Name, Dept_ID__r.MGR_LVL_1_DESCR__c, ' +
            '    Dept_ID__r.MGR_LVL_2_DESCR__c, Dept_ID__r.MGR_LVL_3_DESCR__c, Dept_ID__r.MGR_LVL_4_DESCR__c, ' +
            '    Dept_ID__r.MGR_LVL_5_DESCR__c, Dept_ID__r.MGR_LVL_6_DESCR__c, Dept_ID__r.MGR_LVL_7_DESCR__c, ' +
            '    Location__c, Location__r.Name, Location__r.Location_Id__c, Organization__r.Organization_Id__c ' +
            ' FROM Organization_Department__c ' +
            ' WHERE Organization__c IN: setOfId AND Dept_ID__c != null AND Organization__c != null AND Dept_ID__c != null AND Dept_ID__r.MGR_LVL_3_DESCR__c IN: optionValue' +
            '    ORDER BY LastModifiedDate DESC NULLS FIRST ';
        }

        System.debug('setOfId : ' + setOfId);
        System.debug('optionValue : ' + optionValue);
        System.debug('dynamicQuery : ' + dynamicQuery);
        return Database.query(dynamicQuery);
    }
}