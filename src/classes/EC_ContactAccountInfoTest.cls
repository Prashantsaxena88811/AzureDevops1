/* Class Name       :EC_ContactAccountInfoTest
 * Description      :Test Class for EC_ContactAccountInfo
 * Created By       :Harsha N
 * Created On       :07-05-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Harsha N       07-05-2019                                   Test Class for EC_ContactAccountInfo
 * Raghav Sharma
 */
@isTest(SeeAllData = false)public class EC_ContactAccountInfoTest {
	@TestSetup
	static void setupData() {
		EC_TestData.setupTestUser();
		User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

		List<Account> lstAcc = new List<Account>();
		Map<string, Account> mapAcc = new Map<string, Account>();

		system.runas(thisUser) {
			Account corpAccount = new Account(Name = 'Corporate_Acc',
										      OwnerId                 = UserInfo.getUserId(),
										      Type                    = 'Customer',
										      EC_Status__c            = 'Active',
										      EC_CDM_Account__c       = '324235',
										      recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId());
			lstAcc.add(corpAccount);
			mapAcc.put('corp', corpAccount);

			Account soldToAccount = new Account(Name = 'SoldTo_Acc',
											    OwnerId                 = UserInfo.getUserId(),
											    Type                    = 'Customer',
											    EC_Status__c            = 'Active',
											    EC_Account_Number__c    = '322235',
											    EC_CDM_Account__c       = '123456',
											    EC_SalesRepresentative__c = UserInfo.getUserId(),
											    recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To').getRecordTypeId());
			lstAcc.add(soldToAccount);
			mapAcc.put('sold', soldToAccount);

			Account soldToAccount1 = new Account(Name = 'SoldTo_Acc1',
											     OwnerId                 = UserInfo.getUserId(),
											     Type                    = 'Customer',
											     EC_Status__c            = 'Active',
											     EC_Account_Number__c    = '322236',
											     recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To').getRecordTypeId());
			lstAcc.add(soldToAccount1);
			mapAcc.put('sold1', soldToAccount1);

			Account shipToAccount1 = new Account(Name = 'shipTo_Acc1',
											     OwnerId                 = UserInfo.getUserId(),
											     Type                    = 'Customer',
											     EC_Status__c            = 'Active',
											     EC_Account_Number__c    = '324985',
												 EC_Division__c 		 = 'WATER',
											     Phone                   = '8976453786',
											     recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId(),
											     ShippingStreet          = EC_TestData.generateRandomString(32),
											     ShippingCity            = EC_TestData.generateRandomString(32),
											     ShippingState           = EC_TestData.generateRandomString(32),
											     ShippingCountry         = EC_TestData.generateRandomString(32),
											     ShippingPostalCode      = EC_TestData.generateRandomString(5));
			lstAcc.add(shipToAccount1);
			mapAcc.put('ship1', shipToAccount1);

			Account shipToAccount2 = new Account(Name = 'shipTo_Acc2',
											     OwnerId                 = UserInfo.getUserId(),
											     Type                    = 'Customer',
											     EC_Status__c            = 'Active',
											     EC_Account_Number__c    = '324986',
												 EC_Division__c 		 = 'Institutional',
											     Phone                   = '8976453786',
											     EC_SalesRepresentative__c = UserInfo.getUserId(),
											     recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId(),
											     ShippingStreet          = EC_TestData.generateRandomString(32),
											     ShippingCity            = EC_TestData.generateRandomString(32),
											     ShippingState           = EC_TestData.generateRandomString(32),
											     ShippingCountry         = EC_TestData.generateRandomString(32),
											     ShippingPostalCode      = EC_TestData.generateRandomString(5));
			lstAcc.add(shipToAccount2);
			mapAcc.put('ship2', shipToAccount2);

			Account shipToAccount3 = new Account(Name = 'shipTo_Acc3',
											     OwnerId                 = UserInfo.getUserId(),
											     Type                    = 'Customer',
											     EC_Status__c            = 'Active',
											     EC_Account_Number__c    = '324987',
												 EC_Division__c 		 = 'Institutional',
											     Phone                   = '8976453786',
											     recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId(),
											     ShippingStreet          = EC_TestData.generateRandomString(32),
											     ShippingCity            = EC_TestData.generateRandomString(32),
											     ShippingState           = EC_TestData.generateRandomString(32),
											     ShippingCountry         = EC_TestData.generateRandomString(32),
											     ShippingPostalCode      = EC_TestData.generateRandomString(5));
			lstAcc.add(shipToAccount3);
			mapAcc.put('ship3', shipToAccount3);

			Account shipToAccount4 = new Account(Name = 'shipTo_Acc4',
											     OwnerId                 = UserInfo.getUserId(),
											     Type                    = 'Customer',
											     EC_Status__c            = 'Active',
											     EC_Account_Number__c    = '324988',
												 EC_Division__c 		 = 'WATER',
											     EC_CDM_Account__c       = '12345',
											     Phone                   = '8976453786',
											     recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId(),
											     ShippingStreet          = '',
											     ShippingCity            = '',
											     ShippingState           = '',
											     ShippingCountry         = '',
											     ShippingPostalCode      = '');
			lstAcc.add(shipToAccount4);
			mapAcc.put('ship4', shipToAccount4);

			insert lstAcc;

			list<account> lstUpdateAcc = new list<account>();
			for(account tmpAcc :mapAcc.values()) {
				if(tmpAcc.Name == 'SoldTo_Acc') {
					tmpAcc.parentId = mapAcc.get('corp').id;
					lstUpdateAcc.add(tmpAcc);
				} else if(tmpAcc.Name == 'shipTo_Acc3') {
					tmpAcc.parentId = mapAcc.get('sold').id;
					lstUpdateAcc.add(tmpAcc);
				} else if(tmpAcc.Name == 'shipTo_Acc4') {
					tmpAcc.parentId = mapAcc.get('sold').id;
					lstUpdateAcc.add(tmpAcc);
				} else if(tmpAcc.Name == 'shipTo_Acc2') {
					tmpAcc.parentId = mapAcc.get('sold1').id;
					lstUpdateAcc.add(tmpAcc);
				}
			}
			update lstUpdateAcc;
			Account shipToAccount5 = new Account(Name = 'shipTo_Acc5',
												    OwnerId                 = UserInfo.getUserId(),
												    Type                    = 'Customer',
												    EC_Status__c            = 'Active',
												    EC_Account_Number__c    = '100001',
												    Phone                   = '8976453786',
												    recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId(),
												    ShippingStreet          = EC_TestData.generateRandomString(32),
												    ShippingCity            = EC_TestData.generateRandomString(32),
												    ShippingState           = EC_TestData.generateRandomString(32),
												    ShippingCountry         = EC_TestData.generateRandomString(32),
												    ShippingPostalCode      = EC_TestData.generateRandomString(5),
												    parentId                 = mapAcc.get('sold').id);
			insert shipToAccount5;

			List<AccountContactRelation> lstAccContRec = new List<AccountContactRelation>();
			for(account tmpAcc :mapAcc.values()) {
				AccountContactRelation accContRec = new AccountContactRelation(AccountId = tmpAcc.id, ContactId = thisUser.contactId, Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE);
				lstAccContRec.add(accContRec);
			}
			insert lstAccContRec;
            upsert new EC_LogsEnabler__c(Name = 'selfAccountAlignment',
                                     EC_LogsEnabled__c = false
                                    );
        upsert new EC_LogsEnabler__c(Name = 'selfAccountAlignment',
                                     EC_LogsEnabled__c = true
                                    );
		}
	}
	/***************************************************************************************************************************************
	 Method Name : setupMuleSoftIntegration()
	 Description : to setup Custom Setting
	 Return type :
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void testShipSoldCont() {
		User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

		Account accRec = [SELECT Id FROM Account WHERE EC_Account_Number__c = '324985'];
		System.assertNotEquals(null, accRec);
		Contact tempContRec = [SELECT Id FROM Contact WHERE Id = :thisUser.contactId];
		System.assertNotEquals(null, tempContRec);
		EC_ContactAccountInfo.contactInfoWrapper classInst = new EC_ContactAccountInfo.contactInfoWrapper();
		system.runas(thisUser) {
			Test.startTest();
			classInst = EC_ContactAccountInfo.getContactAccountInformation();

			System.assert(classInst.lstAcc.size() > 0);
			Test.stopTest();
		}

	}
	/***************************************************************************************************************************************
	 Method Name : setupMuleSoftIntegration()
	 Description : to setup Custom Setting
	 Return type :
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void testRecSalesRep() {
		EC_TestData.setupTestSalesRepUser();
		EC_TestData.createContactForSalesrep(2);
		User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'SalesRepUser'];

		Account accRec = [SELECT Id FROM Account WHERE EC_Account_Number__c = '324985'];
		System.assertNotEquals(null, accRec);
		Contact tempContRec = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact limit 1];
		System.assertNotEquals(null, tempContRec);
		EC_ContactAccountInfo.contactInfoWrapper classInst1 = new EC_ContactAccountInfo.contactInfoWrapper();
		EC_ContactAccountInfo.accInfoWrapper accInf = new EC_ContactAccountInfo.accInfoWrapper();
		EC_ContactAccountInfo.addressInfoWrapper ad = new EC_ContactAccountInfo.addressInfoWrapper();
		ad.ShiptoId = 'Test';
		ad.ShiptoAddress = 'Test';
		ad.ShiptoCity = 'Test';
		ad.ShiptoState = 'Test';
		ad.ShiptoStreet = 'Test';
		ad.fullAddress = 'Test';
		ad.phoneNumber = 'Test';
		accInf.accName = 'Test';
		accInf.accNum = 'Test';
		accInf.lstShipTo = new List<EC_ContactAccountInfo.addressInfoWrapper>();
		accInf.lstShipTo.add(ad);
		List<EC_ContactAccountInfo.accInfoWrapper> accInfList = new List<EC_ContactAccountInfo.accInfoWrapper>();
		accInfList.add(accInf);



		system.runas(thisUser) {
			Test.startTest();
			classInst1 = EC_ContactAccountInfo.createContactInfoRecSalesRep(tempContRec, accInfList);
			EC_ContactAccountInfo.contactInfoWrapper contWrap = EC_ContactAccountInfo.getContactAccountInformation();
			System.assert(classInst1.lstAcc.size() > 0);
			Test.stopTest();
		}
	}

	/***************************************************************************************************************************************
	Method Name : selfAccountAlignmentShipTo1002()
	Description : Test Method to cover SelfAlignment 1002 response
	Return type :
	*************************************************************************************************************************************/
	@isTest
	public static void selfAccountAlignmentShipTo1002() {
		User thisUser = [SELECT Id, EC_CDM_User__c, contactId FROM User WHERE LastName = 'TestUser'];

		EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
		csobj.EC_ClientId__c = '12345678';
		csobj.EC_Client_Secret__c = '11114563';
		csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
		csobj.Name = 'SELFALIGNMENT';
		insert csobj;
		Account accRec = [SELECT Id, EC_Account_Number__c FROM Account WHERE EC_Account_Number__c = '324985'];
		System.assertNotEquals(null, accRec);

		Contact tempContRec = [SELECT Id FROM Contact WHERE Id = :thisUser.contactId];
		System.assertNotEquals(null, tempContRec);
		
		Map<String, String> myMap = new Map<String, String>{ 'AccountNumber' => '324985', 'SalesRepEmail' => 'jamie@lannister.com' };

		List<EC_MulesoftIntegration_Custom_Codes__mdt> code = new List<EC_MulesoftIntegration_Custom_Codes__mdt>();

		system.runas(thisUser) {
			Test.setMock(HttpCalloutMock.class, new EC_MockHttpResponseGenerator('SelfAlign1002'));
			Test.startTest();

			code = EC_ContactAccountInfo.selfAccountAlignment(myMap);
			System.assertEquals(code[0].EC_CustomCodes__c, '1002');
			Test.stopTest();
		}
	}

	/*************************************************************************************************************************************
	Method Name : selfAccountAlignmentShipTo1001()
	Description : Test Method to cover SelfAlignment 1002 response
	Return type :
	**************************************************************************************************************************************/
	@isTest
	public static void selfAccountAlignmentShipTo1001() {
		User thisUser = [SELECT Id, EC_CDM_User__c, contactId FROM User WHERE LastName = 'TestUser'];

		EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
		csobj.EC_ClientId__c = '12345678';
		csobj.EC_Client_Secret__c = '11114563';
		csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
		csobj.Name = 'SELFALIGNMENT';
		insert csobj;
		Account accRec = [SELECT Id, EC_Account_Number__c FROM Account WHERE EC_Account_Number__c = '324985'];
		System.assertNotEquals(null, accRec);

		Contact tempContRec = [SELECT Id FROM Contact WHERE Id = :thisUser.contactId];
        System.assertNotEquals(null, tempContRec);

		Map<String, String> myMap = new Map<String, String>{ 'AccountNumber' => '324985', 'SalesRepEmail' => 'jamie@lannister.com' };

		List<EC_MulesoftIntegration_Custom_Codes__mdt> code = new List<EC_MulesoftIntegration_Custom_Codes__mdt>();

		system.runas(thisUser) {
			Test.setMock(HttpCalloutMock.class, new EC_MockHttpResponseGenerator('SelfAlign1001'));
			Test.startTest();

			code = EC_ContactAccountInfo.selfAccountAlignment(myMap);
			System.assertEquals(code[0].EC_CustomCodes__c, '1001');
			Test.stopTest();
		}
	}

	/***************************************************************************************************************************************
	 Method Name : setupMuleSoftIntegration()
	 Description : to setup Custom Setting
	 Return type :
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
	@isTest
	public static void alignShipToTest() {

		User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

		Account accRec = [SELECT Id, EC_Account_Number__c FROM Account WHERE EC_Account_Number__c = '322235'];
		Contact con = [SELECT Id FROM Contact WHERE Id = :thisUser.contactId];
		test.startTest();
		EC_ContactAccountInfo.alignShipTo(accRec, con);
		EC_ContactAccountInfo.alignSoldToAndRelatedShipTo(accRec, con);
		test.stopTest();

	}

	/***************************************************************************************************************************************
	 Method Name : setupMuleSoftIntegration()
	 Description : to setup Custom Setting
	 Return type :
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void alignContactAccount() {

		User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
		System.runAs(thisUser) {
			String accountNo = '324988';
			String salesRepEmail = 'abc@def.com';
			String userKey = '1234';
			EC_RegMuleSoftWrapper wrp = new EC_RegMuleSoftWrapper(accountNo, salesRepEmail, userKey);
			wrp.accountKey = '12345';
			//EC_TestData.setupTestUser();

			Contact currentContact = [Select Id, AccountId from contact where id = :thisUser.ContactId];
			Account acc = [SELECT Id, EC_Account_Number__c FROM Account WHERE EC_Account_Number__c = '324986'];
			System.assertNotEquals(null, acc);
			test.startTest();
			EC_ContactAccountInfo.alignContactAccount(wrp, currentContact);

			test.stopTest();
		}
	}
	/***************************************************************************************************************************************
	 Method Name : setupMuleSoftIntegration()
	 Description : to setup Custom Setting
	 Return type :
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void NegalignContactAccount() {

		User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
		System.runAs(thisUser) {
			String accountNo = '322235';
			String salesRepEmail = 'abc@def.com';
			String userKey = '1234';
			EC_RegMuleSoftWrapper wrp = new EC_RegMuleSoftWrapper(accountNo, salesRepEmail, userKey);
			wrp.accountKey = '123456';
			//EC_TestData.setupTestUser();

			Contact currentContact = [Select Id, AccountId from contact where id = :thisUser.ContactId];
			Account acc = [SELECT Id, EC_Account_Number__c, RecordType.Name FROM Account WHERE EC_Account_Number__c = '322235'];
			System.assertNotEquals(null, acc);
			test.startTest();
			EC_ContactAccountInfo.alignContactAccount(wrp, currentContact);

			test.stopTest();
		}

	}
	/***************************************************************************************************************************************
	 Method Name : setupMuleSoftIntegration()
	 Description : to setup Custom Setting
	 Return type :
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void NegAlignShipTo() {

		User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
		System.runAs(thisUser) {
			Contact currentContact = [Select Id, AccountId from contact where id = :thisUser.ContactId];
			Account acc = [SELECT Id, EC_Account_Number__c, RecordType.Name FROM Account WHERE EC_Account_Number__c = '100001'];

			test.startTest();
			EC_ContactAccountInfo.alignShipTo(acc, currentContact);

			test.stopTest();
		}

	}
	/***************************************************************************************************************************************
	 Method Name : setupMuleSoftIntegration()
	 Description : to setup Custom Setting
	 Return type :
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void NegAlignSoldToAndRelatedShipTo() {
		User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
		Contact currentContact = [Select Id, AccountId from contact where id = :thisUser.ContactId];
		Account acc = [SELECT Id, EC_Account_Number__c FROM Account WHERE EC_Account_Number__c = '322235'];
		EC_TestData.createOutageRecord();
		test.startTest();
		EC_ContactAccountInfo.alignSoldToAndRelatedShipTo(acc, currentContact);
		EC_ContactAccountInfo.outageRedirect();
		test.stopTest();
	}

	/***************************************************************************************************************************************
	 Method Name : pestDivisionCheck()
	 Description : this method is to fetch Pest Division Check
	 Return type :
	 *************************************************************************************************************************************/
	@isTest
	public static void pestDivisionCheck() {
		User thisUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser'];
        
        System.runAs(thisUser) {
		test.startTest();
		Boolean result = EC_ContactAccountInfo.isPestDivision();
		system.assertEquals(result, false);
		test.stopTest();
        }
	}

	
}