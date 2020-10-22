/* Class Name      :EC_AccAccessSalesRepHelper
* Description      :helper class for EC_AccAccessSalesRep trigger
* Created By       :Mishika Mahajan
* Created On       :08-08-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          08-08-2019                                   helper class for EC_AccAccessSalesRep trigger
*/
public class EC_AccAccessSalesRepHelper {
   /***************************************************************************************************************************************
Method Name : createAccUserShare
Description : to insert account share record on insertion of AccountContactRelation Record
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    public static void createAccUserShare(Map<Id,AccountContactRelation> accConRelMap){
        System.debug('2222222222222222222');
        List<AccountShare> accShareList = new List<AccountShare>();
        List<AccountContactRelation> accConRelList = [select accountId,ContactId,contact.EC_SalesRep_User__r.profile.Name from AccountContactRelation where id in:accConRelMap.keySet()
                                                     and contact.EC_SalesRep_User__c!= null and contact.EC_SalesRep_User__r.isActive = true and contact.EC_User_Type__c=:Label.EC_Employee];
        if(accConRelList!=null && !(accConRelList.isEmpty())){
        for(AccountContactRelation acr: accConRelList){
             AccountShare accShare;
             if( acr.contact.EC_SalesRep_User__r.profile.Name == System.Label.EC_User_Profile_Name )   {
            accShare = new AccountShare();
            accShare.AccountId =acr.AccountId;
            accShare.UserOrGroupId =acr.Contact.EC_SalesRep_User__c;
            accShare.RowCause = EC_Constants.MANUAL;
            accShare.AccountAccessLevel=EC_Constants.EDIT;
            accShare.OpportunityAccessLevel=EC_Constants.READ;
            accShareList.add(accShare);
            }
          }
        }
        if(accShareList!=null){
       Database.SaveResult[] savRes = Database.insert(accShareList,false);

            for(Database.SaveResult sr:savRes){
            if(!sr.isSuccess()){
                for(Database.Error  err: sr.getErrors()) {
             //EC_UtilityLogger.logException(null,'EC_AccAccessSalesRepHelper','createAccUserShare',true,err,'');
                }
            }
        }
      }
    }

 /***************************************************************************************************************************************
Method Name : deleteAccUserShare
Description : to delete account share record on AccountContactRelation Record
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/

     public static void deleteAccUserShare(Map<Id,AccountContactRelation> accConRelMap){
         List<AccountShare> accShareList = new List<AccountShare>();
         List<Id> accShareToDelete = new List<Id>();
         List<Id> accConIdList = new List<Id>();
         List<Id> userIdList = new List<Id>();
         Set<String>  accContIdSet = new Set<String>();

         List<AccountContactRelation> accConRelList = [select accountId,ContactId,contact.EC_SalesRep_User__r.profile.Name from AccountContactRelation where id in:accConRelMap.keySet()];
            if(accConRelList!=null){
              for(AccountContactRelation acr: accConRelList){
                if( acr.contact.EC_SalesRep_User__r.profile.Name == System.Label.EC_User_Profile_Name ){
                    accConIdList.add(acr.AccountId);
                    userIdList.add(acr.Contact.EC_SalesRep_User__c);
                    accContIdSet.add(acr.Contact.EC_SalesRep_User__c+'_'+acr.AccountId);
                   }
                }
             }


         if(accConIdList!=null && !(accConIdList.isEmpty())){
         accShareList = EC_QueryUtility.getAccShare(accConIdList,userIdList);
         if(accShareList!=null && !(accShareList.isEmpty())){
             for(AccountShare acshare:accShareList){
                 String accContId = acshare.UserOrGroupId+'_'+ acshare.AccountId;
                 if(accContIdSet.contains(accContId)){
                 accShareToDelete.add(acshare.id);
                 }
             }
         }

       }

             if(accShareToDelete!=null && !(accShareToDelete.isEmpty())){
            Database.DeleteResult[] savRes = Database.delete(accShareToDelete,false);
           }
        }
    }