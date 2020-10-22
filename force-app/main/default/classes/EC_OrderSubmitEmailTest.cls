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
        System.runas(thisUser){
            EC_TestData.setupCatalog();
            list<ccrz__E_Order__c> orders = EC_TestData.createOrders(1);
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
            ccrz__E_Cart__c cart = [Select Id, Default_Unloading_Point__c FROM ccrz__E_Cart__c WHERE Id = :orders[0].ccrz__OriginatedCart__c];
            cart.Default_Unloading_Point__c = UL1.Id;
            update cart;



            Tank_Detail__c tank = new Tank_Detail__c();
            tank.Unloading_Point__c =UL1.id;
            tank.Tank_ID__c = '123';
            tank.Account__c = orders[0].ccrz__Account__c;
            tank.Tank_Number__c = '1234';
            insert tank;

            //ccrz__E_OrderItem__c orderItem1 = [Select Id, ]
            List<ccrz__E_OrderItem__c> orderItem = new List<ccrz__E_OrderItem__c>{
                                new ccrz__E_OrderItem__c(ccrz__Price__c= 50,ccrz__Quantity__c= 2,ccrz__SubAmount__c= 20,Tank_Number__c = tank.Id,ccrz__Order__c = orders[0].Id,Unloading_Point__c = UL1.Id),
                                new ccrz__E_OrderItem__c(ccrz__Price__c= 50,ccrz__Quantity__c= 2,ccrz__SubAmount__c= 20,Tank_Number__c = tank.Id,ccrz__Order__c = orders[0].Id,Unloading_Point__c = UL2.Id),
                                new ccrz__E_OrderItem__c(ccrz__Price__c= 50,ccrz__Quantity__c= 2,ccrz__SubAmount__c= 20,ccrz__Order__c = orders[0].Id,Unloading_Point__c = UL2.Id)
                        };
            insert orderItem;

            ccrz__E_Order__c order = [Select ccrz__User__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.ccrz__E_AccountGroup__c from ccrz__E_Order__c where id = :orders[0].Id];
            String accountGroup = order.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.ccrz__E_AccountGroup__c;
            User u = [Select Id from User where Id = :order.ccrz__User__c];
            u.User_Type__c = 'Internal';
            update u;



            List<ccrz__E_AccountGroupPriceList__c> accGrpPLList = [Select id,ccrz__AccountGroup__c,ccrz__Pricelist__r.EC_Price_List_Type__c,ccrz__Pricelist__r.Name,ccrz__Pricelist__c  from ccrz__E_AccountGroupPriceList__c where ccrz__AccountGroup__c = :accountGroup];

            ccrz__E_PriceList__c priceList = [Select id from ccrz__E_PriceList__c where id =:accGrpPLList[0].ccrz__Pricelist__c limit 1];
            priceList.EC_Price_List_Type__c  ='SBA';
            update priceList;

            ccrz__E_TransactionPayment__c transactions = new ccrz__E_TransactionPayment__c();
            transactions.ccrz__Token__c = 'token';
            transactions.ccrz__CCOrder__c = order.Id;
            insert transactions;

            ccrz__E_PaymentDetail__c payments = new ccrz__E_PaymentDetail__c();
            payments.ccrz__Payment_Token__c = 'token';
            payments.EC_Card_Holder_Name__c = 'name';
            payments.ccrz__CC_Order__c = order.Id;
            payments.ccrz__Cart__c = order.ccrz__OriginatedCart__c;
            insert payments;

            Test.startTest();

            EC_OrderSubmitEmail ordersubmitmail = new EC_OrderSubmitEmail();
            ordersubmitmail.ordId = orders[0].Id;
            EC_OrderSubmitEmail.OrderInfoWrapper orderInfoWrapper = ordersubmitmail.getOrderInfoWrapper();
            System.assertNotEquals(null, orderInfoWrapper);

            Test.stopTest();


        }
    }
}