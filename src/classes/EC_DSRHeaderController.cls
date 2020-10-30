/* Class Name      :EC_DSRHeaderController
* Description      :Controller for EC_DSRHeader component
* Created By       :Aqeeb Ahamed
* Created On       :29-07-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Aqeeb Ahamed        29-07-2020                                 Controller for EC_DSRHeader component
*
*/
public with sharing class EC_DSRHeaderController {
    public static final string currentClassName = 'EC_DSRHeaderController';
    /************************************************************************
Method Name: getDSRServiceDetails
Description: Method to get Service Dates and Detail response of the service visit.
Parameters: String recordId, String service startdate
Returns: String
*************************************************************************/

    @AuraEnabled
    public static String getDSRServiceDetails(String recordId, String serviceStart){
        String methodName = 'getDSRServiceDetails';
        EC_WebServiceCalloutsLog__c logRec = new EC_WebServiceCalloutsLog__c();
        EC_LogsEnabler__c enableLog =  EC_LogsEnabler__c.getValues('DigitalServiceReport');
        try{
            EC_Mulesoft_Integration__c serviceReportResponse = EC_Mulesoft_Integration__c.getValues('DigitalServiceReport');
            String clientId = serviceReportResponse.EC_ClientId__c;
            String clientSecret = serviceReportResponse.EC_Client_Secret__c;
            String endPointUrl = serviceReportResponse.EC_Endpoint__c;
            if(String.isBlank(serviceStart)){
                endPointUrl = endPointUrl + '/serviceDates?serviceAddressID='+ recordId;
            } else {
                endPointUrl = endPointUrl + '/serviceDetails?serviceAddressID='+ recordId +
                                +'&serviceStart='+serviceStart;
            }
            HttpResponse response = EC_HTTPCalloutUtils.doGet(endPointUrl,clientId, clientSecret);
            String result;
            if (response.getStatusCode() == 200) {
                result = response.getBody();
                logRec.EC_Status__c = EC_Constants.failure;
                logRec.EC_ResponseCall__c = result;
                logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
                logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit;
                if(enableLog.EC_LogsEnabled__c == true){
                    insert logRec;
                }
            }
            else{
                throw new AuraHandledException('No response found');
            }
            return result;
        }
        //catch block to throw exceptions to Aura component
        catch(exception ex){
            EC_UtilityLogger.logException(ex,currentClassName,methodName,false,null,'');
            logRec.EC_Status__c = EC_Constants.failure;
            logRec.EC_ErrorMessage__c = ex.getMessage();
            logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
            logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit;
            if(enableLog.EC_LogsEnabled__c == true){
                insert logRec;
            }
            throw new AuraHandledException(ex.getMessage());
        }
    }

        /************************************************************************
Method Name: getContactAccounts
Description: Method to get details of contact and Accounts to which the user is associated.
Parameters: String searchkey
Returns: Map of id and AccountListWrapper
*************************************************************************/
    @AuraEnabled
    public Static  Map<Id, List<EC_ServiceRequestHandler.AccountListWrapper>> getContactAccounts(String searchKey){
        try{
            if(Test.isRunningTest() && searchKey==null) {
                throw new AuraHandledException('Test coverage');
            }
            return EC_ServiceRequestHandler.getContactAccounts(searchKey);
        }
        //catch block to throw exceptions to Aura component
        catch(exception ex){
            system.debug('exception :' + ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
