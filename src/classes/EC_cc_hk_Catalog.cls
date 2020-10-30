/* Class Name      :EC_cc_hk_Catalog
* Description      :Hook class for Catalog
* Created By       :Ashish Kr. 
* Created On       :07-08-2019

* Modification Log:
* ------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------------------------------------------
* Ashish Kr.               07-08-2019                              Initial version (log modification)
*
*
*/
global without sharing class EC_cc_hk_Catalog extends ccrz.cc_hk_Catalog {
    /*
*   Method name -   autoComplete
*   Parameters  -   Map<String,Object> inputData
*   Description -   method overrides auto fill of search functionality of cloud craze with contains in product name
*/
    global override Map<String,Object> autoComplete(Map<String,Object> inputData){
        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EC_ccLogicProductFind:autoComplete:inputData', inputData);
        Map<String,Object> superRet = new Map<String,Object>();
        String prodName = (String)inputData.get(ccrz.cc_hk_Catalog.PARAM_SEARCH_STRING);
        String storeFront = (String)inputData.get('STOREFRONT_STRING');
        Integer iLimit = (Integer)inputData.get('RESULTS_LIMIT');
        String prodStatus = Label.EC_ProductStatusFilter;
        String[] prodSts = prodStatus.split(';');
        Set<String> setProdStatus = new Set<String>(prodSts);
        prodName = prodName + '%'; 
        String  prodName2 = '% '+ prodName;
        Date today = Date.today();
        try{
            List<String> lstProdName = new List<String>();
            Set<String> priceIdsIdsSet = new Set<String>();
            Set<String> prodIdsSet = new Set<String>();
            String accGroupId;
            String effAccID = ccrz.cc_CallContext.effAccountId;
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EC_ccLogicProductFind:autoComplete:effAccID', effAccID);
            if(Cache.Session.contains('local.UserCache.priceIdsIdsSet'+effAccID)){
                priceIdsIdsSet = (Set<String>) Cache.Session.get('local.UserCache.priceIdsIdsSet'+effAccID);
            }else{
                for(ccrz__E_AccountGroupPriceList__c accGroup : [SELECT ccrz__AccountGroup__c,ccrz__Pricelist__c,ccrz__Pricelist__r.ccrz__CurrencyISOCode__c 
                                                                 from ccrz__E_AccountGroupPriceList__c 
                                                                 where ccrz__StartDate__c <= :today 
                                                                 AND ccrz__EndDate__c >= :today 
                                                                 AND ccrz__AccountGroup__c IN (Select ccrz__E_AccountGroup__c from Account Where Id=:ccrz.cc_CallContext.effAccountId)
                                                                 AND ccrz__Pricelist__r.ccrz__CurrencyISOCode__c=:ccrz.cc_CallContext.userCurrency
                                                                 AND ccrz__PriceList__r.ccrz__Storefront__c INCLUDES (:storeFront) 
                                                                 AND ccrz__Pricelist__r.ccrz__StartDate__c <= :today 
                                                                 AND ccrz__Pricelist__r.ccrz__EndDate__c >= :today]){            
                                                                     priceIdsIdsSet.add(accGroup.ccrz__Pricelist__c);            
                                                                 }
                Cache.Session.put('local.UserCache.priceIdsIdsSet'+effAccID, priceIdsIdsSet);
            }
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EC_ccLogicProductFind:autoComplete:priceIdsIdsSet', priceIdsIdsSet);
            
            for(AggregateResult ep : [SELECT ccrz__Product__r.Name prodName from ccrz__E_PriceListItem__c 
                                      where ccrz__Pricelist__c in :priceIdsIdsSet
                                      AND ccrz__StartDate__c <= :today
                                      AND ccrz__EndDate__c >= : today
                                      AND ccrz__Product__r.ccrz__StartDate__c <= :today 
                                      AND ccrz__Product__r.ccrz__EndDate__c >= :today 
                                      AND ccrz__Product__r.ccrz__Storefront__c=:storeFront 
                                      AND (ccrz__Product__r.name like :prodName or ccrz__Product__r.name like :prodName2) 
                                      AND ccrz__Product__r.ccrz__ProductStatus__c in :setProdStatus AND ccrz__Product__r.ccrz__ProductIndexStatus__c !=: Label.EC_ProductIndexPending Group By ccrz__Product__r.Name limit :iLimit]){
                                          lstProdName.add(String.valueOf(ep.get('prodName')));
                                      }
			ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EC_ccLogicProductFind:autoComplete:lstProdName', lstProdName);            
            inputData.put(ccrz.cc_hk_Catalog.PARAM_SEARCH_RESULTS, lstProdName);
        }        
        catch (exception ex)
        {
            System.debug('autoComplete: exception' + ex.getMessage() + ' ' + ex.getLineNumber() + ' '+ ex.getStackTraceString());
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EC_ccLogicProductFind:autoComplete:error', ex.getMessage() + ' ' + ex.getLineNumber());
        }
        return inputData;
    }
}