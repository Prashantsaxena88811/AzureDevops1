public with sharing class EC_OrderItemGroupSchedulableBatch  implements Schedulable {
    Public void execute(SchedulableContext SC) {
        EC_OrderItemGroupSubmissionBatchJob varBatchClassInstance = new EC_OrderItemGroupSubmissionBatchJob();       
        Database.executeBatch(varBatchClassInstance,10);
    }
}