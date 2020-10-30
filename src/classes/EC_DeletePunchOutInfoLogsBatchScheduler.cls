/* Class Name      :EC_DeletePunchOutInfoLogsBatchScheduler
* Description      :TestClass for EC_DeletePunchOutInfoLogsBatchScheduler.
* Created By       :Raghav Sharma
* Created On       :01/08/2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Raghav Sharma          01/08/2020                                    TestClass for EC_DeletePunchOutInfoLogsBatchScheduler.
*
*/
global class EC_DeletePunchOutInfoLogsBatchScheduler implements Schedulable{
    global void execute(SchedulableContext ctx){
        EC_DeletePunchOutInfoLogsBatch deleteLogBatch = new EC_DeletePunchOutInfoLogsBatch();
        Database.executeBatch(deleteLogBatch,2000);
    }
}