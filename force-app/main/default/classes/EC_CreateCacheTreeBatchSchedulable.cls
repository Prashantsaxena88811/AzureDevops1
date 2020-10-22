/* Class Name    : EC_CreateCacheTreeBatchSchedulable
 * Description      :Class used to schedule the EC_CreateCacheTreeBatch after every hour
 * Created By       :Jitan Goyal  
 * Created On       :08-05-2019

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Jitan Goyal             08-05-2019        BC-74102    Created the class   
 *
 */
global class EC_CreateCacheTreeBatchSchedulable implements Schedulable {
    
    public static String CRON_EXP;
    public EC_ProductIndexBatchStatus__c batchStartTime ;
    /***************************************************************************************************************************************
    Constructor Name : EC_CreateCacheTreeBatchSchedulable
    Description : N/A
    Return type : N/A
    *************************************************************************************************************************************/
    global EC_CreateCacheTreeBatchSchedulable(){      
    }
    /***************************************************************************************************************************************
    Method Name : execute
    Description : Schedules the PriceList Category Mapping Batch Job
    Return type : void
    *************************************************************************************************************************************/     
    global void execute(SchedulableContext SC) {
        /**Store Front**/
        String front = Label.EC_CategoryTreeStoreFront;
        
        /**Currency**/
        String curr= 'USD';
        
        /**Locale**/
        String locale ='en_US';
        
        /**Execute Batch**/
        //if product index complete execute this 
        
        
        
        batchStartTime  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
        Integer batchScheduleInterval = Integer.valueOf(batchStartTime.EC_Category_Batch_Schedule_Interval__c);
        DateTime firstCleanUpJobStartTime =  batchStartTime.Index_Batch_Start_Time__c;
        
        List<AsyncApexJob> lastCleanUpJobs = new List<AsyncApexJob>();
        
        if(!Test.isRunningTest()){
        
        lastCleanUpJobs  =  [SELECT CreatedBy.Name, ApexClassId, ApexClass.Name, CompletedDate, CreatedById, CreatedDate, Id, toLabel(JobType), NumberOfErrors, Status, TotalJobItems 
                                         FROM AsyncApexJob Where ApexClass.Name ='ccProductIndexCleanupJob' AND CreatedDate >: firstCleanUpJobStartTime  Order By CreatedDate DESC Limit 1];
        }else{
            
            lastCleanUpJobs = [SELECT ApexClassId,Status from AsyncApexJob Where Status = 'Completed' limit 1];
            
            
        }
        
        
        if(lastCleanUpJobs.size() > 0 && lastCleanUpJobs[0].Status == 'Completed'){
            EC_CreatePriceListCategoryMappingBatch allowedCatJob=new EC_CreatePriceListCategoryMappingBatch(front,curr,locale);
            Database.executebatch(allowedCatJob,50);    
        }else{
            
            DateTime now = System.now().addMinutes(batchScheduleInterval);
            
            String dayVal = String.valueOf(now.day());
            String monthVal = String.valueOf(now.month());
            String hourVal = String.valueOf(now.hour());
            String minuteVal = String.valueOf(now.minute());
            String secondVal = String.valueOf(now.second());
            String yearVal = String.valueOf(now.year());
            String jobName = 'Category Index Job '+secondVal+minuteVal+hourVal+dayVal+monthVal+yearVal;
            String strSchedule = '0 ' + minuteVal + ' ' + hourVal + ' ' + dayVal + ' ' + monthVal + ' ?' + ' ' + yearVal;
            System.Schedule(jobName, strSchedule, new EC_CreateCacheTreeBatchSchedulable());           
        }
   }
    
    
}