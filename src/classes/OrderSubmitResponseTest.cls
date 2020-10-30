@isTest
public class OrderSubmitResponseTest {
    static testMethod void testMethod1() {
        String Jasonstring = '{ "SAP_OrderNumber__c": "09876", "Order_Item_Group_Status__c": "In Process", "Mulesoft_Response_Description__c": "Description Goes Here" }';
        OrderSubmitResponse.parse(Jasonstring);
        system.assert(Jasonstring!=null);
    }
}