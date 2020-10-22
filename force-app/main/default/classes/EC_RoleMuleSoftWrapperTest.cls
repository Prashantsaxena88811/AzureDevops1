/*******************************************************************************************************************
 * Apex Class Name     : EC_RoleMuleSoftWrapperTest
 * Created Date        : 08 Aug 2019
 * Description         : Test Class For EC_RegMuleSoftWrapper
 * Developer                        Date                   Description
 * -----------------------------------------------------------------------------------------------------------------
 * Shruti Sinha                 24/07/2019              Original Version
 *************************************************************************************************************************/
@isTest
public class EC_RoleMuleSoftWrapperTest {
	@isTest

	/***************************************************************************************************************************************
	 Method Name : setUpdata
	 Description : to test the method
	 Parameter   : String
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
	public static void setUpdata() {


		List<String> roleToAdd = new List<String>{ 'Buyer', 'Buyer+' };
		String sourceSystemCode = '12345';
		Integer userKey = 1234;
		List<String> roleToRemove = new List<String>{ 'Buyer' };
		test.startTest();
		EC_RoleMuleSoftWrapper obj = new EC_RoleMuleSoftWrapper(roleToAdd, roleToRemove, userKey, sourceSystemCode);


		test.stopTest();


	}
}