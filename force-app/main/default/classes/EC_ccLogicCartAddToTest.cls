/* Class Name    : EC_ccLogicCartAddToTest
* Description      : Test Class to cover EC_ccLogicCartAddTo
* Created By       :Viraj  
* Created On       :2019-Nov-04
*/

/* Modification Log:
* -------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -------------------------------------------------------------------------------------------------------------------------------------
* Viraj                     2019-Nov-04     Tech-Debt         Created the class   
*/
@isTest
public class EC_ccLogicCartAddToTest{
    
    @testSetup static void setup(){
        
        list<Account> testAccountSoldTo = new list<Account>{
            new Account(
                Name                    = 'Test Sold To',
                OwnerId                 = UserInfo.getUserId(),
                BillingStreet           = EC_TestData.generateRandomString(32),
                BillingCity             = EC_TestData.generateRandomString(32),
                BillingState            = EC_TestData.generateRandomString(32),
                BillingCountry          = 'USA',
                BillingPostalCode       = EC_TestData.generateRandomString(5),
                EC_Account_Number__c    = EC_TestData.generateRandomString(5),
                EC_Billing_Account_Number__c = 'NLC_SAP/12345',
                RecordTypeId            = EC_TestData.getRecordType('soldTo')) //Sold To
                
                };
                    insert testAccountSoldTo;
        
        list<ccrz__E_Product__c> prodNew = new list<ccrz__E_Product__c>{
            new ccrz__E_Product__c(
                Name                       = 'MyProd Bag',
                ccrz__SKU__c               = 'test001MyProd%',
                ccrz__ProductId__c         = 'test001MyProd',
                ccrz__ProductStatus__c     = 'Released',
                ccrz__UnitOfMeasure__c     = 'BG',
                ccrz__StartDate__c         = Date.today().addDays(-7),
                ccrz__EndDate__c           = Date.today().addDays(7),
                ccrz__Storefront__c        = 'DefaultStore',
                ccrz__ProductWeight__c     = 500,
                ccrz__HazardousFlag__c     = true,
                ccrz__ShortDesc__c       ='product001 Bag',
                ccrz__LongDesc__c       ='product001 Bag',
                ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent)
                };
                    insert prodNew;        
    }
    
    @isTest 
    static void test1(){
        
        list<Account> testAccountSoldTo = [select Name,OwnerId,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,EC_Account_Number__c,EC_Billing_Account_Number__c,RecordTypeId from Account];
        list<ccrz__E_Product__c> prodNew = [Select Name,ccrz__SKU__c,ccrz__ProductId__c,ccrz__ProductStatus__c,ccrz__UnitOfMeasure__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Storefront__c,ccrz__ProductWeight__c,ccrz__HazardousFlag__c,ccrz__ShortDesc__c,ccrz__LongDesc__c,ccrz__ProductIndexStatus__c from ccrz__E_Product__c];
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            Test.startTest();
            
            
            ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = testAccountSoldTo[0].id;
            
            Account shipTo = [Select EC_SalesOrg__c from Account Where Id=:EC_TestData.testAccountShipTo.id];
            shipTo.EC_SalesOrg__c = '1001';
            update shipTo;
            ccrz.cc_CallContext.effAccountId = testAccountSoldTo[0].id;            
            ccrz.cc_CallContext.initRemoteContext(ctx);
            ccrz.cc_CallContext.currAccountId = testAccountSoldTo[0].id;
            
            List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1);
            
            List<Map<String,String>> prodList = new List<Map<String,String>>();
            Map<String,String> maps= new Map<String,String>();
            prodList.add(maps);
            
            ccrz__E_CartItem__c cartItem1 = new ccrz__E_CartItem__c();
            cartItem1.ccrz__Cart__c = cart[0].Id;
            cartItem1.ccrz__Product__c = prodNew[0].id;
            cartItem1.ccrz__Price__c = 100;
            insert cartItem1;            
            
