/********************************************************************************************************
* @Class Name    EC_ControllerTriggerCCIndexes 
* @description   EC_ControllerTriggerCCIndexes is used to trigger inactivation & indexing jobs after data load
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 

global with sharing class EC_ControllerTriggerCCIndexes {

    /***************************************************************************************************************************************
         Method Name : runCCBatches
         Description : runCCBatches method is used to run indexing & inactivation jobs
         Return type : void
        **************************************************************************************************************************************/
        
       @InvocableMethod(label='Run-ccBatches')
       global static void runCCBatches(){
           
           String indexBatchJobName = Label.EC_Run_Product_Index_JobName;
   
           List<EC_InformaticaAuditTable__c> informaticaJobInfo = [SELECT EC_IndexBatchRan__c,EC_JobStartTime__c,EC_JobEndTime__c,EC_JobName__c FROM EC_InformaticaAuditTable__c Where EC_JobName__c = :indexBatchJobName order by EC_JobEndTime__c desc limit 2];
   
           DateTime startTime = null;
           
           if(informaticaJobInfo.size()>1){
               
                startTime = informaticaJobInfo[1].EC_JobEndTime__c;            
               
           }else{
               
               startTime = informaticaJobInfo[0].EC_JobEndTime__c;
               startTime = startTime.addDays(-1);
               
           }
           
           System.debug('startTime-->'+startTime);
                  
           EC_ProductIndexBatchStatus__c indexBatchCS  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
   
           if(indexBatchCS.EC_Category_Index_Switch__c == true){
               runCategoryIndexJob();
           }
           
           if(indexBatchCS.EC_Spec_Index_Switch__c == true){
               runProductSpecIndexJob();    
           }

           if(startTime != null && indexBatchCS.EC_Product_Sequence_Index__c == true){
               runInactivePriceListItemJob(startTime);    
           }
          
       }
       
       /***************************************************************************************************************************************
         Method Name : runCategoryIndexJob
         Description : runCategoryIndexJob method is used to run category indexing job
         Return type : void
        **************************************************************************************************************************************/
        
       
        @TestVisible
        private static void runCategoryIndexJob(){
   
            DateTime now = System.now().addMinutes(15);
            
            String dayVal = String.valueOf(now.day());
            String monthVal = String.valueOf(now.month());
            String hourVal = String.valueOf(now.hour());
            String minuteVal = String.valueOf(now.minute());
            String secondVal = String.valueOf(now.second());
            String yearVal = String.valueOf(now.year());
            String strSchedule = '0 ' + minuteVal + ' ' + hourVal + ' ' + dayVal + ' ' + monthVal + ' ?' + ' ' + yearVal;
            String jobName = 'Category Index Job '+secondVal+minuteVal+hourVal+dayVal+monthVal+yearVal;
            System.Schedule(jobName, strSchedule, new EC_CreateCacheTreeBatchSchedulable());
        }
       
       /***************************************************************************************************************************************
         Method Name : runProductSpecIndexJob
         Description : runProductSpecIndexJob method is used to run product spec indexing job
         Return type : void
        **************************************************************************************************************************************/
        
       
       @TestVisible
       private static void runProductSpecIndexJob(){        
           ccrz.cc_job_LoadProductSpecIndex prodSpecJob  = new ccrz.cc_job_LoadProductSpecIndex('Select Id, ccrz__ParentProduct__c, ccrz__FilterData__c from ccrz__E_Product__c');
           Database.executeBatch(prodSpecJob);                                                                              
       }
       
       /***************************************************************************************************************************************
         Method Name : runInactivePriceListItemJob
         Description : This method is used to run product inactive pricelist item job
         Return type : void
        **************************************************************************************************************************************/
        
       
       @TestVisible
       private static void runInactivePriceListItemJob(DateTime jobStartTime){
           EC_ProductIndexBatchStatus__c batchStartTime = EC_ProductIndexBatchStatus__c.getOrgDefaults();
           batchStartTime.Index_Batch_Start_Time__c = System.now();
           upsert batchStartTime;                   
           EC_InactivePriceListItemBatch inactivePriceListBatchJob = new EC_InactivePriceListItemBatch(jobStartTime);  
           Database.executeBatch(inactivePriceListBatchJob);                                                                               
       }   
   }