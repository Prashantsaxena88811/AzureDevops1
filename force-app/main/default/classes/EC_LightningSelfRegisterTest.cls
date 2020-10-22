/*******************************************************************************************************************
 * Apex Class Name     : EC_LighteningSelfRegisterControllerTest
 * Created Date        : 7th Aug 2019
 * Description         : Class to cover EC_LightningSelfRegisterController
 * Developer                        Date                   Description
 * -----------------------------------------------------------------------------------------------------------------
 * Shruti Sinha                 08/07/2019              Original Version
 *************************************************************************************************************************/

@isTest
public class EC_LightningSelfRegisterTest {

    /***************************************************************************************************************************************
	 Method Name : setup
	 Description : to set up test data
	 Parameter   : NA
	 Return type : void
	 Author      : Raghav Sharma
	 *************************************************************************************************************************************/


	@testSetup static void setup() {
    upsert new EC_LogsEnabler__c(Name = 'Registration',
										   EC_LogsEnabled__c = false
												);
		upsert new EC_LogsEnabler__c(Name = 'Registration',
												EC_LogsEnabled__c = true
												);
		upsert new EC_LogsEnabler__c(Name = 'CaseCreationController',
											EC_LogsEnabled__c = true
											);
    }
	/*******************************************************************************************************************
	 * Method     : EC_LighteningSelfRegisterControllerTest
	 *Parameter   : null
	 * ReturnType : void
	 *Author      :Shruti Sinha
	 *************************************************************************************************************************/

