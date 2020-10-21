@istest
public class EC_StagingPermissionUserUpdateTest {
    /***************************************************************************************************************************************
Method Name : createPermissionSetAssignment
Description : Used to test Permission Set Insert scenarios for staging Records
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/
    
    @istest 
    public static void createPermissionSetAssignment(){
        List<RecordType> lstRecordTypeSoldTO =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_SoldTo];
        
        Account testSoldParent = new Account();
        testSoldParent.Name = 'TESTSOldParenNamehere';
        testSoldParent.EC_Account_Number__c = '14102012';
        testSoldParent.EC_CDM_Account__c = '14102012';
        testSoldParent.RecordTypeId = lstRecordTypeSoldTO[0].Id;
        Insert testSoldParent;
        
        
        Contact contactCC = new Contact(
            FirstName = 'Community',
            LastName  = 'StagingPermissionTest2',
            Email = 'testingContacthere@xydfz.com',
            MailingStreet = 'abc',
            AccountId = testSoldParent.Id,
            EC_CDM_Contact__c = '15102019',
            EC_isActive__c = true
        );
        
        insert contactCC;
        User testOwner = [SELECT TimeZoneSidKey, UserRoleId
                          FROM User
                          WHERE Id = :UserInfo.getUserId()];
        
        system.runAs(testOwner){
            UserRole role = new UserRole(DeveloperName = 'TestUser1', Name = 'TestRole');
            insert role;
            
            Profile profile = [SELECT Id
                               FROM Profile
                               WHERE Name = 'Ecolab Customer Community Plus Users' LIMIT 1];
            
            
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
                ContactId                = contactCC.Id,
                Contact                  = contactCC,
                UserRole                 = role,
                EC_CDM_User__c           = '15102019'
                
            );
            insert testUser;       
        }
        
        List<String> lstUserKeys = new List<String>();
        lstUserKeys.add(contactCC.EC_CDM_Contact__c);
        
        test.startTest();
        EC_StagingPermissionUserUpdate batchObj = new EC_StagingPermissionUserUpdate(lstUserKeys);
        Id batchId = Database.executeBatch(batchObj,2);
        test.stopTest();
        
    }
}