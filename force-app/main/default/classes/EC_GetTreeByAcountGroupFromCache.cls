/* Class Name    : EC_GetTreeByAcountGroupFromCache
 * Description      :Class used to get the category cache data on run time by looking at user account group id
 * Created By       :Jitan Goyal
 * Created On       :07-30-2019

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Jitan Goyal             07-30-2019       BC-74102       Created the class   
 *
 */
global with sharing class EC_GetTreeByAcountGroupFromCache extends ccrz.ccLogicCategoryGetTree{
	 /***************************************************************************************************************************************
  Method Name : process
  Description : return category tree data from EC_CategoryTreeCache__c object 
  Return type : Returns Map<String,Object>
 *************************************************************************************************************************************/
	global virtual override Map<String, Object> process(Map<String, Object> inputData){
        /*
         * Account acc = [Select ccrz__E_AccountGroup__c from Account Where Id=:ccrz.cc_CallContext.effAccountId Limit 1];
        String accGroup = '';
        if(acc!=null){
            accGroup = acc.ccrz__E_AccountGroup__c;
        }*/

		List<EC_CategoryTreeCache__c> caches = [
			SELECT
			EC_CacheData__c,
			EC_Locale__c,
			EC_Currency__c,
            EC_Sequence__c
			FROM
			EC_CategoryTreeCache__c
			WHERE
			EC_Storefront__c = :ccrz.cc_CallContext.storefront AND
			EC_AccountGroup__c IN (Select ccrz__E_AccountGroup__c from Account Where Id=:ccrz.cc_CallContext.effAccountId) AND
			(
			EC_Locale__c = :ccrz.cc_CallContext.userLocale
			)
			ORDER BY
			EC_Sequence__c ASC
		];
		ccrz.ccLog.log(LoggingLevel.DEBUG,'@@','@@caches='+ caches);
		// if no cache is found, fall back on the default full category tree
		if(caches.isEmpty()){
			return null;//super.process(inputData);
		}
        String cache = '';
        for(EC_CategoryTreeCache__c cacheRecord:caches){
            if(String.isNotBlank(cache)){
                cache = cache + cacheRecord.EC_CacheData__c;
            }else{
               cache = cacheRecord.EC_CacheData__c; 
            }
        }
		List<ccrz.cc_bean_Category> theCategories = (List<ccrz.cc_bean_Category>)JSON.deserialize(cache,List<ccrz.cc_bean_Category>.class);
		ccrz.ccLog.log(LoggingLevel.DEBUG,'@@','@@theCategories='+ theCategories);
		Map<String, Object> ret = new Map<String,Object>();
		ret.put(ccrz.ccAPICategory.CATEGORYTREE,(Object)theCategories);
		return ret;
	}
    
}