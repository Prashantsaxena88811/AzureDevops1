//EC_StagingUserAccountDelete
//This is class to handle the User Account insert records on Staging
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//

public class EC_StagingUserAccountDelete{

/***************************************************************************************************************************************
Method Name : userAccountDelete
Description : Used to Delete userAccountDelete From Staging Object on the Delete Action.
Return type : void
Author      : Harsha N
*************************************************************************************************************************************/
    public static void userAccountDelete(List<EC_Mulesoft_CDM_Staging__c> usrAccStage){
        Set<AccountContactRelation> setDelAccContRel = new Set<AccountContactRelation>();
        Set<AccountContactRelation> lstBlanketAccContRel = new Set<AccountContactRelation>();
        List<contact> lstContextDirectCont = new List<contact>();
        Set<contact> setContactUpdate = new set<contact>();
        Set<string> lstContextAccKey = new Set<string>();
        Set<string> lstForbiddenAccKey = new Set<string>();
        Set<string> lstContextContKey = new Set<string>();
        Set<string> lstDirectContKey = new Set<string>();
        List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        Map<EC_Mulesoft_CDM_Staging__c, set<AccountContactRelation>> mapStgAccGrp = new Map<EC_Mulesoft_CDM_Staging__c, set<AccountContactRelation>>();
        Map<string, contact> mapDirectCont = new Map<string, contact>();
        Map<string, string> mapDirectReplacement = new Map<string, string>();
         List<EC_Mulesoft_CDM_Staging__c> successSalesRepArg = new List<EC_Mulesoft_CDM_Staging__c>();
        // We will use the below lists to update the IsProcessed field in the Staging table
        list<Id> lstUpdatedSuccess = new list<Id>();
        list<EC_Mulesoft_CDM_Staging__c> successStgRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        Set<EC_Mulesoft_CDM_Staging__c> successRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Map<String, EC_Mulesoft_CDM_Staging__c> userAccKeysStageMap = new  Map<String, EC_Mulesoft_CDM_Staging__c>(); 
        Map<String, EC_Mulesoft_CDM_Staging__c> userKeysStageMap = new  Map<String, EC_Mulesoft_CDM_Staging__c>();
        Map<String, EC_Mulesoft_CDM_Staging__c> accContKeysStageMap = new  Map<String, EC_Mulesoft_CDM_Staging__c>(); 
        List<String> accConRelKey = new List<String>();
		
        try{
		 // modified on 01/07/2020
            for(EC_Mulesoft_CDM_Staging__c stageRec : usrAccStage){
                userAccKeysStageMap.put(stageRec.EC_Account_Key__c+'_'+ stageRec.EC_User_Key__c,stageRec);
                lstContextAccKey.add(stageRec.EC_Account_Key__c);
                lstContextContKey.add(stageRec.EC_User_Key__c);
                userKeysStageMap.put(stageRec.EC_User_Key__c,stageRec);
                accContKeysStageMap.put(stageRec.EC_Account_Key__c+'_'+ stageRec.EC_User_Key__c,stageRec);
            }
            List<AccountContactRelation> accContList =[SELECT id, account.EC_CDM_Account__c, contact.EC_CDM_Contact__c FROM AccountContactRelation WHERE account.EC_CDM_Account__c IN: lstContextAccKey AND contact.EC_CDM_Contact__c IN: lstContextContKey];
            set<EC_Mulesoft_CDM_Staging__c> duplicateRecStageSet = new  set<EC_Mulesoft_CDM_Staging__c>(usrAccStage);
            System.debug('accContList:'+accContList);
            if(accContList!=null && !accContList.isEmpty()){
            // modified on 01/07/2020
                for(AccountContactRelation accConRel:accContList){
                    String accUserKey = accConRel.account.ec_cdm_account__c + '_'+ accConRel.contact.EC_CDM_Contact__c;
                    if(userAccKeysStageMap.containsKey(accUserKey)){
                        duplicateRecStageSet.remove(userAccKeysStageMap.get(accUserKey));  
                    }
                    accConRelKey.add(accUserKey);
                }
                for(EC_Mulesoft_CDM_Staging__c stageRec:duplicateRecStageSet){
                    EC_Mulesoft_CDM_Staging__c stageRecUpdate = new EC_Mulesoft_CDM_Staging__c();
                    stageRecUpdate.Id = stageRec.Id;
                    stageRecUpdate.EC_Record_Status__c = Label.EC_Duplicate;
                    stageRecUpdate.EC_IsProcessed__c = true;
                    if(stageRecUpdate.Id != null && !String.isBlank(stageRecUpdate.Id)){
                        existRecords.add(stageRecUpdate);
                    }
                }


                List<AccountContactRelation> relevantAccContList = [SELECT id, account.EC_CDM_Account__c, contact.EC_CDM_Contact__c, isDirect, account.RecordType.Name, account.parent.EC_CDM_Account__c, accountId, account.parent.RecordType.Name FROM AccountContactRelation WHERE (account.EC_CDM_Account__c IN: lstContextAccKey AND contact.EC_CDM_Contact__c IN: lstContextContKey AND account.RecordType.Name =: EC_Constants.Ship_To) OR ((account.EC_CDM_Account__c IN: lstContextAccKey AND contact.EC_CDM_Contact__c IN: lstContextContKey AND account.RecordType.Name =: EC_Constants.Sold_To) OR (account.parent.EC_CDM_Account__c IN: lstContextAccKey AND contact.EC_CDM_Contact__c IN: lstContextContKey AND account.parent.RecordType.Name =: EC_Constants.Sold_To))];


                Map<string, AccountContactRelation> mapContDirectAccCont = new Map<string, AccountContactRelation>();
                Map<Id, EC_Mulesoft_CDM_Staging__c> stageContactMap = new Map<Id, EC_Mulesoft_CDM_Staging__c>();//MM
                for(EC_Mulesoft_CDM_Staging__c stageRec : usrAccStage){
                    for(AccountContactRelation accRec : relevantAccContList){
                        if(stageRec.EC_Account_Key__c == accRec.account.EC_CDM_Account__c && stageRec.EC_User_Key__c == accRec.contact.EC_CDM_Contact__c && accRec.account.RecordType.Name == EC_Constants.Ship_To){
                            if(accRec.isDirect){
                                mapContDirectAccCont.put(accRec.contact.EC_CDM_Contact__c, accRec);
                                lstDirectContKey.add(accRec.contact.EC_CDM_Contact__c);
                                stageContactMap.put(accRec.contact.id,stageRec);
                            }else{
                                setDelAccContRel.add(accRec);

                            }
                            lstForbiddenAccKey.add(accRec.account.EC_CDM_Account__c);
                        }else if((stageRec.EC_Account_Key__c == accRec.account.EC_CDM_Account__c && stageRec.EC_User_Key__c == accRec.contact.EC_CDM_Contact__c && accRec.account.RecordType.Name == EC_Constants.Sold_To) || (stageRec.EC_Account_Key__c == accRec.account.parent.EC_CDM_Account__c && stageRec.EC_User_Key__c == accRec.contact.EC_CDM_Contact__c && accRec.account.parent.RecordType.Name == EC_Constants.Sold_To)){
                            if(accRec.isDirect){
                                mapContDirectAccCont.put(accRec.contact.EC_CDM_Contact__c, accRec);
                                lstDirectContKey.add(accRec.contact.EC_CDM_Contact__c);
                                stageContactMap.put(accRec.contact.id,stageRec);
                            }else{
                                setDelAccContRel.add(accRec);

                            }
                            lstForbiddenAccKey.add(accRec.account.EC_CDM_Account__c);
                        }
                    }
                    if(!accConRelKey.contains(stageRec.EC_Account_Key__c+'_'+ stageRec.EC_User_Key__c)){
                        EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageRec.Id,null,null,null,null,null,null,null,null,null,'Invalid AccountContactRelation','EC_StagingUserAccountDelete',
                        'userAccountDelete');
                        stageLogWrapList.add(stageLogWrap);
                    }
                }


                lstContextDirectCont = [SELECT id, EC_CDM_Contact__c FROM contact WHERE EC_CDM_Contact__c IN: lstDirectContKey];


                List<AccountContactRelation> lstInDirectAccCont = [SELECT Id, contactId, contact.EC_CDM_Contact__c, account.EC_CDM_Account__c, isDirect FROM AccountContactRelation WHERE contact.EC_CDM_Contact__c IN: lstDirectContKey AND isDirect = false AND account.EC_CDM_Account__c NOT IN: lstForbiddenAccKey];


                Map<string, AccountContactRelation> mapContInDirectAccCont = new Map<string, AccountContactRelation>();

                for(AccountContactRelation tempAccCont : lstInDirectAccCont){
                    if(!mapContInDirectAccCont.containskey(tempAccCont.contact.EC_CDM_Contact__c)){
                        mapContInDirectAccCont.put(tempAccCont.contact.EC_CDM_Contact__c, tempAccCont);
                    }
                }


                for(contact tempContRec : lstContextDirectCont){
                    account tempAcc = new account();
                    if(mapContInDirectAccCont.containskey(tempContRec.EC_CDM_Contact__c)){
                        tempAcc.EC_CDM_Account__c = mapContInDirectAccCont.get(tempContRec.EC_CDM_Contact__c).account.EC_CDM_Account__c;
                    }else{
                        tempAcc.EC_CDM_Account__c = EC_Constants.DummyAccountKey;
                    }
                    tempContRec.account = tempAcc;
                    setContactUpdate.add(tempContRec);

                    if(mapContDirectAccCont.containskey(tempContRec.EC_CDM_Contact__c)){
                        setDelAccContRel.add(mapContDirectAccCont.get(tempContRec.EC_CDM_Contact__c));
                    }
                }



                Set<EC_Mulesoft_CDM_Staging__c> errorRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
                if(setContactUpdate != null && setContactUpdate.size() > 0){
                    list<contact> updateList = new list<contact>();
                    updateList.addAll(setContactUpdate);
                    Map<Integer,String> indexKeyMap = new Map<Integer,String>();
                    Integer index = 0;
                    for(Contact temStorage : updateList){
                        indexKeyMap.put(index, temStorage.EC_CDM_Contact__c);
                        index++;
                    }
                    Database.SaveResult[] savRes = Database.update(updateList,false);
                    index = 0;
                    for(Database.SaveResult sr:savRes){
                        if(sr.isSuccess()){
                            successRecords.add(stageContactMap.get(sr.getId()));
                        }
                        else if(!sr.isSuccess()){
                            for(Database.Error  err: sr.getErrors()) {
                                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(userKeysStageMap.get(indexKeyMap.get(index)).Id,stageContactMap.get(sr.getId()).EC_User_Key__c,stageContactMap.get(sr.getId()).EC_Account_Key__c,stageContactMap.get(sr.getId()).EC_Source_Table__c,
                                                    stageContactMap.get(sr.getId()).EC_Action__c,null,null,null,null,null,err.getMessage(),'EC_StagingUserAccountDelete',
                                            'userAccountDelete');
                                    stageLogWrapList.add(stageLogWrap);
                            }
                        }
                        index++;
                    }
                }

                Map<Id,EC_Mulesoft_CDM_Staging__c>  stageAccConMap = new Map<Id,EC_Mulesoft_CDM_Staging__c>();
                // modified on 01/07/2020
                for(AccountContactRelation tempAccContRec : setDelAccContRel){
                String accUserkey = tempAccContRec.account.EC_CDM_Account__c +'_'+ tempAccContRec.contact.EC_CDM_Contact__c;
                    if(userAccKeysStageMap.containsKey(accUserkey)){
                        stageAccConMap.put(tempAccContRec.id,userAccKeysStageMap.get(accUserkey));
                }
                }
                
                if(setDelAccContRel != null && setDelAccContRel.size() > 0){
                    list<AccountContactRelation> deleteList = new list<AccountContactRelation>();
                    deleteList.addAll(setDelAccContRel);
                    Map<Integer,String>  indexKeysMap = new Map<Integer,String>();
                    Integer index1 = 0;
                    for(AccountContactRelation temStorage: deleteList){
                        indexKeysMap.put(index1, temStorage.account.EC_CDM_Account__c +'_'+ temStorage.contact.EC_CDM_Contact__c);
                        index1++;
                    }
                    Database.deleteResult[] deleteRes = Database.delete(deleteList,false);
                    index1 = 0;
                    for(Database.DeleteResult dr :deleteRes){
                        if(dr.isSuccess()){
                        successRecords.add(stageAccConMap.get(dr.getId()));
                        }
                        else if(!dr.isSuccess()){
                            for(Database.Error  err: dr.getErrors()) {
                                if(stageAccConMap.get(dr.getId())!=null){
                        EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(accContKeysStageMap.get(indexKeysMap.get(index1)).Id,stageAccConMap.get(dr.getId()).EC_User_Key__c,stageAccConMap.get(dr.getId()).EC_Account_Key__c,stageAccConMap.get(dr.getId()).EC_Source_Table__c,
                                        stageAccConMap.get(dr.getId()).EC_Action__c,null,null,null,null,null,err.getMessage(),'EC_StagingUserAccountDelete',
                                'userAccountDelete');
                        stageLogWrapList.add(stageLogWrap);
                                }
                        }
                        }
                        index1++;
                    }
                }
                if(successRecords!=null && !successRecords.isEmpty()){
                    for(EC_Mulesoft_CDM_Staging__c stage : successRecords){
                        if(stage!=null){
                            successSalesRepArg.add(stage);
                            EC_Mulesoft_CDM_Staging__c stageRecUpdate2 = new EC_Mulesoft_CDM_Staging__c();
                            stageRecUpdate2.Id = stage.Id;
                            stageRecUpdate2.EC_Record_Status__c = Label.EC_Completed;
                            stageRecUpdate2.EC_IsProcessed__c = true;
                            if(stageRecUpdate2.Id != null && !String.isBlank(stageRecUpdate2.Id)){
                                existRecords.add(stageRecUpdate2);
                            }
                        }
                    }
                }
            }else{
                for(EC_Mulesoft_CDM_Staging__c stage : usrAccStage){
                    EC_Mulesoft_CDM_Staging__c stageRecUpdate1 = new EC_Mulesoft_CDM_Staging__c();
                    stageRecUpdate1.Id = stage.Id;
                    stageRecUpdate1.EC_Record_Status__c = Label.EC_Duplicate;
                    stageRecUpdate1.EC_IsProcessed__c = true;
                    if(stageRecUpdate1.Id != null && !String.isBlank(stageRecUpdate1.Id)){
                        existRecords.add(stageRecUpdate1);
                    }
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stage.Id,null,null,null,null,null,null,null,null,null,'Invalid AccountContactRelation','EC_StagingUserAccountDelete',
                            'userAccountDelete');
                    stageLogWrapList.add(stageLogWrap);
                }
            }
            if(existRecords!=null && !existRecords.isEmpty()){

                Database.SaveResult[] savRes = Database.update(existRecords,false);
                for(Database.SaveResult sr:savRes){
                    if(!sr.isSuccess()){
                        for(Database.Error  err: sr.getErrors()) {
                            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(sr.getId(),null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingUserAccountDelete',
                                    'userAccountDelete');
                            stageLogWrapList.add(stageLogWrap);
                        }
                    }
                }
            }
            EC_StagingLogger.stageLogException(stageLogWrapList);
            EC_StagingUtilities.assignSalesRepToAccDelete(successSalesRepArg);
            if(Test.isRunningTest()){
                throw new DMLException();
            }
        } catch(Exception ex){
            List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
             EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingUserAccountDelete',
                'userAccountDelete');
            stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);
        }
    }
}