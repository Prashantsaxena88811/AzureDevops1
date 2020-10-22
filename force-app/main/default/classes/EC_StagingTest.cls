@isTest
public class EC_StagingTest {

/***************************************************************************************************************************************
Method Name : testData
Description : TestSetup method for creating Accounts and Users
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/
    @testSetup
    static void testData(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test3@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EC_CDM_User__c = '28102019',
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
            testAccount.EC_Unique_Account_Number__c = 'CORP_2';
            Insert testAccount;



            List<RecordType> lstRecordTypeSoldTO =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_SoldTo];

            Account testSoldto = new Account();
            testSoldto.Name = 'TESTSOLD TO';
            testSoldto.EC_Account_Number__c = '15081947';
            testSoldto.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            testSoldto.EC_CDM_Account__c = '15081947';
            testSoldto.EC_Unique_Account_Number__c = 'NLC/15081947';
            Insert testSoldto;

            Account testSoldParent = new Account();
            testSoldParent.Name = 'TESTSOldParent';
            testSoldParent.EC_Account_Number__c = '15081950';
            testSoldParent.EC_CDM_Account__c = '15081950';
            testSoldParent.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            testSoldParent.EC_Unique_Account_Number__c = 'NLC/15081950';
            Insert testSoldParent;

            Account negativeAccount = new Account();
            negativeAccount.Name = 'TESTnegativeAccount';
            negativeAccount.EC_Account_Number__c = '150819501';
            negativeAccount.EC_CDM_Account__c = '150819501';
            negativeAccount.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            negativeAccount.EC_Unique_Account_Number__c = 'NLC/150819501';
            Insert negativeAccount;

            Account negativeAccount1 = new Account();
            negativeAccount1.Name = 'TESTnegativeAccount1';
            negativeAccount1.EC_Account_Number__c = '150819502';
            //negativeAccount.EC_CDM_Account__c = '150819501';
            negativeAccount1.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            negativeAccount1.EC_Unique_Account_Number__c = 'NLC/150819502';
            Insert negativeAccount1;

            Contact cntct = new Contact();
            cntct.LastName = 'testLasthere';
            cntct.EC_User_Type__c = EC_Constants.CUSTOMER;
            cntct.AccountId = testSoldto.Id;
            cntct.EC_CDM_Contact__c = '2234408';
            cntct.EC_SalesRep_User__c = portalUser.id; //2020
            Insert cntct ;

            Contact cntct1 = new Contact();
            cntct1.LastName = 'testLasthere1';
            cntct1.EC_User_Type__c = EC_Constants.CUSTOMER;
            cntct1.AccountId = negativeAccount.Id;
            // cntct1.EC_CDM_Contact__c = '2234408';
            Insert cntct1 ;
            AccountContactRelation accContRel = new AccountContactRelation(accountid = negativeAccount1.id, contactid = cntct1.id);
            EC_Mulesoft_CDM_Staging__c energysoldInsert =  EC_TestData.getAccStaging('1610201801','WATER','SOLDTO','A');
            energysoldInsert.EC_Action__c = 'InsertAction';
            energysoldInsert.EC_Account_Global_Business_Unit_Name__c = 'ENERGY';
            insert energysoldInsert;

            EC_Mulesoft_CDM_Staging__c papersoldInsert =  EC_TestData.getAccStaging('16102017001','WATER','SOLDTO','A');
            papersoldInsert.EC_Action__c = 'InsertAction';
            papersoldInsert.EC_Account_Global_Business_Unit_Name__c = 'PAPER';
            papersoldInsert.EC_Account_Number__c = '16102017001';
            papersoldInsert.EC_Status_Code__c = 'I';
            insert papersoldInsert;



        }
    }


/***************************************************************************************************************************************
Method Name : runUserActions
Description : Test the scenarios for (User Insert,Update,Delete) and User_Permission(Insert,Delete)
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/


    public static testMethod void runUserActions(){

        // Below data is Used for Contact Insertion
        EC_Mulesoft_CDM_Staging__c contactInsertExt =   EC_TestData.getUsrStaging('2234408','testemail33cust@ecolab.com','Employee');
        contactInsertExt.EC_User_Status_Code__c = 'A';
        contactInsertExt.EC_User_Type__c = EC_Constants.CUSTOMER;
        contactInsertExt.EC_Action__c = 'InsertAction';
        insert contactInsertExt;

        EC_Mulesoft_CDM_Staging__c contactInsertInt =   EC_TestData.getUsrStaging('2234409','testemail33emp@ecolab.com','Employee');
        contactInsertInt.EC_User_Status_Code__c = 'A';
        contactInsertExt.EC_User_Type__c = EC_Constants.CUSTOMER;
        contactInsertInt.EC_Action__c = 'InsertAction';
        insert contactInsertInt;
        
        EC_Mulesoft_CDM_Staging__c contactInsertInt1 =   EC_TestData.getUsrStaging('2234411','testemail33emp@ecolab.com','Employee');
        contactInsertInt1.EC_User_Status_Code__c = 'A';
        contactInsertInt1.EC_User_Type__c = EC_Constants.EMPLOYEE;
        contactInsertInt1.EC_Action__c = 'InsertAction';
        insert contactInsertInt1;

        EC_Mulesoft_CDM_Staging__c contactUpdateInt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Customer');
        contactUpdateInt.EC_Action__c = 'UpdateAction';
        contactInsertExt.EC_User_Type__c = EC_Constants.CUSTOMER;
        insert contactUpdateInt;

        EC_Mulesoft_CDM_Staging__c contactUpdateExt =   EC_TestData.getUsrStaging('2234409','testemail33cust@ecolab.com','Customer');
        contactUpdateExt.EC_User_Status_Code__c = 'A';
        contactUpdateExt.EC_Action__c = 'UpdateAction';
        contactInsertExt.EC_User_Type__c = EC_Constants.CUSTOMER;
        insert contactUpdateExt;


        EC_Mulesoft_CDM_Staging__c usrPermissionByr =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
        usrPermissionByr.EC_Action__c = 'InsertAction';
        insert  usrPermissionByr;

        EC_Mulesoft_CDM_Staging__c usrPermissionExtUser =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
        usrPermissionExtUser.EC_Action__c = 'InsertAction';
        insert  usrPermissionExtUser;

        EC_Mulesoft_CDM_Staging__c usrPermissionExtBasicUser =  EC_TestData.createuserPermissionRecStaging('2234409','ECOBSCUSR');
        usrPermissionExtBasicUser.EC_Action__c = 'InsertAction';
        insert  usrPermissionExtBasicUser;
        
        EC_Mulesoft_CDM_Staging__c usrPermissionExtBasicUser1 =  EC_TestData.createuserPermissionRecStaging('2234411','ECOBSCUSR');
        usrPermissionExtBasicUser1.EC_Action__c = 'InsertAction';
        insert  usrPermissionExtBasicUser1;
        
        EC_Mulesoft_CDM_Staging__c usrPermissionExtBasicUser2 =  EC_TestData.createuserPermissionRecStaging('2234412','ECOBSCUSR');
        usrPermissionExtBasicUser2.EC_Action__c = 'InsertAction';
        insert usrPermissionExtBasicUser2;

        EC_Mulesoft_CDM_Staging__c usrPermissionPyrExtUser =  EC_TestData.createuserPermissionRecStaging('2234409','ECOPYRUSR');
        usrPermissionPyrExtUser.EC_Action__c = 'InsertAction';
        insert  usrPermissionPyrExtUser;

        EC_Mulesoft_CDM_Staging__c usrPermissionViewPrcExtUser =  EC_TestData.createuserPermissionRecStaging('2234409','ECOVWPRCE');
        usrPermissionViewPrcExtUser.EC_Action__c = 'InsertAction';
        insert  usrPermissionViewPrcExtUser;

        EC_Mulesoft_CDM_Staging__c usrPermissionIntUser =  EC_TestData.createuserPermissionRecStaging('2234409','ECOBYRUSR');
        usrPermissionIntUser.EC_Action__c = 'InsertAction';
        insert  usrPermissionIntUser;

        EC_Mulesoft_CDM_Staging__c usrPermissionduplicate =  EC_TestData.createuserPermissionRecStaging('28102019','ECOBYRUSR');
        usrPermissionduplicate.EC_Action__c = 'InsertAction';
        insert  usrPermissionduplicate;

        EC_Mulesoft_CDM_Staging__c usrPermissionDelte =  EC_TestData.createuserPermissionRecStaging('2234408','ECOBYRUSR');
        usrPermissionDelte.EC_Action__c = 'DeleteAction';
        insert  usrPermissionDelte;

        EC_Mulesoft_CDM_Staging__c usrPermissionViewPrcExtDelete =  EC_TestData.createuserPermissionRecStaging('2234408','ECOVWPRCE');
        usrPermissionViewPrcExtDelete.EC_Action__c = 'InsertAction';
        insert  usrPermissionViewPrcExtDelete;

        EC_Mulesoft_CDM_Staging__c usrPermissionDelte1 =  EC_TestData.createuserPermissionRecStaging('2234412','ECOBYRUSR');
        usrPermissionDelte1.EC_Action__c = 'DeleteAction';
        insert  usrPermissionDelte1;



        EC_Mulesoft_CDM_Staging__c contactDeleteInt =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
        contactDeleteInt.EC_Action__c = 'DeleteAction';
        insert contactDeleteInt;
        
        EC_Mulesoft_CDM_Staging__c contactDeleteInt1 =   EC_TestData.getUsrStaging('2234408','testemail33@ecolab.com','Employee');
        contactDeleteInt1.EC_Action__c = 'DeleteAction';
        insert contactDeleteInt1;
        
        EC_Mulesoft_CDM_Staging__c contactInsertExt1 =   EC_TestData.getUsrStaging('2234406','testemail33emp@ecolab.com','Employee');
        contactInsertExt1.EC_User_Status_Code__c = 'A';
        contactInsertExt1.EC_User_Type__c = EC_Constants.EMPLOYEE;
        contactInsertExt1.EC_Action__c = 'InsertAction';
        insert contactInsertExt1;

        List<EC_Mulesoft_CDM_Staging__c> lstScope = new List<EC_Mulesoft_CDM_Staging__c>();
        lstScope.add(usrPermissionIntUser);
        lstScope.add(contactUpdateExt);
        lstScope.add(contactUpdateInt);
        lstScope.add(contactDeleteInt);
        lstScope.add(usrPermissionByr);
        lstScope.add(usrPermissionExtUser);
        lstScope.add(usrPermissionDelte);
        lstScope.add(usrPermissionExtBasicUser);
        lstScope.add(usrPermissionViewPrcExtUser);
        lstScope.add(usrPermissionPyrExtUser);
        lstScope.add(usrPermissionDelte1);
        lstScope.add(usrPermissionViewPrcExtDelete);
        lstScope.add(usrPermissionduplicate);
        lstScope.add(contactDeleteInt1);
        lstScope.add(contactInsertExt1);
        lstScope.add(contactInsertInt1);
        lstScope.add(usrPermissionExtBasicUser1);
        lstScope.add(usrPermissionExtBasicUser2);

        EC_StagingBatch obj = new EC_StagingBatch();
        obj.execute(null,lstScope);
    }


/***************************************************************************************************************************************
Method Name : runAccountActions
Description : Used to cover scenarios for Account(Insert,Delete) Scenarios
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static testmethod void runAccountActions(){

        test.startTest();
        // INSERT ACTIONS
        EC_Mulesoft_CDM_Staging__c contactInsertInt =   EC_TestData.getUsrStaging('27102019','stagusrAcc3@ecolab.com','Employee');
        contactInsertInt.EC_Action__c = 'InsertAction';
        insert contactInsertInt;

        EC_Mulesoft_CDM_Staging__c soldWatr =  EC_TestData.getAccStaging('223440801','WATER','SOLDTO','A');
        soldWatr.EC_Customer_Key__c = '2';
        soldWatr.EC_Account_Number__c = '223440801';
        soldWatr.EC_Action__c = 'InsertAction';
        insert soldWatr;

        EC_Mulesoft_CDM_Staging__c  soldInst =   EC_TestData.getAccStaging('2234410','INSTITUTIONAL','SOLDTO','A');
        soldInst.EC_Customer_Key__c = '2';
        soldInst.EC_Action__c = 'InsertAction';
        insert soldInst;

        EC_Mulesoft_CDM_Staging__c  shipWater =   EC_TestData.getAccStaging('2234412','WATER','SHIPTO','A');
        shipWater.EC_Action__c = 'InsertAction';
        insert shipWater;

        // This Record will be skipped as the parent account number does not exist
        EC_Mulesoft_CDM_Staging__c  skipAccRec =   EC_TestData.getAccStaging('2234412','WATER','SHIPTO','A');
        skipAccRec.EC_Parent_Account_Number__c = 'Sold223';
        skipAccRec.EC_Action__c = 'InsertAction';
        insert skipAccRec;

        EC_Mulesoft_CDM_Staging__c FnBInsert =  EC_TestData.getAccStaging('16102019','FOOD & BEVERAGE','SOLDTO','A');
        FnBInsert.EC_Customer_Key__c = '2';
        FnBInsert.EC_Action__c = 'InsertAction';
        insert FnBInsert;


        EC_Mulesoft_CDM_Staging__c energyInsert =  EC_TestData.getAccStaging('16102018','WATER','SHIPTO','A');
        energyInsert.EC_Action__c = 'InsertAction';
        energyInsert.EC_Parent_Account_Number__c = 'NLC/15081947';
        energyInsert.EC_Account_Global_Business_Unit_Name__c = 'ENERGY';
        insert energyInsert;

        EC_Mulesoft_CDM_Staging__c paperInsert =  EC_TestData.getAccStaging('161020170','WATER','SHIPTO','A');
        paperInsert.EC_Action__c = 'InsertAction';
        paperInsert.EC_Account_Global_Business_Unit_Name__c = 'PAPER';
        paperInsert.EC_Account_Number__c = '161020170';
        paperInsert.EC_Parent_Account_Number__c = 'NLC/15081947';
        paperInsert.EC_Status_Code__c = 'I';
        insert paperInsert;

        EC_Mulesoft_CDM_Staging__c paperdupl =  EC_TestData.getAccStaging('161020170','WATER','SHIPTO','A');
        paperdupl.EC_Account_Number__c = '161020170';
        paperdupl.EC_Parent_Account_Number__c = '';
        paperdupl.EC_Action__c = 'InsertAction';
        insert paperdupl;


        // Insert ContactAccount RelationShip
        EC_Mulesoft_CDM_Staging__c usrAccountDel =  EC_TestData.createUser_AccountStaging('223440801','27102019');
        usrAccountDel.EC_Action__c = 'InsertAction';
        insert  usrAccountDel;

        EC_Mulesoft_CDM_Staging__c shipInstUpd2 =  EC_TestData.getAccStaging('223441201','WATER','SHIPTO','A');
        shipInstUpd2.EC_Account_Name_English__c = 'ShipToupate2';
        shipInstUpd2.EC_Parent_Account_Number__c = '223440800';
        shipInstUpd2.EC_SalesOrg__c = '2002';
        shipInstUpd2.EC_Stage_Unique_AccNumber__c = 'NCL_SAP/223441201';
        shipInstUpd2.EC_Origination_Account_System_Code__c = 'NCL_SAP';
        shipInstUpd2.EC_Action__c = 'UpdateAction';
        insert shipInstUpd2;

        // DeleteAction
        EC_Mulesoft_CDM_Staging__c objTest3 = EC_TestData.getAccStaging('223440801','WATER','SOLDTO','A');
        objTest3.EC_Action__c = 'DeleteAction';
        insert  objTest3;

        /* EC_Mulesoft_CDM_Staging__c delDuplicate = EC_TestData.getAccStaging('223440801','WATER','SOLDTO','A');
        delDuplicate.EC_Action__c = 'DeleteAction';
        insert  delDuplicate; */

