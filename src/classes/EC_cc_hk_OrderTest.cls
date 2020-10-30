/*******************************************************************************************************************
Apex Class Name     : EC_cc_hk_OrderTest
Created Date        : 8 August 2019
Description         : Test class for EC_cc_hk_Order
* Developer                        Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Vishal                           8 August 2019          Test class for EC_cc_hk_Order
*************************************************************************************************************************/

@isTest
public class EC_cc_hk_OrderTest{

    /************************************************************************
    Method Name: place
    Description: Test method for place(Map<String,Object> inputData) in EC_cc_hk_Order class
    Parameters: NA
    Returns: void
    *************************************************************************/

    public static testMethod void place(){
        Map<String,Object> inputData = new Map<String,Object>();
        Test.startTest();
        EC_cc_hk_Order hkOrder = new EC_cc_hk_Order();
        List<ccrz__E_Order__c> orderList = EC_TestData.createOrders(1);
        List<ccrz__E_OrderItem__c> orderItems = [Select Id,ccrz__Order__c,ccrz__Product__c from ccrz__E_OrderItem__c];
        List<ccrz__E_Product__c> prod = [Select Id from ccrz__E_Product__c];
        List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
        prod[0].Name = 'newTestProduct';
        update prod;

        testOrderItems.add(
            new ccrz__E_OrderItem__c(
                ccrz__Order__c           = orderList.get(0).Id,
                ccrz__Price__c           = 50,
                ccrz__Quantity__c        = 2,
                ccrz__SubAmount__c       = 20,
                ccrz__Product__c         = prod[0].Id,
                ccrz__Comments__c        = 'test',
                ccrz__OrderLineType__c = 'Minor',
                ccrz__RequestDate__c     = system.today(),
                ccrz__OriginalQuantity__c =2
            ));

         testOrderItems.add(
            new ccrz__E_OrderItem__c(
                ccrz__Order__c           = orderList.get(0).Id,
                ccrz__Price__c           = 50,
                ccrz__Quantity__c        = 2,
                ccrz__SubAmount__c       = 20,
                ccrz__Product__c         = prod[1].Id,
                ccrz__Comments__c        = 'test',
                ccrz__OrderLineType__c = 'Minor',
                ccrz__RequestDate__c     = system.today(),
                ccrz__OriginalQuantity__c =2
            ));
        ccrz__E_Product__c prodNew = new ccrz__E_Product__c(
                        Name                       = 'MyProd Bag',
                        ccrz__SKU__c               = 'test001MyProd',
                        ccrz__ProductId__c         = 'test001MyProd',
                        ccrz__ProductStatus__c     = 'Released',
                        ccrz__UnitOfMeasure__c     = 'BG',
                        ccrz__StartDate__c         = Date.today().addDays(-7),
                        ccrz__EndDate__c           = Date.today().addDays(7),
                        ccrz__Storefront__c        = 'DefaultStore',
                        ccrz__ProductWeight__c     = 500,
                        ccrz__HazardousFlag__c     = true,
                        ccrz__ShortDesc__c       ='product001 Bag',
                        ccrz__LongDesc__c       ='product001 Bag',
                    ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
                );
        insert prodNew;


         testOrderItems.add(
            new ccrz__E_OrderItem__c(
                ccrz__Order__c           = orderList.get(0).Id,
                ccrz__Price__c           = 50,
                ccrz__Quantity__c        = 2,
                ccrz__SubAmount__c       = 20,
                ccrz__Product__c         = prodNew.Id,
                ccrz__Comments__c        = 'test',
                ccrz__OrderLineType__c = 'Minor',
                ccrz__RequestDate__c     = system.today(),
                ccrz__OriginalQuantity__c =2
            ));

        insert testOrderItems;

        ccrz__E_Order__c order = orderList[0];
        Account account = EC_TestData.testAccount;
        order.ccrz__EffectiveAccountID__c = account.id;
        update order;
        List<ccrz__E_Cart__c> wishListCart = EC_TestData.createQuickLists(1);
        wishListCart[0].ccrz__CartType__c = 'WishList';
		wishListCart[0].EC_PurchasedWishlist__c = true;
        update wishListCart;

         List<ccrz__E_CartItem__c> testCartItems = new List<ccrz__E_CartItem__c>();

        for(ccrz__E_Product__c pc: prod){
            pc.Name = 'New Product';
        }
        update prod;

        for(ccrz__E_Product__c pc: prod){
            testCartItems.add(
                   new ccrz__E_CartItem__c(
                            ccrz__Cart__c           = wishListCart.get(0).Id,
                            ccrz__Price__c           = 50,
                            ccrz__Quantity__c        = 2,
                            ccrz__SubAmount__c       = 20,
                            ccrz__Product__c         = pc.Id,
                            ccrz__Comments__c        = 'test',
                            ccrz__RequestDate__c     = system.today()
                    ));

        }

        insert testCartItems;

        inputData.put('order', order);
        inputData.put('orderItems', (Object)testOrderItems);
        inputData.put('placeStep', ccrz.cc_hk_Order.STEP_END);
        hkOrder.place(inputData);
        Test.stopTest();
        System.assert(inputData.containsKey('order'), null);
    }
    /************************************************************************
    Method Name: pplace2lace
    Description: Test method for place(Map<String,Object> inputData) in EC_cc_hk_Order class
    Parameters: NA
    Returns: void
    *************************************************************************/

