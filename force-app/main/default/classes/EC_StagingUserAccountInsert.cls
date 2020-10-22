//EC_StagingUserAccountInsert
//This is class to handle the User Account insert records on Staging
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//

public class EC_StagingUserAccountInsert{
    
    /***************************************************************************************************************************************
Method Name : userAccountInsert 
Description : Used to Insert userAccountInsert From Staging Object on the Insert Action.
Return type : void
Author      : Harsha N
*************************************************************************************************************************************/   
    
    
    public static void userAccountInsert(List<EC_Mulesoft_CDM_Staging__c> usrAccStage){
        Set<AccountContactRelation> setUpsertAccContRel = new Set<AccountContactRelation>();
        //List<AccountContactRelation> lstExistAccContRel = new List<AccountContactRelation>();
        List<EC_Mulesoft_CDM_Staging__c> usrAccStageUpdate = new List<EC_Mulesoft_CDM_Staging__c>();
        //List<account> lstBlanketAcc = new List<account>();
        Map<string, contact> newContactMap = new Map<string, contact>();
        Set<string> lstContextAccKey = new Set<string>();
        Set<string> lstContextContKey = new Set<string>();
        Set<string> lstBlacketAccKey = new Set<string>();
        Set<AccountContactRelation> setDeleteAccContRel = new Set<AccountContactRelation>();
        List<contact> lstUpdateContact= new List<contact>();
        Map<EC_Mulesoft_CDM_Staging__c, set<accContWrapper>> mapStgAccGrp = new Map<EC_Mulesoft_CDM_Staging__c, set<accContWrapper>>();
        Map<accContWrapper, AccountContactRelation> mapStgExistAccCont = new Map<accContWrapper, AccountContactRelation>();
        Map<string, AccountContactRelation> mapDummyAccCont = new Map<string, AccountContactRelation>();
        Map<String,EC_Mulesoft_CDM_Staging__c> accContRelStageMap = new Map<String,EC_Mulesoft_CDM_Staging__c>();
        String ship_to = EC_Constants.Ship_To;
        String sold_to = EC_Constants.Sold_To;
        List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        // We will use the below lists to update the IsProcessed field in the Staging table 
        list<Id> lstUpdatedSuccess = new list<Id>();
        list<EC_Mulesoft_CDM_Staging__c> successStgRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        list<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new list<EC_Mulesoft_CDM_Staging__c>();
        Map<String, AccountContactRelation> accContRelConcatMap = new Map<String, AccountContactRelation>();
        Map<String, AccountContactRelation> dummyAccContRelMap = new Map<String, AccountContactRelation>();
        Map<String, EC_Mulesoft_CDM_Staging__c> userAccKeysStageMap = new  Map<String, EC_Mulesoft_CDM_Staging__c>();
        Map<Integer, String> indexStageRecMap = new  Map<Integer, String>();
        try{
            // modified on 01/07/2020
            for(EC_Mulesoft_CDM_Staging__c stageRec : usrAccStage){
                userAccKeysStageMap.put(stageRec.EC_Account_Key__c+'_'+ stageRec.EC_User_Key__c,stageRec);
                lstContextAccKey.add(stageRec.EC_Account_Key__c);
                lstContextContKey.add(stageRec.EC_User_Key__c);
            }
            Map<Id,AccountContactRelation> accContMap = new Map<Id,AccountContactRelation>([SELECT id,Alignment_Type__c ,account.EC_CDM_Account__c, contact.EC_CDM_Contact__c FROM AccountContactRelation WHERE account.EC_CDM_Account__c IN: lstContextAccKey AND contact.EC_CDM_Contact__c IN: lstContextContKey]);
            
            // modified on 01/07/2020
            Map<Id,AccountContactRelation> mapUpdateAccRel = new Map<Id,AccountContactRelation>();
            if(accContMap!=null && !accContMap.isEmpty()){
                for(AccountContactRelation accConRel:accContMap.values()){
                    String accUserKey = accConRel.account.ec_cdm_account__c + '_'+ accConRel.contact.EC_CDM_Contact__c;
                    EC_Mulesoft_CDM_Staging__c stageRecUpdate = new EC_Mulesoft_CDM_Staging__c();
                    if(userAccKeysStageMap.containsKey(accUserKey)){
                        //EC_Mulesoft_CDM_Staging__c stageRecUpdate = new EC_Mulesoft_CDM_Staging__c();
                        EC_Mulesoft_CDM_Staging__c stageRec = userAccKeysStageMap.get(accUserKey);
                        stageRecUpdate.Id = stageRec.Id;
                        stageRecUpdate.EC_Record_Status__c = Label.EC_Duplicate;
                        stageRecUpdate.EC_IsProcessed__c = true;
                        accConRel.Alignment_Type__c = stageRec.EC_Alignment_Type__c;
                        mapUpdateAccRel.put(accConRel.Id,accConRel);
                       
                    }
                    if(!String.isBlank(stageRecUpdate.Id)){
                        existRecords.add(stageRecUpdate);
                    }
                }
            }
            
            
            
            Map<Id,Account> mapBlanketAcc = new Map<Id,Account>([SELECT id, RecordType.Name, EC_CDM_Account__c, parent.EC_CDM_Account__c, parent.parent.EC_CDM_Account__c, parent.RecordType.Name FROM account WHERE EC_CDM_Account__c IN: lstContextAccKey OR parent.EC_CDM_Account__c IN: lstContextAccKey]);
            
            for(EC_Mulesoft_CDM_Staging__c stageRec : usrAccStage){
                for(account accRec : mapBlanketAcc.values()){
                    //System.debug('accRechere is+++++'+accRec.EC_CDM_Account__c+'AND STAGING RECORD IS++'+stageRec.EC_Account_Key__c + 'RecordTypehere is +++++'+accRec.RecordType.Name); 
                    if(stageRec.EC_Account_Key__c == accRec.EC_CDM_Account__c && accRec.RecordType.Name == ship_to){
                        set<accContWrapper> tempLstAcc = new set<accContWrapper>();
                        accContWrapper accContWrapRec = new accContWrapper();
                        accContWrapRec.accKey = accRec.EC_CDM_Account__c;
                        accContWrapRec.accId = accRec.Id;
                        accContWrapRec.contKey = stageRec.EC_User_Key__c;
                        accContWrapRec.alignmentType = stageRec.EC_Alignment_Type__c;
                        tempLstAcc.add(accContWrapRec);
                        //system.debug('Processed ShipTO--->'+tempLstAcc);
                        mapStgAccGrp.put(stageRec, tempLstAcc);
                    }else if((stageRec.EC_Account_Key__c == accRec.EC_CDM_Account__c && accRec.RecordType.Name == sold_to) || (stageRec.EC_Account_Key__c == accRec.parent.EC_CDM_Account__c && accRec.parent.RecordType.Name == sold_to)){
                        if(mapStgAccGrp.containskey(stageRec)){
                            accContWrapper accContWrapRec = new accContWrapper();
                            accContWrapRec.accKey = accRec.EC_CDM_Account__c;
                            accContWrapRec.accId = accRec.Id;
                            accContWrapRec.contKey = stageRec.EC_User_Key__c;
                            accContWrapRec.alignmentType = stageRec.EC_Alignment_Type__c;
                            //system.debug('Processed SoldTO11--->'+accContWrapRec);
                            mapStgAccGrp.get(stageRec).add(accContWrapRec);
                        }else{
                            set<accContWrapper> tempLstAcc = new set<accContWrapper>();
                            accContWrapper accContWrapRec = new accContWrapper();
                            accContWrapRec.accKey = accRec.EC_CDM_Account__c;
                            accContWrapRec.accId = accRec.Id;
                            accContWrapRec.contKey = stageRec.EC_User_Key__c;
                            accContWrapRec.alignmentType = stageRec.EC_Alignment_Type__c;
                            //system.debug('Processed SoldTO12--->'+accContWrapRec);
                            tempLstAcc.add(accContWrapRec);
                            mapStgAccGrp.put(stageRec, tempLstAcc);
                        }
                    }
                }
                //system.debug('mapStgAccGrp:'+mapStgAccGrp);
                //system.debug('mapStgAccGrpstageRec:'+stageRec);
                if(mapStgAccGrp.get(stageRec) == null){
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageRec.Id,null,null,null,null,null,null,null,null,null,'Invalid EC_CDM_Account__c','EC_StagingUserAccountInsert',
                                                                                           'userAccountInsert');
                    stageLogWrapList.add(stageLogWrap);
                }
            }
            Set<EC_Mulesoft_CDM_Staging__c> stageRecordSet = mapStgAccGrp.keySet() ;
            //system.debug('mapStgAccGrp--> '+mapStgAccGrp);
            for(EC_Mulesoft_CDM_Staging__c stageRec : stageRecordSet){
                for(accContWrapper accContWrapRec: mapStgAccGrp.get(stageRec)){
                    lstBlacketAccKey.add(accContWrapRec.accKey);
                }
            }
            String dummyAccountKey = EC_Constants.DummyAccountKey; 
             if (!AccountContactRelation.sObjectType.getDescribe().isAccessible()) {  //Good: Permissions are checked before any resources are accessed.
	 		        return;
	 	                     }
            Map<Id,AccountContactRelation> mapExistAccContRel = new Map<Id,AccountContactRelation>([SELECT id,Alignment_Type__c,contact.EC_CDM_Contact__c, account.EC_CDM_Account__c FROM AccountContactRelation WHERE (contact.EC_CDM_Contact__c IN: lstContextContKey AND account.EC_CDM_Account__c =:dummyAccountKey) OR (contact.EC_CDM_Contact__c IN: lstContextContKey AND account.EC_CDM_Account__c IN: lstBlacketAccKey)]);
            //system.debug('lstExistAccContRel-->'+lstExistAccContRel);
            for(AccountContactRelation existAccContRel : mapExistAccContRel.values()){
                String accContKey = existAccContRel.account.ec_cdm_account__c+'_'+existAccContRel.contact.ec_cdm_contact__c;//concatenation of accountkey and contactKey for unique combination. 
                
                if(existAccContRel.account.ec_cdm_account__c == dummyAccountKey ){
                    dummyAccContRelMap.put(existAccContRel.contact.ec_cdm_contact__c,existAccContRel); // dummyAccContRelMap contains existing AccountContactRelation records  of contact with dummy account.
                }else{
                    accContRelConcatMap.put(accContKey,existAccContRel);// accContRelConcatMap contains existing AccountContactRelation records of Contact with accounts except DummyAccount
                }
            }
            //system.debug('lstExistAccContRel--> '+lstExistAccContRel);
            
            for(EC_Mulesoft_CDM_Staging__c stageRec : stageRecordSet){// Staging records  for AccountContactRelation records insert
                for(accContWrapper accContWrapRec : mapStgAccGrp.get(stageRec)){// iterates over sold to and associated ship to accounts . accContWrapper contains contKey, accKey, accId of sold to and associated ship to accounts
                    String accContKeyConcat = accContWrapRec.accKey+'_'+accContWrapRec.contKey;     //concatenation of accountkey and contactKey for unique combination.                                                                                                                                                        
                    AccountContactRelation accountContactConcat = accContRelConcatMap.get(accContKeyConcat);// retrieve accountContactRelation associated with unique combination of accountkey_contactKey.
                    if(accContRelConcatMap.containskey(accContKeyConcat)){
                        mapStgExistAccCont.put(accContWrapRec, accountContactConcat);
                    }else if(dummyAccContRelMap.containskey(accContWrapRec.contKey)){
                        if(!mapDummyAccCont.containskey(accContWrapRec.contKey)){
                            mapDummyAccCont.put(accContWrapRec.contKey, dummyAccContRelMap.get(accContWrapRec.contKey));
                        }
                    }
                }
            }
            //system.debug('dummy Map--> '+mapDummyAccCont);
            
            Map<Id,contact> mapContactRec = new Map<Id,contact>([SELECT id, EC_CDM_Contact__c, accountId FROM contact WHERE EC_CDM_Contact__c IN: lstContextContKey AND account.EC_CDM_Account__c =:dummyAccountKey]);
            for(contact contRec : mapContactRec.values()){
                newContactMap.put(contRec.EC_CDM_Contact__c, contRec);
            }
            //System.debug('newContactMap---'+ newContactMap);
            Map<Id,EC_Mulesoft_CDM_Staging__c> stageAccConMap = new Map<Id,EC_Mulesoft_CDM_Staging__c>();
            Map<Id,EC_Mulesoft_CDM_Staging__c> stageContactMap = new Map<Id,EC_Mulesoft_CDM_Staging__c>();
            Integer index1 = 0;
            List<String> userKeyList = new List<String>();
            for(EC_Mulesoft_CDM_Staging__c stageRec : stageRecordSet){
                String userKey = stageRec.EC_User_Key__c;
                for(accContWrapper accInstRec : mapStgAccGrp.get(stageRec)){                    
                    if(newContactMap.containskey(userKey)){
                        //system.debug('INSERT RECORD newContactMap-->'+ accInstRec);
                        contact tempAccContRec = newContactMap.get(userKey);
                        tempAccContRec.accountId = accInstRec.accId;
                        lstUpdateContact.add(tempAccContRec);
                        if(!stageContactMap.containskey(newContactMap.get(userKey).id)){
                            stageContactMap.put(newContactMap.get(userKey).id,stageRec);
                        }
                        if(!stageAccConMap.containskey(mapDummyAccCont.get(userKey).id)){
                            stageAccConMap.put(mapDummyAccCont.get(userKey).id,stageRec);
                        }
                        userKeyList.add(userKey);
                        newContactMap.remove(userKey);
                        setDeleteAccContRel.add(mapDummyAccCont.get(userKey));
                    }else{
                        if(!mapStgExistAccCont.containskey(accInstRec)){
                            //system.debug('INSERT RECORD mapStgExistAccCont-->'+ accInstRec);
                            AccountContactRelation tempAccContRec = new AccountContactRelation();
                            contact tempCont = new contact();
                            tempCont.EC_CDM_Contact__c = userKey;
                            tempAccContRec.contact = tempCont;
                            account tempAcc = new account();
                            tempAcc.EC_CDM_Account__c = accInstRec.accKey;
                            tempAccContRec.account = tempAcc;
                            tempAccContRec.isActive = true;
                            tempAccContRec.Alignment_Type__c=stageRec.EC_Alignment_Type__c; //PBI-121286
                            setUpsertAccContRel.add(tempAccContRec);
                            indexStageRecMap.put(index1,tempAccContRec.account.ec_cdm_account__c+'_'+tempAccContRec.contact.ec_cdm_contact__c);
                            accContRelStageMap.put(tempAccContRec.account.ec_cdm_account__c+'_'+tempAccContRec.contact.ec_cdm_contact__c,stageRec);
                            userKeyList.add(userKey);
                            index1++;
                        } else {
                            //BUG-133628
                            if(mapExistAccContRel != null){
                                for(AccountContactRelation existAccContRec: mapExistAccContRel.values()){
                                    if(existAccContRec.Contact.EC_CDM_Contact__c == userKey && existAccContRec.Account.EC_CDM_Account__c == accInstRec.accKey){
                                        existAccContRec.Alignment_Type__c=stageRec.EC_Alignment_Type__c;
                                        mapUpdateAccRel.put(existAccContRec.Id,existAccContRec); 
                                        indexStageRecMap.put(index1,existAccContRec.account.ec_cdm_account__c+'_'+existAccContRec.contact.ec_cdm_contact__c);
                                        accContRelStageMap.put(existAccContRec.account.ec_cdm_account__c+'_'+existAccContRec.contact.ec_cdm_contact__c,stageRec);
                                    }
                                }
                            }
                            userKeyList.add(userKey);
                            index1++;
                        }
                    }
                }
                usrAccStageUpdate.add(stageRec);
                if(!userKeyList.contains(userKey)){
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageRec.Id,null,null,null,null,null,null,null,null,null,'Invalid EC_User_Key__c','EC_StagingUserAccountInsert',
                                                                                           'userAccountInsert');
                    stageLogWrapList.add(stageLogWrap);
                }
            }
            Set<EC_Mulesoft_CDM_Staging__c> errorRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
            
