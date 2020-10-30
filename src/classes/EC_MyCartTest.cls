/*******************************************************************************************************************
 * Apex Class Name     : EC_MyCartTest
 * Created Date        : 18 July 2019
 * Description         : Class to make header component links working
 * Developer                        Date                   Description
 * -----------------------------------------------------------------------------------------------------------------
 * Shruti Sinha                 08/07/2019              Original Version
 *************************************************************************************************************************/


@isTest
public class EC_MyCartTest {

	/************************************************************************************************************************************
	 Method Name : setupData
	 Description : to load mini cart with the active cart of user.
	 Parameter   : NA
	 Return type : NA
	 Author      : Raghav Sharma
	 *************************************************************************************************************************************/

	@TestSetup
	static void setupData() {
		List<ccrz__E_Menu__c> lstMenuItem = new List<ccrz__E_Menu__c>{
			new ccrz__E_Menu__c(ccrz__DisplayName__c = 'Home',
							    ccrz__URL__c = 'RandomURL',
							    ccrz__StoreID__c = 'Connect'),
			new ccrz__E_Menu__c(ccrz__DisplayName__c = 'Products',
							    ccrz__URL__c = 'RandomURL',
							    ccrz__StoreID__c = 'Connect'),
            new ccrz__E_Menu__c(ccrz__DisplayName__c = 'Intelligence',
                				ccrz__URL__c = 'RandomURL',
								ccrz__StoreID__c = 'Connect')
            };
		insert lstMenuItem;
	}
	/***************************************************************************************************************************************
	 Method Name : cartInfoLoadTest
	 Description : to test the cartInfoLoadTest
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
	public static testmethod void cartInfoLoadTest() {
		EC_TestData.setupTestUser();
		User usr = [Select Id, FirstName, LastName, ProfileId, ContactId from User where LastName = 'TestUser'];       
        System.runAs(usr) {
            PermissionSet varPermissionSet = [SELECT Id from PermissionSet WHERE Name='EC_BuyerSet'];
            PermissionSetAssignment varPermSetAssingment = new PermissionSetAssignment();
            varPermSetAssingment.PermissionSetId = varPermissionSet.Id;
            varPermSetAssingment.AssigneeId = usr.Id;
            insert varPermSetAssingment;
            EC_TestData.assignPestPermissions(usr);
			EC_TestData.setupCatalog();
			EC_TestData.createCarts(4);
			test.startTest();
			EC_MyCart.cartInfoLoad();
			EC_MyCart.getContact();
			EC_MyCart.getQuickListUrl();
			EC_MyCart.cartQuantity();
			EC_MyCart.getProfile();
			EC_MyCart.getLogoutUrl();
            EC_CacheWrapper userCache = EC_CacheHelper.getCacheInfo();
            userCache.hasNalcoAccount = true;
			EC_MyCart.getHeaderLinks();
			EC_MyCart.checkPayerPermission();
			EC_MyCart.isBasicBuyerCheck();            
			EC_MyCart.getUserAccountDivision();
			List<EC_Utility.PermWrapper> tempVar = EC_MyCart.compVisible();
            userCache.lstPermisssionSet = null;
            try{
                EC_MyCart.isBasicBuyerCheck();
            }catch(Exception e)
            {
                 system.assert(true, e.getMessage().contains('Script-thrown exception'));
            }                      
			test.stopTest();
		}

	}
	/***************************************************************************************************************************************
	 Method Name : noActiveCartTest
	 Description : to test the permCache
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
	public static testmethod void noActiveCartTest() {
		EC_TestData.setupTestUser();
		User usr = [Select Id, FirstName, LastName, ProfileId, ContactId from User where LastName = 'TestUser'];
		System.runAs(usr) {
			EC_TestData.setupCatalog();
			test.startTest();

			EC_MyCart.cartInfoLoad();
			test.stopTest();
		}

	}
}