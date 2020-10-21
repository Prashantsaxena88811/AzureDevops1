/*
* Class Name	: EC_UserRegistrationService 
* Description	: This class contains the service methods to invoke the User Registration APIs.
	1) Register User 2) Get Domain Properties 3) Create Directory User
*/
public class EC_UserRegistrationService {
 
    //This is private constructor to restrict object creation. All the methods are static
    private EC_UserRegistrationService() {}
    
    /*
    * Method Name	: registerUser
    * Description	: This method invokes the Register User API.
    * Request 		: RegisterUserRequest DTO
    * Response		: RegisterUserResponse DTO
    */
    public static EC_UserRegistrationDTO.RegisterUserResponse registerUser(EC_UserRegistrationDTO.RegisterUserRequest ruRequest) {

        System.debug('>>> EC_UserRegistrationService.registerUser(): ' + ruRequest);
        
        // Get the RegisterUser API callout Logs flag                                              
        Boolean isRULogsEnabled = EC_LogsEnabler__c.getValues(EC_Constants.REGISTER_USER).EC_LogsEnabled__c;
        
        String ruReqJSON = JSON.serialize(ruRequest);
        
        // Get the RegisterUser API Header attributes                                                                
        EC_Mulesoft_Integration__c ruHeaderAttr = EC_QueryUtility.getHeader(EC_Constants.REGISTER_USER);
        
        System.debug('>> Header, Logger, Request JSON: ' + ruHeaderAttr + ',' + isRULogsEnabled + ',' + ruReqJSON);
        
        // Register User API callout
        HttpResponse httpResponse = EC_HTTPCalloutUtils.doPost(ruHeaderAttr.EC_Endpoint__c, ruReqJSON, 
                                                               ruHeaderAttr.EC_ClientId__c, ruHeaderAttr.EC_Client_Secret__c);
        
        String ruResJSON = httpResponse.getBody();

        System.debug('>> Register User Response: ' + ruResJSON);
        
        Integer httpStatusCode = httpResponse.getStatusCode();
        
        if(httpStatusCode == 401 || httpStatusCode == 500) {
            throw new EC_UserRegistrationException(String.valueOf(httpStatusCode));
        }
        
        EC_UserRegistrationDTO.RegisterUserResponse ruResponse = (EC_UserRegistrationDTO.RegisterUserResponse) 
            JSON.deserialize(ruResJSON, EC_UserRegistrationDTO.RegisterUserResponse.class);
        
        // Log the API request and response                                                                
        if(ruResponse.responseCode == EC_Constants.SUCCESS_RESP_CODE && isRULogsEnabled) {
            EC_Utility.logCallouts(EC_Constants.REGISTER_USER, ruReqJSON, ruResJSON, null, EC_Constants.SUCCESS);
        } else if(isRULogsEnabled) {
            EC_Utility.logCallouts(EC_Constants.REGISTER_USER, ruReqJSON, ruResJSON, null, EC_Constants.failure);
        }
        
        System.debug('<<< EC_UserRegistrationService.registerUser(): ' + ruResponse);
        
        if(ruResponse.responseCode != EC_Constants.SUCCESS_RESP_CODE) {
            throw new EC_UserRegistrationException(ruResponse.responseCode);
        }
        
        return ruResponse;
    }
    
