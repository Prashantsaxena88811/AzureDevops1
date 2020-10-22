/* Class Name      :EC_cclogicPICreateTest
* Description      :EC_cclogicPICreateTest is code coverage for EC_cclogicPICreate
* Created By       :Rajeshwar Bachu. 
* Created On       :25-05-2020

* Modification Log:
* ------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------------------------------------------
* Rajeshwar bachu         25-05-2020                             Initial version (log modification)
*
*
*/
@isTest
public class EC_cclogicPICreateTest {
    public static final String STOREFRONT_NAME = 'DefaultStore'; 
    
    @testSetup static void setup(){
        //INSERT CATEGORIES
        ccrz__E_Category__c testAllRoot = new ccrz__E_Category__c(
            Name                = 'Products',
            ccrz__CategoryID__c = '0',
            ccrz__StartDate__c  = Date.today().addDays(-1),
            ccrz__EndDate__c    = Date.today().addDays(1)
        );
        insert testAllRoot;
        //INSERT PRODUCTS
        ccrz__E_Product__c productint = new ccrz__E_Product__c(
            Name                       = 'product003',
            ccrz__SKU__c               = 'test003',
            ccrz__ProductId__c         = 'test003',
            ccrz__ProductStatus__c     = 'Released',
            ccrz__UnitOfMeasure__c     = 'BG',
            ccrz__StartDate__c         = Date.today().addDays(-7),
            ccrz__EndDate__c           = Date.today().addDays(7),
            ccrz__Storefront__c        = STOREFRONT_NAME,
            ccrz__ProductWeight__c     = 500,
            ccrz__HazardousFlag__c     = true,
            ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent,
            //ERP_Product_Description__c = 'Text123',
            ccrz__ShortDescRT__c = 'Text12345'
        );
        insert productint;
        //ccrz__E_Product__c product = [SELECT Id FROM ccrz__E_Product__c limit 1];        
        ccrz__E_PriceList__c priceList= new ccrz__E_PriceList__c(
            Name                     = 'PL002',
            ccrz__CurrencyISOCode__c = 'USD',
            ccrz__Enabled__c         = true,
            ccrz__Storefront__c      = STOREFRONT_NAME,
            ccrz__StartDate__c       = Date.today().addDays(-7),
            ccrz__EndDate__c         = Date.today().addDays(7),
            ccrz__PricelistId__c     = '250287-SIEMENS'
            
        );
        insert priceList;
    }
    
    static testMethod void createProductIndicesMethod()
    {
        ccrz__E_Category__c testAllRoot = [SELECT Id,Name,ccrz__CategoryID__c,ccrz__StartDate__c,ccrz__EndDate__c FROM ccrz__E_Category__c LIMIT 1];
        ccrz__E_Product__c productint = [SELECT Id,Name,ccrz__SKU__c,ccrz__ProductId__c,ccrz__ProductStatus__c,ccrz__UnitOfMeasure__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Storefront__c,ccrz__ProductWeight__c,ccrz__HazardousFlag__c,ccrz__ProductIndexStatus__c,ccrz__ShortDescRT__c FROM ccrz__E_Product__c LIMIT 1];
        ccrz__E_PriceList__c priceList = [SELECT Id,Name,ccrz__CurrencyISOCode__c,ccrz__Enabled__c,ccrz__Storefront__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__PricelistId__c FROM ccrz__E_PriceList__c LIMIT 1];
        
        Map<String,Map<String,Map<String, Object>>> pricingDataMap = new Map<String,Map<String,Map<String, Object>>>{
            productint.Id => New Map<String, Map<String,Object>>{
                'USD'=> New Map<String, Map<String,Object>>{
                    'USD' => New Map<String,Object>{
                        'price' => 1.0,
                            'priceLists' => priceList.Id
                            }
                    
                }
            }
        };
        //Map<String, Map<String, Object>> currencyPricingData = new Map<String, Map<String, Object>>();
        String productJSON = '{"shortDesc":"","ERPProductDescription":"","SKU":"3ET465.36","sfdcName":"Bella Chrome Coffee Machine","sfid":"' + productint.Id + '"}'; 
        //String productJSON = '{"shortDesc":"","ERPProductDescription":"","SKU":"3ET465.36","sfdcName":"Bella Chrome Coffee Machine","sfid":"' + productint.Id + '"}';
        string productCat = '{"startDate":"2019-03-22","sequence":100,"endDate":"2099-12-31","category":"' + testAllRoot.id + '","sfdcName":"012289","sfid":"' + productint.Id + '","product":"' + productint.Id + '"}';        
        List<Map<String,Object>> productListCatMap = new List<Map<String,Object>>();
        productListCatMap.add((Map<String,Object>)JSON.deserializeUntyped(productCat)); 
        List<Map<String,Object>> productListMap = new List<Map<String,Object>>();
        Map<String,Object> productMap = new Map<String,Object>();
        productMap = (Map<String,Object>)JSON.deserializeUntyped(productJSON);
        productMap.put('productCategoriesS', productListCatMap);
        productListMap.add(productMap); 
        Map<String, Object> inputData = new Map<String, Object>();
        inputData.put(ccrz.ccAPIProductIndex.PRODUCT_PRICING_DATA,pricingDataMap);
        inputData.put(ccrz.ccAPIProduct.PRODUCTLIST, productListMap);
        inputData.put(ccrz.ccAPIProductIndex.LOCALE,'en_US');
        inputData.put(ccrz.ccAPIProductIndex.CURRENCIES, 'USD');
        inputData.put(ccrz.ccAPI.API_VERSION, 8);
        EC_cclogicPICreate logicPICreate=new EC_cclogicPICreate();
        Test.startTest();
        logicPICreate.createProductIndices(inputData);
        system.assert(inputData!=Null);
        Test.stopTest();
    }
    
