@isTest
public class EC_CartDetailControllerTest {
    @isTest
    public static void testConstructor(){
        boolean isSalesRep = false;
        Test.startTest();
        Account shipTo = [Select EC_SalesOrg__c,Ship_To_Name__c from Account Where Id=:EC_TestData.testAccountShipTo.id];
        shipTo.EC_SalesOrg__c = '1001';
        shipTo.parent =EC_TestData.testAccountShipTo;
        update shipTo;
        ccrz.cc_CallContext.effAccountId = shipTo.id;
        EC_CartDetailController testEC_CartDetailController = new EC_CartDetailController();
        system.assertNotEquals(null, testEC_CartDetailController);
        Test.stopTest();
    }
    
    @isTest 
    static void profileUsr() {  
        Account shipTo = [Select EC_SalesOrg__c,Ship_To_Name__c from Account Where Id=:EC_TestData.testAccountShipTo.id];
        shipTo.EC_SalesOrg__c = '1001';
        shipTo.parent =EC_TestData.testAccountShipTo;
        update shipTo;
        ccrz.cc_CallContext.effAccountId = shipTo.id;        
        user usr = new user();
        usr.ProfileId = [SELECT Id, Name FROM Profile where name ='Sales Rep'].Id;
        usr.Username = System.now().millisecond() + 'test3713@test.com';
        usr.Alias = 'batman13';
        usr.Email='bruce.wayne@waynee781212nterprises.com';
        usr.EmailEncodingKey='UTF-8';
        usr.Firstname='Brce';
        usr.Lastname='Waye';
        usr.LanguageLocaleKey='en_US';
        usr.LocaleSidKey='en_US';
        usr.TimeZoneSidKey='America/Chicago';
        insert usr;
        system.runas(usr){
            Test.startTest();
            EC_CartDetailController testEC_CartDetailController1 = new EC_CartDetailController();
            system.assertNotEquals(null, testEC_CartDetailController1);
            Test.stopTest();
        }
    }
    
    @isTest 
    static void UnloadingPoints() {        
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            Test.startTest();
            //EC_TestData.setupCatalog();
            ccrz__E_AccountGroup__c accGroup = EC_TestData.testAccountGroup;
             String randomText =    EC_TestData.generateRandomString(32);
            Account testAccountSoldTo = new Account(
                Name                    = 'Test Sold To',
                OwnerId                 = UserInfo.getUserId(),
                BillingStreet           = randomText,
                BillingCity             = randomText,
                BillingState            = randomText,
                BillingCountry          = 'USA',
                BillingPostalCode       = EC_TestData.generateRandomString(5),
                EC_Account_Number__c    = EC_TestData.generateRandomString(5),
                EC_Billing_Account_Number__c = 'NLC_SAP/12345',
                Account_Name2__c			= 'ShipTo1',
                Account_Name3__c			= 'ShipTo2',
                Account_Name4__c			= 'ShipTo3',
                parent 						=	EC_TestData.testAccountShipTo,
                ccrz__E_AccountGroup__c = accGroup.Id,
                RecordTypeId            = EC_TestData.getRecordType('soldTo') //Sold To
                
            );
            insert testAccountSoldTo;
            
            ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();
            //List<Account> account = [Select id from Account Limit 1];
            ctx.effAccountId = testAccountSoldTo.id;
            
            Account shipTo = [Select EC_SalesOrg__c from Account Where Id=:EC_TestData.testAccountShipTo.id];
            shipTo.EC_SalesOrg__c = '1001';
            shipTo.Account_Name2__c = 'ShipTo1';
            shipTo.Account_Name3__c = 'ShipTo2';
            shipTo.Account_Name4__c = 'ShipTo3';
            shipTo.parent =EC_TestData.testAccountShipTo;
            update shipTo;
            ccrz.cc_CallContext.effAccountId = testAccountSoldTo.id;
            
            ccrz.cc_CallContext.initRemoteContext(ctx);
            ccrz.cc_CallContext.currAccountId = testAccountSoldTo.id;
            
            List<ccrz__E_CartItem__c> currentItemLists = new List<ccrz__E_CartItem__c>();
            List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1);
            
            List<ccrz__E_ContactAddr__c> unloadingPoints = new List<ccrz__E_ContactAddr__c>(); 
            ccrz__E_ContactAddr__c unloadingPoint = new ccrz__E_ContactAddr__c();
            unloadingPoint.EC_Account_Number__c = testAccountSoldTo.EC_Billing_Account_Number__c;
            insert unloadingPoint;
            unloadingPoints.add(unloadingPoint);
            
            List<ccrz__E_Product__c> products = EC_TestData.products; 
            List<Map<String,String>> prodList = new List<Map<String,String>>();
            Map<String,String> maps= new Map<String,String>();
            prodList.add(maps);
            
