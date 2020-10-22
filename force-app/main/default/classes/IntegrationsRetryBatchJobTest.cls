/********************************************************************************************************
* @Class Name    IntegrationsRetryBatchJobTest 
* @description   IntegrationsRetryBatchJobTest is used to test functionality of IntegrationsRetryBatchJob
* @Created By -    
* @Created On -  
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 *                                     Initial version
 *********************************************************************************************************/ 


@isTest
public class IntegrationsRetryBatchJobTest {
    /***************************************************************************************************************************************
      Method Name : testBatchWithException
      Description : This method is used to test exception scenario
      Return type : void
     **************************************************************************************************************************************/
    static testMethod void testBatchWithException() {
        
        Global_Static__c gsSettings = new Global_Static__c();
        gsSettings.Name = 'Source_System';
        gsSettings.value__c = 'Connect'; 
        insert gsSettings;  

        SAP_TIBCO_URL__c settings = new SAP_TIBCO_URL__c();
        settings.Name = 'Destination URL';
        settings.TIBCO_End_Point_Url__c = '__https://local'; 
        insert settings;

        Case testCase = new Case();
        testCase.Origin = 'Portal';
        testCase.Order_Type__c = 'ZESR';
        testCase.Sold_To__c = '2345';
        testCase.Ship_To__c = '2312';
        testCase.Type = 'Request Service';
        testCase.SuppliedName = 'testname';
        testCase.SuppliedPhone = '2343454556';
        testCase.SuppliedEMail = 'test@test.com';
        
        testCase.Category_1_4__c = 'Test';
        testCase.Category_1_8__c = 'Firs';
        testCase.Category_2_4__c = 'test';
        testCase.Category_2_8__c = 'last';
        testCase.Subject = 'Pest Portal - Request Service Visit';
        testCase.Description = 'Test Case for Integrations Retry Batch';
        insert testCase; 
        testCase = [select Id, CaseNumber from Case where id =: testCase.id];
        System.debug('testCase.CaseNumber' + testCase.CaseNumber + '/ id: ' + testCase.id);
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.Identifier__c = testCase.CaseNumber;
        intLog.Integration_Component__c = 'Service Request';
        intLog.Integration_Type__c = 'SFDC_To_TIBCO';
        intLog.Retry_Counter__c = 0;
        intLog.Status__c = 'false';
		insert intLog;

        Test.startTest();
        IntegrationsRetryBatchJob bJob = new IntegrationsRetryBatchJob();
        Database.executeBatch(bJob,1); 
        Test.stopTest();

        Case caseForTest = [Select id, integration_Status__c, caseNumber from Case where id = :testCase.id];
        system.assert( caseForTest.integration_Status__c != '');

    }    
}