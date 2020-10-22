/*******************************************************************************************************************
Apex Class Name     : EC_HTTPCalloutUtils
Created Date        : 18 July 2019
Description         : Generic Class to make an api call to external system.
* Developer                        Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Ayusha Patnaik                  18/07/2019              Original Version
*************************************************************************************************************************/
public with sharing class EC_HTTPCalloutUtils {


    /************************************************************************
Method Name: doGet
Description: Method to make get api call.
Parameters: String url
Returns: HttpResponse
*************************************************************************/
    public static HttpResponse doGet(String url) {
        return doCallout(Label.EC_GET, url, null,null,null);
    }

    /************************************************************************
Method Name: doPost
Description: Method to make post api call.
Parameters: String url, String requestBody
Returns: HttpResponse
*************************************************************************/
    public static HttpResponse doPost(String url, String requestBody, String clientId, String clientSecret) {
        return doCallout(Label.EC_POST, url, requestBody,clientId,clientSecret);
    }

    /************************************************************************
Method Name: doCallout
Description: Method to make all callouts.
Parameters: String requestType, String url, String requestBody
Returns: HttpResponse
*************************************************************************/
    public static HttpResponse doCallout(String requestType, String url, String requestBody, String clientId, String clientSecret) {
        Integer timeout = Integer.valueOf(System.Label.EC_TIMEOUT);
        HttpResponse response;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(requestType);
        if(requestType == Label.EC_POST) {
            request.setHeader(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
            request.setHeader('client_id', clientId);
            request.setHeader('client_secret', clientSecret);
            request.setBody(requestBody);
        }
        Http http = new Http();
        request.setTimeout(timeout);
        return http.send(request);
    }
}