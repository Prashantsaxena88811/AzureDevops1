/********************************************************************************************************
* @Class Name    EC_InactiveProductMediaBatch 
* @description   EC_InactiveProductMediaBatch is used to inactive the product media records based on configured end date
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 


global with sharing class EC_InactiveProductMediaBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private DateTime lastJobRunTime;
    
    global EC_InactiveProductMediaBatch(DateTime lastJobRunTime) {
        this.lastJobRunTime = lastJobRunTime;
    } 
    
      /***************************************************************************************************************************************
      Method Name : start
      Description : start method is used to query the records to be processed in the batch
      Return type : Database.QueryLocator
     **************************************************************************************************************************************/
     
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
         String formattedEndDate = lastJobRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        String query = 'Select id,ccrz__Enabled__c from ccrz__E_ProductMedia__c where lastModifiedDate <= '+formattedEndDate +' and ccrz__Enabled__c = true';
        
        return Database.getQueryLocator(query);
        
    }
    
      /***************************************************************************************************************************************
      Method Name : execute
      Description : execute method is used to disable given product media records
      Return type : void
     **************************************************************************************************************************************/
       
    
    global void execute(Database.BatchableContext BC, List<ccrz__E_ProductMedia__c> scope) {
        
        EC_ProductIndexBatchStatus__c indexBatchCS  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
      
        if(indexBatchCS.EC_InActive_ProductMedia_Batch__c == true){
                    
            List<ccrz__E_ProductMedia__c> mediaList = new List<ccrz__E_ProductMedia__c>();
            
            for(ccrz__E_ProductMedia__c media : scope){
                
                media.ccrz__Enabled__c = false;
                
                mediaList.add(media);
                
                }
    
            update mediaList;   
        }
   
    }
    
   /***************************************************************************************************************************************
      Method Name : finish
      Description : finish method is used to addProductToMasterPriceList job
      Return type : void
     **************************************************************************************************************************************/
  
    
    global void finish(Database.BatchableContext BC) {
        
        EC_AddProductToMasterPricelist addProductToMasterPricelist = new EC_AddProductToMasterPricelist();
        
        Database.executeBatch(addProductToMasterPricelist);
        
    }
}