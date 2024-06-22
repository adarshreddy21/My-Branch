/*Author: Sireesha
Description: This class would be used to send the Updated Case details to WIN
*/
public class RestUpdateCase {

    @future(callout=true)
    public static void sendCaseDetails(List<Id> caseIds, Boolean fromCase){
        
        Case caseObj = [Select CaseNumber, Owner.Name, Status, Comments__c, LastModifiedBy.Name, LastModifiedBy.Alias, (Select Id, CommentBody, LastModifiedBy.Alias, LastModifiedBy.Name from CaseComments order by lastModifiedDate desc limit 1) from Case where Id =: caseIds[0]];
        
        RequestWrapper reqWrap = new RequestWrapper();
        reqWrap.CaseNumber = caseObj.CaseNumber;
        if(fromCase){
            reqWrap.UserName = caseObj.LastModifiedBy.Alias;
        }
        else if(caseObj.CaseComments.size() > 0){
            reqWrap.UserName = caseObj.CaseComments[0].LastModifiedBy.Alias;
        }
        reqWrap.CaseStatus = caseObj.Status;
        if(caseObj.CaseComments.size() > 0){
            reqWrap.Comment = caseObj.CaseComments[0].CommentBody;
        }
        
        String endPointUrl = System.Label.WIN_ENDPOINT_URL;
        String authToken = System.Label.WIN_AUTH_TOKEN;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setEndpoint('callout:WIN_ENDPOINT_URL_NC'); 
        request.setBody(JSON.serialize(reqWrap));
        request.setMethod('POST');
        request.setHeader('AuthToken', '{!$Credential.Password}');
        request.setTimeOut(60000);
        HttpResponse response = http.send(request);
        
        System.debug('--'+JSON.deserializeUntyped(response.getBody()));
        if(response.getStatusCode()==200 && JSON.deserializeUntyped(response.getBody()) == ''){
            caseObj.WIN_Sync_Status__c = CHConstants.CASE_WIN_SYNC_STATUS_SUCCESSFUL;
        }
        else{
            caseObj.WIN_Sync_Status__c = CHConstants.CASE_WIN_SYNC_STATUS_FAILED;
        }
        update caseObj;
    }
    
    public class RequestWrapper{
        
        public String CaseNumber;
        public String UserName;
        public String CaseStatus;
        public String Comment;
    }
}