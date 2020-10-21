/*********************************************************************************
 Class Name      : EC_AthenaOrdersTest
 Description     : This class is used as the test class for EC_AthenaOrders
 Created By      :  Raghu Varma
 Created Date    : 28-Jan-20
 Modification Log:
 ----------------------------------------------------------------------------------
 Developer                 Date                   Description
 ----------------------------------------------------------------------------------
 Raghu Varma             28-Jan-20              Initial Version
 *********************************************************************************/
@isTest
public class EC_AthenaOrdersTest { 
    @isTest
	public static void respondTest() {
		String requestString = '[{"division":"00","shipTo":"0123456789","systemId":"ECL_EBS","salesOrg":"US"}]';
		insert new EC_Custom_URL_Settings__c(Name = 'Athena_Orders_Cloudhub', custom_url__c = 'https://api-cloudhubcentral-st.ecolab.com/orders/v1/shiptonumbers');
        insert new EC_Custom_URL_Settings__c(Name = 'Microsoft OAuth Token', custom_url__c = 'https://login.microsoftonline.com/ecolab.com/oauth2/token');
        insert new EC_Athena_Settings__c(Name = 'GrantType', value__c = 'client_credentials');
        insert new EC_Athena_Settings__c(Name = 'ClientId', value__c = '81e0147a-46f3-4378-a28e-9f107202b9c8');
        insert new EC_Athena_Settings__c(Name = 'ClientSecret', value__c = '+8UK69YONWOA0nCOBwEbFh0X6GlHwASxoDqQec8xpR8=');
        insert new EC_Athena_Settings__c(Name = 'Resource', value__c = '0424e542-1ef6-4a47-81fc-9c533794e78c');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EC_OmniOrdersMock());
        EC_AthenaOrders.respond(requestString);
        EC_TestData.createOutageRecord();
        Boolean outageFlag = EC_SelfRegistrationController.outageRedirect();
        System.assert(outageFlag);
        Test.stopTest();
        
    }

}