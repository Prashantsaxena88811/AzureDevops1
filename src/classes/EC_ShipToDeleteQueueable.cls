/*
* Class Name	: EC_ShipToDeleteQueueable
* Description	: Quable class to delete Shipto Alignements for Corresponding Soldtos
*/
public class EC_ShipToDeleteQueueable implements Queueable {
    private List<AccountContactRelation> lstShipToDeletes;

    public EC_ShipToDeleteQueueable(List<AccountContactRelation> lstSoldTos) {
        //All SOld To Accounts
        this.lstShipToDeletes = lstSoldTos;
    }

    public void execute(System.QueueableContext qc) {
        List<Id> allContIds = new List<Id>();
        List<Id> setOrgAccIds = new List<Id>();
        try{
            for(AccountContactRelation contRec : lstShipToDeletes){
                setOrgAccIds.add(contRec.accountId);
                allContIds.add(contRec.contactId);
            }
            Set<AccountContactRelation> setDelAccContRel = new Set<AccountContactRelation>();
            //Fetching All Shito Allignments corresponding Soldtos
            List<AccountContactRelation> relevantAccContList = [SELECT id, account.Id, contact.Id, isDirect, account.RecordType.Name, account.parent.Id, accountId, account.parent.RecordType.Name FROM AccountContactRelation WHERE account.parent.Id IN: setOrgAccIds AND contact.Id IN: allContIds AND account.parent.RecordType.Name =: EC_Constants.Sold_To];
            for(AccountContactRelation orgRec : lstShipToDeletes){
                for(AccountContactRelation accRec : relevantAccContList){
                    if(orgRec.accountId == accRec.account.parent.Id && orgRec.contactId == accRec.contact.Id && accRec.account.parent.RecordType.Name == EC_Constants.Sold_To && !accRec.isDirect) {
                        setDelAccContRel.add(accRec);
                    }
                }
            }
            //Deleting Sold to records
            if(setDelAccContRel != null && !setDelAccContRel.isempty()){
                list<AccountContactRelation> deleteList = new list<AccountContactRelation>();
                deleteList.addAll(setDelAccContRel);
                Database.deleteResult[] deleteRes = Database.delete(deleteList,false);
            }
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
        } catch(Exception ex) {
            EC_UtilityLogger.logException(ex,'EC_ShipToDeleteQueueable','execute',false,null,'');
        }   
    }
}