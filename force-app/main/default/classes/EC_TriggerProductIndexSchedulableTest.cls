/********************************************************************************************************
* @Class Name    EC_TriggerProductIndexSchedulableTest
* @description   EC_TriggerProductIndexSchedulableTest is used to test functionality of new EC_TriggerProductIndexSchedulable
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
public class EC_TriggerProductIndexSchedulableTest{

    public static testMethod void testScheduleJob(){
      String sch = '0 59 * * * ?'; 
        // Schedule the test job
      
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

      EC_TestData.setupCatalog();
      ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c();
      priceList.Name = 'AllProducts_PL';
      priceList.ccrz__PricelistId__c = 'AllProducts_PL';
      priceList.ccrz__EndDate__c = System.today() +10;
      priceList.ccrz__Enabled__c = true;
      priceList.ccrz__StartDate__c = System.today() - 1;
      insert priceList;
      
      List<ccrz__E_Product__c> products = [Select ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductStatus__c, ccrz__ProductIndexStatus__c FROM ccrz__E_Product__c limit 15];
      List<ccrz__E_PriceListItem__c> plis = new List<ccrz__E_PriceListItem__c>();

      for (Integer i=0; i<products.size();i++) {
        ccrz__E_PriceListItem__c pli = new ccrz__E_PriceListItem__c();
        pli.ccrz__Product__c =  products[i].id;
        pli.ccrz__Price__c = 0.0;
        pli.ccrz__Pricelist__c = priceList.id;
        pli.ccrz__StartDate__c = System.today()-10;
        plis.add(pli);
        products[i].ccrz__ProductIndexStatus__c = 'Pending';
      }
      insert plis;
      update products;   
      Test.startTest();
        String jobId = System.schedule('EC_TriggerProductIndexBatch',sch,new EC_TriggerProductIndexSchedulable());
      Test.stopTest();
         // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime
                                FROM CronTrigger WHERE id = :jobId];
      System.assertEquals(sch, ct.CronExpression);

  }
}