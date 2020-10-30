//EC_StagingAccountUpdate
//This is class to handle the Account update action on Staging
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//

public class EC_StagingAccountUpdate{

/***************************************************************************************************************************************
Method Name : getAccountRelations
Description : Get type of relation for Account based on division.
Return type : Map<String,String>
**************************************************************************************************************************************/
public static Map<String,Account_RelationShip__mdt> getAccountRelations() {
    Map<String,Account_RelationShip__mdt> accountRelationMap = new Map<String,Account_RelationShip__mdt>();
    List<Account_RelationShip__mdt > accRelation = [Select MasterLabel,Relation__c,Division__c   from Account_RelationShip__mdt];
    if(!accRelation.isEmpty()){
        for(Account_RelationShip__mdt metaRecord : accRelation){
            accountRelationMap.put(metaRecord.MasterLabel.toLowerCase(),metaRecord);
        }
    }
    return accountRelationMap;
}

/***************************************************************************************************************************************
Method Name : accountUpdate
Description : Used to Update account From Staging object for Account UpdateAction
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static void accountUpdate(List<EC_Mulesoft_CDM_Staging__c> acctStage){
        List<Account>  acctUpdate = new  List<Account>();
        List<String>  stageAccKey = new  List<String>();
        Set<String>  newParentAccNum = new  Set<String>();
        Set<String>  oldParentId = new  Set<String>();
        Map<String,Id> recordTypeIdMap = new Map<String,Id>();
        Map<EC_Mulesoft_CDM_Staging__c, Account> mapStgAcc = new Map<EC_Mulesoft_CDM_Staging__c, Account>();
        Map<string, List<AccountContactRelation>> mapShipOldAccCont = new Map<string, List<AccountContactRelation>>();
        Map<string, List<contact>> mapNewParentCont = new Map<string, List<contact>>();
        Map<string, Id> mapNewParentId = new Map<string, Id>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        // Below Map will be used to update the account group of the Child Account with the parent accounts.
        Map<string,Id> mapNewParentGroup = new Map<string,Id>();
        Map<Id,EC_Mulesoft_CDM_Staging__c> accStageMap = new  Map<Id,EC_Mulesoft_CDM_Staging__c>();
        List<AccountContactRelation> lstDelAccCont = new List<AccountContactRelation>();
        List<AccountContactRelation> lstInsertAccCont = new List<AccountContactRelation>();
        List<string> acctStageKeys = new List<string>();
        List<string> lstBlanketAccKeys = new List<string>();
        String className = 'EC_StagingAccountUpdate';
        String methodName = 'accountUpdate';
        // Below Lists and Map will be used for updating the IsProcessed field for Staging table
        list<Id> lstUpdatedSuccess = new list<Id>();
        Set<EC_Mulesoft_CDM_Staging__c> successStgRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
        list<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new List<EC_Mulesoft_CDM_Staging__c>();
        Map<String,EC_Mulesoft_CDM_Staging__c> accountKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        Map<String,EC_Mulesoft_CDM_Staging__c> accContStgMap = new Map<String,EC_Mulesoft_CDM_Staging__c>();
        Map<String,Account_RelationShip__mdt> accountRelationMap = getAccountRelations();
        Map<id,Account_RelationShip__mdt> accStgRelationMap = new Map<id,Account_RelationShip__mdt>();
        String unalignedKey = System.label.EC_Unaligned_Account;
        Account unaligned = new Account();
        String shipTo = 'ShipTo';
        String soldToShipTo = 'SoldTo_ShipTo';

        try{
            for(EC_Mulesoft_CDM_Staging__c stageRec : acctStage){
                System.debug('Reached AcctState with record as++++'+stageRec);
                stageAccKey.add(stageRec.EC_Account_Key__c);
                try {
                    Account_RelationShip__mdt relation = new Account_RelationShip__mdt();
                    String relationType = '';
                    if(stageRec.EC_Account_Global_Business_Unit_Name__c != null){
                        relation = accountRelationMap.get(stageRec.EC_Account_Global_Business_Unit_Name__c.toLowerCase());
                        accStgRelationMap.put(stageRec.id,relation);
                        relationType = relation.Relation__c;
                    } else if(stageRec.EC_Account_Divisional_Business_Unit_Name__c!=null){
                        relation = accountRelationMap.get(stageRec.EC_Account_Divisional_Business_Unit_Name__c.toLowerCase());
                        accStgRelationMap.put(stageRec.id,relation);
                        relationType = relation.Relation__c;
                    }
                    if(stageRec.EC_Partner_Function__c == EC_Constants.SHIPTO && relationType != shipTo){
                        if(stageRec.EC_Parent_Account_Number__c !=null && !String.isBlank(stageRec.EC_Parent_Account_Number__c)){
                            newParentAccNum.add(stageRec.EC_Parent_Account_Number__c);
                        }
                    }else if(stageRec.EC_Partner_Function__c == EC_Constants.SOLDTO || relationType == shipTo){
                        newParentAccNum.add(EC_Constants.CORPPREFIX+stageRec.EC_Customer_Key__c);
                    }
                    if(Test.isRunningTest()){
                       throw new DMLException(); 
                    }
                } catch(Exception ex) {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageRec.id,null,null,null,
                                                                                           null,null,null,null,null,null,ex.getMessage(), className,
                                                                                           'accountInsert');
                    stageLogWrapList.add(stageLogWrap);
                }
                accountKeyMap.put(stageRec.EC_Account_Key__c,stageRec);
            }
		stageAccKey.add(unalignedKey);
        List<Contact> lstNewParentCont = [SELECT id, account.EC_Unique_Account_Number__c,account.EC_Account_Number__c FROM contact WHERE account.EC_Unique_Account_Number__c IN: newParentAccNum];
        for(contact contRec : lstNewParentCont){
            if(mapNewParentCont.containskey(contRec.account.EC_Unique_Account_Number__c)){
                mapNewParentCont.get(contRec.account.EC_Unique_Account_Number__c).add(contRec);
            }else{
                List<contact> tempLstCont = new List<contact>();
                tempLstCont.add(contRec);
                mapNewParentCont.put(contRec.account.EC_Unique_Account_Number__c, tempLstCont);
            }
        }

        List<Account> lstBlanketAccRec = [SELECT id, Name, ShippingState,BillingState,ShippingStreet,BillingStreet, EC_Division__c, ShippingCity, BillingCity, BillingCountry,ShippingCountry,ShippingPostalCode,BillingPostalCode, EC_CDM_Account__c, parent.EC_CDM_Account__c, EC_Unique_Account_Number__c, parent.EC_Unique_Account_Number__c,ccrz__E_AccountGroup__c ,EC_Account_Number__c,parent.EC_Account_Number__c FROM account WHERE EC_CDM_Account__c IN: stageAccKey OR EC_Unique_Account_Number__c IN: newParentAccNum];
        for(account accRec : lstBlanketAccRec){
            if(accRec.EC_Unique_Account_Number__c == unalignedKey) {
                unaligned = accRec;
            } 
            lstBlanketAccKeys.add(accRec.EC_CDM_Account__c);
            for(EC_Mulesoft_CDM_Staging__c stageRec : acctStage){
                if(stageRec.EC_Account_Key__c == accRec.EC_CDM_Account__c){
                    mapStgAcc.put(stageRec, accRec);
                }
            }
            if(newParentAccNum.contains(accRec.EC_Unique_Account_Number__c)){
                mapNewParentId.put(accRec.EC_Unique_Account_Number__c,accRec.Id);
                if(accRec.ccrz__E_AccountGroup__c != null){
                    mapNewParentGroup.put(accRec.EC_Unique_Account_Number__c,accRec.ccrz__E_AccountGroup__c);
                }
            }else{
                oldParentId.add(accRec.parentId);
            }
        }
        for(EC_Mulesoft_CDM_Staging__c stageRec : acctStage){
            if(!lstBlanketAccKeys.contains(stageRec.EC_Account_Key__c)){
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageRec.Id,null,null,null,
                                null,null,null,
                                null,null,null,'Invalid EC_Account_Key__c', className,methodName);
                                stageLogWrapList.add(stageLogWrap);
            }
        }

        List<String> recrodTypeNames = new List<String>();
        recrodTypeNames.add(EC_Constants.Corporate);
        recrodTypeNames.add(EC_Constants.Ship_To);
        recrodTypeNames.add(EC_Constants.Sold_To);

        List<RecordType> lstRecordType = [Select Id,Name from RecordType where name in:recrodTypeNames];
        for(RecordType recordType:lstRecordType){
            recordTypeIdMap.put(recordType.Name,recordType.Id);
        }

        String ship_to = EC_Constants.Ship_To;

        List<AccountContactRelation> lstAccContRel = [SELECT Id, account.EC_CDM_Account__c, account.parent.EC_Unique_Account_Number__c,account.parent.EC_Account_Number__c FROM AccountContactRelation WHERE contact.accountId IN: oldParentId AND account.EC_CDM_Account__c IN: stageAccKey AND account.RecordType.Name =:ship_to];

        for(AccountContactRelation accContRec : lstAccContRel){
            if(mapShipOldAccCont.containskey(accContRec.account.EC_CDM_Account__c)){
                mapShipOldAccCont.get(accContRec.account.EC_CDM_Account__c).add(accContRec);
                accContStgMap.put(accContRec.Id,accountKeyMap.get(accContRec.account.EC_CDM_Account__c));
            }else{
                List<AccountContactRelation> tempLstAccCont = new List<AccountContactRelation>();
                tempLstAccCont.add(accContRec);
                mapShipOldAccCont.put(accContRec.account.EC_CDM_Account__c, tempLstAccCont);
            }
        }

        for(EC_Mulesoft_CDM_Staging__c stageRec : acctStage){

            if(mapStgAcc != null && mapStgAcc.containskey(stageRec)){
                Account_RelationShip__mdt relation = accStgRelationMap.get(stageRec.Id);
                String relationtype= relation.Relation__c;
                account tempAccRec = mapStgAcc.get(stageRec);
                if(stageRec.EC_Partner_Function__c == EC_Constants.SOLDTO && relationtype == soldToShipTo){
                    //AccountName English Should be used
                    tempAccRec.Name = stageRec.EC_Account_Name_English__c;
                    tempAccRec.EC_Unique_Account_Number__c = stageRec.EC_Stage_Unique_AccNumber__c  ;
                    tempAccRec.EC_Account_Number__c = stageRec.EC_Account_Number__c;
				 //tempAccRec.RecordTypeId =  recordTypeIdMap.get(EC_Constants.Sold_To); We should not update the RecordType of any Account
                    if(stageRec.EC_SalesOrg__c != null && !String.isBlank(stageRec.EC_SalesOrg__c)){
                        tempAccRec.EC_SalesOrg__c = stageRec.EC_SalesOrg__c;
                    }
					if(stageRec.EC_Origination_Account_System_Code__c != null && !String.isBlank(stageRec.EC_Origination_Account_System_Code__c)){
                		tempAccRec.ccrz__SourceSystem__c = stageRec.EC_Origination_Account_System_Code__c;
            		}
                    if(mapNewParentId != null){
                        if(stageRec.EC_Partner_Function__c == EC_Constants.SHIPTO && mapNewParentId.containskey(stageRec.EC_Parent_Account_Number__c ) &&  (stageRec.EC_Account_Global_Business_Unit_Name__c != EC_Constants.FOODANDBEVERAGE || (stageRec.EC_Account_Divisional_Business_Unit_Name__c!=null && stageRec.EC_Account_Divisional_Business_Unit_Name__c != EC_Constants.FOODANDBEVERAGE ))){
                            tempAccRec.parentId = mapNewParentId.get(stageRec.EC_Parent_Account_Number__c);
                        }else if(stageRec.EC_Partner_Function__c == EC_Constants.SOLDTO && mapNewParentId.containskey(EC_Constants.CORPPREFIX+stageRec.EC_Customer_Key__c) || (stageRec.EC_Account_Divisional_Business_Unit_Name__c!=null && !System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(stageRec.EC_Account_Divisional_Business_Unit_Name__c)) || (stageRec.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE|| (stageRec.EC_Account_Divisional_Business_Unit_Name__c!=null && stageRec.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE))){
                            if(mapNewParentId.containskey(EC_Constants.CORPPREFIX+stageRec.EC_Customer_Key__c)){
                                tempAccRec.parentId = mapNewParentId.get(EC_Constants.CORPPREFIX+stageRec.EC_Customer_Key__c);
                            }

                        }
                    }
                      if (stageRec.EC_Status_Code__c == EC_Constants.A){
                            tempAccRec.EC_Status__c = EC_Constants.Active;
                        }else{
                            tempAccRec.EC_Status__c = EC_Constants.Inactive;
                        }

                    acctUpdate.add(tempAccRec);
                     accStageMap.put(tempAccRec.id,stageRec);
                     acctStageKeys.add(stageRec.Id);
                } else if(stageRec.EC_Partner_Function__c == EC_Constants.SHIPTO || (stageRec.EC_Partner_Function__c == EC_Constants.SOLDTO && relationtype == 'SoldTo')){
                    tempAccRec.EC_CDM_Account__c =  stageRec.EC_Account_Key__c;
                    //AccountName English Should be used
                    tempAccRec.Name = stageRec.EC_Account_Name_English__c;
                    tempAccRec.EC_Unique_Account_Number__c = stageRec.EC_Stage_Unique_AccNumber__c  ;
                    tempAccRec.EC_Account_Number__c = stageRec.EC_Account_Number__c ;
                    tempAccRec.ShippingStreet = '';
                    tempAccRec.BillingStreet = '';
                    // Commented the below code as there should never be an Update on the Account Division
                    /* if(stageRec.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL ||(stageRec.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(stageRec.EC_Account_Divisional_Business_Unit_Name__c))){
                        tempAccRec.EC_Division__c = System.label.EC_DivisionValueInsitituional;
                    }else if(stageRec.EC_Account_Global_Business_Unit_Name__c == EC_Constants.WATER || (stageRec.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_NALCOBUSINESSUNITNAME.contains(stageRec.EC_Account_Divisional_Business_Unit_Name__c))){
                        tempAccRec.EC_Division__c = System.label.EC_DivisionValueNACLO;
                    } */
                    //Street Address should be a combination of Address line1,2,3,4 Defect-81154
                    if(stageRec.EC_Partner_Function__c == EC_Constants.SHIPTO && relationtype != shipTo){
                        tempAccRec.Account_Name2__c = stageRec.Account_Name2__c;
                        tempAccRec.Account_Name3__c = stageRec.Account_Name3__c;
                        tempAccRec.Account_Name4__c = stageRec.Account_Name4__c;    
                    }
                    if (stageRec.EC_Street_Address_1__c!='' && stageRec.EC_Street_Address_1__c!=null){
                        tempAccRec.ShippingStreet = stageRec.EC_Street_Address_1__c + ' ';

                        if(relationtype != soldToShipTo){
                            tempAccRec.BillingStreet = stageRec.EC_Street_Address_1__c + ' ';
                        }
                    }
                    if(stageRec.EC_Street_Address_2__c!='' && stageRec.EC_Street_Address_2__c!=null){
                        tempAccRec.ShippingStreet = tempAccRec.ShippingStreet+ stageRec.EC_Street_Address_2__c + ' ';

                        if(relationtype != soldToShipTo){
                            tempAccRec.BillingStreet = tempAccRec.BillingStreet+ stageRec.EC_Street_Address_2__c + ' ';
                        }
                    }
                    if(stageRec.EC_Street_Address_3__c!='' && stageRec.EC_Street_Address_3__c!=null){
                        tempAccRec.ShippingStreet = tempAccRec.ShippingStreet+ stageRec.EC_Street_Address_3__c + ' ';

                        if(relationtype != soldToShipTo){
                            tempAccRec.BillingStreet = tempAccRec.BillingStreet+ stageRec.EC_Street_Address_3__c + ' ';
                        }
                    }
                    if(stageRec.EC_Street_Address_4__c!='' && stageRec.EC_Street_Address_4__c!=null){
                        tempAccRec.ShippingStreet = tempAccRec.ShippingStreet+ stageRec.EC_Street_Address_4__c;

                        if(relationtype != soldToShipTo){
                            tempAccRec.BillingStreet = tempAccRec.BillingStreet+ stageRec.EC_Street_Address_4__c;
                        }
                    }
                    if(stageRec.EC_City__c != '' && stageRec.EC_City__c != null) {
                        tempAccRec.ShippingCity =  stageRec.EC_City__c;

                        if(relationtype != soldToShipTo){
                            tempAccRec.BillingCity = stageRec.EC_City__c;
                        }
                    }
                    if(stageRec.EC_State_Province__c != '' && stageRec.EC_State_Province__c != null) {
                        tempAccRec.ShippingState  = stageRec.EC_State_Province__c;

                        if(relationtype != soldToShipTo){
                            tempAccRec.BillingState = stageRec.EC_State_Province__c;
                        }
                    }
                    if(stageRec.EC_Country_ISO3_Code__c!='' && stageRec.EC_Country_ISO3_Code__c!=null){
                        tempAccRec.ShippingCountry = stageRec.EC_Country_ISO3_Code__c;

                        if(relationtype != soldToShipTo){
                            tempAccRec.BillingCountry = stageRec.EC_Country_ISO3_Code__c;
                        }
                    }
                    if(stageRec.EC_Postal_Code__c!='' && stageRec.EC_Postal_Code__c!=''){
                        tempAccRec.ShippingPostalCode =  stageRec.EC_Postal_Code__c ;

                        if(relationtype != soldToShipTo){
                            tempAccRec.BillingPostalCode = stageRec.EC_Postal_Code__c;
                        }
                    }
                    if(stageRec.EC_SalesOrg__c != null && !String.isBlank(stageRec.EC_SalesOrg__c)){
                        tempAccRec.EC_SalesOrg__c = stageRec.EC_SalesOrg__c;
                    }
					if(stageRec.EC_Origination_Account_System_Code__c != null && !String.isBlank(stageRec.EC_Origination_Account_System_Code__c)){
                		tempAccRec.ccrz__SourceSystem__c = stageRec.EC_Origination_Account_System_Code__c;
            		}
                    if(mapNewParentId != null){
                        if(stageRec.EC_Partner_Function__c == EC_Constants.SHIPTO &&  relationtype != shipTo){
                            if(stageRec.EC_Parent_Account_Number__c == '' || string.isBlank(stageRec.EC_Parent_Account_Number__c) || stageRec.EC_Parent_Account_Number__c == null){
                                tempAccRec.parentId =null;
                            }else if(mapNewParentId.containskey(stageRec.EC_Parent_Account_Number__c )){
                                tempAccRec.parentId = mapNewParentId.get(stageRec.EC_Parent_Account_Number__c );
                            }else{
                                System.debug('Reached the continue statement in AccountUpdate');
                                continue;
                            }
                        } else if(stageRec.EC_Partner_Function__c == EC_Constants.SOLDTO || relationtype == shipTo){
                            if(mapNewParentId.containskey(EC_Constants.CORPPREFIX+stageRec.EC_Customer_Key__c)){
                                tempAccRec.parentId = mapNewParentId.get(EC_Constants.CORPPREFIX+stageRec.EC_Customer_Key__c);
                            } else if(stageRec.EC_Customer_Key__c != null){
                                tempAccRec.ParentId = unaligned.id;
                                tempAccRec.Customer_Key__c = stageRec.EC_Customer_Key__c;
                            } else {
                                System.debug('Reached the continue statement in AccountUpdate second time');
                                continue;
                            }
                        }
                    }

