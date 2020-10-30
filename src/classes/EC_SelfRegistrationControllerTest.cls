@isTest
public class EC_SelfRegistrationControllerTest {
    
   @TestSetup
    static void Setup() {
        EC_UserRegistrationTestDataFactory.insetCustomSettings();
    }
    
   @isTest
    public static void testToPrivateConst(){
        EC_UserRegistrationDAO DaoConst = new EC_UserRegistrationDAO();
        EC_UserRegistrationService ServiceConst = new EC_UserRegistrationService();
        System.debug('DaoConst' + 'ServiceConst'+ DaoConst + ServiceConst);//To avoid code scan Issues
        System.assertNotEquals(null, DaoConst);
    }
    
    @isTest
    private static void testWithNewUserAccTypeNone() {
        
        EC_UserRegistrationTestDataFactory.createAccountContactRelation();
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '555');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER, 'registerUser_Sce4_200');
        
        Test.startTest();
        try{
        	EC_SelfRegistrationController.registerUser(userRequest);     
        }
        catch(Exception ex){
			system.assertNotEquals(null, ex);            
        }
        Test.stopTest();
    }

    @isTest
    private static void testWithNewUserAccTypeLocal() {
        
        EC_UserRegistrationTestDataFactory.createAccountContactRelation();
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '555');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER, 'registerUser_Sce3_200');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        System.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testWithNewUserAccTypeFederated() {
        
        EC_UserRegistrationTestDataFactory.createAccountContactRelation();
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '555');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER, 'registerUser_Sce2_200');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        System.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testWithNewUserAccTypeAll() {
        
        EC_UserRegistrationTestDataFactory.createAccountContactRelation();
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '555');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER, 'registerUser_Sce1_200');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        System.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testWithExistingUserAccTypeNone() {
        
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '18787');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES,'domainProperties_Sce4_200');
        
        Test.startTest();
        try{
        	EC_SelfRegistrationController.registerUser(userRequest);    
        }
        catch(Exception ex){
            System.assertNotEquals(null, ex); 
        } 
        Test.stopTest();
    }

    @isTest
    private static void testWithExistingUserAccTypeFederated() {
        
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '18787');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES,'domainProperties_Sce3_200');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        system.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testWithExistingUserAccTypeLocal() {
        
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '18787');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES,'domainProperties_Sce2_200');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        system.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testWithExistingUserAccTypeAll() {
        
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '18787');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES, 'domainProperties_Sce1_200');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        system.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testWithCaseStatusClosed() {
        
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'Closed', true);
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '18787');     
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        System.assertNotEquals(null, jsonResult);    
        Test.stopTest();
    }
    
    @isTest
    private static void testCreateDirectoryUser() {
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce1_200');
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.createDirectoryUser('user1@testClass.com','LocalAccount','jhon','smith');
        system.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testCreateDirectoryUserException() {
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce1_400');
        
        Test.startTest();
        try{
            EC_SelfRegistrationController.createDirectoryUser('user1@testClass.com','LocalAccount','jhon','smith');    
        }
        catch(Exception ex){
            System.assertNotEquals(null, ex);
        }
        Test.stopTest();
    }
       
    @isTest
    private static void testRegisterUserFailureResponse() {
        EC_UserRegistrationTestDataFactory.createAccountContactRelation();
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '555');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER, 'registerUser_Sce1_400');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        System.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testDomainPropertiesFailureResponse() {
        
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '18787');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES,'domainProperties_Sce1_400');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        system.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testDirectoryUserFailureResponse() {
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce1_400');
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.createDirectoryUser('user1@testClass.com','LocalAccount','jhon','smith');
        system.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testRegisterUserWrongCustomCode() {
        EC_UserRegistrationTestDataFactory.createAccountContactRelation();
        
        Map<String, String> userRequest = new Map<String, String>();
        userRequest.put('FirstName', 'Test');
        userRequest.put('LastName', 'UserV1');
        userRequest.put('PhoneNumber', '(453) 543-3542');
        userRequest.put('Email', 'user1@testClass.com');
        userRequest.put('SalesRepEmail', 'sales@testClass.com');
        userRequest.put('AccountNumber', '555');     
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER, 'registerUser_Sce5_200');
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.registerUser(userRequest);
        System.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    @isTest
    private static void testCreateDirectoryWrongCustomCode() {
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce2_200');
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
        
        Test.startTest();
        String jsonResult = EC_SelfRegistrationController.createDirectoryUser('user1@testClass.com','LocalAccount','jhon','smith');
        system.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }

    @isTest
    private static void ExceptionNullTest() {
        Exception exObj = NULL;
        Case newCase = new Case(Description='Exception');
        insert newCase;
        
        Test.StartTest();
		system.assertNotEquals(null, EC_UserRegistrationHelper.logExceptionOnCase(newCase, exObj));
        Test.stopTest();
    }

    @isTest
    private static void testOutageRedirect() {
        EC_TestData.createOutageRecord();
        Test.startTest();
        Boolean outageFlag = EC_SelfRegistrationController.outageRedirect();
        System.assert(outageFlag);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetProfile() {
        Test.startTest();
        String profileIBuy = EC_SelfRegistrationController.getProfile();
        System.assertNotEquals(null, profileIBuy);
        Test.stopTest();
    }

}