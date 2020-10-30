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
    Private String baSFID ='baSFID';
    Private String currItem ='currItem';
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
        Map<String,String> skuMap = new Map<String,String>();
        
        // <PBI-150126> This is used to get the cached Non-Orderable Products 
        EC_EntitlementCacheDTO lstCacheProducts = EC_EntitlementCacheUtility.getINSTSalesEntitlementCache(ccrz.cc_CallContext.effAccountId);
       
        List<String> prodIds = lstCacheProducts!= null ? lstCacheProducts.productIds :  new List<String>();
        //ccrz.ccLog.log('ccLogicCartAddTo prodIds' + prodIds);
        // Geting Account division
        Account effAcc;
        if(Account.sObjectType.getDescribe().isAccessible()){
             effAcc = [Select EC_Division__c from Account Where Id=:ccrz.cc_CallContext.effAccountId Limit 1];
         }
        String accDivision = effAcc.EC_Division__c; 
        // NW division from lable
        String divisions = Label.EC_LLI_Divisions;
        EC_CartDetailController.updateCartShipToSoldTo();
        if(inputData.get(ccrz.ccApiCart.LINE_DATA) instanceof List<ccrz.ccApiCart.LineData>){
            LineDataWrapper varWrapper = handleLineItemData(inputData,prodIds);
            if(varWrapper.displaySKUs != null && !varWrapper.displaySKUs.isEmpty()) {
                List<ccrz__E_ProductIndex__c> prodList = new List<ccrz__E_ProductIndex__c>();
                if(ccrz__E_ProductIndex__c.sObjectType.getDescribe().isAccessible()){
                          prodList = [SELECT ccrz__SKU__c from ccrz__E_ProductIndex__c where ccrz__SKU__c like :varWrapper.displaySKUs];
                }
                for(ccrz__E_ProductIndex__c prodInd : prodList){
                    if(!prodInd.ccrz__SKU__c.split('/')[0].equals(prodInd.ccrz__SKU__c)){
                        skuMap.put(prodInd.ccrz__SKU__c.split('/')[1],prodInd.ccrz__SKU__c);
                    }
                }
                for(ccrz.ccApiCart.LineData lineDataItem : varWrapper.finalLineData) {
                    String displaySKU = lineDataItem.sku;
                    if(!displaySKU.contains('/') && skuMap.containsKey(displaySKU)) {
                        lineDataItem.sku = skuMap.get(displaySKU);
                    }
                }
            }
            inputData.put(ccrz.ccApiCart.LINE_DATA, varWrapper.finalLineData);
            inputData.put(ccrz.ccApi.MESSAGES, 'lineData');
            Map<String, Object> retData = super.processInputData(inputdata);

            if(divisions.contains(accDivision)){
                retData.put(ccrz.ccApiCart.ADD_SEPARATE,TRUE);
            }            
            return retData;  
        } else {
            Map<String, Object> retData = super.processInputData(inputdata);
            ccrz.ccLog.log('ccLogicCartAddTo retData--' + retData);
            
            if(divisions.contains(accDivision)){
                retData.put(ccrz.ccApiCart.ADD_SEPARATE,TRUE);
            } 
            return retData;  
        }
    }
/********************************************************************************************
Method Name : addCartLinesToItems
Description : Stamps BA to the CartItems
Return type : Returns Map<String,Object>
************************************************************************************************/
global virtual override Map<String,Object> addCartLinesToItems(Map<String,Object> inputDataFetch){
        Map<String,Object> returnMapAddToCart = super.addCartLinesToItems(inputDataFetch);     
        return cartItemUtility(returnMapAddToCart);
}
/********************************************************************************************
Method Name : setCartItemFields
Description : Stamps BA to the CartItems
Return type : Returns Map<String,Object>
************************************************************************************************/    
global virtual override Map<String,Object> setCartItemFields(Map<String,Object> inputData){
        Map<String,Object> returnMap = super.setCartItemFields(inputData);     
        return cartItemUtility(returnMap);
    }

