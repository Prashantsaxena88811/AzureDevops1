@isTest
public class EC_PowerBIControllerTest {
    private static final string CUSTOMER = 'Customer';
    private static final string ACTIVE = 'Active';
    private static final string SHIPTO = 'Ship To';

    @TestSetup
    static void dataSetup() {
        EC_TestData.setupTestUser();

        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];
        
        system.runas(thisUser) {    
            Account pestAccount = new Account(Name = 'Pest Account',
											     OwnerId                 = UserInfo.getUserId(),
											     Type                    = CUSTOMER,
											     EC_Status__c            = ACTIVE,
											     EC_Account_Number__c    = '324988',
												 EC_Division__c 		 = 'PEST',
											     EC_CDM_Account__c       = '12345',
											     Phone                   = '8976453786',
											     recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SHIPTO).getRecordTypeId(),
											     ShippingStreet          = '',
											     ShippingCity            = '',
											     ShippingState           = '',
											     ShippingCountry         = '',
                                                 ShippingPostalCode      = '');
            insert pestAccount;
            
            AccountContactRelation accContRec = new AccountContactRelation(AccountId = pestAccount.id, ContactId = thisUser.contactId, Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE);
			insert accContRec;

            OAuthApp_pbi__c PBIOAuth = new OAuthApp_pbi__c();
            PBIOAuth.Name = 'PowerBI Final';
            PBIOAuth.Access_Token_URL__c = 'https://test.salesforce.com/oauth2/token';
            PBIOAuth.Authorization_URL__c = 'https://test.salesforce.com/oauth2/authorize';
            PBIOAuth.BaseTokenURL__c = 'https://test.powerbi.com/v1.0/myorg/groups/';
            PBIOAuth.Client_Id__c = '3dd7db0c-f80e-44d5-9360-8f5614cca22b';
            PBIOAuth.Client_Secret__c = 'btE-7tb8X6EOn6fw1B.m098~G~jNxMdSkP';
            PBIOAuth.Object_Id__c = '2b748971-d557-498c-86f9-babfe217a5a5';
            PBIOAuth.Resource_URI__c = 'https://test.windows.in/powerbi/api';
            PBIOAuth.Grant_Type__c = 'credentials';            
            insert PBIOAuth; 
            
            List<EC_LogsEnabler__c> PBILogs = new List<EC_LogsEnabler__c>();
            EC_LogsEnabler__c OAuthSetting = new EC_LogsEnabler__c();
            OAuthSetting.Name = 'PBI_OAuthToken';
            OAuthSetting.EC_LogsEnabled__c = true;
            PBILogs.add(OAuthSetting);
            
            EC_LogsEnabler__c DataSetSetting = new EC_LogsEnabler__c();
            DataSetSetting.Name = 'PBI_DataSet';
            DataSetSetting.EC_LogsEnabled__c = true;
            PBILogs.add(DataSetSetting);
            
            EC_LogsEnabler__c EmbedSetting = new EC_LogsEnabler__c();
            EmbedSetting.Name = 'PBI_EmbedToken';
            EmbedSetting.EC_LogsEnabled__c = true;
            PBILogs.add(EmbedSetting);
            
            insert PBILogs;
            
