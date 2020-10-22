/* Class Name       :EC_PunchInServiceTest
 * Description      : Test class for Web Service API for Punchout Service
 * Created By       :Raghav Sharma
 * Created On       :06-10-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Raghav Sharma        06-10-2019                                  Test Class for Web Service API for Punchout Service
 */
@isTest(SeeAllData = false) public class EC_PunchInServiceTest {

	public static final String UKEY = 'hJoVwNEqzy/QDXSmXEfbeQCMmV+gioWYPRdkZ4enNUpRMh+qYdxJN0vCsVbCRMt8';
	public static final String PKEY = 'v8lROzzVzkL4q12Ew+ZJUKVxmMW0L5Hw8Fv2HSBg6cQ=';
	public static final String SHIPTO = '805269693';
	public static final String SHAREDSECRET = 'Winter16';
	public static final String CALLBACKURL = 'https://www.ibuyefficient.com/Buyer/Catalog/PunchoutWait?catalogID=4614266667';
	public static final String BUYERCOOKIE = '4614268931461426666720191015023245';
	public static final String FROMDOMAIN = 'NetworkId';
	public static final String FROMIDENTITY = '106681320132430eb38a99318dce8f68';
	public static final String SENDERDOMAIN = 'buyefficient.com';
	public static final String SENDERIDENTITY = '106681320132430eb38a99318dce8f68';
	public static final String TODOMAIN = 'buyefficient.com';
	public static final String TOIDENTITY = '805269693';
	public static final String SENDERUSERAGENT = 'Ariba ORMS 5.1P4';
	public static final String XMLLANGUAGE = 'Yes';
	public static final String PAYLOADID = 'Yes';
	public static final String VERSION = 'Yes';

	/***************************************************************************************************************************************
	 Method Name : setup
	 Description : to set up test data
	 Parameter   : NA
	 Return type : void
	 Author      : Raghav Sharma
	 *************************************************************************************************************************************/


	@testSetup static void setup() {
		Account testAccountComm = new Account(Name = 'ACCOUNT_NAME',
										      OwnerId                 = UserInfo.getUserId(),
										      Type                    = 'Customer',
										      EC_Division__c          = 'WATER',
										      EC_Account_Number__c    = '805269693');
		insert testAccountComm;

		List<User> userList = new List<User>();
		List<Contact> conList = new List<Contact>();
		Contact contactCC = new Contact(FirstName = 'Community',
									    LastName  = 'TestUserCom' + '1',
									    Email = 'abc@xydfz.com',
									    AccountId = testAccountComm.Id,
									    MailingStreet = 'abc');
		conList.add(contactCC);
		insert conList;
		User testOwner = [SELECT TimeZoneSidKey, UserRoleId
					      FROM User
					      WHERE Id = :UserInfo.getUserId()];

		system.runAs(testOwner) {
			UserRole role = new UserRole(DeveloperName = 'TestUser1', Name = 'TestRole');
			insert role;

			Profile profile = [SELECT Id
							   FROM Profile
							   WHERE Name = 'Ecolab Customer Community Plus Users' LIMIT 1];


			String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
			User testUser = new User(Alias = 'cctest',
								     Email                    = emailAddress,
								     EmailEncodingKey         = 'UTF-8',
								     LastName                 = 'TestUser',
								     LanguageLocaleKey        = 'en_US',
								     LocaleSidKey             = 'en_US',
								     ProfileId                = profile.Id,
								     TimeZoneSidKey           = testOwner.TimeZoneSidKey,
								     Username                 = emailAddress,
								     isActive                 = true,
								     ContactId                = conList [0].Id,
								     Contact                  = conList [0],
								     UserRole                 = role);

			userList.add(testUser);
			insert userList;


		}

		upsert new EC_PunchoutSecretKey__c(Name = 'Winter16',
										   EC_Secret_Key__c = 'Winter16',
										   EC_EncryptionKey__c = 'FVffiJmMRR0yOJ2Iw1CFf8trSmJdFtcaQtAhdEsgzbs=');
        upsert new EC_LogsEnabler__c(Name = 'PunchInService',
										   EC_LogsEnabled__c = false
										   );
        upsert new EC_LogsEnabler__c(Name = 'PunchInService',
										   EC_LogsEnabled__c = true
										   );

	}


	/***************************************************************************************************************************************
	 Method Name : createCallBackUrlTest
	 Description : Create CallBack URL
	 Parameter   : NA
	 Return type : void
	 Author      : Raghav Sharma
	 *************************************************************************************************************************************/

