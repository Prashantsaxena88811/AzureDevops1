/********************************************************************************************************
* @Class Name    EC_ControllerRunInactiveBillingAddress 
* @description   EC_ControllerRunInactiveBillingAddress is used to invoke inactive billing address job when audit entry is created after data load
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 
global with sharing class EC_ControllerRunInactiveBillingAddress {

   /***************************************************************************************************************************************
      Method Name : runInactiveBillingAdd
      Description : runInactiveBillingAdd method is used to trigger inactive billing address job based on custom setting flag
      Return type : void
     **************************************************************************************************************************************/   
    
 @InvocableMethod(label='Run-inactiveBillingAddress')
    global static void runInactiveBillingAdd(){
        
        EC_ProductIndexBatchStatus__c indexBatchCS  = EC_ProductIndexBatchStatus__c.getOrgDefaults();
        
        String indexBatchJobName = Label.EC_Run_BillingAddress_JobName;

        List<EC_InformaticaAuditTable__c> informaticaJobInfo = [SELECT EC_IndexBatchRan__c,EC_JobStartTime__c,EC_JobEndTime__c,EC_JobName__c FROM EC_InformaticaAuditTable__c Where EC_JobName__c = :indexBatchJobName order by EC_JobEndTime__c desc limit 2];

        DateTime startTime = null;
        
        if(informaticaJobInfo.size()>1){
            
             startTime = informaticaJobInfo[1].EC_JobEndTime__c;            
            
        }else{
            
            startTime = informaticaJobInfo[0].EC_JobEndTime__c;
            startTime = startTime.addDays(-1);
            
        }       
        if(startTime != null && indexBatchCS.EC_Inactive_Billing_Address_Flag__c == true){
            runInactiveBillingAddressJob(startTime);    
        }
        
    }
    
    @TestVisible
    private static void runInactiveBillingAddressJob(DateTime jobStartTime){        
        
        EC_InactiveAccountAddressbookBatch inactiveBillingAddrJob = new EC_InactiveAccountAddressbookBatch(jobStartTime);
        
        Database.executeBatch(inactiveBillingAddrJob);
                                                                                      
    }
    
}