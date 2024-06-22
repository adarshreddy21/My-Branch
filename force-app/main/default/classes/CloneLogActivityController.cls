public class CloneLogActivityController {
	@AuraEnabled
    public static sObject cloneLogActivity(String recordId){
        Task taskRec = [
            SELECT Id
            FROM Task
            WHERE Id = :recordId
            LIMIT 1
            ALL ROWS
        ];
        sObject originalSObject = (sObject)taskRec; 
        List<sObject> originalSObjects = new List<sObject>{originalSObject};
        List<sObject> clonedSObjects;
        try{
        	clonedSObjects = cloneObjects(originalSobjects, originalSobject.getsObjectType());        
        }catch(Exception exceptionObj) {
            throw new AuraHandledException(exceptionObj.getMessage());
        }   
        
        return clonedSObjects[0];
    }
    
    public static List<sObject> cloneObjects(List<sObject> sObjects, Schema.SObjectType objectType){    
        List<Id> sObjectIds = new List<Id>{};
        List<String> sObjectFields = new List<String>{};
        List<sObject> clonedSObjects = new List<sObject>{};  
        Set<String> excludeFields = new Set<String>{'call_center_lead__c', 'call_center_opportunity__c', 'customer_service_case__c'};
        if(objectType != null){
            for(String key : objectType.getDescribe().fields.getMap().keySet()){
                if(!excludeFields.contains(key))
            		sObjectFields.add(key); 
            }
        }    
        if (sObjects != null && 
            !sObjects.isEmpty() && 
            !sObjectFields.isEmpty()){    
          for (sObject objectInstance: sObjects){
            sObjectIds.add(objectInstance.Id);
          }
          String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0);     
          for (Integer i=1 ; i < sObjectFields.size() ; i++){
            allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
          }    
          allSObjectFieldsQuery+=' FROM '+objectType.getDescribe().getName()+ 
                                   ' WHERE ID IN (\''+sObjectIds.get(0)+ 
                                   '\'';
          for (Integer i=1 ; i < sObjectIds.size() ; i++){
            allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
          }    
          allSObjectFieldsQuery += ')';    
                
          System.debug('allSObjectFieldsQuery ' + allSObjectFieldsQuery);
          try{      
            for (SObject sObjectFromDatabase:
                 Database.query(allSObjectFieldsQuery)){
              clonedSObjects.add(sObjectFromDatabase.clone(false,true,false,false));  
            }    
          } catch (exception e){
            System.debug('Exception '+e.getMessage());
          }
        }      

        return clonedSObjects;
  	}
}