	@isTest
	public static void createCallBackUrlTest() {
		EC_TestData.setupTestUser();
		User thisUser = [SELECT Username, Id, EC_CDM_User__c, contactId FROM User WHERE LastName = 'TestUser' limit 1];
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Punchout'; //Request URL
		req.httpMethod = 'POST'; //HTTP Request Type
		req.requestBody = Blob.valueof('{\"ukey\":\"hJoVwNEqzy/QDXSmXEfbeQCMmV+gioWYPRdkZ4enNUpRMh+qYdxJN0vCsVbCRMt8\", \"pkey\":\"v8lROzzVzkL4q12Ew+ZJUKVxmMW0L5Hw8Fv2HSBg6cQ=\", \"shipTo\":\"805269693\", \"sharedSecret\":\"Winter16\" , \"callBackURL\":\"https://www.ibuyefficient.com/Buyer/Catalog/PunchoutWait?catalogID=4614266667\", \"BuyerCookie\":\"4614268931461426666720191015023245\", \"fromDomain\":\"NetworkId\", \"fromIdentity\":\"106681320132430eb38a99318dce8f68\", \"senderDomain\":\"buyefficient.com\", \"senderIdentity\":\"106681320132430eb38a99318dce8f68\", \"toDomain\":\"buyefficient.com\", \"toIdentity\":\"805269693\", \"senderUserAgent\":\"Ariba ORMS 5.1P4\", \"xmlLanguage\":\"Yes\", \"payloadId\":\"Yes\" ,\"Version\":\"Yes\" }');
									   RestContext.request = req;
									   RestContext.response = res;
									   System.runAs(thisUser) {
									   Test.setMock(HttpCalloutMock.class, new EC_MockHttpResponseGeneratorPunchin());
									   test.startTest();
									   EC_PunchInService.createCallBackURL(UKEY, PKEY, SHIPTO, 'Winter16', CALLBACKURL, BUYERCOOKIE, FROMDOMAIN, FROMIDENTITY, SENDERDOMAIN, SENDERIDENTITY,
									   TODOMAIN, TOIDENTITY, SENDERUSERAGENT, XMLLANGUAGE, PAYLOADID, VERSION);


									   }

									   }

 /***************************************************************************************************************************************
 Method Name : createCallBackUrlTestincorrectSecretKey
 Description : Negative Test Case  CallBack URL
   Parameter   : NA
   Return type : void
   Author      : Raghav Sharma
   *************************************************************************************************************************************/

