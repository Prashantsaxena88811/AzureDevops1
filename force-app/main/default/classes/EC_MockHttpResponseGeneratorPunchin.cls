/* Class Name       :EC_MockHttpResponseGeneratorPunchin
* Description      : MockResponse Generator for EC_PunchinService class
* Created By       :Raghav Sharma
* Created On       :06-10-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Raghav Sharma        06-10-2019                                  MockResponse Generator for EC_PunchinService class
*
*/
@isTest()
global class EC_MockHttpResponseGeneratorPunchin implements HttpCalloutMock {
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
        res.setHeader('client_id', '3MVG9er.T8KbeePT1omIsgyERiPw3Xpz40f3om.tgbYaA3xpABw_pKrRXdYp_stiX.sS_N.U4VfgnlOL_8on3');
        res.setHeader('client_secret', '477B2D172AE122AC39071AC0E0FBE5C9020818ACAD0EE4DDF35858DB63D8436C');
       // res.setBody(getJSONBody());
        res.setBody('{\"ukey\":\"skapuuser234@yopmail.com\", \"pkey\":\"deloitte2\", \"shipTo\":\"805269693\", \"sharedSecret\":\"Winter16\" , \"callBackURL\":\"https://www.ibuyefficient.com/Buyer/Catalog/PunchoutWait?catalogID=4614266667\", \"BuyerCookie\":\"4614268931461426666720191015023245\", \"fromDomain\":\"NetworkId\", \"fromIdentity\":\"106681320132430eb38a99318dce8f68\", \"senderDomain\":\"buyefficient.com\", \"senderIdentity\":\"106681320132430eb38a99318dce8f68\", \"toDomain\":\"buyefficient.com\", \"toIdentity\":\"805269693\", \"senderUserAgent\":\"Ariba ORMS 5.1P4\", \"xmlLanguage\":\"Yes\", \"payloadId\":\"Yes\" ,\"Version\":\"Yes\" }');
        res.setStatusCode(200);
        return res;
    }

     global string getJSONBody()
    {

    //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
    String json = '{'+
		'\"url\": http://devec1-ecolabconnect--devec1.cs62.force.com/DefaultStore/PunchoutLogin?uKey=skapuuser234@yopmail.com&pKey=deloitte2&effectiveAccountId=0015C00000QHK4RQAX&cartId=144fd36b-d643-4979-a1b0-b8fd541d5723,'+
		'\"responseCode\": \"2001\",'+
        '\"Message\": \"Success\",'+
		'}';
    return json;
    }


}