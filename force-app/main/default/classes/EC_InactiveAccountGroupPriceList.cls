/********************************************************************************************************
* @Class Name    EC_InactiveAccountGroupPriceList 
* @description   EC_InactiveAccountGroupPriceList is used to inactivate account group pricelist records based on configured lastModified Date
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 

global with sharing class EC_InactiveAccountGroupPriceList implements Database.Batchable<sObject>, Database.Stateful{
    
    private DateTime lastJobRunTime;
    private String accountGroupPriceListIds;
    private String accountGroupAllPL;
    private String priceListString;

/***************************************************************************************************************************************
      Constructor Name : EC_InactiveAccountGroupPriceList
      Description : Method is used to query and initialize the AG,PL,AGPL to be skipped for the current batch Job
      Return type : N/A
**************************************************************************************************************************************/
    global EC_InactiveAccountGroupPriceList(DateTime lastJobRunTime) {
        this.lastJobRunTime = lastJobRunTime;
        
        Date today = Date.today();
        Set<String> onlyAccountGroups = new Set<String>();
        Set<String> priceListSet = new Set<String>();
        Set<String> accGroupSet = new Set<String>();
        Set<String> accGroupPLset = new Set<String>();
        accountGroupAllPL = '';
        accountGroupPriceListIds = '';
        priceListString = '';
        // Get the AG/PL Ids to be skipped from custom metadata.
        List<String> accountGrpPriceListStr = new List<String>();
        for(exceptionConfig__mdt acg: [SELECT id,Account_Group__c,Active__c,PriceList__c,Start_Date__c,End_Date__c, DeveloperName FROM exceptionConfig__mdt 
                                       where Active__c = true AND Start_Date__c <= :today AND End_Date__c >= :today]){
            // Check if Both PriceList & account group are available.
            if(String.isNotBlank(acg.Account_Group__c) &&  String.isNotBlank(acg.PriceList__c)){
                accGroupSet.add(acg.Account_Group__c);
                accGroupPLset.add(acg.PriceList__c);
                accountGrpPriceListStr.add(acg.Account_Group__c+'|'+acg.PriceList__c);
                //Check if Account Group is available & PriceGroup is empty
            }else if(String.isNotBlank(acg.Account_Group__c) && String.isBlank(acg.PriceList__c) && !onlyAccountGroups.contains(acg.Account_Group__c)){
                onlyAccountGroups.add(acg.Account_Group__c); 
                accountGroupAllPL += '\'' +acg.Account_Group__c + '\',';
                // Check if Account group is empty & PriceGroup is available.
            }else if(String.isBlank(acg.Account_Group__c) && String.isNotBlank(acg.PriceList__c) && !priceListSet.contains(acg.PriceList__c)){
                priceListSet.add(acg.PriceList__c); 
                priceListString += '\'' +acg.PriceList__c + '\',';
            }
        }
        // Logic to Get all PL from AccountGroupPL set & AccountGroup Set created above. 
        if(!accGroupSet.isEmpty() && !accGroupPLset.isEmpty()){
            for(ccrz__E_AccountGroupPriceList__c agpL : [Select Id,ccrz__Pricelist__r.ccrz__PricelistId__c , ccrz__AccountGroup__r.ccrz__AccountGroupID__c , ccrz__AccountGroupPriceListID__c from ccrz__E_AccountGroupPriceList__c 
                                                         where ccrz__AccountGroup__r.ccrz__AccountGroupID__c  in :accGroupSet and ccrz__Pricelist__r.ccrz__PricelistId__c in :accGroupPLset])
            {
                String acountGrpPLStr = agpL.ccrz__AccountGroup__r.ccrz__AccountGroupID__c + '|'+ agpL.ccrz__Pricelist__r.ccrz__PricelistId__c;
                if(accountGrpPriceListStr.contains(acountGrpPLStr)){
                    accountGroupPriceListIds += '\'' + agpL.ccrz__AccountGroupPriceListID__c + '\',';
                }
            }
        }
        accountGroupAllPL = String.isNotBlank(accountGroupAllPL) ? accountGroupAllPL.removeEnd(','): '';
        accountGroupPriceListIds = String.isNotBlank(accountGroupPriceListIds) ? accountGroupPriceListIds.removeEnd(',') : '';
        priceListString = String.isNotBlank(priceListString) ? priceListString.removeEnd(',') : '';
    }
  
   /***************************************************************************************************************************************
      Method Name : start
      Description : start method is used to query the records to be processed in the batch
      Return type : Database.QueryLocator
     **************************************************************************************************************************************/
     
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String formattedEndDate = lastJobRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        String query = 'Select id,ccrz__Enable__c from ccrz__E_AccountGroupPriceList__c where lastModifiedDate <='+formattedEndDate;
        // Add an extra condition to the query to skip if AGPL is available.
        if(!String.isBlank(accountGroupPriceListIds)){
            query = query + ' AND ccrz__AccountGroupPriceListID__c not in ('+ accountGroupPriceListIds + ')';    
        }
        // Add an extra condition in query to skip if AG is available.
        if(!String.isBlank(accountGroupAllPL)){
            query = query + ' AND ccrz__AccountGroup__r.ccrz__AccountGroupID__c not in ('+ accountGroupAllPL + ')';    
        }
        // Add an extra condition in query to skip if PL is available.
        if(!String.isBlank(priceListString)){
            query = query + ' AND ccrz__Pricelist__r.ccrz__PricelistId__c not in ('+ priceListString + ')';    
        }
        system.debug('AccountGroupPL query-- '+query);
        return Database.getQueryLocator(query);
    }
    
    /***************************************************************************************************************************************
      Method Name : execute
      Description : execute method is used to inactive the given account group pricelist records
      Return type : void
     **************************************************************************************************************************************/
       
    
    global void execute(Database.BatchableContext BC, List<ccrz__E_AccountGroupPriceList__c> scope) {
        
        
      EC_ProductIndexBatchStatus__c indexBatchCS  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
      
        if(indexBatchCS.EC_InActive_AccountGroupPriceList_Batch__c == true){
            
            List<ccrz__E_AccountGroupPriceList__c> accGrpPlList = new List<ccrz__E_AccountGroupPriceList__c>();
            
            for(ccrz__E_AccountGroupPriceList__c acGrpPL : scope){
              
               acGrpPL.ccrz__Enable__c = false;
               accGrpPlList.add(acGrpPL);
            
            }
    
            update accGrpPlList;
    
        }

    }
    
    
     /***************************************************************************************************************************************
      Method Name : finish
      Description : finish method is used to trigger inactive product media job
      Return type : void
     **************************************************************************************************************************************/
          
    
    global void finish(Database.BatchableContext BC) {
        
        EC_InactiveProductMediaBatch inactiveMediaBatchJob = new EC_InactiveProductMediaBatch(lastJobRunTime);
        
        Database.executeBatch(inactiveMediaBatchJob);
        
    }
}