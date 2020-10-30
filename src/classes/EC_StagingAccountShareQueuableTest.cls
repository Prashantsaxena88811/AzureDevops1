/* Class Name       :EC_StagingAccountShareQueuableTest
* Description      :TestClass for EC_StagingAccountShareQueuable.
* Created By       :Mishika Mahajan
* Created On       :09-07-2019   
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          09-07-2019                                     TestClass for EC_StagingAccountShareQueuable.
* 
*/
@isTest
public class EC_StagingAccountShareQueuableTest {
@isTest
    private static void EC_StagingAccountShareQueuableExecuteTest(){
        List<Id> userList = new List<Id>();
        User testUser;
        User testOwner = [SELECT TimeZoneSidKey, UserRoleId
            FROM User
            WHERE Id = :UserInfo.getUserId()];
        system.runAs(testOwner){
       UserRole role = new UserRole(DeveloperName = 'TestUser1', Name = 'TestRole1');
            insert role;
            
            Profile profile = [SELECT Id
            FROM Profile
            WHERE Name = 'Sales Rep' LIMIT 1];
    
            String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
            testUser = new User(
                    Alias                    = 'cctest',
                    Email                    = emailAddress,
                    EmailEncodingKey         = 'UTF-8',
                    LastName                 = 'SalesRepUser',
                    LanguageLocaleKey        = 'en_US',
                    LocaleSidKey             = 'en_US',
                    ProfileId                = profile.Id,
                    TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                    Username                 = emailAddress,
                    isActive                 = true,
                    User_Type__c             ='Internal',
                    UserRole                 = role
                    
            );
            insert testUser;
            userList.add(testUser.id);
            
        }
    
        EC_TestData.setupCatalog();
        Account acc1 = EC_TestData.testAccount;
        Contact contactCC = new Contact(
                FirstName = 'CloudCraze',
                LastName  = 'TestUser2',
                Email = 'abc@xyz.com',
                AccountId = acc1.Id,
                MailingStreet = 'abc',
                EC_SalesRep_User__c = testUser.id
        );
        insert contactCC;
       AccountContactRelation accCon = new AccountContactRelation();
        accCon.AccountId = EC_TestData.testAccountSoldTo.id;
        accCon.ContactId = contactCC.id;
        insert accCon;
        List<EC_Mulesoft_CDM_Staging__c> conList = new List<EC_Mulesoft_CDM_Staging__c>();
       EC_Mulesoft_CDM_Staging__c contactInsertExt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Customer');
        contactInsertExt.EC_Action__c = 'InsertAction';
       
        conList.add(contactInsertExt);
        EC_Mulesoft_CDM_Staging__c contactInsertInt =   EC_TestData.getUsrStaging('2234409','testemail33@ecolab.com','Employee');
        contactInsertInt.EC_Action__c = 'InsertAction';
        
          conList.add(contactInsertInt);
        EC_Mulesoft_CDM_Staging__c contactUpdateInt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
        contactUpdateInt.EC_Action__c = 'UpdateAction';
        
       conList.add(contactUpdateInt);
       insert conList;
        EC_StagingAccountShareQueuable stagAccShare = new EC_StagingAccountShareQueuable(userList,conList,null,null);
         Test.startTest();        
        System.enqueueJob(stagAccShare);
        Test.stopTest(); 
    }
    @TestSetup
    
    public static void stagingTest(){
       
      UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalUser = new User(
        UserRoleId = portalRole.Id,
       ProfileId = profile1.Id,
       Username = System.now().millisecond() + 'test2@test.com',
       Alias = 'batman',
       Email='bruce.wayne@wayneenterprises.com',
        EmailEncodingKey='UTF-8',
     Firstname='Bruce',
       Lastname='Wayne',
      LanguageLocaleKey='en_US',
       LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago');
     insert portalUser;
        
         
      System.runAs (portalUser) {
       Account portalAccount1 = new Account(
       Name = 'DummyAccountKey',
       EC_CDM_Account__c = 'DummyAccountKey',
       OwnerId = portalUser.Id);
       Database.insert(portalAccount1);
   List<RecordType> lstRecordType =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_Corporate];
        Account testAccount = new Account();
				  testAccount.EC_Account_Number__c = 'CORP_2';
				  testAccount.Name = 'TestCoporateAccount';
                  testAccount.RecordTypeId = lstRecordType[0].Id;
		    Insert testAccount;
   
     
          
       List<RecordType> lstRecordTypeSoldTO =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_SoldTo];
	
      Account testSoldto = new Account();
              testSoldto.Name = 'TESTSOLD TO';
			   testSoldto.EC_Account_Number__c = '15081947';
               testSoldto.RecordTypeId = lstRecordTypeSoldTO[0].Id;
		Insert testSoldto;
     
        Account testSoldParent = new Account();
              testSoldParent.Name = 'TESTSOldParent';
			   testSoldParent.EC_Account_Number__c = '15081950';
               testSoldParent.EC_CDM_Account__c = '15081950';
               testSoldParent.RecordTypeId = lstRecordTypeSoldTO[0].Id;
		Insert testSoldParent;
          
       Contact cntct = new Contact();
          cntct.LastName = 'testLasthere';
          cntct.AccountId = testSoldto.Id;
          cntct.EC_CDM_Contact__c = '15081950';
          Insert cntct ;
          
          
          
          
    EC_Mulesoft_CDM_Staging__c objTest =  EC_TestData.getAccStaging('2234408','INSTITUTIONAL','SOLDTO','A');
     objTest.EC_Action__c = 'InsertAction';
    insert objTest;  
        
     EC_Mulesoft_CDM_Staging__c objTest2 = EC_TestData.getAccStaging('2234408','INSTITUTIONAL','SOLDTO','A');    
        objTest2.EC_Action__c = 'UpdateAction';
      insert  objTest2;  
          
    // below list to test the duplicate update action on same record
    List<EC_Mulesoft_CDM_Staging__c> liststaging = new List<EC_Mulesoft_CDM_Staging__c>();
    EC_Mulesoft_CDM_Staging__c objTemp = EC_TestData.getAccStaging('2234408','INSTITUTIONAL','SOLDTO','A');    
     objTemp.EC_Action__c = 'UpdateAction';
    EC_Mulesoft_CDM_Staging__c objTemp2 = EC_TestData.getAccStaging('2234408','WATER','SOLDTO','A');    
     objTemp2.EC_Action__c = 'UpdateAction'; 
      liststaging.add(objTemp);
     liststaging.add(objTemp2);   
    Insert  liststaging ;                                  
        
      }   
    }
}