/* Class Name       :EC_TestData
 * Description      :Storing/Creating the test data for all the test classes
 * Created By       :Ashish Kr.
 * Created On       :06-18-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Ashish Kr.                 06-18-2019                                  Test data creation
 * 
 */

public with sharing class EC_TestData{
    // General Constants
        public static final String STOREFRONT_NAME                            = 'DefaultStore'; 
        public static final String ACCOUNT_NAME                               = 'TestAccount';
        public static final String ACCOUNTGROUP_NAME                          = 'TestAccountGroup';
        public static final String ANON_ACCOUNT_NAME                               = 'CCAnonymous';
        public static final String ANON_ACCOUNTGROUP_NAME                          = 'Anonymous';
        public static final String CLOUDCRAZE_CUSTOMER_COMMUNITY_PROFILE_NAME = 'Ecolab Customer Community Plus Users';
        public static final String CLOUDCRAZE_CUSTOMER_GUEST_PROFILE_NAME1 = 'EcolabStore Profile';
        public static final String CLOUDCRAZE_EXTERNAL_PROFILE ='Sales Rep' ;
        public static final String CLOUDCRAZE_CUSTOMER_GUEST_PROFILE_NAME2 = 'EcolabStore Profile';
        public static final String USER_LANGUAGE                              = 'en_US';
        public static final Decimal DEFAULT_PRICE                             = 100.00;
    
        // Category Name Constants
        public static final String STOREFRONT_CATEGORY_ROOT        = 'BP Root';
        public static final String STOREFRONT_CATEGORY_ROOT_IR     = 'IR Root';
        public static final String STOREFRONT_CATEGORY_ROOT_EXT_ID = 'RootExtId';
        public static final String PRODUCT_TYPE_CATEGORY_1         = 'ProductType1';
        public static final String PRODUCT_TYPE_CATEGORY_2         = 'ProductType2';
        public static final String BRAND_CATEGORY_1                = 'Brand1';
        public static final String BRAND_CATEGORY_2                = 'Brand2';
        public static final String BRAND_CATEGORY_3                = 'Brand3';
        public static final String BRAND_CATEGORY_4                = 'Brand4';
        public static final String SUB_BRAND_CATEGORY_1            = 'SubBrand1';
        public static final String SUB_BRAND_CATEGORY_2            = 'SubBrand2';
        public static final String SUB_BRAND_CATEGORY_3            = 'SubBrand3';
        public static final String SUB_BRAND_CATEGORY_4            = 'SubBrand4';
        // case creation constants
        public static final String  BASIC                          =  'Basic';
        public static final String  BUYER                          =  'Buyer';
        public static final String  APPROVED                       =  'Approved';
        public static final String  NEWVAL                         =  'new';
        public static final String  WEB                            =  'web';
        public static final String  CASETYPE                       =  'Access Request';
        public static final String  BASICSET                       =  'EC_BasicSet';
        public static final String  BUYERSET                       =  'EC_BuyerSet';
        public static final String  SOLDTO                         =  'soldTo';
        
        private static Boolean catalogSetupIsComplete = false;
        
        public static ccrz__E_AccountGroup__c testAccountGroup {
            get {
                if (testAccountGroup == null) {
                    testAccountGroup = new ccrz__E_AccountGroup__c( Name = ACCOUNTGROUP_NAME );
                    insert testAccountGroup;
                }
                return testAccountGroup;
            }
            private set;
        }
    
        public static ccrz__E_AccountGroup__c anonAccountGroup {
            get {
                if (anonAccountGroup == null) {
                    anonAccountGroup = new ccrz__E_AccountGroup__c( Name = ANON_ACCOUNTGROUP_NAME );
                    insert anonAccountGroup;
                }
                return anonAccountGroup;
            }
            private set;
        }
        
        public static Account testAccount {
            get {
                if (testAccount == null) {
                    testAccount = new Account(
                            Name                    = ACCOUNT_NAME,
                            ccrz__E_AccountGroup__c = testAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            EC_Division__c          = 'WATER',
                        
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            ShippingCountry          = 'USA',
                            ccrz__SourceSystem__c = 'Test',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = generateRandomString(5),
                            RecordTypeId            = getRecordType('corporate')
                    );
                    insert testAccount;
                }
                return testAccount;
            }
            private set;
        }
        
        public static Account testAccountSoldTo {
            get {
                if (testAccountSoldTo == null) {
                    testAccountSoldTo = new Account(
                            Name                    = ACCOUNT_NAME + ' Sold To',
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = generateRandomString(5),
                            RecordTypeId            = getRecordType(SOLDTO) //Sold To
                            
                    );
                    insert testAccountSoldTo;
                }
                return testAccountSoldTo;
            }
            private set;
        }
        /*
        public static Account testAccountBillTo {
            get {
                if (testAccountBillTo == null) {
                    testAccountBillTo = new Account(
                            Name                    = ACCOUNT_NAME+ ' BILL TO' ,
                            ccrz__E_AccountGroup__c = testAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = generateRandomString(5),
                            RecordTypeId            = '012a0000001WK7MAAW'
                    );
                    insert testAccountBillTo ;
                }
                return testAccountBillTo ;
            }
            private set;
        }
    */
        public static Account testAccountShipTo {
            get {
                if (testAccountShipTo == null) {
                    testAccountShipTo = new Account(
                            Name                    = ACCOUNT_NAME+ ' SHIP TO' ,
                            ccrz__E_AccountGroup__c = testAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            ShippingStreet           = generateRandomString(32),
                            ShippingCity             = generateRandomString(32),
                            ShippingPostalCode      = generateRandomString(5),
                            ShippingCountry         = 'USA',
                            ShippingState           = generateRandomString(5),
                            RecordTypeId            = getRecordType('shipTo'), //Ship To
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = generateRandomString(5),
                            ParentId                = testAccountSoldTo.Id,
                        	EC_Division__c          = 'WATER'
                    );
                    insert testAccountShipTo;
                }
                return testAccountShipTo;
            }
            private set;
        }
        
        public static Account testAccountShipTo2 {
            get {
                if (testAccountShipTo2 == null) {
                    testAccountShipTo2 = new Account(
                            Name                    = ACCOUNT_NAME+ ' SHIP TO2' ,
                            ccrz__E_AccountGroup__c = testAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            ShippingStreet           = generateRandomString(32),
                            ShippingCity             = generateRandomString(32),
                            RecordTypeId            = getRecordType('shipTo'), //Ship To
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = generateRandomString(5),
                            ParentId                = testAccountSoldTo.Id
                    );
                    insert testAccountShipTo2;
                }
                return testAccountShipTo2;
            }
            private set;
        }
        
        public static Account testAccountShipTolone2 {
            get {
                if (testAccountShipTolone2 == null) {
                    testAccountShipTolone2 = new Account(
                            Name                    = ACCOUNT_NAME+ ' SHIP TOlone2' ,
                            ccrz__E_AccountGroup__c = testAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            ShippingStreet           = generateRandomString(32),
                            ShippingCity             = generateRandomString(32),
                            RecordTypeId            = getRecordType('shipTo'), //Ship To
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = generateRandomString(5)
                    );
                    insert testAccountShipTolone2;
                }
                return testAccountShipTolone2;
            }
            private set;
        }
        
        public static Account testAccountShipToFaB {
            get {
                if (testAccountShipToFaB == null) {
                    testAccountShipToFaB = new Account(
                            Name                    = ACCOUNT_NAME+ ' SHIP FaB' ,
                            ccrz__E_AccountGroup__c = testAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            ShippingStreet           = generateRandomString(32),
                            ShippingCity             = generateRandomString(32),
                            RecordTypeId            = getRecordType(SOLDTO), //Ship To
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = generateRandomString(5),
                            EC_Division__c 			= 'FOOD & BEVERAGE'
                    );
                    insert testAccountShipToFaB;
                }
                return testAccountShipToFaB;
            }
            private set;
        }
        public static Account testAccountServiceRequest {
            get {
                if (testAccountShipToFaB == null) {
                    testAccountShipToFaB = new Account(
                            Name                    = 'Testaccount5',
                            ccrz__E_AccountGroup__c = testAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            ShippingStreet           = generateRandomString(32),
                            ShippingCity             = generateRandomString(32),
                            RecordTypeId            = getRecordType(SOLDTO), //Ship To
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = '234555',
                            EC_Division__c 			= 'INSTITUTIONAL'
                    );
                    if(Account.sObjectType.getDescribe().isCreateable()) {
                        insert testAccountShipToFaB;
                    }
                    
                }
                return testAccountShipToFaB;
            }
            private set;
        }
        public static Account testAccountShipTocorp2 {
            get {
                if (testAccountShipTocorp2 == null) {
                    testAccountShipTocorp2 = new Account(
                            Name                    = ACCOUNT_NAME+ ' SHIP TOcorp2' ,
                            ccrz__E_AccountGroup__c = testAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            ShippingStreet           = generateRandomString(32),
                            ShippingCity             = generateRandomString(32),
                            RecordTypeId            = getRecordType('shipTo'), //Ship To
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32),
                            BillingState            = generateRandomString(32),
                            BillingCountry          = 'USA',
                            BillingPostalCode       = generateRandomString(5),
                            EC_Account_Number__c    = generateRandomString(5),
                            ParentId                = testAccount.Id
                    );
                    insert testAccountShipTocorp2;
                }
                return testAccountShipTocorp2;
            }
            private set;
        }
        
        public static Account anonAccount {
            get {
                if (anonAccount == null) {
                    anonAccount = new Account(
                            Name                    = ANON_ACCOUNT_NAME,
                            ccrz__E_AccountGroup__c = anonAccountGroup.Id,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32)
                    );
                    insert anonAccount;
                }
                return anonAccount;
            }
            private set;
        }
        
        
        public static User testUser {
            get {
                if (testUser == null) {
                    setupTestUser();
                }
                return testUser;
            }
            private set;
        }
        
        public static ccrz__E_ContactAddr__c billToAddress {
            get {
                if (billToAddress == null) {
                    billToAddress = getContactAddress();
                    insert billToAddress;
                }
                return billToAddress;
            }
            private set;
        }
    
    
        public static ccrz__E_ContactAddr__c shipToAddress {
            get {
                if (shipToAddress == null) {
                    shipToAddress = getContactAddress();
                    insert shipToAddress;
                }
                return shipToAddress;
            }
            private set;
        }
        
        public static List<ccrz__E_Product__c> products {
            get {
                if (products == null || products.isEmpty()) {
                    setupCatalog();
                }
                return products;
            }
            private set;
        }
        
        public static List<ccrz__E_Spec__c> ccSpecs {
            get {
                if (ccSpecs == null || ccSpecs.isEmpty()) {
                    setupCatalog();
                }
                return ccSpecs;
            }
            private set;
        }
        
        public static List<ccrz__E_ProductSpec__c> productSpecs {
            get {
                if (productSpecs == null || productSpecs.isEmpty()) {
                    setupCatalog();
                }
                return productSpecs;
            }
            private set;
        }
        
        public static List<Product2> productOOB {
            get {
                if (productOOB == null || productOOB.isEmpty()) {
                    setupCatalog();
                }
                return productOOB;
            }
            private set;
        }
     /*   
        public static void createMenu(){
            ccrz__E_Menu__c objSupportCCMenu = new ccrz__E_Menu__c();
            objSupportCCMenu.ccrz__DisplayName__c = 'Support';
            objSupportCCMenu.ccrz__URL__c = 'testSupportURL';
            insert objSupportCCMenu;
        }
       */ 
         public static List<ccrz__E_ProductInventoryItem__c> productsInventory {
            get {
                if (productsInventory == null || productsInventory.isEmpty()) {
                    setupCatalog();
                }
                return productsInventory;
            }
            private set;
        }
        
        public static List<ccrz__E_ProductMedia__c> prodMedia {
            get {
                if (prodMedia == null || prodMedia.isEmpty()) {
                    setupCatalog();
                }
                return prodMedia;
            }
            private set;
        }
        
        public static List<ccrz__E_ProductCategory__c> productCategories {
            get {
                if (productCategories == null) {
                    setupCatalog();
                }
                return productCategories;
            }
            private set;
        }
        public static Map<String,ccrz__E_Category__c> categoryMap {
            get {
                if (categoryMap == null) {
                    categoryMap = new Map<String,ccrz__E_Category__c>();
                    setupCatalog();
                }
                return categoryMap;
            }
            private set;
            }
           
    /***************************************************************************************************************************************
          Method Name : getRecordType
          Description : getRecordType
          Return type : Id
    *************************************************************************************************************************************/
        public static Id getRecordType(String rtype) {
            if(rtype == SOLDTO){
                List<RecordType> recType = [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_SoldTo];
                return recType[0].id;
                
            }else if(rtype == 'shipTo'){
                List<RecordType> recType = [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_ShipTo];
                return recType[0].id;
            }else if(rtype == 'corporate'){
                List<RecordType> recType = [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_Corporate];
                return recType[0].id;
            }
            return 'a0n5C000000TOoT';
        }
    
    
    /***************************************************************************************************************************************
          Method Name : createCart
          Description : createCart is to create Single Cart.
          Return type : ccrz__E_Cart__c
    *************************************************************************************************************************************/
        public static ccrz__E_Cart__c createCart() {
            Account anonAcc = anonAccount;
            ccrz__E_AccountGroup__c anonAccGrp = anonAccountGroup;
            return createCarts(1).get(0);
        }
    
    /***************************************************************************************************************************************
          Method Name : createCarts
          Description : createCarts is to create Cart based on nunmber of Carts passed in input parameter.
          Return type : List<ccrz__E_Cart__c>
    *************************************************************************************************************************************/
        public static List<ccrz__E_Cart__c> createCarts(Integer numberOfCarts) {
    
            final List<ccrz__E_Cart__c> testCarts = new List<ccrz__E_Cart__c>();
            //System.assert(testUser != null);
            for (Integer i = 0; i < numberOfCarts; i++) {
                testCarts.add(
                        new ccrz__E_Cart__c(
                                ccrz__Account__c         = testAccount.Id,
                                ccrz__CartType__c        = 'Cart',
                                ccrz__CartStatus__c      = 'Open',
                                ccrz__User__c            = testUser.Id,
                                ccrz__Contact__c         = testUser.ContactId,
                                ccrz__Name__c            = 'cart',
                                OwnerId                  = testUser.Id,
                                ccrz__AnonymousID__c     = false,
                                ccrz__ActiveCart__c      = true,
                                ccrz__SessionId__c       = 'testing',
                                ccrz__CurrencyISOCode__c = 'USD',
                                ccrz__Storefront__c      = STOREFRONT_NAME,
                                ccrz__EncryptedId__c     = 'encid' + String.valueOf(Crypto.getRandomInteger()),//i
                                ccrz__BillTo__c          = billToAddress.Id,
                                ccrz__ShipTo__c          = shipToAddress.Id,
                                EC_Ship_To_Account__c    = testAccount.Id,
                                EC_Sold_To_Account__c    = testAccountSoldTo.Id,
                                ccrz__PONumber__c           =  '',
                                ccrz__RequestDate__c     = Date.Today()
                        )
                );
            }
            System.assertEquals(testCarts.size(), numberOfCarts);
            upsert testCarts;
            final List<ccrz__E_PaymentDetail__c> testPaymentDetails = new List<ccrz__E_PaymentDetail__c>();
            final List<String> cartIds                              = new List<String>();
    
            for (Integer i = 0; i < numberOfCarts; i++) {
                testPaymentDetails.add(
                        new ccrz__E_PaymentDetail__c(
                                ccrz__Cart__c           = testCarts.get(i).Id,
                                ccrz__Payment_Method__c = 'PO Number',
                                ccrz__Account_Number__c = 'PO' + String.valueOf(i)
                        ));
                cartIds.add(testCarts.get(i).Id);
            }
            insert testPaymentDetails;
    
            return [SELECT Id, ccrz__User__c,ccrz__RequestDate__c,ccrz__ShipTo__c,ccrz__BillTo__c,EC_Sold_To_Account__c,EC_Ship_To_Account__c,ccrz__User__r.Id,ccrz__Account__r.Id,ccrz__Contact__r.Id,ccrz__Contact__c,ccrz__Account__c, ccrz__EncryptedId__c,ccrz__User__r.LanguageLocaleKey
            FROM ccrz__E_Cart__c
            WHERE Id IN :cartIds];
        }
        
        /*------------------------------------------------------------
        Description:   Add Items to Test CC Cart
        ------------------------------------------------------------*/
    
        public static ccrz__E_CartItem__c addCartItem(ccrz__E_Cart__c testCart, Id prodId, Decimal qty, Decimal price) {
            return addCartItems(testCart,
                    new Map<Id,Decimal> { prodId => qty },
                    new Map<Id,Decimal> { prodId => price }).get(0);
        }
        public static List<ccrz__E_CartItem__c> addCartItems(ccrz__E_Cart__c testCart,
                Map<Id,Decimal> productQuantityMap,
                Map<Id,Decimal> productPriceMap
        ) {
            final List<ccrz__E_CartItem__c> items = new List<ccrz__E_CartItem__c>();
            final Map<Id,Decimal> itemPrices      = (null == productPriceMap) ? new Map<Id,Decimal>() : productPriceMap;
    
            for (Id productId : productQuantityMap.keySet()) {
                final Decimal itemPrice = itemPrices.containsKey(productId) ? itemPrices.get(productId) : DEFAULT_PRICE;
                items.add(
                        new ccrz__E_CartItem__c(
                                ccrz__Cart__c         = testCart.Id,
                                ccrz__Quantity__c     = productQuantityMap.get(productId),
                                ccrz__Product__c      = productId,
                                ccrz__Price__c        = itemPrice,
                                ccrz__SubAmount__c    = productQuantityMap.get(productId)*itemPrice,
                                ccrz__UnitOfMeasure__c= 'Each'
                        ));
            }
            insert items;
            return items;
        }
     
    /***************************************************************************************************************************************
          Method Name : createOrders
          Description : createOrders is to create Orders based on nunmber of Orders passed in input parameter.
          Return type : List<ccrz__E_Order__c>
    *************************************************************************************************************************************/
            public static List<ccrz__E_Order__c> createOrders(Integer numberOfOrders) {
    
            final List<ccrz__E_Order__c> testOrders = new List<ccrz__E_Order__c>();
            final List<ccrz__E_Seller__c> sellers = new List<ccrz__E_Seller__c>{
                    new ccrz__E_Seller__c(
                            
                            ccrz__SellerId__c            = 'ABDN',                        
                            ccrz__Storefront__c          = STOREFRONT_NAME,
                            ccrz__Enabled__c             = true,
                            ccrz__EffectiveStart__c      = Date.Today()-10,
                            ccrz__EffectiveEnd__c        = Date.Today()+10
                    )
            };
            insert sellers;
            System.assert(testUser != null);
            ccrz__E_Cart__c cart = createCart();
            for (Integer i = 0; i < numberOfOrders; i++) {
                testOrders.add(
                        new ccrz__E_Order__c(
                                ccrz__Account__c         = testAccount.Id,
                                ccrz__Contact__c         = testUser.ContactId,
                                OwnerId                  = testUser.Id,
                                ccrz__OrderNumber__c     = i,
                                ccrz__OrderStatus__c ='Pending',
                                ccrz__Storefront__c      = STOREFRONT_NAME,
                                ccrz__ShipTo__c          = shipToAddress.Id,
                                ccrz__OrderDate__c       = Date.Today(),
                                ccrz__User__c           = testUser.Id,
                                ccrz__BillTo__c          = billToAddress.Id,
                                ccrz__OriginatedCart__c  = cart.Id,
                                ccrz__EncryptedId__c    = 'testEncryptedId'+ i.format(),
                                ccrz__Note__c           = '',  
                                ccrz__ShipComplete__c   = false,
                                ccrz__ShipMethod__c     = 'test',
                                ccrz__PONumber__c       = '1233456',
                                ccrz__RequestDate__c    = system.today()+3,
                                EC_Related_Products__c  = 'SearchText',
                                ccrz__EffectiveAccountID__c = testAccount.Id
                            
                        ));
            }
            System.assertEquals(testOrders.size(), numberOfOrders);
            upsert testOrders;
    
            final List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
            final List<String> orderIds                              = new List<String>();
    
            for (Integer i = 0; i < numberOfOrders; i++) {
                testOrderItems.add(
                        new ccrz__E_OrderItem__c(
                                ccrz__Order__c           = testOrders.get(i).Id,
                                ccrz__Price__c           = 50,
                                ccrz__Quantity__c        = 2,
                                ccrz__SubAmount__c       = 20,
                                ccrz__Product__c         = products[i].Id,
                                ccrz__Comments__c        = 'test',
                                ccrz__OrderLineType__c = 'Minor',
                                ccrz__RequestDate__c     = system.today(),
                                ccrz__OriginalQuantity__c =2
                        ));
                orderIds.add(testOrders.get(i).Id);
            }
            insert testOrderItems;
    
            return[SELECT Id,OwnerId,ccrz__OriginatedCart__c,ccrz__Account__r.Id,ccrz__Contact__r.Id,ccrz__Contact__c,ccrz__Account__c, ccrz__EncryptedId__c from ccrz__E_Order__c WHERE Id IN :orderIds];
        }
        
