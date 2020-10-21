/* Class Name       : EC_EffectiveAccountController
 * Description      : Controller class for the EC_EffectiveSelPicker VF component.
 * Created By       : Vishal  
 * Created On       : 8/7/2019

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Vishal                     2019-Jun-12    WI-75941                Created the class   
 *
 */

global class EC_EffectiveAccountController{

    public string profileName{get;set;}
    /***************************************************************************************************************************************
    Constructor Name : updateContactLocale
    Description : Sets the profile of the user to profileName field
    *************************************************************************************************************************************/
    public EC_EffectiveAccountController(){
        User user = [SELECT id, Profile.Name FROM User where id = :ccrz.cc_CallContext.currUser.id];
        profileName = user.Profile.Name;
        
    }
    
   /***************************************************************************************************************************************
      Method Name : updateContactLocale
      Description : Remote call to change the currency and locale of the user to enable multicurrency
      Return type : Returns ccrz.cc_RemoteActionResult
     *************************************************************************************************************************************/
    @RemoteAction
     global static ccrz.cc_RemoteActionResult updateContactLocale(final ccrz.cc_RemoteActionContext ctx, String locale, String effAccId,String cartId) { 
        boolean isToUpdate = false;
        string canadaCustomLabelDataStr = System.Label.EC_CanadaLocale;
        List<string> canadaCustomLabelDataList = canadaCustomLabelDataStr.split(',');
        string unitedStatesCustomLabelDataStr = System.Label.EC_UnitedStates;
        List<string> unitedStatesCustomLabelDataList = unitedStatesCustomLabelDataStr .split(',');
        ccrz.cc_RemoteActionResult rac = new ccrz.cc_RemoteActionResult();
        User user= [SELECT id, LocaleSidKey, ccrz__CC_CurrencyCode__c from User where id =: ccrz.cc_callContext.currUserId];
        List<ccrz__E_Cart__c> cartOb = [SELECT id,ccrz__EncryptedId__c,ccrz__EffectiveAccountID__c from ccrz__E_Cart__c where ccrz__EncryptedId__c =:cartId or id=:cartId];
        if (unitedStatesCustomLabelDataList.contains(locale) && user.LocaleSidKey != 'en_US'){
            user.LocaleSidKey = 'en_US';
            user.ccrz__CC_CurrencyCode__c = 'USD';
            cartOb[0].ccrz__CurrencyISOCode__c = 'USD';
            isToUpdate = true;
        } else if (canadaCustomLabelDataList.contains(locale) && user.LocaleSidKey != 'en_CA'){
             user.LocaleSidKey = 'en_CA';
             user.ccrz__CC_CurrencyCode__c = 'CAD';
             cartOb[0].ccrz__CurrencyISOCode__c = 'CAD';
             isToUpdate = true;
        }
        if (isToUpdate){
            cartOb[0].ccrz__EffectiveAccountID__c = effAccId;
            update cartOb;
            update user;
        }
        rac.success = true;
        return rac;
    }
}