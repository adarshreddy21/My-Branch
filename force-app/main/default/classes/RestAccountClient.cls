public class RestAccountClient {
    public static List<WinResponse> generateWinIds(List<Account> accountsForGeneratingWin){
        HttpRequest req = new HttpRequest();
		req.setMethod('POST');
        req.setEndpoint('callout:WinId_Generation_Endpoint/api/win');
		req.setHeader('Content-Type','application/json'); 
        req.setHeader('Accept','application/json');
        req.setTimeout(100000); 
		List<WinRequest> requestPayload  = new List<WinRequest>();
        for(Account acc : accountsForGeneratingWin){
            WinRequest requestData = new WinRequest();
            requestData.SFID= acc.Id;
            requestData.CompanyName = acc.Name;
            requestData.CompanyType= acc.Type;
            requestPayload.Add(requestData); 
        }
        //System.debug(requestPayload);
		req.setBody(JSON.serialize(requestPayload));
		Http http = new Http();
		HTTPResponse res = http.send(req);
		string response= res.getBody();
        //System.debug(response);
        if(res.getStatusCode() == 200){
            return (List<WinResponse>)JSON.deserialize(response, List<WinResponse>.class);
        }
        else{
            WinResponse responseObj= new WinResponse();
            responseObj.Message= response;
            return new List<WinResponse>{responseObj};
        }    
    }
    public static string createMagentoAccountOnDifferentThread(Account accountObject){   
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm(); 
        String restAPIURL = sfdcURL + '/services/data/v56.0/sobjects/Account/';  
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('POST');   
        httpRequest.setHeader('Content-Type','application/json'); 
        httpRequest.setHeader('Accept','application/json');
        httpRequest.setBody(JSON.serialize(accountObject));
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); 
        httpRequest.setEndpoint(restAPIURL);  
        String response = '';
        try{  
            Http http = new Http();   
            HttpResponse httpResponse = http.send(httpRequest);
            response= httpResponse.getBody();
        } 
        catch(System.Exception e) {  
                System.debug('ERROR: '+ e);  
                throw e;  
        }  
        return response;       
    }
    
    public class WinResponse{
    	public String SFID {get; set;}
        public string WinID {get; set;}
        public string Message {get; set;}
	}
    public class WinRequest{
    	public String SFID {get; set;}
        public string CompanyName {get; set;}
        public string CompanyType {get; set;}
	}
}