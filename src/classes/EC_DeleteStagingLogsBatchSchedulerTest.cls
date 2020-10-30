/* Class Name      :EC_DeleteStagingLogsBatchTest
* Description      :TestClass for EC_DeleteStagingLogsBatchScheduler.
* Created By       :Mishika Mahajan
* Created On       :12-16-2019   
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          12-16-2019                                    TestClass for EC_DeleteStagingLogsBatchScheduler.
* 
*/


@isTest
public class EC_DeleteStagingLogsBatchSchedulerTest{

 public static testmethod void testStagingLogSchedulerBatch(){
 		
 
 		EC_StagingExceptionLog__c  stageLog = new  EC_StagingExceptionLog__c();
     	stageLog.EC_ClassName__c ='EC_DeleteStagingLogsBatchTest';
     	stageLog.EC_MethodName__c = 'testStagingLogBatch';
     	stageLog.EC_ExceptionMessage__c ='Null pointer exception';
     	insert  stageLog; 
        
        Test.startTest();
        EC_DeleteStagingLogsBatchScheduler sch = new EC_DeleteStagingLogsBatchScheduler();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
 		String jobId = system.schedule('schedule job Test', CRON_EXP, sch);       
        Test.stopTest();
      }
  }