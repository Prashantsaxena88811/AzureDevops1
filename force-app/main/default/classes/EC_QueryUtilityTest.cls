/* Class Name       :EC_QueryUtility
 * Description      :Test Class for EC_QueryUtility
 * Created By       :Shruti Sinha
 * Created On       :07-29-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Shruti Sinha         07-29-2019                                   Utility for SOQL queries.
 *
 */
@isTest
public class EC_QueryUtilityTest {

	/***************************************************************************************************************************************
	 Method Name : EC_QueryUtilitySetUp
	 Description : test method
	 Return type : Void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void EC_QueryUtilitySetUp() {

		EC_TestData.setupTestUser();
		User testUser = [select id, ContactId from User where Alias = 'cctest'];

		Map<String, ccrz__E_PriceListItem__c> pliMap = new Map<String, ccrz__E_PriceListItem__c>();
		Contact conts = [select id, Name from Contact where LastName = 'TestUser'];
		EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
		csobj.EC_ClientId__c = '12345678';
		csobj.EC_Client_Secret__c = '11114563';
		csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
		csobj.Name = 'SELFALIGNMENT';
		insert csobj;
		Set<Id> setIDs = new Set<Id>();
		Set<String> setStr = new Set<String>();
		List<ID> listId = new List<ID>();
		Account acc = EC_TestData.testAccountSoldTo;
		List<String> listIds = new List<String>();
		listIds.add(acc.id);
		List<ccrz__E_Order__c> ords = EC_TestData.createOrders(1);
		setIDs.add(ords [0].id);
		List<ccrz__E_Product__c> prod = EC_TestData.products;
		Set<Id> prdId = new Set<Id>();
		List<String> productSkuList = new List<String>();
		for(ccrz__E_Product__c prd :prod) {

			prdId.add(prd.Id);
			productSkuList.add(prd.Id);
		}
		List<ccrz__E_Order__c> fetchOrder = [select id, ccrz__OriginatedCart__r.ccrz__EncryptedId__c, ccrz__OriginatedCart__r.ccrz__Contact__c from ccrz__E_Order__c where id IN :setIDs];
		Contact con = [select id from Contact where id = :fetchOrder [0].ccrz__OriginatedCart__r.ccrz__Contact__c];
		List<ccrz__E_AccountGroupPriceList__c> accGrp = [select id from ccrz__E_AccountGroupPriceList__c where ccrz__PriceList__r.Name = 'PL002'];
		List<ccrz__E_PriceList__c> plists = [select id from ccrz__E_PriceList__c where Name = 'PL002'];
		EC_CacheWrapper cacheWrap = new EC_CacheWrapper();
		cacheWrap.contactAccList = listIds;

		Test.startTest();

		User currUser = EC_QueryUtility.getCurrentUser();
		String prof = EC_QueryUtility.getProfile();
		List<PermissionSetAssignment> permSetAssign = EC_QueryUtility.getPermissionSetAssignment();
		List<PermissionSet> permSet = EC_QueryUtility.getPermissionSet();
		List<EC_User_Role_CDM__mdt> userMetdata = EC_QueryUtility.getUserRoleCDMmdt(EC_Constants.BASIC, EC_Constants.BASIC);
		List<AccountContactRelation> acr = EC_QueryUtility.getAccountContactRelation(testUser);
		List<ccrz__E_OrderItem__c> ordItem = EC_QueryUtility.getOrderListItem(setIDs);
		List<ccrz__E_Cart__c> cart = EC_QueryUtility.getActiveCartRec(fetchOrder [0].ccrz__OriginatedCart__r.ccrz__EncryptedId__c);
		List<EC_UserRegistration_Custom_Code__mdt> userReg = EC_QueryUtility.getCustomCodeUserRegistration(EC_Constants.SUCCESSCODE);
		List<EC_MulesoftIntegration_Custom_Codes__mdt> msInt = EC_QueryUtility.getCustomCodeSelfAlignment(EC_Constants.SUCCESSCODE);
		list<ccrz__E_Cart__c> carts = EC_QueryUtility.getCartList((String) fetchOrder [0].ccrz__OriginatedCart__r.ccrz__Contact__c, true);
		List<ccrz__E_PriceListItem__c> plis = EC_QueryUtility.getPriceListItems(setStr, 'test001');
		List<ccrz__E_Invoice__c> invoice = EC_QueryUtility.getInvoice((String) fetchOrder [0].id);
		/*Contact conts = [select id from Contact where LastName  = 'TestUser'];
		 testUser.ContactId = conts.id;
		 update testUser;
		 String cont = EC_QueryUtility.getUserContact();*/
		List<User> usr = EC_TestData.setupCommunityUser();
		System.runas(usr [2]) {
			String cont = EC_QueryUtility.getUserContact();
		}
		EC_Mulesoft_Integration__c msIntgt = EC_QueryUtility.getHeader(csobj.Name);
		//List<AccountContactRelation> accCon = EC_QueryUtility.getAccountContactRelationOne(currUser,null);

		setStr.add(plists [0].id);
		plis = EC_QueryUtility.getOrderPriceListItems(setStr, 'test001');
		listIds.add(accGrp [0].id);
		List<ccrz__E_AccountGroupPriceList__c> accGroup = EC_QueryUtility.getAccountGroupPriceList(listIds);
		ordItem = EC_QueryUtility.getOrderListItemSortByName(listIds);
		permSetAssign  = EC_QueryUtility.getPermissionSetAssignmentList();
		setIds.add(prod [0].id);
		List<ccrz__E_ProductMedia__c> prodMedia = EC_QueryUtility.getListProdMedia(setIDs);
		List<ccrz__E_ProductMedia__c> prodMediaSDS = EC_QueryUtility.getListProdSDS(prdId);
		ords = EC_QueryUtility.getOrderList(listIds, '');
		currUser = [select id from User where Profile.Name = 'System Administrator' limit 1];
		ords = EC_QueryUtility.getOrderList(cacheWrap);
		setStr.add((String) prod [0].id);
		prodMedia = EC_QueryUtility.getProductMediaDocSearch(setStr);
		listId.add(prod [0].id);
		prodMedia = EC_QueryUtility.getDocuments(listId);
		cart = EC_QueryUtility.getActiveCart();
		cart = EC_QueryUtility.getActiveOpenCart();
		pliMap.put(plis [0].ccrz__Product__r.Name, plis [0]);
		prodMedia = EC_QueryUtility.getProductmediaList(pliMap);
		userMetdata = EC_QueryUtility.getUserRoleCDMmdt(null, EC_Constants.BASIC);
		ords = EC_QueryUtility.getOrderList(null, (String) fetchOrder [0].id);
		List<Contact> contacts = EC_QueryUtility.getSaleRepContact();
		List<Id> usrList = new List<Id>();
        List<AccountShare> acs = EC_QueryUtility.getAccShare(listIds,usrList);
		List<ccrz__E_PriceListItem__c> pliAfterTest = EC_QueryUtility.getPriceListItemsAutoSuggest(setStr,'test001');
		EC_QueryUtility.getProdSDS(prdId);
        EC_QueryUtility.getResponseCode('200');
        EC_QueryUtility.getProductsFromSkuIds(productSkuList);
		//System.assertEquals(conts.Name,EC_QueryUtility.getUserContact());
		//accCon = EC_QueryUtility.getAccountContactRelationOne(currUser,conts);

		Test.stopTest();

	}





}