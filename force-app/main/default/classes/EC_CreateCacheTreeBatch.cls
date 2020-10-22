/* Class Name    : EC_CreateCacheTreeBatch
 * Description      :Storing/Creating the cache tree of all categories
 * Created By       :Jitan Goyal  
 * Created On       :07-30-2019

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Jitan Goyal             07-30-2019        BC-74102    Created the class   
 *
 */
global with sharing class EC_CreateCacheTreeBatch implements Database.Batchable<sObject>{
	
	private String storefront;
	private String[] plCurrencies;
	private String[] locales;
    private Date today = Date.today();
    
	/***************************************************************************************************************************************
  Constructor Name : EC_CreateCacheTreeBatch
  Description : Constructor to initialize variables of EC_CreateCacheTreeBatch class
  Return type : N/A
 *************************************************************************************************************************************/
    global EC_CreateCacheTreeBatch(String storefront, String[] plCurrencies, String[] locales) {
		this.storefront = storefront;
		this.plCurrencies = plCurrencies;
		this.locales = locales;
	} 
	
	/***************************************************************************************************************************************
  Method Name : start
  Description : sets the ccrz__E_AccountGroup__c query string
  Return type : Database.QueryLocator
 *************************************************************************************************************************************/       
    global Database.QueryLocator start(Database.BatchableContext BC) {
		 String query = 'Select Id from ccrz__E_AccountGroup__c Where Id in ( ' +
		'Select ccrz__AccountGroup__c From ccrz__E_AccountGroupPriceList__c Where ccrz__Pricelist__r.ccrz__CurrencyISOCode__c IN: plCurrencies and ccrz__Pricelist__r.ccrz__Storefront__c =\'' + String.escapeSingleQuotes(storefront) +'\' AND ccrz__StartDate__c <= :today AND ccrz__EndDate__c >= :today AND ccrz__Enable__c = true)';

		return Database.getQueryLocator(query);
	}
	
	/***************************************************************************************************************************************
  Method Name : execute
  Description : get category json from the cache helper class and refreshes the cache
  Return type : void
 *************************************************************************************************************************************/    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Map<Id,List<EC_AccountGroup_Category__c>> accountGrpCategoryMap = EC_CreateCacheTreeHelper.createAccountGroupAllowedCategories(scope, plCurrencies, storefront); 
		EC_CreateCacheTreeHelper.refreshCategoryCaches(accountGrpCategoryMap, plCurrencies, storefront, locales);
	}
	
	/***************************************************************************************************************************************
  Method Name : finish
  Description : N/A
  Return type : void
 *************************************************************************************************************************************/   
    global void finish(Database.BatchableContext BC) {
	}

}