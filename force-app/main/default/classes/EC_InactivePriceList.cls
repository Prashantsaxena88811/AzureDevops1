/********************************************************************************************************
* @Class Name    EC_InactivePriceList 
* @description   EC_InactivePriceList is used to inactive the price list records based on configured end date
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 


global with sharing class EC_InactivePriceList implements Database.Batchable<sObject>, Database.Stateful{
    
    private DateTime lastJobRunTime;
    private Set<String> ccrzPricelistSet = new Set<String>();
    private String exceptionPriceList;

/***************************************************************************************************************************************
      Constructor Name : EC_InactivePriceList
      Description : Method is used to query and initialize PL to be skipped for the current batch Job
      Return type : N/A
**************************************************************************************************************************************/
     
    global EC_InactivePriceList(DateTime lastJobRunTime) {
        this.lastJobRunTime = lastJobRunTime;
        Date today = Date.today();
        exceptionPriceList = '';
        // Get the AG/PL Ids to be skipped from custom metadata.
        for(exceptionConfig__mdt acg: [SELECT id,Account_Group__c,PriceList__c,Active__c,Start_Date__c,End_Date__c,  DeveloperName FROM exceptionConfig__mdt
                                       Where PriceList__c != null and Active__c = true AND Start_Date__c <= :today AND End_Date__c >= :today]){
                                           if(!this.ccrzPricelistSet.contains(acg.PriceList__c)){
                                               this.ccrzPricelistSet.add(acg.PriceList__c);
                                               exceptionPriceList += '\''+ acg.PriceList__c + '\',';
                                           }
                                       }
        exceptionPriceList = String.isNotBlank(exceptionPriceList) ? exceptionPriceList.removeEnd(',') : '';
    }
    
      /***************************************************************************************************************************************
      Method Name : start
      Description : start method is used to query the records to be processed in the batch
      Return type : Database.QueryLocator
     **************************************************************************************************************************************/
     
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
       String pricelistType = Label.EC_InactivePriceListType;
       String pricelistSequence = Label.EC_InactivePLSequence;
       List<String> pricelistTypeList = pricelistType.split(',');
       String pricelistTypeQuery = '\''+ String.join(pricelistTypeList,'\',\'')+'\'';
        
        String formattedEndDate = lastJobRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');        
        String query = 'SELECT id,ccrz__Enabled__c,lastModifiedDate FROM ccrz__E_PriceList__c where ccrz__Enabled__c=true and EC_Price_List_Type__c in ('+pricelistTypeQuery +')  and  ccrz__PricelistId__c != \'AllProducts_PL\' and lastModifiedDate <='+formattedEndDate+' AND id in (select ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c where ccrz__Sequence__c in ('+pricelistSequence+'))';
         
         System.debug('exceptionPriceList:'+exceptionPriceList);
         // Add an extra condition in query to skip if PL is available.
         if(!String.isBlank(exceptionPriceList)){
            query = query + ' AND ccrz__PricelistId__c not in (' + exceptionPriceList + ')';
        }
        system.debug('PriceList query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ccrz__E_PriceList__c> scope) {
        
        EC_ProductIndexBatchStatus__c indexBatchCS  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
      
        if(indexBatchCS.EC_InActive_PriceList_Batch__c == true){
            
             List<ccrz__E_PriceList__c> PlList = new List<ccrz__E_PriceList__c>();
            
            for(ccrz__E_PriceList__c pl : scope){
              
               pl.ccrz__Enabled__c = false;
               PlList.add(pl);
            
            }
    
            update PlList;

        }    
    }
    
    /***************************************************************************************************************************************
      Method Name : finish
      Description : finish method is used to trigger Inactive AccountGroupPriceList job
      Return type : void
     **************************************************************************************************************************************/
  
    
    global void finish(Database.BatchableContext BC) {
        
        EC_InactiveAccountGroupPriceList inactiveAccountGroupPriceListBatchJob = new EC_InactiveAccountGroupPriceList(lastJobRunTime);
        
        Database.executeBatch(inactiveAccountGroupPriceListBatchJob);
        
    }
}