            cart = [Select ccrz__BillTo__c, ccrz__ShipTo__c,ccrz__EncryptedId__c from ccrz__E_Cart__c Where Id=: cart[0].id Limit 1];
            cart[0].ccrz__BillTo__c = null;
            cart[0].ccrz__ShipTo__c = null;
            update cart;
            CCRZ.cc_CallContext.currCartId = cart[0].Id;
            
            thisUser.User_Type__c='Internal';
            thisUser.Phone='123456';
            thisUser.MobilePhone='98765432';
            update thisUser;
            EC_TestData.setupCatalog();
            ccrz__E_Cart__c cart1 = EC_TestData.createCart();
            ccrz__E_Product__c proditem = [SELECT id, ccrz__sku__c FROM ccrz__E_Product__c where  ccrz__sku__c  like '00000000000%' LIMIT 1  ];
            system.debug('proditem'+proditem);
            ccrz__E_ProductIndex__c prodIndex = new ccrz__E_ProductIndex__c();
            prodIndex.ccrz__sku__c = 'test001MyProd';
            insert prodIndex;
            ccrz__E_ProductIndex__c prodIndex2 = new ccrz__E_ProductIndex__c();
            prodIndex2.ccrz__sku__c = '12test001MyProd12/12';
            insert prodIndex2;
            List<Account> accList = new List<Account>();
            Account shipTo2 = EC_TestData.testAccountShipTo;
            ccrz.cc_CallContext.effAccountId = shipTo2.id;
            accList.add(shipTo2);
            
            List<ccrz.ccApiCart.LineData> lineDataList = new List<ccrz.ccApiCart.LineData>();
            System.debug([SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c]);
            List<ccrz__E_cartitem__c> cartitemlist = [SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c WHERE ccrz__cart__c = :cart[0].id];
            
            for(ccrz__E_cartitem__c cartitem : cartitemlist){
                ccrz.ccApiCart.LineData lineData = new ccrz.ccApiCart.LineData();
                lineData = new ccrz.ccApiCart.LineData();
                lineData.sku = cartitem.ccrz__Product__r.ccrz__sku__c.substring(11,cartitem.ccrz__Product__r.ccrz__sku__c.length());
                lineDataList.add(lineData);
            }
            
            Map<String, Object> inputData = new Map<String, Object>();
            
            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartAddTo classOb = new EC_ccLogicCartAddTo();
            
            // outData = classOb.processInputData(inputData);
            
            inputData = new Map<String, Object>{
                ccrz.ccAPICart.CART_ID => cart1.id,
                    ccrz.ccAPI.API_VERSION => 8,
                    ccrz.ccApiCart.LINE_DATA => lineDataList 
                    };
                        System.debug('test1inputData1' + inputData.get(ccrz.ccApiCart.LINE_DATA));
            outData = classOb.processInputData(inputData);
            inputData = new Map<String, Object>{
                ccrz.ccAPICart.CART_ID => cart1.id,
                    ccrz.ccAPI.API_VERSION => 8,
                    ccrz.ccApiCart.LINE_DATA => null 
                    };
                        System.debug('test1inputData12' + inputData.get(ccrz.ccApiCart.LINE_DATA));
            outData = classOb.processInputData(inputData);
            
            System.assertNotEquals(outData,null);
            
            Test.stopTest();
        }
    }