            List<ccrz__E_ContactAddr__c> uloadingList = new List<ccrz__E_ContactAddr__c>();
            ccrz__E_ContactAddr__c UL1 = EC_TestData.getContactAddress();
            UL1.EC_Account_Number__c = testAccountSoldTo.EC_Billing_Account_Number__c;
            UL1.Type__c = 'Unloading Point';
            UL1.Active__c =  true;
            ccrz__E_ContactAddr__c UL2 = EC_TestData.getContactAddress();
            UL2.EC_Account_Number__c = testAccountSoldTo.EC_Billing_Account_Number__c;
            UL2.Type__c = 'Unloading Point';
            UL2.Active__c =  true;
            uloadingList.add(UL1);
            uloadingList.add(UL2);
            insert uloadingList;
            
            
            Set<String> ULidSet = new Set<String>();
            ULidSet.add(string.ValueOf(UL1.id));
            ULidSet.add(string.ValueOf(UL2.id));
            Tank_Detail__c tank = new Tank_Detail__c();
            tank.Unloading_Point__c =UL1.id;       
            tank.Tank_ID__c = '123';
            tank.Active__c = true;
            tank.Material_Description__c = 'ST70';
            tank.Delivery_Template_Code__c ='91';
            tank.Delivery_Priority__c = '7';
            tank.Account__c = testAccountSoldTo.id;
            
            
            Set<String> productIDs = new Set<String>();
            productIDs.add(products[0].Id);
            tank.Tank_Number__c = '1234';
            insert tank;
            
            Tank_Detail__c tankDetail = new Tank_Detail__c();
            tankDetail.Active__c = true;
            tankDetail.Tank_Id__c = System.Label.DropOff;
            tankDetail.Account__c = shipTo.Id;
            tankDetail.Tank_Number__c = '1223';
            tankDetail.Delivery_Priority__c = '7';
            tankDetail.Material_Description__c = '123';
            tankDetail.Delivery_Template_Code__c = '91';
            tankDetail.Delivery_Priority__c = '7';
            insert tankDetail;
            maps.put('tanknumber',tank.Id);
            maps.put('unloadpoint',UL1.Id);                          
            ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c = cart[0].Id;
            cartItem.ccrz__Price__c = 100;
            cartItem.Tank_Number__c =tank.Id;
            cartItem.Unloading_Point__c =UL1.id;
            cartItem.ccrz__Product__c = products[0].Id;
            
            insert cartItem;
            
            currentItemLists.add(cartItem);
            maps.put('tanknumber',tank.Id);
            maps.put('unloadpoint',UL1.Id);
            Map<string,String> itemMap = new Map<String,String>();
            itemMap.put('sfid',cartItem.Id);
            prodList.add(itemMap);
            EC_CartDetailController.saveUnloadingPoints(ctx,cart[0].Id, prodList, unloadingPoints[0].Id);
            EC_CartDetailController.getECUnloadingPoints(ctx,testAccountSoldTo.id);
            EC_CartDetailController.updateCartItemUOM(null);
            
            ccrz__E_PriceList__c PL = [Select id from ccrz__E_PriceList__c limit 1];
            EC_CartDetailController.saveBillingArrangement(ctx,cart[0].Id, cartItem.Id, PL.Id);
            EC_CartDetailController.ECsaveBillingArrangement(ctx,cart[0].Id);
           
            
            cart = [Select ccrz__BillTo__c, ccrz__ShipTo__c,ccrz__EncryptedId__c,ccrz__EffectiveAccountID__c from ccrz__E_Cart__c Where Id=: cart[0].id Limit 1];
            cart[0].ccrz__BillTo__c = null;
            cart[0].ccrz__ShipTo__c = null;
            update cart;
            CCRZ.cc_CallContext.currCartId = cart[0].Id;
            //CCRZ.cc_CallContext.currCartId = cart[0].ccrz__EncryptedId__c;
            ccrz.cc_CallContext.effAccountId = cart[0].ccrz__EffectiveAccountID__c;
                
            List<Tank_Detail__c> tanks = new List<Tank_Detail__c>();
            
            Tank_Detail__c newtankDetail = new Tank_Detail__c();
            newtankDetail.Active__c = true;
            newtankDetail.Tank_Id__c = '333';
            newtankDetail.Account__c = shipTo.Id;
            newtankDetail.Tank_Number__c = '3434';
            newtankDetail.Delivery_Priority__c = '7';
            newtankDetail.Material_Description__c = '123';
            newtankDetail.Delivery_Template_Code__c = '91';
            newtankDetail.Delivery_Priority__c = '7';
            insert newtankDetail;
            tanks.add(newtankDetail);
            EC_CartDetailController.unStampTankNumber(tanks,products[0].Id);
            