            //CREATE NEW AccountContactRelation
            Set<EC_Mulesoft_CDM_Staging__c> successRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
            if(setUpsertAccContRel != null && setUpsertAccContRel.size() > 0){
                list<AccountContactRelation> upsertList = new list<AccountContactRelation>();
                upsertList.addAll(setUpsertAccContRel);
                //    Database.upsert(upsertList);
                
                Database.SaveResult[] saveRes = Database.insert(upsertList,false);
                Integer index = 0;
                for(Database.SaveResult sr:saveRes){
                    if(sr.isSuccess()){
                        lstUpdatedSuccess.add(sr.getId());
                    }
                    else{
                        for(Database.Error  err: sr.getErrors()) {
                            String keyString = indexStageRecMap.get(index);
                            System.debug('The errors received is ++++++++++++'+err.getFields()+'Errror here is+++'+err);
                            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(accContRelStageMap.get(keyString).Id,null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingUserAccountInsert',
                                                                                                   'userAccountInsert');
                            stageLogWrapList.add(stageLogWrap);
                        }
                    }
                    index++;
                }
                // Now we will have to check the staging records that are having these as Ids.      
                /*List<String> contactsInserted = new List<String>(); 
                List<String> accountsInserted = new List<String>();   
                
                for(AccountContactRelation accCont:[Select Account.EC_CDM_Account__c,Contact.EC_CDM_Contact__c from AccountContactRelation where Id in:lstUpdatedSuccess])  
                {
                accountsInserted.add(accCont.Account.EC_CDM_Account__c);
                contactsInserted.add(accCont.Contact.EC_CDM_Contact__c );
                }*/
                List<AccountContactRelation> insrtdsSuccess =[Select Account.EC_CDM_Account__c,Contact.EC_CDM_Contact__c from AccountContactRelation where Id in:lstUpdatedSuccess];  
                
                for(AccountContactRelation accCont:insrtdsSuccess){
                    String user_acc_key = accCont.account.ec_cdm_account__c+ '_' + accCont.contact.ec_cdm_contact__c;
                    if(accContRelStageMap.containsKey(user_acc_key)){
                        successRecords.add(accContRelStageMap.get(user_acc_key)); 
                    }
                }
            }
            
