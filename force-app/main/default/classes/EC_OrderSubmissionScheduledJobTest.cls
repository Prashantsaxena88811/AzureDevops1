/********************************************************************************************************
* @Class Name    EC_OrderSubmissionScheduledJobTest 
* @description   Test Class for EC_OrderSubmissionScheduledJob
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 

@isTest
public class EC_OrderSubmissionScheduledJobTest {

  /***************************************************************************************************************************************
      Method Name : testPositive
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
   
        
    public static testmethod void testPositive(){
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        EC_OrderSubmissionScheduledJob sch = new EC_OrderSubmissionScheduledJob();
        String jobId = system.schedule('schedule job Test', CRON_EXP, sch);
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        Test.stopTest();

        System.assertEquals(0, ct.TimesTriggered);
        
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime)); 
    }

                  

}