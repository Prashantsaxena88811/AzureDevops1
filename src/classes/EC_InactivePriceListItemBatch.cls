/********************************************************************************************************
* @Class Name    EC_InactivePriceListItemBatch 
* @description   EC_InactivePriceListItemBatch is used to inactive the price list item records based on configured end date
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 


global with sharing class EC_InactivePriceListItemBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private DateTime lastJobRunTime;
    private Set<String> ccrzPricelistSet = new Set<String>();
    private String exceptionPriceList;

/***************************************************************************************************************************************
      Constructor Name : EC_InactivePriceListItemBatch
      Description : Method is used to query and initialize the PL to be skipped for the current batch Job
      Return type : N/A
**************************************************************************************************************************************/    
    global EC_InactivePriceListItemBatch(DateTime lastJobRunTime) {
        this.lastJobRunTime = lastJobRunTime;
        Date today = Date.today();
        // Get the AG/PL Ids to be skipped from custom metadata.
        List<exceptionConfig__mdt> exceptionConfig = [SELECT id,Account_Group__c,PriceList__c,Active__c,Start_Date__c,End_Date__c, DeveloperName FROM exceptionConfig__mdt Where PriceList__c != null and Active__c = true AND Start_Date__c <= :today AND End_Date__c >= :today];
        if(!exceptionConfig.isEmpty()){
            exceptionPriceList = '';
            for(exceptionConfig__mdt acg: exceptionConfig){
                if(!this.ccrzPricelistSet.contains(acg.PriceList__c)){
                    this.ccrzPricelistSet.add(acg.PriceList__c);    
                    exceptionPriceList += '\''+ acg.PriceList__c + '\',';
                }
            }
            exceptionPriceList = String.isNotBlank(exceptionPriceList) ? exceptionPriceList.removeEnd(',') : '';
        }
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
        
        String query = 'Select id,ccrz__EndDate__c,lastModifiedDate from ccrz__E_PriceListItem__c where lastModifiedDate <='+formattedEndDate+' and ccrz__Pricelist__r.EC_Price_List_Type__c in ('+pricelistTypeQuery +')  and ccrz__EndDate__c >= Today and ccrz__Pricelist__c in (select ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c where ccrz__Sequence__c in ('+pricelistSequence+'))';
        
        System.debug('exceptionPriceList:'+exceptionPriceList);
        // Add an extra condition in query to skip if PL is available.
        if(!String.isBlank(exceptionPriceList)){
            query = query + ' AND ccrz__Pricelist__r.ccrz__PricelistId__c not in (' + exceptionPriceList + ')';
        }
        
        System.debug('PriceListItem query:'+query);
        return Database.getQueryLocator(query);
    }
    
   global void execute(Database.BatchableContext BC, List<ccrz__E_PriceListItem__c> scope) {
    
      EC_ProductIndexBatchStatus__c indexBatchCS  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
        
        if(indexBatchCS.EC_InActive_PriceListItem_Batch__c == true){
            
            
            List<ccrz__E_PriceListItem__c> priceListItemList = new List<ccrz__E_PriceListItem__c>();
            
            for(ccrz__E_PriceListItem__c pli : scope){
                
                pli.ccrz__EndDate__c = System.today()-1;
                
                priceListItemList.add(pli);
                
            }
            
            update priceListItemList;
        }
    
   }
    
       /***************************************************************************************************************************************
      Method Name : finish
      Description : finish method is used to trigger inactive pricelist batch job
      Return type : void
     **************************************************************************************************************************************/
  
    
    global void finish(Database.BatchableContext BC) {
        
        EC_InactivePriceList inactivePriceListBatchJob = new EC_InactivePriceList(lastJobRunTime);
        
        Database.executeBatch(inactivePriceListBatchJob);
      
    }
}