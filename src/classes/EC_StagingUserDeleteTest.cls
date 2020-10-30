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
    private static final String CDMKEY1 = '2234408';
    private static final String CDMKEY2 = '2234409';
    private static final String CDMKEY3 = '2234412';
    private static final String CDMKEY4 = '15081950';
    private static final String CUSTOMER = 'Customer';
    private static final String EMPLOYEE = 'Employee';
    private static final String SOLDTO = 'SOLDTO';
    private static final String SHIPTO = 'SHIPTO';
    private static final String INSERTACTION = 'InsertAction';
    private static final String UPDATEACTION = 'UpdateAction';
    private static final String DELETEACTION = 'DeleteAction';
    private static final String INSTITUTIONAL = 'INSTITUTIONAL';
    private static final String WATER = 'WATER';
    private static final String Active = 'A';
    private static final String EMAIL = 'testemail33@ecolab.com';
    private static final String ECOBYRUSR = 'ECOBYRUSR';
    
	@testSetup
    static void testData(){
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
			List<RecordType> lstRecordTypeShipTO =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_ShipTo];
            Account testSoldto = new Account();
            testSoldto.Name = 'TESTSOLD TO';
            testSoldto.EC_Account_Number__c = '15081947';
            testSoldto.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            Insert testSoldto;

            Account testSoldParent = new Account();
            testSoldParent.Name = 'TESTSOldParent';
            testSoldParent.EC_Account_Number__c = CDMKEY4;
            testSoldParent.EC_CDM_Account__c = CDMKEY4;
            testSoldParent.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            Insert testSoldParent;

            Contact cntct = new Contact();
            cntct.LastName = 'testLasthere';
            cntct.AccountId = testSoldto.Id;
            cntct.EC_CDM_Contact__c = CDMKEY4;
            Insert cntct ;
            
            Account testShipParent = new Account();
            testShipParent.Name = 'TESTSOldChild';
            testShipParent.EC_Account_Number__c = '456754';
            testShipParent.parentid = testSoldParent.Id;
            testShipParent.EC_CDM_Account__c = '456754';
            testShipParent.RecordTypeId = lstRecordTypeShipTO[0].Id;
            Insert testShipParent;
            
            Account testShipParent1 = new Account();
            testShipParent1.Name = 'TESTSOldChild';
            testShipParent1.EC_Account_Number__c = '4567541';
            testShipParent1.parentid = testSoldParent.Id;
            testShipParent1.EC_CDM_Account__c = '4567541';
            testShipParent1.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            Insert testShipParent1;
            
            Contact cntct1 = new Contact();
            cntct1.LastName = 'testLasthere';
            cntct1.AccountId = testShipParent.Id;
            cntct1.EC_CDM_Contact__c = '345644';
            Insert cntct1 ;
            
            Contact cntct2 = new Contact();
            cntct2.LastName = 'testLasthere1';
            cntct2.AccountId = testShipParent1.Id;
            cntct2.EC_CDM_Contact__c = '3456443';
            Insert cntct2 ;
            
            Account testShipParent3 = new Account();
            testShipParent3.Name = 'TESTSOldChild1';
            testShipParent3.EC_Account_Number__c = '45675445';
            testShipParent3.EC_CDM_Account__c = '45675445';
            testShipParent3.RecordTypeId = lstRecordTypeShipTO[0].Id;
            Insert testShipParent3;
            
            AccountContactRelation accContRel22 = new AccountContactRelation(accountid = testSoldParent.id, contactid = cntct.id);
        	insert accContRel22;
            
            AccountContactRelation accContRel23 = new AccountContactRelation(accountid = testShipParent3.id, contactid = cntct2.id);
        	insert accContRel23;
        }
    }
    
    public static testMethod void EC_StagingUserDeleteNegativeMethod(){
        test.startTest();
        EC_Mulesoft_CDM_Staging__c usrAccountDelNegative11 =  EC_TestData.createUser_AccountStaging('4567541','3456443');
        usrAccountDelNegative11.EC_Action__c = DELETEACTION;
        
        EC_Mulesoft_CDM_Staging__c usrAccountDelNegative =  EC_TestData.createUser_AccountStaging(CDMKEY4,CDMKEY4);
        usrAccountDelNegative.EC_Action__c = DELETEACTION;
        
        EC_Mulesoft_CDM_Staging__c usrAccountDelNegative1 =  EC_TestData.createUser_AccountStaging('456754','345644');
        usrAccountDelNegative1.EC_Action__c = DELETEACTION;
        
        EC_Mulesoft_CDM_Staging__c usrAccountDelNegative2 =  EC_TestData.createUser_AccountStaging(CDMKEY4,CDMKEY4);
        usrAccountDelNegative2.EC_Action__c = DELETEACTION;
        
        List<EC_Mulesoft_CDM_Staging__c> lstScope = new List<EC_Mulesoft_CDM_Staging__c>();
        lstScope.add(usrAccountDelNegative2);
        lstScope.add(usrAccountDelNegative1);
        lstScope.add(usrAccountDelNegative);
        lstScope.add(usrAccountDelNegative11);
        EC_StagingBatch obj = new EC_StagingBatch();
        obj.execute(null,lstScope);
        test.stopTest();
    } 
    
    public static testMethod void EC_StagingUserDeleteMethodNegative(){
       	test.startTest();
        EC_Mulesoft_CDM_Staging__c usrAccountDelNegative11 =  EC_TestData.createUser_AccountStaging('2345','678');
        usrAccountDelNegative11.EC_Action__c = DELETEACTION;
        
        EC_Mulesoft_CDM_Staging__c usrAccountDelNegative1 =  EC_TestData.createUser_AccountStaging('3467','432');
        usrAccountDelNegative1.EC_Action__c = DELETEACTION;
        
        EC_Mulesoft_CDM_Staging__c  updAcc = new  EC_Mulesoft_CDM_Staging__c();
        updAcc.EC_Parent_Account_Number__c = CDMKEY4;
        updAcc.EC_Account_Key__c = CDMKEY3;
        updAcc.EC_Account_Name_English__c = 'Updated Account here';
        updAcc.EC_Account_Number__c = CDMKEY3;
        updAcc.EC_Partner_Function__c = SHIPTO;
        updAcc.EC_Account_Global_Business_Unit_Name__c = WATER;
        updAcc.EC_Account_Divisional_Business_Unit_Name__c = WATER;
        updAcc.EC_Source_Table__c = 'Account';
        updAcc.EC_Action__c = UPDATEACTION;
        insert  updAcc;

        EC_Mulesoft_CDM_Staging__c  updsoldAcc = new  EC_Mulesoft_CDM_Staging__c();
        updsoldAcc.EC_Account_Key__c = CDMKEY1;
        updsoldAcc.EC_Account_Name_English__c = 'Updated Account here';
        updsoldAcc.EC_Account_Number__c = CDMKEY1;
        updsoldAcc.EC_Partner_Function__c = SOLDTO;
        updsoldAcc.EC_Account_Global_Business_Unit_Name__c = INSTITUTIONAL;
        updsoldAcc.EC_Account_Divisional_Business_Unit_Name__c = 'XYZ';
        updsoldAcc.EC_Source_Table__c = 'Account';
        updsoldAcc.EC_Action__c = UPDATEACTION;
        insert  updsoldAcc;      
        
        List<EC_Mulesoft_CDM_Staging__c> lstScope = new List<EC_Mulesoft_CDM_Staging__c>();
        lstScope.add(usrAccountDelNegative1);
        lstScope.add(usrAccountDelNegative11);
        EC_StagingUtilities.userInsert(lstScope); 
        EC_StagingBatch obj = new EC_StagingBatch();
        obj.execute(null,lstScope);
        test.stopTest();
    } 
    
    public static testMethod void EC_StagingUserDeleteMethod(){
        EC_Mulesoft_CDM_Staging__c objTest =  EC_TestData.getAccStaging(CDMKEY1,INSTITUTIONAL,SOLDTO,Active);
        objTest.EC_Action__c = INSERTACTION;
        insert objTest;  

        EC_Mulesoft_CDM_Staging__c objTest2 = EC_TestData.getAccStaging(CDMKEY1,INSTITUTIONAL,SOLDTO,Active);    
        objTest2.EC_Action__c = UPDATEACTION;
        insert  objTest2;  

        // below list to test the duplicate update action on same record
        List<EC_Mulesoft_CDM_Staging__c> liststaging = new List<EC_Mulesoft_CDM_Staging__c>();
        EC_Mulesoft_CDM_Staging__c objTemp = EC_TestData.getAccStaging(CDMKEY1,INSTITUTIONAL,SOLDTO,Active);    
        objTemp.EC_Action__c = UPDATEACTION;
        EC_Mulesoft_CDM_Staging__c objTemp2 = EC_TestData.getAccStaging(CDMKEY1,WATER,SOLDTO,Active);    
        objTemp2.EC_Action__c = UPDATEACTION; 
        liststaging.add(objTemp);
        liststaging.add(objTemp2);   
        Insert  liststaging ;     

        EC_Mulesoft_CDM_Staging__c objTest3 = EC_TestData.getAccStaging(CDMKEY1,INSTITUTIONAL,SOLDTO,Active);    
        objTest3.EC_Action__c = DELETEACTION;
        insert  objTest3;     

        EC_Mulesoft_CDM_Staging__c shipInst =  EC_TestData.getAccStaging('2234407',INSTITUTIONAL,SHIPTO,Active);
        shipInst.EC_Action__c = INSERTACTION;
        //  insert shipInst;

        EC_Mulesoft_CDM_Staging__c  soldWater = EC_TestData.getAccStaging(CDMKEY2,WATER,SOLDTO,Active);       
        soldWater.EC_Action__c = INSERTACTION;     
        //   insert   soldWater;

        EC_Mulesoft_CDM_Staging__c  soldInst =   EC_TestData.getAccStaging('2234410',INSTITUTIONAL,SOLDTO,Active);
        soldInst.EC_Action__c = INSERTACTION;    
        //  insert soldInst;

        EC_Mulesoft_CDM_Staging__c  shipWater =   EC_TestData.getAccStaging(CDMKEY3,WATER,SHIPTO,Active);
        shipWater.EC_Action__c = INSERTACTION;    
        insert shipWater; 
        EC_Mulesoft_CDM_Staging__c  shipWaterUpdt =   EC_TestData.getAccStaging(CDMKEY3,WATER,SHIPTO,Active);
        shipWaterUpdt.EC_Action__c = UPDATEACTION;
        insert shipWaterUpdt;         

        EC_Mulesoft_CDM_Staging__c objTestDup =  EC_TestData.getAccStaging(CDMKEY1,INSTITUTIONAL,SOLDTO,Active);
        objTestDup.EC_Action__c = INSERTACTION;
        insert objTestDup;  

        // Below data is Used for Contact Insertion    
        EC_Mulesoft_CDM_Staging__c contactInsertExt =   EC_TestData.getUsrStaging(CDMKEY1,EMAIL,CUSTOMER);
        contactInsertExt.EC_Action__c = INSERTACTION;
        insert contactInsertExt;

        EC_Mulesoft_CDM_Staging__c contactInsertInt =   EC_TestData.getUsrStaging(CDMKEY2,EMAIL,EMPLOYEE);
        contactInsertInt.EC_Action__c = INSERTACTION;
        insert contactInsertInt; 

        EC_Mulesoft_CDM_Staging__c contactUpdateInt =   EC_TestData.getUsrStaging(CDMKEY2,EMAIL,EMPLOYEE);
        contactUpdateInt.EC_Action__c = UPDATEACTION;
        insert contactUpdateInt;

        EC_Mulesoft_CDM_Staging__c usrPermissionByr =  EC_TestData.createuserPermissionRecStaging(CDMKEY1,ECOBYRUSR);
        usrPermissionByr.EC_Action__c = INSERTACTION;
        insert  usrPermissionByr;

        EC_Mulesoft_CDM_Staging__c usrAccountstg =  EC_TestData.createUser_AccountStaging(CDMKEY1,CDMKEY3);
        usrAccountstg.EC_Action__c = INSERTACTION;
        insert  usrAccountstg; 

        EC_Mulesoft_CDM_Staging__c usrPermissionExtUser =  EC_TestData.createuserPermissionRecStaging(CDMKEY1,ECOBYRUSR);
        usrPermissionExtUser.EC_Action__c = INSERTACTION;
        insert  usrPermissionExtUser; 

        EC_Mulesoft_CDM_Staging__c usrPermissionDelte =  EC_TestData.createuserPermissionRecStaging(CDMKEY1,ECOBYRUSR);
        usrPermissionDelte.EC_Action__c = DELETEACTION;
        insert  usrPermissionDelte; 

        EC_Mulesoft_CDM_Staging__c contactDeleteInt =   EC_TestData.getUsrStaging(CDMKEY1,EMAIL,CUSTOMER);
        contactDeleteInt.EC_Action__c = DELETEACTION;
        insert contactDeleteInt; 
        
        EC_Mulesoft_CDM_Staging__c contactDeleteInt1 =   EC_TestData.getUsrStaging(CDMKEY2,EMAIL,EMPLOYEE);
        contactDeleteInt1.EC_Action__c = DELETEACTION;
        insert contactDeleteInt1; 
        
        EC_Mulesoft_CDM_Staging__c contactDeleteInt2 =   EC_TestData.getUsrStaging('22344208',EMAIL,EMPLOYEE);
        contactDeleteInt2.EC_Action__c = DELETEACTION;
        insert contactDeleteInt2; 

        EC_Mulesoft_CDM_Staging__c contactDeleteInt4 =   EC_TestData.getUsrStaging('',EMAIL,EMPLOYEE);
        contactDeleteInt4.EC_Action__c = DELETEACTION;
        insert contactDeleteInt4;

        EC_Mulesoft_CDM_Staging__c usrAccountDel =  EC_TestData.createUser_AccountStaging(CDMKEY1,CDMKEY3);
        usrAccountDel.EC_Action__c = DELETEACTION;
        insert  usrAccountDel;  
        
        List<EC_Mulesoft_CDM_Staging__c> lstScope = new List<EC_Mulesoft_CDM_Staging__c>();
        lstScope.add(contactUpdateInt);
        lstScope.add(contactDeleteInt);
        lstScope.add(usrPermissionByr);
        lstScope.add(usrPermissionExtUser);
        lstScope.add(usrPermissionDelte);
        lstScope.add(contactDeleteInt1);
        lstScope.add(contactDeleteInt2);
        lstScope.add(contactDeleteInt4);
        
        EC_StagingBatch obj = new EC_StagingBatch();
        obj.execute(null,lstScope);
        
        test.startTest();
        EC_StagingUtilities.userInsert(lstScope);
        EC_Mulesoft_CDM_Staging__c contactDeleteInt3 =   EC_TestData.getUsrStaging('22344208',EMAIL,EMPLOYEE);
        contactDeleteInt3.EC_Action__c = DELETEACTION;
        insert contactDeleteInt3; 
        
        List<EC_Mulesoft_CDM_Staging__c> lstScope1 = new List<EC_Mulesoft_CDM_Staging__c>();
        lstScope1.add(contactDeleteInt3);
        EC_StagingBatch obj1 = new EC_StagingBatch();
        obj1.execute(null,lstScope1);
        test.stopTest();
    }
}