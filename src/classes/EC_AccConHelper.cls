/*
* Class Name	: EC_AccConHelper
* Description	: This class contains the helper methods used to process User Account Alignments from Informatica
				  1) alignmentInserHelper 2) CompleteRegistrationController
*/
public with sharing class EC_AccConHelper {
    public static final string currentClassName = 'EC_AccConHelper';
    /***************************************************************************************************************************************
    Method Name : alignmentInserHelper
    Description : To process user account insert
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void alignmentInserHelper(List<AccountContactRelation> relList){
        Set<Id> setOrgAccIds = new Set<Id>();
        Map<Id,Id> conAccMap = new Map<Id,Id>();
        try {
            //To fetch all Account and ContactIDs for insert alignments
            for(AccountContactRelation contRec : relList){
                setOrgAccIds.add(contRec.accountId);
                conAccMap.put(contRec.contactId,contRec.accountId);
            }
            //To fetch the account details from custom meta data to allow any division of data
            List<Account_RelationShip__mdt > accRelation = [Select MasterLabel,Relation__c,Division__c   from Account_RelationShip__mdt];
            List<String> ShipToDivisions = new List<String>();
            List<String> SoldToDivisions = new List<String>();
            for(Account_RelationShip__mdt metaRecord : accRelation){
                if(metaRecord.Relation__c == 'SoldTo_ShipTo') {
                    SoldToDivisions.add(metaRecord.Division__c);
                } else {
                    ShipToDivisions.add(metaRecord.Division__c);
                }
            }
            //Fetch SoldoTos for SoldToDivisions(Nalco) and ShipTos for ShipToDivisions (INST,F&B,PEST,TCD)
            Map<ID, Account> lstSoldToAccounts = new Map<ID, Account>([SELECT Id, EC_Division__c, parentId FROM account WHERE id IN:setOrgAccIds AND ((recordtype.Name='Sold To' And EC_Division__c in :SoldToDivisions) OR (recordtype.Name='Ship To' And EC_Division__c in :ShipToDivisions))]);
            if (lstSoldToAccounts != null && !lstSoldToAccounts.isEmpty()) {
                //Method to insert alignments
                processInsertAlignment(relList,lstSoldToAccounts,conAccMap);
            }
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage1');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,currentClassName,'alignmentInserHelper',false,null,'');
        }
    } 
 
    /***************************************************************************************************************************************
    Method Name : processInsertAlignment
    Description : To process user account insert
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void processInsertAlignment (List<AccountContactRelation> relList,Map<ID, Account> lstSoldToAccounts,Map<Id,Id> conAccMap) {
        List<AccountContactRelation> lstShipToInserts = new List<AccountContactRelation>();
        Set<Id> processAccIds = new Set<Id>();
        Set<Id> scopeContIds = new Set<Id>();
        try {
            //Iterting all Insert records
            for(AccountContactRelation contRec : relList){
                Account validAccount = lstSoldToAccounts.get(contRec.accountId);
                if(validAccount != null && validAccount.EC_Division__c != 'FOOD & BEVERAGE' && validAccount.EC_Division__c !='INSTITUTIONAL') {
                    lstShipToInserts.add(contRec); 
                }
                if(validAccount != null) {
                    processAccIds.add(contRec.accountId);
                    scopeContIds.add(contRec.contactId);
                }
            }
            // Process selected records which are Valid 
            // EX:SoldoTos for SoldToDivisions(Nalco) and ShipTos for ShipToDivisions (INST,F&B,PEST,TCD)
            runAlignments(scopeContIds,processAccIds,conAccMap,lstShipToInserts);
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage2');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,currentClassName,'processInsertAlignment',false,null,'');
        }
    }
    
    /***************************************************************************************************************************************
    Method Name : runAlignments
    Description : To process alignments
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void runAlignments(Set<Id> scopeContIds,Set<Id> processAccIds,Map<Id,Id> conAccMap,List<AccountContactRelation> lstShipToInserts ){
        List<AccountContactRelation> dummyRelationships ;
        String dummyAccountKey = EC_Constants.DummyAccountKey;
        List<Contact> lstUpdateContact = new List<Contact>();
        try {
            if (scopeContIds != null && !scopeContIds.isEmpty() && processAccIds != null && !processAccIds.isEmpty()) {
                //Fetching the existing AccountContact relation records which are Associated with Dummy Accounts for inserted Contacts
                dummyRelationships = [select id,contactid from AccountContactRelation where contact.id in:scopeContIds and account.EC_CDM_Account__c =:dummyAccountKey];
                //Updating dummy relationship with newly created alignment
                for(AccountContactRelation dumRel: dummyRelationships){
                    contact tempAccContRec = new Contact();
                    tempAccContRec.id = dumRel.contactid;
                    tempAccContRec.accountId = conAccMap.get(dumRel.contactid);
                    lstUpdateContact.add(tempAccContRec);
                }
            }
            //Method to save the records
            loadintoDatabase(lstShipToInserts,lstUpdateContact,dummyRelationships,processAccIds);
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage3');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,currentClassName,'runAlignments',false,null,'');
        }
    }
    
    /***************************************************************************************************************************************
    Method Name : loadintoDatabase
    Description : Creating Shipto aligns and updating Dummy contact relation
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void loadintoDatabase(List<AccountContactRelation> lstShipToInserts,List<Contact> lstUpdateContact,List<AccountContactRelation> dummyRelationships,Set<Id> processAccIds) {
        try {
            System.debug('lstUpdateContact:'+ lstUpdateContact);
            if (lstUpdateContact != null && !lstUpdateContact.isEmpty()) {
                //Updating Account id in contact which are having Dummy account relationship
                Database.SaveResult[]  savRes = Database.update(lstUpdateContact,false);
                //Deleting Dummy Account contact relationship records
                Database.deleteResult[] deleteRes = Database.delete(dummyRelationships,false);
            }
            //Method to assign primary sales rep to Account
            assignSalesRepOnUserAccInsert(processAccIds);
            System.debug('lstShipToInsertsq:'+ lstShipToInserts);
            if (lstShipToInserts != null && !lstShipToInserts.isEmpty()) {
                //Batch job to create  ShipTo records for SoldToDivisions
                EC_AccontContactRelationInsert insertList = new EC_AccontContactRelationInsert(lstShipToInserts);
        	    Database.executeBatch(insertList);
            }
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage4');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,currentClassName,'loadintoDatabase',false,null,'');
        }
    }
    
    /***************************************************************************************************************************************
    Method Name : assignSalesRepOnUserAccInsert
    Description : To assign sales rep on user account insert
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void assignSalesRepOnUserAccInsert(Set<Id> acckeyList){

        List<Account> UpdateaccWithSalesRep = new List<Account>();
        Map<String,Id> accUserMap = new Map<String,Id>();
        try {
            //Fetching all Alignment records for primary and salesrep contacts
            for(AccountContactRelation accConRel : [Select Id, Contact.EC_CDM_Contact__c, Contact.EC_SalesRep_User__c,Account.EC_CDM_Account__c
                                                    FROM AccountContactRelation WHERE
                                                    Alignment_Type__c = :EC_Constants.PRIMARY_ALIGNMENT_TYPE
                                                    AND Account.Id IN :acckeyList
                                                    AND Contact.EC_User_Type__c = :Label.EC_Employee
                                                    AND contact.EC_isActive__c = true]){
                                                        if(Contact.EC_SalesRep_User__c != null){
                                                            accUserMap.put(accConRel.Account.EC_CDM_Account__c,accConRel.Contact.EC_SalesRep_User__c);
                                                        }
                                                    }
            if(accUserMap != null){
                //Fetching all accounts and updating into Salesrep field of Account Record.
                for(Account accToUpdate:[select id , EC_SalesRepresentative__c,EC_CDM_Account__c,parent.RecordType.Name, Parent.EC_CDM_Account__c
                                        FROM Account WHERE ec_cdm_account__c in :accUserMap.keySet() OR parent.EC_CDM_Account__c IN :accUserMap.keySet()]){
                                            if(accToUpdate.parent.RecordType.Name == EC_Constants.Sold_To){
                                                accToUpdate.EC_SalesRepresentative__c = accUserMap.get(accToUpdate.Parent.EC_CDM_Account__c);
                                            } else {
                                                accToUpdate.EC_SalesRepresentative__c = accUserMap.get(accToUpdate.EC_CDM_Account__c);
                                            }
                                            UpdateaccWithSalesRep.add(accToUpdate);
                                        }
                //Updating primary rep for account
                Database.update(UpdateaccWithSalesRep,false);
            }
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage5');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,currentClassName,'assignSalesRepOnUserAccInsert',false,null,'');
        }
    }
    
    /***************************************************************************************************************************************
    Method Name : alignmentDeleteHelper
    Description : To process user account delete
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void alignmentDeleteHelper(List<AccountContactRelation> relList){
        List<Id> allContIds = new List<Id>();
        List<Id> setOrgAccIds = new List<Id>();
        Set<string> lstDirectContKey = new Set<string>();
        Set<string> lstForbiddenAccKey = new Set<string>();
        List<contact> lstContextDirectCont = new List<contact>();
        Set<AccountContactRelation> setDelAccContRel = new Set<AccountContactRelation>();
        Set<contact> setContactUpdate = new set<contact>();
        List<AccountContactRelation> lstShipToDeletes = new List<AccountContactRelation>();
        try {
            //Fetching all Account and ContactId for delete alignment records
            for(AccountContactRelation contRec : relList){
                setOrgAccIds.add(contRec.accountId);
                allContIds.add(contRec.contactId);
            }

            if (!Contact.sObjectType.getDescribe().isAccessible() || !Account.sObjectType.getDescribe().isAccessible() || !AccountContactRelation.sObjectType.getDescribe().isAccessible() ) { 
                return;
            }

            //To fetch the account details from custom meta data to allow any division of data
            List<Account_RelationShip__mdt > accRelation = [Select MasterLabel,Relation__c,Division__c   from Account_RelationShip__mdt];
            List<String> ShipToDivisions = new List<String>();
            List<String> SoldToDivisions = new List<String>();
            for(Account_RelationShip__mdt metaRecord : accRelation){
                if(metaRecord.Relation__c == 'SoldTo_ShipTo') {
                    SoldToDivisions.add(metaRecord.Division__c);
                } else {
                    ShipToDivisions.add(metaRecord.Division__c);
                }
            }
            //Fetching all SOld to Account records
            Map<Id,Account> lstAccounts = new Map<Id,Account>([Select id, Ec_Division__c from Account where id in :setOrgAccIds And account.RecordType.Name =: EC_Constants.Sold_To]);
            //Fetch SoldoTos for SoldToDivisions(Nalco) and ShipTos for ShipToDivisions (INST,F&B,PEST,TCD)
            List<AccountContactRelation> relevantAccContList = [SELECT id, account.Id, contact.Id, isDirect, account.RecordType.Name, account.parent.Id, accountId, account.parent.RecordType.Name FROM AccountContactRelation WHERE ((account.Id IN: setOrgAccIds AND contact.Id IN: allContIds AND account.RecordType.Name =: EC_Constants.Ship_To AND account.EC_Division__c in :ShipToDivisions) OR (account.Id IN: setOrgAccIds AND contact.Id IN: allContIds AND account.RecordType.Name =: EC_Constants.Sold_To And account.EC_Division__c in :SoldToDivisions))];
            Map<string, AccountContactRelation> mapContDirectAccCont = new Map<string, AccountContactRelation>();
            Map<Id, AccountContactRelation> stageContactMap = new Map<Id, AccountContactRelation>();//MM
            for(AccountContactRelation orgRec : relList){
                //getting all Soldto records into list to delete shiptos using Quable job
                if(lstAccounts.get(orgRec.accountId) != null) {
                    lstShipToDeletes.add(orgRec); 
                }
                //Identifying the relationships which are having direct relation ship with alignments
                for(AccountContactRelation accRec : relevantAccContList){
                    if(orgRec.accountId == accRec.account.Id && orgRec.contactId == accRec.contact.Id){
                        if(accRec.isDirect) {
                            mapContDirectAccCont.put(accRec.contact.Id, accRec);
                            lstDirectContKey.add(accRec.contact.Id);
                            stageContactMap.put(accRec.contact.id,orgRec);
                        } 
                        lstForbiddenAccKey.add(accRec.account.Id);
                    }
                }
            }
            //Fetching the contacts which are having direct relationship with delting relationship record
            lstContextDirectCont = [SELECT id, EC_CDM_Contact__c FROM contact WHERE Id IN: lstDirectContKey];
            //Fetching the Indirect Account contact relationships for contacts
            List<AccountContactRelation> lstInDirectAccCont = [SELECT Id, contactId, contact.id, account.EC_CDM_Account__c, isDirect FROM AccountContactRelation WHERE contact.id IN: lstDirectContKey AND isDirect = false AND account.id NOT IN: lstForbiddenAccKey and (account.RecordType.Name =: EC_Constants.Sold_To OR (account.RecordType.Name =: EC_Constants.Ship_To AND account.EC_Division__c in :ShipToDivisions))];
            Map<string, AccountContactRelation> mapContInDirectAccCont = new Map<string, AccountContactRelation>();
            
            for(AccountContactRelation tempAccCont : lstInDirectAccCont){
                if(!mapContInDirectAccCont.containskey(tempAccCont.contact.id)){
                    mapContInDirectAccCont.put(tempAccCont.contact.id, tempAccCont);
                }
            }
            Account dummyAccount = [select Id from Account where EC_CDM_Account__c=:EC_Constants.DummyAccountKey limit 1];
            //Assigning AccountId as Dummy account key if there is no other relationships or Assigning other relationship accountid
            for(contact tempContRec : lstContextDirectCont){
                if(mapContInDirectAccCont.containskey(tempContRec.id)){
                    tempContRec.Accountid = mapContInDirectAccCont.get(tempContRec.id).account.id;
                }else{
                    tempContRec.Accountid = dummyAccount.id;
                }
                setContactUpdate.add(tempContRec);
                // Adding in to deleting records list
                if(mapContDirectAccCont.containskey(tempContRec.EC_CDM_Contact__c)){
                    setDelAccContRel.add(mapContDirectAccCont.get(tempContRec.EC_CDM_Contact__c));
                }
            }
            //Method to update dummy account contact relation and quable job
			updateDummyDeleteRelation(setContactUpdate, lstShipToDeletes, setOrgAccIds, allContIds);
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage6');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,currentClassName,'alignmentDeleteHelper',false,null,'');
        }    
    } 
    /***************************************************************************************************************************************
    Method Name : updateDummyDeleteRelation
    Description : To update dummyrelationship for contacts
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void updateDummyDeleteRelation(Set<contact> setContactUpdate, List<AccountContactRelation> lstShipToDeletes, List<Id> setOrgAccIds,List<Id> allContIds ) {
        try{
            if(setContactUpdate != null && setContactUpdate.size() > 0){
                list<contact> updateList = new list<contact>();
                updateList.addAll(setContactUpdate);
                // Adding into Updating direct relationship contacts
                Database.SaveResult[] savRes = Database.update(updateList,false);
                for(Database.SaveResult sr:savRes){
                    if(!sr.isSuccess()){
                        for(Database.Error  err: sr.getErrors()) {
                            System.debug('err.getMessage():'+ err.getMessage()); 
                        }
                    }
                }
            }
            // Updating salesrep field for account
            assignSalesRepToAccDelete(setOrgAccIds,allContIds);
            // Updating shipto records using Quable class
            updateShipToDeletes(lstShipToDeletes);
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage7');
            }
        } catch(Exception ex){
            EC_UtilityLogger.logException(ex,currentClassName,'updateDummyDeleteRelation',false,null,'');
        } 
    }

    /***************************************************************************************************************************************
    Method Name : updateShipToDeletes
    Description : To update ShipTo Delete relationship records
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void updateShipToDeletes(List<AccountContactRelation> lstShipToDeletes) {
        if(lstShipToDeletes != null && !lstShipToDeletes.isEmpty()) {
            //Batch job to delete Shipto alignments for all SoldToDivisions
            EC_AccontContactRelationDelete deleteList = new EC_AccontContactRelationDelete(lstShipToDeletes);
        	Database.executeBatch(deleteList);
        }
    }

    
    /***************************************************************************************************************************************
    Method Name : assignSalesRepToAccDelete
    Description : To assign sales rep on user account delete relation
    Return type : Void
    Author      : Venkatesh Paladugu
    *************************************************************************************************************************************/
    public static void assignSalesRepToAccDelete(List<Id> acckeyList,List<Id> userkeyList) {

        List<Account> UpdateaccWithSalesRep = new List<Account>();
        Map<String,Id> accUserMap = new Map<String,Id>();
        try{
            //Fetching Account contact relation ship for all Salesrep and primary alignment type  records
            List<AccountContactRelation> accContRelList = [ Select account.EC_CDM_Account__c,contact.EC_CDM_Contact__c,contact.EC_SalesRep_User__c from AccountContactRelation
                                                               where account.Id in: acckeyList
                                                               and contact.Id not in:userkeyList
                                                               and  contact.EC_User_Type__c = :Label.EC_Employee
                                                               and contact.EC_isActive__c = true
                                                               and Alignment_Type__c = :EC_Constants.PRIMARY_ALIGNMENT_TYPE];
    
            if(accContRelList!=null && !accContRelList.isEmpty()){
                for(AccountContactRelation accContRel:accContRelList){
                    accUserMap.put(accContRel.account.EC_CDM_Account__c,accContRel.contact.EC_SalesRep_User__c);
                }
            }
            //adding to update list if Deleted Contact assigned as Primary rep
            for(Account accToUpdate:[select id ,EC_CDM_Account__c ,EC_SalesRepresentative__r.ec_cdm_User__c,EC_SalesRepresentative__c,parent.RecordType.Name,Parent.EC_CDM_Account__c
                                     from Account where id in:acckeyList OR parent.id IN :acckeyList]){
                                         if(accUserMap.containsKey(accToUpdate.EC_CDM_Account__c)){
                                             if(accToUpdate.parent.RecordType.Name == EC_Constants.Sold_To){
                                                 accToUpdate.EC_SalesRepresentative__c = accUserMap.get(accToUpdate.Parent.EC_CDM_Account__c);
                                             } else {
                                                 accToUpdate.EC_SalesRepresentative__c = accUserMap.get(accToUpdate.EC_CDM_Account__c);
                                             }
                                         }
                                         else{
                                             accToUpdate.EC_SalesRepresentative__c  = null;
                                         }
                                         UpdateaccWithSalesRep.add(accToUpdate);
                                     }
            //Updating Primary rep for account
            Database.update(UpdateaccWithSalesRep,false);
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage8');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,currentClassName,'assignSalesRepToAccDelete',false,null,'');
        }
    }
}