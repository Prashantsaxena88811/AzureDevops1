@isTest
public class EC_OrderItemGroupSubmissionBatchJobTest {
    static testMethod void testBatchWithException() { 
        String failed = 'Failed';
         EC_TestData.setupTestUser();
         EC_TestData.setupCatalog();
                 list<ccrz__E_Order__c> ord = EC_TestData.createOrders(1);
          ord[0].ccrz__OrderStatus__c = failed;
          update ord;
         list<ccrz__E_OrderItemGroup__c> orders = new list<ccrz__E_OrderItemGroup__c>();
        ccrz__E_OrderItemGroup__c order1 = new ccrz__E_OrderItemGroup__c();
        order1.Submission_Failure_Count__c = 3;
        order1.Order_Item_Group_Status__c = failed;
        order1.ccrz__Order__c = ord[0].Id;
        Insert order1;
        ccrz__E_OrderItemGroup__c order2 = new ccrz__E_OrderItemGroup__c();
        order2.Submission_Failure_Count__c = 4;
        order2.Order_Item_Group_Status__c = failed;
        order2.ccrz__Order__c = ord[0].Id;
        Insert order2;         
        orders.add(order1);
        orders.add(order2);
        ccrz__E_Cart__c cart = [Select id,EC_Ship_To_Account__c from ccrz__E_Cart__c where id = :ord[0].ccrz__OriginatedCart__c];
        Account acc = [Select id,EC_Division__c from Account Where id = :cart.EC_Ship_To_Account__c];
        acc.EC_Division__c = 'Water';
        update acc;
             
        Test.startTest();
            EC_OrderItemGroupSubmissionBatchJob bJob = new EC_OrderItemGroupSubmissionBatchJob();
            Database.executeBatch(bJob); 
        Test.stopTest();
        
        ccrz__E_OrderItemGroup__c order = [select Order_Item_Group_Status__c from ccrz__E_OrderItemGroup__c where Id = :orders[0].Id];
        system.assert( order.Order_Item_Group_Status__c == failed);

    }
    
    static testMethod void testBatchJobWithNoRecords(){
        Test.startTest();
            EC_OrderItemGroupSubmissionBatchJob bJob = new EC_OrderItemGroupSubmissionBatchJob();
           Database.executeBatch(bJob);
           system.assert(bJob!=null);
        Test.stopTest();
        
    }
    
}