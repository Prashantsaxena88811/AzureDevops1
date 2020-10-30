/* Class Name       :EC_StagingQueableTest
* Description      :TestClass for EC_StagingQueable.
* Created By       :Mishika Mahajan
* Created On       :09-07-2019   
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          09-07-2019                                     TestClass for EC_StagingQueable.
* 
*/
@isTest
public class EC_StagingQueableTest {
    private static final string en_US = 'en_US';
    private static final string UTFFormat = 'UTF-8';
    
    
    /***************************************************************************************************************************************
    Method Name : runUserActions
    Description : Test the scenarios for (User Insert,Update,Delete) and User_Permission(Insert,Delete)
    Return type : void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    public static testMethod void runUserUpdateActions(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2qw@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises1a.com',
            EmailEncodingKey=UTFFormat,
            Firstname='Bruce',
            Lastname='Wayneew3',
            LanguageLocaleKey=en_US,
            LocaleSidKey=en_US,
            TimeZoneSidKey='America/Chicago');
        insert portalUser;
        
        System.runAs (portalUser) {
            List<RecordType> lstRecordTypeSoldTO =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_SoldTo];
            Profile ecpProfile = [SELECT Id FROM Profile WHERE Name = :EC_Constants.PROFILE LIMIT 1];
            Profile salesRepProfile = [SELECT Id FROM Profile WHERE Name = :EC_Constants.SALES_REP LIMIT 1];
                
            PermissionSet buyerPerm = [Select Id from PermissionSet where name = 'EC_BuyerSet'];

            Account portalAccount1 = new Account(
            Name = 'DummyAccountKey',
            EC_CDM_Account__c = 'DummyAccountKey',
            OwnerId = portalUser.Id);
            Database.insert(portalAccount1);
                
            Account testSoldto = new Account();
            testSoldto.Name = 'TESTSOLD TO';
            testSoldto.EC_Account_Number__c = '15081947';
            testSoldto.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            Insert testSoldto;
                
            Contact cntct = new Contact();
            cntct.LastName = 'testLasthere7';
            cntct.AccountId = testSoldto.Id;
            cntct.EC_User_Type__c = EC_Constants.CUSTOMER;
            cntct.EC_CDM_Contact__c = '15081950';
            cntct.EC_isActive__c = true;
            cntct.EC_Alias__c = 'ecpSU1@';
            Insert cntct ;
                
            User testUser = new User();
            testUser.LastName = 'ecpStage';
            testUser.Username = 'ecpUser@stageUser.ecdevv';
            testUser.Email = 'ecpUser@stageUser.ecdevv';
            testUser.Alias = 'ecpSU1@';
            testUser.TimeZoneSidKey = portalUser.TimeZoneSidKey;
            testUser.LocaleSidKey = en_US;
            testUser.EmailEncodingKey = UTFFormat;
            testUser.ProfileId = ecpProfile.Id;
            testUser.LanguageLocaleKey = en_US;
            testUser.EC_CDM_User__c = '15081950';
            testUser.ContactId = cntct.Id;
            testUser.isActive = true;
            testUser.Contact = cntct;
            insert testUser; 
                
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = testUser.Id;
            psAssignment.PermissionSetId = buyerPerm.Id;
            insert psAssignment;
                
            User testUser1 = new User();
            testUser1.LastName = 'ecpStage';
            testUser1.Username = 'ecpUser1@stageUser.ecdevv';
            testUser1.Email = 'ecpUser1@stageUser.ecdevv';
            testUser1.Alias = 'ecpSU2@';
            testUser1.TimeZoneSidKey = portalUser.TimeZoneSidKey;
            testUser1.LocaleSidKey = en_US;
            testUser1.EmailEncodingKey = UTFFormat;
            testUser1.ProfileId = salesRepProfile.Id;
            testUser1.LanguageLocaleKey = en_US;
            testUser1.EC_CDM_User__c = '150819501';
            testUser1.isActive = true;
            insert testUser1;
            
            PermissionSetAssignment psAssignment1 = new PermissionSetAssignment();
            psAssignment1.AssigneeId = testUser1.Id;
            psAssignment1.PermissionSetId = buyerPerm.Id;
            insert psAssignment1;
                
            Contact cntct1 = new Contact();
            cntct1.LastName = 'testLasthere8';
            cntct1.AccountId = testSoldto.Id;
            cntct1.EC_Alias__c = 'ecpSU2@';
            cntct1.EC_User_Type__c = EC_Constants.EMPLOYEE;
            cntct1.EC_CDM_Contact__c = '150819501';
            cntct1.EC_isActive__c = true;
            cntct1.EC_SalesRep_User__c = testUser1.Id;
            Insert cntct1 ;
                
            User testUser2 = new User();
            testUser2.LastName = 'ecpStage';
            testUser2.Username = 'ecpUser1@stageUser1.ecdevv';
            testUser2.Email = 'ecpUser1@stageUser1.ecdevv';
            testUser2.Alias = 'ecpSU3@';
            testUser2.TimeZoneSidKey = portalUser.TimeZoneSidKey;
            testUser2.LocaleSidKey = en_US;
            testUser2.EmailEncodingKey = UTFFormat;
            testUser2.ProfileId = salesRepProfile.Id;
            testUser2.LanguageLocaleKey = en_US;
            testUser2.EC_CDM_User__c = '1508195012';
            testUser2.isActive = true;
            insert testUser2;
            
            Contact cntct2 = new Contact();
            cntct2.LastName = 'testLasthere9';
            cntct2.AccountId = testSoldto.Id;
            cntct2.EC_Alias__c = 'ecpSU3@';
            cntct2.EC_User_Type__c = EC_Constants.EMPLOYEE;
            cntct2.EC_CDM_Contact__c = '1508195012';
            cntct2.EC_isActive__c = true;
            cntct2.EC_SalesRep_User__c = testUser2.Id;
            Insert cntct2 ;
                
            Contact cntct4 = new Contact();
            cntct4.LastName = 'testLastherew';
            cntct4.AccountId = testSoldto.Id;
            cntct4.EC_User_Type__c = EC_Constants.CUSTOMER;
            cntct4.EC_CDM_Contact__c = '15081953';
            cntct4.EC_Alias__c = 'ecpU4@';
            cntct4.EC_isActive__c = true;
            Insert cntct4 ;
            
            User testUser4 = new User();
            testUser4.LastName = 'ecpStage';
            testUser4.Username = 'ecpUser@stageUser33.ecdevv';
            testUser4.Email = 'ecpUser@stageUser33.ecdevv';
            testUser4.Alias = 'ecpU4@';
            testUser4.TimeZoneSidKey = portalUser.TimeZoneSidKey;
            testUser4.LocaleSidKey = en_US;
            testUser4.EmailEncodingKey = UTFFormat;
            testUser4.ProfileId = ecpProfile.Id;
            testUser4.LanguageLocaleKey = en_US;
            testUser4.EC_CDM_User__c = '15081953';
            testUser4.ContactId = cntct4.Id;
            testUser4.isActive = true;
            testUser4.Contact = cntct4;
            insert testUser4; 
                
            PermissionSetAssignment psAssignment4 = new PermissionSetAssignment();
            psAssignment4.AssigneeId = testUser4.Id;
            psAssignment4.PermissionSetId = buyerPerm.Id;
            insert psAssignment4;
                
            User testUser5 = new User();
            testUser5.LastName = 'ecpStage';
            testUser5.Username = 'ecpUser1@stageUser13.ecdevv';
            testUser5.Email = 'ecpUser1@stageUser13.ecdevv';
            testUser5.Alias = 'ecp35@';
            testUser5.TimeZoneSidKey = portalUser.TimeZoneSidKey;
            testUser5.LocaleSidKey = en_US;
            testUser5.EmailEncodingKey = UTFFormat;
            testUser5.ProfileId = salesRepProfile.Id;
            testUser5.LanguageLocaleKey = en_US;
            testUser5.EC_CDM_User__c = '1508195015';
            testUser5.isActive = false;
            insert testUser5;
                
            PermissionSetAssignment psAssignment5 = new PermissionSetAssignment();
            psAssignment5.AssigneeId = testUser2.Id;
            psAssignment5.PermissionSetId = buyerPerm.Id;
            insert psAssignment5;
                
            Contact cntct5 = new Contact();
            cntct5.LastName = 'testLasthere11';
            cntct5.AccountId = testSoldto.Id;
            cntct5.EC_User_Type__c = EC_Constants.EMPLOYEE;
            cntct5.EC_CDM_Contact__c = '1508195015';
            cntct5.EC_isActive__c = false;
            cntct5.EC_Alias__c = 'ecp35@';
            cntct5.EC_SalesRep_User__c = testUser5.Id;
            Insert cntct5 ;
            test.startTest();

            List<EC_Mulesoft_CDM_Staging__c> stageList = new List<EC_Mulesoft_CDM_Staging__c>();
                
            EC_Mulesoft_CDM_Staging__c contactUpdateExt3 =   EC_TestData.getUsrStaging('1508195012','testemail33cust@ecolab.com', '');
            contactUpdateExt3.EC_User_Status_Code__c = 'I';
            contactUpdateExt3.EC_Action__c = 'UPDATEACTION';
            contactUpdateExt3.EC_User_Type__c = EC_Constants.EMPLOYEE;
            insert contactUpdateExt3;
            stageList.add(contactUpdateExt3);
            
            EC_Mulesoft_CDM_Staging__c contactUpdateExt2 =   EC_TestData.getUsrStaging('150819501','testemail33cust@ecolab.com', '');
            contactUpdateExt2.EC_User_Status_Code__c = 'A';
            contactUpdateExt2.EC_Action__c = 'UPDATEACTION';
            contactUpdateExt2.EC_User_Type__c = EC_Constants.EMPLOYEE;
            insert contactUpdateExt2;
            stageList.add(contactUpdateExt2);
                
            EC_Mulesoft_CDM_Staging__c contactUpdateExt =   EC_TestData.getUsrStaging('15081950','testemail33cust@ecolab.com', '');
            contactUpdateExt.EC_User_Status_Code__c = 'A';
            contactUpdateExt.EC_Action__c = 'UPDATEACTION';
            contactUpdateExt.EC_User_Type__c = EC_Constants.CUSTOMER;
            insert contactUpdateExt;
            stageList.add(contactUpdateExt);
                
            EC_Mulesoft_CDM_Staging__c contactUpdateExt5 =   EC_TestData.getUsrStaging('15081953','testemail33cust3@ecolab.com', '');
            contactUpdateExt5.EC_User_Status_Code__c = 'I';
            contactUpdateExt5.EC_Action__c = 'UPDATEACTION';
            contactUpdateExt5.EC_User_Type__c = EC_Constants.CUSTOMER;
            insert contactUpdateExt5;
            stageList.add(contactUpdateExt5);
                
            EC_Mulesoft_CDM_Staging__c contactUpdateExt1 =   EC_TestData.getUsrStaging('','testemail33cust@ecolab.com', EC_Constants.CUSTOMER);
            contactUpdateExt1.EC_User_Status_Code__c = 'A';
            contactUpdateExt1.EC_Action__c = 'UPDATEACTION'; 
            contactUpdateExt1.EC_User_Type__c = EC_Constants.CUSTOMER;
            insert contactUpdateExt1;
            stageList.add(contactUpdateExt1);
                
            EC_Mulesoft_CDM_Staging__c contactUpdateExt7 =   EC_TestData.getUsrStaging('1508195015','testemail335cust@ecolab.com', EC_Constants.CUSTOMER);
            contactUpdateExt7.EC_User_Status_Code__c = 'A';
            contactUpdateExt7.EC_Action__c = 'UPDATEACTION'; 
            contactUpdateExt7.EC_User_Type__c = EC_Constants.EMPLOYEE;
            insert contactUpdateExt7;
            stageList.add(contactUpdateExt7);
            
            EC_StagingQueable stagQueue = new EC_StagingQueable(stageList);
            System.enqueueJob(stagQueue);
            system.assertEquals(true, stageList!=null);
            test.stopTest();
        }
    }
    
    public static testMethod void stagingQueableTest(){
        List<EC_Mulesoft_CDM_Staging__c> stageList = new List<EC_Mulesoft_CDM_Staging__c>();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey= UTFFormat, 
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey=en_US,
            LocaleSidKey=en_US,
            TimeZoneSidKey='America/Chicago');
        insert portalUser;
        
        
        System.runAs (portalUser) {
          List<RecordType> lstRecordType =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_Corporate];
          List<RecordType> lstRecordTypeSoldTO =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_SoldTo];
          Profile ecpProfile = [SELECT Id FROM Profile WHERE Name = :EC_Constants.PROFILE LIMIT 1];
          PermissionSet buyerPerm = [Select Id from PermissionSet where name = 'EC_BuyerSet'];

          Account portalAccount1 = new Account(
          Name = 'DummyAccountKey',
          EC_CDM_Account__c = 'DummyAccountKey',
          OwnerId = portalUser.Id);
          Database.insert(portalAccount1);
          
          Account testAccount = new Account();
          testAccount.EC_Account_Number__c = 'CORP_2';
          testAccount.Name = 'TestCoporateAccount';
          testAccount.RecordTypeId = lstRecordType[0].Id;
          Insert testAccount;
          
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
          cntct.LastName = 'testLasthere22';
          cntct.AccountId = testSoldto.Id;
          cntct.EC_CDM_Contact__c = '15081950';
          Insert cntct ;

          Contact conV1 = new Contact();
          conV1.LastName = 'testLasthere23';
          conV1.AccountId = testSoldto.Id;
          conV1.EC_CDM_Contact__c = '97359875';
          conV1.Email = 'staging.test@stagingtest.com';
          conV1.EC_User_Type__c = 'Customer';
          Insert conV1;

          User testUser = new User();
          testUser.LastName = 'ecpStage';
          testUser.Username = 'ecpUser@stageUser.ecdevv';
          testUser.Email = 'ecpUser@stageUser.ecdevv';
          testUser.Alias = 'ecpSU@';
          testUser.TimeZoneSidKey = portalUser.TimeZoneSidKey;
          testUser.LocaleSidKey = en_US;
          testUser.EmailEncodingKey = UTFFormat;
          testUser.ProfileId = ecpProfile.Id;
          testUser.LanguageLocaleKey = en_US;
          testUser.EC_CDM_User__c = '97359875';
          testUser.ContactId = conV1.Id;
          testUser.isActive = true;
          testUser.Contact = conV1;
          insert testUser;

          PermissionSetAssignment psAssignment = new PermissionSetAssignment();
          psAssignment.AssigneeId = testUser.Id;
          psAssignment.PermissionSetId = buyerPerm.Id;
          insert psAssignment;
          
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
          
          EC_Mulesoft_CDM_Staging__c objTest3 = EC_TestData.getAccStaging('2234408','INSTITUTIONAL','SOLDTO','A');    
          objTest3.EC_Action__c = 'DeleteAction';
          insert  objTest3;     
          
          EC_Mulesoft_CDM_Staging__c shipInst =  EC_TestData.getAccStaging('2234407','INSTITUTIONAL','SHIPTO','A');
          shipInst.EC_Action__c = 'InsertAction';
          //  insert shipInst;
          
          EC_Mulesoft_CDM_Staging__c  soldWater = EC_TestData.getAccStaging('2234409','WATER','SOLDTO','A');           
          soldWater.EC_Action__c = 'InsertAction';        
          //   insert    soldWater;
          
          EC_Mulesoft_CDM_Staging__c  soldInst =   EC_TestData.getAccStaging('2234410','INSTITUTIONAL','SOLDTO','A');
          soldInst.EC_Action__c = 'InsertAction';    
          //  insert soldInst;
          
          EC_Mulesoft_CDM_Staging__c  shipWater =   EC_TestData.getAccStaging('2234412','WATER','SHIPTO','A');
          shipWater.EC_Action__c = 'InsertAction';    
          insert shipWater; 
          EC_Mulesoft_CDM_Staging__c  shipWaterUpdt =   EC_TestData.getAccStaging('2234412','WATER','SHIPTO','A');
          shipWaterUpdt.EC_Action__c = 'UpdateAction';
          insert shipWaterUpdt;         
          
          EC_Mulesoft_CDM_Staging__c objTestDup =  EC_TestData.getAccStaging('2234408','INSTITUTIONAL','SOLDTO','A');
          objTestDup.EC_Action__c = 'InsertAction';
          insert objTestDup; 
          
          // Below data is Used for Contact Insertion    
          EC_Mulesoft_CDM_Staging__c contactInsertExt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Customer');
          contactInsertExt.EC_Action__c = 'InsertAction';
          insert contactInsertExt;
          
          EC_Mulesoft_CDM_Staging__c contactInsertInt =   EC_TestData.getUsrStaging('2234409','testemail33@ecolab.com','Employee');
          contactInsertInt.EC_Action__c = 'InsertAction';
          insert contactInsertInt; 
          stageList.add(contactInsertInt);
          
          EC_Mulesoft_CDM_Staging__c contactUpdateInt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
          contactUpdateInt.EC_Action__c = 'UpdateAction';
          insert contactUpdateInt;
          stageList.add(contactUpdateInt);
          
          EC_Mulesoft_CDM_Staging__c contactUpdateInt1 =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
          contactUpdateInt1.EC_Action__c = 'DeleteAction';
          insert contactUpdateInt1;
          stageList.add(contactUpdateInt1);
          
          EC_Mulesoft_CDM_Staging__c contactUpdateInt2 =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
          contactUpdateInt2.EC_Action__c = 'DeleteAction';
          insert contactUpdateInt2;
          stageList.add(contactUpdateInt2);
          
          EC_Mulesoft_CDM_Staging__c contactUpdateInt3 =   EC_TestData.getUsrStaging('','testemail33@ecolab.com','Employee');
          contactUpdateInt3.EC_Action__c = 'UpdateAction';
          insert contactUpdateInt3;
          stageList.add(contactUpdateInt3);
          
          EC_Mulesoft_CDM_Staging__c contactUpdateInt4 =   EC_TestData.getUsrStaging('2234403','testemail33@ecolab.com','Employee');
          contactUpdateInt4.EC_Action__c = '';
          insert contactUpdateInt4;
          stageList.add(contactUpdateInt4); 
          
          EC_Mulesoft_CDM_Staging__c contactUpdateInt5 =   EC_TestData.getUsrStaging('','testemail33@ecolab.com','Employee');
          contactUpdateInt5.EC_Action__c = 'DeleteAction';
          insert contactUpdateInt5;
          stageList.add(contactUpdateInt5);
          
          EC_Mulesoft_CDM_Staging__c contactUpdateInt6 =   EC_TestData.getUsrStaging('','testemail33@ecolab.com','Employee');
          contactUpdateInt6.EC_Action__c = 'DeleteAction';
          contactUpdateInt6.EC_Source_Table__c = '';
          insert contactUpdateInt6;
          stageList.add(contactUpdateInt6);
          
          EC_Mulesoft_CDM_Staging__c usrPermissionByr =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
          usrPermissionByr.EC_Action__c = 'InsertAction';
          insert  usrPermissionByr;
          stageList.add(usrPermissionByr);
          
          EC_Mulesoft_CDM_Staging__c usrAccountstg =  EC_TestData.createUser_AccountStaging('2234408','2234412');
          usrAccountstg.EC_Action__c = 'InsertAction';
          insert  usrAccountstg; 
          
          EC_Mulesoft_CDM_Staging__c usrAccountstg1 =  EC_TestData.createUser_AccountStaging('2234408','2234412');
          usrAccountstg1.EC_Action__c = '';
          insert  usrAccountstg1; 
          stageList.add(usrAccountstg1);
          
          EC_Mulesoft_CDM_Staging__c usrPermissionExtUser =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
          usrPermissionExtUser.EC_Action__c = 'InsertAction';
          insert  usrPermissionExtUser; 
          stageList.add(usrPermissionExtUser); 
          
          EC_Mulesoft_CDM_Staging__c usrPermissionExtUser1 =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
          usrPermissionExtUser1.EC_Action__c = '';
          insert  usrPermissionExtUser1; 
          stageList.add(usrPermissionExtUser1); 
          
          EC_Mulesoft_CDM_Staging__c usrPermissionDelte =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
          usrPermissionDelte.EC_Action__c = 'DeleteAction';
          insert  usrPermissionDelte;
          stageList.add(usrPermissionDelte); 

          EC_Mulesoft_CDM_Staging__c usrPermissionDelete =  EC_TestData.createuserPermissionRecStaging('97359875','ECOBYRUSRV1');
          usrPermissionDelete.EC_Action__c = 'DeleteAction';
          insert  usrPermissionDelete;
          stageList.add(usrPermissionDelete);
          
          EC_Mulesoft_CDM_Staging__c contactDeleteInt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
          contactDeleteInt.EC_Action__c = 'DeleteAction';
          insert contactDeleteInt; 
          
          EC_Mulesoft_CDM_Staging__c  updAcc = new  EC_Mulesoft_CDM_Staging__c();
          updAcc.EC_Parent_Account_Number__c = '15081950';
          updAcc.EC_Account_Key__c = '2234412';
          updAcc.EC_Account_Name_English__c = 'Updated Account here';
          updAcc.EC_Account_Number__c = '2234412';
          updAcc.EC_Partner_Function__c = 'SHIPTO';
          updAcc.EC_Account_Global_Business_Unit_Name__c = 'WATER';
          updAcc.EC_Account_Divisional_Business_Unit_Name__c = 'WATER';
          updAcc.EC_Source_Table__c = 'Account';
          updAcc.EC_Action__c = 'UpdateAction';
          insert  updAcc;
          stageList.add(updAcc); 
          
          EC_Mulesoft_CDM_Staging__c  updsoldAcc = new  EC_Mulesoft_CDM_Staging__c();
          updsoldAcc.EC_Account_Key__c = '2234408';
          updsoldAcc.EC_Account_Name_English__c = 'Updated Account here';
          updsoldAcc.EC_Account_Number__c = '2234408';
          updsoldAcc.EC_Partner_Function__c = 'SOLDTO';
          updsoldAcc.EC_Account_Global_Business_Unit_Name__c = 'INSTITUTIONAL';
          updsoldAcc.EC_Account_Divisional_Business_Unit_Name__c = 'XYZ';
          updsoldAcc.EC_Source_Table__c = 'Account';
          updsoldAcc.EC_Action__c = 'UpdateAction';
          insert  updsoldAcc;      
          stageList.add(updsoldAcc); 
          
          EC_Mulesoft_CDM_Staging__c  updsoldAcc1 = new  EC_Mulesoft_CDM_Staging__c();
          updsoldAcc1.EC_Account_Key__c = '2234408';
          updsoldAcc1.EC_Account_Name_English__c = 'Updated Account here';
          updsoldAcc1.EC_Account_Number__c = '2234408';
          updsoldAcc1.EC_Partner_Function__c = 'SOLDTO';
          updsoldAcc1.EC_Account_Global_Business_Unit_Name__c = 'INSTITUTIONAL';
          updsoldAcc1.EC_Account_Divisional_Business_Unit_Name__c = 'XYZ';
          updsoldAcc1.EC_Source_Table__c = 'Account';
          updsoldAcc1.EC_Action__c = '';
          insert  updsoldAcc1;      
          stageList.add(updsoldAcc1);
          
          EC_Mulesoft_CDM_Staging__c usrAccountDel =  EC_TestData.createUser_AccountStaging('2234408','2234412');
          usrAccountDel.EC_Action__c = 'DeleteAction';
          insert  usrAccountDel;  
          
          EC_StagingQueable stagQueue = new EC_StagingQueable(stageList);
          Test.startTest();
          System.enqueueJob(stagQueue);
          system.assertEquals(true, stageList!=null);
          Test.stopTest();	
        }
    }
}