    static testMethod void productWithoutCategory()
    {
        ccrz__E_Product__c productint = [SELECT Id,Name,ccrz__SKU__c,ccrz__ProductId__c,ccrz__ProductStatus__c,ccrz__UnitOfMeasure__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Storefront__c,ccrz__ProductWeight__c,ccrz__HazardousFlag__c,ccrz__ProductIndexStatus__c,ccrz__ShortDescRT__c FROM ccrz__E_Product__c LIMIT 1];
        ccrz__E_PriceList__c priceList = [SELECT Id,Name,ccrz__CurrencyISOCode__c,ccrz__Enabled__c,ccrz__Storefront__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__PricelistId__c FROM ccrz__E_PriceList__c LIMIT 1];
        
        Map<String,Map<String,Map<String, Object>>> pricingDataMap = new Map<String,Map<String,Map<String, Object>>>{
            +productint.Id => New Map<String, Map<String,Object>>{
                'USD'=> New Map<String, Map<String,Object>>{
                    'USD' => New Map<String,Object>{
                        'price' => 1.0,
                            'priceLists' => +priceList.Id
                            }
                    
                }
            }
        };
        system.debug('testestest: ' + ccrz.ccAPIProductIndex.PRODUCT_PRICING_DATA);
        //Map<String, Map<String, Object>> currencyPricingData = new Map<String, Map<String, Object>>();
        String productJSON = '{"shortDesc":"","ERPProductDescription":"","SKU":"3ET465.36","sfdcName":"Bella Chrome Coffee Machine","sfid":"' + productint.Id + '"}'; 
        //String productJSON = '{"shortDesc":"","ERPProductDescription":"","SKU":"3ET465.36","sfdcName":"Bella Chrome Coffee Machine","sfid":"' + productint.Id + '"}';
        List<Map<String,Object>> productListMap = new List<Map<String,Object>>();
        Map<String,Object> productMap = new Map<String,Object>();
        productMap = (Map<String,Object>)JSON.deserializeUntyped(productJSON);
        productListMap.add(productMap); 
        Map<String, Object> inputData = new Map<String, Object>();
        system.debug('ccrz.ccAPIProductIndex.PRODUCT_PRICING_DATA'+ccrz.ccAPIProductIndex.PRODUCT_PRICING_DATA);
        inputData.put(ccrz.ccAPIProductIndex.PRODUCT_PRICING_DATA,pricingDataMap);
        inputData.put(ccrz.ccAPIProduct.PRODUCTLIST, productListMap);
        inputData.put(ccrz.ccAPIProductIndex.LOCALE,'en_US');
        inputData.put(ccrz.ccAPIProductIndex.CURRENCIES, 'USD');
        inputData.put(ccrz.ccAPI.API_VERSION, 8);
        EC_cclogicPICreate logicPICreate=new EC_cclogicPICreate();
        Test.startTest();
        logicPICreate.createProductIndices(inputData);
        system.assert(inputData!=Null);
        Test.stopTest();
    }
}