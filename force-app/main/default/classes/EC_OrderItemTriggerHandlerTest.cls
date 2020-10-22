//EC_OrderItemTriggerHandlerTest
//This is the test class to test the EC_OrderItemTriggerHandler class
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shruti Sinha     5th Aug, 2019   to concatenate the name of the product on OrderItem 
//

@isTest
public class EC_OrderItemTriggerHandlerTest {
 /***************************************************************************************************************************************
      Method Name :  orderUpdateTest
      Description : to test the orderUpdate Method Of EC_OrderItemTriggerHandler
      Return type : void
      Author      :Shruti Sinha
*************************************************************************************************************************************/
   
    public static testmethod void orderItemTriggerTest(){
        
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
        System.runAs(thisUser){
             EC_TestData.setupCatalog();
             EC_TestData.createOrders(1);
             List<ccrz__E_Order__c> order = [Select Id from ccrz__E_Order__c LIMIT 1];
            List<ccrz__E_Product__c> products = [Select Id from ccrz__E_Product__c limit 1];
           
            
            //Creating Order Item 
             List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
             ccrz__E_OrderItem__c fstOrdItem = new ccrz__E_OrderItem__c();
             fstOrdItem.ccrz__Order__c= order[0].Id;
             fstOrdItem.ccrz__Price__c = 50 ;
             fstOrdItem.ccrz__Quantity__c = 2 ;
             fstOrdItem.ccrz__Product__c = products[0].Id;
             fstOrdItem.ccrz__Comments__c = 'test';
             fstOrdItem.ccrz__OrderLineType__c = 'Minor' ;
             fstOrdItem.ccrz__SubAmount__c =30;
              fstOrdItem.ccrz__RequestDate__c = system.today();
            ccrz__E_OrderItem__c SecOrdItem = new ccrz__E_OrderItem__c();
             SecOrdItem.ccrz__Order__c= order[0].Id;
             SecOrdItem.ccrz__Price__c = 50 ;
             SecOrdItem.ccrz__Quantity__c = 2 ;
             SecOrdItem.ccrz__Product__c = products[0].Id;
             SecOrdItem.ccrz__Comments__c = 'test';
             SecOrdItem.ccrz__OrderLineType__c = 'Minor';
             SecOrdItem.ccrz__SubAmount__c = 20;
             SecOrdItem.ccrz__RequestDate__c = system.today();
             testOrderItems.add(fstOrdItem);
            testOrderItems.add(SecOrdItem);
            test.startTest();
                 insert testOrderItems;
                         
            test.stopTest();
            
        }
        
}
    
  
}