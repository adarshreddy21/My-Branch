@RestResource(urlMapping = '/NewCase/*')
global class RestNewCase {
    @HttpGet
    global static List <Case> getCase()
    {
        /*
        //services/apexrest/NewCase?startDate=05-10-2019T11:30 AM&endDate=05-10-2019T11:40 AM
		*/
        /*
        String startDate = RestContext.request.params.get('startDate'); //Format : MM-DD-YYYYThh:mm AM
        String endDate = RestContext.request.params.get('endDate'); //Format : MM-DD-YYYYThh:mm AM
        
        system.debug('startDate-->'+startDate);
        system.debug('endDate-->'+endDate);
        
        Datetime startDT = Datetime.parse(startDate.replace('T',' ').replace('-','/'));
        Datetime endDt = Datetime.parse(endDate.replace('T',' ').replace('-','/'));
        
        system.debug('startDate-->'+startDT);
        system.debug('endDate-->'+endDT);
        
        List<Case> c = [SELECT id, createdDate, status, subject, WIN_Id__c, Balance_Amount__c, CurrentSpendAmount__c, 
                               Inserted_By__c, PO_Amount__c, PONumber__c, Sales_Order_Number__c, Cust_PO_Master_ID__c, Description, PO_Notify_Email__c 
                               FROM Case
                               WHERE recordtype.name = 'Customer PO Case'
                               AND createddate >=: startDt
                               AND createddate <=: endDt];
        */
        List<Case> c = [select id, createdDate, status, subject, WIN_Id__c, Balance_Amount__c, CurrentSpendAmount__c, 
                        Inserted_By__c, PO_Amount__c, PONumber__c, Sales_Order_Number__c, Cust_PO_Master_ID__c, Description, PO_Notify_Email__c,PO_Expiration_Date__c,PO_Activation_Date__c,PO_Case_Auto_Create__c, Unbilled_Amount__c  from Case
                        //where createddate > startDate and createddate < enddate
                        limit 1];
        return c;
    }  
        
    @HttpPost
    
    global static void createnewcase (string subject, string status, string winid, decimal BalanceAmount, decimal CurrentSpendAmount, decimal POAmount,
                                      string PONumber, string SalesOrderNumber, string Comments, string InsertedBy, string CustPOMasterId, string NotifyEmail, string Priority, string Reason,string POExpirationDate, string POActivationDate, Boolean AutoCreateFlag, decimal UnbilledAmount){
        
         //string POExpirationDate  = RestContext.request.params.get('POExpirationDate'); 
         //string POActivationDate  = RestContext.request.params.get('POActivationDate');
                                          
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer PO Case').getRecordTypeId();
       
        try{
           case newcase = new case ();
            newcase.RecordTypeId = devRecordTypeId;
            newcase.Subject = subject;
            newcase.status = status;
            newcase.WIN_Id__c = winid;           
            newcase.Balance_Amount__c = BalanceAmount;
            newcase.CurrentSpendAmount__c = CurrentSpendAmount;
            newcase.PO_Amount__c = POAmount;
            newcase.PONumber__c = PONumber;
            newcase.Inserted_By__c = InsertedBy;
            newcase.Sales_Order_Number__c = SalesOrderNumber;
            newcase.Description = Comments;
            newcase.Cust_PO_Master_ID__c = CustPOMasterId;
            newcase.PO_Notify_Email__c = NotifyEmail;
            newcase.Priority = Priority;
            newcase.Reason = Reason;
            newcase.PO_Expiration_Date__c = Datetime.valueof(POExpirationDate);
            newcase.PO_Activation_Date__c = Datetime.valueOf(POActivationDate);
            newcase.PO_Case_Auto_Create__c = AutoCreateFlag;
            newcase.Unbilled_Amount__c = UnbilledAmount;
              
            
            // c1.PO_Expiration_Date__c = system.now();
          //c1.PO_Activation_Date__c = system.now();
          //c1.PO_Case_Auto_Create__c = true;
          //c1.Unbilled_Amount__c = 5000;
            
            insert newcase;
          string CaseNumber;
           List<case> acc= [select Id,CaseNumber from case where Id=: newcase.Id];
           for(case a: acc)
          {
            CaseNumber = a.CaseNumber;
           }
         RestContext.response.responseBody = Blob.valueOf('{"case_id" :"' +newcase.Id+'","Error":"","Case_No":"'+CaseNumber+'"}');
        } catch (Exception e){
            RestContext.response.responseBody =  Blob.valueOf('{"case_id":"","Error":"'+ e.getMessage()+'","Case_No":""}');
        }
        
    }
    
 
    
}