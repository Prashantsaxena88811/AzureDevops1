/*
* Class Name	: EC_UserRegistrationHelper
* Description	: This class contains the helper methods used by User Registration Controllers.
				  1) SelfRegisterController 2) CompleteRegistrationController
*/

public class EC_UserRegistrationHelper {
    
    //This is private constructor to restrict object creation. All the methods are static
    private EC_UserRegistrationHelper() {}

   /*
    * Method Name	: registerNewUser
    * Description	: This method validates the Account and registers user in CDM.
    * Request 		: RegisterUser DTO, user submitted values from Registration page.
    * Response		: RegPageResponse DTO, response values returned back to Registration page.
    */
  	public static EC_UserRegistrationDTO.RegPageResponse registerNewUser(EC_UserRegistrationDTO.RegisterUser rUser) {
		
		System.debug('>>> EC_UserRegistrationHelper.registerNewUser(): ' + rUser);
        
		EC_UserRegistrationDTO.RegPageResponse rpResponse = new EC_UserRegistrationDTO.RegPageResponse();
		
		rpResponse.firstName = rUser.firstName;
		rpResponse.lastName = ruser.lastName;
		
        EC_UserRegistrationDTO.RegisterUserRequest ruRequest = new EC_UserRegistrationDTO.RegisterUserRequest(
                                                                rUser.firstName, rUser.lastName, rUser.phoneNumber, 
                                                                rUser.userEmail, rUser.accountNo, 
                                                                rUser.salesRepEmail, 
                                                                EC_Constants.SOURCESYSTEMCODE);

        EC_UserRegistrationDTO.RegisterUserResponse ruResponse = EC_UserRegistrationService.registerUser(ruRequest);
        
		rpResponse.status = ruResponse.responseCode;

        // Get allowed account type(s) for user
        rpResponse.accountType = getAccountTypesAllowedForUser(ruResponse.isLocalAllowed, 
                                                               ruResponse.isRegisteredDomain);
        
        // Create Contact, User and Case records
        Case objCase = EC_UserRegistrationDAO.createExtUserAndCase(rUser, ruResponse);
        
        rpResponse.caseStatus = objCase.Status;
        rpResponse.objCase = objCase;

        System.debug('<<< EC_UserRegistrationHelper.registerNewUser(): ' + rpResponse);
		
		return rpResponse;
	}

   /*
    * Method Name	: registerExistingUser
    * Description	: This method validates the User and completes the registration.
    * Request 		: RegisterUser DTO, user submitted values from Registration page.
    * Response		: RegPageResponse DTO, response values returned back to Registration page.
    */  
	public static EC_UserRegistrationDTO.RegPageResponse registerExistingUser(String userEmail, Case objCase) {

        System.debug('>>> EC_UserRegistrationHelper.registerExistingUser(): ' + userEmail + ',' + objCase);
                                                                                    
		EC_UserRegistrationDTO.RegPageResponse rpResponse = new EC_UserRegistrationDTO.RegPageResponse();
	
	    rpResponse.firstName = objCase.Contact.FirstName;
        rpResponse.lastName = objCase.Contact.LastName;
        rpResponse.caseStatus = EC_Constants.CASE_STATUS_NEW;
		
        // Validate the User
        User objUser = EC_UserRegistrationDAO.isValidUser(userEmail);

		if(objUser != null) {
			rpResponse.status = EC_Constants.SUCCESS_RESP_CODE;
			rpResponse.accountType = getAccountTypesAllowedForUser(userEmail);     
		} else {
            throw new EC_UserRegistrationException(EC_Constants.ERROR_USER_NOT_FOUND_CODE);
		}
                                                                                    
        System.debug('<<< EC_UserRegistrationHelper.registerExistingUser(): RegPageResponse ' + rpResponse);
		
		return rpResponse;
	}

