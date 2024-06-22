@isTest
global class EPAIdMock implements HttpCalloutMock {
    private Boolean isEPAIdValid;
    public EPAIdMock(Boolean isEpaIdValid) {
       this.isEPAIdValid= isEpaIdValid;
    }

    public HTTPResponse respond(HTTPRequest req) {
        AccountValidatorController.EPAIdResponse epaIdResponseObject=new AccountValidatorController.EPAIdResponse();
        epaIdResponseObject.ValidEpa= this.isEPAIdValid;
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setBody(JSON.serialize(epaIdResponseObject));
        return resp;
    }
}