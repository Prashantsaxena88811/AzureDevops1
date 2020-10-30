/**************************************************************************************************************
** Name             : ServiceNowCaseCreateHTTPMockFactory
** Description      : This is a generic Class which can be used to mock callouts for testing REST implementation
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Graytitude                    Oct-2020                    1.0                          Created    
**************************************************************************************************************/
@isTest
public class ServiceNowCaseCreateHTTPMockFactory implements HttpCalloutMock {
    public Integer responseCode {get; set;}
    public String status {get; set;}
    public String response {get; set;}
    protected Map<String, String> responseHeaders;
    public HttpRequest request {get; set;}

    public ServiceNowCaseCreateHTTPMockFactory(Integer responseCode, String status, String response, Map<String, String> responseHeaders) {
        this.responseCode = responseCode;
        this.status = status;
        this.response = response;
        this.responseHeaders = responseHeaders;
    }
    public HTTPResponse respond(HTTPRequest req) {
        this.request = req;
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.response);
        res.setStatusCode(this.responseCode);
        res.setStatus(this.status);
        return res;
    }
}