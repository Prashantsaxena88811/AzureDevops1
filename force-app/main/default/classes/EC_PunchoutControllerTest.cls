/* Class Name       :EC_PunchoutControllerTest
 * Description      :This is the test class to test the EC_PunchoutController class
 * Created By       :Harsha N
 * Created On       :24-10-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Ayusha Patnaik          17-10-2019                                  This is the controller class that helps the iBuy user to punch out of the system
 *
 */
@isTest
public class EC_PunchoutControllerTest {

	/*************************************************************************************************************************************
	 Method Name : completeTest
	 Description : Test class to create the CXML with the Cart Id
	 Parameter   : NA
	 Return type : void
	 Author      : Harsha N
	 *************************************************************************************************************************************/

	@isTest
	public static void completeTest() {
		EC_TestData.setupTestUser();
		User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];

		system.runas(thisUser) {

			EC_TestData.setupCatalog();

			ccrz__E_Category__c allProdsCateg = new ccrz__E_Category__c(Name = 'All Products',
																	    ccrz__CategoryID__c = 'ALL-PRODUCTS',
																	    ccrz__StartDate__c  = Date.today().addDays(-1),
																	    ccrz__EndDate__c    = Date.today().addDays(1));
			insert allProdsCateg;

			ccrz__E_Cart__c cartRec = EC_TestData.createCart();
			ccrz__E_Product__c prodRec = [SELECT Id FROM ccrz__E_Product__c LIMIT 1];
			ccrz__E_CartItem__c cartItemRec = addCartItem(cartRec, prodRec.Id, 1.00, 100.00);

			EC_PunchOutInfo__c punchRec = new EC_PunchOutInfo__c();
			punchRec.EC_BuyerCookie__c = 'randomText';
			punchRec.EC_From_Domain__c = 'randomText';
			punchRec.EC_From_Identity__c = 'randomText';
			punchRec.EC_To_Domain__c = 'randomText';
			punchRec.EC_To_Identity__c = 'randomText';
			punchRec.EC_Sender_Domain__c = 'randomText';
			punchRec.EC_Sender_Identity__c = 'randomText';
			punchRec.EC_SenderUserAgent__c = 'randomText';
			punchRec.EC_Version__c = 'randomText';
			punchRec.EC_XMLLanguage__c = 'randomText';
			punchRec.EC_PayloadId__c = 'randomText';
			punchRec.EC_EncryptedCartId__c = cartRec.ccrz__EncryptedId__c;
			insert punchRec;

			Test.startTest();


			Map<String, String> cXMLDummy = EC_PunchoutController.generateCXMLWithCart(cartRec.ccrz__EncryptedId__c);
			string cXMLStr = cXMLDummy.get('cxmlString');
			string cXMLErrorStr = EC_PunchoutController.generateCXMLWIthError('Test Error');
			EC_PunchoutController ec = new EC_PunchoutController();
            ec.returnValue = 'test value';
            ec.cXMLStr = 'test value';
            ec.punchOutCallbackURL = 'test value';
			PageReference pageRef = Page.EC_PunchoutLogin;
			Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('ukey', 'randomText');
			System.currentPageReference().getParameters().put('pkey', 'randomText');
			System.currentPageReference().getParameters().put('effectiveAccount', 'randomText');
			System.currentPageReference().getParameters().put('cartId', cartRec.ccrz__EncryptedId__c);
			PageReference pageRefOut = EC_PunchoutController.redirectToPunchoutLogin();
            
            System.currentPageReference().getParameters().put('ukey', '');
			System.currentPageReference().getParameters().put('pkey', '');
			System.currentPageReference().getParameters().put('effectiveAccount', 'randomText');
			System.currentPageReference().getParameters().put('cartId', cartRec.ccrz__EncryptedId__c);
            System.currentPageReference().getParameters().put('startURL', 'startURL');
            
			PageReference pageRefOut22 = EC_PunchoutController.redirectToPunchoutLogin();

			System.currentPageReference().getParameters().put('ukey', 'randomText');
			System.currentPageReference().getParameters().put('pkey', 'randomText');
			System.currentPageReference().getParameters().put('effectiveAccount', 'randomText');
			System.currentPageReference().getParameters().put('cartId', cartRec.ccrz__EncryptedId__c);
			System.currentPageReference().getParameters().put('startURL', 'startURL');
            
			PageReference pageRefOutAnother = EC_PunchoutController.redirectToPunchoutLogin();

			Test.stopTest();
		}
	}

	/*************************************************************************************************************************************
	 Method Name : addCartItem
	 Description : Add Cart Item
	 Parameter   : ccrz__E_Cart__c, Id, Decimal, Decimal
	 Return type : ccrz__E_CartItem__c
	 Author      : Harsha N
	 *************************************************************************************************************************************/

	public static ccrz__E_CartItem__c addCartItem(ccrz__E_Cart__c testCart, Id prodId, Decimal qty, Decimal price) {
		return addCartItems(testCart,
						    new Map<Id, Decimal>{ prodId => qty },
						    new Map<Id, Decimal>{ prodId => price }).get(0);
	}

	/*************************************************************************************************************************************
	 Method Name : addCartItems
	 Description : Test class to add cart item
	 Parameter   : ccrz__E_Cart__c, Map<Id, Decimal>,Map<Id, Decimal>
	 Return type : void
	 Author      : Harsha N
	 *************************************************************************************************************************************/

	public static List<ccrz__E_CartItem__c> addCartItems(ccrz__E_Cart__c testCart,
													     Map<Id, Decimal> productQuantityMap,
													     Map<Id, Decimal> productPriceMap) {
		final List<ccrz__E_CartItem__c> items = new List<ccrz__E_CartItem__c>();
		final Map<Id, Decimal> itemPrices = (null == productPriceMap) ? new Map<Id, Decimal>() :productPriceMap;

		for (Id productId :productQuantityMap.keySet()) {
			final Decimal itemPrice = itemPrices.containsKey(productId) ? itemPrices.get(productId) :1000.00;
			items.add(new ccrz__E_CartItem__c(ccrz__Cart__c = testCart.Id,
				      ccrz__Quantity__c     = productQuantityMap.get(productId),
				      ccrz__Product__c      = productId,
				      ccrz__Price__c        = itemPrice,
				      ccrz__SubAmount__c    = productQuantityMap.get(productId) * itemPrice,
				      ccrz__UnitOfMeasure__c= 'Each'));
		}
		insert items;
		return items;
	}
}