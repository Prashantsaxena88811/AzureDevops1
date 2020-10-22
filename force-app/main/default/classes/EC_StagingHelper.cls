//EC_StagingHelper
//This is class to handle all the CDM Staging events
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//

public class EC_StagingHelper {

/***************************************************************************************************************************************
Method Name : stagingtriggerHelper
Description : Used as a helper method to the Trigger
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static void AccountHelperBeforeInsert(List<EC_Mulesoft_CDM_Staging__c> stgList){
        for(EC_Mulesoft_CDM_Staging__c stgObj:stgList){
            if(stgObj.EC_Source_Table__c == EC_Constants.ACCOUNT){
                stgObj.EC_Stage_Unique_AccNumber__c =  stgObj.EC_Origination_Account_System_Code__c +'/'+ stgObj.EC_Account_Number__c;

                if(stgObj.EC_Parent_Account_Number__c!=null && !String.isBlank(stgObj.EC_Parent_Account_Number__c) && !stgObj.EC_Parent_Account_Number__c.contains('/')){
                 stgObj.EC_Parent_Account_Number__c = stgObj.EC_Origination_Account_System_Code__c + '/' +  stgObj.EC_Parent_Account_Number__c;
                }
            }
        }
    }

    public static void stagingtriggerHelper(List<EC_Mulesoft_CDM_Staging__c> stgList, String triggerEvent){

        List<EC_Mulesoft_CDM_Staging__c> accInsert = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> accUpdate = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> accDelete = new List<EC_Mulesoft_CDM_Staging__c>();
        List<String>   accUpdatekeys = new List<String>();

        List<EC_Mulesoft_CDM_Staging__c> userInsert = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> userUpdate = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> userDelete = new List<EC_Mulesoft_CDM_Staging__c>();
        List<String> userUpdatekeys = new List<String>();
        List<String> userDeletekeys = new List<String>();


        List<EC_Mulesoft_CDM_Staging__c> contactInsert = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> contactUpdate = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> contactDelete = new List<EC_Mulesoft_CDM_Staging__c>();

        List<EC_Mulesoft_CDM_Staging__c> user_AccountInsert = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> user_AccountDelete = new List<EC_Mulesoft_CDM_Staging__c>();


        List<EC_Mulesoft_CDM_Staging__c> user_PermissionInsert = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> user_PermissionDelete = new List<EC_Mulesoft_CDM_Staging__c>();

        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Map<Id,String> muleCDMMap = new Map<Id,String>();

        for(EC_Mulesoft_CDM_Staging__c stgObj:stgList){
            if(stgObj.EC_Source_Table__c == EC_Constants.ACCOUNT){
                if(triggerEvent != 'trigger'){ 
                    stgObj.EC_Stage_Unique_AccNumber__c =  stgObj.EC_Origination_Account_System_Code__c +'/'+ stgObj.EC_Account_Number__c;

                    if(stgObj.EC_Parent_Account_Number__c!=null && !String.isBlank(stgObj.EC_Parent_Account_Number__c) && !stgObj.EC_Parent_Account_Number__c.contains('/')){
                     stgObj.EC_Parent_Account_Number__c = stgObj.EC_Origination_Account_System_Code__c + '/' +  stgObj.EC_Parent_Account_Number__c;
                    }
                }

                if(stgObj.EC_Action__c == EC_Constants.INSERTACTION){
                    System.debug('staginHelper_record:'+stgObj);
                    accInsert.add(stgObj);
                }else if (stgObj.EC_Action__c == EC_Constants.UPDATEACTION){
                    if(!accUpdatekeys.contains(stgObj.EC_Account_Key__c)){
                        accUpdate.add(stgObj);
                        accUpdatekeys.add(stgObj.EC_Account_Key__c);
                    }
                } else if (stgObj.EC_Action__c == EC_Constants.DELETEACTION){
                    accDelete.add(stgObj);
                } else {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                        null,null,null,null,null,null,'Invalid Action For Account SourceTable','EC_StagingHelper', 'stagingtriggerHelper');
                    stageLogWrapList.add(stageLogWrap);
                }

            }else if(stgObj.EC_Source_Table__c == EC_Constants.SouceTable_User){
                if(stgObj.EC_Action__c == EC_Constants.INSERTACTION){
                    contactInsert.add(stgObj);
                } else if (stgObj.EC_Action__c ==  EC_Constants.UPDATEACTION){
                    System.debug('user_update_action');
                    if(!userUpdatekeys.contains(stgObj.EC_User_Key__c)){
                        contactUpdate.add(stgObj);
                        userUpdate.add(stgObj);
                        userUpdatekeys.add(stgObj.EC_User_Key__c);
                    }
                    if(stgObj.EC_User_Key__c == null || stgObj.EC_User_Key__c == ''){
                        EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                            null,null,null,null,null,null,'Invalid EC_User_Key__c null or empty','EC_StagingHelper','stagingtriggerHelper');
                        stageLogWrapList.add(stageLogWrap);
                    }
                } else if (stgObj.EC_Action__c == EC_Constants.DELETEACTION){
                    if(!userDeletekeys.contains(stgObj.EC_User_Key__c)){
                        contactDelete.add(stgObj);
                        userDelete.add(stgObj);
                        userDeletekeys.add(stgObj.EC_User_Key__c);
                    } else {
                        EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                            null,null,null,null,null,null,'Duplicate delete event','EC_StagingHelper','stagingtriggerHelper');
                        stageLogWrapList.add(stageLogWrap);
                    }
                    if(stgObj.EC_User_Key__c == null || stgObj.EC_User_Key__c == ''){
                        EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                            null,null,null,null,null,null,'Invalid EC_User_Key__c null or empty','EC_StagingHelper','stagingtriggerHelper');
                        stageLogWrapList.add(stageLogWrap);
                    }
                } else {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                        null,null,null,null,null,null,'Invalid Action For User SourceTable','EC_StagingHelper','stagingtriggerHelper');
                    stageLogWrapList.add(stageLogWrap);
                }
            }else if(stgObj.EC_Source_Table__c == EC_Constants.SouceTable_User_Account){
                if(stgObj.EC_Action__c == EC_Constants.INSERTACTION){
                    user_AccountInsert.add(stgObj);
                } else if(stgObj.EC_Action__c ==EC_Constants.DELETEACTION){
                    user_AccountDelete.add(stgObj);
                } else {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                        null,null,null,null,null,null,'Invalid Action For User_Account SourceTable','EC_StagingHelper','stagingtriggerHelper');
                    stageLogWrapList.add(stageLogWrap);
                }
            }
            else if((stgObj.EC_Source_Table__c == EC_Constants.SouceTable_User_Permission)){
                if(stgObj.EC_Action__c == EC_Constants.INSERTACTION){
                    user_PermissionInsert.add(stgObj);
                }else if(stgObj.EC_Action__c == EC_Constants.DELETEACTION){
                    user_PermissionDelete.add(stgObj);
                }  else {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                        null,null,null,null,null,null,'Invalid Action For User_Permission SourceTable','EC_StagingHelper','stagingtriggerHelper');
                    stageLogWrapList.add(stageLogWrap);
                }
            } else {
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                        null,null,null,null,null,null,'Invalid SourceTable','EC_StagingHelper','stagingtriggerHelper');
                stageLogWrapList.add(stageLogWrap);
            }
        }

        EC_StagingLogger.stageLogException(stageLogWrapList);

        if (accInsert != null && !accInsert.isEmpty()){
            EC_StagingAccountInsert.accountInsert(accInsert);
        }

        if(accUpdate!=null && !accUpdate.isEmpty()){
            EC_StagingAccountUpdate.accountUpdate(accUpdate);
        }

        if(accDelete!=null && !accDelete.isEmpty()){
            EC_StagingAccountDelete.accountDelete(accDelete);
        }
        
        if (userInsert != null && !userInsert.isEmpty()){
            // commenting the below code as user insert will be done while creating a permission
            // EC_StagingHelper.userInserthelper(userInsert);
        }

        if (user_PermissionInsert != null && !user_PermissionInsert.isEmpty()){
            EC_StagingUserUtilities.userPermissionsInserthelper(user_PermissionInsert);
        }

        if(user_PermissionDelete!=null && !user_PermissionDelete.isEmpty()){
            EC_StagingUserUtilities.deleteUserPermissionsHelper(user_PermissionDelete);
        }

        if(userUpdate!=null && !userUpdate.isEmpty()){
            EC_StagingUserUtilities.userUpdatehelper(userUpdate);
        }

        if(userDelete!=null && !userDelete.isEmpty()){
            EC_StagingUserUtilities.userDeletehelper(userDelete);
        }

        if (contactInsert != null && !contactInsert.isEmpty()){
            EC_StagingContactUtilities.contactInsert(contactInsert);
        }

        if(contactUpdate!=null && !contactUpdate.isEmpty()){
            // We are sending null parameter as it is used for mapping the Users with contact,we send this parameter from UserInsert Function
            EC_StagingContactUtilities.contactUpdate(contactUpdate,null);
        }

        if(contactDelete!=null && !contactDelete.isEmpty()){
            EC_StagingContactUtilities.contactDelete(contactDelete);
        }

        if (user_AccountInsert != null && !user_AccountInsert.isEmpty()){
            EC_StagingUserAccountInsert.userAccountInsert(user_AccountInsert);
        }
        
        if(user_AccountDelete!=null && !user_AccountDelete.isEmpty()){
            EC_StagingUserAccountDelete.userAccountDelete(user_AccountDelete);
        }
    }
}