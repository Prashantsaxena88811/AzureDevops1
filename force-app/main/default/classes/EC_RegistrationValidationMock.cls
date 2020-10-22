@isTest
global class EC_RegistrationValidationMock  implements HttpCalloutMock{

     global HTTPResponse respond(HTTPRequest request){
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
       response.setBody('{"responseCode":"1001","userKey":"123","accountKey":"1234","federationId":"ExampleFederationId","redemptionUrl":"ExampleRedemptionUrl","accountNo":"322235","salesRepEmail":"jamie@lannister.com","userEmail":"ecolabDev1@outlook.com","firstName":"John","lastName":"Snow","sourceSystemCode":"User"}' );
     //     response.setBody('{\"accountNo\":\"1242\", \"salesRepEmail\":\"abc@gmail.com\", \"userKey\":\"ujey\"}');
        response.setStatusCode(200);
        return response; 
    }

         
         
         
         }