@isTest
global class EC_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('client_id', '123456');
        res.setHeader('client_secret', '1234156');
       // res.setBody(getJSONBody());
        res.setBody('{\"responseCode\":\"1002\", \"accountNo\":\"23445667\", \"userKey\":\"123456\", \"isValid\":\"true\"}');
        res.setStatusCode(200);
        return res;
    }
    
     global string getJSONBody()
    {
     
    //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
    String json = '{'+
		'\"responseCode\": 1001,'+
		'\"accountNo\": \"23445667\",'+
        '\"userKey\": \"123456\",'+
        '\"isValid\": true,'+
		'}';
    return json;
    }
    
    
}