/* Class Name       :batchCreateAccountContact
 * Description      :Batch class to create account contact
 * Created By       :Shivam Vats
 * Created On       :07-05-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Shivam Vats         07-05-2019                                   Batch class to create account contact
 *
 */

global class batchCreateAccountContact implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id, accountId, contactId, Alignment_Type__c FROM AccountContactRelation WHERE account.RecordType.Name = \'Sold To\'';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<AccountContactRelation> scope) {
        Set<Id> setSoldAccIds = new Set<Id>();
        Set<Id> scopeContIds = new Set<Id>();
        for(AccountContactRelation contRec : scope){
            setSoldAccIds.add(contRec.accountId);
            scopeContIds.add(contRec.contactId);
        }

        List<account> lstBlanketAccounts = [SELECT Id, parentid FROM account WHERE parentid IN:setSoldAccIds AND recordtype.Name = 'Ship To'];

        map<Id, List<Id>> mapParentChildAcc = new map<Id, List<Id>>();
        Set<Id> setShipAccIds = new Set<Id>();

        for(account accRec : lstBlanketAccounts){
            if(mapParentChildAcc.containsKey(accRec.parentid)){
                mapParentChildAcc.get(accRec.parentid).add(accRec.id);
            }else{
                List<Id> tempStrList = new List<Id>();
                tempStrList.add(accRec.id);
                mapParentChildAcc.put(accRec.parentid, tempStrList);
            }
            setShipAccIds.add(accRec.Id);
        }

        Set<AccountContactRelation> lstInsertAccCont = new Set<AccountContactRelation>();
        for(AccountContactRelation contRec : scope){
            if(mapParentChildAcc.containsKey(contRec.accountId)){
                for(Id tempStr : mapParentChildAcc.get(contRec.accountId)){
                    AccountContactRelation tempInsertAccCont = new AccountContactRelation();
                    tempInsertAccCont.contactId = contRec.contactId;
                    tempInsertAccCont.accountId = tempStr;
                    if(!String.isBlank(contRec.Alignment_Type__c)){
                        tempInsertAccCont.Alignment_Type__c = contRec.Alignment_Type__c; //BUG-133500
                    }
                    lstInsertAccCont.add(tempInsertAccCont);
                }
            }
        }
        
        List<AccountContactRelation> lstExistingAccContRel = [SELECT id, ContactId,Alignment_Type__c,accountId FROM AccountContactRelation WHERE account.RecordType.Name = 'Ship To' AND (contactId IN: scopeContIds AND accountId IN: setShipAccIds)];
        
        for(AccountContactRelation tempAccCont : lstInsertAccCont){
            for(AccountContactRelation tempExistAccCont : lstExistingAccContRel){
                if(tempAccCont.ContactId == tempExistAccCont.ContactId && tempAccCont.accountId == tempExistAccCont.accountId){
                    lstInsertAccCont.remove(tempAccCont);
                }
            }
        }

        List<AccountContactRelation> finalInsertList = new List<AccountContactRelation>();
        finalInsertList.addAll(lstInsertAccCont);
        insert finalInsertList;
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}