        test.stopTest();

    }
    /***************************************************************************************************************************************
Method Name : runAccUpdateActions
Description : Used to cover scenarios for Account(update) Scenarios
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/



    public static testmethod void runAccUpdateActions(){

        // Insert Action
        test.startTest();

        List<RecordType> lstRecordTypeSoldTO =  [SELECT id,DeveloperName from RecordType where Name = :EC_Constants.Sold_To];
        List<RecordType> lstRecordTypeShipTO =  [SELECT id,DeveloperName from RecordType where Name = :EC_Constants.Ship_To];

        EC_Mulesoft_CDM_Staging__c contactInsertInt =   EC_TestData.getUsrStaging('27102019','stagusrAccupd3@ecolab.com','Employee');
        contactInsertInt.EC_Action__c = 'InsertAction';
        insert contactInsertInt;
        
        List<ccrz__E_AccountGroup__c> accountGroup = [Select ID FROM ccrz__E_AccountGroup__c];
        Account testSoldto = new Account();
        testSoldto.Name = 'TESTSOLD TO';
        testSoldto.EC_Account_Number__c = '223660800';
        testSoldto.RecordTypeId = lstRecordTypeSoldTO[0].Id;
        testSoldto.ccrz__E_AccountGroup__c = accountGroup[0].id;
        testSoldto.EC_CDM_Account__c = '223660800';
        testSoldto.EC_Unique_Account_Number__c = 'NLC_SAP/223660800';
        Insert testSoldto;

        List<Account> accountList = new List<Account>();
        Account testShipTo = new Account();
        testShipTo.Name = 'TESTSHIP TO';
        testShipTo.EC_Account_Number__c = '223441200';
        testShipTo.parentId = testSoldto.Id;
        testShipTo.RecordTypeId = lstRecordTypeShipTO[0].Id;
        testShipTo.ccrz__E_AccountGroup__c = accountGroup[0].id;
        testShipTo.EC_CDM_Account__c = '223441200';
        testShipTo.EC_Unique_Account_Number__c = 'ECL_EBS/223441200';
        accountList.add(testShipTo);
        //Insert testShipTo;

        Account testShipToNew = new Account();
        testShipToNew.Name = 'TESTSHIP TO1';
        testShipToNew.EC_Account_Number__c = '223440900';
        testShipToNew.parentId = testSoldto.Id;
        testShipToNew.RecordTypeId = lstRecordTypeShipTO[0].Id;
        testShipToNew.ccrz__E_AccountGroup__c = accountGroup[0].id;
        testShipToNew.EC_CDM_Account__c = '223440900';
        testShipToNew.EC_Unique_Account_Number__c = 'NLC_SAP/223440900';
        accountList.add(testShipToNew);
        //Insert testShipToNew;
        //
        Database.insert(accountList);

        List<EC_Mulesoft_CDM_Staging__c> cdmStgList = new List<EC_Mulesoft_CDM_Staging__c>();
        EC_Mulesoft_CDM_Staging__c soldWatr =  EC_TestData.getAccStaging('223440800','WATER','SOLDTO','A');
        soldWatr.EC_Customer_Key__c = '2';
        soldWatr.EC_Account_Number__c = '223440800';
        soldWatr.EC_Parent_Account_Number__c = 'ECL_EBS/223441200';
        soldWatr.EC_Action__c = 'InsertAction';
        soldWatr.EC_SalesOrg__c = '2002';
        soldWatr.EC_Stage_Unique_AccNumber__c = 'NCL_SAP/223440800';
        soldWatr.EC_Origination_Account_System_Code__c = 'NCL_SAP';
        cdmStgList.add(soldWatr);
        //insert soldWatr;

        EC_Mulesoft_CDM_Staging__c soldInst =  EC_TestData.getAccStaging('2234408011','INSTITUTIONAL','SHIPTO','A');
        soldInst.EC_Customer_Key__c = '2';
        soldInst.EC_Account_Global_Business_Unit_Name__c = 'INSTITUTIONAL';
        soldInst.EC_Parent_Account_Number__c = 'ECL_EBS/223441200';
        soldInst.EC_Account_Number__c = '2234408011';
        soldInst.EC_SalesOrg__c = '1001';
        soldInst.EC_Stage_Unique_AccNumber__c = 'ECL_EBS/2234408011';
        soldInst.EC_Origination_Account_System_Code__c = 'ECL_EBS';
        soldInst.EC_Action__c = 'InsertAction';
        cdmStgList.add(soldInst);
        //insert soldInst;

        Contact cntct = new Contact();
        cntct.LastName = 'testLast';
        cntct.EC_User_Type__c = EC_Constants.CUSTOMER;
        cntct.AccountId = testSoldto.Id;
        cntct.EC_CDM_Contact__c = '150819123';
        Insert cntct ;

        EC_Mulesoft_CDM_Staging__c  shipWater =   EC_TestData.getAccStaging('223441200','WATER','SHIPTO','A');
        shipWater.EC_Action__c = 'InsertAction';
        cdmStgList.add(shipWater);
        //insert shipWater;
        
        // 2nd ShipWater account
        EC_Mulesoft_CDM_Staging__c  shipWater2 =   EC_TestData.getAccStaging('223441201','WATER','SHIPTO','A');
        shipWater2.EC_Action__c = 'InsertAction';
        shipWater.EC_Parent_Account_Number__c = 'ECL_EBS/2234408011';
        cdmStgList.add(shipWater2);
        //insert shipWater2;

        // Insert ContactAccount RelationShip
        EC_Mulesoft_CDM_Staging__c usrAccount =  EC_TestData.createUser_AccountStaging('223440800','27102019');
        usrAccount.EC_Action__c = 'InsertAction';
        cdmStgList.add(usrAccount);
        //insert  usrAccount;

        EC_Mulesoft_CDM_Staging__c usrAccount1 =  EC_TestData.createUser_AccountStaging('223660800','27102019');
        usrAccount1.EC_Action__c = 'InsertAction';
        cdmStgList.add(usrAccount1);
        //insert  usrAccount1;

        EC_Mulesoft_CDM_Staging__c usrAccount2 =  EC_TestData.createUser_AccountStaging('2234408011','27102019');
        usrAccount2.EC_Action__c = 'InsertAction';
        cdmStgList.add(usrAccount2);
        //insert  usrAccount2;

        AccountContactRelation accContRel = new AccountContactRelation(accountid = testSoldto.id, contactid = cntct.id);
      //  insert accContRel;
        AccountContactRelation accContRel4 = new AccountContactRelation(accountid = testShipTo.id, contactid = cntct.id);
        insert accContRel4;
        // Update Action

        EC_Mulesoft_CDM_Staging__c soldUpd = EC_TestData.getAccStaging('223440800','WATER','SOLDTO','A');
        soldUpd.EC_Account_Name_English__c = 'SoldToAccUpdated';
        soldUpd.EC_Action__c = 'UpdateAction';
        soldUpd.EC_Stage_Unique_AccNumber__c = 'NCL_SAP/223440800';
        soldUpd.EC_SalesOrg__c = '2002';
        soldUpd.EC_Origination_Account_System_Code__c = 'NCL_SAP';
        cdmStgList.add(soldUpd);
        //insert  soldUpd;

        EC_Mulesoft_CDM_Staging__c soldInstUpd = EC_TestData.getAccStaging('2234408011','INSTITUTIONAL','SOLDTO','A');
        soldInstUpd.EC_Account_Name_English__c = 'SoldToINSTAccUpdated';
        soldInstUpd.EC_Account_Global_Business_Unit_Name__c = EC_Constants.INSTITUTIONAL ;
        soldInstUpd.EC_Street_Address_1__c = 'Street1';
        soldInstUpd.EC_Parent_Account_Number__c = 'NLC/15081947';
        soldInstUpd.EC_Street_Address_2__c = 'Street2';
        soldInstUpd.EC_Street_Address_3__c = 'Celment St';
        soldInstUpd.EC_Street_Address_4__c = 'Block 4';
        soldInstUpd.EC_Stage_Unique_AccNumber__c = 'ECL_EBS/2234408011';
        soldInstUpd.EC_City__c = 'Boston';
        soldInstUpd.EC_Parent_Account_Key__c = '2';
        soldInstUpd.EC_SalesOrg__c = '1001';
        soldInstUpd.EC_Origination_Account_System_Code__c = 'ECL_EBS';
        soldInstUpd.EC_State_Province__c = 'CA';
        soldInstUpd.EC_Country_ISO3_Code__c = 'US';
        soldInstUpd.EC_Postal_Code__c = '454322';
        soldInstUpd.EC_Action__c = 'UpdateAction';
        cdmStgList.add(soldInstUpd);
        //insert  soldInstUpd;

        EC_Mulesoft_CDM_Staging__c shipInstUpd =  EC_TestData.getAccStaging('223441200','WATER','SHIPTO','A');
        shipInstUpd.EC_Account_Name_English__c = 'ShipToupate';
        shipInstUpd.EC_Parent_Account_Number__c = '223440800';
        shipInstUpd.EC_Account_Global_Business_Unit_Name__c = EC_Constants.FOODANDBEVERAGE;
        shipInstUpd.EC_Street_Address_1__c = 'Street1';
        shipInstUpd.EC_Street_Address_2__c = 'Street2';
        shipInstUpd.EC_Street_Address_3__c = 'Celment St';
        shipInstUpd.EC_Street_Address_4__c = 'Block 4';
        shipInstUpd.EC_City__c = 'Boston';
        shipInstUpd.EC_Parent_Account_Key__c = '2';
        shipInstUpd.EC_SalesOrg__c = '2002';
        shipInstUpd.EC_Stage_Unique_AccNumber__c = 'NCL_SAP/223441200';
        shipInstUpd.EC_Origination_Account_System_Code__c = 'NCL_SAP';
        shipInstUpd.EC_State_Province__c = 'CA';
        shipInstUpd.EC_Country_ISO3_Code__c = 'US';
        shipInstUpd.EC_Postal_Code__c = '454322';
        shipInstUpd.EC_Action__c = 'UpdateAction';
        cdmStgList.add(shipInstUpd);
        //insert shipInstUpd;

        Contact cntct3 = new Contact();
        cntct3.LastName = 'testLasthere';
        cntct3.AccountId = testShipTo.Id;
        cntct3.EC_User_Type__c = EC_Constants.CUSTOMER;
        cntct3.EC_CDM_Contact__c = '150878233';
        Insert cntct3;

        AccountContactRelation accContRel2 = new AccountContactRelation(accountid = testShipTo.id, contactid = cntct3.id);
      //  insert accContRel2;
        AccountContactRelation accContRel3 = new AccountContactRelation(accountid = testSoldto.id, contactid = cntct3.id);
        insert accContRel3;
        /* List<AccountContactRelation> accRelList = new List<AccountContactRelation>();
        accRelList.add(accContRel);
        accRelList.add(accContRel2);
        accRelList.add(accContRel3);
        accRelList.add(accContRel4);
        upsert accRelList; */
        EC_Mulesoft_CDM_Staging__c usrAccountDel =  EC_TestData.createUser_AccountStaging('223441201','15081950');
        usrAccountDel.EC_Action__c = 'DeleteAction';
        usrAccountDel.EC_Stage_Unique_AccNumber__c = '223441201';
        cdmStgList.add(usrAccountDel);
        //insert  usrAccountDel;

        EC_Mulesoft_CDM_Staging__c usrAccountDelDuplicate =  EC_TestData.createUser_AccountStaging('78990000','67780000');
        usrAccountDelDuplicate.EC_Action__c = 'DeleteAction';
        cdmStgList.add(usrAccountDelDuplicate);
        //insert  usrAccountDelDuplicate;

        EC_Mulesoft_CDM_Staging__c shipInstUpd2 =  EC_TestData.getAccStaging('223441201','WATER','SHIPTO','A');
        shipInstUpd2.EC_Account_Name_English__c = 'ShipToupate2';
        shipInstUpd2.EC_Parent_Account_Number__c = '223440800';
        shipInstUpd2.EC_SalesOrg__c = '2002';
        shipInstUpd2.EC_Stage_Unique_AccNumber__c = 'NCL_SAP/223441201';
        shipInstUpd2.EC_Origination_Account_System_Code__c = 'NCL_SAP';
        shipInstUpd2.EC_Action__c = 'UpdateAction';
        cdmStgList.add(shipInstUpd2);
        //insert shipInstUpd2;
        
        Database.insert(cdmStgList);

        Contact cntct4 = new Contact();
        cntct4.LastName = 'testLasthere';
        cntct4.EC_User_Type__c = EC_Constants.CUSTOMER;
        cntct4.AccountId = testShipTo.Id;
        cntct4.EC_CDM_Contact__c = '150228233';
        Insert cntct4;
        test.stopTest();
    }

