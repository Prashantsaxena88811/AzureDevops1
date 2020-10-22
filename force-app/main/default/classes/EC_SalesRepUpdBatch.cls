/* Class Name       :EC_StagingUserDelete
* Description      :Batch class to update Sales rep on account
* Created By       :Shivam Vats
* Created On       :08-23-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Shivam Vats        08-23-2019                                    Batch class to update Sales rep on account
*
*/

global class EC_SalesRepUpdBatch implements Database.Batchable<Sobject> {
  global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT EC_CDM_Account__c FROM Account where  EC_SalesRepresentative__c = \'\' OR EC_SalesRepresentative__r.EC_CDM_User_Status__c = false';
        return Database.getQueryLocator(query);
     }
     global void execute(Database.BatchableContext bc,List<Account> acctRecords){
        List<Account> acctUpdate = new list<Account>();
        List<AccountContactRelation> accContactList = new List<AccountContactRelation>();
        Map<String,Id> accContMap = new Map<String,Id>();
        List<String> accKeyRecords = new List<String>();

         for(Account acc:acctRecords)
         {
             accKeyRecords.add(acc.EC_CDM_Account__c);
         }

        accContactList = [SELECT id, contact.EC_SalesRep_User__c, account.EC_CDM_Account__c FROM AccountContactRelation where contact.EC_SalesRep_User__r.EC_CDM_User_Status__c = true and contact.EC_SalesRep_User__r.User_Type__c = 'Internal' and account.EC_CDM_Account__c in :accKeyRecords];
        for(AccountContactRelation accCont: accContactList){
            if(!accContMap.containsKey(accCont.account.EC_CDM_Account__c)){
                if(accCont.contact.EC_SalesRep_User__c != null){
                    accContMap.put(accCont.account.EC_CDM_Account__c,accCont.contact.EC_SalesRep_User__c);
                }
            }
        }
        for(Account acct:[Select EC_CDM_Account__c,EC_SalesRepresentative__c from Account where EC_CDM_Account__c in:accKeyRecords]){
            if(accContMap.containskey(acct.EC_CDM_Account__c)){
                acct.EC_SalesRepresentative__c = accContMap.get(acct.EC_CDM_Account__c);
            }else{
                acct.EC_SalesRepresentative__c = null;
            }
           acctUpdate.add(acct);
        }
        if(acctUpdate != null && !acctUpdate.isEmpty()){
            update acctUpdate;
        }

    }

    global void finish(Database.BatchableContext bc){

    }
      }