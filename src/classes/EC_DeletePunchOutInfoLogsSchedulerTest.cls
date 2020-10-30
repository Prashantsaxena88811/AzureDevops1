/* Class Name      :EC_DeletePunchOutInfoLogsSchedulerTest
* Description      :TestClass for EC_DeletePunchOutInfoLogsSchedulerTest.
* Created By       :Raghav Sharma
* Created On       :01/08/2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Raghav Sharma          01/08/2020                                    TestClass for EC_DeletePunchOutInfoLogsSchedulerTest.
*
*/


@isTest
public class EC_DeletePunchOutInfoLogsSchedulerTest{

 public static testmethod void testPunchoutLogSchedulerBatch(){


 		EC_PunchOutInfo__c  punch = new  EC_PunchOutInfo__c();
        punch.EC_BuyerCookie__c = 'test123';
        punch.Name = 'Test';
        insert  punch;

        Test.startTest();
        EC_DeletePunchOutInfoLogsBatchScheduler sch = new EC_DeletePunchOutInfoLogsBatchScheduler();
        String CRON_EXP = '0 0 0 ? * 1#1 *';
 		String jobId = system.schedule('schedule job Test', CRON_EXP, sch);
        Test.stopTest();
      }
  }