/*******************************************************************************************************************
 * Apex Class Name     : EC_RegMuleSoftWrapperTest
 * Created Date        : 08 Aug 2019
 * Description         : Test Class For EC_RegMuleSoftWrapper
 * Developer                        Date                   Description
 * -----------------------------------------------------------------------------------------------------------------
 * Shruti Sinha                 24/07/2019              Original Version
 *************************************************************************************************************************/
@isTest
public class EC_RegMuleSoftWrapperTest {

	/***************************************************************************************************************************************
	 Method Name : testmethodOne
	 Description : to test the method
	 Parameter   : String
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
	@isTest
	public static void testmethodOne() {

		EC_TestData.setupTestUser();


		User usr = [Select Id, FirstName, LastName, ProfileId, ContactId, Contact.AccountId, Contact.Account.EC_Account_Number__c, Email from User where LastName = 'TestUser'];
		System.runas(usr) {
			String accountNo = usr.Contact.Account.EC_Account_Number__c;
			String salesRepEmail = usr.Email;
			String userEmail = 'abc@xyz.com';
			String firstName = usr.FirstName;
			String LastName = usr.LastName;
			String sourceSystemCode = '12344';
			String userKey = '1245';
			String federationId = 'usr@abc.com';
			String redemptionUrl = 'https://ecolabconnect--devec1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage';
			String isValid = 'TRUE';
			String responseCode = '200';
			String client_id = '123456';
			String client_secret = '1234555';
			test.StartTest();

			EC_RegMuleSoftWrapper obj = new EC_RegMuleSoftWrapper(accountNo, salesRepEmail, userEmail);
			obj.isValid = 'TRUE';

			test.stopTest();



		}
	}

	/***************************************************************************************************************************************
	 Method Name : testmethodtwo
	 Description : to test the method
	 Parameter   : String
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void testmethodtwo() {
		EC_TestData.setupTestUser();


		User usr = [Select Id, FirstName, LastName, ProfileId, ContactId, Contact.AccountId, Contact.Account.EC_Account_Number__c, Email from User where LastName = 'TestUser'];
		System.runas(usr) {
			String accountNo = usr.Contact.Account.EC_Account_Number__c;
			String salesRepEmail = usr.Email;
			String userEmail = 'abc@xyz.com';
			String firstName = usr.FirstName;
			String LastName = usr.LastName;
			String sourceSystemCode = '12344';
			String userKey = '1245';
			String federationId = 'usr@abc.com';
			String redemptionUrl = 'https://ecolabconnect--devec1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage';
			String isValid = 'TRUE';
			String responseCode = '200';
			String client_id = '123456';
			String client_secret = '1234555';
			test.StartTest();


			EC_RegMuleSoftWrapper objTwo = new EC_RegMuleSoftWrapper(accountNo, salesRepEmail, userEmail, firstName, LastName, sourceSystemCode);
			test.stopTest();


		}

	}

	/***************************************************************************************************************************************
	 Method Name : testmethodThree
	 Description : to test the method
	 Parameter   : String
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/

	@isTest
	public static void testmethodThree() {

		EC_TestData.setupTestUser();


		User usr = [Select Id, FirstName, LastName, ProfileId, ContactId, Contact.AccountId, Contact.Account.EC_Account_Number__c, Email from User where LastName = 'TestUser'];
		System.runas(usr) {
			String accountNo = usr.Contact.Account.EC_Account_Number__c;
			String salesRepEmail = usr.Email;
			String userEmail = 'abc@xyz.com';
			String firstName = usr.FirstName;
			String LastName = usr.LastName;
			String sourceSystemCode = '12344';
			String userKey = '1245';
			String federationId = 'usr@abc.com';
			String redemptionUrl = 'https://ecolabconnect--devec1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage';
			String isValid = 'TRUE';
			String responseCode = '200';
			String client_id = '123456';
			String client_secret = '1234555';
			test.StartTest();


			EC_RegMuleSoftWrapper objThree = new EC_RegMuleSoftWrapper(accountNo, salesRepEmail, userEmail, firstName, LastName, sourceSystemCode, userKey, federationId, redemptionUrl);
			test.stopTest();



		}
	}



}