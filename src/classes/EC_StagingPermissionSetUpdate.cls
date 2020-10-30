/* Class Name       :EC_StagingUserDelete
* Description      :Batch class to update permission set
* Created By       :Shivam Vats
* Created On       :08-23-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Shivam Vats         08-23-2019                                    Batch class to update permission set
*
*/
global class EC_StagingPermissionSetUpdate implements Database.Batchable<Sobject>,Database.Stateful{

    global Map<Id,String> permissionMap;
    global List<String> permissiontSetName = new List<String>();
    global List<Id> payerUserIds = new List<Id>();
    global List<PermissionSet> lstPermissionSet = new List<PermissionSet>();
    global Map<String,Id> permissionSetMap = new Map<String,Id>();
    global List<PermissionSetAssignment> lstPermissionSetAssign = new List<PermissionSetAssignment>();
    global List<EC_Mulesoft_CDM_Staging__c> lstStaging = new List<EC_Mulesoft_CDM_Staging__c>();
    global List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();

    public EC_StagingPermissionSetUpdate(Map<Id,String> permissionMaps,List<EC_Mulesoft_CDM_Staging__c> lstStagingObjs, List<EC_StagingExceptionLog__c> stageLogWraperList){
        permissionMap = permissionMaps;
        lstStaging = lstStagingObjs;
       stageLogWrapList = stageLogWraperList;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<Id> lstUsr = new List<Id>();

        if(permissionMap != null && permissionMap.KeySet().size()>0){
            for(Id usrId : permissionMap.KeySet()){
                lstUsr.add(usrId);
            }
        }
        return Database.getQueryLocator([select id from User where id in :lstUsr]);
    }
    global void execute(Database.BatchableContext bc, List<User> lstUsr){
       // The below Lists will be used to check isProcessed field on Staging Object
        List<Id> lstUpdatedSuccess = new List<Id>();
        List<String> lstInsertedUserKeys = new List<String>();
        List<String> lstAssigneeId = new List<String>();
        List<EC_Mulesoft_CDM_Staging__c> successRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        Map<Id,String> userKeyIdMap = new Map<Id,String>();
        Map<Id,String> permissionSetIdMap = new Map<Id,String>();
        Map<String,EC_Mulesoft_CDM_Staging__c> permissionStagingKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        // Below list will be used for exception handling
        List<EC_StagingExceptionLog__c> stagePermissionWrapList = new List<EC_StagingExceptionLog__c>();
        List<Permision_Set_Mapping__mdt> permissionSets = [Select label, Permission_Set_Name__c from Permision_Set_Mapping__mdt];
        Map<String,String> permissions = new Map<String,String>();
        for(Permision_Set_Mapping__mdt permission:permissionSets) {
            permissiontSetName.add(permission.Permission_Set_Name__c);
            permissions.put(permission.Permission_Set_Name__c,permission.label);
        }

        List<PermissionSet> lstPSet = [Select Id,Name from PermissionSet where name in:permissiontSetName];
        List<User> usersList = [Select Id,EC_CDM_User__c from User where Id in:permissionMap.keyset()];
      	for(User usr: usersList){
            userKeyIdMap.put(usr.Id,usr.EC_CDM_User__c);
        }
      	for(PermissionSet permission:lstPSet){
        	permissionSetMap.put(permission.Name,permission.Id);
            permissionSetIdMap.put(permission.Id,permissions.get(permission.Name));
        }

        for(EC_Mulesoft_CDM_Staging__c stgObj:lstStaging){
            permissionStagingKeyMap.put(stgObj.EC_User_Key__c+stgObj.EC_Permission_Code__c,stgObj);
        }

       for(Id usrId:permissionMap.keyset()){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = permissionSetMap.get(permissionMap.get(usrId));
            psa.AssigneeId = usrId;
            lstPermissionSetAssign.add(psa);
        }
        Database.SaveResult[] saveRes = Database.insert(lstPermissionSetAssign,false);
        for(Database.SaveResult sr:saveRes){
            if(sr.isSuccess()){
                system.debug('succ '+sr.getId());
            lstUpdatedSuccess.add(sr.getId());
            }
            else {
                 for(Database.Error  err: sr.getErrors()) {
                    system.debug('failure '+sr.getErrors());
               EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,
                                null,null,null,null,null,null,err.getMessage(),'EC_StagingPermissionSetUpdate',
                                'UserPermissionUpdate');
                stagePermissionWrapList.add(stageLogWrap);
                     }
                     }
        }
        if(stagePermissionWrapList!=null && stagePermissionWrapList.size()>0){
             EC_StagingLogger.stageLogException(stagePermissionWrapList);
        }

         for(PermissionSetAssignment psa:[SELECT AssigneeId,PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment where Id in:lstUpdatedSuccess]){
            //successRecords.add(permissionStagingKeyMap.get(userKeyIdMap.get(psa.AssigneeId)+permissionSetIdMap.get(psa.PermissionSetId)));
            if(psa.PermissionSet.Name == EC_Constants.PayerPermissionSet){
                payerUserIds.add(psa.AssigneeId);
            }
        }
        /*List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        if(successRecords != null) {
            for(EC_Mulesoft_CDM_Staging__c successStg:successRecords){
                successStg.EC_IsProcessed__c= true;
                 if(successStg.Id != null && !String.isBlank(successStg.Id)){
                    existRecords.add(successStg);
                }
            }
        }*/
    }

   global void finish(Database.BatchableContext bc){
        // This is the exception list of User Inserts
        if(stageLogWrapList!=null && stageLogWrapList.size()>0){
            EC_StagingLogger.stageLogException(stageLogWrapList);
        }
        if(payerUserIds.size()>0){
            updatePayerCases(payerUserIds);
        }
    }
    public void updatePayerCases(List<Id> payerUserIds){
        List<Case> payerCases= [SELECT Id, Status FROM Case WHERE Type = :EC_Constants.CASE_TYPE_ACCESS
                                AND Status = :EC_Constants.STATUS_Pending AND EC_User__c IN :payerUserIds AND EC_PortalAccessRole__c =:EC_Constants.Portal_Access_Role];
        if(payerCases.size()>0){
            for(Case pyrCase:payerCases){
                pyrCase.Status = EC_Constants.STATUS_CLOSED;
            }
            Update payerCases;
        }
    }
}