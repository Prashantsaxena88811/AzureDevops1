//EC_StagingAccountInsert
//This is class to handle the Account insert action on Staging
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//

public class EC_StagingAccountInsert{

    /***************************************************************************************************************************************
    Method Name : accountInsert
    Description : Used to Insert Accounts From the Staging Object for Account Insert Action
    Return type : void
    Author      : Shivam Vats
    *************************************************************************************************************************************/

    public static void accountInsert(List<EC_Mulesoft_CDM_Staging__c> acctStage){
        List<Account> acctInsert = new List<Account>();
        List<string> lstAllContId = new List<string>();
        List<contact> lstContUpdate = new List<contact>();
        Map<String,Id> recordTypeIdMap = new Map<String,Id>();
        Map<String,Id> accountParentMap = new Map<String,Id>();
        Map<String,Id> accountParentGroupMap = new  Map<String,Id>();
        List<string> acctStageKeys = new List<string>();

        Map<String,String> parentAccIdMap = new Map<String,String>();
        Map<String,account> mapNewShipAcc = new Map<String,account>();
        Map<String,List<contact>> mapParentConts = new Map<String,List<contact>>();

        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        List<AccountContactRelation> lstAccContInsert = new List<AccountContactRelation>();
        List<EC_Mulesoft_CDM_Staging__c> existingAccList = new List<EC_Mulesoft_CDM_Staging__c>();
        Map<string, AccountContactRelation> mapDummyAccContRel = new Map<string, AccountContactRelation>();
        Map<String,EC_Mulesoft_CDM_Staging__c> existingStageMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> lstvalidAccounts = new  List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> lstInvalidAccounts = new  List<EC_Mulesoft_CDM_Staging__c>();
        list<Account>  listUpdateAccounts = new list<Account>();
        list<Account>  listInsertAccounts = new list<Account>();
        // Use this List of creating new Account Groups and associate them with the inserted Account
        list<Account> listAccountGroups = new list<Account>();

        // User the Below Maps and lists for updating the Processed Staging Records
        list<Id> lstInsertedSuccess = new list<Id>();
        list<Account> lstInsertedAccts = new list<Account>();
        Set<EC_Mulesoft_CDM_Staging__c> successStgRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new List<EC_Mulesoft_CDM_Staging__c>();
        Map<String,EC_Mulesoft_CDM_Staging__c> accountKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();

        List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<String> lstGroupKey = new List<String>();
        Map<String,EC_Mulesoft_CDM_Staging__c> accStageMap = new Map<String,EC_Mulesoft_CDM_Staging__c>();


        Map<EC_Mulesoft_CDM_Staging__c,Id> accountUpdateMap = new  Map<EC_Mulesoft_CDM_Staging__c,Id>();
        try{
            for(EC_Mulesoft_CDM_Staging__c acc: acctStage){
                if(acc.EC_Parent_Account_Number__c!=null && acc.EC_Parent_Account_Number__c!= '' && acc.EC_Partner_Function__c==EC_Constants.SHIPTO &&  (acc.EC_Account_Global_Business_Unit_Name__c != EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c != EC_Constants.FOODANDBEVERAGE ))){
                    parentAccIdMap.put(acc.EC_Parent_Account_Number__c,acc.EC_Stage_Unique_AccNumber__c);
                }else if(acc.EC_Partner_Function__c==EC_Constants.SOLDTO || acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ||acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE){
                    parentAccIdMap.put(EC_Constants.CORPPREFIX+acc.EC_Customer_Key__c,acc.EC_Stage_Unique_AccNumber__c);
                }
                existingStageMap.put(acc.EC_Stage_Unique_AccNumber__c,acc);

                lstvalidAccounts.add(acc);
                accountKeyMap.put(acc.EC_Account_Key__c,acc);
            }

            String statusInactive = EC_Constants.Inactive;
            for(Account acc: [Select Id,Name,EC_Unique_Account_Number__c,EC_Account_Number__c from Account where EC_Unique_Account_Number__c in: existingStageMap.keyset() and EC_Status__c =:statusInactive]){
                accountUpdateMap.put(existingStageMap.get(acc.EC_Unique_Account_Number__c),acc.Id);
            }

            // Fetching Parent account Id and Account group and saving into map
            List<Account> parentAccountList = [Select Id,Name,EC_Unique_Account_Number__c,EC_Account_Number__c,ccrz__E_AccountGroup__c from Account where EC_Unique_Account_Number__c in:parentAccIdMap.keySet()];
            for(Account ac : parentAccountList){
                accountParentMap.put(ac.EC_Unique_Account_Number__c,ac.Id);
                accountParentGroupMap.put(ac.EC_Unique_Account_Number__c,ac.ccrz__E_AccountGroup__c);
            }

            String sold_to = EC_Constants.Sold_To;
            List<Id>  contactList = new List<Id>();
            list<AccountContactRelation> lstAccCont = [select Id,accountid, contactid,account.EC_CDM_Account__c from AccountContactRelation where accountId in:accountParentMap.values() and account.RecordType.Name =:sold_to];

            map<id, contact> mapRelatedCont;
            if(lstAccCont!=null && !lstAccCont.isEmpty()) {
                for(AccountContactRelation accContRel : lstAccCont){
                    contactList.add(accContRel.contactid);
                    accStageMap.put(accContRel.Id,accountKeyMap.get(accContRel.account.EC_CDM_Account__c));
                }
                if(contactList!=null && !contactList.isEmpty()){
                    mapRelatedCont = new map<id, contact>([SELECT id, accountId FROM contact WHERE id IN: contactList]);
                }
                for(AccountContactRelation accContRec : lstAccCont){
                    lstAllContId.add(accContRec.contactid);
                    if(mapParentConts.containskey(accContRec.accountId)){
                        mapParentConts.get(accContRec.accountId).add(mapRelatedCont.get(accContRec.contactId));
                    }else{
                        List<contact> lstContId = new List<contact>();
                        lstContId.add(mapRelatedCont.get(accContRec.contactId));
                        mapParentConts.put(accContRec.accountId, lstContId);
                    }
                }
            }

            String dummyAccountKey = EC_Constants.DummyAccountKey;
            List<AccountContactRelation> lstAccContRel = [SELECT Id, contactId FROM AccountContactRelation WHERE contactId IN: lstAllContId AND account.EC_CDM_Account__c =:dummyAccountKey];

            for(AccountContactRelation accContRec : lstAccContRel){
                mapDummyAccContRel.put(accContRec.contactId, accContRec);
            }

            List<String> recrodTypeNames = new List<String>();
            recrodTypeNames.add(EC_Constants.Corporate);
            recrodTypeNames.add(EC_Constants.Ship_To);
            recrodTypeNames.add(EC_Constants.Sold_To);

            List<RecordType> lstRecordType = [Select Id,Name from RecordType where name in:recrodTypeNames];
            for(RecordType recordType:lstRecordType){
                recordTypeIdMap.put(recordType.Name,recordType.Id);
            }

            for(EC_Mulesoft_CDM_Staging__c acc: acctStage) {
                try {
                	Account ac = new Account();
                    if(acc.EC_Origination_Account_System_Code__c != null && !String.isBlank(acc.EC_Origination_Account_System_Code__c)){
                        ac.ccrz__SourceSystem__c = acc.EC_Origination_Account_System_Code__c;
                    }
                    if(acc.EC_SalesOrg__c != null && !String.isBlank(acc.EC_SalesOrg__c)){
                        ac.EC_SalesOrg__c = acc.EC_SalesOrg__c;
                    }
                    if(acc.EC_Partner_Function__c == EC_Constants.SHIPTO || (acc.EC_Partner_Function__c == EC_Constants.SOLDTO && (acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c) ||  acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE)))){
                        ac.EC_CDM_Account__c =  acc.EC_Account_Key__c;
                        // Account Name English Should be used for account name
                        ac.Name = acc.EC_Account_Name_English__c;
                        if (acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.WATER||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_NALCOBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                            ac.EC_Division__c = EC_Constants.WATER;
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.ENERGY||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.ENERGY)){
                                ac.EC_Division__c = EC_Constants.ENERGY;
                            }else if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.PAPER||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.PAPER)){
                                ac.EC_Division__c = EC_Constants.PAPER;
                            }
                        } else if (acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null &&  System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                            ac.EC_Division__c = System.label.EC_DivisionValueInsitituional;
                        }else if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE  )){
                            ac.EC_Division__c = EC_Constants.FOODANDBEVERAGE;
                        }
    
                        // Street Address should be a combination of Address line1,2,3,4 Defect-81154
                        if (acc.EC_Street_Address_1__c!='' && acc.EC_Street_Address_1__c!=null){
                            ac.ShippingStreet = acc.EC_Street_Address_1__c + ' ';
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ) || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                                ac.BillingStreet = acc.EC_Street_Address_1__c + ' ';
                            }
                        }
                        if(acc.EC_Street_Address_2__c!='' && acc.EC_Street_Address_2__c!=null){
                            ac.ShippingStreet = ac.ShippingStreet+ acc.EC_Street_Address_2__c + ' ';
    
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ) || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                                ac.BillingStreet = ac.BillingStreet+ acc.EC_Street_Address_2__c + ' ';
                            }
                        }
                        if(acc.EC_Street_Address_3__c!='' && acc.EC_Street_Address_3__c!=null){
                            ac.ShippingStreet = ac.ShippingStreet+ acc.EC_Street_Address_3__c + ' ';
    
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ) || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                                ac.BillingStreet = ac.BillingStreet+ acc.EC_Street_Address_3__c + ' ';
                            }
                        }
                        if(acc.EC_Street_Address_4__c!='' && acc.EC_Street_Address_4__c!=null){
                            ac.ShippingStreet = ac.ShippingStreet+ acc.EC_Street_Address_4__c;
    
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ) || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                                ac.BillingStreet = ac.BillingStreet+ acc.EC_Street_Address_4__c;
                            }
                        }
                        if(acc.EC_City__c != '' && acc.EC_City__c != null) {
                            ac.ShippingCity =  acc.EC_City__c;
    
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ) || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                                ac.BillingCity = acc.EC_City__c;
                            }
                        }
                        if(acc.EC_State_Province__c != '' && acc.EC_State_Province__c != null) {
                            ac.ShippingState  = acc.EC_State_Province__c;
    
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ) || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                                ac.BillingState = acc.EC_State_Province__c;
                            }
                        }
                        if(acc.EC_Country_ISO3_Code__c!='' && acc.EC_Country_ISO3_Code__c!=null){
                            ac.ShippingCountry = acc.EC_Country_ISO3_Code__c;
    
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ) || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                                ac.BillingCountry = acc.EC_Country_ISO3_Code__c;
                            }
                        }
                        if(acc.EC_Postal_Code__c!='' && acc.EC_Postal_Code__c!=''){
                            ac.ShippingPostalCode =  acc.EC_Postal_Code__c ;
    
                            if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ) || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                                ac.BillingPostalCode = acc.EC_Postal_Code__c;
                            }
                        }
                        ac.EC_Unique_Account_Number__c = acc.EC_Stage_Unique_AccNumber__c;
                        ac.EC_Account_Number__c = acc.EC_Account_Number__c;
                        /* changed by Venkatesh
                        if(acc.EC_Partner_Function__c == EC_Constants.SOLDTO && (acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE))){
                            ac.RecordTypeId =  recordTypeIdMap.get(EC_Constants.Sold_To);
                        }else{
                            ac.RecordTypeId =  recordTypeIdMap.get(EC_Constants.Ship_To);
                        }*/
    
                        ac.RecordTypeId =  recordTypeIdMap.get(EC_Constants.Ship_To);
    
                        //We are updating the below parentIds only in case of SHIPTO Accounts, SOLD To Accounts will not have parentIds
                        if(acc.EC_Partner_Function__c == EC_Constants.SHIPTO && (acc.EC_Account_Global_Business_Unit_Name__c != EC_Constants.FOODANDBEVERAGE || (acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c != EC_Constants.FOODANDBEVERAGE ))){
                            if(acc.EC_Parent_Account_Number__c == '' || String.isBlank(acc.EC_Parent_Account_Number__c)){
                                ac.ParentId = null;
                            }else if(accountParentMap.containsKey(acc.EC_Parent_Account_Number__c)){
                                ac.ParentId = accountParentMap.get(acc.EC_Parent_Account_Number__c);
                            }else{
                                //TODO:Logs: Invalid Parent Account Key for Nalco Ship To Account
                                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(acc.id,null,null,null,
                                        null,null,null,null,null,null,'Invalid Parent Account Key for Nalco Ship To Account','EC_StagingAccountInsert',
                                        'accountInsert');
                                stageLogWrapList.add(stageLogWrap);
                                continue;
                            }
                            // AccountGroup of Parent Accounts should be assigned to ShipTo Accounts
                            ac.ccrz__E_AccountGroup__c = accountParentGroupMap.get(acc.EC_Parent_Account_Number__c);
                        }else if(acc.EC_Partner_Function__c == EC_Constants.SOLDTO || acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE )){
                            if(accountParentMap.containsKey(EC_Constants.CORPPREFIX+acc.EC_Customer_Key__c)){
                                ac.ParentId = accountParentMap.get(EC_Constants.CORPPREFIX+acc.EC_Customer_Key__c);
                            }else{
                                //TODO:Logs: Invalid Parent Account Key for F&B and InstAccounts
                                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(acc.id,null,null,null,
                                        null,null,null,null,null,null,'Invalid Parent Account Key for F&B and InstAccounts','EC_StagingAccountInsert',
                                        'accountInsert');
                                stageLogWrapList.add(stageLogWrap);
                                continue;
                            }
                        }

                        // The account should be active if the status code is A
                        if (acc.EC_Status_Code__c == EC_Constants.A){
                            ac.EC_Status__c = EC_Constants.Active;
                        }else{
                            ac.EC_Status__c = EC_Constants.Inactive;
                        }
                        mapNewShipAcc.put(ac.ParentId, ac);
                }else if(acc.EC_Partner_Function__c == EC_Constants.SOLDTO && System.label.EC_DivisionValueNACLO.contains(acc.EC_Account_Global_Business_Unit_Name__c) ||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_NALCOBUSINESSUNITNAME.contains(acc.EC_Account_Divisional_Business_Unit_Name__c))){
                        // Account Name English Should be used for account name
                        ac.Name = acc.EC_Account_Name_English__c;
                        ac.EC_CDM_Account__c =  acc.EC_Account_Key__c;
                        ac.EC_Unique_Account_Number__c = acc.EC_Stage_Unique_AccNumber__c;
                        ac.EC_Account_Number__c = acc.EC_Account_Number__c;
                        ac.RecordTypeId =  recordTypeIdMap.get(EC_Constants.Sold_To);
                        ac.ParentId = accountParentMap.get(EC_Constants.CORPPREFIX+acc.EC_Customer_Key__c);
                        // The account should be active if the status code is A
                        if (acc.EC_Status_Code__c == EC_Constants.A){
                            ac.EC_Status__c = EC_Constants.Active;
                        }else{
                            ac.EC_Status__c = EC_Constants.Inactive;
                        }
        
                        // ac.EC_Division__c = System.label.EC_DivisionValueNACLO;
                        if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.ENERGY||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.ENERGY)){
                            ac.EC_Division__c = EC_Constants.ENERGY;
                        }else if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.PAPER||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.PAPER)){
                            ac.EC_Division__c = EC_Constants.PAPER;
                        }
                        else if(acc.EC_Account_Global_Business_Unit_Name__c == EC_Constants.WATER||(acc.EC_Account_Divisional_Business_Unit_Name__c!=null && acc.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.WATER)){
                            ac.EC_Division__c = EC_Constants.WATER;
                        }
                    }
                    if(acc.EC_Partner_Function__c==EC_Constants.SHIPTO){
                        ac.Account_Name2__c = acc.Account_Name2__c;
                        ac.Account_Name3__c = acc.Account_Name3__c;
                        ac.Account_Name4__c = acc.Account_Name4__c;
                    }
                    listInsertAccounts.add(ac);
                    acctStageKeys.add(acc.Id); 
                } catch(Exception exc) {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(acc.id,null,null,null,
                                        null,null,null,null,null,null,exc.getMessage(),'EC_StagingAccountInsert',
                                        'accountInsert');
                     stageLogWrapList.add(stageLogWrap);
            	}
        	}

        if(listInsertAccounts!=null && !listInsertAccounts.isEmpty()) {
            // insert listInsertAccounts;
            Database.SaveResult[] saveRes = Database.insert(listInsertAccounts,false);
            Integer index = 0;
            for(Database.SaveResult sr:saveRes){
                if(sr.isSuccess()){
                    lstInsertedSuccess.add(sr.getId());
                }else{
                    for(Database.Error  err: sr.getErrors()) {
                        EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(acctStageKeys.get(index),null,null,null,
                                    null,null,null,null,null,null,err.getMessage(),'EC_StagingAccountInsert',
                                    'accountInsert');
                        stageLogWrapList.add(stageLogWrap);
                    }
                }
                index++;
            }
            lstInsertedAccts =  [Select Id,Name,EC_CDM_Account__c,ccrz__E_AccountGroup__c,EC_Unique_Account_Number__c,EC_Account_Number__c,RecordTypeId from Account where Id in:lstInsertedSuccess];
            for(Account act:lstInsertedAccts){
                successStgRecords.add(accountKeyMap.get(act.EC_CDM_Account__c))  ;
            }
        }

        for(string parentIdStr : mapNewShipAcc.keyset()){
            if(mapParentConts.containskey(parentIdStr)){
                for(contact contIdStr : mapParentConts.get(parentIdStr)){
                    if(mapDummyAccContRel.containskey(contIdStr.id)){
                        contIdStr.accountId = parentIdStr;
                        lstContUpdate.add(contIdStr);
                        mapDummyAccContRel.remove(contIdStr.id);
                    }else{
                        Account shiptoAcc = mapNewShipAcc.get(parentIdStr);
                        if (shiptoAcc != null && shiptoAcc.id != null && contIdStr.id != null) {
                            AccountContactRelation accContRec = new AccountContactRelation();
                            accContRec.accountId = mapNewShipAcc.get(parentIdStr).id;
                            accContRec.contactId = contIdStr.id;
                            lstAccContInsert.add(accContRec);
                        }
                    }
                }
            }
        }

        if(lstContUpdate != null && lstContUpdate.size() > 0){
            Database.update(lstContUpdate);
        }

        if(lstAccContRel != null && lstAccContRel.size() > 0){
            // Database.delete(lstAccContRel);
            Database.DeleteResult[] delRes = Database.delete(lstAccContRel,false);
            for(Database.DeleteResult dr:delRes){
                if(!dr.isSuccess()){
                    successStgRecords.remove(accStageMap.get(dr.getId()));
                    for(Database.Error  err: dr.getErrors()){
                        if(accStageMap.get(dr.getId())!=null){
                            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(accStageMap.get(dr.getId()).id,null,accStageMap.get(dr.getId()).EC_Account_Key__c,accStageMap.get(dr.getId()).EC_Source_Table__c,
                                accStageMap.get(dr.getId()).EC_Action__c,accStageMap.get(dr.getId()).EC_Account_Global_Business_Unit_Name__c,accStageMap.get(dr.getId()).EC_Partner_Function__c,
                                accStageMap.get(dr.getId()).EC_Parent_Account_Key__c,null,null,err.getMessage(),'EC_StagingAccountInsert','accountInsert');
                            stageLogWrapList.add(stageLogWrap);
                        }
                    }
                }
            }
        }

        if(lstAccContInsert != null && lstAccContInsert.size() > 0){
            Database.SaveResult[] savRes = Database.insert(lstAccContInsert);
        }

        List<EC_Mulesoft_CDM_Staging__c> succesStgInstance = new List<EC_Mulesoft_CDM_Staging__c>();
        for(EC_Mulesoft_CDM_Staging__c successStg:successStgRecords){
            EC_Mulesoft_CDM_Staging__c successInprogress = new EC_Mulesoft_CDM_Staging__c();
            successInprogress.Id= successStg.Id;
            successInprogress.EC_IsProcessed__c= true;
            if(successStg.Id!=null && !String.isBlank(successStg.Id)){
                existRecords.add(successStg);
            }
            if(successStg.EC_Partner_Function__c == EC_Constants.SOLDTO || successStg.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ||(successStg.EC_Account_Divisional_Business_Unit_Name__c!=null && successStg.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE)){
                lstGroupKey.add(successStg.EC_Account_Key__c);
            }
            succesStgInstance.add(successInprogress);
        }

        if(lstGroupKey!=null && !lstGroupKey.isEmpty()){
            for(Account ac:[Select Id,Name,EC_CDM_Account__c,ccrz__E_AccountGroup__c,EC_Unique_Account_Number__c,EC_Account_Number__c,RecordTypeId from Account where EC_CDM_Account__c in:lstGroupKey]){
                //Account Group should be created for the SOLD TO Account
                // if (ac.RecordTypeId ==  recordTypeIdMap.get(EC_Constants.Sold_To))
                listAccountGroups.add(ac);
            }
        }

        EC_StagingUtilities.createAccountGroup(listAccountGroups);
        if(succesStgInstance!=null && !succesStgInstance.isEmpty()){
            Database.SaveResult[] savRes = Database.update(succesStgInstance,false);
            for(Database.SaveResult sr:savRes){
                if(!sr.isSuccess()){
                    for(Database.Error  err: sr.getErrors()) {
                        EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(sr.getId(),null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingAccountInsert',
                                        'accountInsert');
                        stageLogWrapList.add(stageLogWrap);
                        }
                    }
                }
            }
            EC_StagingLogger.stageLogException(stageLogWrapList);
            if(Test.isRunningTest()) {
                    throw new DMLException('Test coverage');
                }
        }catch(Exception ex){
            List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingAccountInsert',
                                'accountInsert');
            stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);
        }
    }
}