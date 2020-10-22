@isTest
global class EC_CaseTextMyRepToSAPMockUpNegative implements WebServiceMock {
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
      respElement.status = false;
      respElement.message = 'Failed message';
      response.put('response_x', respElement); 
   }
}