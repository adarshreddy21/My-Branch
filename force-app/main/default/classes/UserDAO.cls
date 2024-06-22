/**
 * @description       : 
 * @author            : Vikram Simha
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : Vikram Simha
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   03-08-2023   Vikram Simha   Initial Version
**/
public without sharing class UserDAO {
    
    /**
    * @description
    * @author Vikram Simha | 04-08-2023 
    * @param Set<String> EmployeeIds 
    * @return List<User> 
    **/
    public static List<User> getUsersforEmpIds(Set<String> employeeIDs) {
        return [
            SELECT Id, Name,EmployeeNumber,ManagerId,isActive FROM user 
            where EmployeeNumber in :employeeIDs
        ];
    }
	
	 /**
    * @description
    * @author Bezawada Balaji| 29-08-2023 
    * @param getProfileDetailsById 
    * @return Set<profileIds> 
    **/
	 public static List<Profile> getProfileDetailsById(Set<Id> profileIds){
        return [
            SELECT Id, Name 
            FROM Profile 
            WHERE Id IN :profileIds
        ];
    }

    public static List<User> getUserDetailsByUserId(Set<Id> userIds){
        return [
            SELECT id,Name,Email,Phone,Profile.Name 
            FROM User
            WHERE Id IN :userIds
        ];
    }

    public static List<User> getUserTerritory(Set<Id> userIds){
        return [
            SELECT Id, Sales_Person_Type__c, Profile.Name, Territory__c
            FROM User
            WHERE Id IN :userIds
        ];
    }

}