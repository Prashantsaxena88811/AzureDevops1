/********************************************************************************************************
* @Class Name    EC_OrderServiceCallOutPositiveMock
* @description   Mock Class used for Test class
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
global class EC_OrderServiceCallOutPositiveMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        EC_OrderServiceOutput.OrderOutput_element respElement = 
           new  EC_OrderServiceOutput.OrderOutput_element();
       respElement.Status = false;
       response.put('response_x', respElement); 
   }
}