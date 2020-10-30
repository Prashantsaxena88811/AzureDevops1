@isTest(SeeAllData = false) 
public class EC_OrderItemGroupServiceTest {
    
    public static testMethod void testProcessOrderItemGroup(){
        
        Id orderID = createOrder();
        Test.setMock(HttpCalloutMock.class, new EC_MockOrderHttpResponseGenerator()); 
        Test.startTest();
        String query  = EC_OrderItemGroupService.getOrderItemGroupQuery();
        query += ' Where ccrz__Order__c = \''+orderID +'\'';
        List<ccrz__E_OrderItemGroup__c> orderItemGroups = Database.query(query);
        EC_OrderItemGroupService.ServiceResponse response = EC_OrderItemGroupService.processOrderItemGroups(orderItemGroups);
        EC_OrderItemGroupDAO.checkCCType('Mastercard');
        EC_OrderItemGroupDAO.checkInteger('-1');
        EC_OrderItemGroupDAO.checkLong(null);
        System.assert(response != null);
        Test.stopTest();
        
    }
    
    public static testMethod void testProcessOrderItemGroupFailed(){
        Id orderID = createOrder();
        
        Test.setMock(HttpCalloutMock.class, new EC_MockFailedOrderHttpResponseGenerator()); 
        Test.startTest();
        String query  = EC_OrderItemGroupService.getOrderItemGroupQuery();
        query += ' Where ccrz__Order__c = \''+orderID +'\'';
        List<ccrz__E_OrderItemGroup__c> orderItemGroups = Database.query(query);
        EC_OrderItemGroupService.ServiceResponse response = EC_OrderItemGroupService.processOrderItemGroups(orderItemGroups);
        System.assert(response != null); 
        Test.stopTest();
        
    }
    
    public static testMethod void testProcessOrderItemGroupException(){
        Id orderID = createOrder();
        Test.setMock(HttpCalloutMock.class, new EC_MockFailedOrderHttpResponseGenerator()); 
        Test.startTest();
        EC_OrderItemGroupService.createOrderItemGroupError(orderID,'msg','webservice');
        EC_OrderItemGroupService.processOrderItemGroup(new List<Id> {orderID}); 
        List<ccrz__E_OrderItemGroup__c> listOrderItemGroup = [SELECT id from ccrz__E_OrderItemGroup__c
                                                              ORDER BY CreatedDate DESC];
        system.assertEquals(!listOrderItemGroup.isEmpty(), true);
        Test.stopTest();
    }
    
    public static Id createOrder(){
        
        
        List<ccrz__E_Order__c> orderList = EC_TestData.createOrders(1);
        List<ccrz__E_Product__c> prod = [Select Id from ccrz__E_Product__c];
        prod[0].Name = 'newTestProduct';
        prod[0].ccrz__SKU__c = 'newTestProductConnect';
        update prod;
        
        ccrz__E_OrderItemGroup__c oIGroup = new ccrz__E_OrderItemGroup__c();
        oIGroup.ccrz__Order__c = orderList.get(0).Id;
        insert oIGroup;
        
        EC_SplitOrderTest.utilityMethod(orderList,prod); 
        
        List<ccrz__E_OrderItem__c> listOrderItems = [SELECT Id from ccrz__E_OrderItem__c
                                                     WHERE ccrz__Order__c =:orderList.get(0).Id];
        for(ccrz__E_OrderItem__c varOrderItem: listOrderItems)
        {
            varOrderItem.ccrz__OrderItemGroup__c = oIGroup.Id;            
            varOrderItem.Custom_PricingUOM__c = 'CustomPricingUOM';
        }
        
        update listOrderItems;
        
        ccrz__E_Order__c order = orderList[0];
        //order.ccrz__EffectiveAccountID__c= 'effectiveAccountId';
        //system.debug('orders===='+order);
        Account account = EC_TestData.testAccount;
        account.EC_Account_Number__c = '12345/1222';
        update account;
        order.ccrz__EffectiveAccountID__c = account.id;
        order.ccrz__RequestDate__c = System.today();
        update order;      
        order = [Select ccrz__OriginatedCart__r.Id from ccrz__E_Order__c where Id=: order.id Limit 1];   
        ccrz__E_PaymentDetail__c payment = new ccrz__E_PaymentDetail__c(
            ccrz__Credit_Card_Type__c ='VISA',
            ccrz__Payment_Method__c = 'Credit Card',
            ccrz__Payment_Token__c= '-E19791-22-22-1233',
            ccrz__Expiration_Month__c = '01',
            ccrz__Expiration_Year__c = Decimal.valueOf('2020'),
            ccrz__CC_Order__c = order.id,
            ccrz__Cart__c = order.ccrz__OriginatedCart__r.Id
        );
        insert payment;
        return order.id;
    }
    
    @IsTest
    private static void EC_HttpFormBuilderTest() {       
        Test.startTest();        
        string contentType = EC_HttpFormBuilder.SafelyPad('value','value=','\r\n\n\r');        
		System.assertEquals('dmFsdWUgICANCgoN',contentType);
        EC_HttpFormBuilder.WriteBoundary(EC_HttpFormBuilder.EndingType.Cr);
        EC_HttpFormBuilder.WriteBoundary(EC_HttpFormBuilder.EndingType.None);
        Test.stopTest();      
    }

    
      /***************************************************************************************************************************************
      Method Name :createOrderItemGroupError
      Description : This method is used to test long error message
      Return type : void
    **************************************************************************************************************************************/
    @isTest
    private static void testCreateOrderItemGroupError(){ 
        list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
        String errorMessage = 'This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string.'; 
        Test.startTest();
        EC_Order_Submission_Error__c varOrderSubmissionErrorRecord = EC_OrderItemGroupService.createOrderItemGroupError(orders[0].id,errorMessage, 'webServiceName');
        System.assertEquals('webServiceName',varOrderSubmissionErrorRecord.EC_Web_Service_Name__c);
        Test.stopTest(); 
    }
         /***************************************************************************************************************************************
      Method Name :testprocessFailedOrder
      Description : This method is used to test long error message more than 131072 characters 
      Return type : void
    **************************************************************************************************************************************/
    @isTest
    private static void testprocessFailedOrder(){ 
        list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
        ccrz__E_Order__c varOrderRecord = [SELECT EC_Submission_Failure_Count__c from ccrz__E_Order__c Where Id IN:orders];
        
        ccrz__E_OrderItemGroup__c oIGroup = new ccrz__E_OrderItemGroup__c();
        oIGroup.ccrz__Order__c = varOrderRecord.Id;
        insert oIGroup;
        
        String errorMessage = 'This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string,looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong strrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrriiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiinnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg Salllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllleeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeesssssssssssssssssssssssssssssssssssssssssssssssssssssssssfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffooooooooooooooooooooooooooooooooooooooooooooooooooooooooooorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string, This is a very long string.'; 
        for(Integer i=0;i<6;i++){
            errorMessage += errorMessage;
        }
        Test.startTest();
        EC_Order_Submission_Error__c varOrderSubmissionErrorRecord = EC_OrderItemGroupService.processFailedOrder(oIGroup,errorMessage);
        System.assertEquals(errorMessage.substring(0,131072),varOrderSubmissionErrorRecord.EC_Error_Description__c);
        Test.stopTest(); 
    }
}