/********************************************************************************************
Method Name : cartItemUtility
Description : this method handles the redundant logic for setting Cart Items.
Return type : Returns Map<String,Object>
************************************************************************************************/  
    @TestVisible
    private Map<String,Object> cartItemUtility(Map<String,Object> returnMap)
    {
        try{
            ccrz__E_CartItem__c cartItemAdded = new ccrz__E_CartItem__c();
            if(returnMap.get(currItem) != null) {
                cartItemAdded = (ccrz__E_CartItem__c)returnMap.get(currItem);  
            }
            
            List<Object> inputMapListForAddTo = (List<Object>)returnMap.get('lineData');        
            Map<String,Object> inputMapForAddTo = (Map<String,Object>)inputMapListForAddTo[0];
            
            if(inputMapForAddTo.containsKey(baSFID) && String.isNotBlank(String.valueOf(inputMapForAddTo.get(baSFID)))){
                ccrz.ccLog.log('addCartLinesToItems' + (string)inputMapForAddTo.get(baSFID));
                cartItemAdded.Billing_Arrangement__c = (string)inputMapForAddTo.get(baSFID);
                cartItemAdded.ccrz__PricingType__c='external';
                cartItemAdded.ccrz__SubAmount__c=0.0;   
            }
            
            returnMap.put(currItem,cartItemAdded); 
        } catch(exception ex) {
            ccrz.ccLog.log('ccLogicCartAddTo stackStrace' + ex.getLineNumber()+'----'+ex.getStackTraceString());
        }
        return returnMap;
    }

    /********************************************************************************************
Method Name : handleLineItemData
Description :  this method returns displaySKU & finalLineItemData.
Return type : Returns LineDataWrapper
************************************************************************************************/  
private LineDataWrapper handleLineItemData(Map<String,Object> inputData,List<String> prodIds)
{
    List<ccrz.ccApiCart.LineData> lineData = (List<ccrz.ccApiCart.LineData>)inputData.get(ccrz.ccApiCart.LINE_DATA);
    Map<String, String> cartProdTaxonomyMap = new Map<String, String>();
    
    // <PBI-150126> This is used to identify the Product Taxonomy for Quick Order SKUs
    for(ccrz.ccApiCart.LineData lineDataItem : lineData) {
        cartProdTaxonomyMap.put(lineDataItem.sku, '');
    }
    List<ccrz__E_Product__c> prodList = new List<ccrz__E_Product__c>();
    if(ccrz__E_Product__c.sObjectType.getDescribe().isAccessible()){
            prodList = [select ccrz__SKU__c, Taxonomy__c from ccrz__E_Product__c where ccrz__SKU__c IN :cartProdTaxonomyMap.keySet()];
    }
    for(ccrz__E_Product__c eachProd : prodList) {
               cartProdTaxonomyMap.put(eachProd.ccrz__SKU__c, eachProd.Taxonomy__c);
    }

    return handleDisplaySKU(lineData,prodIds,cartProdTaxonomyMap);
}

    /********************************************************************************************
Method Name : handleDisplaySKU
Description :  this method returns displaySKU & finalLineItemData.
Return type : Returns LineDataWrapper
************************************************************************************************/  
private LineDataWrapper handleDisplaySKU(List<ccrz.ccApiCart.LineData> lineData,List<String> prodIds, Map<String, String> cartProdTaxonomyMap)
{
    LineDataWrapper varWrapper;
    List<ccrz.ccApiCart.LineData> finalLineData = new List<ccrz.ccApiCart.LineData>();
    List<String> displaySKUs = new List<String>();
       
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

    varWrapper= new lineDataWrapper(displaySKUs,finalLineData);
    return varWrapper;
}

/********************************************************************************************
Class Name : LineDataWrapper
Description : This wrapper sets disaplySKUs & finalLineData.
************************************************************************************************/  

public class LineDataWrapper
{
    List<String> displaySKUs {get;set;}
    List<ccrz.ccApiCart.LineData> finalLineData {get;set;}
    public LineDataWrapper(List<String> displaySKUs,List<ccrz.ccApiCart.LineData> finalLineData)
    {
        this.displaySKUs=displaySKUs;
        this.finalLineData=finalLineData;
    }
}

}