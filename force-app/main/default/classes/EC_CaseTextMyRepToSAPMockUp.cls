@isTest
global class EC_CaseTextMyRepToSAPMockUp implements WebServiceMock {
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
      EC_CaseTextMyRepToSAP.ESRResponseType respElement = new  EC_CaseTextMyRepToSAP.ESRResponseType();
      respElement.status = true;
      respElement.message = 'successful';
      response.put('response_x', respElement); 
   }
}