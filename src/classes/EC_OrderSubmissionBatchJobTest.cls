/********************************************************************************************************
* @Class Name    EC_OrderSubmissionBatchJobTest 
* @description   EC_OrderSubmissionBatchJobTest is used to test functionality of EC_OrderSubmissionBatchJob
* @Created By -  Ravindra Singh  
* @Created On -  2019-8-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-8-25                                    Initial version
 *********************************************************************************************************/ 


@isTest
public class EC_OrderSubmissionBatchJobTest {

  
   /***************************************************************************************************************************************
      Method Name : testBatchWithException
      Description : This method is used to test exception scenario
      Return type : void
     **************************************************************************************************************************************/
     
     

    static testMethod void testBatchWithException() {
         EC_TestData.setupTestUser();
         EC_TestData.setupCatalog();
         list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
          orders[0].ccrz__OrderStatus__c = 'Failed';
          orders[0].ccrz__Storefront__c = 'Exception Condition';
          update orders;
         
        ccrz__E_Cart__c cart = [Select id,EC_Ship_To_Account__c from ccrz__E_Cart__c where id = :orders[0].ccrz__OriginatedCart__c];
        Account acc = [Select id,EC_Division__c from Account Where id = :cart.EC_Ship_To_Account__c];
        acc.EC_Division__c = 'Institutional';
        update acc;
             
        Test.startTest();
            EC_OrderSubmissionBatchJob bJob = new EC_OrderSubmissionBatchJob();
            Database.executeBatch(bJob); 
        Test.stopTest();
        
        ccrz__E_Order__c order = [select ccrz__OrderStatus__c from ccrz__E_Order__c where Id = :orders[0].Id];
        system.assert( order.ccrz__OrderStatus__c == 'Failed');

    }
    
   
  
   /***************************************************************************************************************************************
      Method Name : testBatchJobWithNoRecords
      Description : This method is used to test order submission batch job
      Return type : void
     **************************************************************************************************************************************/
     
    
    static testMethod void testBatchJobWithNoRecords(){
        
        Test.startTest();
            EC_OrderSubmissionBatchJob bJob = new EC_OrderSubmissionBatchJob();
           Database.executeBatch(bJob);
           
        Test.stopTest();
        
    }
    
}