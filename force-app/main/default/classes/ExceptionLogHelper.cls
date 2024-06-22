/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 11-28-2022
 * @last modified by  : Suresh Beniwal 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   11-28-2022   Suresh Beniwal   Initial Version
**/
public without sharing class ExceptionLogHelper { 
    
    public static List<Exception_Log__c> logException(Boolean performDML, Database.SaveResult[] srList, String dmlObject, List<SObject> sobjList, String sourceClassTrigger, String sourceMethodEvent){
        List<Exception_Log__c> errLogList = new List<Exception_Log__c>();
        try{
			Integer i = 0;            
            for (Database.SaveResult sr : srList) {
                Id recId = sobjList.get(i).Id;
                i++;
                if (!sr.isSuccess()) {
                    Exception_Log__c el = new Exception_Log__c();
                    el.Apex_Class_Trigger__c = sourceClassTrigger;
                    el.Apex_Method_Event__c = sourceMethodEvent;
                    el.Record_Id__c = recId;
                    el.DML_Object__c = dmlObject;
                    String errMsg = '';
                    String errFields = '';
                    
                    for(Database.Error err : sr.getErrors()) {                                      
                        errMsg += '[Code:'+err.getStatusCode() + '#MSG:' + err.getMessage()+']';                    
                        errFields += err.getFields();                    
                    }
                    
                    if(errMsg.length() > 32500){
                        errMsg = errMsg.substring(0, 32500);
                    }
                    
                    if(errFields.length() > 4999){
                        errFields = errFields.substring(0, 4999);
                    }
                    
                    el.Error_Message__c = errMsg;
                    el.Error_Fields__c = errFields;
                    //el.Exception_Stack_Trace__c = errMsg;
                    errLogList.add(el);
                }
            }
            
            if(performDML){
                Database.insert(errLogList, false);
            }
        }catch(Exception ex){}
        
        return errLogList;
    }//end logException()

}