/***************************************************************************************************************************************
Method Name : createOrderItems
Description : createOrderItems is to create OrderItems based input parameters.
Return type : ccrz__E_OrderItem__c
*************************************************************************************************************************************/
    public static ccrz__E_OrderItem__c createOrderItems(Id orderId, Id productId) {
        return new ccrz__E_OrderItem__c(
            ccrz__Order__c           = orderId,
            ccrz__Price__c           = 50,
            ccrz__Quantity__c        = 2,
            ccrz__SubAmount__c       = 20,
            ccrz__Product__c         = productId,
            ccrz__Comments__c        = 'test',
            ccrz__OrderLineType__c = 'Minor',
            ccrz__RequestDate__c     = system.today(),
            ccrz__OriginalQuantity__c =2
        );   
    }
        public static List<ccrz__E_Order__c> createShipToOrders(Integer numberOfOrders) {
    
            final List<ccrz__E_Order__c> testOrders = new List<ccrz__E_Order__c>();
            final List<ccrz__E_Seller__c> sellers = new List<ccrz__E_Seller__c>{
                    new ccrz__E_Seller__c(
                            
                            ccrz__SellerId__c            = 'ABDN',                        
                            ccrz__Storefront__c          = STOREFRONT_NAME,
                            ccrz__Enabled__c             = true,
                            ccrz__EffectiveStart__c      = Date.Today()-10,
                            ccrz__EffectiveEnd__c        = Date.Today()+10
                    )
            };
            if (ccrz__E_Seller__c.sObjectType.getDescribe().isAccessible()) {
                insert sellers;
            }
            ccrz__E_Cart__c cart = createCart();
            for (Integer i = 0; i < numberOfOrders; i++) {
                testOrders.add(
                        new ccrz__E_Order__c(
                                ccrz__Account__c         = testAccountShipTo.Id,
                                ccrz__Contact__c         = testUser.ContactId,
                                OwnerId                  = testUser.Id,
                                ccrz__OrderNumber__c     = i,
                                ccrz__OrderStatus__c ='Pending',
                                ccrz__Storefront__c      = STOREFRONT_NAME,
                                ccrz__ShipTo__c          = shipToAddress.Id,
                                ccrz__OrderDate__c       = Date.Today(),
                                ccrz__User__c           = testUser.Id,
                                ccrz__BillTo__c          = billToAddress.Id,
                                ccrz__OriginatedCart__c  = cart.Id,
                                ccrz__EncryptedId__c    = 'testEncryptedId'+ i.format(),
                                ccrz__Note__c           = '',  
                                ccrz__ShipComplete__c   = false,
                                ccrz__ShipMethod__c     = 'test',
                                ccrz__PONumber__c       = '1233456',
                                ccrz__RequestDate__c    = system.today()+3,
                                EC_Related_Products__c  = 'SearchText',
                                ccrz__EffectiveAccountID__c = testAccountShipTo.Id
                            
                        ));
            }
            if (ccrz__E_Order__c.sObjectType.getDescribe().isAccessible()) {
                upsert testOrders;
            }
    
            final List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
            final List<String> orderIds                              = new List<String>();
    
            for (Integer i = 0; i < numberOfOrders; i++) {
                testOrderItems.add(
                        new ccrz__E_OrderItem__c(
                                ccrz__Order__c           = testOrders.get(i).Id,
                                ccrz__Price__c           = 50,
                                ccrz__Quantity__c        = 2,
                                ccrz__SubAmount__c       = 20,
                                ccrz__Product__c         = products[i].Id,
                                ccrz__Comments__c        = 'test',
                                ccrz__OrderLineType__c = 'Minor',
                                ccrz__RequestDate__c     = system.today(),
                                ccrz__OriginalQuantity__c =2
                        ));
                orderIds.add(testOrders.get(i).Id);
            }
            if (ccrz__E_OrderItem__c.sObjectType.getDescribe().isAccessible()) {
                insert testOrderItems;
            }
    
            if (ccrz__E_Order__c.sObjectType.getDescribe().isAccessible()) {
                return[SELECT Id,OwnerId,ccrz__OriginatedCart__c,ccrz__Account__r.Id,ccrz__Contact__r.Id,ccrz__Contact__c,ccrz__Account__c, ccrz__EncryptedId__c from ccrz__E_Order__c WHERE Id IN :orderIds];
            }
            return new List<ccrz__E_Order__c>();
        }
    /*
    public static List<ccrz__E_Order__c> createOrdersForBatch(Integer numberOfOrders) {
    
            final List<ccrz__E_Order__c> testOrders = new List<ccrz__E_Order__c>();
            final List<ccrz__E_Seller__c> sellers = new List<ccrz__E_Seller__c>{
                    new ccrz__E_Seller__c(
                            
                            ccrz__SellerId__c            = 'ABDN',                        
                            ccrz__Storefront__c          = STOREFRONT_NAME,
                            ccrz__Enabled__c             = true,
                            ccrz__EffectiveStart__c      = Date.Today()-10,
                            ccrz__EffectiveEnd__c        = Date.Today()+10
                    )
            };
            insert sellers;
            System.assert(testUser != null);
            ccrz__E_Cart__c cart = createCart();
            for (Integer i = 0; i < numberOfOrders; i++) {
                testOrders.add(
                        new ccrz__E_Order__c(
                                ccrz__Account__c         = testAccount.Id,
                                ccrz__Contact__c         = testUser.ContactId,
                                OwnerId                  = testUser.Id,
                                ccrz__OrderNumber__c     = i,
                                ccrz__OrderStatus__c ='Order Submitted',
                                ccrz__Storefront__c      = STOREFRONT_NAME,
                                ccrz__ShipTo__c          = shipToAddress.Id,
                                ccrz__OrderDate__c       = Date.Today(),
                                ccrz__User__c           = testUser.Id,
                                ccrz__BillTo__c          = billToAddress.Id,
                                ccrz__OriginatedCart__c  = cart.Id,
                                ccrz__EncryptedId__c    = 'testEncryptedId'+ i.format(),
                                ccrz__Note__c           = '',  
                                ccrz__ShipComplete__c   = false,
                                ccrz__ShipMethod__c     = 'test',
                                ccrz__PONumber__c       = '1233456',
                                ccrz__RequestDate__c    = system.today()+3
                                
                        ));
            }
            System.assertEquals(testOrders.size(), numberOfOrders);
            upsert testOrders;
    
            final List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c>();
            final List<String> orderIds                              = new List<String>();
    
            for (Integer i = 0; i < numberOfOrders; i++) {
                testOrderItems.add(
                        new ccrz__E_OrderItem__c(
                                ccrz__Order__c           = testOrders.get(i).Id,
                                ccrz__Price__c           = 50,
                                ccrz__Quantity__c        = 2,
                                ccrz__SubAmount__c       = 20,
                                ccrz__Product__c         = products[i].Id,
                                ccrz__Comments__c        = 'test'
                        ));
                orderIds.add(testOrders.get(i).Id);
            }
            insert testOrderItems;
    
            return[SELECT Id,OwnerId,ccrz__OriginatedCart__c,ccrz__User__c,ccrz__Account__r.Id,ccrz__Contact__r.Id,ccrz__Contact__c,ccrz__Account__c, ccrz__EncryptedId__c from ccrz__E_Order__c WHERE Id IN :orderIds];
        }
     */   
    /***************************************************************************************************************************************
          Method Name : setupCatalog
          Description : setupCatalog is to create Create Product Catalog in Storefront
          Return type : void
    *************************************************************************************************************************************/
        public static void setupCatalog() {
            if (catalogSetupIsComplete) {
                return;
            }
            catalogSetupIsComplete = true;
            
            //******************************************************************************
            // INSERT EC_PermissionSetMapping SETTINGS
            //******************************************************************************
            final List<EC_PermissionSetMapping__c> permissionSetMaps = new List<EC_PermissionSetMapping__c>{
                    new EC_PermissionSetMapping__c(
                            Name                               = 'Basic',
                            EC_PermissionSetList__c            = 'EC_BasicSet'                       
                    ),new EC_PermissionSetMapping__c(
                            Name                               = 'Buyer',
                            EC_PermissionSetList__c            = 'EC_BuyerSet'                        
                    )
            };
            insert permissionSetMaps;
    
            //******************************************************************************
            // INSERT STOREFRONT SETTINGS
            //******************************************************************************
            ccrz.cc_util_Reflection.createStorefrontSetting(STOREFRONT_NAME);
            ccrz.cc_util_Reflection.updateStorefrontSettings(STOREFRONT_NAME, 'ccrz__DefaultLanguage__c', USER_LANGUAGE);
    
            System.debug('@@Created storefront setting: ' + STOREFRONT_NAME);
    
             final List<ccrz__E_Seller__c> sellers = new List<ccrz__E_Seller__c>{
                    new ccrz__E_Seller__c(
                            
                            ccrz__SellerId__c            = 'SIEMENS',                        
                            ccrz__Storefront__c          = STOREFRONT_NAME,
                            ccrz__Enabled__c             = true,
                            ccrz__EffectiveStart__c      = Date.Today()-10,
                            ccrz__EffectiveEnd__c        = Date.Today()+10
                    )
            };
            insert sellers;
            //******************************************************************************
            // INSERT PRICE LISTS
            //******************************************************************************
            final List<ccrz__E_PriceList__c> priceLists = new List<ccrz__E_PriceList__c> {
                    new ccrz__E_PriceList__c(
                            Name                     = 'PL002',
                            ccrz__CurrencyISOCode__c = 'USD',
                            ccrz__Enabled__c         = true,
                            ccrz__Storefront__c      = STOREFRONT_NAME,
                            ccrz__StartDate__c       = Date.today().addDays(-7),
                            ccrz__EndDate__c         = Date.today().addDays(7),
                            ccrz__Seller__c          = sellers[0].Id,
                            ccrz__PricelistId__c  = '250287-SIEMENS'
                            
                    )
            };
            insert priceLists;
            
            final List<ccrz__E_AccountGroupPriceList__c> testAccountGroupPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
    
            for (ccrz__E_PriceList__c priceList : priceLists) {
                testAccountGroupPriceLists.add(
                        new ccrz__E_AccountGroupPriceList__c(
                                ccrz__AccountGroup__c = testAccountGroup.Id,
                                EC_Price_List_Type__c = 'Z1MP',
                                ccrz__PriceList__c    = priceList.Id,
                                ccrz__Enable__c       = true
                        ));
                testAccountGroupPriceLists.add(
                        new ccrz__E_AccountGroupPriceList__c(
                                ccrz__AccountGroup__c = anonAccountGroup.Id,
                                EC_Price_List_Type__c = 'Z1MP',
                                ccrz__PriceList__c    = priceList.Id,
                                ccrz__Enable__c       = true
                        ));
            }
            
            System.debug('InEC_TestData_accntgrupList'+testAccountGroupPriceLists);
            insert testAccountGroupPriceLists;
            
            //******************************************************************************
            // INSERT PRODUCTS
            //******************************************************************************
            products = new List<ccrz__E_Product__c>{
                    new ccrz__E_Product__c(
                            Name                       = 'product001 Bag',
                            ccrz__SKU__c               = 'test001',
                            ccrz__ProductId__c         = 'test001',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = true,
                            ccrz__ShortDesc__c       ='product001 Bag',
                            ccrz__LongDesc__c       ='product001 Bag',
                        ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product002',
                            ccrz__SKU__c               = 'test002',
                            ccrz__ProductId__c         = 'test002',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = true,
                            ccrz__ShortDesc__c       ='product002 Bag',
                            ccrz__LongDesc__c       ='product002 Bag',
                        ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
    
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product003',
                            ccrz__SKU__c               = 'test003',
                            ccrz__ProductId__c         = 'test003',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = true,
                        ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
               
                
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product004',
                            ccrz__SKU__c               = 'test/test004',
                            ccrz__ProductId__c         = 'test004',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = true,
                            ccrz__ShortDesc__c       ='product004',
                            ccrz__LongDesc__c       ='product004',
                        ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
                            
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product005 Pallet',
                            ccrz__SKU__c               = 'test005',
                            ccrz__ProductId__c         = 'test005',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = true,
                            ccrz__ShortDesc__c       ='product005',
                            ccrz__LongDesc__c       ='product005',
                        ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent
                            ),
                    new ccrz__E_Product__c(
                            Name                       = 'product007',
                            ccrz__SKU__c               = 'test007',
                            ccrz__ProductId__c         = 'test007',
                            ccrz__ProductStatus__c     = 'Blocked',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='product007',
                            ccrz__LongDesc__c       ='product007'
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'FILTER IN-LINE',
                            ccrz__SKU__c               = '023 20878 001',
                            ccrz__ProductId__c         = '023 20878 001',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='FILTER IN-LINE',
                            ccrz__LongDesc__c       ='FILTER IN-LINE'
                 ),
                    new ccrz__E_Product__c(
                            Name                       = 'HG Layer',
                            ccrz__SKU__c               = '0001823',
                            ccrz__ProductId__c         = '0001823',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500, 
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='HG Layer',
                            ccrz__LongDesc__c       ='HG Layer'
                                  
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product',
                            ccrz__SKU__c               = '3003340-303',
                            ccrz__ProductId__c         = '3003340-303',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='SIEMENS',
                            ccrz__LongDesc__c       ='SIEMENS'
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product 20',
                            ccrz__SKU__c               = '612435',
                            ccrz__ProductId__c         = '612435',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='SIEMENS 20',
                            ccrz__LongDesc__c       ='SIEMENS 20'
                ),
                    new ccrz__E_Product__c(
                            Name                       = 'product 30',
                            ccrz__SKU__c               = '72369',
                            ccrz__ProductId__c         = '72369',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='SIEMENS 30',
                            ccrz__LongDesc__c       ='SIEMENS 30'                   
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product 40',
                            ccrz__SKU__c               = '43166',
                            ccrz__ProductId__c         = '43166',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='SIEMENS 40',
                            ccrz__LongDesc__c       ='SIEMENS 40'                  
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product 50',
                            ccrz__SKU__c               = '16251652',
                            ccrz__ProductId__c         = '16251652',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='SIEMENS 50',
                            ccrz__LongDesc__c       ='SIEMENS 50'
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product 60',
                            ccrz__SKU__c               = '97827',
                            ccrz__ProductId__c         = '97827',
                            ccrz__ProductStatus__c     = 'Released',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='SIEMENS 60',
                            ccrz__LongDesc__c       ='SIEMENS 60'                 
                    ),
                    new ccrz__E_Product__c(
                            Name                       = 'product420',
                            ccrz__SKU__c               = '00000000000012345323421',
                            ccrz__ProductId__c         = '97827420',
                            ccrz__ProductStatus__c     = 'Released420',
                            ccrz__UnitOfMeasure__c     = 'BG',
                            ccrz__StartDate__c         = Date.today().addDays(-7),
                            ccrz__EndDate__c           = Date.today().addDays(7),
                            ccrz__Storefront__c        = STOREFRONT_NAME,
                            ccrz__ProductWeight__c     = 500,
                            ccrz__HazardousFlag__c     = false,
                            ccrz__ShortDesc__c       ='SIEMENS 420',
                            ccrz__LongDesc__c       ='SIEMENS 420'                 
                    )                        
            };
            insert products;
            
            //******************************************************************************
            // INSERT CC SPECS
            //******************************************************************************
            ccSpecs = new List<ccrz__E_Spec__c>{
                new ccrz__E_Spec__c(
                            Name                       = 'SPEC 1',
                            ccrz__UseForFilter__c      = true,
                            ccrz__DisplayName__c       = 'SPEC 1',
                            ccrz__FilterDisplayName__c = 'SPEC 1',
                            ccrz__FilterType__c        = 'Checkbox'
                ),
                new ccrz__E_Spec__c(
                            Name                       = 'SPEC 1',
                            ccrz__UseForFilter__c      = true,
                            ccrz__DisplayName__c       = 'SPEC 1',
                            ccrz__FilterDisplayName__c = 'SPEC 1',
                            ccrz__FilterType__c        = 'Checkbox'
                ),
                new ccrz__E_Spec__c(
                            Name                       = 'SPEC 1',
                            ccrz__UseForFilter__c      = true,
                            ccrz__DisplayName__c       = 'SPEC 1',
                            ccrz__FilterDisplayName__c = 'SPEC 1',
                            ccrz__FilterType__c        = 'Checkbox'
                )
            };
            insert ccSpecs;
            
            //******************************************************************************
            // INSERT PRODSPECS
            //******************************************************************************
            productSpecs = new List<ccrz__E_ProductSpec__c>{
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[0].id,
                            ccrz__Spec__c              = ccSpecs[0].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                ),
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[1].id,
                            ccrz__Spec__c              = ccSpecs[0].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                ),
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[2].id,
                            ccrz__Spec__c              = ccSpecs[0].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                ),
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[0].id,
                            ccrz__Spec__c              = ccSpecs[1].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                ),
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[1].id,
                            ccrz__Spec__c              = ccSpecs[1].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                ),
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[2].id,
                            ccrz__Spec__c              = ccSpecs[1].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                ),
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[0].id,
                            ccrz__Spec__c              = ccSpecs[2].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                ),
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[1].id,
                            ccrz__Spec__c              = ccSpecs[2].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                ),
                new ccrz__E_ProductSpec__c(
                            ccrz__Product__c           = products[2].id,
                            ccrz__Spec__c              = ccSpecs[2].id,
                            ccrz__SpecValue__c         = 'SPEC 1'
                )
            };
            insert productSpecs;
            
            /// Insert SFID products 
            productOOB=new List<Product2>{
                    new Product2(
                            Name                       = 'test001',
                            ProductCode               = 'test001'
                            
                    )
            };
            insert productOOB;
            
            //******************************************************************************
            // INSERT ccrz__E_RelatedProduct__c
            //******************************************************************************
            final List<ccrz__E_RelatedProduct__c> relatedProd = new List<ccrz__E_RelatedProduct__c> {
                    new ccrz__E_RelatedProduct__c(
                          ccrz__Product__c = products[8].Id,
                          ccrz__RelatedProduct__c = products[7].Id,
                          ccrz__RelatedProductType__c='Dependent'
                    ),
                    new ccrz__E_RelatedProduct__c(
                          ccrz__Product__c = products[9].Id,
                          ccrz__RelatedProduct__c = products[7].Id,
                          ccrz__RelatedProductType__c='Seasonal'
                    ),
                     new ccrz__E_RelatedProduct__c(
                          ccrz__Product__c = products[9].Id,
                          ccrz__RelatedProduct__c = products[8].Id,
                          ccrz__RelatedProductType__c='Seasonal'
                    ),
                     new ccrz__E_RelatedProduct__c(
                          ccrz__Product__c = products[9].Id,
                          ccrz__RelatedProduct__c = products[1].Id,
                          ccrz__RelatedProductType__c='Replaced'
                    ),
                     new ccrz__E_RelatedProduct__c(
                          ccrz__Product__c = products[9].Id,
                          ccrz__RelatedProduct__c = products[10].Id,
                          ccrz__RelatedProductType__c='Alternate'
                    ),
                    new ccrz__E_RelatedProduct__c(
                          ccrz__Product__c = products[10].Id,
                          ccrz__RelatedProduct__c = products[7].Id
                    ),
                    new ccrz__E_RelatedProduct__c(
                          ccrz__Product__c = products[11].Id,
                          ccrz__RelatedProduct__c = products[7].Id
                    )
            };
            insert relatedProd;
            
            //******************************************************************************
            // INSERT ccrz__E_FeaturedProduct__c
            //******************************************************************************
            final List<ccrz__E_FeaturedProduct__c> spotlightProd = new List<ccrz__E_FeaturedProduct__c> {
                    new ccrz__E_FeaturedProduct__c(
                        ccrz__Product__c = products[8].Id,
                        ccrz__Type__c = 'Spotlight',
                        ccrz__Enabled__c=true                
                ),
                    new ccrz__E_FeaturedProduct__c(
                        ccrz__Product__c = products[7].Id,
                        ccrz__Type__c = 'Spotlight',
                        ccrz__Enabled__c=true  
                    )
                    
            };
            insert spotlightProd;
            
            //******************************************************************************
            // INSERT PRODUCTSINVEMTORY
            //******************************************************************************
            
            productsInventory = new List<ccrz__E_ProductInventoryItem__c>{
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample1',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[8].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                            
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample2',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[0].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                            
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample3',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[1].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                            
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample4',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[1].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                            
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample5',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[1].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                            
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample6',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[0].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                            
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample7',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[0].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                                              
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample8',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[7].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                                            
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample9',
                            ccrz__Status__c          = 'Replaced',
                            ccrz__ProductItem__c       = products[8].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                                            
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample10',
                            ccrz__Status__c          = 'Discontinued',
                            ccrz__ProductItem__c       = products[9].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                                         
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample11',
                            ccrz__Status__c          = 'Out of Season',
                            ccrz__ProductItem__c       = products[10].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                                              
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample12',
                            ccrz__Status__c          = 'Unavailable',
                            ccrz__ProductItem__c       = products[11].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                                             
                    ),
                    new ccrz__E_ProductInventoryItem__c(
                            Name                       = 'Sample13',
                            ccrz__Status__c          = 'Available',
                            ccrz__ProductItem__c       = products[12].Id,
                            ccrz__AvailabilityMessage__c ='Available'
                                          
                    )
            };
            insert productsInventory;
            
            List<ccrz__E_ProductInventoryItem__c> inventorySkus= [select ccrz__ProductItem__r.ccrz__SKU__c
                                                                        from ccrz__E_ProductInventoryItem__c
                                                                        where ccrz__ProductItem__r.ccrz__SKU__c IN ('3003340-303')];
                
                
            //final List<ccrz__E_ProductMedia__c> productMedia    = new List<ccrz__E_ProductMedia__c>();
            final List<ccrz__E_ProductItemI18N__c> producti18ns = new List<ccrz__E_ProductItemI18N__c>();
            final List<ccrz__E_PriceListItem__c> priceListItems = new List<ccrz__E_PriceListItem__c>();
        
        prodMedia = new List<ccrz__E_ProductMedia__c>{
                        new ccrz__E_ProductMedia__c(
                                ccrz__Product__c            = products[7].Id,
                                ccrz__FilePath__c           = generateRandomString(10),
                                ccrz__ProductMediaSource__c = 'static',
                                ccrz__StaticResourceName__c = generateRandomString(10),
                                ccrz__MediaType__c='Product Image',
                                ccrz__URI__c=generateRandomString(10)
                        ),
                        new ccrz__E_ProductMedia__c(
                                ccrz__Product__c            = products[1].Id,
                                ccrz__FilePath__c           = generateRandomString(10),
                                ccrz__ProductMediaSource__c = 'static',
                                ccrz__StaticResourceName__c = generateRandomString(10),
                                ccrz__MediaType__c='Product Image',
                                ccrz__URI__c=generateRandomString(10)
                        ),
                        new ccrz__E_ProductMedia__c(
                                ccrz__Product__c            = products[8].Id,
                                ccrz__FilePath__c           = generateRandomString(10),
                                ccrz__ProductMediaSource__c = 'static',
                                ccrz__StaticResourceName__c = generateRandomString(10),
                                ccrz__MediaType__c='Safety Documents',
                                ccrz__URI__c=generateRandomString(10)
                        ),
                        new ccrz__E_ProductMedia__c(
                                ccrz__Product__c            = products[8].Id,
                                ccrz__FilePath__c           = generateRandomString(10),
                                ccrz__ProductMediaSource__c = 'static',
                                ccrz__StaticResourceName__c = generateRandomString(10),
                                ccrz__MediaType__c='Safety Documents',
                                ccrz__URI__c=generateRandomString(10)
                        ),
                        new ccrz__E_ProductMedia__c(
                                ccrz__Product__c            = products[9].Id,
                                ccrz__FilePath__c           = generateRandomString(10),
                                ccrz__ProductMediaSource__c = 'static',
                                ccrz__StaticResourceName__c = generateRandomString(10),
                                ccrz__MediaType__c='Product Image',
                                ccrz__URI__c=generateRandomString(10)
                        ),
                        new ccrz__E_ProductMedia__c(
                                ccrz__Product__c            = products[2].Id,
                                ccrz__FilePath__c           = generateRandomString(10),
                                ccrz__ProductMediaSource__c = 'static',
                                ccrz__StaticResourceName__c = generateRandomString(10),
                                ccrz__MediaType__c='Product Image',
                                ccrz__URI__c=generateRandomString(10)
                        ),
                        new ccrz__E_ProductMedia__c(
                                ccrz__Product__c            = products[3].Id,
                                ccrz__FilePath__c           = generateRandomString(10),
                                ccrz__ProductMediaSource__c = 'static',
                                ccrz__StaticResourceName__c = generateRandomString(10),
                                ccrz__MediaType__c='Product Image',
                                ccrz__URI__c=generateRandomString(10)
                        )
                        };
             insert prodMedia;
        for (ccrz__E_Product__c product : products) {
                
    
                producti18ns.add(
                        new ccrz__E_ProductItemI18N__c(
                                Name             = product.Name + '-de',
                                ccrz__Locale__c  = 'de',
                                ccrz__Product__c = product.Id
                        ));
    
                priceListItems.add(
                        new ccrz__E_PriceListItem__c(
                                ccrz__Pricelist__c = priceLists.get(0).Id,
                                ccrz__Product__c   = product.Id,
                                ccrz__StartDate__c = Date.today().addDays(-7),
                                ccrz__EndDate__c   = Date.today().addDays(7),
                                ccrz__Price__c     = DEFAULT_PRICE
                        ));
            }
            insert producti18ns;
            insert priceListItems;
    
            //******************************************************************************
            // INSERT CATEGORIES
            //******************************************************************************
    
            // all root
            ccrz__E_Category__c testAllRoot = new ccrz__E_Category__c(
                    Name                = 'Products',
                    ccrz__CategoryID__c = '0',
                    ccrz__StartDate__c  = Date.today().addDays(-1),
                    ccrz__EndDate__c    = Date.today().addDays(1)
            );
            insert testAllRoot;
            categoryMap.put('testAllRoot', testAllRoot);
    
            // storefront root for BP
            ccrz__E_Category__c storefrontRoot = new ccrz__E_Category__c(
                    Name                    = STOREFRONT_CATEGORY_ROOT,
                    ccrz__CategoryID__c     = STOREFRONT_CATEGORY_ROOT_EXT_ID,
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = testAllRoot.Id
            );
            insert storefrontRoot;
    
            categoryMap.put(STOREFRONT_CATEGORY_ROOT, storefrontRoot);
    
            // product types
            List<ccrz__E_Category__c> productTypes = new List<ccrz__E_Category__c>();
    
            ccrz__E_Category__c productType1 = new ccrz__E_Category__c(
                    Name                    = PRODUCT_TYPE_CATEGORY_1,
                    ccrz__CategoryID__c     = PRODUCT_TYPE_CATEGORY_1 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = storefrontRoot.Id
            );
            ccrz__E_Category__c productType2 = new ccrz__E_Category__c(
                    Name                    = PRODUCT_TYPE_CATEGORY_2,
                    ccrz__CategoryID__c     = PRODUCT_TYPE_CATEGORY_2 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = storefrontRoot.Id
            );
            productTypes.add(productType1);
            productTypes.add(productType2);
            insert productTypes;
            categoryMap.put(PRODUCT_TYPE_CATEGORY_1, productType1);
            categoryMap.put(PRODUCT_TYPE_CATEGORY_2, productType2);
    
            // brands
            List<ccrz__E_Category__c> brands = new List<ccrz__E_Category__c>();
    
            ccrz__E_Category__c brand1 = new ccrz__E_Category__c(
                    Name                    = BRAND_CATEGORY_1,
                    ccrz__CategoryID__c     = BRAND_CATEGORY_1 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = productType1.Id,
                    ccrz__Sequence__c       = 1
            );
            ccrz__E_Category__c brand2 = new ccrz__E_Category__c(
                    Name                    = BRAND_CATEGORY_2,
                    ccrz__CategoryID__c     = BRAND_CATEGORY_2 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = productType1.Id,
                    ccrz__Sequence__c       = 1
            );
            ccrz__E_Category__c brand3 = new ccrz__E_Category__c(
                    Name                    = BRAND_CATEGORY_3,
                    ccrz__CategoryID__c     = BRAND_CATEGORY_3 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = productType2.Id,
                    ccrz__Sequence__c       = 1
            );
            ccrz__E_Category__c brand4 = new ccrz__E_Category__c(
                    Name                    = BRAND_CATEGORY_4,
                    ccrz__CategoryID__c     = BRAND_CATEGORY_4 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = productType2.Id,
                    ccrz__Sequence__c       = 1
            );
            brands.add(brand1);
            brands.add(brand2);
            brands.add(brand3);
            brands.add(brand4);
            insert brands;
            categoryMap.put(BRAND_CATEGORY_1, brand1);
            categoryMap.put(BRAND_CATEGORY_2, brand2);
            categoryMap.put(BRAND_CATEGORY_3, brand3);
            categoryMap.put(BRAND_CATEGORY_3, brand4);
    
            // sub-brands
            List<ccrz__E_Category__c> subBrands = new List<ccrz__E_Category__c>();
    
            ccrz__E_Category__c subbrand1 = new ccrz__E_Category__c(
                    Name                    = SUB_BRAND_CATEGORY_1,
                    ccrz__CategoryID__c     = SUB_BRAND_CATEGORY_1 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = brand1.Id,
                    ccrz__Sequence__c       = 2
            );
            ccrz__E_Category__c subbrand2 = new ccrz__E_Category__c(
                    Name                    = SUB_BRAND_CATEGORY_2,
                    ccrz__CategoryID__c     = SUB_BRAND_CATEGORY_2 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = brand2.Id,
                    ccrz__Sequence__c       = 2
            );
            ccrz__E_Category__c subbrand3 = new ccrz__E_Category__c(
                    Name                    = SUB_BRAND_CATEGORY_3,
                    ccrz__CategoryID__c     = SUB_BRAND_CATEGORY_3 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = brand1.Id,
                    ccrz__Sequence__c       = 2
            );
            ccrz__E_Category__c subbrand4 = new ccrz__E_Category__c(
                    Name                    = SUB_BRAND_CATEGORY_4,
                    ccrz__CategoryID__c     = SUB_BRAND_CATEGORY_4 + '_ID',
                    ccrz__StartDate__c      = Date.today().addDays(-1),
                    ccrz__EndDate__c        = Date.today().addDays(1),
                    ccrz__ParentCategory__c = brand2.Id,
                    ccrz__Sequence__c       = 2
            );
            subBrands.add(subBrand1);
            subBrands.add(subBrand2);
            subBrands.add(subBrand3);
            subBrands.add(subBrand4);
            insert subBrands;
            categoryMap.put(SUB_BRAND_CATEGORY_1, subbrand1);
            categoryMap.put(SUB_BRAND_CATEGORY_2, subbrand2);
            categoryMap.put(SUB_BRAND_CATEGORY_3, subbrand3);
            categoryMap.put(SUB_BRAND_CATEGORY_4, subbrand4);
    
            //******************************************************************************
            // INSERT PRODUCT CATEGORIES
            // TODO: needs to be updated with category structure for all products
            //******************************************************************************
            productCategories = new List<ccrz__E_ProductCategory__c>();
            ccrz__E_ProductCategory__c product001subbrand1 = new ccrz__E_ProductCategory__c(
                    ccrz__Product__c  = products.get(0).Id,
                    ccrz__Category__c = subbrand1.Id
            );
            ccrz__E_ProductCategory__c product002subbrand2 = new ccrz__E_ProductCategory__c(
                    ccrz__Product__c  = products.get(1).Id,
                    ccrz__Category__c = subbrand2.Id
            );
    
            ccrz__E_ProductCategory__c product003subbrand3 = new ccrz__E_ProductCategory__c(
                    ccrz__Product__c  = products.get(2).Id,
                    ccrz__Category__c = subbrand3.Id
            );
            ccrz__E_ProductCategory__c product004subbrand4 = new ccrz__E_ProductCategory__c(
                    ccrz__Product__c  = products.get(3).Id,
                    ccrz__Category__c = subbrand4.Id
            );
            ccrz__E_ProductCategory__c product005subbrand4 = new ccrz__E_ProductCategory__c(
                    ccrz__Product__c  = products.get(4).Id,
                    ccrz__Category__c = subbrand4.Id
            );
    
            productCategories.add(product001subbrand1);
            productCategories.add(product002subbrand2);
            productCategories.add(product003subbrand3);
            productCategories.add(product004subbrand4);
            productCategories.add(product005subbrand4);
            insert productCategories;
    
            System.debug(Limits.getQueries() + ' of ' + Limits.getLimitQueries() + ' SOQL queries issued.');
    
        }
    
    /***************************************************************************************************************************************
          Method Name : setupTestUser
          Description : setupTestUser is to setup user for Test Class execution
          Return type : void
    *************************************************************************************************************************************/
    
        public static void setupTestUser() {
            
            
            Contact contactCC = new Contact(
                    FirstName = 'CloudCraze',
                    LastName  = 'TestUser',
                    Email = 'abc@xyz.com',
                    AccountId = testAccount.Id,
                    MailingStreet = 'abc'
            );
            insert contactCC;
            User testOwner = [SELECT TimeZoneSidKey, UserRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()];
            system.runAs(testOwner){
                
                UserRole role = new UserRole (DeveloperName = 'TestUser_X' , Name = 'TestUser_X' );
                insert role;
                
                Profile profile = [SELECT Id
                FROM Profile
                WHERE Name = :CLOUDCRAZE_CUSTOMER_COMMUNITY_PROFILE_NAME LIMIT 1];
        
                
        
                String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
                testUser = new User(
                        Alias                    = 'cctest',
                        Email                    = emailAddress,
                        EmailEncodingKey         = 'UTF-8',
                        LastName                 = 'TestUser',
                        LanguageLocaleKey        = 'en_US',
                        LocaleSidKey             = 'en_US',
                        ProfileId                = profile.Id,
                        TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                        Username                 = emailAddress,
                        isActive                 = true,
                        ContactId                = contactCC.Id,
                        Contact                  = contactCC,
                        User_Type__c             ='External',
                        UserRole                 = role
                        
                );
                insert testUser;
            }
            //update testUser.Contact;
        }
    
    /***************************************************************************************************************************************
          Method Name : setupShipToTestUser
          Description : setupShipToTestUser is to setup user for Test Class execution
          Return type : void
    *************************************************************************************************************************************/
    
        public static void setupShipToTestUser() {
            
            
            Contact contactCC = new Contact(
                    FirstName = 'CloudCraze',
                    LastName  = 'TestUser',
                    Email = 'abc@xyz.com',
                    AccountId = testAccountShipTo.Id,
                    MailingStreet = 'abc'
            );
            insert contactCC;
            User testOwner = [SELECT TimeZoneSidKey, UserRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()];
            system.runAs(testOwner){
                
                UserRole role = new UserRole (DeveloperName = 'TestUser_X' , Name = 'TestUser_X' );
                insert role;
                
                Profile profile = [SELECT Id
                FROM Profile
                WHERE Name = :CLOUDCRAZE_CUSTOMER_COMMUNITY_PROFILE_NAME LIMIT 1];
        
                
        
                String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
                testUser = new User(
                        Alias                    = 'cctest',
                        Email                    = emailAddress,
                        EmailEncodingKey         = 'UTF-8',
                        LastName                 = 'TestUser',
                        LanguageLocaleKey        = 'en_US',
                        LocaleSidKey             = 'en_US',
                        ProfileId                = profile.Id,
                        TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                        Username                 = emailAddress,
                        isActive                 = true,
                        ContactId                = contactCC.Id,
                        Contact                  = contactCC,
                        User_Type__c             ='Internal',
                        UserRole                 = role
                        
                );
                insert testUser;
            }
            //update testUser.Contact;
        }
        
    /***************************************************************************************************************************************
          Method Name : getGuestUser
          Description : getGuestUser is to setup user for Test Class execution
          Return type : void
    *************************************************************************************************************************************/
        public static User getGuestUser() {
            User guestUser = [select id, Name from User where profile.Name =: CLOUDCRAZE_CUSTOMER_GUEST_PROFILE_NAME1 or profile.Name =: CLOUDCRAZE_CUSTOMER_GUEST_PROFILE_NAME2 limit 1];
            return guestUser;
        }
        
    /***************************************************************************************************************************************
          Method Name : generateRandomString
          Description : generateRandomString is to generate random string of characters that can be used in creating some test data based
                        on length of characters passed in input parameter
          Return type : String
    *************************************************************************************************************************************/
        public static String generateRandomString(Integer len) {
            final String RANDOM_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
            String returnValue = '';
            Integer random;
            do {
                random = Math.mod(Math.abs(Crypto.getRandomInteger()),RANDOM_CHARS.length());
                returnValue += RANDOM_CHARS.substring(random,random + 1);
            } while (returnValue.length() < len);
    
            return returnValue;
        }
        
    /***************************************************************************************************************************************
          Method Name : getContactAddress
          Description : getContactAddress is to return Contact Address for user as test data
          Return type : ccrz__E_ContactAddr__c
    *************************************************************************************************************************************/
        public static ccrz__E_ContactAddr__c getContactAddress() {
            return new ccrz__E_ContactAddr__c(
                    ccrz__AddressFirstline__c = '100 Pine Street',
                    ccrz__AddressSecondline__c = 'North Lane',
                    ccrz__AddressThirdline__c = '3rd Stage',
                    ccrz__Country__c='SCD',
                    ccrz__CompanyName__c = 'comp1',
                    ccrz__City__c             = 'SmallTown',
                    ccrz__DaytimePhone__c     = '(847) 555-1212',
                    ccrz__FirstName__c        = 'Test',
                    ccrz__HomePhone__c        = '(847) 555-1212',
                    ccrz__LastName__c         = 'User',
                    ccrz__PostalCode__c       = '60601',
                    ccrz__State__c            = 'Idaho',
                    ccrz__StateISOCode__c     = 'ID',
                    ccrz__CountryISOCode__c   = 'USA'
            );
        }
        
    /***************************************************************************************************************************************
          Method Name : createSubscription
          Description : createSubscription is to create new subscriptions
          Return type : ccrz__E_Subscription__c
    *************************************************************************************************************************************/
    /*    public static ccrz__E_Subscription__c createSubscription() {
            Account anonAcc = anonAccount;
            ccrz__E_AccountGroup__c anonAccGrp = anonAccountGroup;
            return createSubscriptions(1).get(0);
        }
    */
    /***************************************************************************************************************************************
          Method Name : createSubscriptions
          Description : createSubscriptions is to create subscription 
          Return type : List<ccrz__E_Subscription__c>
    *************************************************************************************************************************************/
     /*
        public static List<ccrz__E_Subscription__c> createSubscriptions(Integer numberOfSubscriptions) {
    
            final List<ccrz__E_Subscription__c> testSubscription = new List<ccrz__E_Subscription__c>();
            //System.assert(testUser != null);
            for (Integer i = 0; i < numberOfSubscriptions; i++) {
                testSubscription.add(
                        new ccrz__E_Subscription__c(
                                ccrz__Account__c                        = testAccount.Id,
                                ccrz__EffectiveAccountID__c             = shipToAddress.Id,
                                ccrz__SPTOrderFrequency__c              = 17.0,
                                ccrz__OrderLastDate__c                  = Date.today(),
                                ccrz__OrderNextDate__c                  = Date.today(), 
                                ccrz__Quantity__c                       = 2,
                                ccrz__RecurringPrice__c                 = DEFAULT_PRICE,//i
                                ccrz__RecurringPriceSubAmt__c           = DEFAULT_PRICE,
                                ccrz__Storefront__c                     = STOREFRONT_NAME,
                                ccrz__SubscriptionProduct__c            = products[0].Id,
                                ccrz__SubscriptionStartDate__c          = Date.Today(),
                                ccrz__SubscriptionStatus__c             = 'ACTIVE',
                                ccrz__Sequence__c                       = 100,
                                ccrz__SubscriptionId__c                 = 'TestSubscriptionId'
                        )
                );
            }
            upsert testSubscription;
            
    
            return [SELECT Id FROM ccrz__E_Subscription__c WHERE Id = :testSubscription.get(0).Id];
        }
        */
      /***************************************************************************************************************************************
          Method Name : setupCommunityUser
          Description : to setup community user
          Return type : List<User>
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
    
        public static List<User> setupCommunityUser() {
            
            List<User> userList = new List<User>();
            List<Contact> conList = new List<Contact>();
            for(integer i=0;i<4;i++){
            Contact contactCC = new Contact(
                    FirstName = 'Community',
                    LastName  = 'TestUserCom'+i,
                    Email = 'abc@xydfz.com',
                    AccountId = testAccountComm.Id,
                    MailingStreet = 'abc'
            );
            conList.add(contactCC);
                System.debug('CONLIST--'+ conList);
            }
            
            insert conList;
            User testOwner = [SELECT TimeZoneSidKey, UserRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()];
           
                system.runAs(testOwner){
                UserRole role = new UserRole(DeveloperName = 'TestUser1', Name = 'TestRole');
                insert role;
                
                Profile profile = [SELECT Id
                FROM Profile
                WHERE Name = :CLOUDCRAZE_CUSTOMER_COMMUNITY_PROFILE_NAME LIMIT 1];
        
                
                String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
                testUser = new User(
                        Alias                    = 'cctest',
                        Email                    = emailAddress,
                        EmailEncodingKey         = 'UTF-8',
                        LastName                 = 'TestUser',
                        LanguageLocaleKey        = 'en_US',
                        LocaleSidKey             = 'en_US',
                        ProfileId                = profile.Id,
                        TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                        Username                 = emailAddress,
                        isActive                 = true,
                        ContactId                = conList[0].Id,
                        Contact                  = conList[0],
                        UserRole                 = role
                        
                );
                    String emailAddress1 = String.valueOf(System.now().getTime() + '@cc-detest.mail');
              User  testUser1 = new User(
                        Alias                    = 'cctest',
                        Email                    = emailAddress1,
                        EmailEncodingKey         = 'UTF-8',
                        LastName                 = 'TestUser',
                        LanguageLocaleKey        = 'en_US',
                        LocaleSidKey             = 'en_US',
                        ProfileId                = profile.Id,
                        TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                        Username                 = emailAddress1,
                        isActive                 = true,
                        ContactId                = conList[1].Id,
                        Contact                  = conList[1],
                        UserRole                 = role
                        
                );
      
                    String emailAddress2 = String.valueOf(System.now().getTime() + '@cc-testd.email');
               User testUser2 = new User(
                        Alias                    = 'cctest',
                        Email                    = emailAddress2,
                        EmailEncodingKey         = 'UTF-8',
                        LastName                 = 'TestUser',
                        LanguageLocaleKey        = 'en_US',
                        LocaleSidKey             = 'en_US',
                        ProfileId                = profile.Id,
                        TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                        Username                 = emailAddress2,
                        isActive                 = true,
                        ContactId                = conList[2].Id,
                        Contact                  = conList[2],
                        UserRole                 = role,
                        EC_CDM_User__c           = '09546'
                );
      
                    String emailAddress3 = String.valueOf(System.now().getTime() + '@cc-test.email');
               User testUser3 = new User(
                        Alias                    = 'cctest',
                        Email                    = emailAddress3,
                        EmailEncodingKey         = 'UTF-8',
                        LastName                 = 'TestUser',
                        LanguageLocaleKey        = 'en_US',
                        LocaleSidKey             = 'en_US',
                        ProfileId                = profile.Id,
                        TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                        Username                 = emailAddress3,
                        isActive                 = true,
                        ContactId                = conList[3].Id,
                        Contact                  = conList[3],
                        UserRole                 = role
                        
                );
      
             UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
                Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
                User portalUser = new User(
                UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = System.now().millisecond() + 'test37@test.com',
                Alias = 'batman',
                Email='bruce.wayne@waynee78nterprises.com',
                EmailEncodingKey='UTF-8',
                Firstname='Brce',
                Lastname='Waye',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago');
            
                     userList.add(testUser);
                     userList.add(testUser1);
                     userList.add(testUser2);
                     userList.add(testUser3);
                     userList.add(portalUser);
                insert userList;
                }
            return userList;
                 
                 
        }
        /***************************************************************************************************************************************
          Method Name : communityFaultyUser
          Description : to setup faulty community user
          Return type : void
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
    
        public static user communityFaultyUser(){
         
            Contact contactCC = new Contact(
                    FirstName = 'Commun',
                    LastName  = 'Testdemo678',
                    Email = 'abc@xycv.com',
                    AccountId = testAccountwithoutSalesRep.Id,
                    MailingStreet = 'def'
            );
            
            insert contactCC;   
            User testOwner = [SELECT TimeZoneSidKey, UserRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()];
           
                system.runAs(testOwner){
                UserRole role = new UserRole(DeveloperName = 'CommUser', Name = 'commRole');
                insert role;
                
                Profile profile = [SELECT Id
                FROM Profile
                WHERE Name = :CLOUDCRAZE_CUSTOMER_COMMUNITY_PROFILE_NAME LIMIT 1];
                
             String emailAddress = String.valueOf(System.now().getTime() + '@cc-testopq.email');
               User testUser = new User(
                        Alias                    = 'bmw',
                        Email                    = emailAddress,
                        EmailEncodingKey         = 'UTF-8',
                        LastName                 = 'DemoUser',
                        LanguageLocaleKey        = 'en_US',
                        LocaleSidKey             = 'en_US',
                        ProfileId                = profile.Id,
                        TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                        Username                 = emailAddress,
                        isActive                 = true,
                        ContactId                = contactCC.Id,
                        Contact                  = contactCC,
                        UserRole                 = role
                       
                );
            insert testUser;
                }
            return testUser;
      
        }
        /***************************************************************************************************************************************
          Method Name :  createPermissionSet
          Description : to assign basic permission set on user creation
          Return type : void
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
      
       
        public static void createPermissionSet(List<User> usr)
        {
        PermissionSet ps = new PermissionSet();
            List<PermissionSet> pslist =[select id from PermissionSet where name = 'EC_BasicSet'];
            if(pslist.size()>0){
             ps = pslist[0];
            }
        }
        
        /***************************************************************************************************************************************
          Method Name :  createCase
          Description : to create case of type access request
          Return type : void
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
      
         public static void createCase(List<User> usr)
        {
            System.runAs(usr[0]){
          //  createPermissionSet();
             List<Case> cseList = new List<Case>();
            List<Case> cseListUpdated = new List<Case>();
            Case cse = new Case(status=APPROVED, Origin=WEB,type=CASETYPE,EC_PortalAccessRole__c=BASIC,EC_User__c = usr[0].id);
            Case cse1 = new Case(status=APPROVED, Origin=WEB,type=CASETYPE,EC_PortalAccessRole__c=BUYER,EC_User__c = usr[3].id);
            cseList.add(cse);
            cseList.add(cse1);
            
            insert cseList;
            }
            
        }
    /***************************************************************************************************************************************
          Method Name :  testAccountComm
          Description : to setup test account for community users
          Return type : Account
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
        public static Account testAccountComm {
            get {
                if (testAccountComm == null) {
                    testAccountComm = new Account(
                            Name                    = ACCOUNT_NAME,
                            EC_SalesRepresentative__c =UserInfo.getUserId(),
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32)
                            
                    );
                    insert testAccountComm;
                }
                return testAccountComm;
            }
            private set;
        }
        /***************************************************************************************************************************************
          Method Name :  testAccountwithoutSalesRep
          Description : to setup test account for community users without sales representative
          Return type : Account
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
        public static Account testAccountwithoutSalesRep {
            get {
                if (testAccountComm == null) {
                    testAccountComm = new Account(
                            Name                    = ACCOUNT_NAME,
                            OwnerId                 = UserInfo.getUserId(),
                            Type                    = 'Customer',
                            BillingStreet           = generateRandomString(32),
                            BillingCity             = generateRandomString(32)
                            
                    );
                    insert testAccountComm;
                }
                return testAccountComm;
            }
            private set;
        }
        
         /***************************************************************************************************************************************
          Method Name :  createEC_PermissionSetMapping
          Description : to create records of custom setting EC_PermissionSetMapping__c
          Return type : void
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
        public static void createOutageRecord(){
            EC_OutageFlag__c outageRec = new EC_OutageFlag__c();
            outageRec.name='CommunityActive';
            outageRec.EC_isCommunityActive__c = true;
            insert outageRec;
        }
     /***************************************************************************************************************************************
          Method Name :  createEC_PermissionSetMapping
          Description : to create records of custom setting EC_PermissionSetMapping__c
          Return type : void
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
         
      
        public static void createEC_PermissionSetMapping(){
            List<EC_PermissionSetMapping__c> psmList = new List<EC_PermissionSetMapping__c>();
           System.debug('test class');
            EC_PermissionSetMapping__c setting0 = new EC_PermissionSetMapping__c();
            EC_PermissionSetMapping__c setting1 = new EC_PermissionSetMapping__c();
           setting0.Name = BASIC;
           setting0.EC_PermissionSetList__c = BASICSET;
             setting1.Name = BUYER;
           setting1.EC_PermissionSetList__c = BUYERSET;
            
             psmList.add(setting0);
             psmList.add(setting1);
             
           insert psmList;
        } 
        
        
    /***************************************************************************************************************************************
          Method Name :  createEC_UserRegCustomCode_Mdt
          Description : to create records of custom metadata EC_UserRegistration_Custom_Code
          Return type : void
          Author      : Sanjana KR 
    *************************************************************************************************************************************/
         
      
        public static void createEC_UserRegCustomCode_Mdt(){
             EC_UserRegistration_Custom_Code__mdt userRegCC = (EC_UserRegistration_Custom_Code__mdt)JSON.deserializeStrict(
                '{"MasterLabel":"User Registration","EC_CustomCodes__c" : "1013","EC_Message__c" : "We are facing some technical issues.","EC_Popup_Label__c" : "Registration Error"}', EC_UserRegistration_Custom_Code__mdt .class);
            
        }    
        
    
    /***************************************************************************************************************************************
          Method Name : setupCacheWrapper
          Description : This will set up the different variable for the cache 
          Return type : void
    *************************************************************************************************************************************/
        public static void TestCacheUser(User user){
    
    
       
       EC_CacheWrapper usrInformation = new EC_CacheWrapper();
       usrInformation.userFirstName = user.FirstName;
       usrInformation.userLastName = user.LastName ;
       usrInformation.portalConId  =  user.ContactId ;
       usrInformation.userProfile = user.Profile.Name ;
       usrInformation.userRole = user.UserRole.NAME ;
      
       Cache.SessionPartition orgPart = Cache.Session.getPartition('local.UserCache');
       orgPart.put('UserInfo1', usrInformation);
    
    
        }
        
    
        /***************************************************************************************************************************************
          Method Name : setupTestSalesRepUser()
          Description : to setup test SalesRep community users 
          Return type : 
          Author      : Shruti Sinha
    *************************************************************************************************************************************/ 
         public static void setupTestSalesRepUser() {
            
            
          
            User testOwner = [SELECT TimeZoneSidKey, UserRoleId
                FROM User
                WHERE Id = :UserInfo.getUserId()];
            system.runAs(testOwner){
                
                UserRole role = new UserRole(DeveloperName = 'TestUser1', Name = 'TestRole1');
                insert role;
                
                Profile profile = [SELECT Id
                FROM Profile
                WHERE Name = :CLOUDCRAZE_EXTERNAL_PROFILE LIMIT 1];
        
                
        
                String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
                testUser = new User(
                        Alias                    = 'cctest',
                        Email                    = emailAddress,
                        EmailEncodingKey         = 'UTF-8',
                        LastName                 = 'SalesRepUser',
                        LanguageLocaleKey        = 'en_US',
                        LocaleSidKey             = 'en_US',
                        ProfileId                = profile.Id,
                        TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                        Username                 = emailAddress,
                        isActive                 = true,
                        User_Type__c             ='Internal',
                        UserRole                 = role
                        
                );
                insert testUser;
            }
           
        }
        
     /***************************************************************************************************************************************
          Method Name : createQuickLists
          Description : createQuickLists is to create QuickLists based on nunmber of QuickLists passed in input parameter.
          Return type : List<ccrz__E_Order__c>
    *************************************************************************************************************************************/
            public static List<ccrz__E_Cart__c> createQuickLists(Integer numberOfLists) {
    
            final List<ccrz__E_Cart__c> testQuickLists = new List<ccrz__E_Cart__c>();
            
            System.assert(testUser != null);
            ccrz__E_Cart__c cart = createCart();
            for (Integer i = 0; i < numberOfLists; i++) {
                testQuickLists.add(
                        new ccrz__E_Cart__c(
                                ccrz__Account__c         = testAccount.Id,
                                ccrz__Contact__c         = testUser.ContactId,
                                OwnerId                  = testUser.Id,
                                ccrz__Storefront__c      = STOREFRONT_NAME,
                                ccrz__User__c           = testUser.Id,
                                ccrz__EncryptedId__c    = 'testEncryptedId'+ i.format(),
                                ccrz__RequestDate__c    = system.today()+3,
                                ccrz__CartType__c       = 'WishList',
                                EC_PurchasedWishlist__c = true
                        ));
            }
            System.assertEquals(testQuickLists.size(), numberOfLists);
            upsert testQuickLists;
    
            final List<ccrz__E_CartItem__c> testQuickListItems = new List<ccrz__E_CartItem__c>();
            final List<String> quickListIds                              = new List<String>();
    
            for (Integer i = 0; i < numberOfLists; i++) {
                testQuickListItems.add(
                        new ccrz__E_CartItem__c(
                                ccrz__Cart__c           = testQuickLists.get(i).Id,
                                ccrz__Price__c           = 50,
                                ccrz__Quantity__c        = 2,
                                ccrz__SubAmount__c       = 20,
                                ccrz__Product__c         = products[i].Id,
                                ccrz__Comments__c        = 'test',
                                ccrz__RequestDate__c     = system.today(),
                                EC_Last_Purchased_Date__c = system.today()
                        ));
                testQuickListItems.add(
                        new ccrz__E_CartItem__c(
                                ccrz__Cart__c           = testQuickLists.get(i).Id,
                                ccrz__Price__c           = 50,
                                ccrz__Quantity__c        = 2,
                                ccrz__SubAmount__c       = 20,
                                ccrz__Product__c         = products[i+1].Id,
                                ccrz__Comments__c        = 'test',
                                ccrz__RequestDate__c     = system.today(),
                              EC_Last_Purchased_Date__c = system.today()
                        ));
                quickListIds.add(testQuickLists.get(i).Id);
            }
            insert testQuickListItems;
    
            return[SELECT Id,OwnerId,ccrz__Account__r.Id,ccrz__Contact__r.Id,ccrz__Contact__c,ccrz__Account__c, ccrz__EncryptedId__c from ccrz__E_Cart__c WHERE Id IN :quickListIds];
        }
    
         /***************************************************************************************************************************************
          Method Name : createCartWishlist
          Description :  creation Of cart and cart item record for cart type= 'Wishlist'
          Return type : void
          Author      : Mishika Mahajan
    *************************************************************************************************************************************/
        public static void  createCartWishlist(){
         ccrz__E_Cart__c cart = new ccrz__E_Cart__c(
                                ccrz__Account__c         = testAccount.Id,
                                ccrz__Contact__c         = testUser.ContactId,
                                OwnerId                  = testUser.Id,
                                ccrz__Storefront__c      = STOREFRONT_NAME,
                                ccrz__User__c           = testUser.Id,
                                ccrz__EncryptedId__c    = 'EncryptedIdtest',
                                ccrz__RequestDate__c    = system.today()+3,
                                ccrz__CartType__c       = 'WishList',
                                EC_PurchasedWishlist__c = true  
                        );
            insert cart;
          ccrz__E_CartItem__c carttem = new ccrz__E_CartItem__c(
                                ccrz__Cart__c           = cart.Id,
                                ccrz__Price__c           = 50,
                                ccrz__Quantity__c        = 2,
                                ccrz__SubAmount__c       = 20,
                                ccrz__Product__c         = products[0].Id,
                                ccrz__Comments__c        = 'test',
                                ccrz__RequestDate__c     = system.today(),
                                EC_Last_Purchased_Date__c = system.today()
                        );
            insert carttem;
        }
        
    
    
     /***************************************************************************************************************************************
          Method Name : createContactForSalesrep
          Description :  creation Of Contact For Salesrep
          Return type : void
          Author      : Shruti Sinha
    *************************************************************************************************************************************/
        public static void  createContactForSalesrep(Integer numberOfContact){
        
         List<Contact> conlist = new  List<Contact>();
         for(Integer i = 0 ;i<numberOfContact;i++){
    
            
                        Contact con = new Contact();
                        con.FirstName = 'Con'+ i ;
                        con.LastName = 'LastName'+i ;
                        con.Email = 'abc@ccemail.com' ;
                        con.Phone ='123456'+i;
                        con.EC_SalesRep_User__c = UserInfo.getUserId();
                        con.AccountId= testAccount.Id ;
            
                        conlist.add(con);
    
    
    
    
         }
         insert conlist ;
           
    
    
    
        }
        
    /***************************************************************************************************************************************
          Method Name : setupMuleSoftIntegration()
          Description : to setup Custom Setting
          Return type : 
          Author      : Shruti Sinha
    *************************************************************************************************************************************/ 
    public static void TestMuleSoftIntegration(){
    
    
     EC_Mulesoft_Integration__c headerValues = new EC_Mulesoft_Integration__c();
      headerValues.Name ='DummyValues';
      headerValues.EC_ClientId__c = '12345678';
      headerValues.EC_Client_Secret__c = '11114563';
      headerValues.EC_Endpoint__c = 'https://api-CloudhubCentral-dev.ecolab.com:443' ;
      
      insert headerValues;
        }
        
     /***************************************************************************************************************************************
          Method Name : getAccStaging
          Description :This will create account 
          Return type : void
          Authour: Shivam
    *************************************************************************************************************************************/  
       public static EC_Mulesoft_CDM_Staging__c getAccStaging(String Accountnumber,String globalBusinessUnitName,String partnerFunction,String statusCode){
             EC_Mulesoft_CDM_Staging__c  stagingObj = new EC_Mulesoft_CDM_Staging__c();
                        stagingObj.EC_Account_Name__c = 'TestAccount'+partnerFunction;
                        stagingObj.EC_Account_Name_English__c = 'TestAccount'+partnerFunction;
                        stagingObj.EC_Street_Address_1__c = '33 main';
                        stagingObj.EC_City__c = 'New York';
                        stagingObj.EC_State_Province__c = 'Columbia';
                        stagingObj.EC_Country_ISO3_Code__c = 'United States';
                        stagingObj.EC_Street_Address_2__c = '23rdAVE';
                        stagingObj.EC_Street_Address_3__c = 'Clement street';
                        stagingObj.EC_Street_Address_4__c = 'Near Verizon PVT';
                        stagingObj.EC_Postal_Code__c = '6622511';
                        stagingObj.EC_Source_Table__c = 'Account';
                        stagingObj.EC_Parent_Account_Number__c = '15081947';
                        stagingObj.EC_Partner_Function__c = partnerFunction;
                        stagingObj.EC_Account_Number__c = Accountnumber;
                        stagingObj.EC_Account_Key__c = Accountnumber;    
                        stagingObj.EC_Account_Global_Business_Unit_Name__c = globalBusinessUnitName;
                        stagingObj.EC_Account_Divisional_Business_Unit_Name__c = globalBusinessUnitName;
                        stagingObj.EC_Status_Code__c = statusCode; 
                        stagingObj.EC_Customer_Key__c = '2';
                 return stagingObj;          
                  } 
            
       
     /***************************************************************************************************************************************
          Method Name : getUsrStaging
          Description :This will create UserStagingData 
          Return type : void
          Authour: Shivam
    *************************************************************************************************************************************/  
        
        public static EC_Mulesoft_CDM_Staging__c getUsrStaging(String userKey,String email,String userType){
            
            EC_Mulesoft_CDM_Staging__c  stagingObj = new EC_Mulesoft_CDM_Staging__c();      
                stagingObj.EC_Username__c = 'testuser'+email;
                stagingObj.EC_User_Key__c = userKey;
                stagingObj.EC_First_Name__c = 'TestFirstName';
                stagingObj.EC_User_Type__c = userType;  
                stagingObj.EC_Source_Table__c ='User';
                stagingObj.EC_Last_Name__c = 'TestLastName';
                stagingObj.EC_Email__c = email;
                stagingObj.EC_FederationIdentifier__c = email;
                stagingObj.Source__c = EC_Constants.CDMEVENT;
                stagingObj.Redemption_URL__c = 'test.salesforce.com'; 
                return stagingObj ;      
        }  
     /***************************************************************************************************************************************
          Method Name : createuserPermissionRecStaging
          Description :This will create createuserPermissionRecStaging 
          Return type : void
          Authour: Shivam
    *************************************************************************************************************************************/  
         
        
      public static EC_Mulesoft_CDM_Staging__c createuserPermissionRecStaging(String userKey,String permissionCode){
          EC_Mulesoft_CDM_Staging__c permStaging = new EC_Mulesoft_CDM_Staging__c();
                  permStaging.EC_Source_Table__c = 'User_Permission';
                  permStaging.EC_User_Key__c = userKey;
                  permStaging.EC_Permission_Code__c = permissionCode;
            return permStaging;
         }
     
    /***************************************************************************************************************************************
          Method Name : createUser_AccountStaging
          Description :This will create createUser_AccountStaging 
          Return type : void
          Authour: Shivam
    *************************************************************************************************************************************/  
             
        
        public static EC_Mulesoft_CDM_Staging__c createUser_AccountStaging(String AccountKey,String userKey){
            EC_Mulesoft_CDM_Staging__c usraccStaging = new EC_Mulesoft_CDM_Staging__c();
                  usraccStaging.EC_Source_Table__c = 'User_Account';
                  usraccStaging.EC_User_Key__c = userKey;
                  usraccStaging.EC_Account_Key__c = AccountKey;
            return usraccStaging;
             
         } 
    /***************************************************************************************************************************************
          Method Name : getRecord1
          Description :This will get the records from Portal_ESR_Category_Lookup__c 
          Return type : Portal_ESR_Category_Lookup__c
          Authour: Eric Lingbeek
    *************************************************************************************************************************************/  
    
         public static Portal_ESR_Category_Lookup__c getRecord1() {
            Portal_ESR_Category_Lookup__c record = new Portal_ESR_Category_Lookup__c();
                record.Cat_1_Text__c = 'Test Category';
                record.Cat_2_Text__c = 'Test Sub Category';
                record.Show_on_Portal__c = true;
                record.Cat_1_Code__c = 'ABC';
                record.Cat_2_Code__c = '123';
            return record;
        }
    /***************************************************************************************************************************************
          Method Name : getRecord2
          Description :This will get the records from Portal_ESR_Category_Lookup__c 
          Return type : Portal_ESR_Category_Lookup__c
          Authour: Eric Lingbeek
    *************************************************************************************************************************************/  
    
        public static Portal_ESR_Category_Lookup__c getRecord2() {
            Portal_ESR_Category_Lookup__c record2 = new Portal_ESR_Category_Lookup__c();
                record2.Cat_1_Text__c = 'INSTITUTIONAL';
                record2.Cat_2_Text__c = 'PRICING';
                record2.Show_on_Portal__c = true;
                record2.Cat_1_Code__c = 'ABC';
                record2.Cat_2_Code__c = '123';
            return record2;
        }
    /***************************************************************************************************************************************
          Method Name : insertCase
          Description :This will insert the case record   
          Return type : Case
          Authour: Eric Lingbeek
    *************************************************************************************************************************************/  
    
        public static Case insertCase() {
            Case caseRec = new case();
                caseRec.Status = 'New';
                caseRec.Type ='Request Service' ;
                caseRec.Origin = 'Portal';
                caseRec.EC_Request_Service_Type__c = 'INSTITUTIONAL';
                caseRec.EC_Category_Values__c = 'TRAINING' ;
                caseRec.Description = 'Notes' ;
                insert caseRec;
            return caseRec;
        } 
    /***************************************************************************************************************************************
          Method Name : insertContentVersion
          Description :This will insert the Content Version   
          Return type : Void
          Authour: Eric Lingbeek
    *************************************************************************************************************************************/  
    
        public static void insertContentVersion() {
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';      
            cv.PathOnClient ='test';           
            cv.VersionData =beforeblob;          
            insert cv;
        }
    /***************************************************************************************************************************************
          Method Name : insertSettings
          Description :This will insert the SAP_TIBCO_URL__c records   
          Return type : Void
          Authour: Eric Lingbeek
    *************************************************************************************************************************************/  
    
        public static void insertSettings(){
             SAP_TIBCO_URL__c settings = new SAP_TIBCO_URL__c();
                settings.Name = 'Destination URL';
                settings.TIBCO_End_Point_Url__c = '___https://localhost';
                insert settings;
        }  

    /***************************************************************************************************************************************
        Method Name : insertGlobalStaticSettings
        Description :This will insert the Global_Static__c records   
        Return type : Void
    *************************************************************************************************************************************/  
        public static void insertGlobalStaticSettings(){
            Global_Static__c gsSettings = new Global_Static__c();
            gsSettings.Name = 'Source_System';
            gsSettings.value__c = 'Connect'; 
            insert gsSettings; 
        }

    }