   /*
    * Method Name	: getAccountTypesAllowedForUser
    * Description	: This method returns the allowed account type by invoking the domain properties API.
    * Request 		: User email.
    * Response		: Response code, Account type
    */  
    public static String getAccountTypesAllowedForUser(String userEmail) {

        System.debug('>>> EC_UserRegistrationHelper.getAccountTypesAllowedForUser(): ' + userEmail);
        
        // Get domain properties
		EC_UserRegistrationDTO.DomainPropertiesResponse dpResponse = 
										EC_UserRegistrationService.getDomainProperties(userEmail);

        String accountType = getAccountTypesAllowedForUser(dpResponse.isLocalAllowed, dpResponse.isRegisteredDomain);

        System.debug('<<< EC_UserRegistrationHelper.getAccountTypesAllowedForUser(): ' + accountType);

		return accountType;
	}
    
   /*
    * Method Name	: getAccountTypesAllowedForUser
    * Description	: This method returns the account type allowed.
    * Request 		: isLocalAllowed, isRegisteredDomain
    * Response		: Account type
    */
    public static String getAccountTypesAllowedForUser(Boolean isLocalAllowed, Boolean isRegisteredDomain) {

        System.debug('>>> EC_UserRegistrationHelper.getAccountTypesAllowedForUser(): ' + isLocalAllowed + ',' + isRegisteredDomain);

        String accountType = null;
        
        if(isLocalAllowed && isRegisteredDomain) {
            accountType = EC_Constants.ACCOUNT_TYPE_ALL;
        } else if(isLocalAllowed && !isRegisteredDomain) {
            accountType = EC_Constants.ACCOUNT_TYPE_LOCAL;
        } else if(!isLocalAllowed && isRegisteredDomain) {
            accountType = EC_Constants.ACCOUNT_TYPE_FEDERATED;
        } else {
            // Throw custom exception if account type is None
            throw new EC_UserRegistrationException(EC_Constants.ERROR_DOMAIN_PROPERTIES_CODE);
        }

        System.debug('<<< EC_UserRegistrationHelper.getAccountTypesAllowedForUser(): ' + accountType);

        return accountType;
	}
    
    public static String logExceptionOnCase(Case objCase, Exception objException) {
        
        System.debug('>>> EC_UserRegistrationDAO.logExceptionOnCase(): ' + objCase + ',' + objException);
        
        String message = null;
        String responseCode = EC_Constants.ERROR_RESP_CODE;
        
        if(objException == NULL) {
            responseCode = EC_Constants.ERROR_CUSTOM_CODE_NOT_FOUND;
            EC_UserRegistration_Custom_Code__mdt customCode = EC_QueryUtility.getCustomCodeUserRegistration(responseCode)[0];
            message = customCode.EC_CustomCodes__c + ',' + customCode.EC_Message__c;
        } else if(objException.getMessage().length() == 4) {
            responseCode = objException.getMessage();
            List<EC_UserRegistration_Custom_Code__mdt> customCodes = EC_QueryUtility.getCustomCodeUserRegistration(responseCode);           
            if(customCodes.isEmpty()) {
                message = responseCode + ' Not Found.';
            } else {
                message = customCodes[0].EC_CustomCodes__c + ',' + customCodes[0].EC_Message__c;
            }
        } else {
            responseCode = EC_Constants.ERROR_RESP_CODE;
            message = objException.getLineNumber() + '::' + objException.getMessage() + '::' + objException.getCause() + '::' + objException.getStackTraceString();
        }
        
        if(objCase != null) {
            objCase.Status = 'Exception';
            if(objCase.Description == null) {
                objCase.Description = 'Date:' + datetime.now() + '\n' + 'Message:' + message + '\n';
            } else {
                objCase.Description = objCase.Description + '\n\n' + 'Date:' + datetime.now() + '\n' + 'Message:' + message + '\n';
            }
            update objCase;
        }
        
        System.debug('<<< EC_UserRegistrationDAO.logExceptionOnCase(): ' + objCase);
        return responseCode;
    }
}