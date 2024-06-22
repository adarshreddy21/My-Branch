public class MagentoUMOAPIMock implements HttpCalloutMock {
    protected Integer statusCode;  
    private Id accId =null; 
    public MagentoUMOAPIMock (Integer statusCode){
        this.statusCode= statusCode;
    }
    public MagentoUMOAPIMock (Integer statusCode, Id accId){
        this.statusCode= statusCode;
        this.accId= accId;
        winIdSuccessResponseWithPlaceholderSFId= winIdSuccessResponseWithPlaceholderSFId.replace('$$SFId$$', this.accId);
    }
    private  final String accountCreationSuccessResponse = 
    '{'
        +'"success": true,'
        +'"id":"'+CHTestFactory.getFakeId(Account.sObjectType)+'"'
    +'}';
    private final String accountCreationErrorResponse  = 
    '[{'
         +'"WinID": "ABC",'+
         +'"SFID":"'+CHTestFactory.getFakeId(Account.sObjectType)+'"'
     +'}]';
    private final String winIdSuccessResponse  = 
   '[{'
        +'"WinID": "ABC",'+
        +'"SFID":"'+CHTestFactory.getFakeId(Account.sObjectType)+'"'
    +'}]';

    private String winIdSuccessResponseWithPlaceholderSFId  = 
   '[{'
        +'"WinID": "ABC",'+
        +'"SFID":"$$SFId$$"'
    +'}]';
    private final String winIdErrorResponse  = 
    '[]';
    public HttpResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json; charset=UTF-8'); 
        response.setStatusCode(this.statusCode);
        if(this.statusCode==200){
            if(req.getEndpoint().contains('sobjects/Account/')){
            response.setBody(accountCreationSuccessResponse);
            }
            else{
                if(this.accId!=null){
                    response.setBody(winIdSuccessResponseWithPlaceholderSFId);
                }
                else{
                  response.setBody(winIdSuccessResponse);
                }
            }
        }
        else{
            if(req.getEndpoint().contains('sobjects/Account/')){
                if(this.statusCode==400){
                    response.setBody(accountCreationErrorResponse);
                }
                else{
                    response.setBody(accountCreationSuccessResponse);
                }
            }
            else{
                response.setBody(winIdErrorResponse);
            }
        }
        return response;
    }        
}