    public static testMethod void place2(){
        Map<String,Object> inputData = new Map<String,Object>();
        Test.startTest();
        EC_cc_hk_Order hkOrder = new EC_cc_hk_Order();
        List<ccrz__E_Order__c> orderList = EC_TestData.createOrders(1);
        List<ccrz__E_Product__c> prod = [Select Id from ccrz__E_Product__c];
        List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
        prod[0].Name = 'newTestProduct';
        update prod;

        testOrderItems.add(
            new ccrz__E_OrderItem__c(
                ccrz__Order__c           = orderList.get(0).Id,
                ccrz__Price__c           = 50,
                ccrz__Quantity__c        = 2,
                ccrz__SubAmount__c       = 20,
                ccrz__Product__c         = prod[0].Id,
                ccrz__Comments__c        = 'test',
                ccrz__OrderLineType__c = 'Minor',
                ccrz__RequestDate__c     = system.today(),
                ccrz__OriginalQuantity__c =2
            ));

         testOrderItems.add(
            new ccrz__E_OrderItem__c(
                ccrz__Order__c           = orderList.get(0).Id,
                ccrz__Price__c           = 50,
                ccrz__Quantity__c        = 2,
                ccrz__SubAmount__c       = 20,
                ccrz__Product__c         = prod[1].Id,
                ccrz__Comments__c        = 'test',
                ccrz__OrderLineType__c = 'Minor',
                ccrz__RequestDate__c     = system.today(),
                ccrz__OriginalQuantity__c =2
            ));
        ccrz__E_Product__c prodNew = new ccrz__E_Product__c(
                        Name                       = 'MyProd Bag',
                        ccrz__SKU__c               = 'test001MyProd',
                        ccrz__ProductId__c         = 'test001MyProd',
                        ccrz__ProductStatus__c     = 'Released',
                        ccrz__UnitOfMeasure__c     = 'BG',
                        ccrz__StartDate__c         = Date.today().addDays(-7),
                        ccrz__EndDate__c           = Date.today().addDays(7),
                        ccrz__Storefront__c        = 'DefaultStore',
                        ccrz__ProductWeight__c     = 500,
                        ccrz__HazardousFlag__c     = true,
                        ccrz__ShortDesc__c       ='product001 Bag',
                        ccrz__LongDesc__c       ='product001 Bag',
                    ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
                );
        insert prodNew;


         testOrderItems.add(
            new ccrz__E_OrderItem__c(
                ccrz__Order__c           = orderList.get(0).Id,
                ccrz__Price__c           = 50,
                ccrz__Quantity__c        = 2,
                ccrz__SubAmount__c       = 20,
                ccrz__Product__c         = prodNew.Id,
                ccrz__Comments__c        = 'test',
                ccrz__OrderLineType__c = 'Minor',
                ccrz__RequestDate__c     = system.today(),
                ccrz__OriginalQuantity__c =2
            ));

        insert testOrderItems;
        ccrz__E_Order__c order = orderList[0];
        Account account = EC_TestData.testAccount;
        order.ccrz__EffectiveAccountID__c = account.id;
        update order;
        inputData.put('order', order);
        inputData.put('placeStep', ccrz.cc_hk_Order.STEP_END);
        inputData.put('orderItems', (Object)testOrderItems);
        hkOrder.place(inputData);
        Test.stopTest();
        System.assert(inputData.containsKey('order'), null);
    }
    //bharath test class

