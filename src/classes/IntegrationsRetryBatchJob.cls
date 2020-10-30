/********************************************************************************************************
* @Class Name    IntegrationsRetryBatchJob 
* @description   IntegrationsRetryBatchJob is used 
* @Created By -  
* @Created On -  
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 *                                                    Initial version
 *********************************************************************************************************/ 

global class IntegrationsRetryBatchJob implements Database.Batchable<sObject>, Database.AllowsCallouts {       
    Integer globalRetryLimit = 5;
    Integer serviceRequestRetryLimit = 3;

    global Database.QueryLocator start(Database.BatchableContext BC){
         Integration_Settings__mdt[] intSettingMdtList = [Select Integration_Type__c, Retry_Limit__c from Integration_Settings__mdt ];
    	for(Integration_Settings__mdt intSettingMdt: intSettingMdtList){
        	if(intSettingMdt.Integration_Type__c == 'Service Request' && intSettingMdt.Retry_Limit__c != null)
            	serviceRequestRetryLimit = intSettingMdt.Retry_Limit__c.intValue() ;
        	if(intSettingMdt.Integration_Type__c == 'global' && intSettingMdt.Retry_Limit__c != null)
            	globalRetryLimit = intSettingMdt.Retry_Limit__c.intValue() ;
    	}
        System.debug(serviceRequestRetryLimit + '/' + globalRetryLimit);
        String query = 'Select Id, Identifier__c, Integration_Component__c, Integration_Type__c, Retry_Counter__c, Retry_Batch_Class__c from Integration_Log__c where Status__c != \'true\' and Retry_Counter__c < ' + globalRetryLimit;  
        system.debug('start query: ' + query);      
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext BC, List<Integration_Log__c> integrationsList){
        List<Id> ids = new List<Id>();
        List<String> caseNoList = new List<String>();
        for(Integration_Log__c integrationEntry : integrationsList){
            if(integrationEntry.Integration_Component__c == 'Service Request' && integrationEntry.Integration_Type__c == 'SFDC_To_TIBCO' && 
                integrationEntry.Retry_Counter__c < serviceRequestRetryLimit){
                caseNoList.add(integrationEntry.identifier__c);
            }
        }  
        if(caseNoList.size() > 0){
            List<Case> caseIns = new List<Case> ([Select id from case where caseNumber in :caseNoList]);
            if(caseIns.size()>0){
                for(Case caseRec: caseIns){
                    ids.add(caseRec.id);
                }
            }
            EC_CaseTriggerHandler.retryServiceRequestSubmit(ids); 
        } 
    }
    
     /***************************************************************************************************************************************
      Method Name : finish
      Description : finish method is used to log failed order information
      Return type : void
     **************************************************************************************************************************************/
   

    global void finish(Database.BatchableContext BC){ 
        system.debug('IntegrationsRetryBatchJob Finish: response ');     
    }
}