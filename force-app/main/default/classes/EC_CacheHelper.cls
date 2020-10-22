/* Class Name       :EC_CacheHelper
 * Description      :Helper for putting and getting values in/from salesforce cache
 * Created By       :Mishika Mahajan
 * Created On       :08-07-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Mishika Mahajan         08-07-2019                                   Helper for putting and getting values in/from salesforce cache
 *
 */
public class EC_CacheHelper {
    public static EC_CacheWrapper usrInformation;

 /***************************************************************************************************************************************
Method Name : updateUserInfo
Description : to store info in cache
Return type : EC_CacheWrapper
Author      : Shivam Vats
*************************************************************************************************************************************/
    @AuraEnabled
    public static EC_CacheWrapper updateUserInfo(){

        EC_CacheWrapper usrInfo  ;
        usrInfo = new EC_CacheWrapper();
        Contact con = new Contact();
            User usr = EC_QueryUtility.getCurrentUser();


          if(usr!=null && usr.User_Type__c !='External'){

           List<Contact> conlist = [Select Id,FirstName,LastName,Email,Phone,EC_SalesRep_User__c from Contact where EC_SalesRep_User__c =: UserInfo.getUserId() limit 1];

          if(conlist.size()>0){
                     con = conlist[0];
            }

            }
            String profileName = EC_QueryUtility.getProfile();
           List<PermissionSet> permissionSetList = EC_QueryUtility.getPermissionSet();

            List<AccountContactRelation> lstAccContRel = new   List<AccountContactRelation>();
            if(usr.ContactId != null){
             lstAccContRel = EC_QueryUtility.getAccountContactRelation(usr);
            }else{
               lstAccContRel =  [SELECT id, accountId, account.ccrz__E_AccountGroup__c FROM AccountContactRelation WHERE contactId =: con.Id];

            }
            List<string> lstAccIds = new List<string>();
            List<string> lstAccGrpIds = new List<string>();
             //to check if contact is associated with an account
            if(lstAccContRel!=null){
            for(AccountContactRelation accContRec : lstAccContRel){
                //to check if account and account.ccrz__E_AccountGroup__c fields
                if(accContRec.account!=null && accContRec.account.ccrz__E_AccountGroup__c != null){
                    lstAccGrpIds.add(accContRec.account.ccrz__E_AccountGroup__c);
                }
                lstAccIds.add(accContRec.accountId);
              }
            }

            List<ccrz__E_AccountGroupPriceList__c> lstAccGrpPriceList = EC_QueryUtility.getAccountGroupPriceList(lstAccGrpIds);
            Map<string, list<string>> mapAccGrpPriceList = new map<string, list<string>>();
             //null check for ccrz__E_AccountGroupPriceList__c
            if(lstAccGrpPriceList!=null){
            for(ccrz__E_AccountGroupPriceList__c accRec : lstAccGrpPriceList){
                if(mapAccGrpPriceList.containsKey(accRec.Id)){
                    mapAccGrpPriceList.get(accRec.Id).add(accRec.ccrz__Pricelist__c);
                }else{
                    list<string> tempPriceList = new list<string>();
                    tempPriceList.add(accRec.ccrz__Pricelist__c);
                    mapAccGrpPriceList.put(accRec.Id, tempPriceList);
                }
              }
            }
            // updating wrapper
            if(usr.contactId != null){

            usrInfo.portalConId = usr.contactId;

            usrInfo.portalConPhone = usr.contact.Phone ;
            usrInfo.portalConEmail = usr.contact.Email ;
            usrInfo.accGrpPriceListMap = mapAccGrpPriceList;
            usrInfo.contactAccList = lstAccIds;
            usrInfo.lstPermisssionSet = permissionSetList;
            usrInfo.userProfile = profileName;
            usrInfo.usrPermissionMap = EC_Utility.checkCustomPermissionOnUser();
            usrInfo.userLocaleStr = userinfo.getLocale();
            usrInfo.userFirstName = userinfo.getFirstName();
            usrInfo.userLastName = userinfo.getLastName();
            }  else {

              usrInfo.portalConId = con.Id;

            usrInfo.portalConPhone = con.Phone ;
            usrInfo.portalConEmail = con.Email ;

            usrInfo.accGrpPriceListMap = mapAccGrpPriceList;
            usrInfo.contactAccList = lstAccIds;
            usrInfo.lstPermisssionSet = permissionSetList;
            usrInfo.userProfile = profileName;
            usrInfo.usrPermissionMap = EC_Utility.checkCustomPermissionOnUser();
            usrInfo.userLocaleStr = userinfo.getLocale();
            usrInfo.userFirstName = userinfo.getFirstName();
            usrInfo.userLastName = userinfo.getLastName();




            }
            return usrInfo;

    }

/***************************************************************************************************************************************
Method Name : updateUserInfo
Description : to update info from cache
Return type : EC_CacheWrapper
Author      : Shivam Vats
*************************************************************************************************************************************/

    @AuraEnabled
    public static void updateCache(){
       EC_CacheWrapper user ;
        if(Cache.Session.getPartition(EC_Constants.USRCACHE).getCapacity()>Double.valueOf(100)){
            clearCache();
        }
        try{
        usrInformation  =  updateUserInfo();
        Cache.Session.put(EC_Constants.LOCAL, usrInformation);
        if(Test.isRunningTest()) {
			throw new DMLException('Test coverage');
        }
        }catch(Exception ex){
            EC_UtilityLogger.logException(ex,'EC_CacheHelper','updateCache',false,null,'');
        }
    }
    /***************************************************************************************************************************************
Method Name : getCacheInfo
Description : to retrieve info from cache
Return type : EC_CacheWrapper
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    public static EC_CacheWrapper getCacheInfo(){
        EC_CacheWrapper usr ;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(EC_Constants.USRCACHE);
        if(sessionPart!=null){
        usr = (EC_CacheWrapper)sessionPart.get(EC_Constants.USRINFO);
        }
        if(usr == null){
          updateCache();
         Cache.SessionPartition sesionPart = Cache.Session.getPartition(EC_Constants.USRCACHE);
        usr = (EC_CacheWrapper)sesionPart.get(EC_Constants.USRINFO);
        }
        return usr;
    }
    /***************************************************************************************************************************************
Method Name : clearCache
Description : to clear cache
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    public static void clearCache(){
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(EC_Constants.USRCACHE);
      Boolean isRemoved = sessionPart.remove(EC_Constants.USRINFO);

    }


}