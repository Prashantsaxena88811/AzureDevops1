/* Class Name    : EC_OrderSubmitEmailTest
 * Description      Test Class to cover EC_OrderSubmitEmail Class
 * Created By       :Ravindra Singh
 * Created On       :2019-8-6


 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ravindra Singh               2019-8-6     BC-76559        Created the class
 *
 */
@isTest
public class EC_OrderSubmitEmailTest {    
    /***************************************************************************************************************************************
  Method Name : fetchAccountsTest
  Description : Test method to cover getOrderInfoWrapper method
  Return type : void
 *************************************************************************************************************************************/
    static testMethod void test_positiveResponse(){

        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
        createChemicalProductType('90R_Bulk','90R');
        createChemicalProductType('91B_Bulk','91B');
        System.runas(thisUser){
            EC_TestData.setupCatalog();
            list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
            List<ccrz__E_ContactAddr__c> uloadingList = unloadingPointUtility(orders);
            ccrz__E_Cart__c cart = [Select Id, Default_Unloading_Point__c FROM ccrz__E_Cart__c WHERE Id = :orders[0].ccrz__OriginatedCart__c];
            cart.Default_Unloading_Point__c = uloadingList[0].Id;
            cart.EC_AttentionTo__c = 'Kieron Pollard';
            cart.EC_Attention_To_Number__c= '868840';
            update cart;



            Tank_Detail__c tank = new Tank_Detail__c();
            tank.Unloading_Point__c =uloadingList[0].id;
            tank.Tank_ID__c = '123';
            tank.Account__c = orders[0].ccrz__Account__c;
            tank.Tank_Number__c = '1234';
            insert tank;

            //ccrz__E_OrderItem__c orderItem1 = [Select Id, ]
            List<ccrz__E_OrderItem__c> orderItem = orderItemUtility(tank.Id,orders[0].Id,uloadingList);

            ccrz__E_Order__c order = [Select ccrz__User__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.ccrz__E_AccountGroup__c from ccrz__E_Order__c where id = :orders[0].Id];
            String accountGroup = order.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.ccrz__E_AccountGroup__c;
            User u = [Select Id from User where Id = :order.ccrz__User__c];
            u.User_Type__c = 'Internal';
            order.ccrz__PaymentMethod__c = 'PO';
            order.ccrz__PONumber__c = '12345';
            update order;
            update u;



            List<ccrz__E_AccountGroupPriceList__c> accGrpPLList = [Select id,ccrz__AccountGroup__c,ccrz__Pricelist__r.EC_Price_List_Type__c,ccrz__Pricelist__r.Name,ccrz__Pricelist__c  from ccrz__E_AccountGroupPriceList__c where ccrz__AccountGroup__c = :accountGroup];

            ccrz__E_PriceList__c priceList = [Select id from ccrz__E_PriceList__c where id =:accGrpPLList[0].ccrz__Pricelist__c limit 1];
            priceList.EC_Price_List_Type__c  ='SBA';
            priceList.BA_Number__c = '123';
            update priceList;

            ccrz__E_TransactionPayment__c transactions = new ccrz__E_TransactionPayment__c();
            transactions.ccrz__Token__c = 'token';
            transactions.ccrz__CCOrder__c = order.Id;
            insert transactions;

            paymentDetailUtility('02',2020,order);
            
             orderItem[1].Billing_Arrangement__c = priceList.Id;
            update orderItem[1];

            Test.startTest();
            EC_OrderSubmitEmail ordersubmitmail = new EC_OrderSubmitEmail();
            ordersubmitmail.ordId = orders[0].Id;
            EC_OrderSubmitEmail.OrderInfoWrapper orderInfoWrapper = ordersubmitmail.getOrderInfoWrapper();
            orderInfoWrapper.staticResourceUrl= 'https://ecolabconnect--testec1.my.salesforce.com';
            order.ccrz__PaymentMethod__c = 'CC';            
            update order;
            orderInfoWrapper = ordersubmitmail.getOrderInfoWrapper();
            System.assertNotEquals(null, orderInfoWrapper);            
            Test.stopTest();
        }
    }
    
