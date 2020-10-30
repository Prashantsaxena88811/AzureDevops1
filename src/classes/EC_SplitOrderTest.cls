@isTest(SeeAllData = false) 
public class EC_SplitOrderTest {
    
    public static testMethod void testOrderSubmitFlow(){
        
        
        
        List<ccrz__E_Order__c> orderList = EC_TestData.createOrders(1);
        //ccrz__EffectiveAccountID__c
        List<ccrz__E_Product__c> prod = [Select Id from ccrz__E_Product__c];
        List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
        prod[0].Name = 'newTestProduct';
        update prod;
        ccrz__E_PriceList__c fbaPriceList = priceListUtility('Fixed','FBA');
        
       List<ccrz__E_Product__c> listProducts = productUtility(1);      
        
        testOrderItems.add(
            new ccrz__E_OrderItem__c(
                ccrz__Order__c           = orderList.get(0).Id,
                ccrz__Price__c           = 50,
                ccrz__Quantity__c        = 2,
                ccrz__SubAmount__c       = 20,
                ccrz__Product__c         = listProducts[0].Id,
                ccrz__Comments__c        = 'Comments',
                ccrz__OrderLineType__c = 'Minor',
                ccrz__RequestDate__c     = system.today(),
                ccrz__OriginalQuantity__c =2,
                Billing_Arrangement__c = fbaPriceList.id	
                
            ));
        
        insert testOrderItems;
        
        ccrz__E_Order__c order = orderList[0];
        //order.ccrz__EffectiveAccountID__c= 'effectiveAccountId';
        //system.debug('orders===='+order);
        Account account = EC_TestData.testAccount;
        order.ccrz__EffectiveAccountID__c = account.id;
        update order;       
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new EC_MockOrderHttpResponseGenerator()); 
         Map<String,String> skuListMap = new Map<String,String>();
        skuListMap.put(testOrderItems[0].ccrz__Product__r.ccrz__SKU__c,testOrderItems[0].ccrz__Product__r.ccrz__SKU__c);
        Map<String,List<String>> pricelistSKUMap = new Map<String,List<String>>();
        pricelistSKUMap.put(String.valueOf(fbaPriceList.Id),new List<String>{'mapSKU'});
        Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap = new Map<String,List<ccrz__E_OrderItem__c>>();
        BA_ULOrderItemMap.put(String.valueOf(fbaPriceList.Id),new List<ccrz__E_OrderItem__c>{testOrderItems[0]});
        EC_SplitOrder.splitMultipleSPAHelper(testOrderItems[0],String.valueOf(fbaPriceList.Id),String.valueOf(fbaPriceList.Id),BA_ULOrderItemMap,skuListMap,pricelistSKUMap);
        
