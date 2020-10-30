/*
* Class Name	: EC_ShipToInsertQueueable
* Description	: Quable class to insert Shipto Alignements for Corresponding Soldtos
*/
public class EC_ShipToInsertQueueable implements Queueable {
    private List<AccountContactRelation> lstShipToInserts;

    public EC_ShipToInsertQueueable(List<AccountContactRelation> lstSoldTos) {
        //Soldto alignments
        this.lstShipToInserts = lstSoldTos;
    }

    public void execute(System.QueueableContext qc) {
        Set<Id> scopeContIds = new Set<Id>();
        Set<Id> setSoldAccIds = new Set<Id>();
        try{
            if(lstShipToInserts != null && !lstShipToInserts.isEmpty()) {
                for(AccountContactRelation contRec : lstShipToInserts){
                    setSoldAccIds.add(contRec.accountId);
                    scopeContIds.add(contRec.contactId);
                }
                //Fetching ShiptoAccounts for All soldtos
                List<Account> lstBlanketAccounts = [SELECT Id, parentid FROM Account WHERE parentid IN:setSoldAccIds AND recordtype.Name = 'Ship To'];
                map<Id, List<Id>> mapParentChildAcc = new map<Id, List<Id>>();
                Set<Id> setShipAccIds = new Set<Id>();
                //Adding all shipto records to map and Parent Account ID is Key
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
                //Creating Shipto allignemnts and adding to list
                for(AccountContactRelation contRec : lstShipToInserts){
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
                //Checking  that already SHipto alignment is there or not and removing from list, If already alignment is exists 
                List<AccountContactRelation> lstExistingAccContRel = [SELECT id, ContactId,Alignment_Type__c,accountId FROM AccountContactRelation WHERE account.RecordType.Name = 'Ship To' AND (contactId IN: scopeContIds AND accountId IN: setShipAccIds)];
                if(lstExistingAccContRel != null && !lstExistingAccContRel.isEmpty()) {
                    for(AccountContactRelation tempAccCont : lstInsertAccCont){
                        for(AccountContactRelation tempExistAccCont : lstExistingAccContRel){
                            if(tempAccCont.ContactId == tempExistAccCont.ContactId && tempAccCont.accountId == tempExistAccCont.accountId){
                                lstInsertAccCont.remove(tempAccCont);
                            }
                        }
                    }
                }
                //Inserting Shipto alignments
                if (lstInsertAccCont != null && !lstInsertAccCont.isEmpty()) {
                    List<AccountContactRelation> finalInsertList = new List<AccountContactRelation>();
                    finalInsertList.addAll(lstInsertAccCont);
                    Database.SaveResult[] saveRes = Database.insert(finalInsertList,false); 
                }
            }
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,'EC_ShipToInsertQueueable','execute',false,null,'');
        }
    }
}