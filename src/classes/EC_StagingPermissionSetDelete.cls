/* Class Name       :EC_StagingPermissionSetDelete
* Description      :Batch class to permission set delete records of EC_Mulesoft_CDM_Staging__c object.
* Created By       :Mishika Mahajan
* Created On       :07-22-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Moin Sawar          04-28-2020                                    updated logic to incorporate viewPrice permission.
*
*/
global class EC_StagingPermissionSetDelete implements Database.Batchable<Sobject> {
  global Map<String,Id> permissionMap = new Map<String,Id>();
  global List<User> assigneeIds = new List<User>();
  global List<EC_Mulesoft_CDM_Staging__c> stageRecords = new List<EC_Mulesoft_CDM_Staging__c>();
  List<EC_Mulesoft_CDM_Staging__c> invalidEvents = new List<EC_Mulesoft_CDM_Staging__c>();
  public EC_StagingPermissionSetDelete(Map<String,Id> permissionSetsMap,List<User> usrIdsDelete,List<EC_Mulesoft_CDM_Staging__c> stgRecrds, List<EC_Mulesoft_CDM_Staging__c> invalidRecords)
  {
    assigneeIds = usrIdsDelete;
    permissionMap = permissionSetsMap;
    stageRecords = stgRecrds;
    invalidEvents = invalidRecords;
  }
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator([Select Id,AssigneeId,PermissionSetId,PermissionSet.Name from PermissionSetAssignment where AssigneeId in:assigneeIds and PermissionSetId in:permissionMap.values()]);
  }
  global void execute(Database.BatchableContext bc, List<PermissionSetAssignment> psaDELTE){

    //This is will used to delete the permission and make user inactive if only permission among them exists
    Map<String,String> permCodeMap = new Map<String,String>();
    //This is will used to just delete the permission and keep user active
    Map<String,String> permCodeActiveUsrMap = new Map<String,String>();
    String className =  'EC_StagingPermissionSetDelete';
    String methodName = 'UserPermissionDelete';
	  try {
		  List<Permision_Set_Mapping__mdt> permissionSets = [Select label, is_Active_Required__c ,Permission_Set_Name__c from Permision_Set_Mapping__mdt];
      for(Permision_Set_Mapping__mdt permission:permissionSets) {
        if(permission.is_Active_Required__c ) {
          permCodeMap.put(permission.Permission_Set_Name__c,permission.label);
        } else {
          permCodeActiveUsrMap.put(permission.Permission_Set_Name__c,permission.label);
        }
      }
      //Below List will be
      List<EC_StagingExceptionLog__c> stagePermissionWrapList = new List<EC_StagingExceptionLog__c>();
      Map<Id,String> usrPermisionMap = new Map<Id,String>();
      for(User usr:[Select Id,EC_CDM_User__c from User where Id in:assigneeIds ]){
          usrPermisionMap.put(usr.Id,usr.EC_CDM_User__c);
      }
      Map<String,Integer> assigneePermCount = new Map<String,Integer>();
      for(PermissionSetAssignment tempPermContRec : psaDELTE){
        if(!assigneePermCount.containsKey(tempPermContRec.AssigneeId)){
            assigneePermCount.put(tempPermContRec.AssigneeId,0);
        }
        if(permCodeMap.containsKey(tempPermContRec.PermissionSet.Name)){
          Integer currentInt=assigneePermCount.get(tempPermContRec.AssigneeId)+1;
          assigneePermCount.put(tempPermContRec.AssigneeId,currentInt);
        }
      }

      List<EC_Mulesoft_CDM_Staging__c> successRecords = new List<EC_Mulesoft_CDM_Staging__c>();
      List<User> deleteUserlst = new List<User>();
      List<PermissionSetAssignment> psaDelList = new List<PermissionSetAssignment>();
      Map<Integer,String> indexKeyMap = new Map<Integer,String>();
      Integer index = 0;
      for(EC_Mulesoft_CDM_Staging__c stageRec : stageRecords){
        for(PermissionSetAssignment tempPermContRec : psaDELTE){
          if(stageRec.EC_User_Key__c ==  usrPermisionMap.get(tempPermContRec.AssigneeId) && stageRec.EC_Permission_Code__c == permCodeMap.get(tempPermContRec.PermissionSet.Name)){
            EC_Mulesoft_CDM_Staging__c stageRecUpdate = new EC_Mulesoft_CDM_Staging__c();
            stageRecUpdate.Id = stageRec.Id;
            stageRecUpdate.EC_Record_Status__c = EC_Constants.COMPLETED;
            successRecords.add(stageRecUpdate);
            psaDelList.add(tempPermContRec);
            indexKeyMap.put(index, stageRec.Id);
            index++;
            if(assigneePermCount.get(tempPermContRec.AssigneeId) == 1){
              User usr = new User();
              usr.Id = tempPermContRec.AssigneeId;
              usr.IsActive = false;
              deleteUserlst.add(usr);
            }
            break;
          }
          if(stageRec.EC_User_Key__c ==  usrPermisionMap.get(tempPermContRec.AssigneeId) && stageRec.EC_Permission_Code__c == permCodeActiveUsrMap.get(tempPermContRec.PermissionSet.Name)){
            EC_Mulesoft_CDM_Staging__c stageRecUpdate1 = new EC_Mulesoft_CDM_Staging__c();
            stageRecUpdate1.Id = stageRec.Id;
            stageRecUpdate1.EC_Record_Status__c = EC_Constants.COMPLETED;
            successRecords.add(stageRecUpdate1);
            psaDelList.add(tempPermContRec);
            indexKeyMap.put(index, stageRec.Id);
            index++;
            break;
          }
        }
      }
      for (EC_Mulesoft_CDM_Staging__c invalidEvent:invalidEvents) {
        EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(invalidEvent.id,null,null,null,
                          null,null,null,null,null,null,'Invalid User Key',className,methodName);
        stagePermissionWrapList.add(stageLogWrap);
      }
      System.enqueueJob(new EC_StagingAccountShareQueuable(null,successRecords,null,null));
      if(psaDELTE!=null && !psaDELTE.isEmpty()){
          index = 0;
          Database.deleteResult[] saveRes = Database.Delete(psaDelList,false);
          List<Id> lstDelsuccess = new List<Id>();
          for(Database.deleteResult sr:saveRes){
              if(sr.isSuccess()){
                  lstDelsuccess.add(sr.getId());
              } else {
                  for(Database.Error  err: sr.getErrors()) {
                      EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(indexKeyMap.get(index),null,null,null,
                          null,null,null,null,null,null,err.getMessage(),className,methodName);
                      stagePermissionWrapList.add(stageLogWrap);
                  }
              }
          }
          if(deleteUserlst!=null && deleteUserlst.size()>0){
              update deleteUserlst;
          }
      }
      if(stagePermissionWrapList!=null && stagePermissionWrapList.size()>0){
          EC_StagingLogger.stageLogException(stagePermissionWrapList);
      }
      if(Test.isRunningTest()){
          throw new DMLException(); 
      }
    } catch(Exception ex) {
      EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,
                          null,null,null,null,null,null,ex.getMessage(),className,
                      methodName);
		  system.debug('The exception Catched is +++++ '+ex.getMessage());
    }
  }
  global void finish(Database.BatchableContext bc){

  }
}