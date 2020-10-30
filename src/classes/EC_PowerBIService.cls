/*
* Class Name	: EC_PowerBIService
* Description	: This Class is for handling PowerBI Callouts
*/
public with sharing class EC_PowerBIService {
    // Private constructor to prevent instantiation
    private EC_PowerBIService() {

    }
    
	/*
    * Method Name	: getAuthToken
    * Description	: This Method gets Authorization Token for PowerBI
    * Request 		: String, String, String
    * Response		: HttpResponse
    */    
    public static HttpResponse getAuthToken(String endPoint, String requestBody, String contentType) {
        System.debug('>>> EC_PowerBIService.getAuthToken() : endPoint- '+endPoint+
                        ' requestBody- '+requestBody+' contentType- '+contentType);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        request.setEndpoint(endPoint);
        request.setMethod(Label.EC_POST);
        request.setHeader(Label.EC_CONTENT_TYPE, contentType);
        request.setBody(requestBody);
        request.setTimeout(EC_Constants.TIMEOUT);
        
        response = http.send(request);
        System.debug(response.getHeaderKeys());
        System.debug('<<< EC_PowerBIService.getAuthToken() : response- '+response);
        
        return response;
    }
    
    /*
    * Method Name	: getDataSet
    * Description	: This Method gets DataSets for PowerBI
    * Request 		: String, String
    * Response		: HttpResponse
    */
    public static HttpResponse getDataSet(String accessToken, String PBIDataSetURL) {
        System.debug('>>> EC_PowerBIService.getDataSet()');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        request.setMethod(Label.EC_GET);
        request.setHeader(EC_Constants.AUTHORIZATION,'Bearer '+accessToken);
        request.setEndpoint(PBIDataSetURL);
        request.setTimeout(EC_Constants.TIMEOUT);
        response = http.send(request);
        System.debug('<<< EC_PowerBIService.getDataSet() : response- '+response);

        return response;
    }

    /*
    * Method Name	: getPBIEmbedToken
    * Description	: This Method gets Embedded Dashboard Token for PowerBI
    * Request 		: String, String, String
    * Response		: HttpResponse
    */
    public static HttpResponse getPBIEmbedToken(String requestBody, String finalTokenURL, String accessToken) {
        System.debug('>>> EC_PowerBIService.getPBIEmbedToken()');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        request.setBody(requestBody);
        request.setMethod(Label.EC_POST);
        request.setEndpoint(finalTokenURL);
        request.setHeader(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        request.setHeader(EC_Constants.AUTHORIZATION,'Bearer '+accessToken);

        response = http.send(request);
        System.debug('<<< EC_PowerBIService.getPBIEmbedToken() : response- '+response);

        return response;
    }
    
}