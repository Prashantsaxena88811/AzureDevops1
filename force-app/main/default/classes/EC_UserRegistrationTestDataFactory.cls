@isTest
public class EC_UserRegistrationTestDataFactory {

   	public static void insetCustomSettings() {

		List<EC_LogsEnabler__c> listLogSettings = new List<EC_LogsEnabler__c>();
        
        EC_LogsEnabler__c ruSetting = new EC_LogsEnabler__c();
        ruSetting.Name = 'RegisterUser';
        ruSetting.EC_LogsEnabled__c = true;
        listLogSettings.add(ruSetting);
        
        EC_LogsEnabler__c dpSetting = new EC_LogsEnabler__c();
        dpSetting.Name = 'DomainProperties';
        dpSetting.EC_LogsEnabled__c = true;
        listLogSettings.add(dpSetting);
        
        EC_LogsEnabler__c duSetting = new EC_LogsEnabler__c();
        duSetting.Name = 'DirectoryUser';
        duSetting.EC_LogsEnabled__c = true;
        listLogSettings.add(duSetting);

        EC_LogsEnabler__c punchSetting = new EC_LogsEnabler__c();
        punchSetting.Name = 'CaseCreationController';
        punchSetting.EC_LogsEnabled__c = true;
        listLogSettings.add(punchSetting);
        insert listLogSettings;

		List<EC_Mulesoft_Integration__c> listMuleSettings = new List<EC_Mulesoft_Integration__c>();
 
        EC_Mulesoft_Integration__c ruMuleInt = new EC_Mulesoft_Integration__c();
        ruMuleInt.Name = 'RegisterUser';
        ruMuleInt.EC_Endpoint__c = 'http://mule.com/ru';
        ruMuleInt.EC_ClientId__c = '101';
        ruMuleInt.EC_Client_Secret__c = 'xuksi';
		listMuleSettings.add(ruMuleInt);

        EC_Mulesoft_Integration__c dpMuleInt = new EC_Mulesoft_Integration__c();
        dpMuleInt.Name = 'DomainProperties';
        dpMuleInt.EC_Endpoint__c = 'http://mule.com/dp';
        dpMuleInt.EC_ClientId__c = '101';
        dpMuleInt.EC_Client_Secret__c = 'xuksi';
		listMuleSettings.add(dpMuleInt);

        EC_Mulesoft_Integration__c duMuleInt = new EC_Mulesoft_Integration__c();
        duMuleInt.Name = 'DirectoryUser';
        duMuleInt.EC_Endpoint__c = 'http://mule.com/du';
        duMuleInt.EC_ClientId__c = '101';
        duMuleInt.EC_Client_Secret__c = 'xuksi';
		listMuleSettings.add(duMuleInt);
        insert listMuleSettings;

		List<EC_PermissionSetMapping__c> listPermissionSettings = new List<EC_PermissionSetMapping__c>();
        
        EC_PermissionSetMapping__c psmBasic = new EC_PermissionSetMapping__c();
		psmBasic.Name = 'Basic';
		psmBasic.EC_PermissionSetList__c = 'EC_BasicSet';
        listPermissionSettings.add(psmBasic);
        
        EC_PermissionSetMapping__c psmBuyer = new EC_PermissionSetMapping__c();
		psmBuyer.Name = 'Buyer';
		psmBuyer.EC_PermissionSetList__c = 'EC_BuyerSet';
        listPermissionSettings.add(psmBuyer);

        insert listPermissionSettings;
	}

    public static Id createAccount() {
        
        Account objAccount = new Account (
            Name                    = 'B2C',
            Type                    = 'Customer',
            EC_Division__c          = 'WATER',
            BillingStreet           = 'BillingStreet',
            BillingCity             = 'BillingCity',
            BillingState            = 'BillingState',
            BillingCountry          = 'USA',
            ShippingCountry         = 'USA',
            ccrz__SourceSystem__c 	= 'Test',
            BillingPostalCode       = '12807',
            EC_Account_Number__c    = '18787',
            EC_CDM_Account__c		= '17654'	
        );
        
        insert objAccount;
        return objAccount.Id;
    }

