/* Class Name       :EC_StagingUserDeleteTest
* Description      :Batch class to Test EC_StagingUserDelete.
* Created By       :Shruti Sinha
* Created On       :09-09-2019   
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
*Shruti Sinha          09-09-2019                                   Batch class to Test EC_StagingUserDelete.
*/

@istest
public class EC_StagingUserDeleteTest {
    
 public static testMethod void EC_StagingUserDeleteMethod(){

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
                OwnerId = portalUser.Id
            );
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
            //   insert   soldWater;

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

            EC_Mulesoft_CDM_Staging__c contactUpdateInt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
            contactUpdateInt.EC_Action__c = 'UpdateAction';
            insert contactUpdateInt;

            EC_Mulesoft_CDM_Staging__c usrPermissionByr =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
            usrPermissionByr.EC_Action__c = 'InsertAction';
            insert  usrPermissionByr;

            EC_Mulesoft_CDM_Staging__c usrAccountstg =  EC_TestData.createUser_AccountStaging('2234408','2234412');
            usrAccountstg.EC_Action__c = 'InsertAction';
            insert  usrAccountstg; 


            EC_Mulesoft_CDM_Staging__c usrPermissionExtUser =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
            usrPermissionExtUser.EC_Action__c = 'InsertAction';
            insert  usrPermissionExtUser; 


            EC_Mulesoft_CDM_Staging__c usrPermissionDelte =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
            usrPermissionDelte.EC_Action__c = 'DeleteAction';
            insert  usrPermissionDelte; 


            EC_Mulesoft_CDM_Staging__c contactDeleteInt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
            contactDeleteInt.EC_Action__c = 'DeleteAction';
            insert contactDeleteInt; 
            
            EC_Mulesoft_CDM_Staging__c contactDeleteInt1 =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
            contactDeleteInt1.EC_Action__c = 'DeleteAction';
            insert contactDeleteInt1; 
            
            EC_Mulesoft_CDM_Staging__c contactDeleteInt2 =   EC_TestData.getUsrStaging('22344208','testemail33@ecolab.com','Employee');
            contactDeleteInt2.EC_Action__c = 'DeleteAction';
            insert contactDeleteInt2; 

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

            EC_Mulesoft_CDM_Staging__c usrAccountDel =  EC_TestData.createUser_AccountStaging('2234408','2234412');
            usrAccountDel.EC_Action__c = 'DeleteAction';
            insert  usrAccountDel;  
            
            List<EC_Mulesoft_CDM_Staging__c> lstScope = new List<EC_Mulesoft_CDM_Staging__c>();
            lstScope.add(contactUpdateInt);
            lstScope.add(contactDeleteInt);
            lstScope.add(usrPermissionByr);
            lstScope.add(usrPermissionExtUser);
            lstScope.add(usrPermissionDelte);
            lstScope.add(contactDeleteInt1);
            lstScope.add(contactDeleteInt2);
            
            EC_StagingBatch obj = new EC_StagingBatch();
            obj.execute(null,lstScope);

            test.startTest();
            EC_Mulesoft_CDM_Staging__c contactDeleteInt3 =   EC_TestData.getUsrStaging('22344208','testemail33@ecolab.com','Employee');
            contactDeleteInt3.EC_Action__c = 'DeleteAction';
            insert contactDeleteInt3; 
            
            List<EC_Mulesoft_CDM_Staging__c> lstScope1 = new List<EC_Mulesoft_CDM_Staging__c>();
            lstScope1.add(contactDeleteInt3);
            EC_StagingBatch obj1 = new EC_StagingBatch();
            obj1.execute(null,lstScope1);
            test.stopTest();
        }
    }
     
    
}