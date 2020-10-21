/*
* Class Name	: EC_SelfRegistrationController
* Description	: This class contains the aura enabled methods used by SelfRegistration Lightning component.
*/
public without sharing class EC_SelfRegistrationController {

    /*
    * Method Name : registerUser
    * Description : This method triggers the User Registraion Process.
    *				1) Create a new User if Case status is NULL
    *				2) Complete the User Registration if Case status is New
    *				3) Redirect the User to Sign In page if Case status is Closed
    * Parameters  : mapUserDetails
    * Return type : String (JSON response)
    */
    @AuraEnabled
    public static String registerUser(Map<String, String> mapUserDetails) {
        
        System.debug('>>> EC_SelfRegistrationController.registerUser(): ' + mapUserDetails);
        
        EC_UserRegistrationDTO.RegPageResponse rpResponse = new EC_UserRegistrationDTO.RegPageResponse();            
        Case objCase = null;
        
        try {
            
            EC_UserRegistrationDTO.RegisterUser rUser = new EC_UserRegistrationDTO.RegisterUser(
                mapUserDetails.get('FirstName'),mapUserDetails.get('LastName'), mapUserDetails.get('PhoneNumber'),
                mapUserDetails.get('Email'), mapUserDetails.get('SalesRepEmail'), mapUserDetails.get('AccountNumber'));
            
           	objCase = EC_UserRegistrationDAO.getCaseByEmailId(rUser.userEmail);

            // Create a new user if Case not exist already
            if(objCase == NULL) {
	            rpResponse = EC_UserRegistrationHelper.registerNewUser(rUser); 
                objCase = rpResponse.objCase;

          } else {
				rpResponse.caseStatus = objCase.Status;
                if(objCase.Status == EC_Constants.CASE_STATUS_NEW) {
                    rpResponse = EC_UserRegistrationHelper.registerExistingUser(rUser.userEmail, objCase);
                } else if (objCase.Status == EC_Constants.CASE_STATUS_CLOSED) {
                    rpResponse = new EC_UserRegistrationDTO.RegPageResponse();
                    rpResponse.Status = EC_Constants.CASE_STATUS_CLOSED_RESP_CODE;
                    rpResponse.caseStatus = EC_Constants.CASE_STATUS_CLOSED;
                }
            }
            
        } catch(EC_UserRegistrationException urException) {
            rpResponse.status = EC_UserRegistrationHelper.logExceptionOnCase(objCase, urException);
        } catch(Exception ex) {
            rpResponse.status = EC_UserRegistrationHelper.logExceptionOnCase(objCase, ex);
        }
        
        List<EC_UserRegistration_Custom_Code__mdt> customCodes = EC_QueryUtility.getCustomCodeUserRegistration(rpResponse.status);
        
        if(customCodes.isEmpty()) {
            rpResponse.status = EC_UserRegistrationHelper.logExceptionOnCase(objCase, null);
	        customCodes = EC_QueryUtility.getCustomCodeUserRegistration(rpResponse.status);
        }
        
        rpResponse.label = customCodes[0].EC_Popup_Label__c;
        rpResponse.message = customCodes[0].EC_Message__c;    
        
        System.debug('>>> EC_SelfRegistrationController.registerUser: ' + rpResponse);
        
        return JSON.serialize(rpResponse);

    }
    
    /*
    * Method Name : createDirectoryUser
    * Description : This method completes the user registration by creating user in Azure directory.
    * Parameters  : userEmail, accountType, firstName, lastName  
    * Return type : String (JSON response)
    */
    @AuraEnabled
    public static String createDirectoryUser(String userEmail, String accountType, String firstName, String lastName) {
        
        System.debug('>>> EC_SelfRegistrationController.createDirectoryUser: ' + userEmail + ',' + accountType + ',' + 
                     firstName + ',' + lastName);

		EC_UserRegistrationDTO.DirectoryUserResponse duResponse = new EC_UserRegistrationDTO.DirectoryUserResponse();        
        Case objCase = null;
        
        try {

            objCase = EC_UserRegistrationDAO.getCaseByEmailId(userEmail);

            if(objCase == NULL) {
                throw new EC_UserRegistrationException(EC_Constants.ERROR_CASE_NOT_FOUND_CODE);
            }

            EC_UserRegistrationDTO.DirectoryUserRequest duRequest = new 
                EC_UserRegistrationDTO.DirectoryUserRequest(userEmail, accountType, firstName, lastName);
            
            duResponse = EC_UserRegistrationService.createDirectoryUser(duRequest);
            
        } catch(EC_UserRegistrationException urException) {
            duResponse.responseCode = EC_UserRegistrationHelper.logExceptionOnCase(objCase, urException);
        } catch(Exception ex) {
            duResponse.responseCode = EC_UserRegistrationHelper.logExceptionOnCase(objCase, ex);
        }
        
        List<EC_UserRegistration_Custom_Code__mdt> customCodes = 
            EC_QueryUtility.getCustomCodeUserRegistration(duResponse.responseCode);

        if(customCodes.isEmpty()) {
            duResponse.responseCode = EC_UserRegistrationHelper.logExceptionOnCase(objCase, null);
	        customCodes = EC_QueryUtility.getCustomCodeUserRegistration(duResponse.responseCode);
        }
        
        EC_UserRegistrationDTO.CompleteRegPageResponse crpResponse =  
            new EC_UserRegistrationDTO.CompleteRegPageResponse(customCodes[0].EC_CustomCodes__c,
                                                               customCodes[0].EC_Popup_Label__c, 
                                                               customCodes[0].EC_Message__c);
        
        System.debug('<<< EC_SelfRegistrationController.createDirectoryUser: ' + crpResponse);

        return JSON.serialize(crpResponse, true);
    }
    
    /*
    * Method Name : outageRedirect
    * Description : This method calls the EC_Utility.getOutageFlag() method
    * Return type : Boolean
    */
    @auraEnabled
    public static Boolean outageRedirect() {
        try {
	        return EC_Utility.getOutageFlag();
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
    	}
    }
    
    /*
    * Method Name : getProfile
    * Description : This method calls the EC_Utility.getProfileIBuy() method
    * Return type : String
    */
    @auraEnabled
    public static String getProfile() {
        try {
	        return EC_Utility.getProfileIBuy();
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
    	}
    }
}