/*
* Class Name	: EC_UserRegistrationDAO 
* Description	: This class contains the data access (CRUD) methods
*/
public without sharing class EC_UserRegistrationDAO {
 
    //This is private constructor to restrict object creation. All the methods are static
    private EC_UserRegistrationDAO() {}
    
    /*
    * Method Name	: getAccountIdByKey
    * Description	: This method returns the Account Id by Account Key.
    * Request 		: Account Key
    * Response		: Account Id
    */  
    private static Id getAccountIdByKey(String accKey) {

        System.debug('>>> EC_UserRegistrationDAO.getAccountIdByKey(): ' + accKey);
        
        List<Account> listAcc = [Select Id from Account where EC_CDM_Account__c =: accKey];

        if(listAcc.isEmpty()) {
            return NULL;
        }

        System.debug('<<< EC_UserRegistrationDAO.getAccountIdByKey(): ' + listAcc[0].Id);
        
        return listAcc[0].Id;
    }

    /*
    * Method Name	: createContact
    * Description	: This method creates a new contact
    * Request 		: RegisterUser & RegisterUserResponse DTO
    * Response		: Contact Id
    */  
    private static Id createContact(Id accId, EC_UserRegistrationDTO.RegisterUser rUser, 
                                    EC_UserRegistrationDTO.RegisterUserResponse ruResponse) {

        System.debug('>>> EC_UserRegistrationDAO.createContact(): RegisterUser,RegisterUserResponse: ' 
                     + rUser + ',' + ruResponse);
                                        
        Contact objCon = new Contact();
        // Populate fields from RegisterUser DTO                                
        objCon.Source__c = EC_Constants.SELFREGISTRATION;
        objCon.Contact_Type__c = EC_Constants.EXTERNAL;
        objCon.FirstName = rUser.firstName;
        objCon.LastName = rUser.lastName;
        objCon.AccountId =  accId;
        objCon.Phone = rUser.phoneNumber;
                                        
		// Populate fields from RegisterUserResponse DTO                                        
        objCon.Email = ruResponse.userEmail;
                                        
		// Add Email extension if it's not Prod                                    
        if(System.label.EC_Email_Extension != EC_Constants.PRODEMAILEXT) {
            objCon.Email = ruResponse.userEmail + '' + System.label.EC_Email_Extension;
        }
                                        
        objCon.EC_CDM_Contact__c = ruResponse.userKey.trim();
        
        insert objCon;
                                        
        System.debug('<<< EC_UserRegistrationDAO.createContact(): objCon: ' + objCon);
                                        
        return objCon.Id;
    }

    /*
    * Method Name	: createUser
    * Description	: This method creates a new user
    * Request 		: RegisterUser & RegisterUserResponse DTO
    * Response		: User Id
    */  
    private static Id createUser(Id conId, EC_UserRegistrationDTO.RegisterUser rUser, 
                                    EC_UserRegistrationDTO.RegisterUserResponse ruResponse) {

        System.debug('>>> EC_UserRegistrationDAO.createUser(): RegisterUser,RegisterUserResponse: ' + rUser + ',' + ruResponse);
                                        
        User user = new User();

        user.LastName = rUser.lastName;
        user.FirstName = rUser.firstName;
        user.EC_CDM_User__c = ruResponse.userKey.trim();

        String nick = '';                                        
        if(ruResponse.userEmail != null) {
 	        nick = ruResponse.userEmail.substring(0, ruResponse.userEmail.indexOf('@'));
            if(nick.length() > 25) {
                nick = nick.substring(0, 25);
            }
        }
                                        
        nick += Datetime.now().getTime();
                                        
        user.Username = ruResponse.userEmail + '' + System.label.EC_USERNAME;
        
        if(System.label.EC_Email_Extension == EC_Constants.PRODEMAILEXT) {
            user.Email = ruResponse.userEmail;
        } else {
            user.Email = ruResponse.userEmail + System.Label.EC_Email_Extension;
        }
        
        user.CommunityNickname = nick;
        
        user.FederationIdentifier = (ruResponse.userEmail).toLowerCase();
        
        user.User_Type__c = EC_Constants.EXTERNAL;
        user.IsActive = true;
        user.Phone = rUser.phoneNumber;
        user.EC_Portal_Access_Role__c = EC_Constants.BUYER;
        user.LocaleSidKey = EC_Constants.EN_US;
        Profile p = [Select Id, Name from Profile where Name=:EC_Constants.PROFILE];
        user.profileId = p.Id;
        user.LanguageLocaleKey = EC_Constants.EN_US;
        user.EmailEncodingKey = EC_Constants.UTF_8;
        user.TimeZoneSidKey = EC_Constants.GMT;
        user.Alias = (ruResponse.userEmail != null) ? ruResponse.userEmail.substring(0, 2) : '';
        user.ContactId = conId;
        
        insert user;
                                        
        System.debug('<<< EC_UserRegistrationDAO.createUser(): ' + user);
                                        
		return user.Id;
    }
    
    /*
	* Method Name  : addPermissionSet
	* Description  : This method is used to assign Permission Set for the User
	* Request      : User Id
	*/ 
    @future 
    private static void addPermissionSet(Id userId) {
        System.debug('>>> EC_UserRegistrationDAO.addPermissionSet(): ' + userId);

        PermissionSetAssignment psAssignment = new PermissionSetAssignment();
        psAssignment.AssigneeId = userId;
        psAssignment.PermissionSetId = EC_Utility.permissionSetId(EC_Constants.BUYER);

        System.debug('<<< EC_UserRegistrationDAO.addPermissionSet(): ' + psAssignment);
       	insert psAssignment;
    }

    /*
    * Method Name	: createRegistrationCase
    * Description	: This method creates a new case
    * Request 		: Account Id, Contact Id, User Id
    */ 
    private static Case createRegistrationCase(String accId, String conId, String userId) {

        System.debug('>>> EC_UserRegistrationDAO.createRegistrationCase(): accId,conId,userId: ' 
                     + accId + ',' + conId + ',' + userId);

        Case objCase = new Case();
        
        AccountContactRelation acRelation = [SELECT Id, EC_Email__c FROM AccountContactRelation 
                                             WHERE AccountId =: accId AND
                                             Alignment_Type__c = :EC_Constants.PRIMARY_ALIGNMENT_TYPE LIMIT 1];
        
        System.debug('>> acRelation: ' + acRelation);

        objCase.AccountId = accId;
        objCase.ContactId = conId;
        
        if(acRelation != null) {
            objCase.EC_Sales_Rep_Email__c = acRelation.EC_Email__c;
        }
        
        objCase.EC_User__c= userId;
        objCase.Status = Label.EC_Status_New;
        
        objCase.Type = EC_Constants.USER_REGISTRATION; // User Registration
        objCase.Origin = Label.EC_Origin_Online_Registration; // Connect
        
        objCase.EC_PortalAccessRole__c = EC_Constants.BUYER;
        
        User user = [SELECT Id, Name FROM User WHERE Id =: Label.EC_CaseOwnerId LIMIT 1];
        objCase.OwnerId = user.Id ;
        
        insert objCase;

        System.debug('<<< EC_UserRegistrationDAO.createRegistrationCase(): objCase: ' + objCase);
                     
        return objCase;
    }

    /*
    * Method Name  : createExtUser
    * Description  : This method is used to create External User for Self Registration
    * Request      : RegisterUser DTO, RegisterUserResponse DTO
    * Response     : Response code
    */
    public static Case createExtUserAndCase(EC_UserRegistrationDTO.RegisterUser rUser, EC_UserRegistrationDTO.RegisterUserResponse ruResponse) {
                                           
        System.debug('>>> EC_UserRegistrationDAO.createExtUser(): ' + rUser + ',' + ruResponse);
                                           
        String accKey = ruResponse.accountKey.trim();
        String accId = getAccountIdByKey(accKey);
        
		// Throw custom exception if account not found
        if(accId == null) {
            throw new EC_UserRegistrationException(EC_Constants.ERROR_ACCOUNT_NOT_FOUND_CODE);
        }
                                           
        String conId = createContact(accId, rUser, ruResponse);
        String userId = createUser(conId, rUser, ruResponse);
            
        addPermissionSet(userId);
        
        Map<String,String> alignAccount = new Map<String,String>();
        
        alignAccount.put(EC_Constants.AccountNumber, ruResponse.accountNo);
        alignAccount.put(EC_Constants.SalesRepEmail, ruResponse.salesRepEmail);
        List<Account> childAccounts = [Select Id from Account where ParentId =: accId];
        List<AccountContactRelation> acRelationships = new List<AccountContactRelation>();
        
        AccountContactRelation acRelation;
            
        for(Account childAccount : childAccounts) {
            acRelation = new AccountContactRelation();
            acRelation.AccountId = childAccount.Id;
            acRelation.ContactId  = conId;
            acRelationships.add(acRelation);
        }
        
        insert acRelationships;
        
        Case objCase = createRegistrationCase(accId, conId, userId);

        System.debug('<<< EC_UserRegistrationDAO.createExtUser(): ' + accId + ',' + conId + '' + userId + ',' + objCase);
        
        return objCase;
    }

    /*
    * Method Name	: isValidUser
    * Description	: This method queries the User using emailId
    * Request 		: User Email
    * Response		: User
    */
    public static User isValidUser(String userEmail) {

        System.debug('>>> EC_UserRegistrationDAO.isValidUser(): ' + userEmail);

        String emailId = userEmail;

        if(System.Label.EC_Email_Extension != EC_Constants.PRODEMAILEXT) {
            emailId = userEmail + System.Label.EC_Email_Extension;
        }
		
        User[] users = [SELECT Id, Name FROM User WHERE Email =: emailId AND IsActive = TRUE LIMIT 1];

        if(users.isEmpty()) {
	        throw new EC_UserRegistrationException(EC_Constants.ERROR_USER_NOT_FOUND_CODE);
        }

        System.debug('<<< EC_UserRegistrationDAO.isValidUser(): ' + users[0]);

        return users[0];
    }

    /*
    * Method Name	: getCaseStatus
    * Description	: This method queries the Case using emailId
    * Request 		: User Email
    * Response		: Case
    */
    public static Case getCaseByEmailId(String userEmail) {
		
        System.debug('>>> EC_UserRegistrationDAO.getCaseByEmailId(): ' + userEmail);
        
        String emailId = userEmail;

        if(System.Label.EC_Email_Extension != EC_Constants.PRODEMAILEXT) {
            emailId = userEmail + System.Label.EC_Email_Extension;
        }

        Case[] objCase = [SELECT Status, Contact.FirstName, Contact.LastName, Description FROM Case WHERE Contact.Email =: emailId AND 
                          (Origin = 'Connect' OR Origin = 'CDM') AND Type = 'User Registration' AND 
                          (Status =: EC_Constants.STATUS_CLOSED OR Status =: Label.EC_Status_New OR Status = 'Exception') LIMIT 1];

        if(objCase.isEmpty()) {
            return null;
        }
        
        objCase[0].Status = (objCase[0].Status == EC_Constants.CASE_STATUS_EXCEPTION) ? EC_Constants.CASE_STATUS_NEW : objCase[0].Status;

        System.debug('<<< EC_UserRegistrationDAO.getCaseByEmailId(): ' + objCase[0]);

		return objCase[0];
    }
}