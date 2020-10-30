@isTest
public class EC_MockHttpResponseGenerator implements HttpCalloutMock {
    String Endpoint;

    Map<String, String> rtnMap = new Map<String, String> {
        'SelfAlign1001' => '{\"responseCode\":\"1001\", \"accountNo\":\"23445667\", \"userKey\":\"123456\", \"isValid\":\"true\"}',
        'SelfAlign1002' => '{\"responseCode\":\"1002\", \"accountNo\":\"23445667\", \"userKey\":\"123456\", \"isValid\":\"true\"}'
    };

    public EC_MockHttpResponseGenerator(String Endpoint) {
        this.Endpoint = Endpoint;
    }

    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');
        res.setHeader('client_id', '123456');
        res.setHeader('client_secret', '1234156');
        res.setBody(rtnMap.get(Endpoint));
        res.setStatusCode(200);
        
        return res;
    }
    
}