    public static testMethod void place3(){
        Map<String,Object> inputData = new Map<String,Object>();
        Test.startTest();
        EC_cc_hk_Order hkOrder = new EC_cc_hk_Order();
        List<ccrz__E_Order__c> orderList = EC_TestData.createOrders(1);
        List<ccrz__E_OrderItem__c> orderItems = [Select Id,ccrz__Order__c,ccrz__Product__c from ccrz__E_OrderItem__c];
        List<ccrz__E_Product__c> prod = [Select Id from ccrz__E_Product__c];
        List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
        prod[0].Name = 'newTestProduct';
        update prod;
        
        ccrz__E_Product__c prodNew = new ccrz__E_Product__c(
                        Name                       = 'MyProd Bag',
                        ccrz__SKU__c               = 'test001MyProd',
                        ccrz__ProductId__c         = 'test001MyProd',
                        ccrz__ProductStatus__c     = 'Released',
                        ccrz__UnitOfMeasure__c     = 'BG',
                        ccrz__StartDate__c         = Date.today().addDays(-7),
                        ccrz__EndDate__c           = Date.today().addDays(7),
                        ccrz__Storefront__c        = 'DefaultStore',
                        ccrz__ProductWeight__c     = 500,
                        ccrz__HazardousFlag__c     = true,
                        ccrz__ShortDesc__c       ='product001 Bag',
                        ccrz__LongDesc__c       ='product001 Bag',
                    ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
                );
        insert prodNew;
        
        testOrderItems.add(EC_TestData.createOrderItems(orderList.get(0).Id, prod[0].Id));
        testOrderItems.add(EC_TestData.createOrderItems(orderList.get(0).Id, prod[1].Id));
        testOrderItems.add(EC_TestData.createOrderItems(orderList.get(0).Id, prodNew.Id));

        insert testOrderItems;

        ccrz__E_Order__c order = orderList[0];
        Account account = EC_TestData.testAccount;
        order.ccrz__EffectiveAccountID__c = account.id;
        update order;
        List<ccrz__E_Cart__c> wishListCart = EC_TestData.createQuickLists(1);
        wishListCart[0].ccrz__CartType__c = 'WishList';
		wishListCart[0].EC_PurchasedWishlist__c = true;
        update wishListCart;
        List<ccrz__E_CartItem__c> testQuickListItems = new List<ccrz__E_CartItem__c>();
        for (Integer i = 0; i < 4; i++) {
            testQuickListItems.add(
                    new ccrz__E_CartItem__c(
                            ccrz__Cart__c           = orderList[0].ccrz__OriginatedCart__c,
                            ccrz__Price__c           = 50,
                            ccrz__Quantity__c        = 2,
                            ccrz__SubAmount__c       = 20,
                            ccrz__Product__c         =prod[1].Id,
                            ccrz__Comments__c        = 'test',
                            ccrz__RequestDate__c     = system.today(),
                            EC_Last_Purchased_Date__c = system.today()
                    ));
            testQuickListItems.add(
                    new ccrz__E_CartItem__c(
                            ccrz__Cart__c           = orderList[0].ccrz__OriginatedCart__c,
                            ccrz__Price__c           = 50,
                            ccrz__Quantity__c        = 2,
                            ccrz__SubAmount__c       = 20,
                            ccrz__Product__c         = prodNew.Id,
                            ccrz__Comments__c        = 'test',
                            ccrz__RequestDate__c     = system.today(),
                          EC_Last_Purchased_Date__c = system.today()
                    ));
        }
        insert testQuickListItems;

        inputData.put('order', order);
        inputData.put('orderItems', (Object)testOrderItems);
        inputData.put('placeStep', ccrz.cc_hk_Order.STEP_CREATE_ORDER_ITEMS_POST);
        hkOrder.place(inputData);
        Test.stopTest();
        System.assert(inputData.containsKey('order'), null);
    }

}