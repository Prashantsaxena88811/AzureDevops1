/* Class Name       : EC_BillingArrangementControllerTest
* Description      : Test Class to cover EC_BillingArrangementController
* Created By       : Moin
* Created On       : 2020-Sep-01
*/
@isTest
public class EC_BillingArrangementControllerTest {
    
     private static EC_BillingArrangementController.ItemWrapper createItemWrapper(){
       EC_BillingArrangementController.ItemWrapper itwr = new EC_BillingArrangementController.ItemWrapper();            
            itwr.price = 22.11;
            itwr.customPricingUOM ='43';
            itwr.customUnitPrice = 45.99;
            itwr.taxonomy ='88';
            //itwr.productID =products[0].Id;
            itwr.PricePer = 45;
            itwr.packageTypeUOM = 'LBS';
            itwr.startDate = '09/09/2020';
            itwr.EndDate = '09/09/2020';
            itwr.uri = 'https://ecolabconnect--devec1.my.salesforce.com/home/home.jsp';
            return itwr;
     
    }
    
    @testSetup static void setup() {
        Account testAccountSoldTo = EC_TestData.testAccount;
        
        ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();
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
        List<ccrz__E_Product__c> productList = EC_SplitOrderTest.productUtility(4);
        productList[0].ccrz__sku__c='GEN CHEMICAL';
        update productList[0];
            
        
        List<ccrz__E_PriceList__c> listPriceLists = new List<ccrz__E_PriceList__c>();
        listPriceLists.add(EC_SplitOrderTest.priceListUtility('BA1','SBA'));
        listPriceLists.add(EC_SplitOrderTest.priceListUtility('Z1MP','Contract'));
        
        EC_SplitOrderTest.accountGroupPriceListUtility(testAccountSoldTo.id,listPriceLists[0].Id);
        EC_SplitOrderTest.accountGroupPriceListUtility(testAccountSoldTo.id,listPriceLists[1].Id);
        
        EC_SplitOrderTest.priceListItemUtility(productList,listPriceLists[0].Id);
        EC_SplitOrderTest.priceListItemUtility(productList,listPriceLists[1].Id);    
     
    }
    
    private static ccrz__E_CartItem__c fetchCartItem(String cartId,String productId, String priceListId){
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c = cartId;
        cartItem.ccrz__Price__c = 100;
        cartItem.ccrz__Product__c = productId;
        cartItem.Billing_Arrangement__c = priceListId;
        return cartItem;
    }
    
    private static EC_BillingArrangementController.baWrapper fetchBAWrapper(String baNumber, String baSFID, String priceListTypeExpansion, String description){
        EC_BillingArrangementController.baWrapper wr = new EC_BillingArrangementController.baWrapper();    
        wr.baNumber = baNumber;
        wr.baId = baSFID;
        wr.baType = priceListTypeExpansion;
        wr.baDesc = description;
        wr.startDate = '21/09/2020';
        wr.EndDate = '23/09/2020';
        return wr;
    }
    
    
    /*****************************************************************
Method Name : BA
Description : Test method to cover EC_BillingArrangementController method
Return type : void
******************************************************************/
    @isTest
    static void BA() {
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            Test.startTest();            
            Account testAccountSoldTo = [SELECT id from Account Order by createddate desc limit 1];
            ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext(); 
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
            
			ccrz__E_PriceList__c pl1 = [Select id,BA_Number__c,Price_List_Type_Expansion__c, ccrz__Desc__c from ccrz__E_PriceList__c where name = 'BA1'];
            List<ccrz__E_Product__c> products = [Select Id from ccrz__E_Product__c];       
            List<ccrz__E_PriceListItem__c> plItems = new List<ccrz__E_PriceListItem__c>();
            
            Set<String > ProdskuSet = new Set<String > ();
            ProdskuSet.add('ST70.15');
            ProdskuSet.add('GEN EQUIPMENT');
            List<ccrz__E_Cart__c> cart = EC_TestData.createCarts(1);
            ccrz__E_CartItem__c cartItem = fetchCartItem(cart[0].Id,products[0].Id,pl1.Id);
            insert cartItem;
            
            List<ccrz__E_CartItem__c> currentItemLists = new List<ccrz__E_CartItem__c>();
            currentItemLists.add(cartItem); 
            
            
            EC_BillingArrangementController Obj = new EC_BillingArrangementController();
            system.debug(Obj);
            EC_BillingArrangementController.baWrapper wr = fetchBAWrapper(Pl1.BA_Number__c,pl1.ID,Pl1.Price_List_Type_Expansion__c,Pl1.ccrz__Desc__c);
           
            
            List<EC_BillingArrangementController.ItemWrapper> itrList = new List<EC_BillingArrangementController.ItemWrapper>();
            EC_BillingArrangementController.ItemWrapper itwr = createItemWrapper();            
            itwr.product = products[0];
            itwr.priceListItem = plItems;
            
            wr.ItemWrapper = itrList;
            wr.prodLineItems = itrList;
            //   ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();
            ccrz.cc_RemoteActionResult res= EC_BillingArrangementController.getBADetail(ctx,'12345');
            System.assertNotEquals(null, res);
            ccrz.cc_RemoteActionResult res1= EC_BillingArrangementController.getBANums(ctx,ccrz.cc_CallContext.effAccountId);
            System.assertNotEquals(null, res1);
            Chemical_Product_Type__c cts = new Chemical_Product_Type__c(name= 'test11', Active__c = true, Package_Code__c ='90R',Product_Type__c ='Bulk' );
            insert cts;
            set<string> res3= EC_BillingArrangementController.getPackageCode();
            System.assertNotEquals(null, res3);
            ccrz.cc_CallContext.initRemoteContext(ctx);
            EC_BillingArrangementController.addToCartBADP(ctx,products[0].Id,cart[0].ccrz__EncryptedId__c, pl1.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBAHelper(){
        Test.startTest();
        ccrz__E_PriceList__c pl1 = [Select id from ccrz__E_PriceList__c where name = 'BA1'];
        ccrz.cc_RemoteActionResult res1 = new ccrz.cc_RemoteActionResult();           
        EC_BillingArrangementDetailHelper.fetchBADPData(res1,pl1.Id);
        System.assertNotEquals(null, res1);
        Test.stopTest();          
    } 

     @isTest
    static void testcheckNALCO(){
        EC_BillingArrangementController varClassInstance = new EC_BillingArrangementController();
        ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();        
        Test.startTest();
        EC_BillingArrangementController.getBANums(ctx,'AccountId');
        varClassInstance.baJSON = 'baJSON';
        Boolean boolNalco = varClassInstance.checkNALCO();
        System.assertEquals(true, boolNalco);
        Test.stopTest();          
    }
}