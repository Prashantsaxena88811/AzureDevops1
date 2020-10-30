@isTest()
public class EC_MockFailedOrderHttpResponseGenerator implements HttpCalloutMock {
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
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
        res.setBody(getJSONBody());
        res.setStatusCode(400);
        return res;
    }
    
     public string getJSONBody()
    {
     
    return '{'+
                    '\"token_type\": \"Bearer\",'+
                    '\"expires_in\": 3599,'+
                    '\"ext_expires_in\": 3599,'+
                    '\"access_token\": \"eyJ0eXAiOiJKV1Qi\",'+
        			'\"apiName\": \"ecolab-orders-entry-v1-dev\",'+
                    '\"meta\": {'+
                        '\"statusCode\": 400,'+
                        '\"additionalInfo\": ['+
                            '\"Bad Request!\"'+
                        '],'+
                        '\"status\": \"Fail\"'+
                    '},'+
                    '\"correlationId\": \"441ad150-fda9-11ea-bd2d-12da160cf2ed\",'+
                    '\"version\": \"v1\",'+
                    '\"timestamp\": \"2020-09-23T14:30:02.695Z\"'+
                '}';
    }
    

}