            EC_Custom_URL_Settings__c PBIMS = new EC_Custom_URL_Settings__c();
            PBIMS.Name = 'Microsoft OAuth Token';
            PBIMS.custom_url__c = 'https://test.online.net/oauth2/token';
            insert PBIMS;
        }
    }
    
    @IsTest
    static void OAuth_Positive() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];
        
        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIOAuthToken_V1'));

        Test.startTest();
        System.runAs(thisUser){
            String response = EC_PowerBIController.OAuthTokenClientCredentials();
            System.assertNotEquals(null, response);
        }
        Test.stopTest();
    }

    @IsTest
    static void OAuth_Negative() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];
        
        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIOAuthToken_V2'));

        Test.startTest();
        System.runAs(thisUser){
            String response = EC_PowerBIController.OAuthTokenClientCredentials();
            system.assertNotEquals(null, response);
        }
        Test.stopTest();
    }

    @IsTest
    static void OAuth_Exception() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];
        
        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIOAuthToken_V3'));

        Test.startTest();
        System.runAs(thisUser){
            try {
                EC_PowerBIController.OAuthTokenClientCredentials();
            }
            catch(Exception ex) {
                system.assertNotEquals(null, ex); 
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void DataSet_Sce1() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        String clientCredaccessToken = '09824hfjhf9324f1sfksfdmfnkdsfs2';
        String groupId = '398535358-31djfhfksfslfkj4o';
        String reportId = '9874294234hj6esjfsfjhf499i4-fisf';
        String datasetId = '98-2rj2r284-2ei2e-231ie20932483';
        String role = 'UserAccess';

        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIDataSet_V1'));

        Test.startTest();
        System.runAs(thisUser){
            String response = EC_PowerBIController.getDataSet(clientCredaccessToken, groupId, reportId, datasetId, role);
            System.assertNotEquals(null, response);
        }
        Test.stopTest();
    }

    @IsTest
    static void DataSet_Sce2() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        String clientCredaccessToken = '09824hfjhf93243fsfksfdmfnkdsfs2';
        String groupId = '398535358-33djfhfksfslfkj4o';
        String reportId = '9874294234hjesjfs5fjhf499i4-fisf';
        String datasetId = '98-2rj2r284-2ei2e-23i5e20932483';
        String role = 'SingleSite';

        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIDataSet_V2'));

        Test.startTest();
        System.runAs(thisUser){
            String response = EC_PowerBIController.getDataSet(clientCredaccessToken, groupId, reportId, datasetId, role);
            System.assertNotEquals(null, response);
        }
        Test.stopTest();
    }

    @IsTest
    static void DataSet_Sce3() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        String clientCredaccessToken = '09824hfjhf93624fsfksfdmfnkdsfs2';
        String groupId = '398535358-34djfhfksfslfkj4o';
        String reportId = '9874294234hjesjf3sfjhf499i4-fisf';
        String datasetId = '98-2rj2r284-2ei2e-23ie260932483';
        String role = 'MultiSite';

        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIDataSet_V3'));

        Test.startTest();
        System.runAs(thisUser){
            String response = EC_PowerBIController.getDataSet(clientCredaccessToken, groupId, reportId, datasetId, role);
            System.assertNotEquals(null, response);
        }
        Test.stopTest();
    }

    @IsTest
    static void DataSet_Sce4() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        String clientCredaccessToken = '09824hfjhf93247fsfksfdmfnkdsfs2';
        String groupId = '398535358-3d6jfhfksfslfkj4o';
        String reportId = '9874294234hj7esjfsfjhf499i4-fisf';
        String datasetId = '98-2rj2r284-2ei2e-23ie120932483';
        String role = 'UserAccess';

        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIDataSet_V4'));

        Test.startTest();
        System.runAs(thisUser){
            String response = EC_PowerBIController.getDataSet(clientCredaccessToken, groupId, reportId, datasetId, role);
            System.assertNotEquals(null, response);
        }
        Test.stopTest();
    }

    @IsTest
    static void DataSet_Exception() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];
        thisUser.User_Type__c = 'Internal';
        Update thisUser;

        String clientCredaccessToken = '09824hfjhf9324fsfksfd8mfnkdsfs2';
        String groupId = '398535358-3d8jfhfksfslfkj4o';
        String reportId = '9874294234hje8sjfsfjhf499i4-fisf';
        String datasetId = '98-2rj2r284-2ei2e-23ie20932483';
        String role = 'UserAccess';

        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIDataSet_V5'));

        Test.startTest();
        System.runAs(thisUser){
            try{
                EC_PowerBIController.getDataSet(clientCredaccessToken, groupId, reportId, datasetId, role);
            }
            catch(Exception ex) {
                system.assertNotEquals(null, ex);
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void EmbedToken_Positive() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        String clientCredaccessToken = '09824hfjhf93124fsfksfdmfnkdsfs2';
        String groupId = '398535358-3dj4fhfksfslfkj4o';
        String reportId = '9874294234hjesjf9sfjhf499i4-fisf';
        String requestBody = '{"testFake": "FakeResponse"}';
        
        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIEmbedToken_V1'));

        Test.startTest();
        System.runAs(thisUser){
            String response = EC_PowerBIController.getPowerBIEmbedToken(clientCredaccessToken, groupId, reportId, requestBody);
            System.assertNotEquals(null, response);
        }
        Test.stopTest();
    }

    @IsTest
    static void EmbedToken_Negative() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        String clientCredaccessToken = '09824hfj1hf9324fsfksfdmfnkdsfs2';
        String groupId = '398535358-3djfhf6ksfslfkj4o';
        String reportId = '9874294234hjesjfs2fjhf499i4-fisf';
        String requestBody = '{"testFake": "FakeResponse"}';
        
        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIEmbedToken_V2'));

        Test.startTest();
        System.runAs(thisUser){
            String response = EC_PowerBIController.getPowerBIEmbedToken(clientCredaccessToken, groupId, reportId, requestBody);
            System.assertNotEquals(null, response);
        }
        Test.stopTest();
    }

    @IsTest
    static void EmbedToken_Exception() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        String clientCredaccessToken = '09824hfjhf9324fsfksfdmfnkdsfs2';
        String groupId = '398535358-3djfhfksf8slfkj4o';
        String reportId = '9874294234hjesjfsfjhf499i4-fisf';
        String requestBody = '{"testFake": "FakeResponse"}';
        
        Test.setMock(HttpCalloutMock.class, new EC_PowerBICalloutMock('PBIEmbedToken_V3'));

        Test.startTest();
        System.runAs(thisUser) {
            try {
                EC_PowerBIController.getPowerBIEmbedToken(clientCredaccessToken, groupId, reportId, requestBody);
            }
            catch(Exception ex) {
                system.assertNotEquals(null, ex);
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void userDashboards_PESTSingle() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        Test.startTest();
        System.runAs(thisUser){
            try {
                PermissionSet INSTPerm = [Select Id from PermissionSet WHERE Name = 'EC_PESTPI'];
                PermissionSetAssignment assignPerm = new PermissionSetAssignment(AssigneeId = thisUser.Id,
                PermissionSetId = INSTPerm.Id);
                insert assignPerm;

                Integer permCheck = [SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId = :thisUser.Id AND PermissionSet.Name = 'EC_PESTPI'];
                System.assertEquals(1, permCheck);

                EC_PowerBIController.getUserDashboards();
            }
            catch(Exception ex) {
                System.assertNotEquals(null, ex);
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void userDashboards_INSTMultiple() {
        User thisUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];

        PermissionSet INSTPerm = [Select Id from PermissionSet WHERE Name = 'EC_INSTRRDB'];
        PermissionSetAssignment assignPerm = new PermissionSetAssignment(AssigneeId = thisUser.Id,
        PermissionSetId = INSTPerm.Id);
        insert assignPerm; 

        Test.startTest();
        System.runAs(thisUser){
            try {
                List<Account> lstAccounts = new List<Account>();
                List<AccountContactRelation> lstAccRels = new List<AccountContactRelation>();
                Account acc_One = new Account(Name = 'INST Account 1',
                                                        OwnerId                 = UserInfo.getUserId(),
                                                        Type                    = CUSTOMER,
                                                        EC_Status__c            = ACTIVE,
                                                        EC_Account_Number__c    = 'INSTACC-1',
                                                        EC_Division__c 		 = 'INSTITUTIONAL',
                                                        EC_CDM_Account__c       = 'INSTACC-1',
                                                        Phone                   = '89764553786',
                                                        recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SHIPTO).getRecordTypeId(),
                                                        ShippingStreet          = '',
                                                        ShippingCity            = '',
                                                        ShippingState           = '',
                                                        ShippingCountry         = '',
                                                        ShippingPostalCode      = '');
                lstAccounts.add(acc_One);

                Account acc_Two = new Account(Name = 'INST Account 2',
                                                        OwnerId                 = UserInfo.getUserId(),
                                                        Type                    = CUSTOMER,
                                                        EC_Status__c            = ACTIVE,
                                                        EC_Account_Number__c    = 'INSTACC-2',
                                                        EC_Division__c 		 = 'INSTITUTIONAL',
                                                        EC_CDM_Account__c       = 'INSTACC-2',
                                                        Phone                   = '8976213786',
                                                        recordtypeid            = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SHIPTO).getRecordTypeId(),
                                                        ShippingStreet          = '',
                                                        ShippingCity            = '',
                                                        ShippingState           = '',
                                                        ShippingCountry         = '',
                                                        ShippingPostalCode      = '');
                lstAccounts.add(acc_Two);
                insert lstAccounts;

                AccountContactRelation accContRec1 = new AccountContactRelation(AccountId = acc_One.Id, ContactId = thisUser.contactId);
                lstAccRels.add(accContRec1);
                
                AccountContactRelation accContRec2= new AccountContactRelation(AccountId = acc_Two.Id, ContactId = thisUser.contactId);
                lstAccRels.add(accContRec2);
                insert lstAccRels;

                EC_PowerBIController.getUserDashboards();

                List<AccountContactRelation> lstAccContRel = new List<AccountContactRelation>();
                lstAccContRel = [SELECT AccountId FROM AccountContactRelation WHERE account.Recordtype.name= :SHIPTO AND contactId =: thisUser.contactId];
                System.assertEquals(3, lstAccContRel.size());
            }
            catch(Exception ex) {
                System.assertNotEquals(null, ex);
            }
        }
        Test.stopTest();
    }
    
}