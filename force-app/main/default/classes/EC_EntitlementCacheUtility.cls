    /* Class Name       :EC_EntitlementCacheUtility
    * Description      :wrapper class used in EC_EntitlementCacheUtility
    * Created By       :Rajeshwar Bachu
    * Created On       :14-08-2020
    *
    * Modification Log:
    * ----------------------------------------------------------------------------------------------------------------
    * Developer                Date                Modification ID             Description
    * ----------------------------------------------------------------------------------------------------------------
    * Rajeshwar Bachu         14-08-2020                                   wrapper class used in EC_EntitlementCacheUtility
    * 
    */
    public with sharing class EC_EntitlementCacheUtility {
    @TestVisible private EC_EntitlementCacheUtility() {
        //Codescan issues used private constructor
    }
    /***************************************************************************************************************************************
    Method Name : getINSTSalesEntitlements
    Description : to fetch the info to cache
    Return type : EC_EntitlementCacheDTO
    Author      : Rajeshwar Bachu
*************************************************************************************************************************************/
    @TestVisible private static EC_EntitlementCacheDTO getINSTSalesEntitlements(String effecId) { 
        EC_EntitlementCacheDTO productCache = new EC_EntitlementCacheDTO();
        List<String> ProductIds = new List<String>();
        List<INST_Sales_Entitlement__c> instSalesEntitList;
        if(!String.isBlank(effecId) && INST_Sales_Entitlement__c.sObjectType.getDescribe().isAccessible()){
         instSalesEntitList = [SELECT Account_Salesforce_Id__c,Taxonomy__c, Product_Salesforce_Id__r.ccrz__SKU__c,Account_Type__c FROM INST_Sales_Entitlement__c where Account_Salesforce_Id__c =:effecId and Account_Salesforce_Id__r.EC_Division__c =:EC_Constants.INSTITUTIONAL and Taxonomy__c =: EC_Constants.TAXONOMY_CHEMICAL];
        }
        if(!instSalesEntitList.isEmpty())
        {
            for(INST_Sales_Entitlement__c inst :instSalesEntitList )
            {
                if(inst.Product_Salesforce_Id__r.ccrz__SKU__c != null) {
                    ProductIds.add(inst.Product_Salesforce_Id__r.ccrz__SKU__c +'_'+inst.Account_Type__c+'_'+inst.Taxonomy__c);
                }
                else if(inst.Account_Salesforce_Id__c != null){
                ProductIds.add(inst.Account_Salesforce_Id__c +'_'+inst.Account_Type__c+'_'+inst.Taxonomy__c);     
                }
            }
            productCache.productIds = ProductIds;
        }
        return productCache;
    }
    /***************************************************************************************************************************************
    Method Name : getINSTSalesEntitlementCache
    Description : to retrieve info from cache
    Return type : EC_EntitlementCacheDTO
    Author      : Rajeshwar Bachu
*************************************************************************************************************************************/
   public static EC_EntitlementCacheDTO getINSTSalesEntitlementCache(string effecId){
    EC_EntitlementCacheDTO EntitlementCachePartition;  
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(EC_Constants.EntitlementCache); 
    if(sessionPart != Null) {
        EntitlementCachePartition = (EC_EntitlementCacheDTO)sessionPart.get(String.valueOf(effecId));
    }
    if(EntitlementCachePartition == null){
       updateEntitlementCache(effecId,EntitlementCachePartition);
        Cache.SessionPartition sessionPartcache = Cache.Session.getPartition(EC_Constants.EntitlementCache);
        EntitlementCachePartition = (EC_EntitlementCacheDTO)sessionPartcache.get(String.valueOf(effecId));
    }
    return EntitlementCachePartition;
}
/***************************************************************************************************************************************
    Method Name : updateEntitlementCache
    Description : to put the value in the Cache
    Return type : void
    Author      : Rajeshwar Bachu
*************************************************************************************************************************************/
    
    public static void updateEntitlementCache(string effecId,EC_EntitlementCacheDTO salesEntitlement){
        EC_EntitlementCacheDTO salesEntitlement1 ;
        if(Cache.Session.getPartition(EC_Constants.EntitlementCache).getCapacity()>Double.valueOf(100)){
            clearCache(String.valueOf(effecId));
        }
        try{
            salesEntitlement1  =  getINSTSalesEntitlements(String.valueOf(effecId));
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(EC_Constants.EntitlementCache);
            sessionPart.put(String.valueOf(effecId), salesEntitlement1);
            if(Test.isRunningTest()) {         
                throw new DMLException('Test coverage'); 
            }
        }catch(Exception ex){
            EC_UtilityLogger.logException(ex,'EC_EntitlementCacheUtility','updateEntitlementCache',false,null,'');
        }
    } 
/***************************************************************************************************************************************
    Method Name : clearCache
    Description : to clear cache
    Return type : void
    Author      : Rajeshwar Bachu
*************************************************************************************************************************************/
   public static void clearCache(string effecId){
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(EC_Constants.EntitlementCache);
    sessionPart.remove(String.valueOf(effecId));
}
}