/********************************************************************************************************
* @Class Name    EC_OrderServiceCallout
* @description   Callout class for Tibco Api, Generated using WSDL
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 

public class EC_OrderServiceCallout{
    public class HttpsEndpoint {
        //public String endpoint_x = 'https://sieai01-dv.ecolab.com:6705/ecolab/https/services/order';
        public String endpoint_x;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput', 'EC_OrderServiceInput_1', 'http://ecolab.com/https/webservices', 'EC_OrderServiceCallout', 'http://www.ecolab.com/services/schemas/OrderOutput', 'EC_OrderServiceOutput_1'};
   
    /***************************************************************************************************************************************
      Method Name : createPurchaseOrder
      Description : This method is used to submit Orders to Tibco
      Return type : EC_OrderServiceOutput.OrderOutput_element
     **************************************************************************************************************************************/
        
        public EC_OrderServiceOutput.OrderOutput_element createPurchaseOrder(EC_OrderServiceInput.PurchaseOrder_element request_x) {
  
            EC_OrderServiceOutput.OrderOutput_element response_x;
            Map<String, EC_OrderServiceOutput.OrderOutput_element> response_map_x = new Map<String, EC_OrderServiceOutput.OrderOutput_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '/ecolab/https/services/createPurchaseOrder',
              'http://www.ecolab.com/services/schemas/PurchaseOrderInput',
              'PurchaseOrder',
              'http://www.ecolab.com/services/schemas/OrderOutput',
              'OrderOutput',
              'EC_OrderServiceOutput.OrderOutput_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}