//EC_StagingHelper
//This is class to handle all the staging scheduler events
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     This is class to handle all the staging scheduler events
//

global class EC_StagingBatchScheduler implements Schedulable{
    global void execute(SchedulableContext ctx){
        EC_StagingBatch b = new EC_StagingBatch();
        Database.executeBatch(b,100);
    }
}