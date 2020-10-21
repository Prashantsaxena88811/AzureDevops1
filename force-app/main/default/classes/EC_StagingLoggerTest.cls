@isTest
public class EC_StagingLoggerTest {
    @istest
    
    public static void stageLogExceptionTest(){
        List<EC_StagingExceptionLog__c> stageExcepLogList = new List<EC_StagingExceptionLog__c>();
        EC_StagingExceptionLog__c stageExcepLog = EC_StagingLogger.logException(null,'1123','6788','user_account','InsertAction',null, null,null, null,null,'test Exception','EC_StagingLoggerTest','stageLogExceptionTest');
        stageExcepLogList.add(stageExcepLog);
        EC_StagingLogger.stageLogException(stageExcepLogList);
    }

}