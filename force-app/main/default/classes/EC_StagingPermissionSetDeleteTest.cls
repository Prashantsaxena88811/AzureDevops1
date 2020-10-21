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

        system.runAs(testOwner){
            UserRole role = new UserRole(DeveloperName = 'TestUser1', Name = 'TestRole');
            insert role;

            Profile profile = [SELECT Id
                               FROM Profile
                               WHERE Name = 'System Administrator' LIMIT 1];

            String emailAddress = String.valueOf(System.now().getTime() + '@3cc-test.mail');
            User  testUser = new User(
                Alias                    = 'cctest',
                Email                    = emailAddress,
                EmailEncodingKey         = 'UTF-8',
                LastName                 = 'TestUser',
                LanguageLocaleKey        = 'en_US',
                LocaleSidKey             = 'en_US',
                ProfileId                = profile.Id,
                TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                Username                 = emailAddress,
                isActive                 = true,
                UserRole                 = role,
                EC_CDM_User__c           = '15102019'
            );
            insert testUser;

             PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'EC_Viewprice'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id);

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EC_BuyerSet'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);

        }
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'EC_Viewprice'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EC_BuyerSet'];

        Map<String,Id> permissionMap = new Map<String,Id>();
        permissionMap.put('EC_Viewprice',ps1.Id);
        permissionMap.put('EC_BuyerSet',ps.Id);

        User delUser = [Select Id from User where EC_CDM_User__c = '15102019'];

        EC_Mulesoft_CDM_Staging__c usrPermissionDelte2 =  EC_TestData.createuserPermissionRecStaging('15102019','ECOVWPRCE');
        usrPermissionDelte2.EC_Action__c = 'DeleteAction';
        insert  usrPermissionDelte2;

        EC_Mulesoft_CDM_Staging__c usrPermissionDelte1 =  EC_TestData.createuserPermissionRecStaging('15102019','ECOBYRUSR');
        usrPermissionDelte1.EC_Action__c = 'DeleteAction';
        insert  usrPermissionDelte1;

        List<User> lstUser = new List<User>();
        lstUser.add(delUser);

        List<EC_Mulesoft_CDM_Staging__c> stgList = new List<EC_Mulesoft_CDM_Staging__c>();
        stgList.add(usrPermissionDelte1);
        stgList.add(usrPermissionDelte2);


        test.startTest();

        EC_StagingPermissionSetDelete batchObj = new EC_StagingPermissionSetDelete(permissionMap,lstUser,stgList,stgList);
        Id batchId = Database.executeBatch(batchObj,5);

        test.stopTest();

    }


}