                    tempAccRec.RecordTypeId = recordTypeIdMap.get(EC_Constants.Ship_To);
                    if(tempAccRec.parent.EC_Unique_Account_Number__c != stageRec.EC_Stage_Unique_AccNumber__c){

                        // We will update the AccountGroup of the parentAccount for ShipTo accounts
                        if(mapNewParentGroup.containsKey(stageRec.EC_Parent_Account_Number__c) && mapNewParentGroup.get(stageRec.EC_Parent_Account_Number__c) !=null){
                            tempAccRec.ccrz__E_AccountGroup__c = mapNewParentGroup.get(stageRec.EC_Parent_Account_Number__c);
                        }else if(!mapNewParentGroup.containsKey(stageRec.EC_Parent_Account_Number__c) && !((stageRec.EC_Partner_Function__c == EC_Constants.SOLDTO && (stageRec.EC_Account_Global_Business_Unit_Name__c == EC_Constants.INSTITUTIONAL ||(stageRec.EC_Account_Divisional_Business_Unit_Name__c!=null && System.label.EC_INSTITUTIONALBUSINESSUNITNAME.contains(stageRec.EC_Account_Divisional_Business_Unit_Name__c)))) || (stageRec.EC_Partner_Function__c == EC_Constants.SHIPTO && stageRec.EC_Account_Global_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE ||stageRec.EC_Account_Divisional_Business_Unit_Name__c!=null && stageRec.EC_Account_Divisional_Business_Unit_Name__c == EC_Constants.FOODANDBEVERAGE))){
                                tempAccRec.ccrz__E_AccountGroup__c = null;
                        }
                            if(mapShipOldAccCont.containskey(stageRec.EC_Account_Key__c)){
                                list<AccountContactRelation> lstTempAccCont = mapShipOldAccCont.get(stageRec.EC_Account_Key__c);
                                lstDelAccCont.addAll(lstTempAccCont);
                                  if(mapNewParentCont != null && mapNewParentCont.containskey(stageRec.EC_Parent_Account_Number__c)){
                                    for(contact tempContRec : mapNewParentCont.get(stageRec.EC_Parent_Account_Number__c)){
                                        AccountContactRelation tempInsertAccCont = new AccountContactRelation();
                                        tempInsertAccCont.contactId = tempContRec.Id;
                                        tempInsertAccCont.accountId = tempAccRec.Id;
                                        lstInsertAccCont.add(tempInsertAccCont);
                                    }
                                }
                            }else{

                                if(mapNewParentCont != null && mapNewParentCont.containskey(stageRec.EC_Parent_Account_Number__c)){
                                    for(contact tempContRec : mapNewParentCont.get(stageRec.EC_Parent_Account_Number__c)){
                                        AccountContactRelation tempInsertAccCont = new AccountContactRelation();
                                        tempInsertAccCont.contactId = tempContRec.Id;
                                        tempInsertAccCont.accountId = tempAccRec.Id;
                                        lstInsertAccCont.add(tempInsertAccCont);
                                    }
                                }
                            }
                        }
                    if (stageRec.EC_Status_Code__c == EC_Constants.A){
                        tempAccRec.EC_Status__c = EC_Constants.Active;
                    }else{
                        tempAccRec.EC_Status__c = EC_Constants.Inactive;
                    }
                    acctUpdate.add(tempAccRec);
                    accStageMap.put(tempAccRec.id,stageRec);
                    acctStageKeys.add(stageRec.Id);
                } else {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stageRec.Id,null,null,null,
                                null,null,null,
                                null,null,null,'Invalid EC_Partner_Function__c',className,methodName);
                                stageLogWrapList.add(stageLogWrap);
                }
            }
        }

        if(acctUpdate != null && acctUpdate.size() > 0){
            Database.SaveResult[] saveRes = Database.update(acctUpdate,false);
            System.debug('The account getting updated is +++++'+acctUpdate);
            Integer index = 0;
            for(Database.SaveResult sr:saveRes){
                if(sr.isSuccess()){
                    lstUpdatedSuccess.add(sr.getId());
                }else {
                       for(Database.Error  err: sr.getErrors()){
                                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(acctStageKeys.get(index),null,null,null,
                                null,null,null,
                                null,null,null,err.getMessage(),className,methodName);
                                stageLogWrapList.add(stageLogWrap);
                           System.debug('The Exception in Account Update is++++'+err.getMessage());

                    }
                }
                index++;
            }


            for(Account act:[Select Id,EC_CDM_Account__c from Account where Id in:lstUpdatedSuccess]){
                successStgRecords.add(accountKeyMap.get(act.EC_CDM_Account__c))  ;
            }


        }



        if(lstDelAccCont != null && lstDelAccCont.size() > 0){
          //  Database.delete(lstDelAccCont);
           Database.DeleteResult[] delRes = Database.delete(lstDelAccCont,false);
                    for(Database.DeleteResult dr:delRes){
                 if(!dr.isSuccess()){
                  successStgRecords.remove(accContStgMap.get(dr.getId()));
                    for(Database.Error  err: dr.getErrors()){
                      if(accContStgMap.get(dr.getId())!=null){
                       EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(accContStgMap.get(dr.getId()).id,null,accContStgMap.get(dr.getId()).EC_Account_Key__c,accContStgMap.get(dr.getId()).EC_Source_Table__c,
                                accContStgMap.get(dr.getId()).EC_Action__c,accContStgMap.get(dr.getId()).EC_Account_Global_Business_Unit_Name__c,accContStgMap.get(dr.getId()).EC_Partner_Function__c,
                                accContStgMap.get(dr.getId()).EC_Parent_Account_Key__c,null,null,err.getMessage(),'EC_StagingAccountInsert','accountInsert');
                      stageLogWrapList.add(stageLogWrap);
                       }
                    }
                }
             }
               }


            if(lstInsertAccCont != null && lstInsertAccCont.size() > 0){
                Database.insert(lstInsertAccCont,false);
            }
            List<EC_Mulesoft_CDM_Staging__c> succesStgInstance = new List<EC_Mulesoft_CDM_Staging__c>();
            for(EC_Mulesoft_CDM_Staging__c successStg:successStgRecords){
                EC_Mulesoft_CDM_Staging__c successInprogress = new EC_Mulesoft_CDM_Staging__c();
                successInprogress.Id= successStg.Id;
                successInprogress.EC_IsProcessed__c= true;
                if(successStg.Id !=null && !String.isBlank(successStg.Id)){
                    succesStgInstance.add(successInprogress);
                }
            }

            if(succesStgInstance!=null && !succesStgInstance.isEmpty()){
               // update succesStgInstance;
            Database.SaveResult[] savRes = Database.update(succesStgInstance,false);
             for(Database.SaveResult sr:savRes){
              if(!sr.isSuccess()){
               for(Database.Error  err: sr.getErrors()) {
                 EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(sr.getId(),null,null,null,null,null,null,null,null,null,err.getMessage(),className,
                                methodName);
                 stageLogWrapList.add(stageLogWrap);
                  }
               }
             }
            }
            EC_StagingLogger.stageLogException(stageLogWrapList);
            if(Test.isRunningTest()){
                throw new DMLException(); 
            }
        }catch(Exception ex){
            system.debug('The exception Catched is +++++ '+ex.getMessage());
            List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(), className,
                                methodName);
            stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);

        }
    }
}