/********************************************************************************************************
* @Class Name    EC_TriggerProductIndex
* @description   EC_TriggerProductIndex is used to update Pending products to Not Current and executes product index batch job
* @Created By -  Ravindra Singh  
* @Created On -  2019-11-27
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-11-27                                    Initial version
 *********************************************************************************************************/ 
global class EC_TriggerProductIndex implements Database.batchable<sObject>, Database.Stateful{
    
    EC_ProductIndexBatchStatus__c indexBatchCS  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
   
     /***************************************************************************************************************************************
      Method Name : start
      Description : start method is used to query the records to be processed in the batch
      Return type : Database.QueryLocator
     **************************************************************************************************************************************/
     
     
    global Database.QueryLocator start(Database.BatchableContext BC) {
       String productList = 'Select ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductStatus__c, ccrz__ProductIndexStatus__c FROM ccrz__E_Product__c WHERE ccrz__ProductIndexStatus__c = \'Pending\' AND ccrz__ProductStatus__c in (\'Released\',\'Not Orderable\') AND ccrz__EndDate__c > Today AND id in (Select ccrz__Product__c from ccrz__E_PriceListItem__c WHERE ccrz__PriceList__r.ccrz__pricelistId__c =\'AllProducts_PL\')';
      return Database.getQueryLocator(productList);
    }
    
     /***************************************************************************************************************************************
      Method Name : execute
      Description : execute method is used to update Pending products to Not Current
      Return type : void
     **************************************************************************************************************************************/
         
    
    global void execute(Database.BatchableContext BC, List<ccrz__E_Product__c> products) {
        
            
        for(ccrz__E_Product__c product : products){
   
               product.ccrz__ProductIndexStatus__c = 'Not Current';
 
            }

        update products;
               
    
    }
    
      /***************************************************************************************************************************************
      Method Name : finish
      Description : finish method is used to trigger product index job
      Return type : void
     **************************************************************************************************************************************/
          
    
    global void finish(Database.BatchableContext BC){
    
      List<ccrz__E_Product__c> pendingProductList = [Select ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductStatus__c, ccrz__ProductIndexStatus__c FROM ccrz__E_Product__c WHERE ccrz__ProductIndexStatus__c in ('Pending','Not Current') AND ccrz__ProductStatus__c in ('Released','Not Orderable') AND ccrz__EndDate__c > Today AND id in (Select ccrz__Product__c from ccrz__E_PriceListItem__c WHERE ccrz__PriceList__r.ccrz__pricelistId__c ='AllProducts_PL')];
        
      if(pendingProductList.size()>0){
      
          List<ccrz__E_PriceList__c> pricelist = [Select id from ccrz__E_PriceList__c where ccrz__PricelistId__c = 'AllProducts_PL' limit 1];    
                ccrz.ccProductIndexBuilder.build(new Map<String,Object>{
                    ccrz.ccAPIProductIndex.LOCALES => new Set<String>{'en_US','en','en_CA'},
                        ccrz.ccAPIProductIndex.CLEAN_ONLY => TRUE,
                        ccrz.ccAPIProductIndex.MASTER_PRICE_LIST => pricelist[0].Id
                        });
        
 
          EC_ProductIndexBatchStatus__c batchStartTime = EC_ProductIndexBatchStatus__c.getOrgDefaults();
          Integer batchScheduleInterval = Integer.valueOf(batchStartTime.EC_Product_Index_Interval__c);
          batchStartTime.EC_Product_Index_Batch_Last_Run__c = System.now();
          upsert batchStartTime; 
            
         DateTime now = System.now().addMinutes(batchScheduleInterval);
            
            String dayVal = String.valueOf(now.day());
            String monthVal = String.valueOf(now.month());
            String hourVal = String.valueOf(now.hour());
            String minuteVal = String.valueOf(now.minute());
            String secondVal = String.valueOf(now.second());
            String yearVal = String.valueOf(now.year());
            String jobName = 'Product Index Job '+secondVal+minuteVal+hourVal+dayVal+monthVal+yearVal;
            String strSchedule = '0 ' + minuteVal + ' ' + hourVal + ' ' + dayVal + ' ' + monthVal + ' ?' + ' ' + yearVal;
            System.Schedule(jobName, strSchedule, new EC_TriggerProductIndexSchedulable());
            
 
      }
    
       
    }
    
}