/*
* Class Name	: EC_CompleteRegistrationController
* Description	: This class contains the aura enabled methods used by CompleteRegistration Lightning component.
*/
public without sharing class EC_CompleteRegistrationController { 

    /*
    * Method Name : validateUser
	* Description : This method validates the case and user using the emailId and returns the below values
	*	- status  : Status of the transaction (1001 - Success and remaining are related to some Failure)
	*	- caseStatus : case status to decide the next action (null/New/Closed)
	*	- accountType: accountType to decide the next action (All/Local/Federated)
	*	- displayName: displayName to send to create directory user API
	*	- label	  : label to show on the page in case of failure
	*	- message : message to show on the page in case of failure
	* Parameters  : String (user emailId)
	* Return type : String (JSON response)
	*/
    @AuraEnabled
    public static String validateUser(String userEmail, String source) {

        System.debug('>>> EC_CompleteRegistrationController.validateUser(): ' + userEmail + ',' + source);

        EC_UserRegistrationDTO.CompleteRegPageResponse crpResponse = new EC_UserRegistrationDTO.CompleteRegPageResponse();
        Case objCase = null;
        
        try {
		
            objCase = EC_UserRegistrationDAO.getCaseByEmailId(userEmail);

            if(objCase == NULL) {
                throw new EC_UserRegistrationException(EC_Constants.ERROR_CASE_NOT_FOUND_CODE);
            }
            
            crpResponse.firstName = objCase.Contact.FirstName;
            crpResponse.lastName = objCase.Contact.LastName;
            crpResponse.caseStatus = objCase.Status;
            crpResponse.status = EC_Constants.SUCCESS_RESP_CODE;

            if(crpResponse.caseStatus == EC_Constants.CASE_STATUS_NEW) {
                EC_UserRegistrationDAO.isValidUser(userEmail);
                if(String.isEmpty(source) || source != '1') {
                    crpResponse.accountType = EC_UserRegistrationHelper.getAccountTypesAllowedForUser(userEmail);
                }
            } else {
            	crpResponse.status = EC_Constants.CASE_STATUS_CLOSED_RESP_CODE;
            }
        } catch(EC_UserRegistrationException urException) {
            crpResponse.status = EC_UserRegistrationHelper.logExceptionOnCase(objCase, urException);
        } catch(Exception ex) {
            crpResponse.status = EC_UserRegistrationHelper.logExceptionOnCase(objCase, ex);
        }
        
        List<EC_UserRegistration_Custom_Code__mdt> customCodes = EC_QueryUtility.getCustomCodeUserRegistration(crpResponse.status);
        if(customCodes.isEmpty()) {
            crpResponse.status = EC_UserRegistrationHelper.logExceptionOnCase(objCase, null);
	        customCodes = EC_QueryUtility.getCustomCodeUserRegistration(crpResponse.status);
        }
        crpResponse.label = customCodes[0].EC_Popup_Label__c;
        crpResponse.message = customCodes[0].EC_Message__c;
        
        System.debug('<<< EC_CompleteRegistrationController.validateUser(): ' + crpResponse);
        
        return JSON.serialize(crpResponse, true);
    }

    /*
    * Method Name : createDirectoryUser
	* Description : This method creates the user in directory with a specific account type
	*	- status  : Status of the transaction (1001 - Success and remaining are related to some Failure)
	*	- label	  : label to show on the page in case of failure
	*	- message : message to show on the page in case of failure
	* Parameters  : String (user emailId)
	* Return type : String (JSON response)
	*/
    @AuraEnabled
    public static String createDirectoryUser(String userEmail, String accountType, String firstName, String lastName) {

        System.debug('>>> EC_CompleteRegistrationController.createDirectoryUser(): ' + userEmail + ',' + 
                     accountType + ',' + firstName + ',' + lastName);

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
        
        System.debug('<<< EC_CompleteRegistrationController.validateUser(): ' + crpResponse);

        return JSON.serialize(crpResponse, true);
    }
}