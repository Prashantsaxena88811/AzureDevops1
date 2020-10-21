/* Test Class Name : EC_ccLogicCartPriceTest
* Class Name       : EC_ccLogicCartPrice
* Description      : Below class is a test class to EC_ccLogicCartPrice
* Created By       : Bharath KN
* Created On       : 05/27/2020

* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------------------------------------------
* Bharath                 05/27/2020               Created the initial class.
*/
@isTest
public without sharing class  EC_ccLogicCartPriceTest {
    
    static testMethod void processMethod() {
        Map<String, Object> testData=new Map<String, Object>();
        EC_TestData.setupCatalog();
        EC_TestData.setupTestUser();
        Account shipTo = EC_TestData.testAccountShipTo;
        ccrz__E_ContactAddr__c unloadingPoint = new ccrz__E_ContactAddr__c();
        unloadingPoint.EC_Account_Number__c = shipTo.EC_Billing_Account_Number__c;
        insert unloadingPoint;
        ccrz.cc_CallContext.effAccountId = shipTo.id;
        ccrz__E_Cart__c cart = EC_TestData.createCart();
        cart.ccrz__EffectiveAccountID__c = shipTo.Id;
        cart.Default_Unloading_Point__c =unloadingPoint.Id;
        update cart;
        ccrz.cc_CallContext.currCartId = cart.ccrz__EncryptedId__c;
        CCRZ.cc_CallContext.currPageName =  'ccrz__Cart';
        string cartId = cart.ccrz__EncryptedId__c;
        shipTo.Id = cart.ccrz__EffectiveAccountID__c;
        update shipTo;
        ccrz__E_Product__c proditem = [SELECT id, ccrz__sku__c FROM ccrz__E_Product__c LIMIT 1  ]; 
        system.debug('proditem' + proditem);
        EC_CartDetailController.updateCartItemUOM(cartId);
        Test.startTest();
        EC_ccLogicCartPrice var=new EC_ccLogicCartPrice();
        Map<String,Object> resp = var.process(testData);
        System.assert(null != resp);
        Test.stopTest();        
    }
}