/***************************************************************************************************************************************
  Method Name : ISE_HappyPath
  Description : Test method to cover Non-ISE Products
  Return type : void
/************************************************************************************************************************************/    
    @isTest 
    static void ISE_HappyPath() {
        
        EC_ISETestDataFactory.setupInstSalesEntitlements();
        
        list<Account> testAccountISE = [select Name,OwnerId,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,EC_Account_Number__c,EC_Billing_Account_Number__c,RecordTypeId from Account where Name LIKE '%_HybridDirect%'];
        system.debug('testAccountISE: '+testAccountISE);
        list<ccrz__E_Product__c> prodNew = [Select Name,ccrz__SKU__c,ccrz__ProductId__c,ccrz__ProductStatus__c,ccrz__UnitOfMeasure__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Storefront__c,ccrz__ProductWeight__c,ccrz__HazardousFlag__c,ccrz__ShortDesc__c,ccrz__LongDesc__c,ccrz__ProductIndexStatus__c from ccrz__E_Product__c];
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser) {
            Test.startTest();
            
            ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = testAccountISE[0].id;
            
            ccrz.cc_CallContext.effAccountId = testAccountISE[0].id;            
            ccrz.cc_CallContext.initRemoteContext(ctx);
            ccrz.cc_CallContext.currAccountId = testAccountISE[0].id;
            
            List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1);
            
            ccrz__E_CartItem__c cartItem1 = new ccrz__E_CartItem__c();
            cartItem1.ccrz__Cart__c = cart[0].Id;
            cartItem1.ccrz__Product__c = prodNew[0].id;
            cartItem1.ccrz__Price__c = 100;
            insert cartItem1;           
            CCRZ.cc_CallContext.currCartId = cart[0].Id;
            
            EC_TestData.setupCatalog();
            ccrz__E_Product__c proditem = [SELECT id, ccrz__sku__c FROM ccrz__E_Product__c where  ccrz__sku__c  like '00000000000%' LIMIT 1  ];
            system.debug('proditem'+proditem);
            ccrz__E_ProductIndex__c prodIndex = new ccrz__E_ProductIndex__c();
            prodIndex.ccrz__sku__c = 'test001MyProd';
            insert prodIndex;
            
            List<ccrz.ccApiCart.LineData> lineDataList = new List<ccrz.ccApiCart.LineData>();
            System.debug([SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c]);
            List<ccrz__E_cartitem__c> cartitemlist = [SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c WHERE ccrz__cart__c = :cart[0].id];
            
            for(ccrz__E_cartitem__c cartitem : cartitemlist){
                ccrz.ccApiCart.LineData lineData = new ccrz.ccApiCart.LineData();
                lineData = new ccrz.ccApiCart.LineData();
                lineData.sku = cartitem.ccrz__Product__r.ccrz__sku__c;
                lineDataList.add(lineData);
            }
            
            Map<String, Object> inputData = new Map<String, Object>();
            
            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartAddTo classOb = new EC_ccLogicCartAddTo();
            
            // outData = classOb.processInputData(inputData);
            
            inputData = new Map<String, Object>{
                ccrz.ccAPICart.CART_ID => cart[0].Id,
                    ccrz.ccAPI.API_VERSION => 8,
                    ccrz.ccApiCart.LINE_DATA => lineDataList 
                    };
                        
                        System.debug('ISE_HappyPathinputData1' + inputData.get(ccrz.ccApiCart.LINE_DATA));
            outData = classOb.processInputData(inputData);            
            System.assertNotEquals(outData,null);
            
            outData = classOb.process(inputData);
            System.assertNotEquals(outData,null);
            Test.stopTest();
        }
    }
    
