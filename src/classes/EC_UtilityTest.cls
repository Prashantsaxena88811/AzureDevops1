/***************************************************************************************************************************************
 Method Name : EC_UtilityTest
 Description : Test Class For EC_Utility
 Return type : void
 Author      :
 *************************************************************************************************************************************/

@isTest(SeeAllData = false) public class EC_UtilityTest {
	/***************************************************************************************************************************************
	 Method Name : isBlankOrEmptyTest
	 Description : Add items to the cart
	 Return type : Void
	 Author      : Priyanka Priya
	 *************************************************************************************************************************************/
	@isTest
	public static void isBlankOrEmptyTest() {
		System.assertEquals(EC_Utility.isBlankOrEmpty('10'), false);
		System.assertEquals(EC_Utility.isBlankOrEmpty(null), true);
	}
	/***************************************************************************************************************************************
	 Method Name : getGovLimitKpiTest
	 Description : Add items to the cart
	 Return type : Void
	 Author      : Priyanka Priya
	 *************************************************************************************************************************************/
	@isTest
	public static void getGovLimitKpiTest() {
		system.assertNotEquals(EC_Utility.getGovLimitKpi(), '');
	}
	/***************************************************************************************************************************************
	 Method Name : getCallingContextTest
	 Description : Add items to the cart
	 Return type : Void
	 Author      : Priyanka Priya
	 *************************************************************************************************************************************/

	@isTest
	public static void getCallingContextTest() {

		Test.startTest();
		EC_Utility.getCallingContext();
		List<EC_Utility.PermWrapper> permWrap = new List<EC_Utility.PermWrapper>();
		permWrap= EC_Utility.getPermCache();
        permWrap= EC_Utility.getPermissionCacheInfo();
        EC_Utility.logCallouts('','','','','');
		Test.stopTest();


	}
	/***************************************************************************************************************************************
	 Method Name : getPageUrlTest
	 Description : To test the methods
	 Return type : Void
	 Author      : Priyanka Priya
	 *************************************************************************************************************************************/

	@isTest
	public static void getPageUrlTest() {
		EC_TestData.createOutageRecord();
		EC_TestData.createEC_PermissionSetMapping();
		Test.startTest();
		EC_Utility.getPageUrl();
		EC_Utility.getProfileIBuy();
		EC_Utility.checkCustomPermissionOnUser();
		EC_Utility.getCommunityUrl();
		EC_Utility.permissionSetMap();
		EC_Utility.permissionSetId('Basic');
		EC_Utility.getOutageFlag();
		Test.stopTest();


	}
	/***************************************************************************************************************************************
	 Method Name : addItemsCartTest
	 Description : Add items to the cart
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void addItemsCartTest() {
		EC_TestData.setupTestUser();
		List<User> usr = [Select Id, FirstName, LastName, ProfileId, ContactId from User where LastName = 'TestUser'];
		System.runAs(usr [0]) {
			EC_TestData.setupCatalog();
			EC_TestData.createOrders(3);
			ccrz__E_Order__c ord = [Select Id, ccrz__EffectiveAccountID__c from ccrz__E_Order__c limit 1];
			ccrz__E_Cart__c crt = [Select Id from ccrz__E_Cart__c limit 1];
			List<ccrz__E_OrderItem__c> lst = [Select Id, ccrz__Product__c, ccrz__OriginalQuantity__c, ccrz__UnitOfMeasure__c from ccrz__E_OrderItem__c limit 5];
			ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c(ccrz__Cart__c = crt.Id,
																   ccrz__Quantity__c     = 5,
																   ccrz__Product__c      = lst [0].ccrz__Product__c,
																   ccrz__Price__c        = 20,
																   ccrz__SubAmount__c    = 22,
																   ccrz__UnitOfMeasure__c= 'Each');
			insert cartItem;

			boolean isReorder = TRUE;
			Id EffAccId = ord.ccrz__EffectiveAccountID__c;
            Map<string,string> prodbean = new Map<string,string>();
            List<ccrz__E_Product__c> productlist = new List<ccrz__E_Product__c>();
            prodbean.put('', 'value');
			test.StartTest();
			EC_Utility.addItemsToCart(crt.Id, EffAccId, lst, isReorder);
            EC_Utility.addAthenaItemsToCart(crt.Id,EffAccId,productlist,prodbean,isReorder);
			EC_Utility.getActiveCartForUser(EffAccId);
            EC_Utility.isIndirectStreetBrandAccount();
			test.StopTest();
		}
	}
	/***************************************************************************************************************************************
	 Method Name : addItemsCartTest
	 Description : Add items to the cart
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void noActiveCartTest() {
		EC_TestData.setupTestUser();
		List<User> usr = [Select Id, FirstName, LastName, ProfileId, ContactId from User where LastName = 'TestUser'];
       		System.runas(usr [0]) {
			EC_TestData.setupCatalog();
			EC_TestData.createOrders(3);
			ccrz__E_Order__c ord = [Select Id, ccrz__EffectiveAccountID__c from ccrz__E_Order__c limit 1];
			Id EffAccId = ord.ccrz__EffectiveAccountID__c;
			test.StartTest();
            EC_Utility.getActiveCartForUser(EffAccId);
			test.StopTest();
		}
	}
    /***************************************************************************************************************************************
	 Method Name : integrationLogCheckTest
	 Description : integrationLog to store the error message
	 Return type : void
	 Author      : Rajeshwar Bachu
	 *************************************************************************************************************************************/
    @isTest
	public static void integrationLogCheckTest() {
		EC_TestData.setupTestUser();
		List<User> usr = [Select Id, FirstName, LastName, ProfileId, ContactId from User where LastName = 'TestUser'];
		System.runas(usr [0]) {
            test.startTest();
		    Integration_Log__c integrationLog = new Integration_Log__c();
            integrationLog.retry_Counter__c = 1;
            integrationLog.identifier__c = '00001852';
            integrationLog.description__c = 'null/Retry# 1Successfully Sent';
            integrationLog.Integration_Component__c = 'Service Request';
            integrationLog.integration_Type__c = 'SFDC_To_TIBCO';
            integrationLog.request_Response_Details__c = null;
            Upsert integrationLog;   
			system.assert(integrationLog != null); 
	        EC_Utility.integrationLogCheck('00001852');
            EC_Utility.logIntegrationError(integrationLog.description__c,integrationLog.Integration_Component__c,integrationLog.integration_Type__c,'','',1,'',integrationLog.identifier__c);
            EC_Utility.logIntegrationError(integrationLog.description__c,integrationLog.Integration_Component__c,integrationLog.integration_Type__c,'','',0,'',Null);
			test.StopTest();
		}
	}
}