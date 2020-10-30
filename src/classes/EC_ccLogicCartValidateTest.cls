/* Class Name    : EC_ccLogicCartValidateTest 
 * Description      Test Class to cover EC_ccLogicCartValidate
 * Created By       :Priyanka Priya
 * Created On       :2019-Aug-19
 */

 /* Modification Log:
 * -------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -------------------------------------------------------------------------------------------------------------------------------------
 * Priyanka Priya     2019-Aug-19       BC-76559            Created the class   
 */
@isTest
public class EC_ccLogicCartValidateTest {
/***************************************************************************************************************************************
  Method Name : processPositiveTest
  Description : Test method to cover process method
  Return type : void
/************************************************************************************************************************************/
    @isTest 
    static void processPositiveTest(){
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        
        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            EC_TestData.setupTestUser();
            ccrz__E_Cart__c cart = EC_TestData.createCart();
            
            ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
            Contact con =[SELECT id from Contact limit 1];
            rac.priceGroupId = con.id;
            
            AccountContactRelation accCon = new AccountContactRelation();
            accCon.AccountId = EC_TestData.testAccountSoldTo.id;
            accCon.ContactId = con.id;
            Insert accCon;
            
            Account shipTo = EC_TestData.testAccountShipTo;
            shipTo.EC_Division__c = 'WATER';
            update shipTo;

            rac.userLocale = EC_TestData.testAccount.id;
            rac.effAccountId = shipTo.id;
            rac.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(rac);
            
            
            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccAPICart.CART_ID => cart.id,
                    ccrz.ccAPI.API_VERSION => 8
                };
            

            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartValidate classOb = new EC_ccLogicCartValidate();
            Test.startTest();
            thisUser.User_Type__c='Internal';
            thisUser.Phone='123456';
            thisUser.MobilePhone='98765432';
            update thisUser;
            outData = classOb.process(inputData);
            System.assertNotEquals(outData,null);
                        
            Test.stopTest();
        }
    }
    /***********************************************************************************************************************************
  Method Name : processNegativeTest
  Description : Test method to cover process method
  Return type : void
 *************************************************************************************************************************************/
    @isTest 
    static void processNegativeTest(){
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        
        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            EC_TestData.setupTestUser();
            ccrz__E_Cart__c cart = EC_TestData.createCart();
            cart = [Select ccrz__BillTo__c, ccrz__ShipTo__c from ccrz__E_Cart__c Where Id=: cart.id Limit 1];
            cart.ccrz__BillTo__c = null;
            cart.ccrz__ShipTo__c = null;
            update cart;

            ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
            Contact con =[SELECT id from Contact limit 1];
            rac.priceGroupId = con.id;
            
            AccountContactRelation accCon = new AccountContactRelation();
            accCon.AccountId = EC_TestData.testAccountSoldTo.id;
            accCon.ContactId = con.id;
            Insert accCon;
            
            Account shipTo = EC_TestData.testAccountShipTo;
            shipTo.EC_Division__c = 'WATER';
            update shipTo;

            rac.userLocale = EC_TestData.testAccount.id;
            rac.effAccountId = shipTo.id;
            rac.currentCartId = cart.id;
            ccrz.cc_CallContext.initRemoteContext(rac);
            
            
            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccAPICart.CART_ID => cart.id,
                    ccrz.ccAPI.API_VERSION => 8
                };
            

            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartValidate classOb = new EC_ccLogicCartValidate();
            Test.startTest();
            outData = classOb.process(inputData);
            
            System.assertNotEquals(outData,null);
            Test.stopTest();
        }
    }
    
