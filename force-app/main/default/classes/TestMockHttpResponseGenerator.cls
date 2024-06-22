@isTest
global class TestMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;

    public TestMockHttpResponseGenerator(Integer code, String status, String body) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        //resp.setStatus(status);
        //resp.setHeader('Set-Cookie', 'application/json');
        if (bodyAsBlob != null) {
            resp.setBodyAsBlob(bodyAsBlob);
        } else {
            resp.setBody(bodyAsString);
        }
        return resp;
    }
}