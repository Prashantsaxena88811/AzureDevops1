/********************************************************************************************************
* @Class Name    EC_TriggerProductIndexSchedulable 
* @description   EC_TriggerProductIndexSchedulable is used to schedule product index batch job
* @Created By -  Ravindra Singh  
* @Created On -  2019-11-27
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-11-27                                    Initial version
 *********************************************************************************************************/ 
global class EC_TriggerProductIndexSchedulable implements Schedulable {
    
    public static String CRON_EXP;
    public EC_ProductIndexBatchStatus__c batchStartTime ;
    
    global EC_TriggerProductIndexSchedulable(){      
    }
    
    /***************************************************************************************************************************************
      Method Name : execute
      Description : This method is used to schedule product index job.
      Return type : void
     **************************************************************************************************************************************/
     
    
    global void execute(SchedulableContext SC) {  
        batchStartTime  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
        Integer batchScheduleInterval = Integer.valueOf(batchStartTime.EC_Product_Index_Interval__c);
        //DateTime firstCleanUpJobStartTime =  batchStartTime.EC_Product_Index_Batch_Last_Run__c;
        //DateTime specJobStartTime =  batchStartTime.Index_Batch_Start_Time__c;
        List<AsyncApexJob> oldJobStatus = new List<AsyncApexJob>();

        if (!AsyncApexJob.sObjectType.getDescribe().isAccessible()) { 
            return;
        }
        
        oldJobStatus  =  [SELECT CreatedBy.Name, ApexClassId, ApexClass.Name, CompletedDate, CreatedById, CreatedDate, Id, toLabel(JobType), NumberOfErrors, Status, TotalJobItems 
                                         FROM AsyncApexJob Where ApexClass.Name IN ('ccProductIndexCleanupJob','ccProductIndexBuildJob2','cc_job_LoadProductSpecIndex','ccProductIndexDisableOldJob') AND Status NOT IN ('Completed','Failed','Aborted') Order By CreatedDate];
        List<ccrz__E_Product__c> pendingProductList = [Select ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductStatus__c, ccrz__ProductIndexStatus__c FROM ccrz__E_Product__c WHERE ccrz__ProductIndexStatus__c in ('Pending','Not Current') AND ccrz__ProductStatus__c in ('Released','Not Orderable') AND ccrz__EndDate__c > Today AND id in (Select ccrz__Product__c from ccrz__E_PriceListItem__c WHERE ccrz__PriceList__r.ccrz__pricelistId__c ='AllProducts_PL')];
        if(oldJobStatus.size() <= 0 && pendingProductList.size() > 0){        
            Database.executebatch(new EC_TriggerProductIndex());          
        }else{
            DateTime now = System.now().addMinutes(batchScheduleInterval);
            String dayVal = String.valueOf(now.day());
            String monthVal = String.valueOf(now.month());
            String hourVal = String.valueOf(now.hour());
            String minuteVal = String.valueOf(now.minute());
            String secondVal = String.valueOf(now.second());
            String yearVal = String.valueOf(now.year());
            String jobName = 'Product Index Job '+secondVal+minuteVal+hourVal+dayVal+monthVal+yearVal;
            String strSchedule = '0 ' + minuteVal + ' ' + hourVal + ' ' + dayVal + ' ' + monthVal + ' ?' + ' ' + yearVal;
            if (pendingProductList.size() > 0) {
                System.Schedule(jobName, strSchedule, new EC_TriggerProductIndexSchedulable());
            }
        }
   }
}