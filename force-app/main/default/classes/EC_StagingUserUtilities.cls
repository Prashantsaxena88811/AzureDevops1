//EC_StagingUserUtilities
//This is class to handle all the User related events from the CDM Staging
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//


public class EC_StagingUserUtilities{

/***************************************************************************************************************************************
Method Name : userPermissionsInserthelper
Description : Used to Insert Users and subsequently assign permissions to them and also assign the Users to respective Contacts,
                this is will further call UserPermissionInsert
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static void userPermissionsInserthelper(List<EC_Mulesoft_CDM_Staging__c> usrPermissionStage){

         Map<String,String> permCodeMap = new Map<String,String>();
        //This is will used to delete the permission and make user inactive if only permission among them exists
        permCodeMap.put(EC_Constants.SouceTable_BuyerPermission,EC_Constants.BuyerPermissionSet);
        permCodeMap.put(EC_Constants.SouceTable_BasicPermission,EC_Constants.BasicPermissionSet);

        Map<String,String> permCodeActiveUsrMap = new Map<String,String>();
        //This is will used to just delete the permission and keep user active
        permCodeActiveUsrMap.put(EC_Constants.SouceTable_ViewpricePermission,EC_Constants.ViewpricePermissionSet);
        permCodeActiveUsrMap.put(EC_Constants.SouceTable_PayerPermission,EC_Constants.PayerPermissionSet);

        List<String> lstUserKey = new List<String>();
        Map<String,List<String>> usrKeyPermissionMap = new Map<String,List<String>>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        for(EC_Mulesoft_CDM_Staging__c stgObj:usrPermissionStage){
            lstUserKey.add(stgObj.EC_User_Key__c);
            if(!usrKeyPermissionMap.containsKey(stgObj.EC_User_Key__c)) {
                usrKeyPermissionMap.put(stgObj.EC_User_Key__c, new List<String>());
            }
            usrKeyPermissionMap.get(stgObj.EC_User_Key__c).add(stgObj.EC_Permission_Code__c);
            
            if (!permCodeMap.containsKey(stgObj.EC_Permission_Code__c) && !permCodeActiveUsrMap.containsKey(stgObj.EC_Permission_Code__c)) {
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.id,null,null,null,null,null,null,null,null,null,'Invalid Permission Set',
                        'EC_StagingUserUtilities','userPermissionsInserthelper');
                stageLogWrapList.add(stageLogWrap);
            }
        }

        List<User> lstexistingUser = new List<User>();
        lstexistingUser = [Select Id,EC_CDM_User__c,EC_CDM_User_Status__c,IsActive from User where EC_CDM_User__c in:lstUserKey];
        List<String> lstexistingUserKeys = new List<String>();
        Map<Id,String> usrIdPermissionMap = new Map<Id,String>();
        for(User usr:lstexistingUser){
            for(String permCode : usrKeyPermissionMap.get(usr.EC_CDM_User__c)){
                if(permCodeMap.containsKey(permCode)){
                    usrIdPermissionMap.put(usr.Id,permCodeMap.get(permCode));
                    lstexistingUserKeys.add(usr.EC_CDM_User__c);
                } else if(permCodeActiveUsrMap.containsKey(permCode) && usr.IsActive){
                    usrIdPermissionMap.put(usr.Id,permCodeActiveUsrMap.get(permCode));
                    lstexistingUserKeys.add(usr.EC_CDM_User__c);
                }
            }
        }
        Set<Id> stagingUpdateIds = new Set<Id>();
        List<EC_Mulesoft_CDM_Staging__c> staginginsertIds = new List<EC_Mulesoft_CDM_Staging__c>();
        for(EC_Mulesoft_CDM_Staging__c stgObj:usrPermissionStage){
            if(lstexistingUserKeys.contains(stgObj.EC_User_Key__c)){
                stagingUpdateIds.add(stgObj.Id);
            }
            else{
                if(usrKeyPermissionMap.containsKey(stgObj.EC_User_Key__c)){
                    for(String permCode : usrKeyPermissionMap.get(stgObj.EC_User_Key__c)){
                        if(permCodeMap.containsKey(permCode)){
                            staginginsertIds.add(stgObj);
                        }
                    }
                }
            }
        }
        if(staginginsertIds!=null && !staginginsertIds.isEmpty()){
            EC_StagingUtilities.userInsert(staginginsertIds);
        }
        if(stagingUpdateIds!=null && !stagingUpdateIds.isEmpty()){
            EC_StagingPermissionUserUpdate batchObj = new EC_StagingPermissionUserUpdate(lstexistingUserKeys);
            Id batchId = Database.executeBatch(batchObj,2500);
            EC_StagingUtilities.updatePermissionSet(usrIdPermissionMap,usrPermissionStage,stageLogWrapList);
        } else if(stageLogWrapList!=null && !stageLogWrapList.isEmpty()) {
            EC_StagingLogger.stageLogException(stageLogWrapList);
        }
    }

/***************************************************************************************************************************************
Method Name : userUpdatehelper
Description : Used to Update Users From Staging Object on the Update Action.
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static void userUpdatehelper(List<EC_Mulesoft_CDM_Staging__c> usrStage){
        List<String> stagingIds = new List<String>();
        Map<String,EC_Mulesoft_CDM_Staging__c> userKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        for(EC_Mulesoft_CDM_Staging__c stgObj:usrStage)
        {
            stagingIds.add(stgObj.EC_User_Key__c);
            userKeyMap.put(stgObj.EC_User_Key__c,stgObj);
        }
        EC_StagingUtilities.userUpdate(stagingIds,userKeyMap);
    }

/***************************************************************************************************************************************
Method Name : userDeletehelper
Description : Used to delete Users From Staging Object on the Delete Action.
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static void userDeletehelper(List<EC_Mulesoft_CDM_Staging__c> usrStage){
        List<String> stagingIds = new List<String>();
        Map<String,EC_Mulesoft_CDM_Staging__c> userKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> duplicateEvnts = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        for(EC_Mulesoft_CDM_Staging__c stgObj:usrStage)
        {
            if(!String.isBlank(stgObj.EC_User_Key__c)) {
                stagingIds.add(stgObj.EC_User_Key__c);
              	if (userKeyMap.get(stgObj.EC_User_Key__c) == null) {
                	userKeyMap.put(stgObj.EC_User_Key__c,stgObj);
                } else {
                    duplicateEvnts.add(stgObj);
                }  
            } else {
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgObj.Id,null,null,null,
                        null,null,null,null,null,null,'Empty User CDM Key for User Delete Event','EC_StagingUserUtilities','userDeletehelper');
                stageLogWrapList.add(stageLogWrap);
            }
        }
        if (stageLogWrapList != null && !stageLogWrapList.isEmpty()) {
          EC_StagingLogger.stageLogException(stageLogWrapList);
        }
        EC_StagingUtilities.userDelete(stagingIds,userKeyMap,duplicateEvnts);
    }


/***************************************************************************************************************************************
Method Name : deleteUserPermissionsHelper
Description : Used to delete user_permission records
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static void deleteUserPermissionsHelper(List<EC_Mulesoft_CDM_Staging__c> deleteUserPermissions){

        List<String> lstdeleteId = new List<String>();
        for(EC_Mulesoft_CDM_Staging__c stg:deleteUserPermissions){
            lstdeleteId.add(stg.EC_User_Key__c);
        }
        EC_StagingUtilities.deleteUserPermissions(lstdeleteId,deleteUserPermissions);
    }
}