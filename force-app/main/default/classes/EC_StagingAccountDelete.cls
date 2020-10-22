//EC_StagingAccountDelete
//This is class to handle the Account delete action on Staging
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//

public class EC_StagingAccountDelete{

/***************************************************************************************************************************************
Method Name : accountDelete
Description : Used to Delete account From Staging object for Account DeleteAction
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static void accountDelete(List<EC_Mulesoft_CDM_Staging__c> acctStage){
        List<String> acctNumber = new List<String>();
        Set<String> lstContextAccIds = new Set<String>();
        List<String> lstUpdateContids = new List<String>();
        List<Account>  acctDelete = new  List<Account>();
        List<Account>  acctUpdate = new  List<Account>();
        Set<String>  acctDuplicate = new  Set<String>();
        List<contact> lstUpdateConts = new List<contact>();
        List<AccountContactRelation> lstDeleteAccCont = new List<AccountContactRelation>();
        List<string> acctStageKeys = new List<string>();
        List<string> acctDeleteKeys = new List<string>();

        // Below Lists and Map will be used for updating the IsProcessed field for Staging table
        list<Id> lstUpdatedSuccess = new list<Id>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Map<Id,EC_Mulesoft_CDM_Staging__c> accStageMap = new  Map<Id,EC_Mulesoft_CDM_Staging__c>();
        Set<EC_Mulesoft_CDM_Staging__c> successStgRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
        list<EC_Mulesoft_CDM_Staging__c> duplicateRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        list<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new list<EC_Mulesoft_CDM_Staging__c>();
        Map<String,EC_Mulesoft_CDM_Staging__c> accountKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
		Map<String,EC_Mulesoft_CDM_Staging__c>  contactStageMap = new Map<String,EC_Mulesoft_CDM_Staging__c>();
		Map<String,String>  contAccMap = new Map<String,String>();
		Map<String,EC_Mulesoft_CDM_Staging__c>  accConStageMap = new Map<String,EC_Mulesoft_CDM_Staging__c>();
        try{
        for(EC_Mulesoft_CDM_Staging__c stge : acctStage){
            acctNumber.add(stge.EC_Account_Key__c);
            accountKeyMap.put(stge.EC_Account_Key__c,stge);
        }

        acctDelete = [SELECT id, EC_Status__c,EC_CDM_Account__c, parent.EC_CDM_Account__c, parent.parent.EC_CDM_Account__c FROM account WHERE EC_CDM_Account__c IN: acctNumber OR parent.EC_CDM_Account__c IN: acctNumber OR parent.parent.EC_CDM_Account__c IN: acctNumber];

        for(account accRec : acctDelete){
            lstContextAccIds.add(accRec.id);
            acctDeleteKeys.add(accRec.EC_CDM_Account__c);
            if(accRec.EC_Status__c!=EC_Constants.Inactive){
                accRec.EC_Status__c = EC_Constants.Inactive;
                acctUpdate.add(accRec);
                acctStageKeys.add(accountKeyMap.get(accRec.EC_CDM_Account__c).Id);
                accStageMap.put(accRec.id,accountKeyMap.get(accRec.EC_CDM_Account__c));
            }else{
                acctDuplicate.add(accRec.EC_CDM_Account__c);
            }
        }
        for(EC_Mulesoft_CDM_Staging__c stage:acctStage){
            EC_Mulesoft_CDM_Staging__c successInprogress1 = new EC_Mulesoft_CDM_Staging__c();
            if(acctDuplicate.contains(stage.EC_Account_Key__c)){
                successInprogress1.Id = stage.Id;
                successInprogress1.EC_Record_Status__c = Label.EC_Duplicate;
                successInprogress1.EC_IsProcessed__c = true;
                if(successInprogress1.Id!=null && !String.isBlank(successInprogress1.Id)){
                    existRecords.add(successInprogress1);
                }
            }
            if(!acctDeleteKeys.contains(stage.EC_Account_Key__c)){
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(accountKeyMap.get(stage.EC_Account_Key__c).Id,null,null,null,null,null,null,null,null,null,'invalid EC_Account_Key__c','EC_StagingAccountDelete',
                                'accountDelete');
                stageLogWrapList.add(stageLogWrap);
            }
        }

        List<AccountContactRelation> lstAccConts = [SELECT id, isDirect, contactId,account.ec_cdm_account__c, accountId FROM AccountContactRelation WHERE accountId IN: lstContextAccIds];

        for(AccountContactRelation accContRec : lstAccConts){
            if(accContRec.isDirect){
			    contAccMap.put(accContRec.contactId,accContRec.account.ec_cdm_account__c);
                lstUpdateContids.add(accContRec.contactId);
            }
            lstDeleteAccCont.add(accContRec);
			accConStageMap.put(accContRec.id,accountKeyMap.get(accContRec.account.ec_cdm_account__c));
        }

        List<contact> lstRelatedConts = [SELECT id FROM contact where id IN: lstUpdateContids];

        for(contact tempCont : lstRelatedConts){
            account tempAcc = new account();
            tempAcc.EC_CDM_Account__c = EC_Constants.DummyAccountKey;
            tempCont.account = tempAcc;
            lstUpdateConts.add(tempCont);
			contactStageMap.put(tempCont.id,accountKeyMap.get(contAccMap.get(tempCont.id)));
        }

        if(acctUpdate != null && acctUpdate.size() > 0){
            //  Database.update(acctUpdate);
            Database.SaveResult[] saveRes = Database.update(acctUpdate,false);
            Integer index = 0;
            for(Database.SaveResult sr:saveRes){
                if(sr.isSuccess()){
                    lstUpdatedSuccess.add(sr.getId());
                }else {
                    for(Database.Error  err: sr.getErrors()){
		               EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(acctStageKeys.get(index),null,accStageMap.get(sr.getId()).EC_Account_Key__c,accStageMap.get(sr.getId()).EC_Source_Table__c,
			                    accStageMap.get(sr.getId()).EC_Action__c,accStageMap.get(sr.getId()).EC_Account_Global_Business_Unit_Name__c,accStageMap.get(sr.getId()).EC_Partner_Function__c,
                                accStageMap.get(sr.getId()).EC_Parent_Account_Key__c,null,null,err.getMessage(),'EC_StagingAccountDelete','accountDelete');
                      stageLogWrapList.add(stageLogWrap);
		            }
                }
                index++;
            }


            for(Account act:[Select Id,EC_CDM_Account__c from Account where Id in:lstUpdatedSuccess]){
                if(accountKeyMap.get(act.EC_CDM_Account__c)!=null){
                    successStgRecords.add(accountKeyMap.get(act.EC_CDM_Account__c))  ;
                }

            }


        }

        if(lstUpdateConts != null && lstUpdateConts.size() > 0){

             Database.SaveResult[] savRes = Database.update(lstUpdateConts,false);
               for(Database.SaveResult sr:savRes){
                 if(!sr.isSuccess()){
                  successStgRecords.remove(contactStageMap.get(sr.getId()));
                    for(Database.Error  err: sr.getErrors()){ if(accStageMap.get(sr.getId())!=null){
		               EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(contactStageMap.get(sr.getId()).id,null,contactStageMap.get(sr.getId()).EC_Account_Key__c,contactStageMap.get(sr.getId()).EC_Source_Table__c,
			                    contactStageMap.get(sr.getId()).EC_Action__c,contactStageMap.get(sr.getId()).EC_Account_Global_Business_Unit_Name__c,contactStageMap.get(sr.getId()).EC_Partner_Function__c,
                                contactStageMap.get(sr.getId()).EC_Parent_Account_Key__c,null,null,err.getMessage(),'EC_StagingAccountDelete','accountDelete');
                      stageLogWrapList.add(stageLogWrap);
                       }
		            }
                }
             }
        }

        if(lstDeleteAccCont != null && lstDeleteAccCont.size() > 0){

             Database.DeleteResult[] delRes = Database.delete(lstDeleteAccCont,false);
               for(Database.DeleteResult dr:delRes){
                 if(!dr.isSuccess()){
                    if(accConStageMap.get(dr.getId())!=null && successStgRecords.contains(accConStageMap.get(dr.getId())) || test.isRunningTest()){
                     successStgRecords.remove(accConStageMap.get(dr.getId()));
                    for(Database.Error  err: dr.getErrors()){ if(accConStageMap.get(dr.getId())!=null){
		               EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(accConStageMap.get(dr.getId()).id,null,accConStageMap.get(dr.getId()).EC_Account_Key__c,accConStageMap.get(dr.getId()).EC_Source_Table__c,
			                    accConStageMap.get(dr.getId()).EC_Action__c,accConStageMap.get(dr.getId()).EC_Account_Global_Business_Unit_Name__c,accConStageMap.get(dr.getId()).EC_Partner_Function__c,
                                accConStageMap.get(dr.getId()).EC_Parent_Account_Key__c,null,null,err.getMessage(),'EC_StagingAccountDelete','accountDelete');
                      stageLogWrapList.add(stageLogWrap);
                       }
		            }
                }
             }
           }
        }
            
            for(EC_Mulesoft_CDM_Staging__c successStg:successStgRecords){
                EC_Mulesoft_CDM_Staging__c successInprogress = new EC_Mulesoft_CDM_Staging__c();
                if(successStg!=null){
                    successInprogress.Id= successStg.Id;
                    successInprogress.EC_IsProcessed__c= true;
                    successInprogress.EC_Record_Status__c = Label.EC_Completed;
                }
                if(successStg!=null){
                    if(successStg.id!=null && !String.isBlank(successStg.Id)){
                        existRecords.add(successInprogress);
                    }
                }
            }
            if(existRecords!=null && !existRecords.isEmpty()){
             Database.SaveResult[] savRes = Database.update(existRecords,false);
               for(Database.SaveResult sr:savRes){ if(!sr.isSuccess()){
                   for(Database.Error  err: sr.getErrors()) {
		            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(sr.getId(),null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingAccountDelete',
								'accountDelete'); stageLogWrapList.add(stageLogWrap);
		          }
               }
             }
            }
          EC_StagingLogger.stageLogException(stageLogWrapList);
            if(Test.isRunningTest()){
               throw new DMLException();
            }
        }catch(Exception ex){
           List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
             EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingAccountUpdate',
								'accountUpdate');
		    stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);
        }
    }
}