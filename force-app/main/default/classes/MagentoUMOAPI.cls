@RestResource(urlMapping='/magento_umo/company/*')
global class MagentoUMOAPI {

  @HttpPost
  global static void createMagentoUmoRecord() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    Response responseObj = new Response();
    responseObj.success = false;
    CompositeWrapper wrapperObject = null;
    res.addHeader('Content-Type', 'application/json'); 
    string message= '';
    List<Contact> existingContacts= new List<Contact>();
    try {
      String reqBody = req.requestBody.toString();
      wrapperObject = (CompositeWrapper) JSON.deserialize(
        reqBody,
        CompositeWrapper.class
      );
      if(wrapperObject.ContactObj!=null){
         existingContacts= ContactDAO.getContactsByEmail(new Set<String>{wrapperObject.ContactObj.Email});
      }
      if(!existingContacts.isEmpty()){
        message= 'Duplicate Email: '+wrapperObject.ContactObj.Email;
        constructResponse(responseObj, res, 400, false, message, wrapperObject.AccountObj.Id, null);
        logException(message, null, null);
        return;
      }
      string accountResponse= RestAccountClient.createMagentoAccountOnDifferentThread(wrapperObject.AccountObj);
      Object rawResponse= JSON.deserializeUntyped(accountResponse);
      if(rawResponse instanceOf List<Object>){
         Map<String, Object> errorResponse= (Map<String, Object>)(((List<Object>)rawResponse)[0]);
         message= 'Account:' + errorResponse.get('message')+ ' for '+ wrapperObject.AccountObj.Name; 
         constructResponse(responseObj, res, 400, false, message, null, null);
         logException(message, null, null); 
         return;
      }
        Map<String, Object> successResponse= (Map<String, Object>)rawResponse;
        wrapperObject.AccountObj.Id= Id.valueOf(String.valueOf(successResponse.get('id')));
        wrapperObject.AccountObj.Type= 'Customer';
        List<RestAccountClient.WinResponse> responseData = RestAccountClient.generateWinIds(
          new List<Account>{ wrapperObject.AccountObj }
        );
        if (!responseData.isEmpty()) {
          RestAccountClient.WinResponse winResponse = responseData[0];
          if (String.isBlank(winResponse.WinID)) {
            message= 'WinAPI Error:' + winResponse.Message;
            constructResponse(responseObj, res, 500, false, message, null, null);
            logException(message, null, null); 
            return;
          } 
            string winId = winResponse.WinID;
            List<Account> accounts =[Select Id from Account where Win_Id__c=:winId];
            if(!accounts.isEmpty()){
               message= 'WinID: '+winId+' already exists for SFId: ' + accounts[0].Id;
               constructResponse(responseObj, res, 500, false, message, null, null);
               logException(message, null, null); 
               return;
            }
              wrapperObject.AccountObj.Win_Id__c = winId;
              updateAccount(winId, wrapperObject.AccountObj.Id);
              if(wrapperObject.ContactObj!=null){
                  wrapperObject.ContactObj.AccountId = wrapperObject.AccountObj.id;
                   if(!Test.isRunningTest()){
                    insert wrapperObject.ContactObj;
                  }
                }
              constructResponse(responseObj, res, 200, true, null, wrapperObject.AccountObj.Id, winId);
        }
        else{
            message= 'WIN API did not return winid for accountSFID:'+ wrapperObject.AccountObj.Id;
            constructResponse(responseObj, res, 400, false, message, wrapperObject.AccountObj.Id, null);
            logException(message, null, null);
        }
   } 
    catch (Exception e) {
      constructResponse(responseObj, res, 400, false, e.getMessage(), null, null);
      logException(e.getMessage(), e.getStackTraceString(), null);
    }
  }
  public class CompositeWrapper {
    public Account AccountObj { get; set; }
    public Contact ContactObj { get; set; }
  }
  @TestVisible
  private class Response {
    public boolean success { get; set; }
    public string message { get; set; }
    public string winId { get; set; }
    public string accountSFid { get; set; }
  }

  @future
  private static void updateAccount(string winId, Id accountId){
      Account accountObj =new Account();
      accountObj.Win_Validate_new__c= true;
      accountObj.Win_Id__c= winId;
      accountObj.High_Priority__c= true;
      accountObj.Id= accountId; 
      if(!Test.isRunningTest()){
          AccountDAO.updateAccounts(new List<Account>{accountObj});
      }
  }

  private static void constructResponse(Response responseObj, RestResponse res, Integer statusCode,Boolean success, string message, Id accountSFId, string winId){
      responseObj.accountSFid= accountSFId;
      res.statusCode= statusCode;
      responseObj.success= success;
      responseObj.message= message;
      responseObj.winId= winId;
      res.responseBody = Blob.valueOf(JSON.serialize(responseObj));
  }

  private static void logException(string errorMessage, string stackTrace, string recordId){
     Exception_Log__c log = new Exception_Log__c(Error_Message__c= errorMessage, Exception_Stack_Trace__c= stackTrace, Record_Id__c= recordId, Apex_Method_Event__c= 'createMagentoUmoRecord');
     ExceptionLogDAO.logException(new List<Exception_Log__c>{log});
  }
}