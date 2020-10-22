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

            Test.startTest();
            System.runAs(usr[2]){
                EC_Mulesoft_Integration__c csobj=new EC_Mulesoft_Integration__c();
                csobj.EC_ClientId__c='12345678';
                csobj.EC_Client_Secret__c='11114563';
                csobj.EC_Endpoint__c='______https://anypoint.mulesoft.com/mocking/api/v1/links/8fcf3b90-870d-4ba2-9cce-d86b3942c022/api/v1/user-registration';
                csobj.Name='USERREGISTRATION';
                insert csobj;
                EC_Mulesoft_Integration__c csUsrRole=new EC_Mulesoft_Integration__c();
                csUsrRole.EC_ClientId__c='12345678';
                csUsrRole.EC_Client_Secret__c='11114563';
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

}