/* Class Name      :EC_cclogicPICreate
* Description      :cclogicPICreate Related inherited cloud craze interface
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

global class EC_cclogicPICreate extends ccrz.ccLogicPICreate{
    /***************************************************************************************************************************************
Method Name : createProductIndices
Description : It takes data from CC Product object and populates the CC Product Index
Return type : Returns Map<String,Object>
**************************************************************************************************************************************/
    
    global virtual override Map<String,Object> createProductIndices(Map<String,Object> inputData) {
        if(ccrz.ccUtil.isNotKeyValued(inputData, ccrz.ccAPIProduct.PRODUCTLIST) || ccrz.ccUtil.isNotKeyValued(inputData, ccrz.ccAPIProductIndex.PRODUCT_PRICING_DATA)){
            return inputData;
        }
        System.debug('inside createProductIndices');
        // The Localized Product Data
        List<Object> productList = (List<Object>)inputData.get(ccrz.ccAPIProduct.PRODUCTLIST);
        
        // Pricing Data Keyed By Product SFID, Currency ISO Code
        Map<String, Map<String, Map<String, Object>>> productPricingMap = (Map<String, Map<String, Map<String, Object>>>)inputData.get(ccrz.ccAPIProductIndex.PRODUCT_PRICING_DATA);
        
        List<ccrz__E_ProductIndex__c> newProductIndices = (List<ccrz__E_ProductIndex__c>)ccrz.ccUtil.defv(inputData, ccrz.ccAPIProductIndex.PRODUCT_INDICES, new List<ccrz__E_ProductIndex__c>());
        
        for(Object product : productList){
            System.debug(' product' + product);
            Map<String, Object> castProduct = (Map<String, Object>)product;
            
            if(ccrz.ccUtil.isKeyValued(productPricingMap, (String)castProduct.get('sfid'))){
                Map<String, Map<String, Object>> currencyPricingData = (Map<String, Map<String, Object>>)productPricingMap.get((String)castProduct.get('sfid'));
                for(String currencyCode : currencyPricingData.keySet()){
                    Map<String, Object> productPricingData = currencyPricingData.get(currencyCode);
                    //If Product Categories Exist --> Create Category Indices
                    if(ccrz.ccUtil.isKeyValued(castProduct, 'productCategoriesS')){
                        List<Object> productCategories = (List<Object>)castProduct.get('productCategoriesS');
                        Boolean isFirstProductCategory = TRUE;
                        
                        // Create Index Record For Each Category The Product Belongs...
                        for(Object productCategory : productCategories){
                            Map<String, Object> castProductCategory = (Map<String, Object>)productCategory;
                            String prodCategory = (String)castProductCategory.get('sfid');
                            ccrz__E_ProductIndex__c newProductIndex = createProductIndex(productPricingData, inputData, castProduct, prodCategory, currencyCode);
                           
                            // Only One Record Should Be Flagged To Show Up In Search...
                            if(isFirstProductCategory){
                                newProductIndex.ccrz__LastIndex__c = TRUE;
                                newProductIndex.ccrz__PriceLists__c = (String)productPricingData.get('priceLists');
                                newProductIndex.ccrz__IndexType__c = ccrz.ccAPIProductIndex.INDEX_TYPE_SEARCH;
                                isFirstProductCategory = FALSE;
                            }
                            
                            newProductIndices.add(newProductIndex);
                        }
                    }
                    else{
                        // Always Create A Record For Search --> Even If Product Does Not Belong To A Category...
                        string noCategory = '';
                        ccrz__E_ProductIndex__c newPISearch = createProductIndex(productPricingData, inputData, castProduct, noCategory, currencyCode);
                        
                      
                        newProductIndices.add(newPISearch);
                    }
                }
            }
        }
        
        if(ccrz.ccUtil.isNotEmpty(newProductIndices)){
            inputData.put(ccrz.ccAPIProductIndex.PRODUCT_INDICES, newProductIndices);
        }
        
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:X', 'EC_cclogicPICreate.createProductIndices');
        return inputData;
        
    }
    
    private ccrz__E_ProductIndex__c  createProductIndex(Map<String, Object> productPricingData, Map<String,Object> inputData, 
                                                        Map<String, Object> castProduct, String productCategory, String currencyCode)
    {
        ccrz__E_ProductIndex__c pI = new ccrz__E_ProductIndex__c();
        pI.ccrz__IndexPrice__c = ccrz.ccUtil.isKeyValued(productPricingData, 'price') ? String.valueOf((Decimal)productPricingData.get('price')).leftPad(19, '0') : '0';
        pI.ccrz__Locale__c = (String)inputData.get(ccrz.ccAPIProductIndex.LOCALE);
        pI.ccrz__IndexType__c = ccrz.ccAPIProductIndex.INDEX_TYPE_SEARCH;
        pI.ccrz__PriceLists__c = (String)productPricingData.get('priceLists');
        pI.ccrz__Product__c = (String)castProduct.get('sfid');
        if(!String.isBlank(productCategory)) { pI.ccrz__ProductCategory__c = productCategory; }
        //ccrz__ProductCategory__c = (String)castProductCategory.get('sfid');
        pI.ccrz__ProductName__c = ccrz.ccUtil.isKeyValued(castProduct, 'alternateName') ? (String)castProduct.get('alternateName') : (String)castProduct.get('sfdcName');
        pI.ccrz__ShortDescription__c = (String)castProduct.get('shortDesc');
        pI.ccrz__LongDescription__c  = (String)castProduct.get('LongDesc');
        pI.ccrz__SKU__c = (String)castProduct.get('SKU');
        pI.ccrz__IndexCurrency__c = currencyCode;
        pI.ccrz__SEOKeywords__c =(String)castProduct.get('SEOKeywords');
        pI.ccrz__FilterData__c =(String)castProduct.get('filterData');
        pI.ccrz__LastIndex__c = TRUE;
        pI.ccrz__Active__c = FALSE;
        // New Custom Fields:
        pI.ERP_Product_Description__c = (String)castProduct.get('ERPProductDescription');
        return pI; 
    }
    
}