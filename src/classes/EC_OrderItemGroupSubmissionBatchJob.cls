/* Class Name      : EC_OrderItemGroupSubmissionBatchJob
* Description      : Batch Class for order submit retry logic
* Created By       : Bharath Kn
* Created On       : 2020-Sept-03


* Modification Log:
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bharath Kn            2020-Sept-03         PBI-                  Created the class
*
*/
global class EC_OrderItemGroupSubmissionBatchJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{    
    global EC_OrderItemGroupService.ServiceResponse response;     
    global list<sObject> records;
    
    global EC_OrderItemGroupSubmissionBatchJob(){
        records = new list<sObject>();
    }    
    
    global Iterable<sObject> start(Database.BatchableContext BC){
    	String divisions = Label.EC_Nalco;
		List<String> divisionList = divisions.split(',');
		String divisionQuery = '\''+ String.join(divisionList,'\',\'')+'\'';  	
    	
        String query  = EC_OrderItemGroupService.getOrderItemGroupQuery();
        query += ' Where (Submission_Failure_Count__c < 5 or Submission_Failure_Count__c = null) and  Order_Item_Group_Status__c = \'Failed\' and ccrz__Order__r.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Division__c in ('+divisionQuery + ')'; 
        system.debug('start query: ' + query);
        records = Database.query(query);
        system.debug('EC_OrderItemGroupSubmissionBatchJob start: records ' + records);
        return records;
    }
  
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<ccrz__E_OrderItemGroup__c> orderItemGroups = ( list<ccrz__E_OrderItemGroup__c> ) scope;
        system.debug('EC_OrderItemGroupSubmissionBatchJob execute: records ' + orderItemGroups);
        if( orderItemGroups != null && !orderItemGroups.isEmpty() ){
            response = EC_OrderItemGroupService.processOrderItemGroups(orderItemGroups); 
        }        
    }

    global void finish(Database.BatchableContext BC){ 
        system.debug('EC_OrderItemGroupSubmissionBatchJob Finish: response ' + response);
        if (response != null && response.errors.size() > 0){ 
            system.debug('EC_OrderItemGroupSubmissionBatchJob Finish: records ' + response.orderItemGroups.values());  
            system.debug('number of errors: ' + response.errors.size());
        }
    }
    
}