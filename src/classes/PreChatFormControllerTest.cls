/* Class Name      :PreChatFormControllerTest
* Description      :Test class for PreChatFormController
* Created By       :Graytitude Team
* Created On       :14.09.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          14.09.2020                                      Created
*/
@isTest
private class PreChatFormControllerTest {
    
    static testmethod void fetchContactTest() {    
         // Setup test data
         UserRole role = new UserRole (DeveloperName = 'TestUser_X' , Name = 'TestUser_X' );
         insert role;
            
        // Create a unique UserName
        String uniqueUserName = 'systemadmin' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User runUser = new User(Alias = 'standt', Email='systemadmin@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName,
        UserRoleId = role.Id);
        
        List<User> usr = new List<User>();
        system.runAs(runUser){                        
            usr = EC_TestData.setupCommunityUser(); 
        } 
        Test.startTest();
        system.runAs(usr[0]) {            
            Contact objContact = PreChatFormController.fetchContact(usr[0].Id);
            System.assert(objContact!=null, 'Contact details not found');  
            PreChatFormController.isexemption = true;
            try{
                objContact = PreChatFormController.fetchContact(usr[0].Id);
            } catch(Exception e) {
                System.assertNotEquals(objContact, null);   
            }
        }        
        Test.stopTest();
    }
    
    static testmethod void fetchContactTest_NonCommunityUser() {   
        String cdmUser = String.valueOf(DateTime.Now().getTime());  
        EC_TestData.setupTestSalesRepUser();
        User salesRep = [SELECT Id FROM User WHERE Profile.Name = :EC_TestData.CLOUDCRAZE_EXTERNAL_PROFILE LIMIT 1];
        salesRep.IsActive = true;
        salesRep.EC_CDM_User__c = cdmUser; //'62849';
        update salesRep;
                
        Test.startTest();
        system.runAs(salesRep) {    
            Account ac = new Account(name ='Grazitti') ;
            insert ac;         
            Contact conRec = new Contact(LastName ='testCon',AccountId=ac.Id,EC_CDM_Contact__c=cdmUser);//'62849'
            insert conRec; 
            Contact objContact = PreChatFormController.fetchContact(salesRep.Id);
            System.assertNotEquals(objContact, null);            
        }  
        Test.stopTest();
    }
}