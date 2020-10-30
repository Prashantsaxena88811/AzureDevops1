/* Class Name      :EC_StagingLogger
* Description      :Exception handling class for Mulesoft Staging records.
* Created By       :Mishika Mahajan
* Created On       :10-24-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          10-24-2019                                  Exception handling class for Mulesoft Staging records.
*/
public class EC_StagingLogger{

 /***************************************************************************************************************************************
Method Name : stageLogException
Description : to insert records of EC_StagingExceptionLog__c object for capturing exception in staging classes.
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    public static void stageLogException(List<EC_StagingExceptionLog__c> stageLogWrap){
        if(stageLogWrap!=null && !stageLogWrap.isEmpty()){
            Database.insert(stageLogWrap,false);
        }
    }

 /***************************************************************************************************************************************
Method Name : logException
Description : to create instance of EC_StagingExceptionLog__c object and assigning values to the same.
Return type : EC_StagingExceptionLog__c
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    public static EC_StagingExceptionLog__c  logException(Id stageid,String userKey, String accountKey,String sourceTable ,String action,String division,String partnerFunction,String parentAccountKey, String email,
                                 String permissionCode,String exceptionMessage,String className,String methodName){
        EC_StagingExceptionLog__c stageExceptionLog = new  EC_StagingExceptionLog__c();
        stageExceptionLog.EC_MuleStageId__c = stageid;
        stageExceptionLog.EC_UserKey__c = userKey;
        stageExceptionLog.EC_Account_key__c= accountKey;
        stageExceptionLog.EC_SourceTable__c = sourceTable;
        stageExceptionLog.EC_Action__c = action;
        stageExceptionLog.EC_Division__c = division;
        stageExceptionLog.EC_PartnerFunction__c = partnerFunction;
        stageExceptionLog.EC_ParentAccountKey__c = parentAccountKey;
        stageExceptionLog.EC_Email__c = email;
        stageExceptionLog.EC_PermissionCode__c = permissionCode;
        stageExceptionLog.EC_ExceptionMessage__c = exceptionMessage;
        stageExceptionLog.EC_ClassName__c = className;
        stageExceptionLog.EC_MethodName__c = methodName;
        return stageExceptionLog;
    }
}