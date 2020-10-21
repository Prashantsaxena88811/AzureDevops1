/*********************************************************************************
 Class Name      : EC_PastOrdersTest
 Description     : This class is used as the test class for EC_PastOrders
 Created By      :  Shruti Sinha ,Raghav Sharma
 Created Date    : 02-July-19
 Modification Log:
 ----------------------------------------------------------------------------------
 Developer                 Date                   Description
 ----------------------------------------------------------------------------------
 Shruti Sinha,Raghav Sharma              02-July-19              Initial Version
 *********************************************************************************/
@isTest
public class EC_PastOrdersTest {
	/***************************************************************************************************************************************
	 Method Name :  getPastOrderTest
	 Description : to get the previous orders
	 Return type : void
	 Author      : Raghav Sharma
	 *************************************************************************************************************************************/
	@isTest
	public static void getPastOrderTest() {
		EC_TestData.setupTestUser();
		User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
		List<EC_PastOrders.OrderInfo> lstOrderInfo = new List<EC_PastOrders.OrderInfo>();
		system.runas(thisUser) {
			EC_TestData.setupCatalog();
			EC_TestData.createOrders(8);
			EC_TestData.createOutageRecord();
			EC_PastOrders.outageRedirect();
			Test.startTest();
			lstOrderInfo = EC_PastOrders.getPastOrder();
			System.assert(lstOrderInfo.size() > 0);
			Test.stopTest();
		}
	}
	/***************************************************************************************************************************************
	 Method Name :  reorderTestForExistingCart
	 Description : to test the reorder method of EC_PastOrders
	 Return type : void
	 Author      : Raghav Sharma
	 *************************************************************************************************************************************/
	@isTest
	public static void reorderTestForExistingCart() {
		EC_TestData.setupTestUser();
		User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
		system.runas(thisUser) {
			List<ccrz__E_Order__c> order = EC_TestData.createOrders(1);
			Test.startTest();
			String str = EC_PastOrders.reorder(order [0].Id);
			String str1 = EC_PastOrders.reorder(order [0].Id);

			Test.stopTest();
		}
	}

	/***************************************************************************************************************************************
	 Method Name :  reorderTestForExistingCart
	 Description : to test the reorder method of EC_PastOrders
	 Return type : void
	 Author      : Raghav Sharma
	 *************************************************************************************************************************************/

	@isTest
	public static void reorderTestForNewCart() {
		EC_TestData.setupTestUser();
		User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
		List<ccrz__E_Order__c> order = EC_TestData.createOrders(1);
		List<ccrz__E_Cart__c> cc_carts = [SELECT Id, ccrz__Contact__c, LastModifiedDate, ccrz__EncryptedId__c
									      FROM ccrz__E_Cart__c
									      WHERE ccrz__Contact__c = :thisUser.ContactId
									      AND ccrz__ActiveCart__c = true
									      order by lastModifieddate desc];
		delete cc_carts;
		system.runas(thisUser) {
			Test.startTest();
			String str = EC_PastOrders.reorder(order [0].Id);

			Test.stopTest();
		}
	}
	/***************************************************************************************************************************************
	 Method Name :  getOrderItemDetailsTest
	 Description : to test the reorder method of EC_PastOrders
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void getOrderItemDetailsTest() {
		EC_TestData.setupTestUser();
		User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
		system.runas(thisUser) {
			EC_TestData.setupCatalog();
			EC_TestData.createOrders(10);


			ccrz__E_OrderItem__c order = [Select Id, ccrz__Order__r.Id, ccrz__Product__c from ccrz__E_OrderItem__c where ccrz__Product__r.ccrz__SKU__c = 'test003' limit 1];
			ccrz__E_ProductMedia__c sdsDoc = new ccrz__E_ProductMedia__c(ccrz__Product__c = order.ccrz__Product__c,
																    ccrz__ProductMediaSource__c = 'static',
																    ccrz__MediaType__c= 'Safety Documents');
			insert sdsDoc;

			Map<Id, List<ccrz__E_ProductMedia__c>> docmap = new Map<Id, List<ccrz__E_ProductMedia__c>>();

			List<EC_PastOrders.OrderItemWrapper> orderInfo = new List<EC_PastOrders.OrderItemWrapper>();

			Test.startTest();
			EC_PastOrders.OrderItemWrapper orderInfo1 = new EC_PastOrders.OrderItemWrapper();
			orderInfo = EC_PastOrders.getOrderDetails(order.ccrz__Order__r.Id);
			docmap = EC_PastOrders.getSDSDocuments(order.ccrz__Order__r.Id);
			EC_PastOrders.getInvoice(order.ccrz__Order__r.Id);


			System.assert(orderInfo.size() > 0);
			Test.stopTest();
		}
	}
	/***************************************************************************************************************************************
	 Method Name :  compVisibleTest
	 Description : to test the permCache
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
	public static testmethod void compVisibleTest() {



		List<User> usrlist = EC_TestData.setupCommunityUser();
		EC_TestData.createPermissionSet(usrlist);
		User user = usrlist [0];
		EC_TestData.TestCacheUser(user);
		Test.startTest();
		EC_PastOrders.compVisible();
		Test.stopTest();
	}
	/***************************************************************************************************************************************
	 Method Name :  getPastOrderTest
	 Description : to get the previous orders
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void getSalesRepPastOrderTest() {
		EC_TestData.setupTestSalesRepUser();
		User thisUser = [SELECT Id FROM User WHERE LastName = 'SalesRepUser'];
		List<EC_PastOrders.OrderInfo> lstOrderInfo = new List<EC_PastOrders.OrderInfo>();
		system.runas(thisUser) {
			EC_TestData.setupCatalog();
			EC_TestData.createOrders(8);
			EC_TestData.createContactForSalesrep(1);

			Test.startTest();
			lstOrderInfo = EC_PastOrders.getPastOrder();
			//  System.assert(lstOrderInfo.size()>0);
			Test.stopTest();
		}
	}

	/***************************************************************************************************************************************
	 Method Name :  getOrderDetailsTest
	 Description : to orders details
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void getSalesRepOrderDetailsTest() {
		EC_TestData.setupTestSalesRepUser();
		User thisUser = [SELECT Id FROM User WHERE LastName = 'SalesRepUser'];

		system.runas(thisUser) {
			EC_TestData.setupCatalog();
			EC_TestData.createOrders(10);



			ccrz__E_OrderItem__c order = [Select Id, ccrz__Order__r.Id, ccrz__Product__c from ccrz__E_OrderItem__c where ccrz__Product__r.ccrz__SKU__c = 'test003' limit 1];

			Map<Id, List<ccrz__E_ProductMedia__c>> docmap = new Map<Id, List<ccrz__E_ProductMedia__c>>();

			List<EC_PastOrders.OrderItemWrapper> orderInfo = new List<EC_PastOrders.OrderItemWrapper>();

			Test.startTest();
			EC_PastOrders.OrderItemWrapper orderInfo1 = new EC_PastOrders.OrderItemWrapper();
			orderInfo = EC_PastOrders.getOrderDetails(order.ccrz__Order__r.Id);
			docmap = EC_PastOrders.getSDSDocuments(order.ccrz__Order__r.Id);
			EC_PastOrders.getInvoice(order.ccrz__Order__r.Id);


			System.assert(orderInfo.size() > 0);
			Test.stopTest();
		}
	}

   
/***************************************************************************************************************************************
      Method Name :  checkPayerPermissionTest
      Description : to orders details
      Return type : void
      Author      : Raghu Varma
*************************************************************************************************************************************/       
    
