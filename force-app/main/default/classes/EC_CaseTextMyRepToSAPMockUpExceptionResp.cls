@isTest
global class EC_CaseTextMyRepToSAPMockUpExceptionResp implements WebServiceMock {
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
		throw new DMLException('Test coverage');
   }
}