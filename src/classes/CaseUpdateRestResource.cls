/**************************************************************************************************************
** Name             : caseUpdateRestResource
** Description      : This API class is exposing to ServiceNow to update resolved/unresolved cases in SFDC
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Graytitude Team                   Sep-2020                    1.0                          Created    
**************************************************************************************************************/
@RestResource(urlMapping='/caseapi/*') //
global with sharing class CaseUpdateRestResource {
    /***************************************************************************************************************************************
Method Name : doPatch
Description : This method is for updating the status of cases based on request body and also will validate the request body.
Return type : void
Author      : Graytitude
*************************************************************************************************************************************/
    @HttpPatch
    global static void doPatch(String casenumber, String status, String resolutionnotes,String worknotes,String description,String connectgroup) {
        RestResponse res = RestContext.response;
        res.headers.put('Content-Type','application/json');
        EC_WebServiceCalloutsLog__c logRec;
        Integration_Log__c integraionLogRec;
        if(Case.sObjectType.getDescribe().isAccessible()) {
            list<case> cases = [select id,Integration_Status__c from case where casenumber=:casenumber limit 1];
            Case objCase = new Case();
            if(String.isBlank(casenumber)) {            
                res.statusCode = EC_Constants.statusCode400; 
                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponseBody(new Error(EC_Constants.errorTypeBadRequest,EC_Constants.missingCaseNumberMessage),EC_Constants.statusFailure)));
            }
            else{
                if(!cases.isEmpty()){
                    String caseid = cases[0].Id;
                    Boolean isError = false;
                    try{
                        objCase.Id = caseid;
                        String errorMessage = validateRequestParamsPatch(casenumber,status,resolutionnotes,worknotes,description,connectgroup);
                        if(!String.isBlank(errorMessage)){
                            isError=true;
                            res.statusCode = EC_Constants.statusCode400;
                            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponseBody(new Error(EC_Constants.errorTypeBadRequest,errorMessage),EC_Constants.statusFailure)));
                        }
                        else{
                            if(cases[0].Integration_Status__c==EC_Constants.receivedResolved || cases[0].Integration_Status__c==EC_Constants.receivedUnResolved){
                                res.statusCode = EC_Constants.statusCode400;
                                res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponseBody(new Error(EC_Constants.errorTypeBadRequest,EC_Constants.casebeenUpdatedMessage),EC_Constants.statusFailure)));
                                isError = true;
                            }
                            else{
                                if(status=='Resolved'){
                                    objCase.status = status;
                                    objCase.Integration_Status__c = EC_Constants.receivedResolved;//'Received Resolved';
                                    objCase.Resolution_Category__c = EC_Constants.resolutionCategory; //'Provide Training or Documentation';
                                    objCase.Resolution_Description__c = resolutionnotes;
                                }
                                else{
                                    if(Group.sObjectType.getDescribe().isAccessible()){
                                        list<Group> groups = [SELECT Id FROM Group where DeveloperName=:connectgroup];
                                        if(!groups.isEmpty()){
                                            Id groupId = groups[0].Id;
                                            list<CaseComment> caseCmnts = new list<CaseComment>();
                                            objCase.status = EC_Constants.statusNew;
                                            objCase.Integration_Status__c = EC_Constants.receivedUnResolved;
                                            objCase.OwnerId = groupId;
                                            if(CaseComment.sObjectType.getDescribe().isAccessible()){
                                                if(!String.isBlank(worknotes)) {
                                                    CaseComment cmnt = new CaseComment();
                                                    cmnt.parentid = caseid;
                                                    cmnt.CommentBody = worknotes;
                                                    caseCmnts.add(cmnt);
                                                }
                                                if(!String.isBlank(description)) {
                                                    CaseComment cmnt = new CaseComment();
                                                    cmnt.parentid = caseid;
                                                    cmnt.CommentBody = description;
                                                    caseCmnts.add(cmnt);
                                                }
                                                if(!caseCmnts.isEmpty()){
                                                    insert caseCmnts;
                                                } 
                                            }
                                        }
                                        else{
                                            res.statusCode = EC_Constants.statusCode400;
                                            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponseBody(new Error(EC_Constants.errorTypeBadRequest,EC_Constants.invalidGroupMessage),EC_Constants.statusFailure)));
                                            isError = true;
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(isError){
                            logRec = EC_Utility.logCallouts('Salesforce Case Update - '+casenumber, String.valueOf(RestContext.request), String.valueOf(res), null, EC_Constants.FAIL);
                            integraionLogRec = EC_Utility.logIntegrationError(String.valueOf(res),EC_Constants.salesforceCaseUpdate, EC_Constants.integrationTypeMuletoSFDC,
                                                                              NULL, logRec.Id, 0, 'Salesforce case update error', casenumber);
                            objCase.Integration_Error_Log__c = integraionLogRec.id;
                        }
                        else{
                            res.statusCode = EC_Constants.statusCode200;
                            res.responseBody = Blob.valueOf('{"status" : "Success", "message" : "Case is updated successfully.","sfcasenumber":"'+casenumber+'"}');
                        }
                        update objCase;
                    }
                    catch (Exception e) {
                        res.statusCode = EC_Constants.statusCode500;
                        res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponseBody(new Error('Internal server error',e.getMessage()),EC_Constants.statusFailure)));
                        
                        if(!String.isBlank(caseid)){
                            objCase.Id = caseid;
                            logRec = EC_Utility.logCallouts('Salesforce Case Update - '+casenumber, String.valueOf(RestContext.request), String.valueOf(res), null, EC_Constants.FAIL);
                            integraionLogRec = EC_Utility.logIntegrationError(String.valueOf(res),EC_Constants.salesforceCaseUpdate, EC_Constants.integrationTypeMuletoSFDC,
                                                                              NULL, logRec.Id, 0, 'Salesforce case update error', casenumber);
                            
                            objCase.Integration_Error_Log__c = integraionLogRec.id;
                            update objCase;
                        }
                    } 
                } 
                else{
                    res.statusCode = EC_Constants.statusCode400;
                    res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponseBody(new Error(EC_Constants.errorTypeBadRequest,EC_Constants.invalidCaseNumberMessage),EC_Constants.statusFailure)));
                }
            }
        }
    }
    public static String validateRequestParamsPatch(String casenumber, String status, String resolutionnotes,String worknotes,String description,String connectgroup){
        String errorMessage='';
        if(status!='Resolved' && !String.isBlank(status)){
            errorMessage = EC_Constants.invalidCaseStatusMessage;
        }
        else if(status=='Resolved' && String.isBlank(resolutionnotes)){
            errorMessage = EC_Constants.missingResolutionnoteMessage;
        }
        else if(!String.isBlank(connectgroup) && !String.isBlank(status)){
            errorMessage = EC_Constants.invalidRequestBodyMessage;
        }
        else if(String.isBlank(connectgroup) && String.isBlank(status)){
            errorMessage = EC_Constants.missingRequiredParamsMessage;
        }
        return errorMessage;
    }
    public class ErrorResponseBody{
        public Error error;
        public string status;
        public ErrorResponseBody(Error error,string status){
            this.error = error;
            this.status = status;
        }
    }
    public class Error {
        public String message;
        public String details;
        public Error(String details,String message) {
            this.message = message;
            this.details = details;
        }
    }
}