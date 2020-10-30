/**************************************************************************************************************
** Name             : CaseCreationQueueable
** Description      : This class is used for callouts for Case Creation
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Graytitude Team                   Sep-2020                    1.0                          Created    
**************************************************************************************************************/
public without sharing class CaseCreationQueueable implements Queueable, Database.AllowsCallouts{
    private String accessToken;
    private list<case> updatedCases = new list<case>();
    private list<case> callOutCases;
    private map<String,Decimal> retryCounterMap = new map<String,Decimal>();
    private static final String requestedFieldsQueryStr = 'Account.EC_Division__c,First_Name__c,Last_Name__c,Company_Name__c,Account.Name, CaseNumber, Account.ShippingCity, Contact_Email_Formula__c, Contact.Name, Contact_Phone_Formula__c, Account.ShippingCountry, Description, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet, Sub_Category__c, Subject';//String.join(fields,',');
    private static Integration_Settings__mdt integrationSettings = [SELECT Id, MasterLabel, Retry_Limit__c,Retry_Interval__c FROM Integration_Settings__mdt where MasterLabel='ServiceNow Retry Limit' limit 1];
    
    public CaseCreationQueueable(list<String> callOutCaseIds,String accessToken){  
        this.accessToken = accessToken;
        if(Case.sObjectType.getDescribe().isAccessible()) {
            String queryStr = String.escapeSingleQuotes('select '+requestedFieldsQueryStr+' from case where id in :callOutCaseIds');
            callOutCases = Database.query(queryStr);
        }
    }
    public void execute(QueueableContext context) {
        Decimal retryMaxCount = integrationSettings.Retry_Limit__c;
        list<Id> retryCases = new list<Id>();
        Boolean isChatbotuser = (userinfo.getName()=='Platform Integration User');
        if(Case.sObjectType.getDescribe().isAccessible() || isChatbotuser) {
            try{ 
                for(case c:callOutCases){
                    try{
                        String requestBody = getRequestBody(c);
                        HttpResponse response = doPostCallToSeviceNow(requestBody,c);
                        EC_WebServiceCalloutsLog__c logRec;
                        Integration_Log__c integraionLogRec;
                        if(response!=null){
                            String statusCode = String.valueOf(response.getStatusCode());
                            if(statusCode==String.valueOf(EC_Constants.statusCode401) && !String.isBlank(accessToken)){
                                accessToken = null;
                                doPostCallToSeviceNow(requestBody,c);
                            }
                            if(label.ServiceNow_Exceptions_Retry_Status_Codes.contains(statusCode)){
                                Case updatedCase = new Case();
                                updatedCase.Id = c.Id;
                                if(statusCode=='200' || statusCode=='201'){
                                    updatedCase.Integration_Status__c  = EC_Constants.submittedSuccess;
                                    CaseCreationQueueable.CreateCaseResponse caseResponse = (CaseCreationQueueable.CreateCaseResponse)JSON.deserialize(response.getBody(),CaseCreationQueueable.CreateCaseResponse.class);
                                    updatedCase.External_Id__c = caseResponse.result.case_number;
                                    updatedCase.External_Source_System__c = 'ServiceNow';
                                }
                                else{
                                    updatedCase.Integration_Status__c  = EC_Constants.submittedFailure;
                                    logRec = EC_Utility.logCallouts('ServiceNow Case Create - '+c.CaseNumber, requestBody, String.valueOf(response), null, EC_Constants.FAIL);
                                    integraionLogRec = EC_Utility.logIntegrationError(String.valueOf(response),EC_Constants.serviceNowCaseCreate, 'SFDC_To_MULESOFT(ServiceNow Case Creation)',
                                                                                      NULL, logRec.Id, 0, 'ERROR', c.CaseNumber);
                                    updatedCase.Integration_Error_Log__c = integraionLogRec.id;
                                }
                                updatedCases.add(updatedCase);
                            }
                            else{
                                createRetryCounterMap(new list<String>{c.CaseNumber});
                                
                                if(retryCounterMap.get(c.CaseNumber)<retryMaxCount || retryCounterMap.get(c.CaseNumber)==null){
                                    logRec = EC_Utility.logCallouts('ServiceNow Case Create - '+c.CaseNumber, requestBody, String.valueOf(response), null, EC_Constants.FAIL);
                                    integraionLogRec = EC_Utility.logIntegrationError(String.valueOf(response),EC_Constants.serviceNowCaseCreate, 'SFDC_To_MULESOFT(ServiceNow Case Creation)',
                                                                                      NULL, logRec.Id, 0, 'ERROR', c.CaseNumber);
                                    retryCases.add(c.id);
                                    Case updatedCase = new Case();
                                    updatedCase.Id = c.Id;
                                    updatedCase.Integration_Error_Log__c = integraionLogRec.id;
                                    updatedCases.add(updatedCase);
                                }
                                else{
                                    Case updatedCase = new Case();
                                    updatedCase.Id = c.Id;
                                    updatedCase.Integration_Status__c = EC_Constants.submittedFailure;
                                    updatedCases.add(updatedCase);
                                }
                            }
                        }
                    }
                    catch(Exception e){
                        System.debug('Error message - '+e.getMessage());
                        System.debug('Stack Trace - '+e.getStackTraceString());
                        Case updatedCase = new Case();
                        updatedCase.Id = c.Id;
                        updatedCase.Integration_Status__c = EC_Constants.submittedFailure;
                        updatedCases.add(updatedCase);
                    }
                }
                if(!updatedCases.IsEmpty()){
                    update updatedCases;
                }
                scheduleJobForCaseCreationRetry(retryCases);
            }
            catch(Exception e){
                System.debug('Error message - '+e.getMessage());
                System.debug('Stack Trace - '+e.getStackTraceString());
                
                //Log Exception on the Exception Framework
                EC_UtilityLogger.logException(e,'CaseCreationQueueable','CaseCreationQueueable-->execute',false,null,'');
            }
        }
    }
    
    /***************************************************************************************************************************************
Method Name : doPostCallToSeviceNow
Description : This method is for make a callout to ServiceNow.
Return type : HttpResponse
Author      : Graytitude
*************************************************************************************************************************************/    
    public HttpResponse doPostCallToSeviceNow(String reqBody,Case c){
        try{
            if(accessToken==null){
                accessToken = getAccessTokenForAPICall();
            } 
            EC_Mulesoft_Integration__c callOutAPIDetails = EC_QueryUtility.getHeader('ServiceNow Case Create'); //why would the token be null?
            HttpResponse response;
            HttpRequest request = new HttpRequest();
            Http http = new Http();
            request.setMethod('POST');
            request.setEndpoint(callOutAPIDetails.EC_Endpoint__c);
            request.setHeader('client_id', callOutAPIDetails.EC_ClientId__c);
            request.setHeader('client_secret', callOutAPIDetails.EC_Client_Secret__c);
            request.setHeader('content-type', 'application/json');
            request.setHeader('Authorization', 'Bearer '+accessToken);
            request.setBody(reqBody);
            response = http.send(request); 
            return response;
        }
        catch(exception e){
            Case updatedCase = new Case();
            updatedCase.Id = c.Id;
            updatedCase.Integration_Status__c = 'Submitted Failure';
            updatedCases.add(updatedCase);
        }
        return null;
    }
    /***************************************************************************************************************************************
Method Name : getAccessTokenForAPICall
Description : This method is for getting token from mulesoft system.
Return type : String
Author      : Graytitude
*************************************************************************************************************************************/
    public string getAccessTokenForAPICall(){ 
        EC_Mulesoft_Integration__c callOutAPIDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        EC_Mulesoft_Integration__c callOutAPIScope = EC_QueryUtility.getHeader('ServiceNow Scope');
        String hashString = '1000' + Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS');
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        HttpResponse response;
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setHeader('content-type', 'multipart/form-data; boundary=----'+hexDigest+'');
        request.setMethod('POST');
        request.setEndpoint(callOutAPIDetails.EC_Endpoint__c);
        String requestBody = '------'+hexDigest+'\r\nContent-Disposition: form-data; name=\"client_id\"\r\n\r\n'+callOutAPIDetails.EC_ClientId__c+'\r\n------'+hexDigest+'\r\nContent-Disposition: form-data; name=\"client_secret\"\r\n\r\n'+callOutAPIDetails.EC_Client_Secret__c+'\r\n------'+hexDigest+'\r\nContent-Disposition: form-data; name=\"grant_type\"\r\n\r\nclient_credentials\r\n------'+hexDigest+'\r\nContent-Disposition: form-data; name=\"scope\"\r\n\r\n'+callOutAPIScope.EC_Endpoint__c+'\r\n------'+hexDigest+'--';
        request.setBody(requestBody);
        response = http.send(request);
        system.debug(response.getBody());
        map<String,object> respMap = (map<String,object>)JSON.deserializeUntyped(response.getBody());
        String token = String.valueOf(respMap.get('access_token'));
        if(!String.isBlank(token)){
            return token;
        }
        
        return null;
    }
    /***************************************************************************************************************************************
Method Name : requestBodyGenerator
Description : This method is for generating the request body to for callout.
Return type : String
Author      : Graytitude
*************************************************************************************************************************************/
    public String getRequestBody(Case c){
        map<String,Object> reqBodyMap = new map<String,Object>();
        CaseCreationWrapper wrapper = new CaseCreationWrapper();
        
        String accountDivision = String.isBlank(c.AccountId)?'':c.Account.EC_Division__c; 
        CaseCreationWrapper.CaseCreationValuesWrapper accountDivisionProps = wrapper.accountDivisionProps;
        if(accountDivision!=null && accountDivisionProps.isTrim && accountDivision.length()>accountDivisionProps.maxLength){
            reqBodyMap.put(accountDivisionProps.fieldName,accountDivision.substring(0,accountDivisionProps.maxLength));
        }
        else{
            reqBodyMap.put(accountDivisionProps.fieldName,accountDivision);
        }
        
        String accountName = String.isBlank(c.AccountId)?c.Company_Name__c:c.Account.Name; 
        CaseCreationWrapper.CaseCreationValuesWrapper accountNameProps = wrapper.accountNameProps;
        if(accountName!=null && accountNameProps.isTrim && accountName.length()>accountNameProps.maxLength){
            reqBodyMap.put(accountNameProps.fieldName,accountName.substring(0,accountNameProps.maxLength));
        }
        else{
            reqBodyMap.put(accountNameProps.fieldName,accountName);
        }
        
        String caseNumber  = c.CaseNumber; 
        CaseCreationWrapper.CaseCreationValuesWrapper caseNumberProps = wrapper.caseNumberProps;
        if(caseNumber!=null && caseNumberProps.isTrim && caseNumber.length()>caseNumberProps.maxLength){
            reqBodyMap.put(caseNumberProps.fieldName,caseNumber.substring(0,caseNumberProps.maxLength));
        }
        else{
            reqBodyMap.put(caseNumberProps.fieldName,caseNumber);
        }
        
        String cityName  = String.isBlank(c.AccountId)?'':c.Account.ShippingCity; 
        CaseCreationWrapper.CaseCreationValuesWrapper cityProps = wrapper.cityProps;
        if(cityName!=null && cityProps.isTrim && cityName.length()>cityProps.maxLength){
            reqBodyMap.put(cityProps.fieldName,cityName.substring(0,cityProps.maxLength));
        }
        else{
            reqBodyMap.put(cityProps.fieldName,cityName);
        }
        
        String contactEmail  = c.Contact_Email_Formula__c; 
        CaseCreationWrapper.CaseCreationValuesWrapper contactEmailProps = wrapper.contactEmailProps;
        if(contactEmail!=null && contactEmailProps.isTrim && contactEmail.length()>contactEmailProps.maxLength){
            reqBodyMap.put(contactEmailProps.fieldName,contactEmail.substring(0,contactEmailProps.maxLength));
        }
        else{
            reqBodyMap.put(contactEmailProps.fieldName,contactEmail);
        }
        
        String contactName  = String.isBlank(c.ContactId)?c.First_Name__c+' '+c.Last_Name__c:c.contact.Name; 
        CaseCreationWrapper.CaseCreationValuesWrapper contactNameProps = wrapper.contactNameProps;
        if(contactName!=null && contactNameProps.isTrim && contactName.length()>contactNameProps.maxLength){
            reqBodyMap.put(contactNameProps.fieldName,contactName.substring(0,contactNameProps.maxLength));
        }
        else{
            reqBodyMap.put(contactNameProps.fieldName,contactName);
        }
        
        String contactPhone  = c.Contact_Phone_Formula__c; 
        
        CaseCreationWrapper.CaseCreationValuesWrapper contactPhoneProps = wrapper.contactPhoneProps;
        if(contactPhone!=null && contactPhoneProps.isTrim && contactPhone.length()>contactPhoneProps.maxLength){
            reqBodyMap.put(contactPhoneProps.fieldName,contactPhone.substring(0,contactPhoneProps.maxLength));
        }
        else{
            reqBodyMap.put(contactPhoneProps.fieldName,contactPhone);
        }
        
        String country  = String.isBlank(c.AccountId)?'':c.Account.ShippingCountry; 
        CaseCreationWrapper.CaseCreationValuesWrapper countryProps = wrapper.countryProps;
        if(country!=null && countryProps.isTrim && country.length()>countryProps.maxLength){
            reqBodyMap.put(countryProps.fieldName,country.substring(0,countryProps.maxLength));
        }
        else{
            reqBodyMap.put(countryProps.fieldName,country);
        }
        
        String description  = c.Description; 
        CaseCreationWrapper.CaseCreationValuesWrapper descriptionProps = wrapper.descriptionProps;
        if(description!=null && descriptionProps.isTrim && description.length()>descriptionProps.maxLength){
            reqBodyMap.put(descriptionProps.fieldName,description.substring(0,descriptionProps.maxLength));
        }
        else{
            reqBodyMap.put(descriptionProps.fieldName,description);
        }
        
        String postalCode  = String.isBlank(c.AccountId)?'':c.Account.ShippingPostalCode; 
        CaseCreationWrapper.CaseCreationValuesWrapper postalCodeProps = wrapper.postalCodeProps;
        if(postalCode!=null && postalCodeProps.isTrim && postalCode.length()>postalCodeProps.maxLength){
            reqBodyMap.put(postalCodeProps.fieldName,postalCode.substring(0,postalCodeProps.maxLength));
        }
        else{
            reqBodyMap.put(postalCodeProps.fieldName,postalCode);
        }
        
        String state  = String.isBlank(c.AccountId)?'':c.Account.ShippingState; 
        CaseCreationWrapper.CaseCreationValuesWrapper stateProps = wrapper.stateProps;
        if(state!=null && stateProps.isTrim && state.length()>stateProps.maxLength){
            reqBodyMap.put(stateProps.fieldName,state.substring(0,stateProps.maxLength));
        }
        else{
            reqBodyMap.put(stateProps.fieldName,state);
        }
        
        String street  = String.isBlank(c.AccountId)?'':c.Account.ShippingStreet; 
        CaseCreationWrapper.CaseCreationValuesWrapper streetProps = wrapper.streetProps;
        if(street!=null && streetProps.isTrim && street.length()>streetProps.maxLength){
            reqBodyMap.put(streetProps.fieldName,street.substring(0,streetProps.maxLength));
        }
        else{
            reqBodyMap.put(streetProps.fieldName,street);
        }
        
        String subcategory  = c.Sub_Category__c; 
        CaseCreationWrapper.CaseCreationValuesWrapper subcategoryProps = wrapper.subcategoryProps;
        if(subcategory!=null && subcategoryProps.isTrim && subcategory.length()>subcategoryProps.maxLength){
            reqBodyMap.put(subcategoryProps.fieldName,subcategory.substring(0,subcategoryProps.maxLength));
        }
        else{
            reqBodyMap.put(subcategoryProps.fieldName,subcategory);
        }
        
        String subject  = c.Subject; 
        CaseCreationWrapper.CaseCreationValuesWrapper subjectProps = wrapper.subjectProps;
        if(subject!=null && subjectProps.isTrim && subject.length()>subjectProps.maxLength){
            reqBodyMap.put(subjectProps.fieldName,subject.substring(0,subjectProps.maxLength));
        }
        else{
            reqBodyMap.put(subjectProps.fieldName,subject);
        }
        
        return JSON.serializePretty(reqBodyMap,true); 
    }
    
    /***************************************************************************************************************************************
Method Name : createRetryCounterMap
Description : This method is for retry counter details.
Return type : void
Author      : Graytitude
*************************************************************************************************************************************/
    private void createRetryCounterMap(list<String> callOutCaseIds){
        for(Integration_Log__c intlog:[SELECT Id,identifier__c,Retry_Counter__c from Integration_Log__c  where identifier__c in :callOutCaseIds]){
            retryCounterMap.put(intlog.identifier__c,intlog.Retry_Counter__c); //this is incorrect. See comments where this is called
        }
    } 
    /***************************************************************************************************************************************
Method Name : scheduleJobForCaseCreationRetry
Description : This method is for making callout after certain time Intervals.
Return type : void
Author      : Graytitude
*************************************************************************************************************************************/
    private void scheduleJobForCaseCreationRetry(list<Id> retryCases){
        Decimal retryInterval = integrationSettings.Retry_Interval__c;
        if(!retryCases.IsEmpty()){ 
            DateTime dt = Datetime.now();
            Integer day = dt.Day();
            string mnthstr = dt.format('MMM');
            //Integer month = dt.Month(); 
            Integer year = dt.Year(); 
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute()); 
            //Adding the interval of 10 secs
            String ss = String.valueOf(Datetime.now().second() + retryInterval);
            
            //construct cron expression
            String nextjobRun = ss+' '+min+' '+hour+' '+day+' '+mnthstr+' ? '+year;
            CaseCreationSchedulable s = new CaseCreationSchedulable(retryCases,accessToken);
            System.schedule('CaseCreationRetry ' + Datetime.now(), nextjobRun, s);
            //System.enqueueJob(new CaseCreationQueueable(retryCases));
        }
    } 
    
    public class CreateCaseResponse{
        public Result result {get;set;} 
    }
    public class Result {
        public String case_number {get;set;} 
        public String state {get;set;} 
    }
}