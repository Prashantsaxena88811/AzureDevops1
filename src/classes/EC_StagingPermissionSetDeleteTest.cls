@istest
public class EC_StagingPermissionSetDeleteTest {

    /***************************************************************************************************************************************
Method Name : createPermissionSetAssignment
Description : Used to test scenarios for DeletePermissionSet in Staging
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/
    @istest
    public static void createPermissionSetAssignment(){

        User testOwner = [SELECT TimeZoneSidKey, UserRoleId
                          FROM User
                          WHERE Id = :UserInfo.getUserId()];
        String user_cdmKey = '15102019';

        system.runAs(testOwner){
            UserRole role = new UserRole(DeveloperName = 'TestUser1', Name = 'TestRole');
            insert role;

            Profile profile = [SELECT Id
                               FROM Profile
                               WHERE Name = 'System Administrator' LIMIT 1];
            String language = 'en_US';
            String emailAddress = String.valueOf(System.now().getTime() + '@3cc-test.mail');
            User  testUser = new User(
                Alias                    = 'cctest',
                Email                    = emailAddress,
                EmailEncodingKey         = 'UTF-8',
                LastName                 = 'TestUser',
                LanguageLocaleKey        = language,
                LocaleSidKey             = language,
                ProfileId                = profile.Id,
                TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                Username                 = emailAddress,
                isActive                 = true,
                UserRole                 = role,
                EC_CDM_User__c           = user_cdmKey
            );
            insert testUser;
            
            User  testUser1 = new User(
                Alias                    = 'cctest',
                Email                    = emailAddress+'2',
                EmailEncodingKey         = 'UTF-8',
                LastName                 = 'TestUsero',
                LanguageLocaleKey        = language,
                LocaleSidKey             = language,
                ProfileId                = profile.Id,
                TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                Username                 = emailAddress+'2',
                isActive                 = true,
                UserRole                 = role,
                EC_CDM_User__c           = user_cdmKey+'2'
            );
            insert testUser1;
            
            Case testCase = new Case(
                Type = EC_Constants.CASE_TYPE_ACCESS,
                Status = EC_Constants.STATUS_Pending,
                EC_User__c = testUser.Id,
                EC_PortalAccessRole__c = EC_Constants.Portal_Access_Role
            );
            insert testCase;
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'EC_Viewprice'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id);

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EC_BuyerSet'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = testUser1.id, PermissionSetId = ps.Id);
            
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'EC_PESTPI'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps2.Id);
            
            PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'EC_DSR'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps3.Id);

        }
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'EC_Viewprice'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EC_BuyerSet'];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'EC_DSR'];
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'EC_PESTPI'];

        Map<String,Id> permissionMap = new Map<String,Id>();
        permissionMap.put('EC_Viewprice',ps1.Id);
        permissionMap.put('EC_BuyerSet',ps.Id);
        permissionMap.put('EC_DSR',ps2.Id);
        permissionMap.put('EC_PESTPI',ps3.Id);
		List<String> userIds= new List<String>();
        userIds.add(user_cdmKey);
        userIds.add(user_cdmKey+'2');
        List<User> delUser = [Select Id from User where EC_CDM_User__c in :userIds];
        String action = 'DeleteAction';
        EC_Mulesoft_CDM_Staging__c usrPermissionDelte2 =  EC_TestData.createuserPermissionRecStaging(user_cdmKey,'ECOVWPRCE');
        usrPermissionDelte2.EC_Action__c = action;
        insert  usrPermissionDelte2;

        EC_Mulesoft_CDM_Staging__c usrPermissionDelte1 =  EC_TestData.createuserPermissionRecStaging(user_cdmKey,'ECOBYRUSR');
        usrPermissionDelte1.EC_Action__c = action;
        insert  usrPermissionDelte1;
        
        EC_Mulesoft_CDM_Staging__c usrPermissionDelte4 =  EC_TestData.createuserPermissionRecStaging(user_cdmKey,'ECOPESTPI');
        usrPermissionDelte4.EC_Action__c = action;
        insert  usrPermissionDelte4;
        
        EC_Mulesoft_CDM_Staging__c usrPermissionDelte3 =  EC_TestData.createuserPermissionRecStaging(user_cdmKey,'ECODSR');
        usrPermissionDelte3.EC_Action__c = action;
        insert  usrPermissionDelte3;
        
        EC_Mulesoft_CDM_Staging__c usrPermissionDelte7 =  EC_TestData.createuserPermissionRecStaging(user_cdmKey+'2','ECOBYRUSR');
        usrPermissionDelte7.EC_Action__c = action;
        insert  usrPermissionDelte7;

        List<EC_Mulesoft_CDM_Staging__c> stgList = new List<EC_Mulesoft_CDM_Staging__c>();
        stgList.add(usrPermissionDelte1);
        stgList.add(usrPermissionDelte2);
        stgList.add(usrPermissionDelte3);
        stgList.add(usrPermissionDelte4);
        stgList.add(usrPermissionDelte7);

        test.startTest();

        EC_StagingPermissionSetDelete batchObj = new EC_StagingPermissionSetDelete(permissionMap,delUser,stgList,stgList);
        Id batchId = Database.executeBatch(batchObj,5);
        test.stopTest();

    }


}