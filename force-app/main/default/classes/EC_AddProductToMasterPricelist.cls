/********************************************************************************************************
* @Class Name    EC_AddProductToMasterPricelist 
* @description   EC_AddProductToMasterPricelist is used to master pricelist for new products
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 

global with sharing class EC_AddProductToMasterPricelist implements Database.Batchable<sObject>, Database.Stateful {
    
    EC_ProductIndexBatchStatus__c indexBatchCS  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
    
     /***************************************************************************************************************************************
      Method Name : start
      Description : start method is used to query the records to be processed in the batch
      Return type : Database.QueryLocator
     **************************************************************************************************************************************/
     
    global Database.QueryLocator start(Database.BatchableContext BC) {
       String productList = 'Select ID,ccrz__SKU__c FROM ccrz__E_Product__c Where ccrz__ProductStatus__c!= \'In Creation\' AND ID NOT IN ( Select ccrz__Product__c from ccrz__E_PriceListItem__c WHERE ccrz__PriceList__r.Name =\'AllProducts_PL\')';
      return Database.getQueryLocator(productList);
    }
    
    /***************************************************************************************************************************************
      Method Name : execute
      Description : execute method is used to create pricelist for the given products
      Return type : void
     **************************************************************************************************************************************/
           
    global void execute(Database.BatchableContext BC, List<ccrz__E_Product__c> scope) {
              
        if(indexBatchCS.EC_Add_Product_to_Master_Pricelist_Batch__c == true){       
            List<ccrz__E_PriceListItem__c> pliList = new List<ccrz__E_PriceListItem__c>();
            List<ccrz__E_PriceList__c> pricelist = [Select id from ccrz__E_PriceList__c where ccrz__PricelistId__c = 'AllProducts_PL' limit 1]; 
            try{
                for(ccrz__E_Product__c prod : scope)
                {
                    ccrz__E_PriceListItem__c pli = new ccrz__E_PriceListItem__c();
                    pli.ccrz__Product__c =  prod.id;
                    pli.ccrz__Price__c = 0.0;
                    pli.ccrz__Pricelist__c = pricelist[0].id;
                    pli.ccrz__StartDate__c = System.today()-10;
                    pliList.add(pli);
                }
            if(pliList.size()>0){   
                insert pliList;
            }
           }
          catch(Exception ex){
                    system.debug('Exception ex ' + ex.getMessage()); 
            }       
        }
        
    }
    
     /***************************************************************************************************************************************
      Method Name : finish
      Description : finish method is used to trigger product index job
      Return type : void
     **************************************************************************************************************************************/
          
    global void finish(Database.BatchableContext BC){
        
         if(indexBatchCS.EC_Product_Index_Switch__c == true){
            
            DateTime now = System.now().addMinutes(1);
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