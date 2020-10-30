/*********************************************************************************
Class Name      : EC_CoveoProductListController
Description     : This class is the main controller for Coveo Product List page
Created By      : COVEO
Created Date    : 09/18/2020
Modification Log:
---------------------------------------------------------------------------------- 
Developer                 Date                   Description
----------------------------------------------------------------------------------            
COVEO                     09/18/2020             Initial Version
lgcarrier@Coveo           09/28/2020             Add function: getCommerceQueryListing
*********************************************************************************/
global with sharing class EC_CoveoProductListController {

    //Coveo Query format to fetch products matching entitlements (Nested query)
    static final String FILTER_TEMPLATE = '@objecttype==ccrz__E_Product__c (NOT @sfccrz__enddate__c<now) @sfccrz__productstatus__c==("Released","Not Orderable") [[@sfccrz_product_id] @sfccrz__price__c @sfccrz__enddate__c>now @sfccrz__pricelist__c==({0})]';
    static final String FILTER_NO_PRODUCT = 'NOT @objecttype==(ccrz__E_Product__c,ccrz__E_PriceListItem__c)';
    
    //variable to generate exception when test class is running
    @TestVisible
    private static boolean throwTestException = false;

    //public get/set for account type and permissions
    public Boolean viewPrice {get;set;}
    public Boolean buyOnline {get;set;}
    public Boolean indirectStreetBrand{get;set;}

    public EC_CoveoProductListController(){
        //Getting permissions from EC Utilily cache
        viewPrice = false;
        buyOnline = false;
        indirectStreetBrand = false;//ISE-152904
        List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermCache();
        ccrz.ccLog.log('permWrapperLst54'+permWrapperLst);
        for(EC_Utility.PermWrapper perm : permWrapperLst){
            if(perm.permName == 'View Price'){
                viewPrice = perm.permVal;
            }
            if(perm.permName == 'Buy Online'){
                buyOnline= perm.permVal;
            }
        } 
        indirectStreetBrand =EC_Utility.isIndirectStreetBrandAccount();//ISE-152904
        //ccrz.ccLog.log(System.LoggingLevel.INFO, 'ERR','indirectStreetBrand: '+indirectStreetBrand);
    }

    /*************************************************************************************************
    Method Name : addToCart
    Description : method to add product to cart
    Params:       Remote action context), Product SKU, Quantity, cart id
    Return type : crz.cc_RemoteActionResult
    **************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult addToCart(final ccrz.cc_RemoteActionContext ctx, String sku, Decimal qty, String cartId) {
        Boolean wasSuccessful = false;
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;

        // Add sku and qty
        Map<String, Object> newSKUToAdd = new Map<String, Object> {
            ccrz.ccApiCart.LINE_DATA_SKU => sku,
            ccrz.ccApiCart.LINE_DATA_QUANTITY => qty
        };


        // Add item to current cart
        Map<String, Object> cartItemsToAdd = new Map<String, Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiCart.CART_ENCID => cartId,
            ccrz.ccApiCart.LINE_DATA => new List<Map<String, Object>> {newSKUToAdd}
        };
        
        try {
             //Call ccrz API to add product to cart
            Map<String, Object> addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);
            wasSuccessful = (Boolean)addToCartResults.get(ccrz.ccApi.SUCCESS);
            res.data = cartId;
            res.success = wasSuccessful;
        } catch (Exception ex) {
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR',ex.getMessage());
        }
        return res;
    }  
    

    /*************************************************************************************************
    Method Name : fetchProduct
    Description : method to fetch Products from Cloud Craze API
    Params:       list of product ids
    Return type : Map<String,String>
    **************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult fetchProducts(final ccrz.cc_RemoteActionContext ctx, List<String> productIds) {
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        ccrz.cc_CallContext.initRemoteContext(ctx);
        res.success = false;
         //Setup product query 
         Map<String, Object> productFetchQuery = new Map<String, Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
            ccrz.ccApiProduct.PRODUCTIDLIST => new Set<String>(productIds),
            ccrz.ccApiProduct.INCLUDE_ATTRIBUTE_PRICING => true,
            ccrz.ccApiProduct.PARSE_ATTRIBUTE_PRICING => true,
            ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true,
            ccrz.ccApi.SIZING => new Map<String, Object>{
                ccrz.ccApiProduct.ENTITYNAME => new Map<String, Object>{
                ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_XL
                }
            }
            };
    
    
            try {
                //Call ccrz API to fetch product data
                Map<String, Object> productFetchData = ccrz.ccApiProduct.fetch(
                    productFetchQuery
                );
    
                //Returning userCurrency info and Product list
                Map<String,Object> productDataResults = new Map<String,Object>();
                productDataResults.put('userCurrency', ccrz.cc_CallContext.userCurrency);
    
                productDataResults.put('products', (List<Map<String, Object>>) productFetchData.get(
                    ccrz.ccApiProduct.PRODUCTLIST
                ));
                res.success = true;
                res.data = productDataResults;
            } catch (Exception ex) {
                res.success = false;
                res.data = false;
                ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR',ex.getMessage());
            }
        return res;
    }

    /*************************************************************************************************
    Method Name : fetchPriceForProducts
    Description : method to fetch prices for a list of products from remote action (Javascript call)
    Params:       list of product ids
    Return type : Map<String,String>
    **************************************************************************************************/
    @RemoteAction
    global static Map<String, Object> fetchPriceForProducts(List<String> productIds) {

        //Setup product query 
        Map<String, Object> productFetchQuery = new Map<String, Object>{
        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
        ccrz.ccApiProduct.PRODUCTIDLIST => new Set<String>(productIds),
        ccrz.ccApiProduct.INCLUDE_ATTRIBUTE_PRICING => true,
        ccrz.ccApiProduct.PARSE_ATTRIBUTE_PRICING => true,
        ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true,
        ccrz.ccApi.SIZING => new Map<String, Object>{
            ccrz.ccApiProduct.ENTITYNAME => new Map<String, Object>{
            ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
            }
        }
        };


        try {
            //Call ccrz API to fetch product data
            Map<String, Object> productFetchData = ccrz.ccApiProduct.fetch(
                productFetchQuery
            );
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'INFO', productFetchData);

            //Returning userCurrency info and Product list
            Map<String,Object> productDataResults = new Map<String,Object>();
            productDataResults.put('userCurrency', ccrz.cc_CallContext.userCurrency);

            productDataResults.put('priceLists', (List<Map<String, Object>>) productFetchData.get(
                ccrz.ccApiProduct.PRODUCTLIST
            ));

            return productDataResults;
        } catch (Exception ex) {
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR',ex.getMessage());
        }

        return null;
    }

    /*************************************************************************************************
    Method Name : getEntitlementsFilter
    Description : method to generate entitlements filter for current user
    Return type : String (Coveo filter format)
    **************************************************************************************************/
    private String getEntitlementsFilter() {
        
        Map<String, Object> callInputs = new Map<String,Object> {
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
        };

        ccrz.ccLog.log(System.LoggingLevel.INFO, 'INFO','COVEO currAccountId: ' + ccrz.cc_CallContext.currAccountId);
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'INFO','COVEOOOOO effAccountId: ' + ccrz.cc_CallContext.effAccountId);
        
        
	
        Map<String,Object> callResults = null;
        String filter = '';
        
        try {
            //Call ccrz API for Price List items
            callResults = ccrz.ccApiPriceList.fetchEntitled( callInputs );
            if(callResults.get(ccrz.ccApiPriceList.PLIDS) != null) {
                Map<String,Object> pricelistsIds = (Map<String,Object>)callResults.get(ccrz.ccApiPriceList.PLIDS);
                //Getting Price List Ids from API response
                String priceListIds = getPriceListIdsStringFromResponse(pricelistsIds);
                //Formating Coveo filter
                filter = String.format(FILTER_TEMPLATE, new List<Object>{priceListIds});
            } else {
                // Exclusion of all products in Coveo page in case something went wrong
                filter = FILTER_NO_PRODUCT;
            }
            // Code block to generate exception for test class coverage
            if(Test.isRunningTest() && throwTestException){
                throw new DMLException();
            }
        } catch (Exception ex) {
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR',ex.getMessage());
            // Exclusion of all products in Coveo page in case something went wrong
            filter = FILTER_NO_PRODUCT;
        }
        return filter;
    }
    
   /*************************************************************************************************
    Method Name : getPriceListIdsStringFromResponse
    Description : method to extract Price list ids form API Response
    Params:       Map<String, Object>
    Return type : String (Coveo filter format)
    **************************************************************************************************/
    private String getPriceListIdsStringFromResponse(Map<String, Object> pricelistsIds) {
        List<String> priceListIds = new List<String>();
        // Get Price List Ids from both Account and Price List Groups
        Set<String> acctGrpsPricelists = (Set<String>)pricelistsIds.get(ccrz.ccApiPriceList.ACCTGRPPLIDS);
        Set<String> priceGrpsPricelists = (Set<String>)pricelistsIds.get(ccrz.ccApiPriceList.PGPLIDS);
        if(acctGrpsPricelists != null) {
            priceListIds.addAll(acctGrpsPricelists);
        }
        if(priceGrpsPricelists != null) {
            priceListIds.addAll(priceGrpsPricelists);
        }
        return JSON.serialize(priceListIds).replaceAll('[\\[\\]]', '');
    }

    /*************************************************************************************************
    Method Name : getFilters
    Description : public method to generate filter for Coveo Search Interface
    Return type : String
    **************************************************************************************************/
    public String getFilters() {
        if (!indirectStreetBrand) {
            return getEntitlementsFilter();
        } else {
            return FILTER_NO_PRODUCT;
        }
    }
    

    /*************************************************************************************************
    Method Name : getCommerceQueryListing
    Description : public method to generate listing value for Coveo CommerceQuery component
    Return type : String
    **************************************************************************************************/
    public String getCommerceQueryListing() {
        String currentAccountName = '';

        Map<String,Object> inputData = new Map<String,Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
        };
        
        try {
            // Call ccrz API to get current account
            Map<String, Object> outputData = ccrz.ccAPIAccount.getCurrent(inputData);
            if(outputData.get(ccrz.ccAPIAccount.ACCOUNTS) != null){
                // The cast to List<Map<String, Object>> is necessary...
                List<Map<String,Object>> accounts = (List<Map<String,Object>>) outputData.get(ccrz.ccAPIAccount.ACCOUNTS);
                 
                // Get the Current Account Account
                Map<String, Object> currentAccount = accounts.get(0);
                 
                // The cast, again, is necessary...
                currentAccountName = (String)currentAccount.get('sfdcName');
            }
            // Code block to generate exception for test class coverage
            if(Test.isRunningTest() && throwTestException){
                throw new DMLException();
            }
        } catch (Exception e) {
            currentAccountName = '';
        }
        
        return currentAccountName;
    }
}