    /*
    * Method Name	: getDomainProperties
    * Description	: This method invokes the Domain Properties API.
    * Request 		: DomainPropertiesRequest DTO
    * Response		: DomainPropertiesResponse DTO
    */
    public static EC_UserRegistrationDTO.DomainPropertiesResponse getDomainProperties(String userEmail) {

        System.debug('>>> EC_UserRegistrationService.getDomainProperties(): ' + userEmail);
        
        // Get the DomainProperties API callout Logs flag                                                                
        Boolean isDPLogsEnabled = EC_LogsEnabler__c.getValues(EC_Constants.DOMAIN_PROPERTIES).EC_LogsEnabled__c;
        
        // Get the DomainProperties API Header attributes                                                                
        EC_Mulesoft_Integration__c dpHeaderAttr = EC_QueryUtility.getHeader(EC_Constants.DOMAIN_PROPERTIES);
        
        System.debug('>> Logger, Header Values: ' + isDPLogsEnabled + ',' + dpHeaderAttr);

        String dpEndpointURL = dpHeaderAttr.EC_Endpoint__c + '?userEmail=' + userEmail;

        System.debug('>> End point URL: ' + dpEndpointURL);
        
        // Domain Properties API callout
        HttpResponse httpResponse = EC_HTTPCalloutUtils.doGET(dpEndpointURL, dpHeaderAttr.EC_ClientId__c, dpHeaderAttr.EC_Client_Secret__c);

        String dpResJSON = httpResponse.getBody();

        System.debug('>> Domain Properties Response: ' + dpResJSON);
        
        Integer httpStatusCode = httpResponse.getStatusCode();
        
       if(httpStatusCode == 401 || httpStatusCode == 500) {
            throw new EC_UserRegistrationException(String.valueOf(httpStatusCode));
        }
        
        EC_UserRegistrationDTO.DomainPropertiesResponse dpResponse = (EC_UserRegistrationDTO.DomainPropertiesResponse) 
			            JSON.deserialize(dpResJSON, EC_UserRegistrationDTO.DomainPropertiesResponse.class);
        
        // Log the API request and response
        if(!Test.isRunningTest()) {                                                                
            if(dpResponse.responseCode == EC_Constants.SUCCESS_RESP_CODE && isDPLogsEnabled) {
                EC_Utility.logCallouts(EC_Constants.DOMAIN_PROPERTIES, userEmail, dpResJSON, dpResponse.responseCode, EC_Constants.SUCCESS);
            } else if(isDPLogsEnabled) {
                EC_Utility.logCallouts(EC_Constants.DOMAIN_PROPERTIES, userEmail, dpResJSON, dpResponse.responseCode, 
                                       EC_Constants.failure);
            }
        }
        
        System.debug('<<< EC_UserRegistrationService.getDomainProperties(): ' + dpResponse);
        
        if(dpResponse.responseCode != EC_Constants.SUCCESS_RESP_CODE) {
            throw new EC_UserRegistrationException(dpResponse.responseCode);
        }
        
        return dpResponse;
    }
    
    /*
    * Method Name	: createDirectoryUser
    * Description	: This method invokes the Directory User API.
    * Request 		: DirectoryUserRequest DTO
    * Response		: DirectoryUserResponse DTO
    */
    public static EC_UserRegistrationDTO.DirectoryUserResponse createDirectoryUser(EC_UserRegistrationDTO.DirectoryUserRequest duRequest) {

        System.debug('>>> EC_UserRegistrationService.createDirectoryUser(): ' + duRequest);
        
        // Get the DirectoryUser API callout Logs flag                                                                
    	Boolean isDULogsEnabled = EC_LogsEnabler__c.getValues(EC_Constants.DIRECTORY_USER).EC_LogsEnabled__c;

        // Get the DirectoryUser API Header attributes                                                                
        EC_Mulesoft_Integration__c duHeaderAttr = EC_QueryUtility.getHeader(EC_Constants.DIRECTORY_USER);
        
        String duReqJSON = JSON.serialize(duRequest);
            
        System.debug('>>> Header, Logger Values: ' + duHeaderAttr + ',' + duReqJSON +  ',' + isDULogsEnabled);
        
        HttpResponse httpResponse = EC_HTTPCalloutUtils.doPost(duHeaderAttr.EC_Endpoint__c, duReqJSON, 
                                                  duHeaderAttr.EC_ClientId__c, duHeaderAttr.EC_Client_Secret__c);
		
        String duResJSON = httpResponse.getBody(); 

        System.debug('>> Directory User Response: ' + duResJSON);
        
        Integer httpStatusCode = httpResponse.getStatusCode();
        
        if(httpStatusCode == 401 || httpStatusCode == 500) {
            throw new EC_UserRegistrationException(String.valueOf(httpStatusCode));
        }

        EC_UserRegistrationDTO.DirectoryUserResponse duResponse = (EC_UserRegistrationDTO.DirectoryUserResponse) 
            JSON.deserialize(duResJSON, EC_UserRegistrationDTO.DirectoryUserResponse.class);
        
        // Log the API request and response
        if(duResponse.responseCode == EC_Constants.SUCCESS_RESP_CODE && isDULogsEnabled) {
            EC_Utility.logCallouts(EC_Constants.DIRECTORY_USER, duReqJSON, duResJSON, duResponse.responseCode, EC_Constants.SUCCESS);
        } else if(isDULogsEnabled) {
            EC_Utility.logCallouts(EC_Constants.DIRECTORY_USER, duReqJSON, duResJSON, duResponse.responseCode, EC_Constants.failure);
        }
        
        System.debug('<<< EC_UserRegistrationService.createDirectoryUser(): ' + 'DirectoryUserResponse- ' + duResponse);
        
        if(duResponse.responseCode != EC_Constants.SUCCESS_RESP_CODE) {
            throw new EC_UserRegistrationException(duResponse.responseCode);
        }

        return duResponse;
    }
}