/* Class Name      : EC_ccLogicCartPrice
* Description      : Logic Cart Price Related inherited cloud craze interface
* Created By       : Bharath KN 
* Created On       : 05-29-2020

* Modification Log:
* ------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------------------------------------------
* Bharath KN               05-29-2020                              Initial version (log modification)
*
*
*/

global virtual with sharing class EC_ccLogicCartPrice extends ccrz.ccLogicCartPrice {
    global virtual override Map<String,Object> Process(Map<String,Object> inputData) {
        // Save UOM fields in cartItem for NALCO
        String effAccountId = ccrz.cc_CallContext.effAccountId;
        String division='';
        if (Account.sObjectType.getDescribe().isAccessible()) {
            List<Account> effAccountList = [Select Id,EC_SalesOrg__c,EC_Division__c FROM Account WHERE Id=:effAccountId LIMIT 1];
            if(!effAccountList.isEmpty()){
                division = effAccountList[0].EC_Division__c;
            }
        }
        if(System.label.EC_DivisionValueNACLO.containsIgnoreCase(division) && ccrz.cc_CallContext.currPageName =='ccrz__Cart') {
            String currCart = ccrz.cc_CallContext.currCartId;
            if (ccrz__E_Cart__c.sObjectType.getDescribe().isAccessible() && ccrz__E_ContactAddr__c.sObjectType.getDescribe().isAccessible()) {
                checkUnlodingPoint(currCart);
            }
            EC_CartDetailController.updateCartItemUOM(currCart);
        }
        Map<String,Object> retData = super.process(inputData);
        ccrz.cclog.log('ccLogicCartPriceAK applyPricing retData--->' + retData);
        return retData;
    }
    
    public static void checkUnlodingPoint(String currCart){
        List<ccrz__E_Cart__c> cart = [Select Id, Default_Unloading_Point__c,ccrz__EffectiveAccountID__c  from ccrz__E_Cart__c Where id=:currCart OR ccrz__EncryptedId__c =:currCart ];
        if(!cart.isEmpty() && cart[0].Default_Unloading_Point__c != null ){
            String billingAccountNumber = [Select EC_Billing_Account_Number__c from Account Where Id=:cart[0].ccrz__EffectiveAccountID__c].EC_Billing_Account_Number__c;
            Id selectedUnloadingPoint = cart[0].Default_Unloading_Point__c;
            List<ccrz__E_ContactAddr__c> unloadingPointForSelectedAccount = [SELECT Id, EC_Account_Number__c FROM ccrz__E_ContactAddr__c Where id=:selectedUnloadingPoint and Active__c=true and EC_Account_Number__c =: billingAccountNumber];
            cart[0].Default_Unloading_Point__c = null;
            if(ccrz__E_Cart__c.sObjectType.getDescribe().isAccessible() && unloadingPointForSelectedAccount.isEmpty()){
                update cart;
            }
        }
    }
}
