/* Class Name    : EC_ccLogicUserGetProfileDataCustom 
 * Description      :Class to extend the Cloudcraze Logic Class ccLogicUserGetProfileData
 * Created By       :Chintan
 * Created On       :2019-Aug-24
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Chintan            2019-Aug-24        BC-75723            Created the class   
 *
 */
global class EC_ccLogicUserGetProfileDataCustom extends ccrz.ccLogicUserGetProfileData
{

    /***************************************************************************************************************************************
  Method Name : getContactData
  Description : process used to retrieve the salesrep contact
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
    global  override Map<String, Object> getContactData(Map<String, Object> inputData) 
    {
        String contactId ='';
        Contact contact;
        
        if(!Test.isRunningTest() && !isInternalUser()){
            inputData = super.getContactData(inputData);
        }
        
        ccrz.cclog.log('Inside Logic User Get Profile---CP3');
        if(isInternalUser()){
            
            contact = [Select Id FROM Contact WHERE EC_SalesRep_User__c=:UserInfo.getUserId()];//'0036A00000RTWCm';
            contactId  = contact.id;
            ccrz.cc_CallContext.currContact = contact;
            
            Map<String, Object> contactResult = ccrz.ccApiContact.fetch(new Map<String, Object> {
                    ccrz.ccApi.API_VERSION => inputData.get(ccrz.ccApi.API_VERSION),
                    ccrz.ccApiContact.ID => contactId,
                    ccrz.ccApi.SIZING=>new Map<String, Object>{
                            ccrz.ccApiContact.ENTITYNAME=>ccrz.ccUtil.defv(inputData, ccrz.ccAPI.SIZING, new Map<String, Object>())
                            }
            });
        
            List<Map<String, Object>> contactList = (List<Map<String, Object>>) contactResult.get(ccrz.ccApiContact.CONTACTS);
         
            if(ccrz.ccUtil.isNotEmpty(contactList)) 
            {
                inputData.put(ccrz.ccApiUser.USER_PROFILE_CONTACT, contactList.get(0));
            }
            inputData.put(ccrz.ccApi.MESSAGES, contactResult.get(ccrz.ccApi.MESSAGES));
            
            ccrz.cclog.log('before end call'+contactResult.get(ccrz.ccApi.MESSAGES) );
        }
        return inputData;
    }
    
  /***************************************************************************************************************************************
  Method Name : getAccountData
  Description : getAccountData used to retrieve the salesrep contact's account
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
    global  override Map<String, Object> getAccountData(Map<String, Object> inputData) 
    {
        String accountId;
        Contact contactId2 = null;    
        ccrz.cclog.log('Inside Logic User Get Account---CP3');
        
        if(!Test.isRunningTest() && !isInternalUser()){
            inputData = super.getAccountData(inputData);
        }
        if(isInternalUser()){
            
            if (null ==  ccrz.cc_CallContext.currUser.AccountId)
            { 
                String effectiveAccount ='';
                ccrz.cclog.log('Inside Beforeeffectiveaccount1');
                ccrz.cclog.log('Inside Aftereffectiveaccount1');
                ccrz.cclog.log('Inside effectiveaccount null');
                List<Contact> contactId = [Select Id FROM Contact WHERE EC_SalesRep_User__c=:UserInfo.getUserId() LIMIT 1];
                ccrz.cclog.log('Inside effectiveaccount null'+contactId);
                  
                Id conId = (String)contactId[0].Id;
                ccrz.cclog.log('Inside effectiveaccount null'+conId);
                List<AccountContactRelation> lstAccConReln =  [SELECT AccountId,ContactId,IsDirect FROM AccountContactRelation WHERE ContactId =:conId AND IsDirect = true];
                ccrz.cclog.log('Inside effectiveaccount nulllstAccConReln '+lstAccConReln );
                accountId = lstAccConReln[0].AccountId;
                  
                ccrz.cc_CallContext.currContact = contactId[0];
                
                ccrz.cclog.log('Inside effectiveAccount'+accountId);
             }
            
            Map<String, Object> accountResult = ccrz.ccApiAccount.fetch(new Map<String, Object> {
                    ccrz.ccApi.API_VERSION => inputData.get(ccrz.ccApi.API_VERSION),
                    ccrz.ccApiAccount.ID => accountId 
            });
            
            List<Map<String, Object>> accountList = (List<Map<String, Object>>) accountResult.get(ccrz.ccAPIAccount.ACCOUNTS);
            
            if(ccrz.ccUtil.isNotEmpty(accountList)) 
            {
                inputData.put(ccrz.ccApiUser.USER_PROFILE_ACCOUNT, accountList.get(0));
            }
            
            inputData.put(ccrz.ccApi.MESSAGES, accountResult.get(ccrz.ccApi.MESSAGES));
        }
        
        return inputData;
    }    
    
    /***************************************************************************************************************************************
  Method Name : isInternalUser
  Description : Checks whether user is a salesrep or not
  Return type : Returns Boolena
 **************************************************************************************************************************************/
    public static boolean isInternalUser(){
        Boolean isInternalUser = false;
        User user = [Select User_Type__c from User Where Id=: userinfo.getUserId() Limit 1];
        if(String.isNotBlank(user.User_Type__c) && user.User_Type__c.equalsIgnoreCase('internal')){
            isInternalUser = true; 
        }
        return isInternalUser;    
    }
    

    
}