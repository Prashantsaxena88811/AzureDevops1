/* Class Name    : EC_OrderAcknowledgementTest 
 * Description      Test Class to cover EC_OrderAcknowledgement
 * Created By       :Priyanka Priya
 * Created On       :2019-Aug-5
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Priyanka Priya    2019-Aug-5             BC-74097        Created the class   
 *
 */
@isTest
public class EC_OrderAcknowledgementTest {
/***************************************************************************************************************************************
  Method Name : getOrderListDetailsTest
  Description : Test method to cover getOrderInfoWrapper method
  Return type : void
 *************************************************************************************************************************************/
    @isTest
    public static void getOrderListDetailsTest(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
        system.runas(thisUser){
            EC_TestData.setupCatalog();
            Chemical_Product_Type__c packTypeCS = new Chemical_Product_Type__c();
            packTypeCS.Active__c = true;
            packTypeCS.Package_Code__c = '91';
            packTypeCS.Name = '91';
            insert packTypeCS;
            List<ccrz__E_Order__c> order =  new List<ccrz__E_Order__c>();
            EC_OrderAcknowledgement eca= new EC_OrderAcknowledgement();
            EC_OrderAcknowledgement.OrderItemWrapper eco= new EC_OrderAcknowledgement.OrderItemWrapper();
            system.debug('eco'+eco);
            order = EC_TestData.createOrders(1);
            
            ccrz__E_Order__c ord =  [Select Id,ccrz__PaymentMethod__c from ccrz__E_Order__c Where Id=:order[0].id Limit 1];
            ord.ccrz__PaymentMethod__c = 'CC';
            update ord;
            
            eca.ordId=order[0].id;
            eca.resourcePath='ery';
            Test.startTest();
            ccrz__E_ProductMedia__c prodMedia = new ccrz__E_ProductMedia__c();
            List<ccrz__E_OrderItem__c> ordItem= [select id, ccrz__Product__c,Custom_UnitPrice__c,Custom_PricingUOM__c,Custom_Factor__c from ccrz__E_OrderItem__c where ccrz__Order__c=:order[0].id];
            prodMedia.ccrz__Product__c = ordItem[0].ccrz__Product__c;
            prodMedia.ccrz__MediaType__c = 'Product Image Thumbnail';
            prodMedia.ccrz__URI__c='google.com';
            insert prodMedia;
            List<ccrz__E_PriceList__c> priceLists = new List<ccrz__E_PriceList__c> 
        {
            new ccrz__E_PriceList__c(
                Name                     = 'BA1',
                ccrz__CurrencyISOCode__c = ccrz.cc_CallContext.userCurrency,
                ccrz__Enabled__c         = false,
                ccrz__Storefront__c      = 'DefaultStore',
                ccrz__StartDate__c       = Date.today().addDays(-10),
                ccrz__EndDate__c         = Date.today().addDays(-1),
                ccrz__PricelistId__c     = '250287', 
                BA_Number__c             = '1234'
            )};
        insert priceLists;            
            ordItem[0].Custom_UnitPrice__c = 12.0;
            ordItem[0].Custom_PricingUOM__c = 'KG';
            ordItem[0].Custom_Factor__c = 1;
            update ordItem;
            ccrz__E_Product__c prod = [Select Id,Taxonomy__c from ccrz__E_Product__c Where Id=:ordItem[0].ccrz__Product__c Limit 1];
            prod.Taxonomy__c = 'Chemical';
            update prod;
            
            ccrz__E_PaymentDetail__c paym = new ccrz__E_PaymentDetail__c();
            paym.ccrz__Payment_Method__c= 'CC';
            paym.ccrz__CC_Order__c = order[0].Id;
            paym.ccrz__Cart__c = order[0].ccrz__OriginatedCart__c;
            paym.ccrz__Credit_Card_Type__c ='Visa';
            insert paym;
                
            EC_OrderAcknowledgement.orderInfoWrapper ordWrapper= new  EC_OrderAcknowledgement.orderInfoWrapper();
            ordWrapper.ECDivision = 'WATER';
            ordWrapper.couponCode = 'FLAT10';
            ordWrapper.isFlatFeeOrder = true;
            EC_OrderAcknowledgement.OrderItemWrapper oitem = new  EC_OrderAcknowledgement.OrderItemWrapper();
            oitem.PricePer = 10;

            eca.getOrderInfoWrapper();
            
             ordItem[0].Billing_Arrangement__c = priceLists[0].Id;
            update  ordItem[0];
            eca.getOrderInfoWrapper();
            
            system.assertNotEquals(eca.getOrderInfoWrapper(), null);
            Test.stopTest();
        }
    }
}