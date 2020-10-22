global class EC_AthenaOrders {

     public static HTTPResponse respond(String jsonBody){
        String token = OAuthToken();
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        EC_Custom_URL_Settings__c customURL = EC_Custom_URL_Settings__c.getValues('Athena_Orders_Cloudhub');
        String url = customURL.custom_url__c;
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        req.setHeader('Authorization', 'Bearer '+token );
        response.setHeader('Content-Type', 'application/json; charset=utf-8');
	    req.setBody(jsonBody);
		
       	try {
        response = http.send(req);
            
        } catch(System.CalloutException e) 
        {
        System.debug('respond Callout error: '+ e);
        }
        return response; 
    }

    public static String OAuthToken () {
        String token = '';
        HttpResponse response = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        EC_Custom_URL_Settings__c customURL = EC_Custom_URL_Settings__c.getValues('Microsoft OAuth Token');
        String url = customURL.custom_url__c;  
        EC_Athena_Settings__c grantType = EC_Athena_Settings__c.getValues('GrantType');
        EC_Athena_Settings__c clientId = EC_Athena_Settings__c.getValues('ClientId');
        EC_Athena_Settings__c clientSecret = EC_Athena_Settings__c.getValues('ClientSecret');
        EC_Athena_Settings__c resourceSettings = EC_Athena_Settings__c.getValues('Resource');
        String grant_type = grantType.value__c;
        String client_id = clientId.value__c;  
        String client_secret = clientSecret.value__c;  
        String resource = resourceSettings.value__c;  
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        PageReference ref = new PageReference(url);
        // Populate parameters
        Map<String, String> params = new Map<String, String>();
        params.put('grant_type',grant_type);
        params.put('Client_id',client_id);
        params.put('Client_secret',client_secret);
        params.put('resource',resource);
        ref.getParameters().putAll(params);
        Url finalUrl = new Url(ref.getUrl());
        // fully url-encoded query string - set the body of http request object
        req.setBody(finalUrl.getQuery());
        response.setHeader('Content-Type', 'application/json; charset=utf-8');
        try {
        	response = http.send(req);
        	if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                token = (String) results.get('access_token');
            }
        } catch(System.CalloutException e) 
        {
        System.debug('OAuth Callout error: '+ e);
        }
        return token; 
    }
}