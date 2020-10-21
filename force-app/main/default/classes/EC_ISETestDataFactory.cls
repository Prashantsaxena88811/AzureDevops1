/* Class Name       : EC_ISETestDataFactory
*  Description      : Common Test Utility Classes for ISE 
*  Created By       : EDC
*  Created On       : 20-08-2020
*/
public with sharing class EC_ISETestDataFactory {
    
    private EC_ISETestDataFactory(){}
    public static final User testUser = [Select Id, ContactId FROM User WHERE Id = :EC_TestData.testUser.Id];
       
    //HybridDirect Institutional Account
	public static Account testAccount_ISEDirect {
        get {
            if (testAccount_ISEDirect == null) {
                testAccount_ISEDirect = new Account(
                    Name                    = EC_TestData.ACCOUNT_NAME + '_HybridDirect',
                    OwnerId                 = UserInfo.getUserId(),
                    Type                    = 'Customer',
                    BillingStreet           = EC_TestData.generateRandomString(32),
                    BillingCity             = EC_TestData.generateRandomString(32),
                    BillingState            = EC_TestData.generateRandomString(32),
                    BillingCountry          = 'USA',
                    BillingPostalCode       = EC_TestData.generateRandomString(5),
                    EC_Account_Number__c    = EC_TestData.generateRandomString(5),
                    RecordTypeId            = EC_TestData.getRecordType('shipTo'), //Ship To
                    EC_Division__c 			= 'INSTITUTIONAL'
                );
                if (Account.sObjectType.getDescribe().isAccessible()) {  
                    Database.insert(testAccount_ISEDirect);
                }
            }
            return testAccount_ISEDirect;
        }
        private set;
    }
    
    //IndirectCore Institutional Account
    public static Account testAccount_ISEIndirect {
        get {
            if (testAccount_ISEIndirect == null) {
                testAccount_ISEIndirect = new Account(
                    Name                    = EC_TestData.ACCOUNT_NAME + '_InDirectCore',
                    OwnerId                 = UserInfo.getUserId(),
                    Type                    = 'Customer',
                    BillingStreet           = EC_TestData.generateRandomString(32),
                    BillingCity             = EC_TestData.generateRandomString(32),
                    BillingState            = EC_TestData.generateRandomString(32),
                    BillingCountry          = 'USA',
                    BillingPostalCode       = EC_TestData.generateRandomString(5),
                    EC_Account_Number__c    = EC_TestData.generateRandomString(5),
                    RecordTypeId            = EC_TestData.getRecordType('shipTo'), //Ship To
                    EC_Division__c 			= 'INSTITUTIONAL'
                );
                if (Account.sObjectType.getDescribe().isAccessible()) { 
                	Database.insert(testAccount_ISEIndirect);
                }
            }
            return testAccount_ISEIndirect;
        }
        private set;
    }
        
    /***************************************************************************************************************************************
    Method Name : setupInstSalesEntitlements
    Description : This will insert the INST_Sales_Entitlement__c records   
    Return type : Void
	*************************************************************************************************************************************/  
    public static void setupInstSalesEntitlements(){
        
        List<INST_Sales_Entitlement__c> iseLst = new List<INST_Sales_Entitlement__c>();
        iseLst.add(new INST_Sales_Entitlement__c(Account_Salesforce_Id__c = testAccount_ISEDirect.Id, Taxonomy__c = 'Chemical',
                                                 Product_Salesforce_Id__c = EC_TestData.products[0].Id, SKU__c = EC_TestData.products[0].ccrz__SKU__c,
                                                 Account_Type__c ='HYBRID-DIRECT'));
        
        iseLst.add(new INST_Sales_Entitlement__c(Account_Salesforce_Id__c = testAccount_ISEIndirect.Id, Taxonomy__c = 'Chemical',
                                                 Account_Type__c ='INDIRECT-CORE'));
        
        Database.insert(iseLst);
    }
    
    /***************************************************************************************************************************************
    Method Name : setupAccConRelForUsr
    Description : This will create AccountContactRelation for the User with ISE Accounts    
    Return type : void
	*************************************************************************************************************************************/  
    public static void setupAccConRelForUsr(){
        List<AccountContactRelation> accConRelLst = new List<AccountContactRelation>();
        accConRelLst.add(new AccountContactRelation(AccountId = testAccount_ISEDirect.id, ContactId = testUser.ContactId));
        accConRelLst.add(new AccountContactRelation(AccountId = testAccount_ISEIndirect.id, ContactId = testUser.ContactId));
        Database.insert(accConRelLst);
    }
    
    /***************************************************************************************************************************************
    Method Name : createOrdersForINSTDirect
    Description : Allows to create Order/OrderItem records for ISE-Hybrid-Direct Account    
    Return type : List<ccrz__E_Order__c>
	*************************************************************************************************************************************/  
    public static List<ccrz__E_Order__c> createOrdersForINSTDirect(Integer numberOfOrders) {
        
        final List<ccrz__E_Order__c> testOrderDirect = new List<ccrz__E_Order__c>();
        testOrderDirect.addAll(createOrders(numberOfOrders, testAccount_ISEDirect));
        
        if(testOrderDirect != null) return testOrderDirect;
        return new List<ccrz__E_Order__c>();
    }
    
    /***************************************************************************************************************************************
    Method Name : createOrdersForINSTDirect
    Description : Allows to create Order/OrderItem records for ISE-InDirect-Core Account    
    Return type : List<ccrz__E_Order__c>
	*************************************************************************************************************************************/  
    public static List<ccrz__E_Order__c> createOrdersForINSTIndirect(Integer numberOfOrders) {
        
        final List<ccrz__E_Order__c> testOrderIDirect = new List<ccrz__E_Order__c>();
        testOrderIDirect.addAll(createOrders(numberOfOrders, testAccount_ISEIndirect));
        
        if(testOrderIDirect != null) return testOrderIDirect;
        return new List<ccrz__E_Order__c>();
    }
    
    /***************************************************************************************************************************************
    Method Name : createOrders
    Description : Generic method to create Order/OrderItem records for the Account    
    Return type : List<ccrz__E_Order__c>
	*************************************************************************************************************************************/  
    public static List<ccrz__E_Order__c> createOrders(Integer numberOfOrders, Account instAcc){
        
        final List<ccrz__E_Order__c> testOrders = new List<ccrz__E_Order__c>();
        final List<ccrz__E_Seller__c> sellers = new List<ccrz__E_Seller__c>{
            new ccrz__E_Seller__c(
                
                ccrz__SellerId__c            = 'ABDN',                        
                ccrz__Storefront__c          = EC_TestData.STOREFRONT_NAME,
                ccrz__Enabled__c             = true,
                ccrz__EffectiveStart__c      = Date.Today()-10,
                ccrz__EffectiveEnd__c        = Date.Today()+10
            )
        };
        if (ccrz__E_Seller__c.sObjectType.getDescribe().isAccessible()) {
        	Database.insert(sellers);
        }
        ccrz__E_Cart__c cart = EC_TestData.createCart();
        for (Integer i = 0; i < numberOfOrders; i++) {
            testOrders.add(
                new ccrz__E_Order__c(
                    ccrz__Account__c         	= instAcc.Id,
                    ccrz__Contact__c         	= testUser.ContactId,
                    OwnerId                  	= testUser.Id,
                    ccrz__OrderNumber__c     	= i,
                    ccrz__OrderStatus__c 		='Pending',
                    ccrz__Storefront__c      	= EC_TestData.STOREFRONT_NAME,
                    ccrz__ShipTo__c          	= EC_TestData.shipToAddress.Id,
                    ccrz__OrderDate__c       	= Date.Today(),
                    ccrz__User__c           	= testUser.Id,
                    ccrz__BillTo__c          	= EC_TestData.billToAddress.Id,
                    ccrz__OriginatedCart__c  	= cart.Id,
                    ccrz__EncryptedId__c    	= 'testEncryptedId'+ i.format(),
                    ccrz__Note__c           	= '',  
                    ccrz__ShipComplete__c   	= false,
                    ccrz__ShipMethod__c     	= 'testShip',
                    ccrz__PONumber__c       	= '1233456',
                    ccrz__RequestDate__c    	= system.today()+3,
                    EC_Related_Products__c  	= 'SearchText',
                    ccrz__EffectiveAccountID__c = instAcc.Id
                )
            );
        }
        if (ccrz__E_Order__c.sObjectType.getDescribe().isAccessible()) {
            Database.upsert(testOrders);
        }
        
        final List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
        final List<String> orderIds                     = new List<String>();
        
        for (Integer i = 0; i < numberOfOrders; i++) {
            testOrderItems.add(
                new ccrz__E_OrderItem__c(
                    ccrz__Order__c            = testOrders.get(i).Id,
                    ccrz__Price__c            = 50,
                    ccrz__Quantity__c         = 2,
                    ccrz__SubAmount__c        = 20,
                    ccrz__Product__c          = EC_TestData.products[i].Id,
                    ccrz__Comments__c         = 'testComment',
                    ccrz__OrderLineType__c    = 'Minor',
                    ccrz__RequestDate__c      = system.today(),
                    ccrz__OriginalQuantity__c = 2
                )
            );
            orderIds.add(testOrders.get(i).Id);
        }
        if (ccrz__E_OrderItem__c.sObjectType.getDescribe().isAccessible()) {
            Database.insert(testOrderItems);
        }
        
        if (ccrz__E_Order__c.sObjectType.getDescribe().isAccessible()) {
            return [SELECT Id,OwnerId,ccrz__OriginatedCart__c,ccrz__Account__r.Id,ccrz__Contact__r.Id,ccrz__Contact__c,ccrz__Account__c, ccrz__EncryptedId__c from ccrz__E_Order__c WHERE Id IN :orderIds];
        }
        return new List<ccrz__E_Order__c>();
    }

    /***************************************************************************************************************************************
    Method Name : createQuickListsforISEDirect
    Description : Method to create QuickLists for ISEDirect Account   
    Return type : List<ccrz__E_Cart__c>
	*************************************************************************************************************************************/  
     public static List<ccrz__E_Cart__c> createQuickListsforISEDirect(Integer numberOfLists) {
        
        final List<ccrz__E_Cart__c> testQuickLists = new List<ccrz__E_Cart__c>();
        testQuickLists.addAll(createQuickList(numberOfLists, testAccount_ISEDirect));
        
        if(!testQuickLists.isEmpty()) return testQuickLists;
        
        return new List<ccrz__E_Cart__c>();
    }
    
     /***************************************************************************************************************************************
    Method Name : createQuickListsforISEIndirect
    Description : Method to create QuickLists for ISEIndirect Account   
    Return type : List<ccrz__E_Cart__c>
	*************************************************************************************************************************************/  
     
    public static List<ccrz__E_Cart__c> createQuickListsforISEIndirect(Integer numberOfLists) {
        
        final List<ccrz__E_Cart__c> testQuickLists = new List<ccrz__E_Cart__c>();
        testQuickLists.addAll(createQuickList(numberOfLists, testAccount_ISEIndirect));
        
        if(!testQuickLists.isEmpty()) return testQuickLists;
        
        return new List<ccrz__E_Cart__c>();
    }
    
    /***************************************************************************************************************************************
    Method Name : createQuickList
    Description : Generic method to create QuickLists   
    Return type : List<ccrz__E_Order__c>
	*************************************************************************************************************************************/  
    
    public static List<ccrz__E_Cart__c> createQuickList(Integer numberOfLists, Account insAcc){
        
        
        final List<ccrz__E_Cart__c> testQuickLists = new List<ccrz__E_Cart__c>();
        
        
        for (Integer i = 0; i < numberOfLists; i++) {
            testQuickLists.add(
                new ccrz__E_Cart__c(
                    ccrz__Account__c         = insAcc.Id,
                    ccrz__Contact__c         = testUser.ContactId,
                    OwnerId                  = testUser.Id,
                    ccrz__Storefront__c      = EC_TestData.STOREFRONT_NAME,
                    ccrz__User__c            = testUser.Id,
                    ccrz__EncryptedId__c     = 'testEncryptedId'+ i.format(),
                    ccrz__RequestDate__c     = system.today()+3,
                    ccrz__CartType__c        = 'WishList',
                    EC_PurchasedWishlist__c  = true
                ));
        }
        
        if (ccrz__E_Cart__c.sObjectType.getDescribe().isAccessible()) { 
            Database.upsert(testQuickLists);
        }
        
        final List<ccrz__E_CartItem__c> testQuickListItems = new List<ccrz__E_CartItem__c>();
        final List<String> quickListIds                              = new List<String>();
        
        for (Integer i = 0; i < numberOfLists; i++) {
            testQuickListItems.add(
                new ccrz__E_CartItem__c(
                    ccrz__Cart__c           = testQuickLists.get(i).Id,
                    ccrz__Price__c           = 50,
                    ccrz__Quantity__c        = 2,
                    ccrz__SubAmount__c       = 20,
                    ccrz__Product__c         = EC_TestData.products[i].Id,
                    ccrz__Comments__c        = 'test',
                    ccrz__RequestDate__c     = system.today(),
                    EC_Last_Purchased_Date__c = system.today()
                )
            );
            testQuickListItems.add(
                new ccrz__E_CartItem__c(
                    ccrz__Cart__c           = testQuickLists.get(i).Id,
                    ccrz__Price__c           = 50,
                    ccrz__Quantity__c        = 2,
                    ccrz__SubAmount__c       = 20,
                    ccrz__Product__c         = EC_TestData.products[i+1].Id,
                    ccrz__Comments__c        = 'test',
                    ccrz__RequestDate__c     = system.today(),
                    EC_Last_Purchased_Date__c = system.today()
                ));
            quickListIds.add(testQuickLists.get(i).Id);
        }
        if (ccrz__E_CartItem__c.sObjectType.getDescribe().isAccessible()) { 
            Database.insert(testQuickListItems);
        }
        
        return[SELECT Id,OwnerId,ccrz__Account__r.Id,ccrz__Contact__r.Id,ccrz__Contact__c,ccrz__Account__c, ccrz__EncryptedId__c from ccrz__E_Cart__c WHERE Id IN :quickListIds];
    }    
}