/***************************************************************************************************************************************
Method Name : runUserAccActions
Description : Used to cover scenarios for UserAccount(Insert,Delete) Scenarios
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/


    public static testmethod void runUserAccActions(){
        test.startTest();

        EC_Mulesoft_CDM_Staging__c contactInsertInt =   EC_TestData.getUsrStaging('280911103','newStagAccUser3@ecolab.com','Employee');
        contactInsertInt.EC_Action__c = 'InsertAction';
        contactInsertInt.EC_User_Type__c = EC_Constants.CUSTOMER;
        insert contactInsertInt;

        EC_Mulesoft_CDM_Staging__c contactInsert2 =   EC_TestData.getUsrStaging('280911105','newStagAccUs33@ecolab.com','Employee');
        contactInsert2.EC_Action__c = 'InsertAction';
        contactInsert2.EC_User_Type__c = EC_Constants.CUSTOMER;
        insert contactInsert2;


        EC_Mulesoft_CDM_Staging__c soldWatr =  EC_TestData.getAccStaging('280966366','WATER','SOLDTO','A');
        soldWatr.EC_Customer_Key__c = '2';
        soldWatr.EC_Account_Number__c = '2234408012';
        soldWatr.EC_Action__c = 'InsertAction';
        insert soldWatr;

        EC_Mulesoft_CDM_Staging__c  shipWater =   EC_TestData.getAccStaging('2809777','WATER','SHIPTO','A');
        shipWater.EC_Parent_Account_Number__c = '15081947';
        shipWater.EC_Action__c = 'InsertAction';
        insert shipWater;

        EC_Mulesoft_CDM_Staging__c usrAccountstg =  EC_TestData.createUser_AccountStaging('2809777','280911105');
        usrAccountstg.EC_Action__c = 'InsertAction';
        insert  usrAccountstg;

        EC_Mulesoft_CDM_Staging__c usrAccountstgNegative1 =  EC_TestData.createUser_AccountStaging('','280911105');
        usrAccountstgNegative1.EC_Action__c = 'InsertAction';
        insert  usrAccountstgNegative1;
        EC_Mulesoft_CDM_Staging__c usrAccountstgNegative2 =  EC_TestData.createUser_AccountStaging('2809777','');
        usrAccountstgNegative2.EC_Action__c = 'InsertAction';
        insert  usrAccountstgNegative2;
        EC_Mulesoft_CDM_Staging__c usrAccountstgSoldto =  EC_TestData.createUser_AccountStaging('280966366','280911103');
        usrAccountstgSoldto.EC_Action__c = 'InsertAction';
        insert  usrAccountstgSoldto;

        EC_Mulesoft_CDM_Staging__c usrAccountstgSoldtoDup =  EC_TestData.createUser_AccountStaging('280966366','280911103');
        usrAccountstgSoldtoDup.EC_Action__c = 'InsertAction';
        insert  usrAccountstgSoldtoDup;

        EC_Mulesoft_CDM_Staging__c usrAccountstgSoldto2 =  EC_TestData.createUser_AccountStaging('280966366','280911198');
        usrAccountstgSoldto2.EC_Action__c = 'InsertAction';
        insert  usrAccountstgSoldto2;

        EC_Mulesoft_CDM_Staging__c usrAccountDelNegative =  EC_TestData.createUser_AccountStaging('150819501','150819501');
        usrAccountDelNegative.EC_Action__c = 'DeleteAction';
        insert  usrAccountDelNegative;

        EC_Mulesoft_CDM_Staging__c usrAccountDel =  EC_TestData.createUser_AccountStaging('280966366','280911103');
        usrAccountDel.EC_Action__c = 'DeleteAction';
        insert  usrAccountDel;


        EC_Mulesoft_CDM_Staging__c usrAccountDelDup =  EC_TestData.createUser_AccountStaging('280966366','280911103');
        usrAccountDelDup.EC_Action__c = 'DeleteAction';
        insert  usrAccountDelDup;

        EC_Mulesoft_CDM_Staging__c usrAccountDelDup2 =  EC_TestData.createUser_AccountStaging('1000','1000');
        usrAccountDelDup2.EC_Action__c = 'DeleteAction';
        insert  usrAccountDelDup2;

        EC_Mulesoft_CDM_Staging__c usrAccountDelShipto =  EC_TestData.createUser_AccountStaging('2809777','280911105');
        usrAccountDelShipto.EC_Action__c = 'DeleteAction';
        insert  usrAccountDelShipto;

        test.stopTest();
    }

    /***************************************************************************************************************************************
Method Name : runExceptionScenarios
Description : Used to cover scenarios for Exception
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/


    public static testmethod void runExceptionScenarios(){
        test.startTest();
        EC_Mulesoft_CDM_Staging__c soldWatr =  EC_TestData.getAccStaging('jlkjklj','WATER','SOLDTO','A');
        soldWatr.EC_Account_Name_English__c = '';
        soldWatr.EC_Action__c = 'InsertAction';
        insert soldWatr;

        EC_Mulesoft_CDM_Staging__c acc12 =  EC_TestData.getAccStaging('jlkjklj','WATER','','A');
        acc12.EC_Account_Name_English__c = '';
        acc12.EC_Action__c = 'InsertAction';
        insert acc12;


        EC_Mulesoft_CDM_Staging__c soldWatrInactive =  EC_TestData.getAccStaging('223229884','WATER','SOLDTO','A');
        soldWatrInactive.EC_Account_Number__c = '301020199';
        soldWatrInactive.EC_Action__c = 'InsertAction';
        soldWatrInactive.EC_Status_Code__c = 'I';
        insert soldWatrInactive;

        EC_Mulesoft_CDM_Staging__c soldWatrDup =  EC_TestData.getAccStaging('jlkjklj','WATER','SOLDTO','A');
        soldWatrDup.EC_Account_Number__c = '301020199';
        soldWatrDup.EC_Account_Name_English__c = '';
        soldWatrDup.EC_Action__c = 'InsertAction';
        insert soldWatrDup;

        EC_Mulesoft_CDM_Staging__c sHipAccount =  EC_TestData.getAccStaging('jlkjklj',EC_Constants.INSTITUTIONAL,'SHIPTO','A');
        sHipAccount.EC_Account_Name_English__c = 'NEW';
        sHipAccount.EC_Action__c = 'InsertAction';
        insert sHipAccount;

        EC_Mulesoft_CDM_Staging__c sHipAccount1 =  EC_TestData.getAccStaging('jlkjklj',EC_Constants.INSTITUTIONAL,'SHIPTO','A');
        sHipAccount1.EC_Account_Name_English__c = '';
        sHipAccount1.EC_Action__c = 'InsertAction';
        insert sHipAccount1;

        EC_Mulesoft_CDM_Staging__c sHipAccount2 =  EC_TestData.getAccStaging('223229884',EC_Constants.INSTITUTIONAL,'SHIPTO','A');
        sHipAccount2.EC_Account_Number__c = '301020199';
        sHipAccount2.EC_Action__c = 'InsertAction';
        sHipAccount2.EC_Status_Code__c = 'I';
        insert sHipAccount2;

        EC_Mulesoft_CDM_Staging__c accDel =  EC_TestData.getAccStaging('elephant','WATER','SOLDTO','A');
        accDel.EC_Action__c = 'DeleteAction';
        insert accDel;

        EC_Mulesoft_CDM_Staging__c accDel1 =  EC_TestData.getAccStaging('elephant',EC_Constants.INSTITUTIONAL,'SHIPTO','A');
        accDel1.EC_Action__c = 'DeleteAction';
        insert accDel1;

        EC_Mulesoft_CDM_Staging__c accDel2 =  EC_TestData.getAccStaging('',EC_Constants.INSTITUTIONAL,'SHIPTO','A');
        accDel2.EC_Action__c = 'DeleteAction';
        insert accDel2;

        List<EC_Mulesoft_CDM_Staging__c> lstScope = new List<EC_Mulesoft_CDM_Staging__c>();
        lstScope.add(soldWatr);
        EC_StagingBatch obj = new EC_StagingBatch();
        obj.execute(null,lstScope);

        List<EC_Mulesoft_CDM_Staging__c> lstScope1 = new List<EC_Mulesoft_CDM_Staging__c>();
        lstScope1.add(sHipAccount);
        EC_StagingBatch obj1 = new EC_StagingBatch();
        obj1.execute(null,lstScope1);

        test.stopTest();
    }
}