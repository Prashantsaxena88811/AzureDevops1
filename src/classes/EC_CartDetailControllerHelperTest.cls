/* Class Name       : EC_CartDetailControllerHelperTest 
* Description      : Test Class to cover EC_CartDetailControllerHelper
* Created By       : Gaurav
* Created On       : 2020-Aug-25
*/
@isTest
public class EC_CartDetailControllerHelperTest {
    @isTest 
    /*****************************************************************
Method Name : BillingArrangment
Description : Test method to cover ECsaveBillingArrangement method
Return type : void
******************************************************************/
    static void BillingArrangment(){
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
         
            
            Id accountId = EC_TestData.testAccount.id;
            ccrz.cc_RemoteActionContext ctx=new ccrz.cc_RemoteActionContext();
            ctx.effAccountId = accountId;
            
            Account shipTo = [Select EC_SalesOrg__c from Account Where Id=:EC_TestData.testAccountShipTo.id];
            shipTo.EC_SalesOrg__c = '1001';
            shipTo.Account_Name2__c = 'ShipTo1';
            shipTo.Account_Name3__c = 'ShipTo2';
            shipTo.Account_Name4__c = 'ShipTo3';
            shipTo.parent =EC_TestData.testAccountShipTo;
            update shipTo;
            ccrz.cc_CallContext.effAccountId = accountId;            
            ccrz.cc_CallContext.initRemoteContext(ctx);            
            ccrz.cc_CallContext.currAccountId = accountId;
            
            List<ccrz__E_Pricelist__c> priceLists=[select id,ccrz__Storefront__c,ccrz__CurrencyISOCode__c, ccrz__Enabled__c,
                    ccrz__StartDate__c,ccrz__EndDate__c,ccrz__PricelistId__c from ccrz__E_Pricelist__c];
            
            Map<String,List<ccrz__E_Pricelist__c>> productLineBAMapP = new Map<String,List<ccrz__E_Pricelist__c>>();
            productLineBAMapP.put('GEN CHEMICAL',priceLists);
            productLineBAMapP.put('GEN EQUIPMENT',priceLists);
            productLineBAMapP.put('ST70.15',priceLists);
           
            EC_TestData.createCartWishlist();
            Id cartId = [Select id from ccrz__E_Cart__c].Id;
            
            ccrz__E_CartItem__c varCartItem = [Select id from ccrz__E_CartItem__c Where ccrz__Cart__c=:cartId LIMIT 1];
            varCartItem.Billing_Arrangement__c = priceLists[0].Id;
            update varCartItem;           
            
            Test.startTest();
            EC_CartDetailControllerHelper obj = new EC_CartDetailControllerHelper();
            obj.ECsaveBillingArrangement(cartId);
            EC_CartDetailControllerHelper.baSetResponse('Chemical','ST70.15' , productLineBAMapP);
            Set<ccrz__E_Pricelist__c> setPriceList = EC_CartDetailControllerHelper.baSetResponse('Equipment','ST70.15' , productLineBAMapP);
            system.assertEquals(!setPriceList.isEmpty(), true);
            Test.stopTest();
        }
    }
}