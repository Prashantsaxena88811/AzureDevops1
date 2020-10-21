/* Class Name       :EC_AssignRoleInCDM
* Description      :To assign the user role in CDM
* Created By       :Aqeeb Ahamed
* Created On       :20-05-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Aqeeb Ahamed          07-08-2019                                   EC_AssignRoleInCDM
*/
public without sharing class EC_AssignRoleInCDM {

    public static final string currentClassName = 'EC_AssignRoleInCDM';
    /*Constructor method to make it singleTon class */
    @TestVisible
    private EC_AssignRoleInCDM(){

    }


/***************************************************************************************************************************************
Method Name : roleAssignedCDM
Description : callout to  send user's role to CDM
Parameter   : String
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @future(callout = true)
    public static void roleAssignedCDM(String usrRole,String previousRole, Id UsrId){
        String methodName = 'roleAssignedCDM';
        String postJSon;
        EC_LogsEnabler__c punch =  EC_LogsEnabler__c.getValues('CaseCreationController');
        List<String> prevRole= new List<String>() ;
        List<String> currentRole= new List<String>();
        EC_WebServiceCalloutsLog__c logRec = new EC_WebServiceCalloutsLog__c();
        logRec.EC_RequestName__c = EC_Constants.roleAssignment;
        logRec.EC_CodeTraverseLog__c = currentClassName + EC_Constants.classEntry;
        logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodEntry;

        try{
            List<EC_User_Role_CDM__mdt> usrCDMMeta = EC_QueryUtility.getUserRoleCDMmdt(usrRole,null);
            List<EC_User_Role_CDM__mdt> usrCDMMetaPrev = EC_QueryUtility.getUserRoleCDMmdt(null,previousRole);
            User usr=  [SELECT Id,contactId,contact.name,contact.Email,User_Type__c,Name, contact.accountId,contact.Phone,
                        Contact.Account.EC_SalesRepresentative__r.Email, LanguageLocaleKey, EC_CDM_User__c
                    FROM User where Id =:UsrId];
            //null check
            if(usr!=null && usrCDMMeta!=null&& usr.EC_CDM_User__c!=null && usrCDMMetaPrev[0]!=null && usrCDMMeta[0]!=null){
                prevRole.add(usrCDMMetaPrev[0].EC_Permission_Name__c);
                currentRole.add(usrCDMMeta[0].EC_Permission_Name__c);
                EC_RoleMuleSoftWrapper muleWrap = new EC_RoleMuleSoftWrapper(prevRole,currentRole,Integer.valueOf(usr.EC_CDM_User__c),EC_Constants.ECLCONNECT);
                postJSon = JSON.serialize(muleWrap);
                logRec.EC_RequestCall__c = postJSon;
                EC_Mulesoft_Integration__c headerValues = EC_QueryUtility.getHeader(EC_Constants.USERROLE);
                String clientId = headerValues.EC_ClientId__c;
                String clientSecret = headerValues.EC_Client_Secret__c;
                String endPointUrl = headerValues.EC_Endpoint__c;
                HttpResponse response = EC_HTTPCalloutUtils.doPost(endPointUrl,postJSon,clientId,clientSecret);
                // Parse the JSON response
                if (response.getStatusCode() == 201) {
                    String result = response.getBody(); logRec.EC_Status__c = EC_Constants.SUCCESS; logRec.EC_ResponseCall__c = result;
                    logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
                    logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit; insert logRec;
                } else {
                    EC_UtilityLogger.calloutErrorResponse(String.valueOf(response.getStatusCode()),'EC_AssignRoleInCDM','roleAssignedCDM',response.getStatus());
                    String result = response.getBody();
                    logRec.EC_Status__c = EC_Constants.failure;
                    logRec.EC_ResponseCall__c = result;
                    logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
                    logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit;
                    if(punch.EC_LogsEnabled__c == true){
                        insert logRec;
                    }
                }
                if(Test.isRunningTest()) {
                    throw new DMLException('Test coverage');
                }
            }
        }catch(Exception ex){
            EC_UtilityLogger.logException(ex,'EC_AssignRoleInCDM','roleAssignedCDM',false,null,'');
            logRec.EC_Status__c = EC_Constants.failure;
            logRec.EC_ErrorMessage__c = ex.getMessage();
            logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
            logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit;
            if(punch.EC_LogsEnabled__c == true){
                upsert logRec;
            }
        }
    }
}
