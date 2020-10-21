global with sharing class EC_CreatePriceListCategoryMappingBatch implements Database.Batchable<sObject>, Database.Stateful{
    private String storefront;
    private String plCurrencies;
    private String locales;
    private Date today = Date.today();
    global List<EC_PriceList_Category_Mapping__c> priceListCategoryMapping;
    global EC_CategoryTreeBatchStartEndTimeLine__c batchTime;
    
    global EC_CreatePriceListCategoryMappingBatch(String storefront, String plCurrencies, String locales) {
        this.storefront = storefront;
        this.plCurrencies = plCurrencies;
        this.locales = locales;
        batchTime = EC_CategoryTreeBatchStartEndTimeLine__c.getOrgDefaults();
    } 
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        batchTime.EC_Batch_Start_Time__c = System.now();
        String query = 'Select Id from ccrz__E_PriceList__c Where Id in (SELECT ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c) AND ccrz__CurrencyISOCode__c=\''+String.escapeSingleQuotes(plCurrencies)+'\' AND ccrz__Storefront__c =\'' + String.escapeSingleQuotes(storefront) +'\' AND ccrz__StartDate__c <= :today AND ccrz__EndDate__c >= :today AND ccrz__Enabled__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        priceListCategoryMapping = new List<EC_PriceList_Category_Mapping__c>();
        Set<Id> pricelistIDs = new Set<Id>();
        
        Map<Id,EC_PriceList_Category_Mapping__c> newPriceListCatMap = new Map<Id,EC_PriceList_Category_Mapping__c>();
        for(sObject s: scope ){
            ccrz__E_PriceList__c priceList = (ccrz__E_PriceList__c) s;
            pricelistIDs.add(priceList.id);
        }
        
        List<EC_PriceList_Category_Mapping__c> allExistingPLCat = [Select Id,EC_PriceList__c,EC_Currency__c,EC_Category__c from EC_PriceList_Category_Mapping__c Where EC_PriceList__c in :(pricelistIDs) AND EC_Currency__c=:plCurrencies AND EC_Locale__c=:locales Limit 50000];
        Map<Id,EC_PriceList_Category_Mapping__c> existingPriceListCatMap = new Map<Id,EC_PriceList_Category_Mapping__c>();
        
        if(!allExistingPLCat.isEmpty()){
            for(EC_PriceList_Category_Mapping__c priceListCat : allExistingPLCat){
                existingPriceListCatMap.put(priceListCat.EC_PriceList__c, priceListCat);
            }
        }
        
        List<EC_PriceList_Category_Mapping__c> toRemoveFromExisting = new List<EC_PriceList_Category_Mapping__c>();
        
        for(sObject s: scope ){
            EC_PriceList_Category_Mapping__c plCat = new EC_PriceList_Category_Mapping__c();
            ccrz__E_PriceList__c priceList = (ccrz__E_PriceList__c) s;
            plCat.EC_PriceList__c = priceList.id;
            plCat.EC_Currency__c = plCurrencies;
            plCat.EC_Locale__c = locales;
            plCat.EC_Category__c = EC_CreateCacheTreeHelper.createPricelistCategoryMapping(priceList.id, plCurrencies, storefront);
            //Bulkified DML statements 
            
            
            if(!existingPriceListCatMap.isEmpty() && existingPriceListCatMap.containsKey(priceList.id)){
                if((existingPriceListCatMap.get(priceList.id).EC_Category__c == plCat.EC_Category__c)
                   && (existingPriceListCatMap.get(priceList.id).EC_Currency__c == plCat.EC_Currency__c)){
                       //need not to be deleted or modified
                       toRemoveFromExisting.add(existingPriceListCatMap.get(priceList.id));
                   }else{
                       //pricelist exist but neither category nor currency matching
                       priceListCategoryMapping.add(plCat);
                   }                
            }else{
                // no existing record nor pricelist not found - create new
                priceListCategoryMapping.add(plCat);
            }
        }
        
        if(!allExistingPLCat.isEmpty()){
            if(!toRemoveFromExisting.isEmpty()){
                for(Integer i= 0; i<allExistingPLCat.size(); i++){
                    if(toRemoveFromExisting.contains(allExistingPLCat[i])){
                        allExistingPLCat.remove(i);
                    }
                }
            }
            delete allExistingPLCat;
        }
        
        if(!priceListCategoryMapping.isEmpty()){
            insert priceListCategoryMapping;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        batchTime.EC_Batch_End_Time__c = System.now();
        upsert batchTime;
        //create custom labels 
        String front = storefront;
        /**Currency**/
        List<String> curr= new List<String>();
        curr.add(plCurrencies);
        //curr.add('USD');
        
        /**Locale**/
        List<String> loc= new List<String>();
        loc.add(locales);
        //loc.add('en_US');
        
        /**Execute Batch**/
        EC_CreateCacheTreeBatch allowedCatJob=new EC_CreateCacheTreeBatch(front,curr,loc);
        Database.executebatch(allowedCatJob,80);
        
        
    }
}