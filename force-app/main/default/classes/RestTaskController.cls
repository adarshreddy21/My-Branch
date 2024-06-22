@RestResource(urlMapping = '/TaskController/*')
global class RestTaskController {
    @HttpPost
    global static void createnewtask(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String reqBody = req.requestBody.toString();
        PCWBCallSheetNotesRequest sheetNoteObj =
            (PCWBCallSheetNotesRequest)JSON.deserialize(reqBody, PCWBCallSheetNotesRequest.class);
        
        String orderNo = sheetNoteObj.FocalPointOrderNo;
        List<Account> accList = new List<Account>();
            
        if(String.isNotBlank(sheetNoteObj.WinId)){
            accList = [Select Id, Name, Account_Owner_Sales_Branch__c from Account where WIN_ID__c=:sheetNoteObj.WinId LIMIT 1];
        }
        
        List<Task> taskLst = new List<Task>();
        if(accList.size() > 0){
            taskLst = [
                SELECT Id 
                FROM Task
                WHERE Service_Order_Number__c = :orderNo
                AND WhatId = :accList[0].Id
                LIMIT 1
            ];
        }
        
        if (taskLst.isEmpty()) {
           Id callCenterActivityRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Call_Center_Activity').getRecordTypeId();
            Task taskRec = new Task();
            taskRec.RecordTypeId = callCenterActivityRecordTypeId;
            taskRec.Caller_First_Name__c = sheetNoteObj.CallerFirstName;
            taskRec.Caller_Last_Name__c = sheetNoteObj.CallerLastName;
            taskRec.Caller_Phone__c = sheetNoteObj.CallerPhone;
            taskRec.Call_Type__c = sheetNoteObj.CallSheetType;
            taskRec.Type = sheetNoteObj.CallType;
            taskRec.Priority = sheetNoteObj.Priority;
            taskRec.Status = sheetNoteObj.OrderStatus;
            taskRec.Description = sheetNoteObj.CallSheetNotes;
            taskRec.Service_Order_Number__c = sheetNoteObj.FocalPointOrderNo;
            taskRec.Primary_Type_of_Service__c = sheetNoteObj.PrimaryTypeOfService;
            taskRec.PO_Number__c= sheetNoteObj.PONumber;
            
            if(accList.size() > 0){
                taskRec.WhatId = accList[0].Id;
            	taskRec.Resolution_3__c = accList[0].Account_Owner_Sales_Branch__c;
            }
            List<User> userLst = [SELECT Id FROM User WHERE FederationIdentifier = :sheetNoteObj.Usrname LIMIT 1];
            if(userLst.size() > 0)
                taskRec.OwnerId = userLst[0].Id;
            Database.SaveResult sr = Database.insert(taskRec, false);
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 200;
            
            if (sr.isSuccess()) {
                PCWBCallSheetNotesResponse notesResponse = new PCWBCallSheetNotesResponse();
                notesResponse.status = 'Success';
                notesResponse.message = 'Task Successfully Created';
                // Operation was successful, so get the ID of the record that was processed
                res.responseBody = Blob.valueOf(JSON.serialize(notesResponse));
            }else {
                PCWBCallSheetNotesResponse notesResponse = new PCWBCallSheetNotesResponse();
                // Operation failed, so get all errors    
                notesResponse.status = 'Error';    
                String errorMessage = '';
                for(Database.Error err : sr.getErrors()) {
                    errorMessage += err.getMessage();
                }
                notesResponse.errorMessage = errorMessage;
                
                res.responseBody = Blob.valueOf(JSON.serialize(notesResponse));
            }
        }else{
            PCWBCallSheetNotesResponse notesResponse = new PCWBCallSheetNotesResponse();
            notesResponse.status = 'Success';
            notesResponse.message = 'Task is already exist for Service Order Id.';
            res.responseBody = Blob.valueOf(JSON.serialize(notesResponse));
        }
    }
    
    public class PCWBCallSheetNotesResponse{
        public String status;
        public String message;
        public String errorMessage;
    }
    
    public class PCWBCallSheetNotesRequest{
        public string Usrname;
        public string CallerFirstName;
        public string CallerLastName;
        public string CallerPhone;
        public string WinId;
        public string CallSheetType;
        public string FocalPointOrderNo;
        public string PrimaryTypeOfService;
        public string CallType;
        public string Priority;
        public string OrderStatus;
        public string CallSheetNotes;
        public string PONumber;
    }
}