/***************************************************************************************************************************************
  Method Name : ISE_IndirectCore
  Description : Test method to cover ISE Indirect Core Scenario
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
            
            ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = testAccountISE[0].id;
            
            ccrz.cc_CallContext.effAccountId = testAccountISE[0].id;            
            ccrz.cc_CallContext.initRemoteContext(ctx);
            ccrz.cc_CallContext.currAccountId = testAccountISE[0].id;
            
            List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1);
            
            ccrz__E_CartItem__c cartItem1 = new ccrz__E_CartItem__c();
            cartItem1.ccrz__Cart__c = cart[0].Id;
            cartItem1.ccrz__Product__c = prodNew[0].id;
            cartItem1.ccrz__Price__c = 100;
            insert cartItem1;           
            CCRZ.cc_CallContext.currCartId = cart[0].Id;
            
            EC_TestData.setupCatalog();
            ccrz__E_ProductIndex__c prodIndex = new ccrz__E_ProductIndex__c();
            prodIndex.ccrz__sku__c = 'test001MyProd';
            insert prodIndex;
            
            List<ccrz.ccApiCart.LineData> lineDataList = new List<ccrz.ccApiCart.LineData>();
            System.debug([SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c]);
            List<ccrz__E_cartitem__c> cartitemlist = [SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c WHERE ccrz__cart__c = :cart[0].id];
            
            for(ccrz__E_cartitem__c cartitem : cartitemlist){
                ccrz.ccApiCart.LineData lineData = new ccrz.ccApiCart.LineData();
                lineData = new ccrz.ccApiCart.LineData();
                lineData.sku = cartitem.ccrz__Product__r.ccrz__sku__c;
                //lineData.sku = 'test001';
                lineDataList.add(lineData);
            }
            
            Map<String, Object> inputData = new Map<String, Object>();
            
            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartAddTo classOb = new EC_ccLogicCartAddTo();
            
            // outData = classOb.processInputData(inputData);
            
            inputData = new Map<String, Object>{
                ccrz.ccAPICart.CART_ID => cart[0].Id,
                    ccrz.ccAPI.API_VERSION => 8,
                    ccrz.ccApiCart.LINE_DATA => lineDataList 
                    };
                        
                        System.debug('ISE_IndirectCoreinputData1' + inputData.get(ccrz.ccApiCart.LINE_DATA));
            outData = classOb.processInputData(inputData);            
            System.assertNotEquals(outData,null);
            
            outData = classOb.process(inputData);
            System.assertNotEquals(outData,null);
            Test.stopTest();
        }
    } 
    
/***************************************************************************************************************************************
  Method Name : ISE_HybridDirect
  Description : Test method to cover ISE Hybrid Direct Scenario
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
            
            ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = testAccountISE[0].id;
            
            ccrz.cc_CallContext.effAccountId = testAccountISE[0].id;            
            ccrz.cc_CallContext.initRemoteContext(ctx);
            ccrz.cc_CallContext.currAccountId = testAccountISE[0].id;
            
            List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1);
            
            ccrz__E_CartItem__c cartItem1 = new ccrz__E_CartItem__c();
            cartItem1.ccrz__Cart__c = cart[0].Id;
            cartItem1.ccrz__Product__c = prodNew[0].id;
            cartItem1.ccrz__Price__c = 100;
            insert cartItem1;           
            CCRZ.cc_CallContext.currCartId = cart[0].Id;
            
            EC_TestData.setupCatalog();
            ccrz__E_ProductIndex__c prodIndex = new ccrz__E_ProductIndex__c();
            prodIndex.ccrz__sku__c = 'test001MyProd';
            insert prodIndex;
            
            List<ccrz.ccApiCart.LineData> lineDataList = new List<ccrz.ccApiCart.LineData>();
            System.debug([SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c]);
            List<ccrz__E_cartitem__c> cartitemlist = [SELECT id,ccrz__Product__r.ccrz__sku__c FROM ccrz__E_cartitem__c WHERE ccrz__cart__c = :cart[0].id];
            
            for(ccrz__E_cartitem__c cartitem : cartitemlist){
                ccrz.ccApiCart.LineData lineData = new ccrz.ccApiCart.LineData();
                lineData = new ccrz.ccApiCart.LineData();
                //lineData.sku = cartitem.ccrz__Product__r.ccrz__sku__c;
                lineData.sku = 'test001';
                lineDataList.add(lineData);
            }
            
            Map<String, Object> inputData = new Map<String, Object>();
            
            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartAddTo classOb = new EC_ccLogicCartAddTo();
            
            // outData = classOb.processInputData(inputData);
            
            inputData = new Map<String, Object>{
                ccrz.ccAPICart.CART_ID => cart[0].Id,
                    ccrz.ccAPI.API_VERSION => 8,
                    ccrz.ccApiCart.LINE_DATA => lineDataList 
                    };
                        
                        System.debug('ISE_HybridDirectinputData1' + inputData.get(ccrz.ccApiCart.LINE_DATA));
            outData = classOb.processInputData(inputData);            
            System.assertNotEquals(outData,null);
            
            outData = classOb.process(inputData);
            System.assertNotEquals(outData,null);
            Test.stopTest();
        }
    }
}