    private static Id createContact(String accountId, String userEmail) {

        Contact objContact = new Contact (
            FirstName 	= 'B2C',
            LastName	= 'TestUser',
            Email 		= userEmail,
            AccountId 	= accountId,
            MailingStreet = 'MailingStreet'
        );
        
        insert objContact;
        System.debug('### objContact: ' + objContact.Id);
        return objContact.Id;
    }
    
    private static Id createUser(String contactId, String userEmail) {
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = :EC_TestData.CLOUDCRAZE_CUSTOMER_COMMUNITY_PROFILE_NAME 
                           LIMIT 1];
        
        User testOwner = [SELECT TimeZoneSidKey, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        
        User objUser = new User(
            Alias               = 	'cctest',
            Email               = 	userEmail,
            EmailEncodingKey    = 	'UTF-8',
            LastName            = 	'TestUser',
            LanguageLocaleKey   = 	'en_US',
            LocaleSidKey        = 	'en_US',
            ProfileId           = 	profile.Id,
            Username            = 	userEmail,
            isActive            = 	true,
            ContactId           = 	contactId,
            User_Type__c        =	'External',
            TimeZoneSidKey		=	testOwner.TimeZoneSidKey
        );
        
        insert objUser;
        System.debug('### objUser: ' + objUser.Id);
        return objUser.Id;
    }
    
    public static Case createCase(String userEmail, String caseStatus, Boolean isCreateUser) {

        String fUserEmail = userEmail;
        
        if(System.Label.EC_Email_Extension != EC_Constants.PRODEMAILEXT) {
      		fUserEmail = userEmail + System.Label.EC_Email_Extension;
      	}

        Case objCase = new Case();

        objCase.AccountId = createAccount();
        objCase.ContactId = createContact(objCase.AccountId, fUserEmail);
        
        if(isCreateUser) {
        	objCase.EC_User__c= createUser(objCase.ContactId, fUserEmail);
        }
        
        objCase.Status = caseStatus;
        objCase.Type = EC_Constants.USER_REGISTRATION; 			// User Registration
        objCase.Origin = Label.EC_Origin_Online_Registration; 	// Connect
        objCase.EC_PortalAccessRole__c = EC_Constants.BUYER;
        insert objCase;
        
        return objCase;
    }
    
    public static void updateAPILogger(String apiName, Boolean flag) {
        EC_LogsEnabler__c logSetting = EC_LogsEnabler__c.getvalues(apiName);
        logSetting.EC_LogsEnabled__c = flag;
        update logSetting;
    } 

    public static void updateAPIEndPointURL(String apiName, String endPoint) {
        System.debug('##ruMuleInt' + apiName + '::' + endPoint);
        EC_Mulesoft_Integration__c ruMuleInt = EC_Mulesoft_Integration__c.getvalues(apiName); 
        System.debug('##ruMuleInt' +ruMuleInt);
        ruMuleInt.EC_Endpoint__c = 'http://mule.com/' + endPoint;
        update ruMuleInt;
    } 
    
    public static void createAccountContactRelation(){
        Account parentAcc = new Account(Name= 'DAOAccount', EC_CDM_Account__c = '555', EC_Account_Number__c = '500000005');
        Database.insert(parentAcc);
        
        List<Account> childAccts = new List<Account>();
        for(Integer i=0; i<3; i++) {
            childAccts.add(new Account(Name = 'TestAcct'+i, ParentId = parentAcc.Id));
        }
        Database.insert(childAccts); 
        
        Contact cont = new Contact(LastName = 'Last', AccountId = parentAcc.Id);
        Database.insert(cont); 
        
        AccountContactRelation accRel = new AccountContactRelation();
        accRel = [Select Id FROM AccountContactRelation WHERE AccountId = :parentAcc.Id];
        accRel.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
        upsert accRel;
    }
    
    public static void createOutageRecord(){
        EC_OutageFlag__c outageRec = new EC_OutageFlag__c();
        outageRec.name = 'CommunityActive';
        outageRec.EC_isCommunityActive__c = true;
        insert outageRec;
    }

}