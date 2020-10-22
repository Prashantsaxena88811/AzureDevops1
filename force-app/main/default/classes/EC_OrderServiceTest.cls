/********************************************************************************************************
* @Class Name    EC_OrderServiceTest
* @description   Test Class for EC_OrderService
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 

@isTest
public class EC_OrderServiceTest {

/***************************************************************************************************************************************
      Method Name : testOrderService_processOrder
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
     
     
     static testMethod void testOrderService_processOrder(){
        
         EC_WebService_Setting__c wsConfig = new EC_WebService_Setting__c();
         wsConfig.Endpoint__c = 'testUrl';
         wsConfig.Name = 'TIBCO';
         insert wsConfig;
        
         EC_TestData.setupTestUser();
         User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' limit 1];
         System.runas(thisUser){
         EC_TestData.setupCatalog();
         list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
         orders[0].ccrz__StoreFront__c = 'shopecolab';
         Account acc = [Select id from Account where EC_Division__c != 'WATER' limit 1];
         orders[0].ccrz__EffectiveAccountID__c = acc.Id;
         update orders;
         
         Id cart = orders[0].ccrz__OriginatedCart__c;
         
         ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c();
         coupon.ccrz__CouponCode__c = 'testcode';
         coupon.ccrz__DiscountType__c = 'Percentage';
         coupon.ccrz__StartDate__c = System.today();
         coupon.ccrz__EndDate__c = System.today().addDays(1);
         coupon.ccrz__CouponName__c = 'testcoupon';
         coupon.ccrz__MaxUse__c = 10;
         coupon.ccrz__TotalUsed__c = 1;
         insert coupon;
           
         ccrz__E_CartCoupon__c cartCoupon = new ccrz__E_CartCoupon__c();
         cartCoupon.ccrz__Enabled__c = true;
         cartCoupon.ccrz__Cart__c = cart;
         cartCoupon.ccrz__Coupon__c = coupon.id;
         insert cartCoupon;
         
         ccrz__E_Order__c order = [Select id,ccrz__ShipTo__c,ccrz__BillTo__c from ccrz__E_Order__c where id = :orders[0].id];
         ccrz__E_ContactAddr__c shipToaddr = [Select id,ccrz__FirstName__c,ccrz__LastName__c,ccrz__ShippingComments__c from ccrz__E_ContactAddr__c Where id = :order.ccrz__ShipTo__c];
         shipToaddr.ccrz__FirstName__c = '';
         shipToaddr.ccrz__LastName__c = '';
         shipToaddr.ccrz__ShippingComments__c = 'comments';
         update shipToaddr;
             
         ccrz__E_ContactAddr__c billToaddr = [Select id,ccrz__FirstName__c,ccrz__LastName__c,ccrz__ShippingComments__c from ccrz__E_ContactAddr__c Where id = :order.ccrz__BillTo__c];
         billToaddr.ccrz__FirstName__c = '';
         billToaddr.ccrz__LastName__c = '';
         update billToaddr;

             
         list<ccrz__E_Order__c> orderInput =[Select  Id,ccrz__EffectiveAccountID__c,ccrz__Account__r.EC_Account_Number__c,ccrz__Account__r.EC_Division__c,Name, ccrz__Storefront__c, ccrz__OrderStatus__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c,ccrz__BuyerEmail__c, ccrz__BuyerPhone__c,
                        ccrz__BuyerMobilePhone__c, ccrz__PaymentMethod__c, ccrz__ShipComplete__c, ccrz__ShipMethod__c, ccrz__SubTotalAmount__c, ccrz__TotalDiscount__c,ccrz__ShipAmount__c, ccrz__TaxAmount__c, ccrz__TotalAmount__c, ccrz__OrderDate__c, EC_Submission_Failure_Count__c,
                        ccrz__Account__r.Name, ccrz__BillTo__r.ccrz__FirstName__c , ccrz__BillTo__r.ccrz__MiddleName__c, ccrz__BillTo__r.ccrz__LastName__c,
                        ccrz__BillTo__r.ccrz__Email__c,    ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondLine__c, ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__DaytimePhone__c, ccrz__BillTo__r.ccrz__HomePhone__c, ccrz__ShipTo__r.ccrz__DaytimePhone__c, ccrz__ShipTo__r.ccrz__HomePhone__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__BillTo__r.ccrz__CountryISOCode__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__FirstName__c    ,
                        ccrz__ShipTo__r.ccrz__MiddleName__c, ccrz__ShipTo__r.ccrz__LastName__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondLine__c,
                        ccrz__ShipTo__r.ccrz__City__c, ccrz__ShipTo__r.ccrz__StateISOCode__c, ccrz__ShipTo__r.ccrz__CountryISOCode__c, ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__ShippingComments__c, ccrz__ShipTo__r.ccrz__Partner_Id__c, ccrz__OriginatedCart__c, ccrz__PONumber__c, ccrz__RequestDate__c,EC_Order_Submission_Type__c,
                        ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Division__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c,
                        ( Select Id, Name, ccrz__ProductType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.Name, ccrz__Quantity__c,
                                 ccrz__Price__c, ccrz__SubAmount__c, ccrz__Comments__c from ccrz__E_OrderItems__r ), 

                        ( Select Id, Name, ccrz__Token__c,ccrz__Amount__c, ccrz__PaymentType__c, ccrz__Comments__c,ccrz__RequestAmount__c,ccrz__TransactionTS__c,
                                 ccrz__ExpirationMonth__c, ccrz__ExpirationYear__c, ccrz__AccountNumber__c, ccrz__TransactionCode__c,ccrz__CurrencyISOCode__c,ccrz__TransactionSubcode__c
                             From ccrz__TransactionPayments__r )

                        From ccrz__E_Order__c where ccrz__StoreFront__c != null  limit 1];
             
             List<ID> orderIds = new List<ID>();
             orderIds.add(orderInput.get(0).id);
         Test.startTest();
           
            EC_OrderService.processOrder(orderIds); 
             
        Test.stopTest();             
       }
    }
    
    /***************************************************************************************************************************************
      Method Name : testOrderService_NegativeResponse
      Description : This method is used to test negative scenario
      Return type : void
     **************************************************************************************************************************************/
  
     static testMethod void testOrderService_NegativeResponse(){
                
         EC_TestData.setupTestUser();
         User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' limit 1];
         System.runas(thisUser){
         EC_TestData.setupCatalog();
         list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
         orders[0].ccrz__StoreFront__c = 'ERROR CONDITION';
         update orders;
             
         list<ccrz__E_Order__c> orderInput =[Select  Id,ccrz__EffectiveAccountID__c,ccrz__Account__r.EC_Account_Number__c,ccrz__Account__r.EC_Division__c,Name, ccrz__Storefront__c, ccrz__OrderStatus__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c,ccrz__BuyerEmail__c, ccrz__BuyerPhone__c,
                        ccrz__BuyerMobilePhone__c, ccrz__PaymentMethod__c, ccrz__ShipComplete__c, ccrz__ShipMethod__c, ccrz__SubTotalAmount__c, ccrz__TotalDiscount__c,ccrz__ShipAmount__c, ccrz__TaxAmount__c, ccrz__TotalAmount__c, ccrz__OrderDate__c, EC_Submission_Failure_Count__c,
                        ccrz__Account__r.Name, ccrz__BillTo__r.ccrz__FirstName__c , ccrz__BillTo__r.ccrz__MiddleName__c, ccrz__BillTo__r.ccrz__LastName__c,
                        ccrz__BillTo__r.ccrz__Email__c,    ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondLine__c, ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__DaytimePhone__c, ccrz__BillTo__r.ccrz__HomePhone__c, ccrz__ShipTo__r.ccrz__DaytimePhone__c, ccrz__ShipTo__r.ccrz__HomePhone__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__BillTo__r.ccrz__CountryISOCode__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__FirstName__c    ,
                        ccrz__ShipTo__r.ccrz__MiddleName__c, ccrz__ShipTo__r.ccrz__LastName__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondLine__c,
                        ccrz__ShipTo__r.ccrz__City__c, ccrz__ShipTo__r.ccrz__StateISOCode__c, ccrz__ShipTo__r.ccrz__CountryISOCode__c, ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__ShippingComments__c, ccrz__ShipTo__r.ccrz__Partner_Id__c, ccrz__OriginatedCart__c, ccrz__PONumber__c, ccrz__RequestDate__c,EC_Order_Submission_Type__c,
                        ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Division__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c,
                        ( Select Id, Name, ccrz__ProductType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.Name, ccrz__Quantity__c,
                                 ccrz__Price__c, ccrz__SubAmount__c, ccrz__Comments__c from ccrz__E_OrderItems__r ), 

                        ( Select Id, Name, ccrz__Token__c,ccrz__Amount__c, ccrz__PaymentType__c, ccrz__Comments__c,ccrz__RequestAmount__c,ccrz__TransactionTS__c,
                                 ccrz__ExpirationMonth__c, ccrz__ExpirationYear__c, ccrz__AccountNumber__c, ccrz__TransactionCode__c,ccrz__CurrencyISOCode__c,ccrz__TransactionSubcode__c
                             From ccrz__TransactionPayments__r )

                        From ccrz__E_Order__c where id = :orders[0].Id  limit 1];
             
         Test.startTest();
            EC_OrderService.processOrders(orderInput); 
        Test.stopTest();             
       }
    }
    
      /***************************************************************************************************************************************
      Method Name : testOrderService_processFailedOrders
      Description : This method is used to test failed order scenario
      Return type : void
     **************************************************************************************************************************************/
  
     
     static testMethod void testOrderService_processFailedOrders(){
        
         EC_WebService_Setting__c wsConfig = new EC_WebService_Setting__c();
         wsConfig.Endpoint__c = 'testUrl';
         wsConfig.Name = 'TIBCO';
         insert wsConfig;
        
         EC_TestData.setupTestUser();
         User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' limit 1];
         System.runas(thisUser){
         EC_TestData.setupCatalog();
         list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
         orders[0].ccrz__StoreFront__c = 'shopecolab';
         Account acc = [Select id from Account where EC_Division__c != 'WATER' limit 1];
         orders[0].ccrz__EffectiveAccountID__c = acc.Id;
         update orders;
         
             
         list<ccrz__E_Order__c> orderInput =[Select  Id,ccrz__EffectiveAccountID__c,ccrz__Account__r.EC_Account_Number__c,ccrz__Account__r.EC_Division__c,Name, ccrz__Storefront__c, ccrz__OrderStatus__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c,ccrz__BuyerEmail__c, ccrz__BuyerPhone__c,
                        ccrz__BuyerMobilePhone__c, ccrz__PaymentMethod__c, ccrz__ShipComplete__c, ccrz__ShipMethod__c, ccrz__SubTotalAmount__c, ccrz__TotalDiscount__c,ccrz__ShipAmount__c, ccrz__TaxAmount__c, ccrz__TotalAmount__c, ccrz__OrderDate__c, EC_Submission_Failure_Count__c,
                        ccrz__Account__r.Name, ccrz__BillTo__r.ccrz__FirstName__c , ccrz__BillTo__r.ccrz__MiddleName__c, ccrz__BillTo__r.ccrz__LastName__c,
                        ccrz__BillTo__r.ccrz__Email__c,    ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondLine__c, ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__DaytimePhone__c, ccrz__BillTo__r.ccrz__HomePhone__c, ccrz__ShipTo__r.ccrz__DaytimePhone__c, ccrz__ShipTo__r.ccrz__HomePhone__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__BillTo__r.ccrz__CountryISOCode__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__FirstName__c    ,
                        ccrz__ShipTo__r.ccrz__MiddleName__c, ccrz__ShipTo__r.ccrz__LastName__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondLine__c,
                        ccrz__ShipTo__r.ccrz__City__c, ccrz__ShipTo__r.ccrz__StateISOCode__c, ccrz__ShipTo__r.ccrz__CountryISOCode__c, ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__ShippingComments__c, ccrz__ShipTo__r.ccrz__Partner_Id__c, ccrz__OriginatedCart__c, ccrz__PONumber__c, ccrz__RequestDate__c,EC_Order_Submission_Type__c,
                        ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Division__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c,
                        ( Select Id, Name, ccrz__ProductType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.Name, ccrz__Quantity__c,
                                 ccrz__Price__c, ccrz__SubAmount__c, ccrz__Comments__c from ccrz__E_OrderItems__r ), 

                        ( Select Id, Name, ccrz__Token__c,ccrz__Amount__c, ccrz__PaymentType__c, ccrz__Comments__c,ccrz__RequestAmount__c,ccrz__TransactionTS__c,
                                 ccrz__ExpirationMonth__c, ccrz__ExpirationYear__c, ccrz__AccountNumber__c, ccrz__TransactionCode__c,ccrz__CurrencyISOCode__c,ccrz__TransactionSubcode__c
                             From ccrz__TransactionPayments__r )

                        From ccrz__E_Order__c where ccrz__StoreFront__c != null  limit 1];
             String id = orders[0].id;
         Test.startTest();
            EC_OrderService.processFailedOrder(orderInput[0],EC_OrderServiceTest.getLongErrorMessage());
            EC_OrderService.processFailedOrder(orderInput[0],'error message');
        Test.stopTest();             
       }
    }
    
    /***************************************************************************************************************************************
      Method Name : testOrderService_gertOrderQuery
      Description : This method is used to test getOrderQuery method
      Return type : void
     **************************************************************************************************************************************/
  
    
     static testMethod void testOrderService_gertOrderQuery(){ 
         Test.startTest();
            String query = EC_OrderService.getOrderQuery();
           System.assertNotEquals(null, query);
        Test.stopTest();             
       }
       
    /***************************************************************************************************************************************
      Method Name : testOrderService_exceptionResponse
      Description : This method is used to test exception response scenario
      Return type : void
     **************************************************************************************************************************************/
  
    
    static testMethod void testOrderService_exceptionResponse(){
        
         EC_WebService_Setting__c wsConfig = new EC_WebService_Setting__c();
         wsConfig.Endpoint__c = 'testUrl';
         wsConfig.Name = 'TIBCO';
         insert wsConfig;
        
         EC_TestData.setupTestUser();
         User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' limit 1];
         System.runas(thisUser){
         EC_TestData.setupCatalog();
         list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
         orders[0].ccrz__StoreFront__c = 'Exception Condition';
         Account acc = [Select id from Account where EC_Division__c != 'WATER' limit 1];
         orders[0].ccrz__EffectiveAccountID__c = acc.Id;
         update orders;
         
         Id cart = orders[0].ccrz__OriginatedCart__c;
         
         ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c();
         coupon.ccrz__CouponCode__c = 'testcode';
         coupon.ccrz__DiscountType__c = 'Percentage';
         coupon.ccrz__StartDate__c = System.today();
         coupon.ccrz__EndDate__c = System.today().addDays(1);
         coupon.ccrz__CouponName__c = 'testcoupon';
         coupon.ccrz__MaxUse__c = 10;
         coupon.ccrz__TotalUsed__c = 1;
         insert coupon;
           
         ccrz__E_CartCoupon__c cartCoupon = new ccrz__E_CartCoupon__c();
         cartCoupon.ccrz__Enabled__c = true;
         cartCoupon.ccrz__Cart__c = cart;
         cartCoupon.ccrz__Coupon__c = coupon.id;
         insert cartCoupon;
         
         ccrz__E_Order__c order = [Select id,ccrz__ShipTo__c from ccrz__E_Order__c where id = :orders[0].id];
         ccrz__E_ContactAddr__c shipToaddr = [Select id,ccrz__ShippingComments__c from ccrz__E_ContactAddr__c Where id = :order.ccrz__ShipTo__c];
         shipToaddr.ccrz__ShippingComments__c = 'comments';
         update shipToaddr;
             
         list<ccrz__E_Order__c> orderInput =[Select  Id,ccrz__EffectiveAccountID__c,ccrz__Account__r.EC_Account_Number__c,ccrz__Account__r.EC_Division__c,Name, ccrz__Storefront__c, ccrz__OrderStatus__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c,ccrz__BuyerEmail__c, ccrz__BuyerPhone__c,
                        ccrz__BuyerMobilePhone__c, ccrz__PaymentMethod__c, ccrz__ShipComplete__c, ccrz__ShipMethod__c, ccrz__SubTotalAmount__c, ccrz__TotalDiscount__c,ccrz__ShipAmount__c, ccrz__TaxAmount__c, ccrz__TotalAmount__c, ccrz__OrderDate__c, EC_Submission_Failure_Count__c,
                        ccrz__Account__r.Name, ccrz__BillTo__r.ccrz__FirstName__c , ccrz__BillTo__r.ccrz__MiddleName__c, ccrz__BillTo__r.ccrz__LastName__c,
                        ccrz__BillTo__r.ccrz__Email__c,    ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondLine__c, ccrz__BillTo__r.ccrz__City__c,
                        ccrz__BillTo__r.ccrz__DaytimePhone__c, ccrz__BillTo__r.ccrz__HomePhone__c, ccrz__ShipTo__r.ccrz__DaytimePhone__c, ccrz__ShipTo__r.ccrz__HomePhone__c,
                        ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__BillTo__r.ccrz__CountryISOCode__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__FirstName__c    ,
                        ccrz__ShipTo__r.ccrz__MiddleName__c, ccrz__ShipTo__r.ccrz__LastName__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondLine__c,
                        ccrz__ShipTo__r.ccrz__City__c, ccrz__ShipTo__r.ccrz__StateISOCode__c, ccrz__ShipTo__r.ccrz__CountryISOCode__c, ccrz__ShipTo__r.ccrz__PostalCode__c,
                        ccrz__ShipTo__r.ccrz__ShippingComments__c, ccrz__ShipTo__r.ccrz__Partner_Id__c, ccrz__OriginatedCart__c, ccrz__PONumber__c, ccrz__RequestDate__c,EC_Order_Submission_Type__c,
                         ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Division__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c,
                        ( Select Id, Name, ccrz__ProductType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.Name, ccrz__Quantity__c,
                                 ccrz__Price__c, ccrz__SubAmount__c, ccrz__Comments__c from ccrz__E_OrderItems__r ), 

                        ( Select Id, Name, ccrz__Token__c,ccrz__Amount__c, ccrz__PaymentType__c, ccrz__Comments__c,ccrz__RequestAmount__c,ccrz__TransactionTS__c,
                                 ccrz__ExpirationMonth__c, ccrz__ExpirationYear__c, ccrz__AccountNumber__c, ccrz__TransactionCode__c,ccrz__CurrencyISOCode__c,ccrz__TransactionSubcode__c
                             From ccrz__TransactionPayments__r )

                        From ccrz__E_Order__c where ccrz__StoreFront__c != null  limit 1];
             String id = orders[0].id;
         Test.startTest();
            EC_OrderService.createOrderError(id,EC_OrderServiceTest.getLongErrorMessage(), 'webServiceName');
            EC_OrderService.processOrders(orderInput); 
        Test.stopTest();             
       }
    }
    
    /***************************************************************************************************************************************
      Method Name :getLongErrorMessage
      Description : This method is used to mock error message
      Return type : void
     **************************************************************************************************************************************/
  
    
    private static String getLongErrorMessage(){
        
        String errorMessage = 'message';
        
        
        return errorMessage;
    }

}