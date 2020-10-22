/********************************************************************************************************
* @Class Name    EC_OrderServiceCalloutTest
* @description   Test Class for EC_OrderServiceCallOut
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 

@isTest
public class EC_OrderServiceCallOutTest {

/***************************************************************************************************************************************
      Method Name : serviceCallOut_test
      Description : test method to test callout class
      Return type : void
     **************************************************************************************************************************************/
        
    
    public static testMethod void serviceCallOut_test(){
        
        EC_OrderServiceCallout.HttpsEndpoint service = new EC_OrderServiceCallout.HttpsEndpoint();
        EC_OrderServiceInput.PurchaseOrder_element request_x = new EC_OrderServiceInput.PurchaseOrder_element();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new EC_OrderServiceCallOutPositiveMock());
        EC_OrderServiceOutput.OrderOutput_element responseElement= service.createPurchaseOrder(request_x);
        System.assertNotEquals(null, responseElement);
        Test.stopTest();
        
    }

}