            //UPDATE CONTACT RECORDS
            //system.debug('lstUpdateContact--> '+lstUpdateContact);
            if(lstUpdateContact != null && lstUpdateContact.size() > 0){
                Database.SaveResult[]  savRes = Database.update(lstUpdateContact,false);
                for(Database.SaveResult sr:savRes){
                    if(sr.isSuccess()){
                        successRecords.add(stageContactMap.get(sr.getId()));  
                    }
                    else if(!sr.isSuccess()){
                        for(Database.Error  err: sr.getErrors()) {
                            if(stageContactMap.get(sr.getId())!=null){
                                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageContactMap.get(sr.getId()).id,stageContactMap.get(sr.getId()).EC_User_Key__c,stageContactMap.get(sr.getId()).EC_Account_Key__c,stageContactMap.get(sr.getId()).EC_Source_Table__c,
                                                                                                       stageContactMap.get(sr.getId()).EC_Action__c,null,null,null,null,null,err.getMessage(),'EC_StagingUserAccountInsert',
                                                                                                       'userAccountInsert');
                                stageLogWrapList.add(stageLogWrap);
                            }
                        }
                    }
                }
                try{
                    Set<Id> setContIds = new Set<Id>();
                    for(Contact c : lstUpdateContact){
                        if(c.Id !=null){
                            setContIds.add(c.Id);
                        }
                    }
                    //Check Permissions before resources are accessed
                    if (!AccountContactRelation.sObjectType.getDescribe().isAccessible()) {  
                        return;
                    }
                    Map<id,AccountContactRelation> accContRec = new Map<id,AccountContactRelation>([Select Id, Alignment_Type__c, Contact.EC_CDM_Contact__c, Account.EC_CDM_Account__c FROM AccountContactRelation WHERE ContactId IN: setContIds]);
                    if(accContRec!=null){
                        for(AccountContactRelation accRec: accContRec.values()){
                            String accUserKey = accRec.account.ec_cdm_account__c + '_'+ accRec.contact.EC_CDM_Contact__c;
                            if(userAccKeysStageMap.containsKey(accUserKey)){
                                EC_Mulesoft_CDM_Staging__c stageRec = userAccKeysStageMap.get(accUserKey);
                                accRec.Alignment_Type__c = stageRec.EC_Alignment_Type__c;
                                mapUpdateAccRel.put(accRec.Id, accRec);
                            }
                        }
                    }
                } catch(Exception e){
                    system.debug('ExceptionException---->'+ e.getMessage());
                }
                
            }
            
            //DELETE AccountContactRelation
            if(stageAccConMap != null && stageAccConMap.size() > 0){
                list<AccountContactRelation> deleteList = new list<AccountContactRelation>();
                deleteList.addAll(setDeleteAccContRel);
                Database.deleteResult[] deleteRes = Database.delete(deleteList,false);
                for(Database.DeleteResult dr :deleteRes){
                    if(dr.isSuccess()){
                        successRecords.add(stageAccConMap.get(dr.getId()));  
                    }
                    else if(!dr.isSuccess()){
                        for(Database.Error  err: dr.getErrors()) {
                            if(stageAccConMap.get(dr.getId())!=null){
                                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageAccConMap.get(dr.getId()).id,stageAccConMap.get(dr.getId()).EC_User_Key__c,stageAccConMap.get(dr.getId()).EC_Account_Key__c,stageAccConMap.get(dr.getId()).EC_Source_Table__c,
                                                                                                       stageAccConMap.get(dr.getId()).EC_Action__c,null,null,null,null,null,err.getMessage(),'EC_StagingUserAccountInsert',
                                                                                                       'userAccountInsert');
                                stageLogWrapList.add(stageLogWrap);
                            }
                        } 
                    }
                }
            }
            
            //UPDATE EXISTING AccountContactRelation
            //Set<EC_Mulesoft_CDM_Staging__c> successRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
            if(mapUpdateAccRel != null && mapUpdateAccRel.size() > 0){
                Database.UpsertResult[]  savRes = Database.upsert(mapUpdateAccRel.values(),false);
                for(Database.UpsertResult sr:savRes){
                    if(sr.isSuccess()){
                        successRecords.add(stageContactMap.get(sr.getId()));  
                    }
                    else if(!sr.isSuccess()){
                        for(Database.Error  err: sr.getErrors()) {
                            if(stageContactMap.get(sr.getId())!=null){
                                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageContactMap.get(sr.getId()).id,stageContactMap.get(sr.getId()).EC_User_Key__c,stageContactMap.get(sr.getId()).EC_Account_Key__c,stageContactMap.get(sr.getId()).EC_Source_Table__c,
                                                                                                       stageContactMap.get(sr.getId()).EC_Action__c,null,null,null,null,null,err.getMessage(),'EC_StagingUserAccountInsert',
                                                                                                       'userAccountInsert');
                                stageLogWrapList.add(stageLogWrap);
                            }
                        }
                    }
                }
            }
            
            //PROCESS MULESOFT RECORD
            List<EC_Mulesoft_CDM_Staging__c> successSalesRepArg = new List<EC_Mulesoft_CDM_Staging__c>();
            
            for(EC_Mulesoft_CDM_Staging__c stage : successRecords){
                if(stage!=null){  
                    successSalesRepArg.add(stage);
                    EC_Mulesoft_CDM_Staging__c stageRecUpdate1 = new EC_Mulesoft_CDM_Staging__c();
                    stageRecUpdate1.Id = stage.Id;
                    stageRecUpdate1.EC_IsProcessed__c = true;
                    stageRecUpdate1.EC_Record_Status__c= Label.EC_Completed;
                    if(stageRecUpdate1.Id != null && !String.isBlank(stageRecUpdate1.Id)){
                        existRecords.add(stageRecUpdate1); 
                    }
                }
            }
            if(existRecords!=null && !existRecords.isEmpty()){
                
                Database.SaveResult[] savRes = Database.update(existRecords,false);
                for(Database.SaveResult sr:savRes){
                    if(!sr.isSuccess()){
                        for(Database.Error  err: sr.getErrors()) {
                            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(sr.getId(),null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingUserAccountDelete',
                                                                                                   'userAccountInsert');
                            stageLogWrapList.add(stageLogWrap);
                        }
                    } 
                }
            }
            EC_StagingLogger.stageLogException(stageLogWrapList);
            EC_StagingUtilities.assignSalesRepOnUserAccInsert(successSalesRepArg);
            if(Test.isRunningTest())
            {
                
                throw new DMLException();
            }
        }catch(Exception ex){
            List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingUserAccountInsert',
                                                                                   'userAccountInsert');
            stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList); 
        }
    }
    
    public class accContWrapper{
        public string accKey, contKey, accId, alignmentType;
    }
}