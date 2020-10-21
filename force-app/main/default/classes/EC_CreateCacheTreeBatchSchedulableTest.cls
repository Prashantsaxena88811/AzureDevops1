/* Class Name    : EC_CreateCacheTreeBatchSchedulableTest
 * Description      Test Class to cover EC_CreateCacheTreeBatchSchedulable
 * Created By       :Jitan Goyal 
 * Created On       :2019-8-5
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Jitan Goyal            2019-8-5          BC-74102            Created the class   
 *
 */
@isTest
public class EC_CreateCacheTreeBatchSchedulableTest{
/***************************************************************************************************************************************
  Method Name : testScheduleJob
  Description : Test method to cover EC_CreateCacheTreeBatchSchedulable class
  Return type : void
 *************************************************************************************************************************************/
    public static testMethod void testScheduleJob(){
       
      EC_TestData.setupTestUser();
         User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' limit 1];
         System.runas(thisUser){
         
         EC_InformaticaAuditTable__c record = new EC_InformaticaAuditTable__c();
        record.EC_JobEndTime__c = System.now().addDays(2);
        record.Name = 'record';
        record.EC_JobName__c = Label.EC_Run_Product_Index_JobName;
        record.EC_JobStartTime__c = System.now();
        insert record;
        
        EC_ProductIndexBatchStatus__c indexBatch = new EC_ProductIndexBatchStatus__c();
        indexBatch.EC_Category_Index_Switch__c = true;
        indexBatch.EC_InActive_AccountGroupPriceList_Batch__c = true;
        indexBatch.EC_InActive_PriceListItem_Batch__c = true;
        indexBatch.EC_InActive_PriceList_Batch__c = true;
        indexBatch.EC_InActive_ProductMedia_Batch__c=true;
        indexBatch.EC_Product_Index_Switch__c=true;
        indexBatch.EC_Spec_Index_Switch__c = true;
        indexBatch.EC_Category_Batch_Schedule_Interval__c = 15;
        insert indexBatch;
        EC_TestData.setupCatalog();  
        
      String sch = '0 59 * * * ?'; 
        // Schedule the test job
      Test.startTest();
      String jobId = System.schedule('EC_CreateCacheTreeBatch',sch,new EC_CreateCacheTreeBatchSchedulable());
      Test.stopTest();
		 // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime
         						FROM CronTrigger WHERE id = :jobId];
        
         System.assertEquals(sch, ct.CronExpression);

   }
  }
}