/***************************************************************************************************************************************
  Method Name : ISE_HybridDirect
  Description : Test method to cover Hybrid Direct for Sales Entitlement
  Return type : void
/************************************************************************************************************************************/
    @isTest 
    static void ISE_HybridDirect() {
        EC_ISETestDataFactory.setupInstSalesEntitlements();
        list<Account> testAccountISE = [select Name,OwnerId,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,EC_Account_Number__c,EC_Billing_Account_Number__c,RecordTypeId from Account where Name LIKE '%_HybridDirect%'];
        list<ccrz__E_Product__c> prodNew = new list<ccrz__E_Product__c>{
            new ccrz__E_Product__c(
                        Name                       = '3D TRASAR Boiler BD, HPSCS, Frame, BD',
                        ccrz__SKU__c               = '0000000000060-BLC6131B.88',
                        ccrz__ProductId__c         = '5285',
                        ccrz__ProductStatus__c     = 'Released',
                        ccrz__UnitOfMeasure__c     = 'Each',
                        ccrz__StartDate__c         = Date.today().addDays(-7),
                        ccrz__EndDate__c           = Date.today().addDays(7),
                        ccrz__Storefront__c        = 'DefaultStore',
                		Taxonomy__c				= 'Chemical',
                    ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent)
                };
        insert prodNew;
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser) {
            Test.startTest();
            
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = testAccountISE[0].id;
            
            ccrz.cc_CallContext.effAccountId = testAccountISE[0].id;            
            ccrz.cc_CallContext.initRemoteContext(ctx);
            ccrz.cc_CallContext.currAccountId = testAccountISE[0].id;
            List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1);
            cart[0].EC_Ship_To_Account__c = testAccountISE[0].id;
            update cart[0];
            
            ccrz__E_CartItem__c cartItem1 = new ccrz__E_CartItem__c();
            cartItem1.ccrz__Cart__c = cart[0].Id;
            cartItem1.ccrz__Product__c = prodNew[0].id;
            cartItem1.ccrz__Price__c = 100;
            insert cartItem1;  
            
            EC_TestData.setupCatalog();
            List<ccrz.ccApiCart.LineData> lineDataList = new List<ccrz.ccApiCart.LineData>();
            
            List<ccrz__E_cartitem__c> cartitemlist = [SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c WHERE ccrz__cart__c = :cart[0].id];
            
            for(ccrz__E_cartitem__c cartitem : cartitemlist){
                ccrz.ccApiCart.LineData lineData = new ccrz.ccApiCart.LineData();
                lineData = new ccrz.ccApiCart.LineData();
                lineData.sku = cartitem.ccrz__Product__r.ccrz__sku__c;
                lineDataList.add(lineData);
            }
            
            Map<String, Object> inputData = new Map<String, Object>();
            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartValidate classOb = new EC_ccLogicCartValidate();
            inputData = new Map<String, Object>{
                ccrz.ccAPICart.CART_ID => cart[0].Id,
                    ccrz.ccAPI.API_VERSION => 8
                    };
                        
            outData = classOb.processValidate(inputData);
            System.assertNotEquals(outData,null);
            
            Test.stopTest();
        }
    }
    
/***************************************************************************************************************************************
  Method Name : ISE_IndirectCore
  Description : Test method to cover Hybrid Direct for Sales Entitlement
  Return type : void
/************************************************************************************************************************************/
    @isTest 
    static void ISE_IndirectCore() {
        EC_ISETestDataFactory.setupInstSalesEntitlements();
        list<Account> testAccountISE = [select Name,OwnerId,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,EC_Account_Number__c,EC_Billing_Account_Number__c,RecordTypeId from Account where Name LIKE '%_InDirectCore%'];
        list<ccrz__E_Product__c> prodNew = new list<ccrz__E_Product__c>{
            new ccrz__E_Product__c(
                        Name                       = '3D TRASAR Boiler BD, HPSCS, Frame, BD',
                        ccrz__SKU__c               = '0000000000060-BLC6131B.88',
                        ccrz__ProductId__c         = '5285',
                        ccrz__ProductStatus__c     = 'Released',
                        ccrz__UnitOfMeasure__c     = 'Each',
                        ccrz__StartDate__c         = Date.today().addDays(-7),
                        ccrz__EndDate__c           = Date.today().addDays(7),
                        ccrz__Storefront__c        = 'DefaultStore',
                		Taxonomy__c				= 'Chemical',
                    ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent)
                };
        insert prodNew;
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser) {
            Test.startTest();
            
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = testAccountISE[0].id;
            
            ccrz.cc_CallContext.effAccountId = testAccountISE[0].id;            
            ccrz.cc_CallContext.initRemoteContext(ctx);
            ccrz.cc_CallContext.currAccountId = testAccountISE[0].id;
            List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1);
            cart[0].EC_Ship_To_Account__c = testAccountISE[0].id;
            update cart[0];
            
            ccrz__E_CartItem__c cartItem1 = new ccrz__E_CartItem__c();
            cartItem1.ccrz__Cart__c = cart[0].Id;
            cartItem1.ccrz__Product__c = prodNew[0].id;
            cartItem1.ccrz__Price__c = 100;
            insert cartItem1;  
            
            EC_TestData.setupCatalog();
            List<ccrz.ccApiCart.LineData> lineDataList = new List<ccrz.ccApiCart.LineData>();
            
            List<ccrz__E_cartitem__c> cartitemlist = [SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c WHERE ccrz__cart__c = :cart[0].id];
            
            for(ccrz__E_cartitem__c cartitem : cartitemlist){
                ccrz.ccApiCart.LineData lineData = new ccrz.ccApiCart.LineData();
                lineData = new ccrz.ccApiCart.LineData();
                lineData.sku = cartitem.ccrz__Product__r.ccrz__sku__c;
                lineDataList.add(lineData);
            }
            
            Map<String, Object> inputData = new Map<String, Object>();
            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartValidate classOb = new EC_ccLogicCartValidate();
            inputData = new Map<String, Object>{
                ccrz.ccAPICart.CART_ID => cart[0].Id,
                    ccrz.ccAPI.API_VERSION => 8
                    };
                        
            outData = classOb.processValidate(inputData);
            System.assertNotEquals(outData,null);
            
            Test.stopTest();
        }
    }
}