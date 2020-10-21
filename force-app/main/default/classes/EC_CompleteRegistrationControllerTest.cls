@isTest
public class EC_CompleteRegistrationControllerTest {

    @testSetup 
    static void setup() {
    	EC_UserRegistrationTestDataFactory.insetCustomSettings();
    }

    // Sce-1: Case Status = None
	static testMethod void testWithoutCase() {
		
        String userEmail = 'dpUser1@testClass.com';
      	Test.startTest(); // Starts the scope of test
		EC_UserRegistrationTestDataFactory.updateAPILogger(EC_Constants.DIRECTORY_USER, false);
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER, 'registerUser_Sce1_200');
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES, 'domainProperties_Sce1_200');
		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        try {
			EC_CompleteRegistrationController.validateUser(userEmail,null);
        } catch (AuraHandledException urException) {
            System.assertNotEquals(null, urException);
        }

        Test.stopTest(); // Ends the scope of test
      
    }
    
    // Sce-2.1: Case Status = New, isLocalAllowed = true, isRegisteredDomain = true
	static testMethod void testWithAccountTypeAll() {

    	String userEmail = 'dpUser1@testClass.com';

        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'New', true);
        
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES, 'domainProperties_Sce1_200');

		Test.startTest();    // Starts the scope of test

        try {
	        EC_CompleteRegistrationController.validateUser(userEmail, null);
        } catch (AuraHandledException urException) {
            System.assertNotEquals(null, urException);
        }

        Test.stopTest();     // Ends the scope of test
      
    }
    
    // Sce-2.2: Case Status = New, isLocalAllowed = true, isRegisteredDomain = false
	static testMethod void testWithAccountTypeLocal() {

    	String userEmail = 'dpUser2@testClass.com';

        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'New', true);

		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES, 'domainProperties_Sce2_200');
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce1_200');
        
		Test.startTest();    // Starts the scope of test

        String jsonResult = EC_CompleteRegistrationController.validateUser(userEmail, null);
        System.assertNotEquals(null, jsonResult);
        
        Test.stopTest();     // Ends the scope of test
      
    }

    // Sce-2.3: Case Status = New, isLocalAllowed = false, isRegisteredDomain = true
	static testMethod void testWithAccountTypeFederated() {

    	String userEmail = 'dpUser3@testClass.com';

        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'New', true);
		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES, 'domainProperties_Sce3_200');
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce2_400');
        
		Test.startTest();    // Starts the scope of test

        String jsonResult = EC_CompleteRegistrationController.validateUser(userEmail,null);
        System.assertNotEquals(null, jsonResult);
        
        Test.stopTest();     // Ends the scope of test
      
    }

    // Sce-2.4: Case Status = New, isLocalAllowed = false, isRegisteredDomain = false
	static testMethod void testWithAccountTypeNone() {

    	String userEmail = 'dpUser4@testClass.com';

        if(System.Label.EC_Email_Extension != EC_Constants.PRODEMAILEXT) {
      		userEmail = userEmail + System.Label.EC_Email_Extension;
      	}

        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'New', true);
		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES, 'domainProperties_Sce4_200');
        
		Test.startTest();    // Starts the scope of test

        try {
        	EC_CompleteRegistrationController.validateUser(userEmail,null);
        } catch (AuraHandledException urException) {
            System.assertNotEquals(null, urException);
        }

        Test.stopTest();     // Ends the scope of test
      
    }
    
    // Sce-3: Case Status = Closed
	static testMethod void testWithCaseStatusClosed() {

   		String userEmail = 'dpUser1@testClass.com';

        Test.startTest();    // Starts the scope of test
        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'Closed', true);

        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER,'registerUser_Sce1_200');
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES,'domainProperties_Sce1_200');
		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());

        String jsonResult = EC_CompleteRegistrationController.validateUser(userEmail,null);
        System.assertNotEquals(null, jsonResult);
 
        Test.stopTest();     // Ends the scope of test

    }
    
    // Sce-4: Case Status = New, User Not Found
	static testMethod void testWithUserNotFoundOrActive() {

   		String userEmail = 'dpUser1@testClass.com';

        Test.startTest();    // Starts the scope of test
        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'New', false);

        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER,'registerUser_Sce1_200');
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES,'domainProperties_Sce1_200');
		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());

	    try {
	        EC_CompleteRegistrationController.validateUser(userEmail,null);
        } catch (AuraHandledException urException) {
            System.assertNotEquals(null, urException);
        }
    
        Test.stopTest();     // Ends the scope of test
    }

    // Sce-5: Invalid Case Status (Pending)
	static testMethod void testWithCaseStatusOther() {

   		String userEmail = 'dpUser1@testClass.com';

        Test.startTest();    // Starts the scope of test
        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'Pending', false);

        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER,'registerUser_Sce1_200');
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES,'domainProperties_Sce1_200');
		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());

	    try {
	        EC_CompleteRegistrationController.validateUser(userEmail, null);
        } catch (AuraHandledException urException) {
            System.assertNotEquals(null, urException);
        }
    
        Test.stopTest();     // Ends the scope of test
    }

    // Sce-6: Self-Register page Source = 1
	static testMethod void testWithConnectSource() {

   		String userEmail = 'dpUser1@testClass.com';

        Test.startTest();    // Starts the scope of test
        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'New', true);
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.REGISTER_USER,'registerUser_Sce1_200');
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES,'domainProperties_Sce1_200');
		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());

        String jsonResult = EC_CompleteRegistrationController.validateUser(userEmail, '1');
        System.assertNotEquals(null, jsonResult);
 
        Test.stopTest();     // Ends the scope of test
    }

    // Sce-7: Create Directory User - Positive 
    @isTest
    private static void testCreateDirectoryUser() {
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce1_200');
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);
		Test.startTest();
        String jsonResult = EC_CompleteRegistrationController.createDirectoryUser('user1@testClass.com','Local','jhon','smith');
        System.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }

    // Sce-8: Create Directory User - Negative 
    @isTest
    private static void testCreateDirectoryUserException() {

        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce1_200');
		EC_UserRegistrationTestDataFactory.updateAPILogger(EC_Constants.DIRECTORY_USER, false);

    	Test.startTest();
        
        try {
	        EC_CompleteRegistrationController.createDirectoryUser('user1@testClass.com','LocalAccount','jhon','smith');
        } catch (AuraHandledException urException) {
            System.assertNotEquals(null, urException);
        }
        
        Test.stopTest();
    }
    
    // Sce-9: Create Directory User - Wrong Custom Code 
    @isTest
    private static void testCreateDirectoryCustomCodeFailure() {
        Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());

        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce2_200');
        EC_UserRegistrationTestDataFactory.createCase('user1@testClass.com', 'New', true);

		Test.startTest();
        String jsonResult = EC_CompleteRegistrationController.createDirectoryUser('user1@testClass.com','Local','jhon','smith');
        System.assertNotEquals(null, jsonResult);
        Test.stopTest();
    }
    
    // Domain Properties - Wrong Custom Code 
	static testMethod void testValidateUserCustomCodeFailure() {

    	String userEmail = 'dpUser2@testClass.com';

        EC_UserRegistrationTestDataFactory.createCase(userEmail, 'New', true);

		Test.setMock(HttpCalloutMock.class, new EC_UserRegistrationCalloutMock());
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DOMAIN_PROPERTIES, 'domainProperties_Sce5_200');
        EC_UserRegistrationTestDataFactory.updateAPIEndPointURL(EC_Constants.DIRECTORY_USER, 'directoryUser_Sce1_200');
        
		Test.startTest();    // Starts the scope of test

        String jsonResult = EC_CompleteRegistrationController.validateUser(userEmail, null);
        System.assertNotEquals(null, jsonResult);
        
        Test.stopTest();     // Ends the scope of test
      
    }
    
}