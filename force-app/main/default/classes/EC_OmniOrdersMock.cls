@isTest
global class EC_OmniOrdersMock  implements HttpCalloutMock{

     global HTTPResponse respond(HTTPRequest request){
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
       	response.setBody('{"orders": [{"orderShipToNumber": "500154933","orderLineItems": [{"orderLineStage": "Order Management","orderLineItemCategory": "ZS3P","orderLineNum": "10"}]}]}' );
        response.setStatusCode(200);
        return response; 
    }
}