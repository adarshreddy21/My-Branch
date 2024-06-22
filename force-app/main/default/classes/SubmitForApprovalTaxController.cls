public class SubmitForApprovalTaxController {
    
    @AuraEnabled
    public static String submitForApprovalTax(String taxRecId, String comments){
        
        String returnMessage = '';
        Boolean isAttAvailable = FALSE;
        
        for(ContentDocumentLink conDoc : [Select Id from ContentDocumentLink where LinkedEntityId =: taxRecId]){
            
            isAttAvailable = TRUE;
            break;
        }
        
        if(isAttAvailable){
            
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(comments);
            req.setObjectId(taxRecId);
            
            // Submit on behalf of a specific submitter
            req.setSubmitterId(UserInfo.getUserId()); 
            
            // Submit the record to specific process and skip the criteria evaluation
            req.setProcessDefinitionNameOrId('Tax_Document_Approval_Process');
            req.setSkipEntryCriteria(true);
            
            // Submit the approval request
            Approval.ProcessResult result = Approval.process(req);
            
            returnMessage = 'success';
        }
        else{
            
            returnMessage = 'error';
        }
        
        return returnMessage;
    }

}