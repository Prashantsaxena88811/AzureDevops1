/********************************************************************************************************
* @Class Name    IntegrationRetryBatchScheduler
* @description   IntegrationRetryBatchScheduler is used to schedule IntegrationsRetryBatchJob
* @Created By -    
* @Created On -  
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Sunil Prasad             2020-04-20                                    Initial version
 *********************************************************************************************************/ 


global class IntegrationRetryBatchScheduler implements System.Schedulable {


   /***************************************************************************************************************************************
      Method Name : execute
      Description : execute method runs IntegrationsRetryBatchJob
      Return type : void
     **************************************************************************************************************************************/
    global void execute(System.SchedulableContext  sch){
        IntegrationsRetryBatchJob batchJob = new IntegrationsRetryBatchJob();
        //setting a batch job of one because off callout errors happening for a batch size more than one
        Database.executeBatch(batchJob, 1); 
    }
}