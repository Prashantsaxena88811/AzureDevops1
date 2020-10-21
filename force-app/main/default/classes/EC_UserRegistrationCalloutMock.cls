@isTest
global class EC_UserRegistrationCalloutMock implements HTTPCalloutMock {
    
    String registerUser_Sce1_200 = '{\"responseCode\":\"1001\",\"accountKey\":555,\"accountNo\":\"222\",\"salesRepEmail\":\"ned.stark@ym.com\",\"userKey\":77777777,\"displayName\":\"John Smith\",\"userEmail\":\"john.smith@ym.com\",\"isLocalAllowed\":true,\"isRegisteredDomain\":true}';
    String registerUser_Sce2_200 = '{\"responseCode\":\"1001\",\"accountKey\":555,\"accountNo\":\"222\",\"salesRepEmail\":\"ned.stark@ym.com\",\"userKey\":77777777,\"displayName\":\"John Smith\",\"userEmail\":\"john.smith@ym.com\",\"isLocalAllowed\":false,\"isRegisteredDomain\":true}';
    String registerUser_Sce3_200 = '{\"responseCode\":\"1001\",\"accountKey\":555,\"accountNo\":\"222\",\"salesRepEmail\":\"ned.stark@ym.com\",\"userKey\":77777777,\"displayName\":\"John Smith\",\"userEmail\":\"john.smith@ym.com\",\"isLocalAllowed\":true,\"isRegisteredDomain\":false}';
    String registerUser_Sce4_200 = '{\"responseCode\":\"1002\",\"accountKey\":555,\"accountNo\":\"222\",\"salesRepEmail\":\"ned.stark@ym.com\",\"userKey\":77777777,\"displayName\":\"John Smith\",\"userEmail\":\"john.smith@ym.com\",\"isLocalAllowed\":false,\"isRegisteredDomain\":false}';
    String registerUser_Sce5_200 = '{\"responseCode\":\"9999\"}';
    String registerUser_Sce1_400 = '{\"responseCode\":\"1004\"}';
    
    String domainProperties_Sce1_200 = '{\"responseCode\":\"1001\",\"isLocalAllowed\":true,\"isRegisteredDomain\":true,\"userInfo\":{\"userEmail\":\"john.smith@ym.com\",\"displayName\":\"JohnSmith\",\"creationType\":\"Local\",\"accountEnabled\":true,\"creationDate\":\"2020-07-19T07:22Z\",\"upn\":\"john.smith@yp.com\",\"azureObjectId\":\"102876\"}}';
    String domainProperties_Sce2_200 = '{\"responseCode\":\"1001\",\"isLocalAllowed\":true,\"isRegisteredDomain\":false,\"userInfo\":{\"userEmail\":\"john.smith@ym.com\",\"displayName\":\"JohnSmith\",\"creationType\":\"Local\",\"accountEnabled\":true,\"creationDate\":\"2020-07-19T07:22Z\",\"upn\":\"john.smith@yp.com\",\"azureObjectId\":\"102876\"}}';
    String domainProperties_Sce3_200 = '{\"responseCode\":\"1001\",\"isLocalAllowed\":false,\"isRegisteredDomain\":true,\"userInfo\":{\"userEmail\":\"john.smith@ym.com\",\"displayName\":\"JohnSmith\",\"creationType\":\"Local\",\"accountEnabled\":true,\"creationDate\":\"2020-07-19T07:22Z\",\"upn\":\"john.smith@yp.com\",\"azureObjectId\":\"102876\"}}';
    String domainProperties_Sce4_200 = '{\"responseCode\":\"1001\",\"isLocalAllowed\":false,\"isRegisteredDomain\":false,\"userInfo\":{\"userEmail\":\"john.smith@ym.com\",\"displayName\":\"JohnSmith\",\"creationType\":\"Local\",\"accountEnabled\":true,\"creationDate\":\"2020-07-19T07:22Z\",\"upn\":\"john.smith@yp.com\",\"azureObjectId\":\"102876\"}}';
    String domainProperties_Sce5_200 = '{\"responseCode\":\"9999\"}';
    String domainProperties_Sce1_400 = '{\"responseCode\":\"1004\"}';
    
    String directoryUser_Sce1_200 = '{\"userEmail\":\"john.smith@ym.com\",\"displayName\":\"John Smith\",\"accountEnabled\":true,\"creationType\":\"Local\",\"creationDate\":\"2020-07-19T07:22Z\",\"upn\":\"john.smith@yp.com\",\"azureObjectID\":\"102876\",\"responseCode\":\"1001\"}';
    String directoryUser_Sce2_200 = '{\"responseCode\":\"9999\"}';
    String directoryUser_Sce1_400 = '{\"responseCode\":\"1004\"}';
    
    public HTTPResponse respond(HTTPRequest req) {
        
        String apiResponse;
        
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setHeader('Content-Type', 'application/json');
        
        if(req.getEndpoint().contains('registerUser_Sce1_200')) {
            apiResponse = registerUser_Sce1_200;
        } else if(req.getEndpoint().contains('registerUser_Sce2_200')) {
            apiResponse = registerUser_Sce2_200; 
        } else if(req.getEndpoint().contains('registerUser_Sce3_200')) {
            apiResponse = registerUser_Sce3_200; 
        } else if(req.getEndpoint().contains('registerUser_Sce4_200')) {
            apiResponse = registerUser_Sce4_200; 
        } else if(req.getEndpoint().contains('registerUser_Sce5_200')) {
            apiResponse = registerUser_Sce5_200; 
        }else if(req.getEndpoint().contains('registerUser_Sce1_400')) {
            apiResponse = registerUser_Sce1_400; 
            resp.setStatusCode(500);
        } else if(req.getEndpoint().contains('domainProperties_Sce1_200')) {
            apiResponse = domainProperties_Sce1_200;   
        } else if(req.getEndpoint().contains('domainProperties_Sce2_200')) {
            apiResponse = domainProperties_Sce2_200;   
        } else if(req.getEndpoint().contains('domainProperties_Sce3_200')) {
            apiResponse = domainProperties_Sce3_200;   
        } else if(req.getEndpoint().contains('domainProperties_Sce4_200')) {
            apiResponse = domainProperties_Sce4_200;   
        } else if(req.getEndpoint().contains('domainProperties_Sce5_200')) {
            apiResponse = domainProperties_Sce5_200;   
        } else if(req.getEndpoint().contains('domainProperties_Sce1_400')) {
            apiResponse = domainProperties_Sce1_400; 
            resp.setStatusCode(500);
        } else if(req.getEndpoint().contains('directoryUser_Sce1_200')) {
            apiResponse = directoryUser_Sce1_200;   
        } else if(req.getEndpoint().contains('directoryUser_Sce2_200')) {
            apiResponse = directoryUser_Sce2_200; 
        } else if(req.getEndpoint().contains('directoryUser_Sce1_400')) {
            apiResponse = directoryUser_Sce1_400;
            resp.setStatusCode(500);
        }
        System.debug('>>> EC_UserRegistrationCalloutMock respond: ' + apiResponse);
        resp.setBody(apiResponse);
        return resp;
    }
}