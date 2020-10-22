//EC_DeleteStagingLogsBatchScheduler
//Scheduler class for  EC_DeleteStagingLogsBatch class.
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Mishika Mahajan    12/16/2019     Scheduler class for  EC_DeleteStagingLogsBatch class.
//
global class EC_DeleteStagingLogsBatchScheduler implements Schedulable{
    global void execute(SchedulableContext ctx){
        EC_DeleteStagingLogsBatch deleteLogBatch = new EC_DeleteStagingLogsBatch();
        Database.executeBatch(deleteLogBatch,2000);
    }
}