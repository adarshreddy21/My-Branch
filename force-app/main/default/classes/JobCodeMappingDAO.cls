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
public without sharing class JobCodeMappingDAO {
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-09-2022 
    * @return List<Organization_Job_Code_Mapping__c> 
    **/
    public static List<Organization_Job_Code_Mapping__c> getListOfJobCodeMappings() {
        return [ 
            SELECT Id, Name, Job_Category_Group__c, Job_Title__c, Job_Code__c 
            FROM Organization_Job_Code_Mapping__c
            WHERE Job_Category_Group__c != NULL
            
        ];
    }
}