            List<ccrz__E_PriceList__c> priceLists = new List<ccrz__E_PriceList__c> 
            {
                new ccrz__E_PriceList__c(
                    Name                     = 'Enterprise',
                    ccrz__CurrencyISOCode__c = ccrz.cc_CallContext.userCurrency,
                    ccrz__Enabled__c         = true,
                    ccrz__Storefront__c      = 'DefaultStore',
                    ccrz__StartDate__c       = Date.today().addDays(-7),
                    ccrz__EndDate__c         = Date.today().addDays(7),
                    ccrz__PricelistId__c         = '250287'
                ),
                    new ccrz__E_PriceList__c(
                        Name                     = 'Contract',
                        ccrz__CurrencyISOCode__c = ccrz.cc_CallContext.userCurrency,
                        ccrz__Enabled__c         = true,
                        ccrz__Storefront__c      = 'DefaultStore',
                        ccrz__StartDate__c       = Date.today().addDays(-7),
                        ccrz__EndDate__c         = Date.today().addDays(7),
                        ccrz__PricelistId__c         = '070289'
                    )
                    };
                        insert priceLists;
            
            List<ccrz__E_AccountGroupPriceList__c> testAccountGroupPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
            testAccountGroupPriceLists.add(
                new ccrz__E_AccountGroupPriceList__c(
                    ccrz__AccountGroup__c = accGroup.Id,
                    EC_Price_List_Type__c = 'Z1MP',
                    ccrz__PriceList__c    = priceLists[0].Id,
                    ccrz__Enable__c       = true
                ));
            insert testAccountGroupPriceLists;
            ccrz__E_PriceListItem__c objPriceListItem = new ccrz__E_PriceListItem__c();
            objPriceListItem .ccrz__Product__c = products[0].id;
            objPriceListItem .ccrz__Pricelist__c = priceLists[0].id;
            objPriceListItem.ccrz__StartDate__c = Date.today().addDays(-7);
            objPriceListItem.ccrz__EndDate__c = Date.today().addDays(7);
            objPriceListItem.ccrz__Price__c = 10.00;
            objPriceListItem.Custom_Factor__c = 2;
            objPriceListItem.Custom_PricingUOM__c = 'KG';
            objPriceListItem.Custom_UnitPrice__c=10.00;
            insert objPriceListItem;
            Map<string,Object> retData=new Map<string,Object>();
            Map<string,Object> retDataValue=new Map<string,Object>();
            retDataValue.put(''+products[0].id, '{productPrice={CustomUnitPrice=1.20, itemType=null, price=6.15, priceList=a115C000001GJf4QAG, sfid=a105C000000j4bnQAA}}');
            retData.put('includePricing',true);
            retData.put('sfid',objPriceListItem.Id);
            retData.put('CustomFactor', objPriceListItem.Custom_Factor__c);
            retData.put('CustomPricingUOM', objPriceListItem.Custom_PricingUOM__c);
            retData.put('CustomUnitPrice', objPriceListItem.Custom_UnitPrice__c);       
            
            retData.put('productPricingData',retDataValue);
            
            EC_CartDetailController.updateCartItemUOM(cart[0].ccrz__EncryptedId__c);
            EC_CartDetailController.getTankNumbersbytmpltCodes(new Set<String>{'ST70.91'});
            EC_CartDetailController.getMinMaxQtyMessage();
            thisUser.User_Type__c='Internal';
            thisUser.Phone='123456';
            thisUser.MobilePhone='98765432';
            update thisUser;
            EC_CartDetailController.updateCartShipToSoldTo();
            List<DropOff_Package_Code__mdt> tankNumberSet = [SELECT Active__c,Id,Label,Package_Code__c,Sales_Org__c,Tank_Number__c FROM DropOff_Package_Code__mdt where Active__c = true AND Sales_Org__c =:shipTo.EC_SalesOrg__c];
            System.assertEquals(false, tankNumberSet.isEmpty());
            EC_CartDetailController.getDropOffTanks(shipTo.EC_SalesOrg__c);
            
            EC_CartDetailControllerHelper helper = new EC_CartDetailControllerHelper();
            helper.ECsaveBillingArrangement(String.valueOf(cart[0].Id));
            EC_CartDetailController.saveBillingArrangement(ctx,String.valueof(cart[0].Id), String.valueOf(cartItem.Id),'1234');
            Map<String,List<ccrz__E_Pricelist__c>> productLineBAMap = new Map<String,List<ccrz__E_Pricelist__c>>();
            
            EC_CartDetailControllerHelper.baSetResponse('Chemistry',products[0].ccrz__sku__c,productLineBAMap );
            //system.assertNotEquals(null, res); 
            Test.stopTest();
        }
    }
}