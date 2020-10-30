/* Class Name       :EC_OrderInfoTest
 * Description      :This is the Test class for EC_OrderInfo
 * Created By       :Harsha N
 * Created On       :06-27-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 *  Harsha N               06-27-2019                                   This is the Test class for EC_OrderInfo
 *  Raghav Sharma
 */
@isTest
public class EC_OrderInfoTest {
	@isTest
	public static void getrecentOrderTest() {
		EC_TestData.setupTestUser();
		User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
		List<EC_OrderInfo.ProdInfo> lstProdInfo = new List<EC_OrderInfo.ProdInfo>();

		system.runas(thisUser) {
			EC_TestData.assignPestPermissions(thisUser);
			EC_TestData.setupCatalog();
			EC_TestData.createOrders(8);
			Chemical_Product_Type__c packTypeCS = new Chemical_Product_Type__c();
            packTypeCS.Active__c = true;
            packTypeCS.Package_Code__c = '91';
            packTypeCS.Name = '91';
            insert packTypeCS;
			ccrz__E_OrderItem__c ordItem = [Select Id,ccrz__Order__r.ccrz__Account__r.ccrz__E_AccountGroup__c, ccrz__Order__r.ccrz__EffectiveAccountID__c, ccrz__Order__c from ccrz__E_OrderItem__c limit 1];
			Id ordItemId = ordItem.Id;
			EC_TestData.createOutageRecord();
			EC_OrderInfo.outageRedirect();
			EC_OrderInfo.isBasicBuyerCheck();
			Test.startTest();
			lstProdInfo = EC_OrderInfo.getRecentOrder();
			List<EC_Utility.PermWrapper> tempVar = EC_OrderInfo.compVisible();
			System.assert(lstProdInfo.size() > 0);

			string cartURL = EC_OrderInfo.getCartURL(ordItemId);
			System.assert(cartURL != null);
			Test.stopTest();
		}
	}

	/***************************************************************************************************************************************
	Method Name : getrecentOrderTestSalesRep
	Description : test method
	Parameter   : N/A
	Return type : Void
	Author      : Harsha N
	*************************************************************************************************************************************/
	@isTest
	public static void getrecentOrderTestSalesRep() {
		EC_TestData.setupTestSalesRepUser();
		User thisUser = [SELECT Id FROM User WHERE LastName = 'SalesRepUser'];
		List<EC_OrderInfo.ProdInfo> lstProdInfo = new List<EC_OrderInfo.ProdInfo>();

		system.runas(thisUser) {

			EC_TestData.setupCatalog();
			EC_TestData.createOrders(8);
			ccrz__E_OrderItem__c ordItem = [Select Id, ccrz__Order__r.ccrz__EffectiveAccountID__c, ccrz__Order__c from ccrz__E_OrderItem__c limit 1];
			Id ordItemId = ordItem.Id;
			EC_TestData.createOutageRecord();
			EC_OrderInfo.outageRedirect();
			Test.startTest();
			lstProdInfo = EC_OrderInfo.getRecentOrder();

			Test.stopTest();
		}
	}

	
    /***************************************************************************************************************************************
    Method Name : getRecentOrderINSTDirectTest
    Description : test method to validate recent orders for ISE-DirectAccount
    Parameter   : N/A
    Return type : void
    *************************************************************************************************************************************/
    @isTest
	public static void getRecentOrderINSTDirectTest() {
        EC_TestData.setupTestUser();
		User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
		
        EC_ISETestDataFactory.setupInstSalesEntitlements();
		EC_ISETestDataFactory.setupAccConRelForUsr();
		EC_ISETestDataFactory.createOrdersForINSTDirect(6);

		system.runas(thisUser) {
            EC_TestData.setupCatalog();
            EC_TestData.createOutageRecord();
			EC_OrderInfo.outageRedirect();
			
            Test.startTest();
			List<EC_OrderInfo.ProdInfo> lstProdInfo = EC_OrderInfo.getRecentOrder();
			System.assert(!lstProdInfo.isEmpty());
			Test.stopTest();
        }
    }
    
    /***************************************************************************************************************************************
    Method Name : getRecentOrderINSTIndirectTest
    Description : test method to validate recent orders for ISE-IndirectAccount
    Parameter   : N/A
    Return type : void
    *************************************************************************************************************************************/
    @isTest
	public static void getRecentOrderINSTIndirectTest() {
        EC_TestData.setupTestUser();
		User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
		
        EC_ISETestDataFactory.setupInstSalesEntitlements();
		EC_ISETestDataFactory.setupAccConRelForUsr();
        EC_ISETestDataFactory.createOrdersForINSTIndirect(6);

		system.runas(thisUser) {
            EC_TestData.setupCatalog();
            EC_TestData.createOutageRecord();
			EC_OrderInfo.outageRedirect();
            
			Test.startTest();
			List<EC_OrderInfo.ProdInfo> lstProdInfo = EC_OrderInfo.getRecentOrder();
			System.assert(!lstProdInfo.isEmpty());
			Test.stopTest();
        }
    }
}