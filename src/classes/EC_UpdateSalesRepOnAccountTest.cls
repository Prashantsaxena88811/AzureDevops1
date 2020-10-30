/* Class Name      :EC_UpdateSalesRepOnAccountTest
 * Description      :Test Class for EC_UpdateSalesRepOnAccountTest
 * Created By       :Mishika Mahajan
 * Created On       :09-23-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Mishika Mahajan          09-23-2019                                    Test Class for EC_UpdateSalesRepOnAccountTest
 *
 */

@isTest
public class EC_UpdateSalesRepOnAccountTest {
	/***************************************************************************************************************************************
	 Method Name : updateSalesRepOnUserInactiveTest
	 Description : Test Method for updateSalesRepOnUserInactive
	 Return type : void
	 Author      : Mishika Mahajan
	 *************************************************************************************************************************************/

	@isTest
	public static void updateSalesRepOnUserInactiveTest() {
		List<User> usrList = new List<User>();
		UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
		User portalUser = new User(UserRoleId = portalRole.Id,
								   ProfileId = profile1.Id,
								   Username = System.now().millisecond() + 'test2@test.com',
								   Alias = 'batman',
								   Email= 'bruce.wayne@wayneenterprises.com',
								   EmailEncodingKey= 'UTF-8',
								   Firstname= 'Bruce',
								   Lastname= 'Wayne',
								   LanguageLocaleKey= 'en_US',
								   LocaleSidKey= 'en_US',
								   TimeZoneSidKey= 'America/Chicago');

		usrList.add(portalUser);

		Profile salesRepProfile = [Select Id from Profile where name = 'Sales Rep'];
		User salesRepUser1 = new User(UserRoleId = portalRole.Id,
										   ProfileId = salesRepProfile.Id,
										   Username = System.now().millisecond() + 'test334@test.com',
										   Alias = 'bunman',
										   Email= 'bruce.wayee23@wayneenterprises.com',
										   EmailEncodingKey= 'UTF-8',
										   Firstname= 'Bruceee',
										   Lastname= 'Waneyy',
										   LanguageLocaleKey= 'en_US',
										   LocaleSidKey= 'en_US',
										   TimeZoneSidKey= 'America/Chicago',
										   EC_CDM_User_Status__c = true);
		usrList.add(salesRepUser1);

		User salesRepUser = new User(UserRoleId = portalRole.Id,
								     ProfileId = salesRepProfile.Id,
								     Username = System.now().millisecond() + 'test3@test.com',
								     Alias = 'bruman',
								     Email= 'bruce.way@wayneenterprises.com',
								     EmailEncodingKey= 'UTF-8',
								     Firstname= 'Bruc',
								     Lastname= 'Wane',
								     LanguageLocaleKey= 'en_US',
								     LocaleSidKey= 'en_US',
								     TimeZoneSidKey= 'America/Chicago',
								     EC_CDM_User_Status__c = true,
								     IsActive= true);
		usrList.add(salesRepUser);
		insert usrList;
		System.runAs(portalUser) {
			Account portalAccount1 = new Account(Name = 'DummyAccountKey',
											     EC_CDM_Account__c = 'DummyAccountKey',
											     OwnerId = portalUser.Id);
			Database.insert(portalAccount1);
			List<RecordType> lstRecordType = [SELECT id, DeveloperName from RecordType where Name = :Label.EC_Account_Corporate];
			Account testAccount = new Account();
			testAccount.EC_Account_Number__c = 'CORP_2';
			testAccount.Name = 'TestCoporateAccount';
			testAccount.RecordTypeId = lstRecordType [0].Id;
			Insert testAccount;



			List<RecordType> lstRecordTypeSoldTO = [SELECT id, DeveloperName from RecordType where Name = :Label.EC_Account_SoldTo];

			Account testSoldto = new Account();
			testSoldto.Name = 'TESTSOLD TO';
			testSoldto.EC_Account_Number__c = '15081947';
			testSoldto.RecordTypeId = lstRecordTypeSoldTO [0].Id;
			testSoldto.EC_SalesRepresentative__c = salesRepUser1.id;
			Insert testSoldto;

			Account testSoldParent = new Account();
			testSoldParent.Name = 'TESTSOldParent';
			testSoldParent.EC_Account_Number__c = '15081950';
			testSoldParent.EC_CDM_Account__c = '15081950';
			testSoldParent.RecordTypeId = lstRecordTypeSoldTO [0].Id;
			Insert testSoldParent;

			Account testAcc = new Account();
			testAcc.Name = 'TESTSOLD TO456';
			testAcc.EC_Account_Number__c = '15089978';
			testAcc.RecordTypeId = lstRecordTypeSoldTO [0].Id;
			testAcc.EC_SalesRepresentative__c = salesRepUser1.id;
			Insert testAcc;

			Contact cntct = new Contact();
			cntct.LastName = 'testLasthere';
			cntct.AccountId = testSoldParent.Id;
			cntct.EC_CDM_Contact__c = '15081950';
			cntct.EC_SalesRep_User__c = salesRepUser.id;
			cntct.EC_isActive__c = true;
			cntct.EC_User_Type__c = 'Employee';
			Insert cntct;
			Contact cntct1 = new Contact();
			cntct1.LastName = 'testLast';
			cntct1.AccountId = testSoldto.Id;
			cntct1.EC_CDM_Contact__c = '789078';
			cntct1.EC_SalesRep_User__c = salesRepUser1.id;
			cntct1.EC_isActive__c = false;
			cntct1.EC_User_Type__c = 'Employee';
			Insert cntct1;

			AccountContactRelation accConRel = new AccountContactRelation(accountId = testSoldto.id, ContactId = cntct.id);

			insert accConRel;
			List<Id> userIdList = new List<Id>();
			userIdList.add(salesRepUser1.id);
			EC_UpdateSalesRepOnAccount.updateSalesRepOnUserInactive(userIdList);
		}

	}
}