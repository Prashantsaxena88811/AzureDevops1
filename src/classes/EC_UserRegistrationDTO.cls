/*
* Class Name	: EC_UserRegistrationDTO
* Description	: This class contains the inner DTO classes to hold the request and response.
				  Unused attributes are commented for Code Coverage. But, Mule returns these attributes in API response.
*/

public class EC_UserRegistrationDTO {

    /*
     * Class Name	: RegisterUserRequest
     * Description	: This class is used to hold the request for Register User API
     */ 
	public class RegisterUserRequest {
 
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String phoneNumber {get; set;}
        public String userEmail {get;set;}
        public String salesRepEmail {get;set;}
        public String accountNo {get;set;}
        public String sourceSystemCode {get;set;}
        
        public RegisterUserRequest(String firstName, String lastName, String phoneNumber, String userEmail, 
		                           String accountNo, String salesRepEmail, String sourceSystemCode) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.phoneNumber = phoneNumber;
            this.userEmail = userEmail;
            this.accountNo = accountNo;
            this.salesRepEmail = salesRepEmail;
            this.sourceSystemCode = sourceSystemCode;
        }
		
	}

    /*
     * Class Name	: RegisterUserResponse
     * Description	: This class is used to hold the response for Register User API
     */ 
    public class RegisterUserResponse {
        public String userEmail {get;set;}
        public String accountNo {get;set;}
        public String salesRepEmail {get;set;}
        public String responseCode {get;set;}
        public String userKey {get;set;}
     // public String displayName {get; set;}
        public String accountKey {get;set;}
        public Boolean isLocalAllowed {get; set;}
        public Boolean isRegisteredDomain {get; set;}
     // public String sourceSystemCode {get;set;}
    }
    
    /*
     * Class Name	: DomainPropertiesUser
     * Description	: This class is used to hold the response (userinfo) for Domain Properties API
     */ 
	/*
    public class DomainPropertiesUser {
        public String userEmail {get;set;}
        public String displayName {get;set;}
        public String creationType {get; set;}
        public Boolean accountEnabled {get; set;}
        public String creationDate {get; set;}
        public String upn {get; set;}
        public String azureObjectId {get; set;}
	}*/
    
    /*
     * Class Name	: DomainPropertiesResponse
     * Description	: This class is used to hold the response for Domain Properties API
     */ 
	public class DomainPropertiesResponse {

        public String responseCode {get;set;}
        public Boolean isLocalAllowed {get;set;}
        public Boolean isRegisteredDomain {get;set;}
		
        // Userinfo is not currently used in Connect. Added for future purpose. 
        // public DomainPropertiesUser userInfo {get;set;}

    }

    /*
     * Class Name	: DirectoryUserRequest
     * Description	: This class is used to hold the request for Directory User API
     */ 
	public class DirectoryUserRequest {

        public String userEmail {get; set;}
        public String creationType {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}

        public DirectoryUserRequest (String userEmail, String creationType, String firstName, String lastName){
            this.userEmail = userEmail; 
            this.creationType = creationType;
            this.firstName = firstName;
            this.lastName = lastName;
        }
	}
    
    /*
     * Class Name	: DirectoryUserResponse
     * Description	: This class is used to hold the response for Directory User API
     */ 
	public class DirectoryUserResponse {
        public String responseCode {get;set;}
     /*   
        public String userEmail {get; set;}
        public String creationType  {get; set;}
        public String displayName {get; set;}
        public Boolean accountEnabled {get; set;}
        public String creationDate {get; set;}
        public String upn {get; set;}
        public String azureObjectId {get; set;}
	*/
	}
    
    /*
     * Class Name	: RegisterUser
     * Description	: This class is used to hold the request submitted from Registration page
     */ 
    public class RegisterUser {

        public String firstName {get;set;}
        public String lastName {get;set;}
        public String phoneNumber {get; set;}
        public String userEmail {get;set;}
        public String salesRepEmail {get;set;}
        public String accountNo {get;set;}
        
        public RegisterUser(String firstName, String lastName, String phoneNumber, String userEmail, 
                            String salesRepEmail, String accountNo) {
            this.firstName = firstName;
			this.lastName = lastName;
            this.phoneNumber = phoneNumber;
			this.userEmail = userEmail;                                   
            this.salesRepEmail = salesRepEmail;
            this.accountNo = accountNo;
        }
    }

    /*
     * Class Name	: RegPageResponse
     * Description	: This class is used to hold the response returned to Registration page
     */ 
    public class RegPageResponse {

        public String status {get;set;}
        
        public String accountType {get;set;}
        public String caseStatus {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        
        public String label {get;set;}
        public String message {get; set;}
        
        public Case objCase {get;set;}
    }
    
    /*
     * Class Name	: CompleteRegPageResponse
     * Description	: This class is used to hold the response returned to Complete Registration page
     */ 
    public class CompleteRegPageResponse {
		
        public String status {get;set;}
        public String label {get;set;}
        public String message {get; set;}

        public String firstName {get;set;}
        public String lastName {get;set;}
        public String accountType {get;set;}
        public String caseStatus {get;set;}
        
        // Default Constructor
        public CompleteRegPageResponse() {}        
        
        public CompleteRegPageResponse(String status, String label, String message) {
            this.status = status;
            this.label = label;
            this.message = message;
        }
 	}
}