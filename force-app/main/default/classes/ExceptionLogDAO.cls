/**
 * @description       : 
 * @author            : Raghav
 * @group             : 
 * @last modified on  : 09-10-2022
 * @last modified by  : Raghav Kumar
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   09-10-2022   Raghav Kumar   Initial Version
**/
public with sharing class ExceptionLogDAO{
    
    /**
    * @description 
    * @author Raghav | 09-10-2022 
    * @param List<Exception_Log__c> exceptionLogs 
    **/
    public static void logException(List<Exception_Log__c> exceptionLogs) {
        for(Exception_Log__c log: exceptionLogs){
            if(log.Error_Message__c!=null && log.Error_Message__c.length() > 32500){
                log.Error_Message__c = log.Error_Message__c.substring(0, 32500);
            }
        }
        insert exceptionLogs;
    }
}