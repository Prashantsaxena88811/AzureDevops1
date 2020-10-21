/* Class Name      :EC_StagingPermissionUserUpdate
* Description      :Batch Class to update permission on user
* Created By       :Shivam Vats
* Created On       :09-23-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Shivam Vats         09-23-2019                                   Batch Class to update permission on user
*
*/

global class EC_StagingPermissionUserUpdate implements Database.Batchable<Sobject> {

   private List<String> userKeys;
   public EC_StagingPermissionUserUpdate(List<String> usrKeys){
        userKeys = usrKeys;
          }
    global Database.QueryLocator start(Database.BatchableContext bc) {
         return Database.getQueryLocator([select IsActive,EC_CDM_User_Status__c,EC_CDM_User__c from User where EC_CDM_User__c in: userKeys]);
    }
    global void execute(Database.BatchableContext bc, List<User> Userlst){
       Map<String,Boolean> usrStatusMap = new  Map<String,Boolean>();
       List<User> updtUserLst = new List<User>();
        for(Contact cntct:[Select EC_CDM_Contact__c,EC_isActive__c from Contact where EC_CDM_Contact__c in:userKeys ])
        {
         usrStatusMap.put(cntct.EC_CDM_Contact__c,cntct.EC_isActive__c);
        }

        for(User usr:Userlst){
            usr.IsActive = usrStatusMap.get(usr.EC_CDM_User__c);
            usr.EC_CDM_User_Status__c = usrStatusMap.get(usr.EC_CDM_User__c);
            updtUserLst.add(usr);
        }
        if(updtUserLst != null && updtUserLst.size()>0){

             Database.SaveResult[] saveRes = Database.update(updtUserLst,false);
        }


                }
    global void finish(Database.BatchableContext bc){

    }
}