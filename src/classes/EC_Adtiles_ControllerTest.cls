/*********************************************************************************
Class Name      : EC_Adtiles_Content_Controller
Description     : This class is used as the handler for adtiles Home page lightning component
Created By      : EDC
Created Date    : 12-08-2019
Modification Log:
---------------------------------------------------------------------------------- 
Developer                 Date                   Description
----------------------------------------------------------------------------------            
EDC                  12-08-2019          		 Initial Version 
*********************************************************************************/
@istest
public class EC_Adtiles_ControllerTest {
    @testSetup
    static void getTestData(){ 
       
    	User testUser=new user();        
        Account testAccount= new Account();
          testAccount = new Account(
                        Name                    = 'Testaccount5',
                        OwnerId                 = UserInfo.getUserId(),
                        Type                    = 'Customer' ,
            			EC_Division__c          = 'Institutional'
                );
        insert testAccount;
        Contact contactCC = new Contact(
                FirstName = 'CommunityUser5',
                LastName  = 'TestUser124',
                Email = 'abcd@xyz.com',
                AccountId = testAccount.Id,
                MailingStreet = 'abc'
        );
        insert contactCC; 
        User testUserRep=new user();
        User testOwner = [SELECT TimeZoneSidKey, UserRoleId
            FROM User
            WHERE Id = :UserInfo.getUserId()];
        system.runAs(testOwner){            
            UserRole role = new UserRole(DeveloperName = 'TestUser5', Name = 'TestRole5');
            insert role;            
            Profile profile = [SELECT Id
            FROM Profile
            WHERE Name = 'Ecolab Customer Community Plus Users' LIMIT 1];
            String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
             testUser = new User(
                    Alias                    = 'sample5',
                    Email                    = emailAddress,
                    EmailEncodingKey         = 'UTF-8',
                    LastName                 = 'TestUsersample5',
                    LanguageLocaleKey        = 'en_US',
                    LocaleSidKey             = 'en_US',
                    ProfileId                = profile.Id,
                    TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                    Username                 = emailAddress,
                    isActive                 = true,
                    ContactId                = contactCC.Id,
                    Contact                  = contactCC,
                    UserRole                 = role                    
            );
            insert testUser;
            Profile profile1 = [SELECT Id
            FROM Profile
            WHERE Name = 'Sales rep' LIMIT 1];
            String emailAddress1 = String.valueOf(System.now().getTime() + '1@cc-test.mail');
             testUserRep = new User(
                    Alias                    = 'sample6',
                    Email                    = emailAddress,
                    EmailEncodingKey         = 'UTF-8',
                    LastName                 = 'TestUsersample6',
                    LanguageLocaleKey        = 'en_US',
                    LocaleSidKey             = 'en_US',
                    ProfileId                = profile1.Id,
                    TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                    Username                 = emailAddress1,
                    isActive                 = true,
                    Contact                  = contactCC,
                 	User_Type__c 			 = 'Internal'                  
            );
            insert testUserRep;
        } 
        
        Contact contactCC1 = new Contact(
                FirstName = 'CommunityUser6',
                LastName  = 'TestUser124',
                Email = 'abcd1@xyz.com',
                AccountId = testAccount.Id,
            	EC_SalesRep_User__c = testUserRep.Id,
                MailingStreet = 'abc'
        );
        insert contactCC1; 
        List<EC_Division_Marketing_Content__c> adTilesList=new List<EC_Division_Marketing_Content__c>();    	
        for (integer i=0;i<3;i++){
            EC_Division_Marketing_Content__c adTilesContent=new EC_Division_Marketing_Content__c();
            adTilesContent.name='000'+i;
            adTilesContent.EC_Content__c='abc' + i;
            adTilesContent.Image_CTA_URL__c='https://googly.com'+ i;
            adTilesContent.Image_CTA_URL_Type__c='External';
            adTilesContent.EC_Division__c='INSTITUTIONAl';
            adTilesContent.Active__c=TRUE;
            adTilesContent.Sequence__c=i;            
            adTilesList.add(adTilesContent);
        }        	
       		insert adTilesList;
    }
    
    @isTest 
    static void testAdTilesTestData(){ 
        user u=[select id, name from user where lastname='TestUsersample5'limit 1];
        user u1=[select id, name from user where lastname='TestUsersample6' limit 1];
        test.startTest();
        system.runAs(u){
        	List<EC_Division_Marketing_Content__c> res=EC_Adtiles_Content_Controller.getAdTileContents();    	 
        }
        system.runAs(u1){
        	List<EC_Division_Marketing_Content__c> res=EC_Adtiles_Content_Controller.getAdTileContents();    	 
        }
        List<EC_Division_Marketing_Content__c> res=EC_Adtiles_Content_Controller.getAdTileContents();
        test.stopTest();
        
    }
}