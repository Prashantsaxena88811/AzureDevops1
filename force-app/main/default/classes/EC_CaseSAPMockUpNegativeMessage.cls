@isTest
global class EC_CaseSAPMockUpNegativeMessage implements WebServiceMock {
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
      respElement.message = 'Failed due to error in test class...Error: parsing Error in test class and covere..Failed due to error in test class...Error: parsing Error in test class and covere..Failed due to error in test class...Error: parsing Error in test class and covere...Failed due to error in test class...Error: parsing Error in test class and covere...Failed due to error in test class...Error: parsing Error in test class and covere';
      response.put('response_x', respElement); 
   }
}