        EC_SplitOrder.orderSubmitFlow(new List<Id>{order.id});
        List<ccrz__E_OrderItemGroup__c> listOrderItemGroup = [SELECT id from ccrz__E_OrderItemGroup__c
                                                              ORDER BY CreatedDate DESC];
        system.assertEquals(!listOrderItemGroup.isEmpty(), true);
        Test.stopTest();
        
    }
    
    public static testMethod void testOrderSubmitFlowUSG(){
        
        
        List<ccrz__E_Order__c> orderList = EC_TestData.createOrders(1);
        List<ccrz__E_Product__c> prod = [Select Id from ccrz__E_Product__c];
        List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
        prod[0].Name = 'newTestProduct';
        update prod;
        ccrz__E_PriceList__c USGPriceList = priceListUtility('Usage','USG');
         
        List<ccrz__E_Product__c> listProducts = productUtility(1);  
        
        testOrderItems.add(
            new ccrz__E_OrderItem__c(
                ccrz__Order__c           = orderList.get(0).Id,
                ccrz__Price__c           = 50,
                ccrz__Quantity__c        = 2,
                ccrz__SubAmount__c       = 20,
                ccrz__Product__c         = listProducts[0].Id,
                ccrz__Comments__c        = 'Comments__c',
                ccrz__OrderLineType__c = 'Minor',
                ccrz__RequestDate__c     = system.today(),
                ccrz__OriginalQuantity__c =2,
                Billing_Arrangement__c = USGPriceList.id	
                
            ));
        
        insert testOrderItems;
        
        ccrz__E_Order__c order = orderList[0];
        //order.ccrz__EffectiveAccountID__c= 'effectiveAccountId';
        //system.debug('orders===='+order);
        Account account = EC_TestData.testAccount;
        order.ccrz__EffectiveAccountID__c = account.id;
        update order;       
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new EC_MockOrderHttpResponseGenerator()); 
        EC_SplitOrder.orderSubmitFlow(new List<Id>{order.id});
        List<ccrz__E_OrderItemGroup__c> listOrderItemGroup = [SELECT id from ccrz__E_OrderItemGroup__c
                                                              ORDER BY CreatedDate DESC];
        system.assertEquals(!listOrderItemGroup.isEmpty(), true);
        Test.stopTest();
        
    }
    
    public static testMethod void testOrderSubmitBAFlow(){
        
        
        List<ccrz__E_Order__c> orderList = EC_TestData.createOrders(1);
        List<ccrz__E_Product__c> prod = [Select Id from ccrz__E_Product__c];
        
        prod[0].Name = 'newTestProduct';
        prod[0].ccrz__SKU__c = 'newTestProductConnect';
        update prod;
        
        utilityMethod(orderList,prod);        
        ccrz__E_Order__c order = orderList[0];
        //order.ccrz__EffectiveAccountID__c= 'effectiveAccountId';
        //system.debug('orders===='+order);
        Account account = EC_TestData.testAccount;
        account.EC_Account_Number__c = '12345/1222';
        update account;
        order.ccrz__EffectiveAccountID__c = account.id;
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
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new EC_MockOrderHttpResponseGenerator()); 
        EC_SplitOrder.orderSubmitFlow(new List<Id>{order.id});
        List<ccrz__E_OrderItemGroup__c> listOrderItemGroup = [SELECT id from ccrz__E_OrderItemGroup__c
                                                              ORDER BY CreatedDate DESC];
        system.assertEquals(!listOrderItemGroup.isEmpty(), true);
        Test.stopTest();
        
    }
    
    public static ccrz__E_PriceList__c priceListUtility(String name,String priceListType)
    {
        ccrz__E_PriceList__c priceListRecord = 
            new ccrz__E_PriceList__c(
                Name                     = name,
                ccrz__CurrencyISOCode__c = 'USD',
                ccrz__Enabled__c         = true,
                ccrz__Storefront__c      = 'DefaultStore',
                ccrz__StartDate__c       = Date.today().addDays(-7),
                ccrz__EndDate__c         = Date.today().addDays(7),
                ccrz__PricelistId__c  	 = name+'-001',
                EC_Price_List_Type__c    =	priceListType,
                BA_Number__c = '12345612'
            );        
        insert priceListRecord;
        return priceListRecord;
    }
    
    public static void utilityMethod(List<ccrz__E_Order__c> orderList,List<ccrz__E_Product__c> prod)
    {
        List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
        ccrz__E_OrderItem__c varOrderItemRecord;
        ccrz__E_PriceList__c fbaPriceList = priceListUtility('Fixed','FBA');
        ccrz__E_PriceList__c usgPriceList = priceListUtility('Usage','USG');
        ccrz__E_PriceList__c sbaPriceList = priceListUtility('Ship and Bill','SBA');
        Map<Integer,String> mapCountVsPricelistId = new Map<Integer,String>();
        mapCountVsPricelistId.put(0,'');
        mapCountVsPricelistId.put(1,fbaPriceList.Id);
        mapCountVsPricelistId.put(2,usgPriceList.Id);
        
        List<ccrz__E_Product__c> listProducts = productUtility(2);
        prod.addAll(listProducts);
        priceListItemUtility(prod,sbaPriceList.Id);
        
        INteger i=0;
        for(ccrz__E_Product__c varProd: prod)
        {            
            for(Integer j=0;j<2;j++)
            {
                varOrderItemRecord =  new ccrz__E_OrderItem__c();
                varOrderItemRecord.ccrz__Order__c           = orderList.get(0).Id;
                varOrderItemRecord.ccrz__Price__c           = 50;
                varOrderItemRecord.ccrz__Quantity__c        = 2;
                varOrderItemRecord.ccrz__SubAmount__c       = 20;
                varOrderItemRecord.ccrz__Product__c         = varProd.Id;
                varOrderItemRecord.ccrz__Comments__c        = 'Commts';
                varOrderItemRecord.ccrz__OrderLineType__c = 'Minor';
                varOrderItemRecord.ccrz__RequestDate__c     = system.today();
                varOrderItemRecord.ccrz__OriginalQuantity__c =2;
                varOrderItemRecord.Billing_Arrangement__c =  mapCountVsPricelistId.get(i)=='' ? null : mapCountVsPricelistId.get(i);
                i++;
                testOrderItems.add(varOrderItemRecord);
            }
        }
        insert testOrderItems; 
        Id effectiveAccountId = [Select ccrz__EffectiveAccountID__c from ccrz__E_Order__c Where Id=:orderList[0].Id].ccrz__EffectiveAccountID__c;
        accountGroupPriceListUtility(effectiveAccountId,sbaPriceList.Id);
    }
    
    public static void priceListItemUtility(List<ccrz__E_Product__c> listProducts,Id priceListId)
    {
        List<ccrz__E_PriceListItem__c> listInsertPriceListItem = new List<ccrz__E_PriceListItem__c>();
        ccrz__E_PriceListItem__c varPriceListItemRecord;
        
        for(ccrz__E_Product__c varProduct: listProducts)
        {
            varPriceListItemRecord = new ccrz__E_PriceListItem__c();
            varPriceListItemRecord.ccrz__Pricelist__c = priceListId;
            varPriceListItemRecord.ccrz__Product__c   = varProduct.Id;
            varPriceListItemRecord.ccrz__StartDate__c = Date.today().addDays(-7);
            varPriceListItemRecord.ccrz__EndDate__c   = Date.today().addDays(7);
            varPriceListItemRecord.ccrz__Price__c     = 100;
            listInsertPriceListItem.add(varPriceListItemRecord);            
        }        
        insert listInsertPriceListItem;
    }
    
    public static List<ccrz__E_Product__c> productUtility(Integer count)
    {
        List<ccrz__E_Product__c> listCreateProducts = new List<ccrz__E_Product__c>();
        ccrz__E_Product__c prodNew;
        
        for(Integer i=0;i<count;i++)
        {
			prodNew = new ccrz__E_Product__c(
            Name                       = 'MyProd Bag'+i,
            ccrz__SKU__c               = 'test001MyProd'+i,
            ccrz__ProductId__c         = 'test001MyProd'+i,
            ccrz__ProductStatus__c     = 'Released',
            ccrz__UnitOfMeasure__c     = 'BG',
            ccrz__StartDate__c         = Date.today().addDays(-10),
            ccrz__EndDate__c           = Date.today().addDays(9),
            ccrz__Storefront__c        = 'DefaultStore',
            ccrz__ProductWeight__c     = 500,
            ccrz__HazardousFlag__c     = true,
            ccrz__ShortDesc__c       ='product001 Bag'+i,
            ccrz__LongDesc__c       ='product001 Bag'+i,
            ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
        );           
            listCreateProducts.add(prodNew);
        }
        insert listCreateProducts;  
      return listCreateProducts;
    }
    
    public static void accountGroupPriceListUtility(Id effectiveAccountId,Id priceListId)
    {
        Id accountGroupId = [Select ccrz__E_AccountGroup__c from Account Where Id =:effectiveAccountId].ccrz__E_AccountGroup__c;
        ccrz__E_AccountGroupPriceList__c varAccGroupPriceListRecord;      
               
        varAccGroupPriceListRecord = new ccrz__E_AccountGroupPriceList__c();
        varAccGroupPriceListRecord.ccrz__AccountGroup__c = accountGroupId;
        varAccGroupPriceListRecord.ccrz__Pricelist__c =  priceListId;
        varAccGroupPriceListRecord.ccrz__StartDate__c = system.today()-7;
        varAccGroupPriceListRecord.ccrz__EndDate__c = system.today()+7;       
        insert varAccGroupPriceListRecord;       
    }   
    
}