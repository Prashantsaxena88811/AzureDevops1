/********************************************************************************************************
* @Class Name    EC_OrderMockDAO
* @description   EC_OrderMockDAO is used to mock Tibco order service response
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 
public with sharing class EC_OrderMockDAO extends EC_OrderDAO{
    public override EC_OrderServiceOutput.OrderOutput_element doCreatePurchaseOrderCallout(EC_OrderServiceCallout.HttpsEndpoint port, EC_OrderServiceInput.PurchaseOrder_element order) {
        EC_OrderServiceOutput.OrderOutput_element output = new EC_OrderServiceOutput.OrderOutput_element();
        System.debug( 'order.StoreFront MOCK DAO: ' + order.StoreFront );
        if( order.StoreFront == 'Exception Condition' ) {
            Exception e = new NullPointerException();
            e.setMessage('Read timed out');
            throw e;                    
        }        
        output.Status = (order.StoreFront != 'ERROR CONDITION');
    return output;
    }
}