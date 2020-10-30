public class EC_CalloutUtility {
	public static final string endpoint = 'Endpoint';
    public static final string httpMethod = 'HttpMethod';
    
    public static HttpResponse doOrderSubmitApiCallout(String requestBody,Map<String,String> requestConfigHeader){
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        try{
            String endpoint = requestConfigHeader.get(endpoint);
            requestConfigHeader.remove(endpoint);
            String httpMethod = requestConfigHeader.get(httpMethod);
            requestConfigHeader.remove(httpMethod);
            for(String key : requestConfigHeader.keySet()){
                req.setHeader(key, requestConfigHeader.get(key));
            }
            req.setEndpoint(endpoint);
            req.setMethod(httpMethod);
            req.setBody(requestBody);
            system.debug('req::'+req);
           	res = h.send(req);
        }Catch(Exception ex){
            system.debug('Log exception here '+ ex.getMessage());
        }
        
        return res;        
    }
    
    public static String doTokenCallout(){
        try {
            Map<String,String> tokenRequestConfigMap = new Map<String,String>();
            
            for(MulesoftOrderSubmitAPIConfig__mdt orderSubmitConfig : [Select Key__c,Value__c from MulesoftOrderSubmitAPIConfig__mdt where Label = 'Token Request']){
                tokenRequestConfigMap.put(orderSubmitConfig.Key__c,orderSubmitConfig.Value__c);
            } 
            
            String endpoint = tokenRequestConfigMap.get(endpoint);
            tokenRequestConfigMap.remove(endpoint);
            String httpMethod = tokenRequestConfigMap.get(httpMethod);
            tokenRequestConfigMap.remove(httpMethod);
            
            string contentType = EC_HttpFormBuilder.GetContentType();
            system.debug(contentType);
            //string json = GetJson(request, Credentials);
            
            //  Compose the form
            string form64 = '';
            for(String key : tokenRequestConfigMap.keySet()){
                form64 += EC_HttpFormBuilder.WriteBoundary();
                form64 += EC_HttpFormBuilder.WriteBodyParameter(key, tokenRequestConfigMap.get(key));
            }
            /*
            form64 += EC_HttpFormBuilder.WriteBoundary();
            form64 += EC_HttpFormBuilder.WriteBodyParameter('grant_type', 'client_credentials');
            form64 += EC_HttpFormBuilder.WriteBoundary();
            form64 += EC_HttpFormBuilder.WriteBodyParameter('Client_id', 'c034a404-1358-42e3-9821-04b0449c425d');
            form64 += EC_HttpFormBuilder.WriteBoundary();
            form64 += EC_HttpFormBuilder.WriteBodyParameter('client_secret', '__9l.~LDb5eyo7r48_0ywdJPBcDfC55y1E');
            form64 += EC_HttpFormBuilder.WriteBoundary();
            form64 += EC_HttpFormBuilder.WriteBodyParameter('scope', 'https://nalco.microsoftonline.com/74f6179a-81c8-47cf-8131-3a854dee93fb/.default');
            */
            
            form64 += EC_HttpFormBuilder.WriteBoundary(EC_HttpFormBuilder.EndingType.CrLf);
            
            //  Compose the http request
            HttpResponse res = new HttpResponse();
            HttpRequest httpRequest = new HttpRequest();
            Http h = new Http();
            httpRequest.setEndpoint(endpoint);
            httpRequest.setHeader('content-Type', contentType);
            httpRequest.setMethod(httpMethod);
            httpRequest.setBody(form64);            
            res = h.send(httpRequest);
            
            String accessToken = '';
            Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            if(response.containsKey('access_token')){
                accessToken = String.valueOf(response.get('access_token'));
            }	            
            return accessToken;
        } catch (Exception e) {
            system.debug(e.getMessage());
            return null;
        }  
    }
}