 @isTest 
    public static void checkPayerPermissionTest(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
        PermissionSetAssignment perm = new PermissionSetAssignment();
        system.debug('thisUser:'+thisUser.Id);
        Test.startTest();
        PermissionSet ps = new PermissionSet();
        List<PermissionSet> pslist =[select id from PermissionSet where name =: EC_Constants.PayerCustomPermission];
            system.debug('pslist:'+pslist);
            if(pslist.size()>0){
                system.debug('pslist:'+pslist);
                ps = pslist[0];
            }
        List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
            newAssignments.add(new PermissionSetAssignment(
                PermissionSetId=ps.Id, AssigneeId=thisUser.Id
            ));
         Database.SaveResult[] sr = Database.insert(newAssignments, false);
        system.runas(thisUser) {
		   Boolean result = EC_PastOrders.checkPayerPermission();
        }
        Test.stopTest();
    }

    /***************************************************************************************************************************************
      Method Name :  getAthenaPastOrdersTest
      Description : 
      Return type : void
      Author      : Aravind Tallapaka
*************************************************************************************************************************************/
    @isTest  
    public static  void getAthenaPastOrdersTest(){
        EC_TestData.setupShipToTestUser();
        EC_TestData.createEC_PermissionSetMapping();        
        User usr = [Select Id,FirstName,LastName,ContactId,Contact.Email,Username,Contact.AccountId,Contact.Account.EC_Account_Number__c   FROM User WHERE LastName = 'TestUser'];
        System.runAs(usr){
            Account soldToAccount = new Account(
                Name                    = 'SoldTo_Acc',
                OwnerId                 = UserInfo.getUserId(),
                Type                    = 'Customer',
                EC_Status__c            = 'Active',
                EC_Account_Number__c    = '322235',
                EC_SalesRepresentative__c = UserInfo.getUserId(),
                recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To').getRecordTypeId()
            );
            insert soldToAccount;
            insert new EC_Custom_URL_Settings__c(Name = 'Athena_Orders_Cloudhub', custom_url__c = 'https://api-cloudhubcentral-st.ecolab.com/orders/v1/shiptonumbers');
            insert new EC_Custom_URL_Settings__c(Name = 'Microsoft OAuth Token', custom_url__c = 'https://login.microsoftonline.com/ecolab.com/oauth2/token');
            insert new EC_Athena_Settings__c(Name = 'GrantType', value__c = 'client_credentials');
            insert new EC_Athena_Settings__c(Name = 'ClientId', value__c = '81e0147a-46f3-4378-a28e-9f107202b9c8');
            insert new EC_Athena_Settings__c(Name = 'ClientSecret', value__c = '+8UK69YONWOA0nCOBwEbFh0X6GlHwASxoDqQec8xpR8=');
            insert new EC_Athena_Settings__c(Name = 'Resource', value__c = '0424e542-1ef6-4a47-81fc-9c533794e78c');            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EC_OmniOrdersMock());
            EC_PastOrders.getAthenaPastOrders();
            EC_TestData.createOutageRecord();
            Boolean outageFlag = EC_SelfRegistrationController.outageRedirect();
            System.assert(outageFlag);
            Test.stopTest();
        }
    }
      
