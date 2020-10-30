/* Class Name    : EC_ccLogicAccountGetCurrentCustom 
 * Description      :Class to extend the Cloudcraze Logic Class ccLogicAccountGetCurrentCustom 
 * Created By       :Viraj  
 * Created On       :2019-Jul-24
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Jul-24        BC-75723          Created the class   
 *
 */
global class EC_ccLogicAccountGetCurrentCustom extends ccrz.ccLogicAccountGetCurrent 
{
   
 /***************************************************************************************************************************************
  Method Name : process
  Description : process used to retrieve the salesrep contact's account
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
 global  override Map<String,Object> process(Map<String,Object> inpData)
 {
     Map<String,Object> ret = new Map<String,Object>()  ;
     String accountId='';
     ccrz.cclog.log('Inside Logic Get Current Custom');
     ccrz.cclog.log('Inside BeforeIf'+ccrz.cc_CallContext.currUser.AccountId);
     if (null ==  ccrz.cc_CallContext.currUser.AccountId)
     { 
            String effectiveAccount ='';
            ccrz.cclog.log('Inside Beforeeffectiveaccount1');
            ccrz.cclog.log('Inside Aftereffectiveaccount1');
            if(EC_ccLogicAccountGetCurrentCustom.isInternalUser())
            { 
              ccrz.cclog.log('Inside effectiveaccount null');
              List<Contact> contactId = [Select Id FROM Contact WHERE EC_SalesRep_User__c=:UserInfo.getUserId() LIMIT 1];
              ccrz.cclog.log('Inside effectiveaccount null'+contactId);
              
              Id conId = (String)contactId[0].Id;
              ccrz.cclog.log('Inside effectiveaccount null'+conId);
              List<AccountContactRelation> lstAccConReln =  [SELECT AccountId,ContactId,IsDirect FROM AccountContactRelation WHERE ContactId =:conId AND IsDirect = true];
              ccrz.cclog.log('Inside effectiveaccount nulllstAccConReln '+lstAccConReln );
              accountId = lstAccConReln[0].AccountId;
              
              ccrz.cc_CallContext.currContact = contactId[0];
               
            }
            else
            {
                effectiveAccount = ccrz.cc_CallContext.effAccountId;
                ccrz.cclog.log('Inside effectiveAccount not null');
                Account effAccount ;
                List<Account> effAccountList = [Select Id FROM Account WHERE Id=:effectiveAccount LIMIT 1];
                if(!effAccountList.isEmpty()){
                    effAccount = effAccountList[0];
                    ccrz.cclog.log('Inside effectiveAccount not null'+effAccount);
                    accountId = effAccount.Id;//effAccount.Id;
                }
                 
            }
         
         ccrz.cclog.log('Inside effectiveAccount'+accountId);
         
         // POC - hard-coding the account id below for now
         ret =  ccrz.ccApiAccount.fetch(new Map<String,Object>{
             ccrz.ccApi.API_VERSION => inpData.get(ccrz.ccApi.API_VERSION)
            ,ccrz.ccApiAccount.ID => accountId
            ,ccrz.ccAPI.SIZING=>ccrz.ccUtil.defv(inpData, ccrz.ccAPI.SIZING, new Map<String, Object>())
        });
     }
     else
     {
         //ccrz.cclog.log(LoggingLevel.DEBUG,'Inside not null account');
         ret =  super.process(inpData);
     }
      ccrz.ccLog.log(LoggingLevel.DEBUG, 'EC:inputData_getcurrent', ret);
     
     return ret;
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