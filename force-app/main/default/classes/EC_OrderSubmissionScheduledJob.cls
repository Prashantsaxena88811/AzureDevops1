/********************************************************************************************************
* @Class Name    EC_OrderSubmissionScheduledJob
* @description   EC_OrderSubmissionScheduledJob is used to schedule EC_OrderSubmissionBatchJob
* @Created By -  Ravindra Singh  
* @Created On -  2019-8-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-8-25                                    Initial version
 *********************************************************************************************************/ 


global class EC_OrderSubmissionScheduledJob implements System.Schedulable {


   /***************************************************************************************************************************************
      Method Name : execute
      Description : execute method runs EC_OrderSubmissionBatchJob
      Return type : void
     **************************************************************************************************************************************/
     
     

    global void execute(System.SchedulableContext  sch){
            EC_OrderSubmissionBatchJob bJob = new EC_OrderSubmissionBatchJob();
            Database.executeBatch( bJob, 1); 
    }
}