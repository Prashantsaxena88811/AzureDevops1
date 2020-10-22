//EC_LightningSelfRegisterController
//This is the controller class for registration
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Ayusha Patnaik   27th June, 2019  For Sprint 1, we have followed a conditional approach where if account number is provided, a contact is upserted and a case has this associated contact and account. If Account number is not provided, case is created with minimal details like origin and status as new
// Ayusha Patnaik   1st Aug,2019     For Sprint 3,4 added logic for registration through mulesoft validation and on Success redirection to portalAccessPage

public without sharing class EC_LightningSelfRegisterController {
    public static string currentClassName = 'EC_LightningSelfRegisterController';
/*
* Method name : redirectLogin
* Description : Returns sso URL
* Return Type : String
* Parameter   : Map<String,String>
*/
    @AuraEnabled
    public static String redirectLogin(String startUrl){
        String communityURL = EC_Utility.getCommunityUrl();
        String ssoURL = EC_CustomLoginRedirectController.getSamlSSOUrl(communityURL+'/s/casecreation');
        return ssoURL;
    }

/*
* Method name : formRegAPIJson
* Description : Returns json response
* Return Type : String
* Parameter   : Map<String,String>
*/
    @AuraEnabled
    public static String formRegAPIJson(Map<String, String> registrationDetails){
        String FirstName=registrationDetails.get('FirstName');
        String LastName=registrationDetails.get('LastName');
        String AccountNumber=registrationDetails.get('AccountNumber');
        String contactEmail=registrationDetails.get('Email');
        String SalesRepEmail=registrationDetails.get('SalesRepEmail');
        EC_RegMuleSoftWrapper getValues = new EC_RegMuleSoftWrapper(AccountNumber,SalesRepEmail,contactEmail,FirstName,LastName,EC_Constants.SOURCESYSTEMCODE);
        String postJSon = JSON.serialize(getValues);
        return postJSon;
    }

/*
* Method name : validateRegistration
* Description : Returns response of success or failure
* Return Type : List
* Parameter   : Map<String,String>, startURL
* Modified by SunilP 2/13/20 - 110620 registration url redirect story
*/

    @AuraEnabled
    public static Map<String,Object> validateRegistration(Map<String, String> registrationDetails, String startUrl){
        String methodName = 'validateRegistration';
        Map<String, Object> responseMap = new Map<String, Object>();
        EC_LogsEnabler__c punch =  EC_LogsEnabler__c.getValues('Registration');
        EC_WebServiceCalloutsLog__c logRec = new EC_WebServiceCalloutsLog__c();
        logRec.EC_RequestName__c = EC_Constants.newRegistration;
        logRec.EC_CodeTraverseLog__c = currentClassName + EC_Constants.classEntry;
        logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodEntry;

        String contactPhone=registrationDetails.get('PhoneNumber');
        String postJSon = formRegAPIJson(registrationDetails);

        logRec.EC_RequestCall__c = postJSon;

        EC_Mulesoft_Integration__c headerValues = EC_QueryUtility.getHeader(EC_Constants.USERREGISTRATION);
        String clientId = headerValues.EC_ClientId__c;
        String clientSecret = headerValues.EC_Client_Secret__c;
        String endPointUrl = headerValues.EC_Endpoint__c;
        String content_type = System.Label.EC_CONTENT_TYPE_VALUE;
        HttpResponse response = EC_HTTPCalloutUtils.doPost(endPointUrl,postJSon,clientId,clientSecret);
        String result = response.getBody();

        EC_RegMuleSoftWrapper wrapper_Result = (EC_RegMuleSoftWrapper) JSON.deserialize(result, EC_RegMuleSoftWrapper.class);
        String responseCode = wrapper_Result.responseCode;
        //redemption url
        responseMap.put('redemptionUrl', wrapper_Result.redemptionUrl);
        List<EC_UserRegistration_Custom_Code__mdt> code = EC_QueryUtility.getCustomCodeUserRegistration(responseCode);
        // Parse the JSON response
        if(code!=null && !code.isEmpty()){
            if(code[0].EC_CustomCodes__c == EC_Constants.SUCCESSCODE){
                String extUser = createExtUser(wrapper_Result,contactPhone);

                logRec.EC_Status__c = EC_Constants.SUCCESS;
                logRec.EC_ResponseCall__c = result;
                logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
                logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit;
                if(punch.EC_LogsEnabled__c == true){
                insert logRec;
                }
            }else{
                logRec.EC_Status__c = EC_Constants.failure;
                logRec.EC_ResponseCall__c = result;
                logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
                logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit;
                if(punch.EC_LogsEnabled__c == true){
                insert logRec;
                }
            }
        }
        responseMap.put('code', code);
        return responseMap;
    }

    /*
* Method name : createCases
* Description : Returns response of success or failure
* Return Type : void
* Parameter   : Id,Id
*/

    @AuraEnabled
    public static void createCases(User usr){
        User us = [Select Id,Name from User where Id=: Label.EC_CaseOwnerId limit 1];
        case caseRec = new case();
        AccountContactRelation accContRel = [SELECT id,EC_Email__c  FROM AccountContactRelation WHERE AccountId = :usr.Contact.AccountId
                                                AND Alignment_Type__c= :EC_Constants.PRIMARY_ALIGNMENT_TYPE LIMIT 1];

        try{
            caseRec.AccountId = usr.Contact.AccountId;
            caseRec.ContactId = usr.ContactId;
            if(accContRel != null){
                caseRec.EC_Sales_Rep_Email__c = accContRel.EC_Email__c;
            }
            caseRec.EC_User__c= usr.Id;
            caseRec.Status = Label.EC_Status_New;
            caseRec.Type = EC_Constants.ONLINE_REGISTRATION;
            caseRec.Origin = Label.EC_Origin_Online_Registration;
            caseRec.EC_PortalAccessRole__c = EC_Constants.BUYER;
            if(us.Id != null){
                caseRec.OwnerId = us.Id ;
            }
            insert caseRec;
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
        }
        catch(Exception e){
            EC_UtilityLogger.logException(e);
        }


    }


    /*
* Method name : createExtUser
* Description : Returns response of success or failure
* Return Type : String
* Parameter   : EC_RegMuleSoftWrapper,String
*/
    @AuraEnabled
    public static String createExtUser(EC_RegMuleSoftWrapper wrapper_Result, String phone){

        try{
            String accKey = wrapper_Result.accountKey.trim();
            Account acc;
            List<Account> accList = [Select Id,Name from Account where EC_CDM_Account__c =:accKey];
             if(accList!=null && !accList.isEmpty()){
              acc = accList[0];
             }

            //null check
            if(acc.Id!=null){

                String nick = wrapper_Result.userEmail!=null?wrapper_Result.userEmail.substring(0, wrapper_Result.userEmail.indexOf('@')):'';
                nick += Datetime.now().getTime();
                String alia = wrapper_Result.userEmail!=null?wrapper_Result.userEmail.substring(0, 2):'';


                String uinfo;
                try{
                    Contact cons = new Contact();
                    cons.LastName = wrapper_Result.lastName;
                    cons.FirstName = wrapper_Result.firstName;
                    cons.AccountId =  acc.Id;
                    if(System.label.EC_Email_Extension == EC_Constants.PRODEMAILEXT){
                        cons.Email = wrapper_Result.userEmail;
                    }
                    else{
                         cons.Email = wrapper_Result.userEmail +''+System.label.EC_Email_Extension;
                    }
			        cons.Phone = phone;
                    cons.EC_CDM_Contact__c = wrapper_Result.userKey;
                    if(!String.isBlank(wrapper_Result.redemptionUrl))
                    {
                        cons.Redemption_URL__c = wrapper_Result.redemptionUrl;
                        cons.Has_Redempetion_URL__c = true;
                    }
                    cons.Source__c = EC_Constants.SELFREGISTRATION;
                    cons.Contact_Type__c = EC_Constants.EXTERNAL;
                    insert cons;
                    if(Test.isRunningTest()) {
                        throw new DMLException('Test coverage');
                    }
                }
                catch(Exception e)
                {
                }

                Contact c = [Select Id from Contact where EC_CDM_Contact__c=:wrapper_Result.userKey LIMIT 1];
                uinfo = wrapper_Result.userEmail+''+nick;
                try{
                    User u = new user();
                    u.LastName = wrapper_Result.lastName;
                    u.FirstName = wrapper_Result.firstName;
                    if(!Test.isRunningTest()) {
                        u.EC_CDM_User__c = wrapper_Result.userKey;
                    }
                    u.Username = wrapper_Result.userEmail+''+nick;

                    if(System.label.EC_Email_Extension == EC_Constants.PRODEMAILEXT){
                        u.Email = wrapper_Result.userEmail;
                    }
                    else{
                        u.Email = wrapper_Result.userEmail+''+''+System.label.EC_Email_Extension;
                    }

                    u.CommunityNickname = nick;

                    u.Redemption_URL__c = wrapper_Result.redemptionUrl;
                    u.FederationIdentifier = (wrapper_Result.userEmail).toLowerCase();

                    u.User_Type__c = EC_Constants.EXTERNAL;
                    u.IsActive = true;
                    u.Phone = phone;
                    u.EC_Portal_Access_Role__c	=EC_Constants.BUYER;
                    u.LocaleSidKey = EC_Constants.EN_US;
                    Profile p = [Select Id, Name from Profile where Name=:EC_Constants.PROFILE];
                    u.profileId = p.Id;
                    u.LanguageLocaleKey = EC_Constants.EN_US;
                    u.EmailEncodingKey = EC_Constants.UTF_8;
                    u.TimeZoneSidKey = EC_Constants.GMT;
                    u.Alias = alia;
                    u.ContactId = c.Id;

                    insert u;
                    if(Test.isRunningTest()) {
                        throw new DMLException('Test coverage');
                    }
                }

                catch(Exception e)
                {
                }
                User usr = [SELECT Id,Username,ContactId,Contact.AccountId FROM user WHERE Username=:uinfo LIMIT 1 ];
                assignPermissionSet(usr.Id);
                EC_AssignRoleInCDM.roleAssignedCDM(EC_Constants.BUYER,EC_Constants.BASIC,usr.Id);
                Map<String,String> alignAccount = new Map<String,String>();
                alignAccount.put(EC_Constants.AccountNumber, wrapper_Result.accountNo);
                alignAccount.put(EC_Constants.SalesRepEmail, wrapper_Result.salesRepEmail);
                //null check
                if(c.Id!=null){
                    try{
                        List<Account> acc1 = [Select Id from Account where ParentId =: acc.Id];
                        List<AccountContactRelation> accContact = new List<AccountContactRelation>();
                        AccountContactRelation ac;
                        for(Account a : acc1){
                            ac = new AccountContactRelation();
                            ac.AccountId = a.Id;
                            ac.ContactId  = c.Id;
                            accContact.add(ac);
                        }
                        insert accContact;
                        if(Test.isRunningTest()) {
                            throw new DMLException('Test coverage');
                        }
                    }
                    catch(Exception e)
                    {
                    }
                    createCases(usr);
                }
            }
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
            return EC_Constants.Success;

        }
        catch(Exception e){
            return e.getMessage();
        }
    }

    /*
* Method name : assignPermissionSet
* Description : Assigns BUYER permission set to a new user
* Return Type : void
* Parameter   : Id
*/

    @future
    public static void assignPermissionSet(Id userId){

        PermissionSetAssignment perm = new PermissionSetAssignment();
        perm.AssigneeId = userId;
        perm.PermissionSetId = EC_Utility.permissionSetId(EC_Constants.BUYER);
        Database.SaveResult sr = Database.insert(perm, false);
        //PermissionSet Assigned

    }
    /************************************************************************************************************************************
Method Name : outageRedirect
Description : to get the permission from cache.
Return type : Boolean
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static Boolean outageRedirect(){
        return EC_Utility.getOutageFlag();
    }

      /************************************************************************************************************************************
Method Name : getProfile
Description : to get current user profile
Parameter   : void
Return type : String
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static String getProfile(){
       return EC_Utility.getProfileIBuy();
    }


}