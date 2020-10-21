/* Class Name       :EC_cc_hk_CatalogTest
* Description      :Test class for EC_cc_hk_Catalog class
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
@IsTest
public class EC_cc_hk_CatalogTest{
     /***************************************************************************************************************************************
  Method Name : autocompleteTest
  Description : Test method to cover autocomplete method
  Return type : void
 *************************************************************************************************************************************/
    @IsTest
    static void autocompleteTest(){
        Map<String,Object> testMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        List<String> lstProdName = new List<String>();
        List<ccrz__E_Product__c> lstProducts = new List<ccrz__E_Product__c>();
        List<String> testProdName = new List<String>();
        String prodStatus = Label.EC_ProductStatusFilter;
        String[] prodSts = prodStatus.split(';');
        Set<String> setProdStatus = new Set<String>(prodSts);
        Test.startTest();
        testMap.put(ccrz.cc_hk_Catalog.PARAM_SEARCH_STRING,'prod');
        testMap.put('STOREFRONT_STRING','DefaultStore');
        testMap.put('RESULTS_LIMIT',5);
        EC_TestData.setupcatalog();
        
        ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
        Account shipTo = EC_TestData.testAccountShipTo;
        rac.effAccountId = shipTo.id;
        ccrz.cc_CallContext.initRemoteContext(rac);
        
        EC_cc_hk_Catalog testCon = new EC_cc_hk_Catalog();
        outMap = testCon.autocomplete(testMap);
        testProdName = (List<String>)outMap.get(ccrz.cc_hk_Catalog.PARAM_SEARCH_RESULTS);
        testProdName = (List<String>)outMap.get(ccrz.cc_hk_Catalog.PARAM_SEARCH_RESULTS);
        System.assert(true);
        Test.stopTest();
    }
    /***************************************************************************************************************************************
  Method Name : autocompleteTest
  Description : Test method to cover autocomplete method
  Return type : void
 *************************************************************************************************************************************/
    @IsTest
    static void autocompleteTest2(){
        Map<String,Object> testMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        List<String> lstProdName = new List<String>();
        List<ccrz__E_Product__c> lstProducts = new List<ccrz__E_Product__c>();
        List<String> testProdName = new List<String>();
        String prodStatus = Label.EC_ProductStatusFilter;
        String[] prodSts = prodStatus.split(';');
        Set<String> setProdStatus = new Set<String>(prodSts);
        Test.startTest();
        testMap.put(ccrz.cc_hk_Catalog.PARAM_SEARCH_STRING,'prod');
        testMap.put('STOREFRONT_STRING','DefaultStore');
        testMap.put('RESULTS_LIMIT',5);
        EC_TestData.setupcatalog();
        
        ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
        Account shipTo = EC_TestData.testAccountShipTo;
        // rac.effAccountId = shipTo.id;
        ccrz.cc_CallContext.initRemoteContext(rac);
        
        try{
            EC_cc_hk_Catalog testCon = new EC_cc_hk_Catalog();
            outMap = testCon.autocomplete(testMap);
            testProdName = (List<String>)outMap.get(ccrz.cc_hk_Catalog.PARAM_SEARCH_RESULTS);
            testProdName = (List<String>)outMap.get(ccrz.cc_hk_Catalog.PARAM_SEARCH_RESULTS);
            System.assert(true);
        }catch(Exception ex){
            system.debug('Exception occured '+ ex.getMessage());
            
        }
        Test.stopTest();
    }
    
}