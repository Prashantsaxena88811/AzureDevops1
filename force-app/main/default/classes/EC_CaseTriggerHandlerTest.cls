@isTest
public class EC_CaseTriggerHandlerTest {
    static String destUrlStr = 'Destination URL';
  	@isTest 
    public static void doFutureCalloutTestPositive() {
        Case testCase = [Select Id from Case];
        List<Id> testCaseList = new List<Id>{testCase.id};
        Test.startTest();
        Test.setMock(WebServiceMock.class, new EC_CaseTextMyRepToSAPMockUp());
        EC_CaseTriggerHandler.doFutureCallout(testCaseList);
		Test.stopTest();
        Case testCaseUpdated = [Select Id,Integration_Status__c from Case];
        System.assertEquals(testCaseUpdated.Integration_Status__c, EC_Constants.SERVICE_REQUEST_INTEGRATION_STATUS);
    }
    
    @isTest 
    public static void doFutureCalloutTestNegative() { 
       	Case testCase = [Select Id from Case];
        List<Id> testCaseList = new List<Id>{testCase.id};  
        Test.startTest();
        Test.setMock(WebServiceMock.class, new EC_CaseTextMyRepToSAPMockUpNegative());
        EC_CaseTriggerHandler.doFutureCallout(testCaseList);
        Test.stopTest();
        Case testCaseUpdated = [Select Id,Integration_Status__c from Case];
        System.assertEquals(testCaseUpdated.Integration_Status__c, EC_Constants.SERVICE_REQUEST_INTEGRATION_STATUS_FAIL);
       
    }

    @isTest 
    public static void doFutureCalloutTestException() { 
       	Case testCase = [Select Id from Case];
        List<Id> testCaseList = new List<Id>{testCase.id};  
        Test.startTest();
        Test.setMock(WebServiceMock.class, new EC_CaseTextMyRepToSAPMockUpExceptionResp());
        EC_CaseTriggerHandler.doFutureCallout(testCaseList);
        Test.stopTest();
        Case testCaseUpdated = [Select Id,Integration_Status__c from Case];
        System.assertEquals(testCaseUpdated.Integration_Status__c, EC_Constants.SERVICE_REQUEST_INTEGRATION_STATUS_FAIL);
       
    }
    
    
    @isTest
    public static void retryServiceRequestSubmitTest(){   
      	Case testCase = [Select Id from Case];
        List<Id> testCaseList = new List<Id>{testCase.id};
        Test.startTest();       
        Test.setMock(WebServiceMock.class, new EC_CaseTextMyRepToSAPMockUp());
        EC_CaseTriggerHandler.retryServiceRequestSubmit(testCaseList);
        Test.stopTest();
        Case testCaseUpdated = [Select Id,Integration_Status__c from Case];
        System.assertEquals(testCaseUpdated.Integration_Status__c, EC_Constants.SERVICE_REQUEST_INTEGRATION_STATUS);
       
     }
    
    @testSetup
    public static void testDataSetup(){
        Case newTestC = new Case();
        newTestC.Origin = 'Portal';
        newTestC.Order_Type__c = 'ZESR';
        newTestC.Sold_To__c = '2345/22333';
        newTestC.Ship_To__c = '2312/33433';
        newTestC.Type = 'Request Service';
        newTestC.SuppliedName = 'testname';
        newTestC.SuppliedPhone = '2343454556';
        newTestC.SuppliedEMail = 'test@test.com';        
        newTestC.Category_1_4__c = 'Test';
        newTestC.Category_1_8__c = 'Firs';
        newTestC.Category_2_4__c = 'test';
        newTestC.Category_2_8__c = 'last';
        newTestC.Subject = 'Pest Portal - Request Service Visit';
        newTestC.Description = 'SFDC to Tibco Test SFDC to Tibco Test SFDC to Tibco Test SFDC to Tibco'
            + 'TestSFDC to Tibco Test SFDC to Tibco Test';
        insert newTestC;
        
        Global_Static__c gsSettings = new Global_Static__c();
        gsSettings.Name = 'Source_System';
        gsSettings.value__c = 'Connect'; 
        insert gsSettings;  

        SAP_TIBCO_URL__c settings = new SAP_TIBCO_URL__c();
        settings.Name = destUrlStr;
        settings.TIBCO_End_Point_Url__c = '__https://local';
        insert settings;

    }
}