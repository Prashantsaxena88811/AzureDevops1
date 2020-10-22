/********************************************************************************************************
* @Class Name    EC_ControllerTriggerCCIndexesTest 
* @description   EC_ControllerTriggerCCIndexesTest is used to test functionality of EC_ControllerTriggerCCIndexes
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 

@isTest
public class EC_ControllerTriggerCCIndexesTest {


/***************************************************************************************************************************************
      Method Name : runCCBatchesTest
      Description : runCCBatchesTest method is used to test functionality of runCCBatches method
      Return type : void
     **************************************************************************************************************************************/
     

    
    @isTest
    private static void runCCBatchesTest(){
           
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
        indexBatch.EC_InActive_ProductCategroy_Batch__c = true;
        indexBatch.EC_Product_Index_Switch__c=true;
        indexBatch.EC_Spec_Index_Switch__c = true;
        indexBatch.EC_Category_Batch_Schedule_Interval__c = 15;
        indexBatch.EC_Product_Index_Interval__c = 5;
        indexBatch.EC_Product_Sequence_Index__c=true;
        insert indexBatch;
        
        EC_TestData.setupCatalog();     
       ccrz__E_PriceList__c priceList = [select id,EC_Price_List_Type__c from ccrz__E_PriceList__c limit 1];
       priceList.EC_Price_List_Type__c = 'SBA';
        update priceList;
             
         
         Test.startTest();
        EC_ControllerTriggerCCIndexes.runCCBatches(); 
        Test.stopTest();
             
         }
    }
}