/* Class Name       :EC_CaseCreationControllerTest
* Description      :test class for controller EC_CaseCreationController
* Created By       :Mishika Mahajan
* Created On       :07-05-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          07-05-2019                                   test class of EC_CaseCreationController class
* Mara Stephan             08-28-2020                                   moved two test methods here for CDM role
*                                                                       assignment from EC_LightningSelfRegisterTest
*
*/
@isTest
public class EC_CaseCreationControllerTest {

    /***************************************************************************************************************************************
Method Name : setup
Description : to set up test data
Parameter   : NA
Return type : void
Author      : Raghav Sharma
*************************************************************************************************************************************/


    @testSetup static void setup() {
        upsert new EC_LogsEnabler__c(Name = 'CaseCreationController',
                                     EC_LogsEnabled__c = false
                                    );
        upsert new EC_LogsEnabler__c(Name = 'CaseCreationController',
                                     EC_LogsEnabled__c = true
                                    );
    }
    /***************************************************************************************************************************************
Method Name : caseCreationTest
Description : test method for caseCreation method of controller EC_CaseCreationController
Return type : void
Author      : Mishika Mahajan
*************************************************************************************************************************************/


    @isTest
    private static void caseCreationTest(){

        EC_CaseCreationController.getProfile();
        List<User> usr = EC_TestData.setupCommunityUser();
        Boolean isPermMapCreated = false;
        System.runAs(usr[4]){
            PermissionSet ps =[Select id from PermissionSet where name ='EC_BasicSet'];
            PermissionSetAssignment psm = new PermissionSetAssignment(AssigneeId = usr[2].id,PermissionSetid = ps.id);
            PermissionSetAssignment psm1 = new PermissionSetAssignment(AssigneeId = usr[4].id,PermissionSetid = ps.id);
            insert psm;
            insert psm1;
        }
        System.runAS(usr[4]){
            Boolean payerpermission = EC_CaseCreationController.payerpermission();
            Boolean conditioncheckPayer = EC_CaseCreationController.conditioncheckPayer();
            Boolean Caseclosureafterpermissionsetassigned = EC_CaseCreationController.Caseclosureafterpermissionsetassigned();
            EC_CaseCreationController.caseCreationPayer();
            EC_TestData.createEC_PermissionSetMapping();
            EC_TestData.createOutageRecord();
            EC_Utility.getOutageFlag();
            EC_CaseCreationController.currentUserRole();
            EC_CaseCreationController.userRoles();

            if(!isPermMapCreated){
                isPermMapCreated = true;
                EC_CaseCreationController.currentUserRole();
            }
        }
        if(isPermMapCreated){

            EC_TestData.createPermissionSet(usr);
            EC_TestData.createEC_PermissionSetMapping();
            System.runAS(usr[4]){
                EC_CaseCreationController.currentUserRole();
                EC_CaseCreationController.userRoles();
            }

            String sampleClientId = '12345678';
            String sampleClientSecret = '11114563';

            Test.startTest();
            System.runAs(usr[2]){
                EC_Mulesoft_Integration__c csobj=new EC_Mulesoft_Integration__c();
                csobj.EC_ClientId__c=sampleClientId;
                csobj.EC_Client_Secret__c=sampleClientSecret;
                csobj.EC_Endpoint__c='______https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
                csobj.Name='USERREGISTRATION';
                insert csobj;
                EC_Mulesoft_Integration__c csUsrRole=new EC_Mulesoft_Integration__c();
                csUsrRole.EC_ClientId__c=sampleClientId;
                csUsrRole.EC_Client_Secret__c=sampleClientSecret;
                csUsrRole.EC_Endpoint__c='______https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
                csUsrRole.Name='userRole';
                insert csUsrRole;
                Test.setMock(HttpCalloutMock.class, new EC_RegistrationCalloutMock());

                String isCreated = EC_CaseCreationController.assigningPermissionSet('Buyer');
                Test.stopTest();
            }

            String isCaseCreated1 = EC_CaseCreationController.assigningPermissionSet('Basic');

            String isCaseCreated2 = EC_CaseCreationController.assigningPermissionSet('');
            EC_CaseCreationController.caseCreation('Buyer', 'Basic');

            Boolean outPut = EC_CaseCreationController.outageRedirect();

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
		User usr = getTestCDMUser();
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
		User usr = getTestCDMUser();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new EC_RegistrationCalloutMockFailure());
		EC_AssignRoleInCDM cls = new EC_AssignRoleInCDM();
        system.debug('cls'+cls);
		EC_AssignRoleInCDM.roleAssignedCDM(EC_Constants.BUYER,EC_Constants.BASIC,usr.Id);
		System.assert(usr !=null);
		Test.stopTest();
	}

    private static User getTestCDMUser() {
        String sampleClientId = '12345678';
        String sampleClientSecret = '11114563';
        EC_TestData.setupTestUser();
        EC_TestData.setupCommunityUser();
		User usr = [Select Id, FirstName, LastName, ContactId, Contact.Email, Contact.AccountId, Contact.Account.EC_Account_Number__c FROM User WHERE EC_CDM_User__c != null and Contact.AccountId !=null Limit 1];
		EC_Mulesoft_Integration__c csobj = new EC_Mulesoft_Integration__c();
						csobj.EC_ClientId__c = sampleClientId;
						csobj.EC_Client_Secret__c = sampleClientSecret;
						csobj.EC_Endpoint__c = 'https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
						csobj.Name = 'USERREGISTRATION';
		insert csobj;
		EC_Mulesoft_Integration__c csUsrRole=new EC_Mulesoft_Integration__c();
            csUsrRole.EC_ClientId__c=sampleClientId;
            csUsrRole.EC_Client_Secret__c=sampleClientSecret;
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
        
        return usr;
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