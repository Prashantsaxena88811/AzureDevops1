/* Class Name       :EC_StagingUserDelete
* Description      :Batch class to process unprocessed records of EC_Mulesoft_CDM_Staging__c object.
* Created By       :Ayusha Patnaik
* Created On       :08-23-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Ayusha Patnaik          08-23-2019                                    to process unprocessed records of EC_Mulesoft_CDM_Staging__c object.
*
*/global class EC_StagingUserDelete implements Database.Batchable<Sobject>{

    private List<String> userIds;
    private Map<String,EC_Mulesoft_CDM_Staging__c> userKeyMapstg = new Map<String,EC_Mulesoft_CDM_Staging__c>();
    private List<EC_Mulesoft_CDM_Staging__c> duplicateEvnts = new List<EC_Mulesoft_CDM_Staging__c>();
    public EC_StagingUserDelete(List<String> Ids,Map<String,EC_Mulesoft_CDM_Staging__c> userKeyMap, List<EC_Mulesoft_CDM_Staging__c> duplicateRecords){
        userIds = Ids;
        userKeyMapstg = userKeyMap;
        duplicateEvnts = duplicateRecords;
        system.debug('Duplicate records count:'+duplicateEvnts.size());
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<User> listItems = [select Id,IsActive,EC_CDM_User__c from User where EC_CDM_User__c in: userIds];
        if(listItems == null || listItems.size() <= 0) {
            List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
            for(String key:userIds){
                EC_Mulesoft_CDM_Staging__c stgRecord = userKeyMapstg.get(key);
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgRecord.Id,stgRecord.EC_User_Key__c,null,stgRecord.EC_Source_Table__c,
                                                                                       stgRecord.EC_Action__c,null,null,null,null,null,'Invalid User Key or User Key Doesnot exist in Salesforce','EC_StagingContactUtilities',
                                                                                       'UserDelete');
                stageLogWrapList.add(stageLogWrap);
        	}
            EC_StagingLogger.stageLogException(stageLogWrapList);
        }
        return Database.getQueryLocator([select Id,IsActive,EC_CDM_User__c from User where EC_CDM_User__c in: userIds]);
    }
    global void execute(Database.BatchableContext bc, List<User> lstUser){
      // The below Lists are used to update the isProcessed field on the Staging Object.
        List<Id> lstUpdatedSuccess = new List<Id>();
        List<EC_Mulesoft_CDM_Staging__c> successRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new List<EC_Mulesoft_CDM_Staging__c>();
        //below list will be used for exception handling
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Map<Id,EC_Mulesoft_CDM_Staging__c> usrStageMap = new Map<Id,EC_Mulesoft_CDM_Staging__c>();
        Map<Integer,String> indexKeyMap = new Map<Integer,String>();
        Map<String,Id> existingKeys = new Map<String,Id>();

        List<User>  userDelete = new  List<User>();
        Integer index = 0;
        for(User usr:lstUser){
            usrStageMap.put(usr.Id,userKeyMapstg.get(usr.EC_CDM_User__c));
            usr.IsActive = false;
            usr.EC_CDM_User_Status__c = false;
            userDelete.add(usr);
            indexKeyMap.put(index, userKeyMapstg.get(usr.EC_CDM_User__c).Id);
            existingKeys.put(usr.EC_CDM_User__c,usr.Id);
            index++;
        }
        for(String key:userIds){
            if(!existingKeys.containsKey(key)){
                EC_Mulesoft_CDM_Staging__c stgRecord = userKeyMapstg.get(key);
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgRecord.Id,stgRecord.EC_User_Key__c,null,stgRecord.EC_Source_Table__c,
			                    stgRecord.EC_Action__c,null,null,null,null,null,'Invalid User Key or User Key Doesnot exist in Salesforce','EC_StagingContactUtilities',
								'UserDelete');
                stageLogWrapList.add(stageLogWrap);
            } 
        }
        Database.SaveResult[] saveRes = Database.Update(userDelete,false);
        index = 0;
        for(Database.SaveResult sr:saveRes){
            if(sr.isSuccess()){
                lstUpdatedSuccess.add(sr.getId());
            }
            else {
                 for(Database.Error  err: sr.getErrors()) {
		       EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(indexKeyMap.get(index),usrStageMap.get(sr.getId()).EC_User_Key__c,null,usrStageMap.get(sr.getId()).EC_Source_Table__c,
			                    usrStageMap.get(sr.getId()).EC_Action__c,null,null,null,null,null,err.getMessage(),'EC_StagingUserDelete',
								'UserDelete');
                stageLogWrapList.add(stageLogWrap);
                     }
            }
            index++;
        }

      for(User usr:[Select Id,EC_CDM_User__c from User where Id in:lstUpdatedSuccess]){
            successRecords.add(userKeyMapstg.get(usr.EC_CDM_User__c));
        }
      System.enqueueJob(new EC_StagingAccountShareQueuable(null,successRecords,lstUpdatedSuccess,stageLogWrapList));




     /*
     List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        for(EC_Mulesoft_CDM_Staging__c successStg:successRecords){
            successStg.EC_IsProcessed__c= true;
            if(successStg.Id != null && !String.isBlank(successStg.Id)){
                existRecords.add(successStg);
            }
                }
        if(existRecords != null && !existRecords.isEmpty()){
            update existRecords;
        } */


           }
    global void finish(Database.BatchableContext bc){

    }

}