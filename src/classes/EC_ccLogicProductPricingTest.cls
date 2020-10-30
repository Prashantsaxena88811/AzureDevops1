/* Test Class Name  : EC_ccLogicProductPricingTest
* Class Name       : EC_ccLogicProductPricing
* Description      : Below class is a test class to EC_ccLogicProductPricing, whcih is used to for accessing custom fields for price list items in ccLogicProductPricing and accessing it in the model from the front-end
* Created By       : Bharath KN
* Created On       : 05/27/2020

* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------------------------------------------
* Bharath                 05/27/2020               Created the initial class.
*/
@isTest
private without sharing class EC_ccLogicProductPricingTest {

    @testSetup static void setup(){
         List<ccrz__E_Product__c> product = new List<ccrz__E_Product__c> {
            new ccrz__E_Product__c(
                Name                       = 'test',
                ccrz__SKU__c               = 'test001',
                ccrz__ProductId__c         = 'test001',
                ccrz__ProductStatus__c     = 'Released',
                ccrz__UnitOfMeasure__c     = 'BG',
                ccrz__StartDate__c         = Date.today().addDays(-7),
                ccrz__EndDate__c           = Date.today().addDays(7),
                ccrz__Storefront__c        = 'DefaultStore',
                ccrz__ProductWeight__c     = 500,
                ccrz__HazardousFlag__c     = true,
                ccrz__ShortDesc__c         ='product001 Bag',
                ccrz__LongDesc__c          ='product001 Bag')
                };
                    insert product;
        List<ccrz__E_PriceList__c> priceLists = new List<ccrz__E_PriceList__c> 
        {
            new ccrz__E_PriceList__c(
                Name                     = 'Enterprise',
                ccrz__CurrencyISOCode__c = 'USD',
                ccrz__Enabled__c         = true,
                ccrz__Storefront__c      = 'DefaultStore',
                ccrz__StartDate__c       = Date.today().addDays(-7),
                ccrz__EndDate__c         = Date.today().addDays(7),
                ccrz__PricelistId__c         = '250287'
            ),
                new ccrz__E_PriceList__c(
                    Name                     = 'Contract',
                    ccrz__CurrencyISOCode__c = 'USD',
                    ccrz__Enabled__c         = true,
                    ccrz__Storefront__c      = 'DefaultStore',
                    ccrz__StartDate__c       = Date.today().addDays(-7),
                    ccrz__EndDate__c         = Date.today().addDays(7),
                    ccrz__PricelistId__c         = '070289'
                )
                };
                    insert priceLists;
     }
    static testMethod void processMethod() {
        List<ccrz__E_Product__c> product = [Select    Name,ccrz__SKU__c ,ccrz__ProductId__c,ccrz__ProductStatus__c,ccrz__UnitOfMeasure__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Storefront__c,ccrz__ProductWeight__c,ccrz__HazardousFlag__c,ccrz__ShortDesc__c,ccrz__LongDesc__c from ccrz__E_Product__c];        
        List<ccrz__E_PriceList__c> priceLists = [Select Name,ccrz__CurrencyISOCode__c,ccrz__Enabled__c,ccrz__Storefront__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__PricelistId__c from ccrz__E_PriceList__c];
        
        Account shipTo = EC_TestData.testAccountShipTo;
        ccrz.cc_CallContext.effAccountId = shipTo.id;
        Map<String,Object> productList = new Map<String, Object>();
        Map<String,Object> pricingResult = new Map<String, Object>();
        ccrz__E_PriceListItem__c objPriceListItem = new ccrz__E_PriceListItem__c();
        objPriceListItem .ccrz__Product__c = product[0].id;
        objPriceListItem .ccrz__Pricelist__c = priceLists[0].id;
        objPriceListItem.ccrz__StartDate__c = Date.today().addDays(-7);
        objPriceListItem.ccrz__EndDate__c = Date.today().addDays(7);
        insert objPriceListItem;
        ccrz__E_PriceListItem__c objPriceListItem1 = new ccrz__E_PriceListItem__c();
        objPriceListItem1 .ccrz__Product__c = product[0].id;
        objPriceListItem1 .ccrz__Pricelist__c = priceLists[1].id;
        objPriceListItem1.ccrz__StartDate__c = Date.today().addDays(-7);
        objPriceListItem1.ccrz__EndDate__c = Date.today().addDays(7);
        objPriceListItem1.ccrz__Price__c = 5;          
        objPriceListItem1.ccrz__PricelistItemId__c = '1235';
        insert objPriceListItem1;
        
        Map<String, Object> insidePricing = new Map<String, Object>();
        Map<String, Object> listObject = new Map<string, Object>();
        
        List<Map<String,Object>> productDataMapList = new List<Map<String,Object>>();
        for(ccrz__E_Product__c prd:product)
        {
            Map<String,Object> prodData = new Map<String,Object>();
            prodData.put('sfid',prd.Id);
            productDataMapList.add(prodData);
        }
        listObject.put('listItemID', objPriceListItem.Id);
        
        Map<String,Object> spfIDValue = new Map<String,Object>();
        spfIDValue.put('sfid',objPriceListItem.id);
        List<Map<String, Object>> listMap = new List<Map<String, Object>>();
        listMap.add(listObject);
        insidePricing.put(ccrz.cc_hk_Pricing.PRICE_MAP_ENTRIES, listMap);
        insidePricing.put('productPrice', spfIDValue);
        pricingResult.put(product[0].id, insidePricing);    
        
        Map<String, Object> testData=new Map<String, Object>();
        List<Map<String, Object>> productMapList = new List<Map<String, Object>>();
        productMapList.add(productList);
        testData.put('productList',productDataMapList);
        testData.put('productPricingData',pricingResult);
        
        testData.put('sfid',objPriceListItem1.Id);
        Map<string,Object> retData=new Map<string,Object>();
        Map<string,Object> retDataValue=new Map<string,Object>();
        retDataValue.put(''+product[0].id, product[0]);
        
        retData.put('sfid',objPriceListItem1.Id);
        retData.put('CustomFactor', 10);
        retData.put('CustomPricingUOM', 'KG');
        retData.put('CustomUnitPrice', 30.00);       
        
        retData.put('productPricingData',retDataValue);
        retData.put('PricePer',600);
        
        
        List<Map<string,Object>> lstPriceList = new List<Map<string,Object>>();
        lstPriceList.add(retData);
        System.debug('retData - > '+retData);   
        List<Map<string,Object>> lstProdList = new List<Map<string,Object>>();
        lstProdList.add(retData);
        testData.put('priceListItems',lstPriceList);
        
        Test.startTest();
        EC_ccLogicProductPricing var=new EC_ccLogicProductPricing();
        var.process(testData);
        system.assertNotEquals(var.process(testData), null);
        var.determinePrice(testData);
        system.assertNotEquals(var.determinePrice(testData), null);
        Test.stopTest();
    }
    static testMethod void processMethod2() {
        List<ccrz__E_Product__c> product = [Select    Name,ccrz__SKU__c ,ccrz__ProductId__c,ccrz__ProductStatus__c,ccrz__UnitOfMeasure__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Storefront__c,ccrz__ProductWeight__c,ccrz__HazardousFlag__c,ccrz__ShortDesc__c,ccrz__LongDesc__c from ccrz__E_Product__c];        
        List<ccrz__E_PriceList__c> priceLists = [Select Name,ccrz__CurrencyISOCode__c,ccrz__Enabled__c,ccrz__Storefront__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__PricelistId__c from ccrz__E_PriceList__c];
        
        Account shipTo2 = EC_TestData.testAccountShipTo;
        shipTo2.EC_Division__c = 'INSTITUTIONAL';
        update shipTo2;
        ccrz.cc_CallContext.effAccountId = shipTo2.id;        
        Map<String,Object> productList = new Map<String, Object>();
        Map<String,Object> pricingResult = new Map<String, Object>();
        ccrz__E_PriceListItem__c objPriceListItem = new ccrz__E_PriceListItem__c();
        objPriceListItem .ccrz__Product__c = product[0].id;
        objPriceListItem .ccrz__Pricelist__c = priceLists[0].id;
        objPriceListItem.ccrz__StartDate__c = Date.today().addDays(-7);
        objPriceListItem.ccrz__EndDate__c = Date.today().addDays(7);
        insert objPriceListItem;
        ccrz__E_PriceListItem__c objPriceListItem1 = new ccrz__E_PriceListItem__c();
        objPriceListItem1 .ccrz__Product__c = product[0].id;
        objPriceListItem1 .ccrz__Pricelist__c = priceLists[1].id;
        objPriceListItem1.ccrz__StartDate__c = Date.today().addDays(-7);
        objPriceListItem1.ccrz__EndDate__c = Date.today().addDays(7);
        objPriceListItem1.ccrz__Price__c = 5;          
        objPriceListItem1.ccrz__PricelistItemId__c = '1235';
        insert objPriceListItem1;
        
        Map<String, Object> insidePricing = new Map<String, Object>();
        Map<String, Object> listObject = new Map<string, Object>();
        
        List<Map<String,Object>> productDataMapList = new List<Map<String,Object>>();
        for(ccrz__E_Product__c prd:product)
        {
            Map<String,Object> prodData = new Map<String,Object>();
            prodData.put('sfid',prd.Id);
            productDataMapList.add(prodData);
        }
        listObject.put('listItemID', objPriceListItem.Id);
        
        Map<String,Object> spfIDValue = new Map<String,Object>();
        spfIDValue.put('sfid',objPriceListItem.id);
        List<Map<String, Object>> listMap = new List<Map<String, Object>>();
        listMap.add(listObject);
        insidePricing.put(ccrz.cc_hk_Pricing.PRICE_MAP_ENTRIES, listMap);
        insidePricing.put('productPrice', spfIDValue);
        pricingResult.put(product[0].id, insidePricing);
                
        Map<String, Object> testData=new Map<String, Object>();
        List<Map<String, Object>> productMapList = new List<Map<String, Object>>();
        productMapList.add(productList);
        testData.put('productList',productDataMapList);
        testData.put('productPricingData',pricingResult);
        
        testData.put('sfid',objPriceListItem1.Id);
        Map<string,Object> retData=new Map<string,Object>();
        Map<string,Object> retDataValue=new Map<string,Object>();
        retDataValue.put(''+product[0].id, product[0]);
        
        retData.put('sfid',objPriceListItem1.Id);
        retData.put('CustomFactor', 10);
        retData.put('CustomPricingUOM', 'KG');
        retData.put('CustomUnitPrice', 30.00);       
        
        retData.put('productPricingData',retDataValue);
        
        
        List<Map<string,Object>> lstPriceList = new List<Map<string,Object>>();
        lstPriceList.add(retData);
        System.debug('retData - > '+retData);   
        List<Map<string,Object>> lstProdList = new List<Map<string,Object>>();
        lstProdList.add(retData);
        testData.put('priceListItems',lstPriceList);
        
        Test.startTest();
        EC_ccLogicProductPricing var=new EC_ccLogicProductPricing();
        var.process(testData);
        system.assertNotEquals(var.process(testData), null);
        var.determinePrice(testData);
        system.assertNotEquals(var.determinePrice(testData), null);
        Test.stopTest();
    }
}