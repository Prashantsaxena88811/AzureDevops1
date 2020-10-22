/********************************************************************************************************
* @Class Name    EC_TriggerProductIndexTest
* @description   EC_TriggerProductIndexTest is used to test functionality of EC_TriggerProductIndex
* @Created By -  Ravindra Singh  
* @Created On -  2019-11-27
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-11-27                                    Initial version
 *********************************************************************************************************/ 
@isTest
public class EC_TriggerProductIndexTest{

   public static testMethod void withExistingPricelist(){
          
     EC_TestData.setupTestUser();
         User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' limit 1];
         System.runas(thisUser){
            
        EC_TestData.setupCatalog();
        
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
            
             
        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c();
        priceList.Name = 'AllProducts_PL';
        priceList.ccrz__PricelistId__c = 'AllProducts_PL';
        priceList.ccrz__EndDate__c = System.today() +10;
        priceList.ccrz__Enabled__c = true;
        priceList.ccrz__StartDate__c = System.today() - 1;
        insert priceList;
        
       ccrz__E_Product__c product = [Select ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductStatus__c, ccrz__ProductIndexStatus__c FROM ccrz__E_Product__c limit 1];
        
        ccrz__E_PriceListItem__c pli = new ccrz__E_PriceListItem__c();
                    pli.ccrz__Product__c =  product.id;
                    pli.ccrz__Price__c = 0.0;
                    pli.ccrz__Pricelist__c = priceList.id;
                    pli.ccrz__StartDate__c = System.today()-10;
                    insert pli;
         
         product.ccrz__ProductIndexStatus__c = 'Pending';
         update product;           

            /**Test Start Here**/
            Test.startTest();
            EC_TriggerProductIndex allowedCatJob=new EC_TriggerProductIndex();
            Database.executebatch(allowedCatJob);         
            Test.stopTest();
            /**Test Stop Here**/
  }
 }

}