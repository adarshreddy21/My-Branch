/**
 * @description       : 
 * @author            : Balaji Bezawada
 * @group             : 
 * @last modified on  : 03-06-2023
 * @last modified by  : Balaji Bezawada
**/
@RestResource(urlMapping = '/CreateCase/*') 
global class RestCreateCase {
    @HttpPost
global static void createnewcase(){   
 List<String> PSPCHES= new List<String>{'Clean Harbors ENV', 'CHES Oil and Gas', 'CHES Industrial'};
 List<String> PSPSKE= new List<String>{'SK ENV', 'SK BPS', 'SK KPP'};
 List<String> CASETYPES= new List<String>{'NOPO', 'WRONGPO', 'PO-UNDRFND'};
        RestRequest request = RestContext.request;
        String reqBody = request.requestbody != NULL ? request.requestbody.tostring() : '';
        RquestWrapper reqWrapper = (RquestWrapper)JSON.deserialize(request.requestbody.tostring(), RquestWrapper.class);
        
        try{
		    String servicingbranchQueue;
			String servicingbranchQueueMapname;
            String branchQueueName;
			Group poCaseQueue = new Group();    
            String accSuppPerson;
            List<Group> branchQueue = new List<Group>();
            case newcase = new case ();
            List<Account> branchAccount = new List<Account>();
            List<Account> invoiceAccount = new List<Account>();
            
            newcase.status = CHConstants.CASE_STATUS_NEW;
            newcase.WIN_Id__c = reqWrapper.CUST_ID;
            newcase.Generator_Code__c = reqWrapper.GENERATOR_CODE;
            newcase.DESCRIPTION = reqWrapper.DESCRIPTION;
            newCase.Conver_DateTime__c = System.now(); //This has been added to include the Case Creation time - Sireesha
            
            //Changes to include the Added by Name based on the OPR ID
            if(reqWrapper.USER_ID != NULL){
                for(User usrObj : [Select Id, Name from User where FederationIdentifier =: reqWrapper.USER_ID LIMIT 1]){
                    newCase.OPRID__c = usrObj.Name;
                } 
            }
            
            List<Account> accs = new List<Account>();
            accs = [Select Id, Name, OwnerId, Owner.ManagerId, Owner.Name, Owner.Manager.Name,Primary_Service_Provider__c,Primary_Service_Provider_New__c, Key_Buying_Decision__c,Key_Account_Support_Person__c,Owner.IsActive, Owner.Manager.IsActive from Account where WIN_ID__c =:reqWrapper.CUST_ID LIMIT 1];
             if(!accs.isEmpty()){
                    newCase.AccountId = accs[0].Id;
                    
                } 
            
            
            if(reqWrapper.SOURCE_APP == CHConstants.INTEGRATION_SOURCE_APP_NSB || reqWrapper.SOURCE_APP == CHConstants.INTEGRATION_SOURCE_APP_COWB){
                      
                newcase.Invoice_Number__c = reqWrapper.INVOICE_NUM;
                newcase.Invoice_Date__c = reqWrapper.INVOICE_DATE; 
                newcase.Invoice_Value__c = Decimal.ValueOf(reqWrapper.INVOICE_VAL);
                newcase.Sales_Order_Number__c = reqWrapper.SALESORDER_NUM;            
                newcase.Type= reqWrapper.CASE_TYPE;
				newcase.Order_Type__c=reqWrapper.ORDER_TYPE;
                newcase.PO_Timing__c=reqWrapper.PO_TIMING;
                newcase.Servicing_Branch__c=reqWrapper.SERVICING_BRANCH;
                newcase.Subject=reqWrapper.Subject;
                
                if(String.isNotBlank(reqWrapper.BRANCH_CODE)){
                    branchAccount = [Select Id, Name from Account where RecordType.Name =:CHConstants.ACCOUNT_RECORD_TYPE_NAME_BRANCH AND Branch_Code__c =:reqWrapper.BRANCH_CODE LIMIT 1];
                }
                
                if(!branchAccount.isEmpty()){
                    newcase.Branch_Account_NSB__c = branchAccount[0].Id;
                }
                 if(String.isNotBlank(reqWrapper.BRANCH_CODE) || String.isNotBlank(reqWrapper.SERVICING_BRANCH)){
                    if(Branch_Queue_Map__c.getValues(reqWrapper.BRANCH_CODE) != NULL || Branch_Queue_Map__c.getValues(reqWrapper.SERVICING_BRANCH) != NULL){
                        Branch_Queue_Map__c branchQueueMap = Branch_Queue_Map__c.getValues(reqWrapper.BRANCH_CODE);
                        Branch_Queue_Map__c servicingbranchQueueMap = Branch_Queue_Map__c.getValues(reqWrapper.SERVICING_BRANCH);
                        if(branchQueueMap !=null){
                            branchQueueName = branchQueueMap.Branch_Queue__c;
                        } 
                        
                        if(servicingbranchQueueMap != NULL){
                            servicingbranchQueueMapname= servicingbranchQueueMap.Branch_Queue__c;
                        }
                    }
                }
                
                 if(String.isNotBlank(branchQueueName) || String.isNotBlank(servicingbranchQueueMapname)){
                    for(Group groupRec :  [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND (Name = :branchQueueName OR Name = :servicingbranchQueueMapname)]){
                        if(branchQueueName == groupRec.Name){
                            branchQueue = new List<Group>{groupRec};
                        }
                        
                        if(servicingbranchQueueMapname == groupRec.Name){
                            servicingbranchQueue = groupRec.Id;
                        }
                    }
                }
                
                for(Group grpObj : [Select Id, Name from Group where type = 'Queue' AND (Name =: CHConstants.QUEUE_NAME_PO_CASE_QUEUE)]){
                    if(grpObj.Name == CHConstants.QUEUE_NAME_PO_CASE_QUEUE){
                        poCaseQueue = grpObj;
                    }
                }
               if(reqWrapper.PO_TIMING == CHConstants.PO_TIMING)
                {
                    if(reqWrapper.SOURCE_APP == CHConstants.INTEGRATION_SOURCE_APP_NSB){
                     newcase.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get(CHConstants.CASE_RECORD_TYPE_NAME_NSB_WIN).getRecordTypeId();
                    }else
                    if(reqWrapper.SOURCE_APP == CHConstants.INTEGRATION_SOURCE_APP_COWB){
                     newcase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CHConstants.CASE_RECORD_TYPE_NAME_COWB).getRecordTypeId();
                    }
                    if(String.isNotBlank(reqWrapper.SERVICING_BRANCH) && String.isNotBlank(servicingbranchQueue)){
                        if(PSPSKE.contains(accs[0].Primary_Service_Provider_New__c)
                          && !accs[0].Primary_Service_Provider_New__c.equals('SK KPP')) { 
                            newCase.OwnerId = servicingbranchQueue;
                        }
                        else 
                            newCase.OwnerId=poCaseQueue.id;
                    } else 
                        newCase.OwnerId=poCaseQueue.id; 
                }   
                else
                if(reqWrapper.SOURCE_APP == CHConstants.INTEGRATION_SOURCE_APP_NSB){
                    newcase.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get(CHConstants.CASE_RECORD_TYPE_NAME_NSB_WIN).getRecordTypeId();
                    if(reqWrapper.CASE_TYPE == CHConstants.CASE_TYPE_SERVICE || CASETYPES.contains(reqWrapper.CASE_TYPE)){
                        if(accs[0].Key_Buying_Decision__c == 'Central Buying'  && accs[0].Key_Account_Support_Person__c != NULL){
                            accSuppPerson = accs[0].Key_Account_Support_Person__c;
                        }else  if(PSPCHES.contains(accs[0].Primary_Service_Provider_New__c)){
                            if(accs[0].Owner.IsActive){
                                newCase.OwnerId = accs[0].OwnerId;    
                            }else{
							    newCase.OwnerId = accs[0].Owner.ManagerId;    
                            }
                        }else if(PSPSKE.contains(accs[0].Primary_Service_Provider_New__c)){
                            List<Account> accountRecLst = [SELECT Id, OwnerId, Owner.ManagerId, Owner.IsActive FROM Account WHERE WIN_ID__c = :reqWrapper.GENERATOR_CODE];
                            if(!accountRecLst.isEmpty()){
                                if(accountRecLst[0].Owner.IsActive){
                                    newCase.OwnerId = accountRecLst[0].OwnerId;    
                                }else{ newCase.OwnerId = accountRecLst[0].Owner.ManagerId;    
                                }
                            }else{RestContext.response.responseBody = Blob.valueOf('{"case_id":"","Error":"No account record for the generator code.","Case_No":""}');
							     RestCreateCase.createExceptionLog('No account record for the generator code.'+ '|' + reqBody, '','');
                                return;
                            }
                        }
                        
                         if(accSuppPerson != null){
                            User us = [Select Id, Name, isActive, ManagerId, Manager.isActive, Manager.Name FROM USER WHERE Name =: accSuppPerson LIMIT 1]; //Update the query to pull Manager Related information - Sireesha
                        	
                            //Assign the user as owner only if the User is active - Sireesha
                            if(us.isActive && !us.Name.Contains('Inactive')){
                                newCase.OwnerId = us.Id;
                            }//Otherwise assign to the Manager if he is active - Sireesha
                            else if(us.ManagerId != NULL && us.Manager.isActive && !us.Manager.Name.Contains('Inactive')){
                                newCase.OwnerId = us.ManagerId;
                            }
                        }
                    }  
                } 
                else if(reqWrapper.SOURCE_APP == CHConstants.INTEGRATION_SOURCE_APP_COWB){
                    newcase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CHConstants.CASE_RECORD_TYPE_NAME_COWB).getRecordTypeId();
                     if( reqWrapper.CASE_TYPE == CHConstants.CASE_TYPE_SERVICE){
					if(!branchQueue.isEmpty()){ 
                            newCase.OwnerId = branchQueue[0].Id;
                        } else
                        if(accs[0].Owner.IsActive){
                                newCase.OwnerId = accs[0].OwnerId;    
                            }else{
							    newCase.OwnerId = accs[0].Owner.ManagerId;    
                            }
					}
                    if(CASETYPES.contains(reqWrapper.CASE_TYPE)){
                        if(accs[0].Key_Buying_Decision__c == 'Central Buying'  && accs[0].Key_Account_Support_Person__c != NULL){
                            accSuppPerson = accs[0].Key_Account_Support_Person__c; 
                        }else if(PSPCHES.contains(accs[0].Primary_Service_Provider_New__c)){ 
                            if(accs[0].Owner.IsActive){
                                newCase.OwnerId = accs[0].OwnerId;    
                            }else{
                                newCase.OwnerId = accs[0].Owner.ManagerId;    
                            }
                        }else if(PSPSKE.contains(accs[0].Primary_Service_Provider_New__c)){
                            List<Account> accountRecLst = [SELECT Id, OwnerId, Owner.ManagerId, Owner.IsActive FROM Account WHERE WIN_ID__c = :reqWrapper.GENERATOR_CODE];
                            if(!accountRecLst.isEmpty()){
                                if(accountRecLst[0].Owner.IsActive){ 
                                    newCase.OwnerId = accountRecLst[0].OwnerId;    
                                }else{
                                    newCase.OwnerId = accountRecLst[0].Owner.ManagerId;    
                                }
                            }else{
                                RestContext.response.responseBody = Blob.valueOf('{"case_id":"","Error":"No account record for the generator code.","Case_No":""}');
								RestCreateCase.createExceptionLog('No account record for the generator code.'+ '|' + reqBody, '','');
                                return;
                            }
                         } 
                    }
                    
                    if(accSuppPerson != null){
                        User us = [Select Id, Name, isActive, ManagerId, Manager.isActive, Manager.Name FROM USER WHERE Name =: accSuppPerson LIMIT 1]; //Update the query to pull Manager Related information - Sireesha
                    	//Assign the user as owner only if the User is active - Sireesha
                        if(us.isActive && !us.Name.Contains('Inactive')){
                            newCase.OwnerId = us.Id;
                        }//Otherwise assign to the Manager if he is active - Sireesha
                        else if(us.ManagerId != NULL && us.Manager.isActive && !us.Manager.Name.Contains('Inactive')){
                            newCase.OwnerId = us.ManagerId;
                        }
                    }
                }
                insert newcase;
                
            }
             /*This is to handle Invoice Delovery Record Type Cases
             */
            else if(reqWrapper.SOURCE_APP == CHConstants.INTEGRATION_SOURCE_APP_INV_DEL){
                
                newcase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CHConstants.CASE_RECORD_TYPE_NAME_INV_DEL).getRecordTypeId();
                
               
                
                newcase.Description= CHConstants.INVOICE_DELIVERY_CASE_DESCRIPTION;
                newcase.Type= reqWrapper.CASE_TYPE;
                if(!accs.isEmpty()){
                   
                    newCase.OwnerId = accs[0].OwnerId;
                }
                insert newCase;
            }
            
            Case caseObj = [select Id,CaseNumber from case where Id=: newcase.Id LIMIT 1];

            RestContext.response.responseBody = Blob.valueOf('{"case_id" :"' +newcase.Id+'","Error":"","Case_No":"'+caseObj.CaseNumber+'"}');
        } catch (Exception e){
            system.debug('---'+e.getLineNumber());
            RestContext.response.responseBody = Blob.valueOf('{"case_id":"","Error":"'+ e.getMessage()+'","Case_No":""}');
			RestCreateCase.createExceptionLog(e.getMessage()+ '|' +reqBody,e.getStackTraceString(), '');
        }
        
    }
    
    public class RquestWrapper{
        
        public String SOURCE_APP;
        public String CUST_ID;
        public String DESCRIPTION;
        public string USER_ID;
        
        //Parameters related to NSB and Closed Order WorkBench
        public String INVOICE_DATE;
        public String INVOICE_NUM;
        public String SALESORDER_NUM;
        public String INVOICE_VAL;
        public String BRANCH_CODE;
        public String CASE_TYPE;
        public String GENERATOR_CODE;
		Public String PO_TIMING;
        public String ORDER_TYPE;
        public String SERVICING_BRANCH;
        Public String Subject;		
        
        //Parameters related to Test
        public String BUSINESS_UNIT;
        public String FOLLOW_UP_ACTION;
        public String Keyword1;
        public String Keyword2;
        public String Keyword3;
        public String SETID;
        public String CUST_BALANCE;        
              
        
    }
    private static void createExceptionLog(string errorMessage, string stackTrace, string recordId){
        Exception_Log__c log = new Exception_Log__c(
            Error_Message__c= errorMessage, 
            Exception_Stack_Trace__c= stackTrace, 
            Record_Id__c= recordId, 
            Apex_Method_Event__c= 'createnewcase'
        );
        ExceptionLogDAO.logException(new List<Exception_Log__c>{log});
    }
}