/* Class Name       :EC_HTTP_UtilsTest
 * Description      :TestClass for HTTPUtils
 * Created By       :Shruti Sinha
 * Created On       :08-07-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 *Shruti Sinha        08-07-2019                                 TestClass
 *
 */

@isTest
public class EC_HTTP_UtilsTest {
	/***************************************************************************************************************************************
	 Method Name : calloutTest
	 Description : to Test callout
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
	@isTest
	public static void calloutTest() {

		String url = 'https://ecolabconnect--devec1.my.salesforce.com' ;
		String clientId = '12345678';
		String clientSecret = '11114563';
		String requestType = 'POST';
		String requestBody = '{\"accountNo\":\"1242\", \"salesRepEmail\":\"abc@gmail.com\", \"userKey\":\"ujey\"}';
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EC_RegistrationCalloutMock());
		HttpResponse resp = EC_HTTPCalloutUtils.doPost(url, requestBody, clientId, clientSecret);
		System.assertEquals(200, resp.getStatusCode());
		Test.stopTest();

	}
	/***************************************************************************************************************************************
	 Method Name : testGetCallout
	 Description : to Test do callout
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
	@isTest


	public static void testGetCallout() {
		test.startTest();
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('EC_RoleCDMMockResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);
		// Call method to test
		HttpResponse resp = EC_HTTPCalloutUtils.doGet('www.google.com');

		test.stopTest();
	}
}