/* Class Name       :EC_StagingUserUpdate
* Description      :Batch class to process unprocessed records of EC_Mulesoft_CDM_Staging__c object.
* Created By       :Mishika Mahajan
* Created On       :07-22-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Ayusha Patnaik          08-23-2019                                    to process unprocessed records of EC_Mulesoft_CDM_Staging__c object.
*
*/
global class EC_StagingUserUpdate implements Database.Batchable<Sobject>
{
    global List<Id> usrIdList = new List<Id>();
    private List<String> userIds;
    private Map<String,EC_Mulesoft_CDM_Staging__c> userKeyMapstg;
    public EC_StagingUserUpdate(List<String> Ids, Map<String,EC_Mulesoft_CDM_Staging__c> userKeyMap){
        userIds = Ids;
        userKeyMapstg = userKeyMap;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([Select FirstName,Redemption_URL__c,LastName,Phone,email,EC_FederationIdentifier__c, EC_CDM_Contact__c,EC_Alias__c,EC_User_Type__c,EC_isActive__c from Contact where EC_CDM_Contact__c in : userIds]);
    }
    global void execute(Database.BatchableContext bc, List<Contact> lstContact){

        List<Id> lstUpdatedSuccess = new List<Id>();
        List<EC_Mulesoft_CDM_Staging__c> successRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new List<EC_Mulesoft_CDM_Staging__c>();
        List<String> permissionSetNames = new List<String>();
        Set<String> usrwthPermSet = new Set<String>();
        Map<String,Contact> userKeyMap = new  Map<String,Contact>();
        List<User>  userUpdate = new  List<User>();
        List<Id> inactiveUserList = new List<Id>();
        permissionSetNames.add(EC_Constants.BuyerPermissionSet);
        permissionSetNames.add(EC_Constants.BasicPermissionSet);
        permissionSetNames.add(EC_Constants.PayerPermissionSet);
        // Below list and Map are used for Exception Handling
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Map<Id,EC_Mulesoft_CDM_Staging__c> usrStageMap = new Map<Id,EC_Mulesoft_CDM_Staging__c>();
        Map<Integer,String> indexKeyMap = new Map<Integer,String>();
        Integer index = 0;

        for(Contact stge : lstContact){
            userKeyMap.put(stge.EC_CDM_Contact__c,stge);
        }

        for(PermissionSetAssignment psa:[SELECT Assignee.EC_CDM_User__c FROM PermissionSetAssignment where Assignee.EC_CDM_User__c in:userKeyMap.keySet() and PermissionSet.Name in:permissionSetNames])
        {
            usrwthPermSet.add(psa.Assignee.EC_CDM_User__c);
        }


        String jsonMap=JSON.serialize(userKeyMap.keySet());

      for(User usr:[select id,name,Username,Alias,Redemption_URL__c,Email,FirstName,LastName,FederationIdentifier,EC_CDM_User__c,phone,IsActive,User_Type__c from User where EC_CDM_User__c in: userKeyMap.keySet()]){
         //update user fields We are assigning Email for the userName field.Defect-82130
          usrStageMap.put(usr.Id,userKeyMapstg.get(usr.EC_CDM_User__c));
          usr.Username = userKeyMap.get(usr.EC_CDM_User__c).email + System.Label.EC_USERNAME ;
            if(userKeyMap.get(usr.EC_CDM_User__c).EC_Alias__c!=''){
                usr.Alias = userKeyMap.get(usr.EC_CDM_User__c).EC_Alias__c;}
            if(userKeyMap.get(usr.EC_CDM_User__c).EC_User_Type__c == EC_Constants.EMPLOYEE){
                usr.User_Type__c =EC_Constants.INTERNAL;
           if (userKeyMap.get(usr.EC_CDM_User__c).EC_isActive__c == true){
             System.debug('THE IFF CONDITION RESULT IS++++++'+usrwthPermSet.contains(usr.EC_CDM_User__c));
               if(usrwthPermSet.contains(usr.EC_CDM_User__c)){
                 System.debug('REACHED INSIDER IFFF CONDITION');
                   usr.IsActive = true;
               }
                usr.EC_CDM_User_Status__c = true;
                   }
           else{
                     usr.EC_CDM_User_Status__c = false;
                     usr.IsActive = false;
                }


            }
          else if(userKeyMap.get(usr.EC_CDM_User__c).EC_User_Type__c == EC_Constants.CUSTOMER){
              usr.User_Type__c = EC_Constants.EXTERNAL;
              if (userKeyMap.get(usr.EC_CDM_User__c).EC_isActive__c == true){
                  System.debug('REACHED FOR TRUE HERE +++++++++++++');
                  usr.EC_CDM_User_Status__c = true;
                  if(usrwthPermSet.contains(usr.EC_CDM_User__c)){
                      usr.IsActive = true;
                  }
              }
              else{
                  usr.EC_CDM_User_Status__c = false;
                  usr.IsActive = false;
              }
          }
          if(!(usr.IsActive) && userKeyMap.get(usr.EC_CDM_User__c).EC_isActive__c){
           //   usr.IsActive = true;
              if(usr.User_Type__c == EC_Constants.INTERNAL){
              usrIdList.add(usr.id);
              }
          }
          else if(usr.IsActive &&!(userKeyMap.get(usr.EC_CDM_User__c).EC_isActive__c))
          {
              // usr.IsActive = false;
              inactiveUserList.add(usr.id);
          }
          if(System.label.EC_Email_Extension == EC_Constants.PRODEMAILEXT){
              usr.Email = userKeyMap.get(usr.EC_CDM_User__c).email;
          }
          else{
              usr.Email = userKeyMap.get(usr.EC_CDM_User__c).email + System.label.EC_Email_Extension;
          }

            usr.TimeZoneSidKey = System.label.EC_UserTimeZoneSidKey;
            usr.LanguageLocaleKey = System.label.EC_UserLanguageLocaleKey;
            usr.LocaleSidKey = System.label.EC_UserLocaleSidKey;
            usr.FirstName = userKeyMap.get(usr.EC_CDM_User__c).FirstName;
            usr.LastName = userKeyMap.get(usr.EC_CDM_User__c).LastName;
            usr.FederationIdentifier = userKeyMap.get(usr.EC_CDM_User__c).email;
            usr.Phone = userKeyMap.get(usr.EC_CDM_User__c).Phone;
            usr.Redemption_URL__c = userKeyMap.get(usr.EC_CDM_User__c).Redemption_URL__c;
            userUpdate.add(usr);
            indexKeyMap.put(index, userKeyMap.get(usr.EC_CDM_User__c).Id);
            index++;
        }
        System.debug('UPDATING THE USERs HERE'+userUpdate);
        //update userUpdate;
        Database.SaveResult[] saveRes = Database.update(userUpdate,false);
        index = 0;
        for(Database.SaveResult sr:saveRes){
            if(sr.isSuccess()){
            lstUpdatedSuccess.add(sr.getId());
            }
            else {
                for(Database.Error  err: sr.getErrors()) {
                    //System.debug('The error in User Update is+++++++++'+err.getMessage());
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(indexKeyMap.get(index),null,null,null,
                                        null,null,null,null,null,null,err.getMessage(),'EC_StagingContactUtilities',
                                        'UserUpdate');
                        stageLogWrapList.add(stageLogWrap);
                }
            }
            index++;
        }
        for(User usr:[Select Id,EC_CDM_User__c from User where Id in:lstUpdatedSuccess]){
            successRecords.add(userKeyMapstg.get(usr.EC_CDM_User__c));
        }

          System.enqueueJob(new EC_StagingAccountShareQueuable(usrIdList,successRecords,inactiveUserList,stageLogWrapList));

         }
    global void finish(Database.BatchableContext bc){

    }

}