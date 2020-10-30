@isTest
public without sharing class  EC_ProductDetailControllerTest {
    
    static testMethod void processMethod() {
        Set<String> ProdPkgCode = new Set<String>();
        ProdPkgCode.add('91');
        ProdPkgCode.add('36');
        String salesorg = '1001';
        Test.startTest();
        Account shipTo = [Select EC_SalesOrg__c,Ship_To_Name__c from Account Where Id=:EC_TestData.testAccountShipTo.id];
        shipTo.EC_SalesOrg__c = '1001';
        shipTo.parent =EC_TestData.testAccountShipTo;
        update shipTo;
        ccrz.cc_CallContext.effAccountId = shipTo.id;        
        EC_ProductDetailController obj = new EC_ProductDetailController();
        system.debug('obj'+obj);
        EC_TestData.setupCatalog();
        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c();
        priceList.Name = 'AllProduct_PL';
        priceList.ccrz__PricelistId__c = 'AllProduct_PL';
        priceList.ccrz__EndDate__c = System.today();
        priceList.ccrz__Enabled__c = true;
        priceList.ccrz__StartDate__c = System.today();
        insert priceList;
        priceList.BA_Number__c = 'BANumber007';
        priceList.EC_Price_List_Type__c = 'FBA';
        update priceList;
        List<ccrz__E_Product__c> product = [Select ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductStatus__c, ccrz__ProductIndexStatus__c FROM ccrz__E_Product__c limit 2];
        product[0].ccrz__SKU__c = 'GEN CHEMICAL';
        update product;
        set<string> pset = new set<string>();
        for(ccrz__E_Product__c prod : product) {
            pset.add(prod.ccrz__SKU__c);
        }
        ccrz__E_PriceListItem__c pli = new ccrz__E_PriceListItem__c();
        pli.ccrz__Product__c =  product[0].id;
        pli.ccrz__Price__c = 0.0;
        pli.ccrz__Pricelist__c = priceList.id;
        pli.ccrz__StartDate__c = System.today();
        pli.ccrz__EndDate__c = System.today();
        insert pli;
        ccrz__E_AccountGroup__c acGrp = EC_TestData.testAccountGroup;
        ccrz__E_AccountGroupPriceList__c testAccountGroupPriceList = new ccrz__E_AccountGroupPriceList__c();
        testAccountGroupPriceList.ccrz__AccountGroup__c = acGrp.Id;
        testAccountGroupPriceList.EC_Price_List_Type__c = 'Z1MP';
        testAccountGroupPriceList.ccrz__PriceList__c    = priceList.Id;
        testAccountGroupPriceList.ccrz__Enable__c       = true;
        testAccountGroupPriceList.ccrz__StartDate__c = System.today();
        testAccountGroupPriceList.ccrz__EndDate__c = System.today();
        insert testAccountGroupPriceList;
        Map<String,List<ccrz__E_Pricelist__c>> productLineBASetMap = EC_ProductDetailController.productLineBASetMap(acGrp.Id,pset);
        Map<String,List<String>> resp = EC_ProductDetailController.getDeliveryTemplateCode(ProdPkgCode,salesorg);
        EC_ProductDetailController.isTankNumberApplicable(ProdPkgCode,salesorg);
        system.assertNotEquals(null, productLineBASetMap);
        System.assert(null != resp);
        Test.stopTest();
    }
    
    @isTest
    private static void testUnstampBillingArrangement()
    {
        ccrz__E_PriceList__c fbaPriceList = EC_SplitOrderTest.priceListUtility('Fixed','FBA');
        ccrz__E_PriceList__c usgPriceList = EC_SplitOrderTest.priceListUtility('Usage','USG');
        Set<ccrz__E_PriceList__c> setPriceList = new Set<ccrz__E_PriceList__c>{usgPriceList};
            
        List<ccrz__E_Product__c> listProducts = EC_SplitOrderTest.productUtility(2);        
        EC_SplitOrderTest.priceListItemUtility(listProducts,usgPriceList.Id);
               
        
        ccrz.cc_CallContext.effAccountId = EC_TestData.testAccount.Id; 
        List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1); 
        String encryptedId = [SELECT ccrz__EncryptedId__c from ccrz__E_Cart__c Where Id IN: cart Limit 1].ccrz__EncryptedId__c;
        cart[0].ccrz__EffectiveAccountID__c = ccrz.cc_CallContext.effAccountId;
        update cart[0];
        CCRZ.cc_CallContext.currCartId = encryptedId;
        
        Map<id,Set<ccrz__E_Pricelist__c>> productToApplicableBAMap = new Map<id,Set<ccrz__E_Pricelist__c>>();
        Map<String,Set<ccrz__E_Pricelist__c>> prodBAsetMap = new Map<String,Set<ccrz__E_Pricelist__c>>();
        
        ccrz__E_CartItem__c cartItem1;        
        List<ccrz__E_CartItem__c> listInsertCartItems = new List<ccrz__E_CartItem__c>();        
        for(ccrz__E_Product__c varProduct : listProducts)
        {
            cartItem1 = new ccrz__E_CartItem__c();
            cartItem1.ccrz__Cart__c = cart[0].Id;
            cartItem1.ccrz__Product__c = varProduct.id;
            cartItem1.ccrz__Price__c = 100;
            cartItem1.Billing_Arrangement__c = fbaPriceList.Id;
            listInsertCartItems.add(cartItem1);
            productToApplicableBAMap.put(varProduct.Id,setPriceList);
            prodBAsetMap.put(varProduct.Id,setPriceList);
        }    
        insert listInsertCartItems;        
        List<ccrz__E_CartItem__c> listCartItems = EC_ProductDetailController.unstampBillingArrangement(productToApplicableBAMap,prodBAsetMap);
        system.assertEquals(false,listCartItems.isEmpty());
    }
}