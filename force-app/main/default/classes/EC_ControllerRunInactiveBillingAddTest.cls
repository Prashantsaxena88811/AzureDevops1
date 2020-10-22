/********************************************************************************************************
* @Class Name    EC_ControllerRunInactiveBillingAddTest  
* @description   EC_ControllerRunInactiveBillingAddTest is used to test functionality of EC_ControllerRunInactiveBillingAddress
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
public class EC_ControllerRunInactiveBillingAddTest {
    
      
    /***************************************************************************************************************************************
      Method Name : runInactiveBillingAddTest
      Description : This method is used to test billing address job for first entry
      Return type : void
     **************************************************************************************************************************************/
          
    
    @isTest
    private static void runInactiveBillingAddTest(){
        EC_TestData.setupTestUser();
         User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' limit 1];
         System.runas(thisUser){
         
         List<EC_InformaticaAuditTable__c> records = new List<EC_InformaticaAuditTable__c>();
         EC_InformaticaAuditTable__c record = new EC_InformaticaAuditTable__c();
         record.EC_JobEndTime__c = System.now().addDays(2);
         record.Name = 'record';
         //record.EC_JobName__c = 'INFORMATICA LOADS COMPLETED FOR BILLING ADDRESS INACTIVATION'; 
         record.EC_JobName__c = Label.EC_Run_BillingAddress_JobName;
         record.EC_JobStartTime__c = System.now();
         records.add(record);
         Database.insert(records);
        
        EC_ProductIndexBatchStatus__c indexBatch = new EC_ProductIndexBatchStatus__c();
        indexBatch.EC_Inactive_Billing_Address_Flag__c = true;
        indexBatch.EC_Category_Batch_Schedule_Interval__c = 15;
        insert indexBatch;
        EC_TestData.setupCatalog();             
         Test.startTest();
        EC_ControllerRunInactiveBillingAddress.runInactiveBillingAdd(); 
        Test.stopTest();
             
         }
    }
    
    
    /***************************************************************************************************************************************
      Method Name : runInactiveBillingAddTest_multiple
      Description : This method is used to test billing address job for mutiple entry
      Return type : void
     **************************************************************************************************************************************/
       
    
    @isTest
    private static void runInactiveBillingAddTest_multiple(){
        EC_TestData.setupTestUser();
         User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' limit 1];
         System.runas(thisUser){
         
         List<EC_InformaticaAuditTable__c> records = new List<EC_InformaticaAuditTable__c>();
         EC_InformaticaAuditTable__c record = new EC_InformaticaAuditTable__c();
        record.EC_JobEndTime__c = System.now().addDays(2);
        record.Name = 'record';
        //record.EC_JobName__c = 'INFORMATICA LOADS COMPLETED FOR BILLING ADDRESS INACTIVATION'; 
           record.EC_JobName__c = Label.EC_Run_BillingAddress_JobName;
        record.EC_JobStartTime__c = System.now();
        records.add(record);
             
        EC_InformaticaAuditTable__c record2 = new EC_InformaticaAuditTable__c();
        record2.EC_JobEndTime__c = System.now().addDays(2);
        record2.Name = 'record2';
        //record.EC_JobName__c = 'INFORMATICA LOADS COMPLETED FOR BILLING ADDRESS INACTIVATION'; 
        record2.EC_JobName__c = Label.EC_Run_BillingAddress_JobName;
        record2.EC_JobStartTime__c = System.now();
        records.add(record2);
        Database.insert(records);
        
        EC_ProductIndexBatchStatus__c indexBatch = new EC_ProductIndexBatchStatus__c();
        indexBatch.EC_Inactive_Billing_Address_Flag__c = true;
        indexBatch.EC_Category_Batch_Schedule_Interval__c = 15;
        insert indexBatch;
        EC_TestData.setupCatalog();             
         Test.startTest();
        EC_ControllerRunInactiveBillingAddress.runInactiveBillingAdd(); 
        Test.stopTest();
             
         }
    }
}