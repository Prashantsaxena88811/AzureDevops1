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
        return returnCartItems(retData);
    }
    
    public static void checkUnlodingPoint(String currCart){
        if (ccrz__E_Cart__c.sObjectType.getDescribe().isAccessible()) {
            List<ccrz__E_Cart__c> cart = [Select Id, Default_Unloading_Point__c,ccrz__EffectiveAccountID__c  from ccrz__E_Cart__c Where id=:currCart OR ccrz__EncryptedId__c =:currCart ];
            if(!cart.isEmpty() && cart[0].Default_Unloading_Point__c != null ){
                String billingAccountNumber = [Select EC_Billing_Account_Number__c from Account Where Id=:cart[0].ccrz__EffectiveAccountID__c].EC_Billing_Account_Number__c;
                Id selectedUnloadingPoint = cart[0].Default_Unloading_Point__c;
                List<ccrz__E_ContactAddr__c> unloadingPointForSelectedAccount = [SELECT Id, EC_Account_Number__c FROM ccrz__E_ContactAddr__c Where id=:selectedUnloadingPoint and Active__c=true and EC_Account_Number__c =: billingAccountNumber];
                if(unloadingPointForSelectedAccount.isEmpty() && ccrz__E_Cart__c.sObjectType.getDescribe().isAccessible()){
                    cart[0].Default_Unloading_Point__c = null;
                    update cart;
                }
            }
        }
    }

    private static Map<String,Object> returnCartItems(Map<String,Object> returnData)
    {
        //BA Logic - Show Entitled price if BA expired.
        String cartId = String.valueof(returnData.get('cartId'));
        Date today = Date.today();
       	List<ccrz__E_CartItem__c> cartItems = new List<ccrz__E_CartItem__c>();
        if(!ccrz__E_CartItem__c.sObjectType.getDescribe().isAccessible()) {
            return new Map<String, Object>();
        }
        cartItems = [SELECT Id,ccrz__Product__c,ccrz__Quantity__c,ccrz__Price__c,Billing_Arrangement__c,Billing_Arrangement__r.ccrz__EndDate__c,Billing_Arrangement__r.ccrz__Enabled__c,ccrz__Product__r.ccrz__sku__c,ccrz__Cart__c,ccrz__Cart__r.Id,ccrz__Cart__r.ccrz__SubtotalAmount__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.Id=:cartId];

            for(ccrz__E_CartItem__c cartItem: cartItems) {
                if(cartItem.Billing_Arrangement__r.ccrz__Enabled__c == false || cartItem.Billing_Arrangement__r.ccrz__EndDate__c < today){
                    cartItem.ccrz__PricingType__c='auto';
                    cartItem.ccrz__SubAmount__c=cartItem.ccrz__Quantity__c*cartItem.ccrz__Price__c;
                }
            }
            update cartItems;
        ccrz.ccLog.log('ccLogicCartValidate retData---' + cartItems);
        
        ccrz.cclog.log('ccLogicCartPriceAK applyPricing retData--->' + returnData);
        //BA Logic Ends.
        return returnData;   
    }
}