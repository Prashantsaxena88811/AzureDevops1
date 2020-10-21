/* Class Name    : EC_ccLogicCartAddTo
* Description      : Class to extend the Cloudcraze Logic Class ccLogicCartAddTo
* Created By       :Viraj  
* Created On       :2019-Nov-04
*/

/* Modification Log:
* -------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -------------------------------------------------------------------------------------------------------------------------------------
* Viraj                 2019-Nov-04       Tech-Debt         Created the class   
*/

global with sharing class EC_ccLogicCartAddTo extends ccrz.ccLogicCartAddTo {
    
/**************************************************************************************************************************************
Method Name : process
Description : identifies the Non-Orderable products and displays Error
Return type : Returns Map<String,Object>
Story #     : 150126
**************************************************************************************************************************************/
    private String indirectProds = '';
    
    global override Map<String, Object> process(Map<String, Object> inputData) {
        Map<String, Object> retData = new Map<String, Object>();
        retData = super.process(inputData);
        Map<String,Decimal> indirectMessage = new Map<String,Decimal>();
        if(indirectProds != '') indirectMessage.put(indirectProds,10);
        retData.put(ccrz.ccAPICart.INCRERROR, indirectMessage);
        ccrz.ccLog.log('ccLogicCartAddTo retData' + retData);
        return retData;
    } 
    
/**************************************************************************************************************************************
Method Name : processInputData
Description : prefixes the sku entered in the quick order with the source name
Return type : Returns Map<String,Object>
**************************************************************************************************************************************/
    global override  Map<String, Object> processInputData(Map<String, Object> inputData) {
        ccrz.ccLog.log('ccLogicCartAddTo inputdata1234' + inputdata);
        
        // <PBI-150126> This is used to get the cached Non-Orderable Products 
        EC_EntitlementCacheDTO lstCacheProducts = EC_EntitlementCacheUtility.getINSTSalesEntitlementCache(ccrz.cc_CallContext.effAccountId);
        
        List<String> prodIds = lstCacheProducts!= null ? lstCacheProducts.productIds :  new List<String>();
        ccrz.ccLog.log('ccLogicCartAddTo prodIds' + prodIds);
        
        if(inputData.get(ccrz.ccApiCart.LINE_DATA) instanceof List<ccrz.ccApiCart.LineData>){
            List<ccrz.ccApiCart.LineData> lineData = (List<ccrz.ccApiCart.LineData>)inputData.get(ccrz.ccApiCart.LINE_DATA);
            List<String> displaySKUs = new List<String>();
            Map<String,String> skuMap = new Map<String,String>();
            List<ccrz.ccApiCart.LineData> finalLineData = new List<ccrz.ccApiCart.LineData>();
            Map<String, String> cartProdTaxonomyMap = new Map<String, String>();
            
            // <PBI-150126> This is used to identify the Product Taxonomy for Quick Order SKUs
            for(ccrz.ccApiCart.LineData lineDataItem : lineData) {
                cartProdTaxonomyMap.put(lineDataItem.sku, '');
            }
            for(ccrz__E_Product__c eachProd : [select ccrz__SKU__c, Taxonomy__c from ccrz__E_Product__c where ccrz__SKU__c IN :cartProdTaxonomyMap.keySet()]) {
                cartProdTaxonomyMap.put(eachProd.ccrz__SKU__c, eachProd.Taxonomy__c);
            }
            
            for(ccrz.ccApiCart.LineData lineDataItem : lineData){
                // <PBI-150126> logic to skip products for INST Entitlements
                String displaySKU = lineDataItem.sku;
                
                if(prodIds != null && !prodIds.isEmpty() && (prodIds.contains(displaySKU+EC_Constants.ISE_HYBRIDDIRECT) || 
                (prodIds.contains(ccrz.cc_CallContext.effAccountId+EC_Constants.ISE_INDIRECTCORE) && (cartProdTaxonomyMap.get(displaySKU) == EC_Constants.TAXONOMY_CHEMICAL)))) {
                    indirectProds = indirectProds==''? displaySKU : indirectProds+', '+ displaySKU;
                } else {   
                    finalLineData.add(lineDataItem);
                }
                
                if(!displaySKU.contains('/')){
                    displaySKUs.add('%' + displaySKU);
                }
            }

            if(displaySKUs != null && !displaySKUs.isEmpty()) {
                List<ccrz__E_ProductIndex__c> prodList = [SELECT ccrz__SKU__c from ccrz__E_ProductIndex__c where ccrz__SKU__c like :displaySKUs];
                system.debug(prodList);
                for(ccrz__E_ProductIndex__c prodInd : prodList){
                    system.debug(prodInd);
                    if(!prodInd.ccrz__SKU__c.split('/')[0].equals(prodInd.ccrz__SKU__c)){
                        skuMap.put(prodInd.ccrz__SKU__c.split('/')[1],prodInd.ccrz__SKU__c);
                    }
                }
                for(ccrz.ccApiCart.LineData lineDataItem : finalLineData) {
                    String displaySKU = lineDataItem.sku;
                    if(!displaySKU.contains('/') && skuMap.containsKey(displaySKU)) {
                        lineDataItem.sku = skuMap.get(displaySKU);
                    }
                }
            }
            inputData.put(ccrz.ccApiCart.LINE_DATA, finalLineData);
            inputData.put(ccrz.ccApi.MESSAGES, 'lineData');
            Map<String, Object> retData = super.processInputData(inputdata);
            /*for(Object key : ((List<Object>)retData.get('lineData'))){
ccrz.ccLog.log('inputdata1234retDatakey' + key);
//ccrz.ccLog.log('inputdata1234retDatavalue' + retData.get(key));
}*/
            ccrz.ccLog.log('inputdata1234retData' + lineData);
            
            //retData.put(ccrz.ccApiCart.ADD_SEPARATE,TRUE);
            
            return retData;  
        } else {
            EC_CartDetailController.updateCartShipToSoldTo();
            Map<String, Object> retData = super.processInputData(inputdata);
            ccrz.ccLog.log('ccLogicCartAddTo retData--' + retData);
            //retData.put(ccrz.ccApiCart.ADD_SEPARATE,TRUE);
            
            return retData;  
        }
    }
}