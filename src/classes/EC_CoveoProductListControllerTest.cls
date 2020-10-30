/*********************************************************************************
Class Name      : EC_CoveoProductListControllerTest
Description     : Test class for EC_CoveoProductListController
Created By      : COVEO
Created Date    : 09/30/2020
Modification Log:
---------------------------------------------------------------------------------- 
Developer                 Date                   Description
----------------------------------------------------------------------------------            
COVEO                     09/30/2020             Initial Version
Abhishek Kumar            10/14/2020             Add negative scenario test methods
*********************************************************************************/
@isTest
public class EC_CoveoProductListControllerTest {
    /*************************************************************************************************
    Method Name : setupData
    Description : method to create test data
    **************************************************************************************************/
    @TestSetup
    static void setupData(){
        
        EC_TestData.setupTestUser();
        EC_TestData.setupCommunityUser();
        //creates everything related to products including specs,  media, pricelist and accountpricegroups
        EC_TestData.setupCatalog();
        
        //create single cart
        EC_TestData.createCart();
    }
    
    /*************************************************************************************************
    Method Name : addToCartTest
    Description : method to test positive scenario for addToCart
    **************************************************************************************************/
    @isTest
    static void addToCartTest(){
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' LIMIT 1]; 
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
        ccrz__E_Product__c prod = [SELECT id, ccrz__SKU__c FROM ccrz__E_Product__c LIMIT 1];
        ccrz__E_Cart__c cart = [SELECT id FROM ccrz__E_Cart__c LIMIT 1];
        System.runAs(thisUser){
            test.startTest();
            ccrz.cc_RemoteActionResult res = EC_CoveoProductListController.addToCart(ctx,prod.ccrz__SKU__c,1,cart.id);
            test.stopTest();
            system.assertEquals(res.success, true);
            system.assertEquals(res.data, cart.id);
        }
    }

    /*************************************************************************************************
    Method Name : addToCartFailureTest
    Description : method to test negative scenario for addToCart
    **************************************************************************************************/
    @isTest
    static void addToCartFailureTest(){
        User thisUser = [SELECT Id FROM User WHERE LastName = 'Waye' LIMIT 1]; 
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
        ccrz__E_Product__c prod = [SELECT id, ccrz__SKU__c FROM ccrz__E_Product__c LIMIT 1];
        ccrz__E_Cart__c cart = [SELECT id FROM ccrz__E_Cart__c LIMIT 1];
        System.runAs(thisUser){
            test.startTest();
            ccrz.cc_RemoteActionResult res = EC_CoveoProductListController.addToCart(ctx,prod.ccrz__SKU__c,1,cart.id);
            test.stopTest();
            system.assertEquals(res.success, false);
        }
    }
    
    /*************************************************************************************************
    Method Name : fetchProductsTest
    Description : method to test positive scenario for fetchProducts method
    **************************************************************************************************/
    @isTest
    static void fetchProductsTest(){
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' LIMIT 1]; 
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
        List<String> pids = new List<String>();
        for(ccrz__E_Product__c prod : [select id from ccrz__E_Product__c limit 5]){
            pids.add(prod.id);
        }
        System.runAs(thisUser){
            test.startTest();
            ccrz.cc_RemoteActionResult res = EC_CoveoProductListController.fetchProducts(ctx,pids);
            test.stopTest();
            system.assertEquals(res.success, true);
        }
    }

    /*************************************************************************************************
    Method Name : fetchProductsFailureTest
    Description : method to test negative scenario for fetchProducts method
    **************************************************************************************************/
    @isTest
    static void fetchProductsFailureTest(){
        User thisUser = [SELECT Id FROM User WHERE LastName = 'Waye' LIMIT 1]; 
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
        List<String> pids = new List<String>();
        for(ccrz__E_Product__c prod : [select id from ccrz__E_Product__c limit 5]){
            pids.add(prod.id);
        }
        System.runAs(thisUser){
            test.startTest();
            ccrz.cc_RemoteActionResult res = EC_CoveoProductListController.fetchProducts(ctx,pids);
            test.stopTest();
            system.assertEquals(res.success, false);
        }
    }
    
    /*************************************************************************************************
    Method Name : fetchPriceForProductsTest
    Description : method to test positive scenario for fetchPriceForProducts method
    **************************************************************************************************/
    @isTest
    static void fetchPriceForProductsTest(){
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' LIMIT 1];    
        List<String> pids = new List<String>();
        for(ccrz__E_Product__c prod : [select id from ccrz__E_Product__c limit 5]){
            pids.add(prod.id);
        }
        System.runAs(thisUser){
            test.startTest();
            Map<String,Object> productDataResults = EC_CoveoProductListController.fetchPriceForProducts(pids);
            test.stopTest();
            system.assertNotEquals(productDataResults, null);
        }
    }
    
