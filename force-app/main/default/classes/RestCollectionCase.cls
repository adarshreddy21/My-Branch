@RestResource(urlMapping = '/CollectionCase/*')
global class RestCollectionCase {
        
    @HttpGet
    global static List <Case> getCase()
    { 
          
        List<Case> c = [select id, createdDate, status, subject, WIN_Id__c, Business_Unit__c,Conver_DateTime__c, Follow_up_action__c,Follow_up_date__c,Keyword_1__c, Keyword_2__c, Keyword_3__c, OPRID__c, SETID__c,EBiller__c,Customer_Balance__c, Description  from Case
                        //where createddate > startDate and createddate < enddate
                        limit 1];  
        return c; 
    }   
         
    @HttpPost
    global static void createnewcase (string CUST_ID, string BUSINESS_UNIT, String FOLLOW_UP_ACTION, String CONVER_DT, String CASE_TYPE, String FOLLOW_UP_DT, String PROMISE_DT,
                                     String PROMISE_AMT,String KEYWORD1, string COMMENTS, String KEYWORD2,  String KEYWORD3, String OPRID, String SETID,String EBILLER ,String CUST_BALANCE,String REFERENCES, String CONVER_DTTM_INIT, String BRANCH, String OVERDUE_BALANCE, String GENERATOR_CODE){
									 
         String reqBody = '\'{\'"CUST_ID": "{0}", "BUSINESS_UNIT": "{1}", "FOLLOW_UP_ACTION": "{2}", "CONVER_DT": "{3}", "CASE_TYPE": "{4}", "FOLLOW_UP_DT": "{5}", "PROMISE_DT": "{6}", "PROMISE_AMT": "{7}", "KEYWORD1": "{8}", "COMMENTS": "{9}", "KEYWORD2": "{10}", "KEYWORD3": "{11}", "OPRID": "{12}", "SETID": "{13}", "EBILLER": "{14}", "CUST_BALANCE": "{15}", "REFERENCES": "{16}", "CONVER_DTTM_INIT": "{17}", "BRANCH": "{18}", "OVERDUE_BALANCE": "{19}", "GENERATOR_CODE": "{20}"\'}\'';
         list<String> lstst=new     List<String>{CUST_ID,BUSINESS_UNIT,FOLLOW_UP_ACTION,CONVER_DT,CASE_TYPE,FOLLOW_UP_DT,PROMISE_DT,PROMISE_AMT,KEYWORD1,COMMENTS,KEYWORD2,KEYWORD3,OPRID,SETID,EBILLER,CUST_BALANCE,REFERENCES,CONVER_DTTM_INIT,BRANCH,OVERDUE_BALANCE,GENERATOR_CODE};
         String message = String.format(reqBody, lstst);
		 List<String> PSPCHES= new List<String>{'Clean Harbors ENV', 'CHES Oil and Gas', 'CHES Industrial'};
         List<String> PSPSKE= new List<String>{'SK ENV', 'SK BPS', 'SK KPP'};
         List<Account> accList = new List<Account>();
		 String accSuppPerson;	
         String ownerid;
                                         
         if(CUST_ID != NULL)
         {
           	accList = [
                SELECT Id, Key_Account_Primary_Business__c, Primary_Service_Provider__c,Buying_Decision__c, Primary_Service_Provider_New__c,Key_Buying_Decision__c,Key_Account_Support_Person__c, OwnerId, Owner.IsActive, Owner.ManagerId, Owner.Manager.IsActive 
                FROM Account 
                WHERE WIN_ID__c =:CUST_ID 
                LIMIT 1
            ]; 
             
             if(!accList.isEmpty()){
                     if(accList[0].Key_Buying_Decision__c == 'Central Buying' && accList[0].Key_Account_Support_Person__c != NULL){
                         accSuppPerson = accList[0].Key_Account_Support_Person__c;
                     }else 
                     if(PSPCHES.contains(accList[0].Primary_Service_Provider_New__c)){ 
                         if(accList[0].Owner.IsActive){
                             ownerid = accList[0].OwnerId;    
                      }else
                         {
                             ownerid = accList[0].Owner.ManagerId;    
                         }
                     }else if(PSPSKE.contains(accList[0].Primary_Service_Provider_New__c)){
                           List<Account> accountRecLst = [SELECT Id, OwnerId, Owner.ManagerId, Owner.IsActive FROM Account WHERE WIN_ID__c = :GENERATOR_CODE];
                             if(!accountRecLst.isEmpty()){
                                if(accountRecLst[0].Owner.IsActive){
                                 ownerid = accountRecLst[0].OwnerId;    
                             }else{
                                 ownerid = accountRecLst[0].Owner.ManagerId;    
                             }
                         }else{
                             RestContext.response.responseBody = Blob.valueOf('{"case_id":"","Error":"No account record for the generator code.","Case_No":""}');
							 RestCollectionCase.createExceptionLog('No account record for the generator code.'+ '|' + reqBody, '','');
                             return;
                      }
                 }
             }
         }
         
         User uObj = new User();
         for(User obj : [Select Id, Name from User where FederationIdentifier =: OPRID Limit 1]){
             uObj = obj;
         }       
         List<user> us = new list<user>();     
         if(accSuppPerson != null){
             us = [Select Id, Name, isActive, ManagerId, Manager.isActive, Manager.Name FROM USER WHERE Name =: accSuppPerson LIMIT 1]; //Update the query to pull Manager Related information - Sireesha
         }
         if(!us.isEmpty()){
             //Assign the user as owner only if the User is active - Sireesha
             if(us[0].isActive && !us[0].Name.Contains('Inactive')){
                 ownerId = us[0].Id;
             }//Otherwise assign to the Manager if he is active - Sireesha
             else if(us[0].ManagerId != NULL && us[0].Manager.isActive && !us[0].Manager.Name.Contains('Inactive')){
                 ownerId = us[0].ManagerId;
             }
         }
                                          
          
          if(EBILLER!='' && EBILLER!=null ){
             us= [SELECT id,EmployeeNumber, isActive, ManagerId, Manager.isActive FROM USER WHERE EmployeeNumber =:EBILLER]; //Update the query to pull Manager Related information - Sireesha
             if(!us.isEmpty() && us.size()>0)
             {
                 //Assign the user as owner only if the User is active
                 if(us[0].isActive){
                     ownerId = us[0].Id;
                 }//Otherwise assign to the Manager if he is active
                 else if(us[0].ManagerId != NULL && us[0].Manager.isActive){
                     ownerId = us[0].ManagerId;
                 }
             }
         } 
         if(ownerId == NULL){
             ownerid=System.label.Ebill_Owner;
         }
                          
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();
                                         
        try{
           case newcase = new case ();
            newcase.RecordTypeId = devRecordTypeId;
            newcase.Subject = 'Collection Case';
            newcase.status = 'New';
            newcase.WIN_Id__c = CUST_ID;           
            newcase.Business_Unit__c = BUSINESS_UNIT;
            newcase.Follow_up_action__c = FOLLOW_UP_ACTION;
            newcase.Keyword_1__c = Keyword1;
            newcase.Keyword_2__c = Keyword2;
            newcase.Keyword_3__c = Keyword3;
            newcase.SETID__c = SETID;
            newcase.EBiller__c = EBILLER;
            newcase.Customer_Balance__c = CUST_BALANCE;
            newcase.Type=CASE_TYPE;
            newcase.PROMISE_AMT__c=decimal.valueOf(Promise_Amt);
            newcase.Description = COMMENTS;
            newcase.Branch_Code__c = BRANCH;
            newcase.Overdue_Balance__c = decimal.valueOf(OVERDUE_BALANCE);
            //To include replace Federation Id with User name
            if(uObj.Name != NULL){
                newcase.OPRID__c = uObj.Name;
            }
            else{
                newcase.OPRID__c = OPRID;
            }
            
            newcase.REFERENCES__c=References;
            newcase.CONVER_DT__c = Date.valueOf(CONVER_DT);
            newcase.Follow_up_date__c = Date.valueOf(FOLLOW_UP_DT);
            newcase.Conver_DateTime__c=Datetime.valueOf(CONVER_DTTM_INIT);
            newcase.Promise_DT__c=Date.valueOf(PROMISE_DT); 
            newcase.Generator_Code__c = GENERATOR_CODE;
			CaseCRUDHandler.skipAutomatedOwnerAssignment=true;
            newcase.OwnerId=ownerid;
            
            insert newcase;
            
           string CaseNumber;
           List<case> acc= [select Id,CaseNumber from case where Id=: newcase.Id];
            for(case a: acc) {  CaseNumber = a.CaseNumber;}      
            RestContext.response.responseBody = Blob.valueOf('{"case_id" :"' +acc[0].Id+'","Error":"","Case_No":"'+CaseNumber+'"}');
        } catch (Exception e){
            RestContext.response.responseBody = Blob.valueOf('{"case_id":"","Error":"'+ e.getMessage()+'","Case_No":""}');
			RestCollectionCase.createExceptionLog(e.getMessage()+ '|' +reqBody,e.getStackTraceString(), '');
        } 
    }   
	
    private static void createExceptionLog(string errorMessage, string stackTrace, string recordId){
        Exception_Log__c log = new Exception_Log__c(
            Error_Message__c= errorMessage, 
            Exception_Stack_Trace__c= stackTrace, 
            Record_Id__c= recordId, 
            Apex_Method_Event__c= 'createnewcase');
        ExceptionLogDAO.logException(new List<Exception_Log__c>{log});
    }	
}