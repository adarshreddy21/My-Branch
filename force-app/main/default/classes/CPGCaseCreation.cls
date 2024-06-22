@RestResource(urlMapping='/cpg/cases/*')
global class CPGCaseCreation {
    private static Id CPGCaseRecordType = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('CPG_Request').getRecordTypeId();
    @HttpPost
    global static void createnewcase(CaseRequestWrapper request)
    {
        RestResponse res = RestContext.response;
        try{
            if(!String.isBlank(request.Profile) && !String.isBlank(request.GeneratorCode) && !String.isBlank(request.ApprovalStatus)){
               List<Case> existingCases = CaseDAO.getCasesforProfileandWinIds(new Set<string>{request.GeneratorCode},new List<string>{request.Profile});
               List<Account> accounts = AccountDAO.getAccountsByWinIdS(new Set<string>{request.GeneratorCode});
			   List<User> owners = new List<User>();
			   List<User> users= new List<User>();
			   if(!String.isBlank(request.CPGOwnerID)){
					users = UserDAO.getUsersforEmpIds(new Set<string>{request.CPGOwnerID});
			   }
			   if(!String.isBlank(request.SubmitterId)){
                    owners = UserDAO.getUsersforEmpIds(new Set<string>{request.SubmitterId});
               }
               if(accounts == null || accounts.isEmpty())
               {
                    res.statusCode=400;
                    res.responseBody = Blob.valueOf(JSON.serialize(new CaseResponseWrapper('false','Invalid Generator Code : '+request.GeneratorCode,'')));
                    return;
               }
               if(request.ApprovalStatus == 'I')
               {
                    if(!existingCases.isEmpty())
                    {   
                        existingCases[0].Waste_Description__c = request.CurrentProfileDescription;
						if(!users.isEmpty()){
							existingCases[0].CPG_Owner__c = users[0].ID;
						}		
                        existingCases[0].Profile_Status__c = request.ApprovalStatus; 
                        existingCases[0].Incomplete_Profile_Comments__c = request.ProfileInstructions;
                        CaseDAO.updateCases(existingCases); 
                        res.responseBody = Blob.valueOf(JSON.serialize(new CaseResponseWrapper('true','','record updated')));
                        return;
                    }
                    else
                    {
                        Case newCase = new Case();
                        newCase.AccountId = accounts[0].Id;
						if(!Owners.isEmpty()) {
                            if(Owners[0].isActive == True){
                                newCase.OwnerId = Owners[0].Id;
                            }
                            else {
                            newCase.OwnerId = Owners[0].ManagerId;
                            }
                        }
                        else if(accounts[0].Secondary_Owner__c != NULL && accounts[0].Secondary_Owner__r.isActive == True){
                            newCase.OwnerId = accounts[0].Secondary_Owner__r.Id;
                        }
                        else if (accounts[0].Secondary_Owner__c != NULL && accounts[0].Secondary_Owner__r.isActive == false){
                            newCase.OwnerId = accounts[0].Secondary_Owner__r.ManagerId;
                        }
                        else if (accounts[0].Secondary_Owner__c == NULL && accounts[0].Owner.IsActive == True){
                            newCase.OwnerId = accounts[0].OwnerId;
                        }
                        else {
                            newCase.OwnerId = accounts[0].Owner.ManagerId;
                        }
                        newCase.Profile_Number__c = request.Profile;
                        newCase.RecordTypeId = CPGCaseRecordType; 
                        newCase.Subject = Label.CPG_Custom_Label;
                        newCase.Profile_Status__c = request.ApprovalStatus; 
                        newCase.Waste_Description__c = request.CurrentProfileDescription;
						if(!users.isEmpty()){
							newCase.CPG_Owner__c = users[0].ID;
						}	
                        newCase.Incomplete_Profile_Comments__c = request.ProfileInstructions;
                        CaseDAO.insertCases(new List<Case>{newCase});
                        res.responseBody = Blob.valueOf(JSON.serialize(new CaseResponseWrapper('true','','record created')));
                        return;
                    }
                   
                }
                else if( request.ApprovalStatus != 'I')
                {
                    if(!existingCases.isEmpty())
                    {
                        if( request.ApprovalStatus == 'D')
                        {
                            existingCases[0].Status = 'Closed - Deadfiled'; 
                        }
                        else if( request.ApprovalStatus == 'A')
                        {
                            existingCases[0].Status = 'Closed - Approved';
                        }
                        else
                        {
                            existingCases[0].Status = 'Closed';
                        }
                        existingCases[0].Waste_Description__c = request.CurrentProfileDescription;
                        existingCases[0].Profile_Status__c = request.ApprovalStatus;   
						if(!users.isEmpty()){	
							existingCases[0].CPG_Owner__c = users[0].ID; 
						}
                        existingCases[0].Incomplete_Profile_Comments__c = request.ProfileInstructions;
                        CaseDAO.updateCases(existingCases);
                        res.responseBody = Blob.valueOf(JSON.serialize(new CaseResponseWrapper('true','','record updated')));
                        return;
                    }
                    else{
                        res.responseBody = Blob.valueOf(JSON.serialize(new CaseResponseWrapper('true','','no action')));
                        return;
                    }
                }
            }
            else
            {
                string errorMessage='';
                if(String.isBlank(request.Profile))
                {
                    errorMessage = errorMessage +'Profile Details are required,';
                }
                if(String.isBlank(request.GeneratorCode))
                {
                    errorMessage = errorMessage +'GeneratorCode is required,';
                }
                if(String.isBlank(request.ApprovalStatus))
                {
                    errorMessage = errorMessage +'Approval Status is required,';
                }
                logException(errorMessage, null, null);
                res.statusCode=400;
                res.responseBody = Blob.valueOf(JSON.serialize(new CaseResponseWrapper('false',errorMessage.removeEnd(','),'')));
                return;
            }
        }
        catch(exception ex)
        {
            logException(ex.getMessage(), null, null);
            res.statusCode=400;
            res.responseBody = Blob.valueOf(JSON.serialize(new CaseResponseWrapper('false',ex.getMessage(),'')));
            return;
        }
        
    }
    global class CaseResponseWrapper{
        public CaseResponseWrapper(string success,string error,string additionalinformation)
        {
            this.success=success;
            this.error=error;
            this.additionalinformation=additionalinformation;
        }
        public string success { get; set; }
        public string error { get; set; }
        public string additionalinformation { get; set; }
    }
    global class CaseRequestWrapper{
        public string GeneratorCode { get; set; }
        public string Profile { get; set; }
        public string ApprovalStatus { get; set; }
        public string CurrentProfileDescription { get; set; }
        public string CPGOwnerID { get; set; }
        public string ProfileInstructions { get; set; }
        public date DateMarkedIncomplete { get; set; } 
		public string SubmitterId {get; set;}
    }
    private static void logException(string errorMessage, string stackTrace, string recordId){
        Exception_Log__c log = new Exception_Log__c(Error_Message__c= errorMessage, Exception_Stack_Trace__c= stackTrace, Record_Id__c= recordId, Apex_Method_Event__c= 'CaseRequestWrapper');
        ExceptionLogDAO.logException(new List<Exception_Log__c>{log});
    }
}