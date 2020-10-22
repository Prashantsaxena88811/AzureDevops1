/********************************************************************************************************
* @Class Name    EC_InactiveAccountAddressbookBatch 
* @description   This Batch class is used to deactivate account address book records based on Configured lastModifiedDate
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 
 
global with sharing class EC_InactiveAccountAddressbookBatch implements Database.Batchable<sObject>, Database.Stateful{
    
     private DateTime lastJobRunTime;
    
    global EC_InactiveAccountAddressbookBatch(DateTime lastJobRunTime) {
        this.lastJobRunTime = lastJobRunTime;
    } 
    
    /***************************************************************************************************************************************
      Method Name : start
      Description : start method is used to query the records to be processed in the batch
      Return type : Database.QueryLocator
     **************************************************************************************************************************************/
     

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
      String formattedEndDate = lastJobRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
      
      String query = 'SELECT Id,LastModifiedDate, ccrz__AddressType__c FROM ccrz__E_AccountAddressBook__c where lastModifiedDate <= '+formattedEndDate+' and ccrz__AddressType__c = \'billing\' and ccrz__AccountId__c != null';
      
      return Database.getQueryLocator(query);
    }
    
      /***************************************************************************************************************************************
      Method Name : execute
      Description : execute method is used to delete accountId for given account address book records
      Return type : void
     **************************************************************************************************************************************/
      
     global void execute(Database.BatchableContext BC, List<ccrz__E_AccountAddressBook__c> scope) {
        
        List<ccrz__E_AccountAddressBook__c> accountAddrBookList = new List<ccrz__E_AccountAddressBook__c>();
      
         System.debug('records-->'+scope);
        for(ccrz__E_AccountAddressBook__c addBook : scope){
   
            addBook.ccrz__AccountId__c = null;
            accountAddrBookList.add(addBook);

        }
        update accountAddrBookList; 
       
    
    }
    
     /***************************************************************************************************************************************
      Method Name : finish
      Description : Overriden method for batch class
      Return type : void
     **************************************************************************************************************************************/
      
    
      global void finish(Database.BatchableContext BC) {
      
    }
}