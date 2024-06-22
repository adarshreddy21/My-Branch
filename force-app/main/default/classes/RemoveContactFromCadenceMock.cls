@isTest
global class RemoveContactFromCadenceMock implements HttpCalloutMock {
    Integer code = 0;
    public RemoveContactFromCadenceMock(Integer code)
    {
        this.code = code;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(code == 200)
        {
            res.setBody('[{"actionName":"removeTargetFromSalesCadence","errors":[{"statusCode":"INVALID_API_INPUT","message":"The selected target isnt in a Cadence.","fields":[]}],"isSuccess":false,"outputValues":{"error":"The selected target isnt in a Cadence."},"version":1}]');
        }
        else
        {
            res.setBody('Success');
        }
        res.setStatusCode(200);
        return res;
    }
}