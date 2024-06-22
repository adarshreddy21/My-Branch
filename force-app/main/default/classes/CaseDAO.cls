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
public without sharing class CaseDAO {
    /**
    * @description
    * @author Vikram | 07-08-2023  
    * @params Set<string> WinIds, List<string> ProfileIds
	**/
public static List<Case> getCasesforProfileandWinIds(Set<string> WinIds, List<string> ProfileIds) {
    return [
            SELECT Id, casenumber,Profile_Number__c, 
         	ACCOUNT.WIN_ID__c FROM case 
         	where Account.WIN_ID__c in :WinIds
         	and Profile_Number__c in :ProfileIds
         	and RecordType.Name = 'CPG Request'
         	and status in ('Received','Working','Sales Complete','Action Required') order by createddate desc Limit 1
        ];
    }
    
     /**
    * @description 
    * @author Vikram | 07-08-2023 
    * @param List<Case> cases 
    **/
    public static void updateCases(List<Case> cases) {
        update cases;
    }
    /**
    * @description 
    * @author Vikram | 07-08-2023 
    * @param List<Case> cases 
    **/
    public static void insertCases(List<Case> cases) {
        insert cases;
    }
}