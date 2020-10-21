/* Class Name      :EC_ccLogicProductPricing
* Description      :Below class is the used to fetch PriceList & PriceListItems
* Created By       :Bharath KN
* Created On       :08/05/2020 

* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------------------------------------------
*/

global virtual with sharing class EC_ccLogicProductPricing extends ccrz.ccLogicProductPricing{
   Global Static final String effAccountId = ccrz.cc_CallContext.effAccountId;
   global static List<Account> effAccountList {
        get {
        ccrz.cclog.log('ccLogicProductPricing effAccountList Before--->' + effAccountList );
            if (effAccountList == null) {
                if (!Account.sObjectType.getDescribe().isAccessible()) {
                    return new List<Account>();
                }
                ccrz.cclog.log('ccLogicProductPricing effAccountList After--->' + effAccountList );
                effAccountList = [Select Id,EC_Division__c FROM Account WHERE Id=:effAccountId LIMIT 1];
            }
            return effAccountList;
        }
        private set;
    }
    global virtual override Map<String, Object> determinePrice(Map<String, Object> inputData){
        Integer CustomFactor;
        String CustomPricingUOM='';
        Decimal CustomUnitPrice;
        String division ='';
        ccrz.cclog.log('inputData superRet--->' + inputData);
        if(!effAccountList.isEmpty()){
            division = effAccountList[0].EC_Division__c;
        }
        if(System.label.EC_DivisionValueNACLO.containsIgnoreCase(division)) {
            Map<String,Object> superRet = super.determinePrice(inputData);
            String pliSfid = '';
            if(superRet.containsKey('sfid')) {
                pliSfid = String.ValueOf(superRet.get('sfid'));
            }
            ccrz.cclog.log('First superRet--->' + superRet);
            List<Map<String,Object>> priceListItems = (List<Map<String,Object>>) inputData.get('priceListItems');
            for(Map<String,Object> priceListItem : priceListItems) {
                if(priceListItem.containsKey('sfid') && priceListItem.get('sfid') == pliSfid){
                    for(String key : priceListItem.keyset()) {
                        if(key.equalsIgnoreCase('customFactor')) {
                            CustomFactor = Integer.Valueof(priceListItem.get(key));
                            superRet.put('CustomFactor',CustomFactor);
                        }
                        if(key.equalsIgnoreCase('customPricingUOM')) {
                            CustomPricingUOM = String.valueof(priceListItem.get(key));
                            superRet.put('CustomPricingUOM',CustomPricingUOM);
                        }
                        if(key.equalsIgnoreCase('customUnitPrice')) {
                            CustomUnitPrice = (Decimal)priceListItem.get(key);
                            superRet.put('CustomUnitPrice',CustomUnitPrice);
                        }
                        ccrz.cclog.log('determinePrice key--->' + key + ' Value: '+priceListItem.get(key));
                    }                   
                }
            }
            ccrz.cclog.log('CustomFactor:' + CustomFactor+' CustomPricingUOM:'+CustomPricingUOM+' CustomUnitPrice:'+CustomUnitPrice);
            ccrz.cclog.log('superRet NALCO--->' + superRet);
            return superRet;
        } else {
            ccrz.cclog.log('determinePrice Non-NALCO--->' + inputData);
            return super.determinePrice(inputData);
        }
    }
    /***************************************************************************************************************************************
*   Method Name : process
*   Description : process method is overridden to add the custom fields of the price list item to the CC Product
*   Return type : Map<String, Object>
*   Created By  : Bharath KN
*   Created On  : 13/05/2020
**************************************************************************************************************************************/    
    global override Map<String,Object> process(Map<String,Object> inputData) {
        String division ='';
        if(!effAccountList.isEmpty()){
            division = effAccountList[0].EC_Division__c;
        }
        if(System.label.EC_DivisionValueNACLO.containsIgnoreCase(division)) {
        Map<String,Object> retData = super.process(inputData);
        Map<String,Object> priceResult;
        Map<String,Object> productData;
        Map<String,Object> priceEntries;
        List<Map<String,Object>> productList = (List<Map<String,Object>>)retData.get('productList');
        Map<String,Object> pricingResults = (Map<String,Object>)retData.get('productPricingData');
        Map<String,Map<String,Object>> productDataMap = new Map<String,Map<String,Object>>();
        if(productList==null){
            return retData ;
        }
        for (Map<String,Object> productD : productList) {
            productDataMap.put((String)productD.get('sfid'), productD);
        }
        for(String productSFID : pricingResults.keySet()){
            priceResult = (Map<String,Object>)pricingResults.get(productSFID);            
            productData = productDataMap.get(productSFID);
            ccrz.ccLog.log('debug:priceResult -',priceResult );
            priceEntries = (Map<String,Object>)priceResult.get('productPrice');
            ccrz.ccLog.log('debug:priceEntries', priceEntries); 
            if (productData != null) {
                productData.put('CustomFactor',priceEntries.get('CustomFactor'));
                productData.put('CustomPricingUOM', priceEntries.get('CustomPricingUOM'));
                productData.put('CustomUnitPrice', priceEntries.get('CustomUnitPrice'));
            }
        }
        ccrz.cclog.log('process NALCO--->' + retData);
        return retData;
    	} else {
            ccrz.cclog.log('process Non-NALCO--->' + inputData);
            return super.process(inputData);
    	}
    }
}