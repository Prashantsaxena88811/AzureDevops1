/* Class Name      :EC_AccAccessSalesRepHelperTest
 * Description      :Test class for EC_AccAccessSalesRepHelperTest
 * Created By       :Mishika Mahajan
 * Created On       :08-08-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Mishika Mahajan          08-08-2019                                   Test class for EC_AccAccessSalesRepHelperTest
 */

@isTest
public class EC_AccAccessSalesRepHelperTest {

	/***************************************************************************************************************************************
	 Method Name : EC_AccAccessSalesRepHelperSetUp
	 Description : test Class for EC_AccAccessSalesRepHelperSetUp
	 Return type : void
	 Author      : Mishika Mahajan
	 *************************************************************************************************************************************/

	@isTest
	public static void EC_AccAccessSalesRepHelperSetUp() {
		User testUser;
		User testOwner = [SELECT TimeZoneSidKey, UserRoleId
					      FROM User
					      WHERE Id = :UserInfo.getUserId()];
		system.runAs(testOwner) {
			UserRole role = new UserRole(DeveloperName = 'TestUser1', Name = 'TestRole1');
			insert role;

			Profile profile = [SELECT Id
							   FROM Profile
							   WHERE Name = 'Sales Rep' LIMIT 1];

			String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
			testUser = new User(Alias = 'cctest',
							    Email                    = emailAddress,
							    EmailEncodingKey         = 'UTF-8',
							    LastName                 = 'SalesRepUser',
							    LanguageLocaleKey        = 'en_US',
							    LocaleSidKey             = 'en_US',
							    ProfileId                = profile.Id,
							    TimeZoneSidKey           = testOwner.TimeZoneSidKey,
							    Username                 = emailAddress,
							    isActive                 = true,
							    User_Type__c             = 'Internal',
							    UserRole                 = role);
			insert testUser;
		}

		EC_TestData.setupCatalog();
		Account acc1 = EC_TestData.testAccount;
		Contact contactCC = new Contact(FirstName = 'CloudCraze',
									    LastName  = 'TestUser2',
									    Email = 'abc@xyz.com',
									    AccountId = acc1.Id,
									    MailingStreet = 'abc',
									    EC_SalesRep_User__c = testUser.id,
									    EC_User_Type__c = 'Employee');
		insert contactCC;
		AccountContactRelation accCon = new AccountContactRelation();
		accCon.AccountId = EC_TestData.testAccountSoldTo.id;
		accCon.ContactId = contactCC.id;
		insert accCon;


		delete accCon;

		User thisUser = [SELECT Id FROM User WHERE Profile.Name = 'Sales Rep' limit 1];
		EC_TestData.setupCatalog();
		Account acc2 = EC_TestData.testAccount;
		Contact contactCC1 = new Contact(FirstName = 'EcoUsertst',
									     LastName  = 'Tstusr',
									     Email = 'tset.eco@def.com',
									     AccountId = acc2.Id,
									     MailingStreet = 'mail',
									     EC_SalesRep_User__c = thisUser.id,
									     EC_User_Type__c = 'Employee');
		insert contactCC1;
		Id accId1 = EC_TestData.testAccountSoldTo.id;
		AccountContactRelation accCont = new AccountContactRelation();
		accCont.AccountId = accId1;
		accCont.ContactId = contactCC1.id;
		insert accCont;

	}
}