/********************************************************************************************************
* @Class Name    EC_AddProductToMasterPricelistTest 
* @description   EC_AddProductToMasterPricelistTest is used to test the functionality of EC_AddProductToMasterPricelist
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 
@isTest
public class EC_AddProductToMasterPricelistTest {
    
     /***************************************************************************************************************************************
      Method Name : AddProductToMasterPricelist_postive
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
      
    
    @isTest
    public static void AddProductToMasterPricelist_postive(){
        EC_AddProductToMasterPricelist addproducttopl= new EC_AddProductToMasterPricelist();
   
        Database.BatchableContext dbc ;
        addproducttopl.start(dbc);
        //EC_TestData.setupCatalog();
        Test.startTest();
        List<ccrz__E_PriceList__c> pricelist = [Select id from ccrz__E_PriceList__c];
        delete pricelist;    
        Database.executeBatch(new EC_AddProductToMasterPricelist());
        List<ccrz__E_Product__c> scope= new List<ccrz__E_Product__c>();
        scope = [select id from ccrz__E_Product__c];
        addproducttopl.execute(dbc,scope);
        addproducttopl.finish(dbc);
        system.assertNotEquals(addproducttopl.start(dbc), null);
        Test.stopTest();
    }
    
    /***************************************************************************************************************************************
      Method Name : AddProductToMasterPricelist
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
      
    
    @isTest
    public static void AddProductToMasterPricelist(){
        
        EC_AddProductToMasterPricelist addproducttopl= new EC_AddProductToMasterPricelist();
        Database.BatchableContext dbc ;
        addproducttopl.start(dbc);
        EC_TestData.setupCatalog();
        Test.startTest();
        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c();
        priceList.Name = 'AllProducts_PL';
        priceList.ccrz__PricelistId__c = 'AllProducts_PL';
        priceList.ccrz__EndDate__c = System.today() +10;
        priceList.ccrz__Enabled__c = true;
        priceList.ccrz__StartDate__c = System.today() - 1;
        insert priceList;
        
        EC_ProductIndexBatchStatus__c indexBatch = new EC_ProductIndexBatchStatus__c();
        indexBatch.EC_Category_Index_Switch__c = true;
        indexBatch.EC_InActive_AccountGroupPriceList_Batch__c = true;
        indexBatch.EC_InActive_PriceListItem_Batch__c = true;
        indexBatch.EC_InActive_PriceList_Batch__c = true;
        indexBatch.EC_InActive_ProductMedia_Batch__c=true;
        indexBatch.EC_Product_Index_Switch__c=true;
        indexBatch.EC_Spec_Index_Switch__c = true;
        indexBatch.EC_Category_Batch_Schedule_Interval__c = 15;
         indexBatch.EC_Product_Index_Interval__c = 5;
        insert indexBatch;
        
        Database.executeBatch(new EC_AddProductToMasterPricelist());
        List<ccrz__E_Product__c> scope= new List<ccrz__E_Product__c>();
        scope = [select id from ccrz__E_Product__c];
        addproducttopl.execute(dbc,scope);
        addproducttopl.finish(dbc);
        system.assertNotEquals(addproducttopl.start(dbc), null);
        Test.stopTest();
    }
  /***************************************************************************************************************************************
      Method Name : AddProductToMasterPricelist_exception
      Description : This method is used to test exception scenario
      Return type : void
     **************************************************************************************************************************************/
      
    @isTest
    public static void AddProductToMasterPricelist_exception(){
        EC_AddProductToMasterPricelist addproducttopl= new EC_AddProductToMasterPricelist();
        Database.BatchableContext dbc ;
        addproducttopl.start(dbc);
        Test.startTest();
        EC_TestData.setupCatalog();
        Database.executeBatch(new EC_AddProductToMasterPricelist());        
        List<ccrz__E_Product__c> scope= new List<ccrz__E_Product__c>();
        scope = [select id from ccrz__E_Product__c];
        addproducttopl.execute(dbc,scope);
        addproducttopl.finish(dbc);
        Test.stopTest();
    }
}