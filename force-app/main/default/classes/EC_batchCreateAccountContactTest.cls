//EC_batchCreateAccountContactTest
//This class is to test batchCreateAccountContact
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Harsha N    27th June, 2019     Initial version
//
@isTest(SeeAllData = false)public class EC_batchCreateAccountContactTest {
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
											     Phone                   = '8976453786',
											     EC_Division__c          = 'WATER',
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
											     Phone                   = '8976453786',
											     recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId(),
											     ShippingStreet          = EC_TestData.generateRandomString(32),
											     ShippingCity            = EC_TestData.generateRandomString(32),
											     ShippingState           = EC_TestData.generateRandomString(32),
											     ShippingCountry         = EC_TestData.generateRandomString(32),
											     ShippingPostalCode      = EC_TestData.generateRandomString(5));
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

			Contact contRec = new Contact(LastName = 'TestContact',
									      FirstName               = 'TestContact',
									      EC_CDM_Contact__c       = '2131415',
									      accountId               = mapAcc.get('sold').id);

			insert contRec;

			List<AccountContactRelation> lstAccContRec = new List<AccountContactRelation>();
			AccountContactRelation accContRec2 = new AccountContactRelation(AccountId = mapAcc.get('ship3').id, ContactId = contRec.id);

			lstAccContRec.add(accContRec2);

			insert lstAccContRec;
		}
	}
	/***************************************************************************************************************************************
	 Method Name : setupMuleSoftIntegration()
	 Description : to setup Custom Setting
	 Return type :
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void testCreateAccCont() {
		User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

		system.runas(thisUser) {
			Test.startTest();
			batchCreateAccountContact obj = new batchCreateAccountContact();
			DataBase.executeBatch(obj);

			Test.stopTest();
		}

	}
}