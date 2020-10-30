/*******************************************************************************************************************
 *Apex Class Name     : EC_GlobalSearchControllerTest
 *Created Date        : 07 Aug 2019
 *Description         : Test Class For EC_GlobalSearchController
 * Developer          :       Date                   Description
 * -----------------------------------------------------------------------------------------------------------------
 *Shruti Sinha              18/07/2019              Original Version
 *************************************************************************************************************************/
@isTest
public class EC_GlobalSearchControllerTest {

	/***************************************************************************************************************************************
	 Method Name : getSuggestionResultsAuraTest
	 Description : Test Method
	 Return type : Void
	 Author      : Harsha
	 ************************************************************************************************************************************/

	public static testmethod void getSuggestionResultsAuraTest() {
		EC_TestData.setupTestUser();
		User usr = [Select Id, FirstName, LastName, ProfileId, ContactId from User where LastName = 'TestUser'];
		System.runAs(usr) {
			EC_TestData.setupCatalog();
			EC_TestData.createOrders(10);
			EC_TestData.createQuickLists(3);
			EC_TestData.createOutageRecord();
			EC_TestData.createCartWishlist();
			EC_GlobalSearchController.outageRedirect();
			EC_CacheHelper.updateCache();


			String searchString = 'prod';
			String SearchStringTwo = 'product003';
			test.startTest();

			List<String> strlist = EC_GlobalSearchController.getSuggestionResultsAura(searchString);
			List<EC_GlobalSearchController.prodBean> prdlist = EC_GlobalSearchController.getProdSearchResultsAura(SearchStringTwo);
			EC_GlobalSearchController.getQuickListAura(searchString);
			List<EC_Utility.PermWrapper> tempVar = EC_GlobalSearchController.compVisible();
			List<EC_GlobalSearchController.orderBean> ordbeanlist = EC_GlobalSearchController.getOrderSearchResultsAura(searchString);
			EC_GlobalSearchController.getDocsSearchResultsAura(searchString);
			System.assert(ordbeanlist.size() > 0);
			test.stopTest();
		}
	}
}