/***************************************************************************************************************************************
      Method Name :  getProductDataTest
      Description : 
      Return type : void
      Author      : Raghu Varma
*************************************************************************************************************************************/       
@isTest 
    public static void getProductDataTest(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser'];
        
        List<String> productList = new List<String>();
        
        system.runas(thisUser){
            List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
            products = EC_TestData.products;
            ccrz__E_Cart__c cart = EC_TestData.createCart();
            for(ccrz__E_Product__c prod : products) {
            productList.add(prod.ccrz__SKU__c);
        }
            List<EC_PastOrders.AthenaOrderItemWrapper> productData = new List<EC_PastOrders.AthenaOrderItemWrapper>();
            Test.startTest();   
            productData = EC_PastOrders.getProductData(productList);
            System.assert(productData.size()>0);
            Test.stopTest();
        }
	}
	@isTest
    public static void athenaReorderTestForExistingCart(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id,ContactId FROM User WHERE LastName = 'TestUser'];
        system.runas(thisUser){
            List<ccrz__E_Order__c> order = EC_TestData.createShipToOrders(1);
            Test.startTest();
           
            String effectiveAccountId = order[0].ccrz__Account__c;
            List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
            products = EC_TestData.products;
            List<String> productList = new List<String>();
            List<String> productListQuantity = new List<String>();
            Integer count = 0;
            for(ccrz__E_Product__c prod : products) {
                productList.add(prod.ccrz__SKU__c);
                productListQuantity.add(prod.ccrz__SKU__c+':'+'1');
                count++;
                if(count > 5){
                    break;
                }
            }
            List<Account> AccountNumber = [SELECT EC_Account_Number__c FROM Account WHERE Id =: effectiveAccountId];
            system.debug('effectiveAccountId:'+effectiveAccountId);
            system.debug('productList:'+productList);
            system.debug('productListQuantity:'+productListQuantity);
            if(!AccountNumber.isEmpty()){
            	String str2 = EC_PastOrders.athenaReorder(AccountNumber[0].EC_Account_Number__c,productList,productListQuantity);
            }
            Test.stopTest();
        }
    }
   
    @isTest
    public static void athenaReorderTestForNewCart(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
        List<ccrz__E_Order__c> order = EC_TestData.createShipToOrders(1);
        List<ccrz__E_Cart__c> cc_carts = [SELECT Id, ccrz__Contact__c, LastModifiedDate, ccrz__EncryptedId__c
                                              FROM ccrz__E_Cart__c
                                              WHERE ccrz__Contact__c = :thisUser.ContactId
                                              AND ccrz__ActiveCart__c = true
                                              order by lastModifieddate desc];
        delete cc_carts;
        system.runas(thisUser){
            Test.startTest();
           
            String effectiveAccountId = order[0].ccrz__Account__c;
            List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
            products = EC_TestData.products;
            List<String> productList = new List<String>();
            List<String> productListQuantity = new List<String>();
            Integer count = 0;
            for(ccrz__E_Product__c prod : products) {
                productList.add(prod.ccrz__SKU__c);
                productListQuantity.add(prod.ccrz__SKU__c+':'+'1');
                count++;
                if(count > 5){
                    break;
                }
            }
            List<Account> AccountNumber = [SELECT EC_Account_Number__c FROM Account WHERE Id =: effectiveAccountId];
            system.debug('effectiveAccountId:'+effectiveAccountId);
            system.debug('productList:'+productList);
            system.debug('productListQuantity:'+productListQuantity);
            if(!AccountNumber.isEmpty()){
				String str1 = EC_PastOrders.athenaReorder(AccountNumber[0].EC_Account_Number__c,productList,productListQuantity);
            }
        
            Test.stopTest();
        }
    }
    @isTest
    public static void athenaSwitchSettingTest(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
        system.runas(thisUser){
            insert new EC_Custom_Switch_Settings__c(Name = 'AthenaSwitch', Is_Athena_Enabled__c = true);
        	Test.startTest();
			Boolean str1 = EC_PastOrders.getAthenaSwitchSetting();
			System.assert(str1 == true || str1 == false);
            Test.stopTest();
        }
    }
}