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
        Test.stopTest();
      }
    }
  }