     /***************************************************************************************************************************************
	 Method Name : createChemicalProductType
	 Description : to create custom setting records
	 Return type : void
	 Author      : Parju
	 *************************************************************************************************************************************/
    
    private static void createChemicalProductType(String Name, String PackageCode) {       
        Chemical_Product_Type__c varCustomSettingRecord = new Chemical_Product_Type__c();
        varCustomSettingRecord.Active__c = true;
        varCustomSettingRecord.Package_Code__c = PackageCode;  
        varCustomSettingRecord.Name = Name;
        varCustomSettingRecord.Product_Type__c = 'Bulk';
        insert varCustomSettingRecord;
    }
    
     /***************************************************************************************************************************************
	 Method Name : paymentDetailUtility
	 Description : to create custom setting records
	 Return type : void
	 Author      : Parju
	 *************************************************************************************************************************************/
    
    private static void paymentDetailUtility(String monthName, Integer year,ccrz__E_Order__c order) {       
        ccrz__E_PaymentDetail__c payments = new ccrz__E_PaymentDetail__c();
        payments.ccrz__Payment_Token__c = 'token';
        payments.EC_Card_Holder_Name__c = 'name';
        payments.ccrz__CC_Order__c = order.Id;
        payments.ccrz__Cart__c = order.ccrz__OriginatedCart__c;
        payments.ccrz__Expiration_Month__c = monthName;
        payments.ccrz__Expiration_Year__c = year;
        insert payments;
    }
    
     /***************************************************************************************************************************************
	 Method Name : orderItemUtility
	 Description : to create Order Item records
	 Return type : List<ccrz__E_OrderItem__c>
	 Author      : Parju
	 *************************************************************************************************************************************/
    
    private static List<ccrz__E_OrderItem__c> orderItemUtility(Id tankId, Id OrderId,List<ccrz__E_ContactAddr__c> uloadingList) {       
        List<ccrz__E_OrderItem__c> orderItem = new List<ccrz__E_OrderItem__c>{
                                new ccrz__E_OrderItem__c(ccrz__Price__c= 50,ccrz__Quantity__c= 2,ccrz__SubAmount__c= 20,Tank_Number__c = tankId,ccrz__Order__c = orderId,Unloading_Point__c = uloadingList[0].Id),
                                new ccrz__E_OrderItem__c(ccrz__Price__c= 50,ccrz__Quantity__c= 2,ccrz__SubAmount__c= 20,Tank_Number__c = tankId,ccrz__Order__c = orderId,Unloading_Point__c = uloadingList[1].Id),
                                new ccrz__E_OrderItem__c(ccrz__Price__c= 50,ccrz__Quantity__c= 2,ccrz__SubAmount__c= 20,ccrz__Order__c = orderId,Unloading_Point__c = uloadingList[1].Id)
                        };
            insert orderItem;
        return orderItem;
    }
    
     /***************************************************************************************************************************************
	 Method Name : unloadingPointUtility
	 Description : to create Order Item records
	 Return type : List<ccrz__E_ContactAddr__c>
	 Author      : Parju
	 *************************************************************************************************************************************/
    
    private static List<ccrz__E_ContactAddr__c> unloadingPointUtility(List<ccrz__E_Order__c> orders) {       
        List<ccrz__E_ContactAddr__c> uloadingList = new List<ccrz__E_ContactAddr__c>();
        ccrz__E_ContactAddr__c UL1 = EC_TestData.getContactAddress();
        UL1.EC_Account_Number__c = orders[0].ccrz__Account__c;
        UL1.ccrz__CompanyName__c = 'Test Company1';
        ccrz__E_ContactAddr__c UL2 = EC_TestData.getContactAddress();
        UL2.EC_Account_Number__c = orders[0].ccrz__Account__c;
        UL2.ccrz__CompanyName__c = 'Test Company2';
        uloadingList.add(UL1);
        uloadingList.add(UL2);
        insert uloadingList;                
        return uloadingList;
    }  
}