	@isTest public static void setupDataTest() {
		EC_LightningSelfRegisterController.getProfile();
		EC_TestData.setupTestUser();
		User usr = [Select Id, FirstName, LastName, ContactId, Contact.Email, Contact.AccountId, Contact.Account.EC_Account_Number__c FROM User WHERE LastName = 'TestUser'];
		System.runAs(usr) {
			String EC_Account_Number = usr.Contact.Account.EC_Account_Number__c;
			EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
			csobj.EC_ClientId__c = '12345678';
			csobj.EC_Client_Secret__c = '11114563';
			csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
			csobj.Name = 'USERREGISTRATION';
			insert csobj;
			String startUrl = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
			Map<String, String> registrationDetails = new Map<String, String>();
			registrationDetails.put('FirstName', usr.FirstName);
			registrationDetails.put('LastName', usr.LastName);
			registrationDetails.put('AccountNumber', EC_Account_Number);
			registrationDetails.put('Email', usr.Contact.Email);
			registrationDetails.put('SalesRepEmail', 'abc@salesrep.com');
			String accountNo = EC_Account_Number;
			String salesRepEmail = 'abc@gmail.com';
			String userkey = '12345';
			//EC_RegMuleSoftWrapper wrapperObj = new EC_RegMuleSoftWrapper(accountNo,salesRepEmail,userkey);
			String url = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new EC_RegistrationCalloutMock());
			EC_LightningSelfRegisterController.formRegAPIJson(registrationDetails);
			EC_LightningSelfRegisterController.redirectLogin('URL');
			Test.stopTest();


		}
	}

	/*******************************************************************************************************************
	 * Method     : setupDataTestTwo
	 *Parameter   : null
	 * ReturnType : void
	 *Author      :Shruti Sinha
	 *************************************************************************************************************************/

	@isTest
	public static void setupDataTestTwo() {

		EC_TestData.setupTestUser();
        EC_TestData.setupCommunityUser();
		EC_TestData.createEC_PermissionSetMapping();
		User userAdmin = [Select Id, FirstName, LastName, ContactId, Contact.Email, Username, Contact.AccountId, Contact.Account.EC_Account_Number__c FROM User WHERE LastName = 'Waye'];
		System.runAs(userAdmin) {
            User usr = [Select Id, FirstName, LastName, ContactId, Contact.Email, Username, Contact.AccountId, Contact.Account.EC_Account_Number__c FROM User WHERE Contact.AccountId !=null Limit 1];
			Account soldToAccount = new Account(Name = 'SoldTo_Acc',
											    OwnerId                 = UserInfo.getUserId(),
											    Type                    = 'Customer',
											    EC_Status__c            = 'Active',
											    EC_Account_Number__c    = '322235',
											    EC_CDM_Account__c       = '1234',
											    EC_SalesRepresentative__c = UserInfo.getUserId(),
											    recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To').getRecordTypeId());
			insert soldToAccount;
			//Account shipTo = EC_TestData.testAccountShipTo;
			Account testAccountShipTo = new Account(Name = EC_TestData.ACCOUNT_NAME + ' SHIP TO',
												    ccrz__E_AccountGroup__c = EC_TestData.testAccountGroup.Id,
												    OwnerId                 = UserInfo.getUserId(),
												    Type                    = 'Customer',
												    ShippingStreet           = EC_TestData.generateRandomString(32),
												    ShippingCity             = EC_TestData.generateRandomString(32),
												    ShippingPostalCode      = EC_TestData.generateRandomString(5),
												    ShippingCountry         = 'USA',
												    ShippingState           = EC_TestData.generateRandomString(5),
												    RecordTypeId            = EC_TestData.getRecordType('shipTo'), //Ship To
												    BillingStreet           = EC_TestData.generateRandomString(32),
												    BillingCity             = EC_TestData.generateRandomString(32),
												    BillingState            = EC_TestData.generateRandomString(32),
												    BillingCountry          = 'USA',
												    BillingPostalCode       = EC_TestData.generateRandomString(5),
												    EC_Account_Number__c    = EC_TestData.generateRandomString(5),
												    ParentId                = soldToAccount.Id);
			insert testAccountShipTo;
			List<Contact> conList = new List<Contact>();
			for(integer i = 0; i < 4; i ++) {
				Contact contactCC = new Contact(FirstName = 'Community',
									    LastName  = 'TestUserCom' + i,
									    Email = 'abc@xydfz.com',
									    AccountId = testAccountShipTo.Id,
									    MailingStreet = 'abc');
				conList.add(contactCC);
			}

			insert conList;
			AccountContactRelation accr = new AccountContactRelation(AccountId =usr.Contact.AccountId,
																				contactId = conList[1].Id,
																				Alignment_Type__c= EC_Constants.PRIMARY_ALIGNMENT_TYPE );
			insert accr;
			String EC_Account_Number = soldToAccount.EC_Account_Number__c;
			EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
			csobj.EC_ClientId__c = '12345678';
			csobj.EC_Client_Secret__c = '11114563';
			csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
			csobj.Name = 'USERREGISTRATION';
			insert csobj;
			String startUrl = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
			Map<String, String> registrationDetails = new Map<String, String>();
			registrationDetails.put('FirstName', usr.FirstName);
			registrationDetails.put('LastName', usr.LastName);
			registrationDetails.put('AccountNumber', EC_Account_Number);
			registrationDetails.put('Email', usr.Contact.Email);
			registrationDetails.put('SalesRepEmail', 'abc@salesrep.com');
			String accountNo = EC_Account_Number;
			String salesRepEmail = 'abc@gmail.com';
			String userkey = '12345';
			EC_RegMuleSoftWrapper wrapperObj = new EC_RegMuleSoftWrapper(accountNo, salesRepEmail, userkey);
			String url = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';

			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new EC_RegistrationValidationMock());
			EC_LightningSelfRegisterController.validateRegistration(registrationDetails, url);
			EC_LightningSelfRegisterController.createCases(usr);
			EC_TestData.createOutageRecord();
			Boolean outageFlag = EC_LightningSelfRegisterController.outageRedirect();
			System.assert(outageFlag);
			Test.stopTest();
		}
	}
	/*******************************************************************************************************************
	 * Method     : setupDataTestTwoFailure
	 *Parameter   : null
	 * ReturnType : void
	 *Author      :Shruti Sinha
	 *************************************************************************************************************************/

	@isTest
	public static void setupDataTestTwoFailure() {

		EC_TestData.setupTestUser();
		EC_TestData.createEC_PermissionSetMapping();
		User usr = [Select Id, FirstName, LastName, ContactId, Contact.Email, Username, Contact.AccountId, Contact.Account.EC_Account_Number__c FROM User WHERE LastName = 'TestUser'];
		System.runAs(usr) {
			Account soldToAccount = new Account(Name = 'SoldTo_Acc',
											    OwnerId                 = UserInfo.getUserId(),
											    Type                    = 'Customer',
											    EC_Status__c            = 'Active',
											    EC_Account_Number__c    = '322235',
											    EC_SalesRepresentative__c = UserInfo.getUserId(),
											    recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To').getRecordTypeId());
			insert soldToAccount;
			//Account shipTo = EC_TestData.testAccountShipTo;
			Account testAccountShipTo = new Account(Name = EC_TestData.ACCOUNT_NAME + ' SHIP TO',
										      ccrz__E_AccountGroup__c = EC_TestData.testAccountGroup.Id,
										      OwnerId                 = UserInfo.getUserId(),
										      Type                    = 'Customer',
										      ShippingStreet           = EC_TestData.generateRandomString(32),
										      ShippingCity             = EC_TestData.generateRandomString(32),
										      ShippingPostalCode      = EC_TestData.generateRandomString(5),
										      ShippingCountry         = 'USA',
										      ShippingState           = EC_TestData.generateRandomString(5),
										      RecordTypeId            = EC_TestData.getRecordType('shipTo'), //Ship To
										      BillingStreet           = EC_TestData.generateRandomString(32),
										      BillingCity             = EC_TestData.generateRandomString(32),
										      BillingState            = EC_TestData.generateRandomString(32),
										      BillingCountry          = 'USA',
										      BillingPostalCode       = EC_TestData.generateRandomString(5),
										      EC_Account_Number__c    = EC_TestData.generateRandomString(5),
										      ParentId                = soldToAccount.Id);
			insert testAccountShipTo;
			List<Contact> conList = new List<Contact>();
			for(integer i = 0; i < 4; i ++) {
				Contact contactCC = new Contact(FirstName = 'Community',
									    LastName  = 'TestUserCom' + i,
									    Email = 'abc@xydfz.com',
									    AccountId = testAccountShipTo.Id,
									    MailingStreet = 'abc');
				conList.add(contactCC);
			}

			insert conList;
			String EC_Account_Number = usr.Contact.Account.EC_Account_Number__c;
			EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
			csobj.EC_ClientId__c = '12345678';
			csobj.EC_Client_Secret__c = '11114563';
			csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
			csobj.Name = 'USERREGISTRATION';
			insert csobj;
			String startUrl = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
			Map<String, String> registrationDetails = new Map<String, String>();
			registrationDetails.put('FirstName', usr.FirstName);
			registrationDetails.put('LastName', usr.LastName);
			registrationDetails.put('AccountNumber', EC_Account_Number);
			registrationDetails.put('Email', usr.Contact.Email);
			registrationDetails.put('SalesRepEmail', 'abc@salesrep.com');
			String accountNo = EC_Account_Number;
			String salesRepEmail = 'abc@gmail.com';
			String userkey = '12345';
			EC_RegMuleSoftWrapper wrapperObj = new EC_RegMuleSoftWrapper(accountNo, salesRepEmail, userkey);
			String url = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';

			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new EC_RegistrationCalloutMockFailure());
			EC_LightningSelfRegisterController.validateRegistration(registrationDetails, url);

			EC_TestData.createOutageRecord();
			Boolean outageFlag = EC_LightningSelfRegisterController.outageRedirect();
			System.assert(outageFlag);
			Test.stopTest();
		}
	}
	/*******************************************************************************************************************
	 * Method     : setupDataTestRoleAssignmentToCDM
	 *Parameter   : null
	 * ReturnType : void
	 *Author      :Aqeeb Ahamed
	 *************************************************************************************************************************/

	@isTest
	public static void setupDataTestRoleAssignmentToCDM() {

		EC_TestData.setupTestUser();
		EC_TestData.setupCommunityUser();
		User usr = [Select Id, FirstName, LastName, ContactId, Contact.Email, Contact.AccountId, Contact.Account.EC_Account_Number__c FROM User WHERE EC_CDM_User__c != null and Contact.AccountId !=null Limit 1];
		EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
						csobj.EC_ClientId__c = '12345678';
						csobj.EC_Client_Secret__c = '11114563';
						csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
						csobj.Name = 'USERREGISTRATION';
		insert csobj;
		EC_Mulesoft_Integration__c csUsrRole=new EC_Mulesoft_Integration__c();
            csUsrRole.EC_ClientId__c='12345678';
            csUsrRole.EC_Client_Secret__c='11114563';
            csUsrRole.EC_Endpoint__c='https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/role-assignment';
            csUsrRole.Name=EC_Constants.USERROLE;
    insert csUsrRole;
		Account soldToAccount = new Account(Name = 'SoldTo_Acc',
												OwnerId                 = UserInfo.getUserId(),
												Type                    = 'Customer',
												EC_Status__c            = 'Active',
												EC_Account_Number__c    = '322235',
												EC_SalesRepresentative__c = UserInfo.getUserId(),
												recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To').getRecordTypeId());
		insert soldToAccount;
		Contact con = new Contact(FirstName = 'Community',
								LastName  = 'TestUserCom',
								Email = 'abcrep@xydfz.com',
								AccountId = soldToAccount.Id);
		insert con;
		AccountContactRelation accr = new AccountContactRelation(AccountId =usr.Contact.AccountId,
																				contactId = con.Id,
																				Alignment_Type__c= EC_Constants.PRIMARY_ALIGNMENT_TYPE );
		insert accr;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EC_RegistrationCalloutMock());
		EC_AssignRoleInCDM.roleAssignedCDM(EC_Constants.BUYER,EC_Constants.BASIC,usr.Id);
		System.assert(usr !=null);
		Test.stopTest();
	}

	/*******************************************************************************************************************
	 * Method     : setupDataTestRoleAssignmentToCDMFailure
	 *Parameter   : null
	 * ReturnType : void
	 *Author      :Aqeeb Ahamed
	 *************************************************************************************************************************/

	@isTest
	public static void setupDataTestRoleAssignmentToCDMFailure() {

		EC_TestData.setupTestUser();
		EC_TestData.setupCommunityUser();
		User usr = [Select Id, FirstName, LastName, ContactId, Contact.Email, Contact.AccountId, Contact.Account.EC_Account_Number__c FROM User WHERE EC_CDM_User__c != null and Contact.AccountId !=null Limit 1];
		EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
						csobj.EC_ClientId__c = '12345678';
						csobj.EC_Client_Secret__c = '11114563';
						csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
						csobj.Name = 'USERREGISTRATION';
		insert csobj;
		EC_Mulesoft_Integration__c csUsrRole=new EC_Mulesoft_Integration__c();
            csUsrRole.EC_ClientId__c='12345678';
            csUsrRole.EC_Client_Secret__c='11114563';
            csUsrRole.EC_Endpoint__c='https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/role-assignment';
            csUsrRole.Name=EC_Constants.USERROLE;
    insert csUsrRole;
		Account soldToAccount = new Account(Name = 'SoldTo_Acc',
												OwnerId                 = UserInfo.getUserId(),
												Type                    = 'Customer',
												EC_Status__c            = 'Active',
												EC_Account_Number__c    = '322235',
												EC_SalesRepresentative__c = UserInfo.getUserId(),
												recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To').getRecordTypeId());
		insert soldToAccount;
		Contact con = new Contact(FirstName = 'Community',
								LastName  = 'TestUserCom',
								Email = 'abcrep@xydfz.com',
								AccountId = soldToAccount.Id);
		insert con;
		AccountContactRelation accr = new AccountContactRelation(AccountId =usr.Contact.AccountId,
																				contactId = con.Id,
																				Alignment_Type__c= EC_Constants.PRIMARY_ALIGNMENT_TYPE );
		insert accr;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EC_RegistrationCalloutMockFailure());
		EC_AssignRoleInCDM cls = new EC_AssignRoleInCDM();
        system.debug('cls'+cls);
		EC_AssignRoleInCDM.roleAssignedCDM(EC_Constants.BUYER,EC_Constants.BASIC,usr.Id);
		System.assert(usr !=null);
		Test.stopTest();
	}
	/*******************************************************************************************************************
	 * Method     : setupDataTestFive
	 *Parameter   : null
	 * ReturnType : void
	 *Author      :Shruti Sinha
	 *************************************************************************************************************************/

	@isTest
	public static void setupDataTestFive() {

		EC_TestData.createEC_PermissionSetMapping();
		EC_TestData.setupTestUser();
		User usr = [Select Id, FirstName, LastName, ContactId, Contact.Email, Contact.AccountId, Contact.Account.EC_Account_Number__c FROM User WHERE LastName = 'TestUser'];
		System.runAs(usr) {
			Test.startTest();
			EC_LightningSelfRegisterController.assignPermissionSet(usr.Id);
			Test.stopTest();
		}
	}

	public class EC_RegistrationCalloutMockFailure implements HttpCalloutMock {

		public HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"responseCode":"1006","userKey":"123","federationId":"ExampleFederationId","redemptionUrl":"ExampleRedemptionUrl","accountNo":"23445667","salesRepEmail":"jamie@lannister.com","userEmail":"ecolabDev1@outlook.com","firstName":"John","lastName":"Snow","sourceSystemCode":"User"}');
			response.setStatusCode(201);
			return response;
		}
	}
}