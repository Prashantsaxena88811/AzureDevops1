/********************************************************************************************************
* @Class Name    IntegrationRetryBatchSchedulerTest 
* @description   Test Class for IntegrationRetryBatchScheduler
* @Created By -   
* @Created On -  
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 *  Sunil P                                               Initial version
 *********************************************************************************************************/ 

@isTest
public class IntegrationRetryBatchSchedulerTest {

  /***************************************************************************************************************************************
      Method Name : scheduleTestMethod
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
      
    public static testmethod void scheduleTestMethod(){
        Test.startTest();
        String CRON_EXP = '0 0 0 6 8 ? 2029';
        IntegrationRetryBatchScheduler sch = new IntegrationRetryBatchScheduler();
        String jobId = System.schedule('IntegrationRetryBatchScheduler_Test', CRON_EXP, sch);        
        CronTrigger ct = [SELECT Id, CronJobDetail.Name, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];       
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2029-08-06 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}