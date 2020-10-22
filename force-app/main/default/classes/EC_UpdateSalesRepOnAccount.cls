/* Class Name      :EC_UpdateSalesRepOnAccount
* Description      :Class to update sales rep on account if existing sales rep becomes inactive.
* Created By       :Mishika Mahajan
* Created On       :09-23-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          09-23-2019                                    Class to update sales rep on account if existing sales rep becomes inactive.
*
*/
public class EC_UpdateSalesRepOnAccount {
/***************************************************************************************************************************************
Method Name : updateSalesRepOnUserInactive
Description : Used to active sales rep on account in case existing sales rep inactivated.
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    public static void updateSalesRepOnUserInactive(List<Id> inactiveUserList){

        Map<Id,Id> accountSalesRepMap = new Map<Id,Id>();
          List<Account> updateAccList = new  List<Account>();
       Map<Id,Account> accMap = new Map<Id,Account>([Select id, name,EC_SalesRepresentative__c from Account where EC_SalesRepresentative__c in:inactiveUserList]);
       List<AccountContactRelation> accConRelList = [select contact.EC_SalesRep_User__c,accountId from AccountContactRelation where accountId in :accMap.keySet()
                                                 and contact.EC_SalesRep_User__c!=null and contact.EC_SalesRep_User__c not in :inactiveUserList and contact.EC_User_Type__c= :Label.EC_Employee and contact.EC_isActive__c = true];
        if(accConRelList!=null && !accConRelList.isEmpty()){
        for(AccountContactRelation accConRel:accConRelList){
            if(!accountSalesRepMap.containsKey(accConRel.AccountId)){
            accountSalesRepMap.put(accConRel.AccountId,accConRel.contact.EC_SalesRep_User__c);
            }
          }
        }
        for(Account acc:accMap.values()){
            if(accountSalesRepMap.containsKey(acc.id)){
            acc.EC_SalesRepresentative__c = accountSalesRepMap.get(acc.id);
                updateAccList.add(acc);
                }else{ acc.EC_SalesRepresentative__c = null;
                    updateAccList.add(acc);
                }
        }
      Database.update(updateAccList,false);
    }

}