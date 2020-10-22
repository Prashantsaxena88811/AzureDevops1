/********************************************************************************************************
* @Class Name    EC_OrderSubmissionBatchJob 
* @description   EC_OrderSubmissionBatchJob is used to submit failed orders to resubmit to Tibco
* @Created By -  Ravindra Singh  
* @Created On -  2019-8-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-8-25                                    Initial version
 *********************************************************************************************************/ 

global class EC_OrderSubmissionBatchJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{    
    global EC_OrderService.ServiceResponse response;     
    global list<sObject> records;
    
    global EC_OrderSubmissionBatchJob(){
        records = new list<sObject>();
    }    
    
   /***************************************************************************************************************************************
      Method Name : start
      Description : start method is used to query the records to be processed in the batch
      Return type : Database.QueryLocator
     **************************************************************************************************************************************/
  
    global Iterable<sObject> start(Database.BatchableContext BC){
        String divisions = Label.EC_OrderSubmissionDivision;
        List<String> divisionList = divisions.split(',');
        String divisionQuery = '\''+ String.join(divisionList,'\',\'')+'\'';    
        
        String query  = EC_OrderService.getOrderQuery();
        query += ' Where (EC_Submission_Failure_Count__c < 5 or EC_Submission_Failure_Count__c = null) and  ccrz__OrderStatus__c = \'Failed\' and ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Division__c in ('+divisionQuery + ')'; 
        system.debug('start query: ' + query);
        records = Database.query(query);
        system.debug('EC_OrderSubmissionBatchJob start: records ' + records);
        return records;
    }
    
     /***************************************************************************************************************************************
      Method Name : execute
      Description : execute method is used to submit given orders to Tibco
      Return type : void
     **************************************************************************************************************************************/
   
  
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<ccrz__E_Order__c> orders = ( list<ccrz__E_Order__c> ) scope;
        system.debug('EC_OrderSubmissionBatchJob execute: records ' + orders);
        if( orders != null && !orders.isEmpty() ){
            response = EC_OrderService.processOrders(orders); 
        }        
    }
    
     /***************************************************************************************************************************************
      Method Name : finish
      Description : finish method is used to log failed order information
      Return type : void
     **************************************************************************************************************************************/
   

    global void finish(Database.BatchableContext BC){ 
        system.debug('EC_OrderSubmissionBatchJob Finish: response ' + response);
      
        if (response != null && response.errors.size() > 0){ 
            system.debug('EC_OrderSubmissionBatchJob Finish: records ' + response.orders.values());  
            system.debug('number of errors: ' + response.errors.size());
        }
      
       
    }
}