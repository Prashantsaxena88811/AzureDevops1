@isTest
public class EC_OrderItemGroupSchedulableBatchTest {
    public static testmethod void test1(){
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        EC_OrderItemGroupSchedulableBatch sch = new EC_OrderItemGroupSchedulableBatch();
        String jobId = system.schedule('schedule job Test', CRON_EXP, sch);
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        Test.stopTest();

        System.assertEquals(0, ct.TimesTriggered);
        
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime)); 
    }

            
}