    /*************************************************************************************************
    Method Name : fetchPriceForProductsFailureTest
    Description : method to test negative scenario for fetchPriceForProducts method
    **************************************************************************************************/
    @isTest
    static void fetchPriceForProductsFailureTest(){
        User thisUser = [SELECT Id FROM User WHERE LastName = 'Waye' LIMIT 1];    
        List<String> pids = new List<String>();
        for(ccrz__E_Product__c prod : [select id from ccrz__E_Product__c limit 5]){
            pids.add(prod.id);
        }
        System.runAs(thisUser){
            test.startTest();
            Map<String,Object> productDataResults = EC_CoveoProductListController.fetchPriceForProducts(pids);
            test.stopTest();
            system.assertEquals(productDataResults, null);
        }
    }
    
    /*************************************************************************************************
    Method Name : getFiltersTest
    Description : method to test positive scenario for getFilters method
    **************************************************************************************************/
    @isTest
    static void getFiltersTest(){
        User thisUser = [SELECT Id, AccountId FROM User WHERE LastName = 'TestUser' LIMIT 1]; 
        String filterNoProduct = 'NOT @objecttype==(ccrz__E_Product__c,ccrz__E_PriceListItem__c)';
        System.runAs(thisUser){
            test.startTest();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
            ctx.effAccountId = thisUser.AccountId;
            ccrz.cc_CallContext.initRemoteContext(ctx);
            EC_CoveoProductListController controller = new EC_CoveoProductListController();
            String filter = controller.getFilters();
            test.stopTest();
            system.assertNotEquals(filter, filterNoProduct);
        }
    }
    
    /*************************************************************************************************
    Method Name : getFiltersFailureTest
    Description : method to test negative scenario for getFilters method
    **************************************************************************************************/
    @isTest
    static void getFiltersFailureTest(){
        User thisUser = [SELECT Id, AccountId FROM User WHERE LastName = 'TestUser' LIMIT 1]; 
        String filterNoProduct = 'NOT @objecttype==(ccrz__E_Product__c,ccrz__E_PriceListItem__c)';
        System.runAs(thisUser){
            EC_CoveoProductListController.throwTestException = true;
            test.startTest();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
            ctx.effAccountId = thisUser.AccountId;
            ccrz.cc_CallContext.initRemoteContext(ctx);
            EC_CoveoProductListController controller = new EC_CoveoProductListController();
            String filter = controller.getFilters();
            test.stopTest();
            system.assertEquals(filter, filterNoProduct);
        }
    }
    
    /*************************************************************************************************
    Method Name : getCommerceQueryListingTest
    Description : method to test positive scenario for getCommerceQueryListing method
    **************************************************************************************************/
    @isTest
    static void getCommerceQueryListingTest(){
        User thisUser = [SELECT Id, AccountId FROM User WHERE LastName = 'TestUser' LIMIT 1]; 
        System.runAs(thisUser){
            test.startTest();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
            ctx.effAccountId = thisUser.AccountId;
            ccrz.cc_CallContext.initRemoteContext(ctx);
            EC_CoveoProductListController controller = new EC_CoveoProductListController();
            String currentAccountName = controller.getCommerceQueryListing();
            test.stopTest();
            system.assert(string.isNotBlank(currentAccountName));
        }
    }
    
    
    /*************************************************************************************************
    Method Name : getCommerceQueryListingFaliureTest
    Description : method to test negative scenario for getCommerceQueryListing method
    **************************************************************************************************/
    @isTest
    static void getCommerceQueryListingFaliureTest(){
        User thisUser = [SELECT Id, AccountId FROM User WHERE LastName = 'TestUser' LIMIT 1]; 
        System.runAs(thisUser){
            EC_CoveoProductListController.throwTestException = true;
            test.startTest();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
            ctx.effAccountId = thisUser.AccountId;
            ccrz.cc_CallContext.initRemoteContext(ctx);
            EC_CoveoProductListController controller = new EC_CoveoProductListController();
            String currentAccountName = controller.getCommerceQueryListing();
            test.stopTest();
            //checking negative scenario
            system.assert(string.isBlank(currentAccountName));
        }
    }
}