   @isTest
   public static void createCallBackUrlTestincorrectSecretKey() {
   EC_TestData.setupTestUser();
   RestRequest req = new RestRequest();
   RestResponse res = new RestResponse();
   User thisUser = [SELECT Username,Id,EC_CDM_User__c, contactId FROM User WHERE LastName = 'TestUser' limit 1];
   req.requestURI = '/services/apexrest/Punchout'; //Request URL
   req.httpMethod = 'POST'; //HTTP Request Type
   req.requestBody = Blob.valueof('{\"ukey\":\"skapuuser234@yopmail.com\", \"pkey\":\"deloitte2\", \"shipTo\":\"805269693\", \"sharedSecret\":\"Winter16\" , \"callBackURL\":\"https://www.ibuyefficient.com/Buyer/Catalog/PunchoutWait?catalogID=4614266667\", \"BuyerCookie\":\"4614268931461426666720191015023245\", \"fromDomain\":\"NetworkId\", \"fromIdentity\":\"106681320132430eb38a99318dce8f68\", \"senderDomain\":\"buyefficient.com\", \"senderIdentity\":\"106681320132430eb38a99318dce8f68\", \"toDomain\":\"buyefficient.com\", \"toIdentity\":\"805269693\", \"senderUserAgent\":\"Ariba ORMS 5.1P4\", \"xmlLanguage\":\"Yes\", \"payloadId\":\"Yes\" ,\"Version\":\"Yes\" }');
   RestContext.request = req;
   RestContext.response = res;
   System.runAs(thisUser) {
   Test.setMock(HttpCalloutMock.class, new EC_MockHttpResponseGeneratorPunchin());
   test.startTest();
   EC_PunchInService.createCallBackURL(UKEY, PKEY, SHIPTO, 'Winter17', CALLBACKURL, BUYERCOOKIE, FROMDOMAIN, FROMIDENTITY, SENDERDOMAIN, SENDERIDENTITY,
   TODOMAIN, TOIDENTITY, SENDERUSERAGENT, XMLLANGUAGE, PAYLOADID, VERSION);
   }
   test.stopTest();
   }
   /***************************************************************************************************************************************
   Method Name : createCallBackUrlTestIncorrectUser
   Description : Nageative Test Case - Create CallBack URL
   Parameter   : NA
   Return type : void
   Author      : Raghav Sharma
   *************************************************************************************************************************************/
   @isTest
   public static void createCallBackUrlTestIncorrectUser() {
   EC_TestData.setupTestUser();
   User thisUser = [SELECT Username, Id, EC_CDM_User__c, contactId FROM User WHERE LastName = 'TestUser' limit 1];
   RestRequest req = new RestRequest();
   RestResponse res = new RestResponse();
   req.requestURI = '/services/apexrest/Punchout'; //Request URL
   req.httpMethod = 'POST'; //HTTP Request Type
   req.requestBody = Blob.valueof('{\"ukey\":\"skapuuser234@yopmail.com\", \"pkey\":\"deloitte2\", \"shipTo\":\"805269693\", \"sharedSecret\":\"Winter16\" , \"callBackURL\":\"https://www.ibuyefficient.com/Buyer/Catalog/PunchoutWait?catalogID=4614266667\", \"BuyerCookie\":\"4614268931461426666720191015023245\", \"fromDomain\":\"NetworkId\", \"fromIdentity\":\"106681320132430eb38a99318dce8f68\", \"senderDomain\":\"buyefficient.com\", \"senderIdentity\":\"106681320132430eb38a99318dce8f68\", \"toDomain\":\"buyefficient.com\", \"toIdentity\":\"805269693\", \"senderUserAgent\":\"Ariba ORMS 5.1P4\", \"xmlLanguage\":\"Yes\", \"payloadId\":\"Yes\" ,\"Version\":\"Yes\" }');
   RestContext.request = req;
   RestContext.response = res;
   System.runAs(thisUser) {
   Test.setMock(HttpCalloutMock.class, new EC_MockHttpResponseGeneratorPunchin());
   test.startTest();
   EC_PunchInService.createCallBackURL('UKEY', PKEY, SHIPTO, 'Winter16', CALLBACKURL, BUYERCOOKIE, FROMDOMAIN, FROMIDENTITY, SENDERDOMAIN, SENDERIDENTITY,
   TODOMAIN, TOIDENTITY, SENDERUSERAGENT, XMLLANGUAGE, PAYLOADID, VERSION);
   }
   test.stopTest();
   }
   /***************************************************************************************************************************************
   Method Name : createCallBackUrlTestInvalidAccount
   Description : Negative Test Case  CallBack URL
   Parameter   : NA
   Return type : void
   Author      : Raghav Sharma
   *************************************************************************************************************************************/
   @isTest
   public static void createCallBackUrlTestInvalidAccount() {
   EC_TestData.setupTestUser();
   User thisUser = [SELECT Username, Id, EC_CDM_User__c, contactId FROM User WHERE LastName = 'TestUser' limit 1];
   RestRequest req = new RestRequest();
   RestResponse res = new RestResponse();
   req.requestURI = '/services/apexrest/Punchout'; //Request URL
   req.httpMethod = 'POST'; //HTTP Request Type
   req.requestBody = Blob.valueof('{\"ukey\":\"skapuuser234@yopmail.com\", \"pkey\":\"deloitte2\", \"shipTo\":\"805269693\", \"sharedSecret\":\"Winter16\" , \"callBackURL\":\"https://www.ibuyefficient.com/Buyer/Catalog/PunchoutWait?catalogID=4614266667\", \"BuyerCookie\":\"4614268931461426666720191015023245\", \"fromDomain\":\"NetworkId\", \"fromIdentity\":\"106681320132430eb38a99318dce8f68\", \"senderDomain\":\"buyefficient.com\", \"senderIdentity\":\"106681320132430eb38a99318dce8f68\", \"toDomain\":\"buyefficient.com\", \"toIdentity\":\"805269693\", \"senderUserAgent\":\"Ariba ORMS 5.1P4\", \"xmlLanguage\":\"Yes\", \"payloadId\":\"Yes\" ,\"Version\":\"Yes\" }');
   RestContext.request = req;
   RestContext.response = res;
   System.runAs(thisUser) {
   Test.setMock(HttpCalloutMock.class, new EC_MockHttpResponseGeneratorPunchin());
   test.startTest();
   EC_PunchInService.createCallBackURL(UKEY, PKEY, 'SHIPTO', 'Winter16', CALLBACKURL, BUYERCOOKIE, FROMDOMAIN, FROMIDENTITY, SENDERDOMAIN, SENDERIDENTITY,
   TODOMAIN, TOIDENTITY, SENDERUSERAGENT, XMLLANGUAGE, PAYLOADID, VERSION);
   }
   test.stopTest();
   }
}