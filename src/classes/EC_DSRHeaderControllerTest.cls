/* Class Name      :EC_DSRHeaderControllerTest
* Description      :Test class for EC_DSRHeaderController
* Created By       :Aqeeb Ahamed
* Created On       :11-08-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Aqeeb Ahamed        11-08-2020                                 Test class for EC_DSRHeaderController
*
*/
@isTest
public with sharing class EC_DSRHeaderControllerTest {

    /***************************************************************************************************************************************
	 Method Name : setup
	 Description : to set up test data
	 Parameter   : NA
	 Return type : void
	 Author      : Aqeeb Ahamed
	 *************************************************************************************************************************************/


	@testSetup static void setup() {
        upsert new EC_LogsEnabler__c(Name = 'DigitalServiceReport',
                                               EC_LogsEnabled__c = false
                                                    );
        upsert new EC_LogsEnabler__c(Name = 'DigitalServiceReport',
                                                    EC_LogsEnabled__c = true
                                                    );
        List<User> lstTestUsers = new List<User>();
        List<Account> lstAccounts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();

        Account testAccount1 = new Account(
            Name                    = 'Testaccount2',
            OwnerId                 = UserInfo.getUserId(),
            Type                    = 'Customer' ,
            EC_Division__c          = 'Water',
            EC_Account_Number__c    = '234005',
            ShippingStreet			= 'ShippingStreet',
            ShippingCity			= 'ShippingCity',
            ShippingState			= 'ShippingState',
            ShippingPostalCode		= 'ShippingPostalCode',
            ShippingCountry			= 'ShippingCountry',
			RecordTypeId            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId()
        );
        lstAccounts.add(testAccount1);
        Database.insert(lstAccounts);

        Contact contact1 = new Contact(FirstName = 'CommunityUser1',LastName  = 'TestUser124',Email = 'abcd@xyz.com',AccountId = testAccount1.Id,MailingStreet = 'abc');
        lstContacts.add(contact1);
        Database.insert(lstContacts);
        User testOwner = [SELECT TimeZoneSidKey, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(testOwner) {
            Profile profile = [SELECT Id
                                FROM Profile
                                WHERE Name = 'Ecolab Customer Community Plus Users' LIMIT 1];
            UserRole role = new UserRole(DeveloperName = 'TestUser5', Name = 'TestRole5');
            insert role;
            String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
            User testUser1 = new User(
                    Alias                    = 'sample1',
                    Email                    = emailAddress,
                    EmailEncodingKey         = 'UTF-8',
                    LastName                 = 'TestUserRequestsample1',
                    LanguageLocaleKey        = 'en_US',
                    LocaleSidKey             = 'en_US',
                    ProfileId                = profile.Id,
                    TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                    Username                 = emailAddress,
                    isActive                 = true,
                    ContactId                = contact1.Id,
                    Contact                  = contact1,
                    UserRole                 = role
                );
            lstTestUsers.add(testUser1);
            Database.insert(lstTestUsers);
        }
        EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
			csobj.EC_ClientId__c = '12345678';
			csobj.EC_Client_Secret__c = '11114563';
			csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/';
			csobj.Name = 'DigitalServiceReport';
        insert csobj;
    }

    /*******************************************************************************************************************
	 * Method     : getServiceDetailResponseWithDate
	 *Parameter   : null
	 * ReturnType : void
	 *Author      : Aqeeb Ahamed
	 *************************************************************************************************************************/

	@isTest
	public static void getServiceDetailResponseWithDate() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EC_DSRHeaderCalloutMock());
        String response1 = EC_DSRHeaderController.getDSRServiceDetails('Ac234555','2019-10-03T07:12:33');
        system.assert(response1.length()>0);
        Test.stopTest();
    }

/*******************************************************************************************************************
	 * Method     : getServiceDetailResponseWithoutDate
	 *Parameter   : null
	 * ReturnType : void
	 *Author      : Aqeeb Ahamed
	 *************************************************************************************************************************/

	@isTest
	public static void getServiceDetailResponseWithoutDate() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EC_DSRHeaderCalloutMock());
        String response2 = EC_DSRHeaderController.getDSRServiceDetails('Ac234555','');
        system.assert(response2.length()>0);
        try {
            String responseException = EC_DSRHeaderController.getDSRServiceDetails(null,null);
            system.debug('responseException ' +responseException);
        } catch (AuraHandledException urException) {
            system.debug('urException ' +urException);
        }
        Test.stopTest();
    }

    /*******************************************************************************************************************
	 * Method     : getContactAccountsTest
	 *Parameter   : null
	 * ReturnType : void
	 *Author      : Aqeeb Ahamed
	 *************************************************************************************************************************/

	@isTest
	public static void getContactAccountsTest() {

        Test.startTest();
        user u=[select id, name, contactId from user where lastname='TestUserRequestsample1' limit 1];
        system.runAs(u){
            Map<Id, List<EC_ServiceRequestHandler.AccountListWrapper>> accContacts = EC_DSRHeaderController.getContactAccounts('Testaccount1');
            system.debug('accContacts ' +accContacts);
            system.assert(accContacts != null);
        }
        try {
            Map<Id, List<EC_ServiceRequestHandler.AccountListWrapper>> accContactsException = EC_DSRHeaderController.getContactAccounts(null);
            system.debug('accContactsException ' +accContactsException);
        } catch (AuraHandledException urException) {
            system.debug('urException ' +urException);
        }
        Test.stopTest();
    }

    public class EC_DSRHeaderCalloutMock implements HttpCalloutMock {

		public HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody('{"service":{"employeeId": "20163971",  "employeeName": "Ayres, Tristan A"}}');
			response.setStatusCode(200);
			return response;
		}
	}
}