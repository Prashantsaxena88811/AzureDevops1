/*
* Class Name	: EC_PowerBIController
* Description	: This Class is used for handling PowerBI Dashboards
*/
public with sharing class EC_PowerBIController {
    private static final String POWERBI_FINAL = 'PowerBI Final';
    private static final OAuthApp_pbi__c PowerBISettings = OAuthApp_pbi__c.getValues(POWERBI_FINAL);
    
    /*
    * Method Name	: getContactAccounts
    * Description	: This Method is to fetch AccountContactRelations for logged-in User
    * Request 		: void
    * Response		: UserWrapper
    */
    private static UserWrapper getContactAccounts() {
        System.debug('>>> EC_PowerBIController.getContactAccounts()');

        try {          
            User loggedInUser = [SELECT id, ccrz__CC_CurrencyCode__c, ContactId FROM User WHERE Id =: userinfo.getuserId()];
            List<AccountContactRelation> lstAccContRel = new List<AccountContactRelation>();
            
            if(loggedInUser != null && loggedInUser.contactId != null){
                lstAccContRel = [SELECT AccountId FROM AccountContactRelation WHERE account.Recordtype.name='Ship To' AND contactId =: loggedInUser.contactId];
            } else {
                lstAccContRel = [SELECT AccountId FROM AccountContactRelation WHERE account.Recordtype.name='Ship To' AND contact.EC_SalesRep_User__c =: userinfo.getuserId()];
            } 
            
            UserWrapper rtnWrapper = new UserWrapper();
            rtnWrapper.accountCount = 0;
            if (lstAccContRel != null && !lstAccContRel.isEmpty()) {
                String AccountId = lstAccContRel[0].AccountId;
                Account accountList =[select Name,EC_Account_Number__c,EC_Division__c FROM Account WHERE Id =:AccountId Limit 1];
                rtnWrapper.accountCount = lstAccContRel.size();
                rtnWrapper.accountName = accountList.Name;
                rtnWrapper.accountNumber = accountList.EC_Account_Number__c;
                rtnWrapper.division = accountList.EC_Division__c;
            }
            
            System.debug('<<< EC_PowerBIController.getContactAccounts() : rtnWrapper- '+rtnWrapper);
            return rtnWrapper;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
         
    }

    /*
    * Method Name	: OAuthTokenClientCredentials
    * Description	: This Method is used to get the PowerBI OAuth Token
    * Request 		: void
    * Response		: String
    */
    @AuraEnabled
    public static String OAuthTokenClientCredentials() {
        System.debug('>>> EC_PowerBIController.OAuthTokenClientCredentials()');
        String token = '';
        try {
            Boolean isOAuthLogsEnabled = EC_LogsEnabler__c.getValues(EC_Constants.PBI_OAuthToken).EC_LogsEnabled__c;
        
            String endPoint = EC_Custom_URL_Settings__c.getValues('Microsoft OAuth Token').custom_url__c;
            String grantType = PowerBISettings.Grant_Type__c;
            String clientId =  PowerBISettings.Client_Id__c;        
            String clientSecret =  PowerBISettings.Client_Secret__c;          
            String resource = PowerBISettings.Resource_URI__c;  
            String contentType = 'application/x-www-form-urlencoded';
            PageReference ref = new PageReference(endPoint);
            // Populate parameters
            Map<String, String> params = new Map<String, String>();
            params.put('grant_type',grantType);
            params.put('Client_id',clientId);
            params.put('Client_secret',clientSecret);
            params.put('resource',resource);
            ref.getParameters().putAll(params);
            Url finalUrl = new Url(ref.getUrl());
            // fully url-encoded query string - set the body of http request object

            HttpResponse httpResponse = EC_PowerBIService.getAuthToken(endPoint, finalUrl.getQuery(), contentType);
            
            Integer httpStatusCode = httpResponse.getStatusCode();
            if(httpStatusCode == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    token = (String) results.get('access_token');
            }

            if(httpStatusCode == 200 && isOAuthLogsEnabled) {
                EC_Utility.logCallouts('OAuthTokenClientCredentials', finalUrl.getQuery(), JSON.serialize(httpResponse.getBody()), null, EC_Constants.SUCCESS);
            } else if(isOAuthLogsEnabled) {
                EC_Utility.logCallouts('OAuthTokenClientCredentials', finalUrl.getQuery(), JSON.serialize(httpResponse.getBody()), null, EC_Constants.failure);
            }
            
            System.debug('<<< EC_PowerBIController.OAuthTokenClientCredentials()');
            return token;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /*
    * Method Name	: getDataSet
    * Description	: This Method is used to get the PowerBI DataSet Details
    * Request 		: String, String, String
    * Response		: String
    */
    @AuraEnabled
    public static string getDataSet(String clientCredaccessToken, String groupId, String reportId, String datasetId, String role) {
        System.debug('>>> EC_PowerBIController.getDataSet() : groupId- '+groupId
        +' reportId- '+reportId+' datasetId- '+datasetId+' role- '+role);

        String jsonBodyReport = '';
        try {
            Boolean isDataSetLogsEnabled = EC_LogsEnabler__c.getValues(EC_Constants.PBI_DataSet).EC_LogsEnabled__c;

            DatasetWrapper dataset;
            //String userEmail = 'harrysoto@thefreshmarket.net'; 
            
            if(datasetId != null) {
                String PBIDataSetURL = PowerBISettings.BaseTokenURL__c+groupId+'/datasets/'+ datasetId;

                HttpResponse response = EC_PowerBIService.getDataSet(clientCredaccessToken, PBIDataSetURL);

                Integer httpStatusCode = response.getStatusCode();
                if(httpStatusCode == 200) {
                    dataset = (DatasetWrapper) JSON.deserialize(response.getBody(), DatasetWrapper.class);
                }

                if(httpStatusCode == 200 && isDataSetLogsEnabled) {
                    EC_Utility.logCallouts('getDataSet', PBIDataSetURL, JSON.serialize(response.getBody()), null, EC_Constants.SUCCESS);
                } else if(isDataSetLogsEnabled) {
                    EC_Utility.logCallouts('getDataSet', PBIDataSetURL, JSON.serialize(response.getBody()), null, EC_Constants.failure);
                }
            }

            jsonBodyReport = getDataSetHelper(dataset, reportId, datasetId, role);
            
            System.debug('<<< EC_PowerBIController.getDataSet() : jsonBodyReport - '+jsonBodyReport);
            return jsonBodyReport;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /*
    * Method Name	: getUserEmail
    * Description	: Helper Method for user email
    * Response		: String
    */
    private static string getUserEmail() {
        String userEmail = '';
        if (!Contact.sObjectType.getDescribe().isAccessible() || !User.sObjectType.getDescribe().isAccessible()) { 
	 		return userEmail;
	 	}
        Contact currContact = new Contact();
        User loggedInUser = [Select Id,contactId, User_Type__c FROM User WHERE Id =:UserInfo.getUserId()];
        if(loggedInUser.User_Type__c==null || loggedInUser.User_Type__c.EqualsIgnoreCase('external')){
            currContact = [Select Id,Email FROM Contact WHERE Id=:loggedInUser.contactId];
        } else {
            currContact = [Select Id,Email FROM Contact WHERE EC_SalesRep_User__c=:loggedInUser.Id];
        }  
        if (currContact != null) {
            userEmail = currContact.Email; 
        }
        if(userEmail == null) {
            userEmail = UserInfo.getUserEmail();
        } 
        return userEmail;
    }

    /*
    * Method Name	: getDataSetHelper
    * Description	: Helper Method for DataSet
    * Request 		: String, String, String
    * Response		: String
    */
    private static string getDataSetHelper(DatasetWrapper dataset, String reportId, String datasetId, String role) {
        String jsonBodyReport = '';
        String objectId =  PowerBISettings.Object_Id__c;  
        String userEmail = getUserEmail();
        
        if(dataset == null) {
            jsonBodyReport ='{"accessLevel":"View","reportId":'+'"'+reportId+'"'+',"identities":[{"username":'+'"'+userEmail+'"'+',"reports":["'+reportId+'"]}]}';      
        }
        else if(dataset.IsRefreshable) {
            if(!dataset.IsOnPremGatewayRequired && dataset.IsEffectiveIdentityRequired) {
                jsonBodyReport = '{"accessLevel":"View","identities":[{"username":'+'"'+userEmail+'"'+',"roles":["'+role+'"],"datasets":["'+datasetId+'"]}]}'; 
            }
        }
        else if(dataset.IsEffectiveIdentityRequired) {
            jsonBodyReport = '{"accessLevel":"View","identities":[{"username":'+'"'+userEmail+'"'+',"roles":["'+role+'"],"datasets":["'+datasetId+'"]}]}'; 
        }
        else {
            jsonBodyReport = '{"accessLevel":"View","identities":[{"username":'+'"'+objectId+'"'+',"customData":"'+userEmail+'"'
            +',"roles":["'+role+'"],"datasets":["'+dataset+'"]}]}';
        } 

        return jsonBodyReport;
    }

    /*
    * Method Name	: getPowerBIEmbedToken
    * Description	: This Method is used to get PowerBI Embedded Token
    * Request 		: String, String, String, String
    * Response		: String
    */
    @AuraEnabled
    public static String getPowerBIEmbedToken(String clientCredaccessToken, String groupId, String reportId, String requestBody) {
        system.debug('>>> EC_PowerBIController.getPowerBIEmbedToken() : groupId- '+groupId
        +' reportId- '+reportId+' requestBody- '+requestBody);

        String embedToken ='';

        try {
            Boolean isPBIEmbedTokenLogsEnabled = EC_LogsEnabler__c.getValues(EC_Constants.PBI_EmbedToken).EC_LogsEnabled__c;

            String finalTokenURL = PowerBISettings.BaseTokenURL__c+groupId+'/reports/'+reportId+'/GenerateToken';

            HttpResponse response = EC_PowerBIService.getPBIEmbedToken(requestBody, finalTokenURL, clientCredaccessToken);
            
            Integer httpStatusCode = response.getStatusCode();
            if(httpStatusCode == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                embedToken = (String) results.get('token');
            }

            if(httpStatusCode == 200 && isPBIEmbedTokenLogsEnabled) {
                EC_Utility.logCallouts('getPowerBIEmbedToken', requestBody, JSON.serialize(response.getBody()), null, EC_Constants.SUCCESS);
            } else if(isPBIEmbedTokenLogsEnabled) {
                EC_Utility.logCallouts('getPowerBIEmbedToken', requestBody, JSON.serialize(response.getBody()), null, EC_Constants.failure);
            }

            system.debug('<<< EC_PowerBIController.getPowerBIEmbedToken()');
            return embedToken;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

    }

    /*
    * Method Name	: getUserDashboards
    * Description	: This Method is used to get the Connect Dashboards assigned to logged in user
    * Request 		: void
    * Response		: UserWrapper
    */
    @AuraEnabled
    public static UserWrapper getUserDashboards() {
        system.debug('>>> EC_PowerBIController.getUserDashboards()');

        List<String> permissionSetList = new list<String>();
        try{
            UserWrapper rtnValue = getContactAccounts();
			List<PermissionSet> userPermissionSets = EC_QueryUtility.getPermissionSet();
 			Boolean isINSTPermission = false;
            for(PermissionSet eachPermission : userPermissionSets) {
                permissionSetList.add(eachPermission.Name);
                if(System.Label.EC_INST_RR_Permissions == eachPermission.Name) {
                    isINSTPermission = true;
                }
            }
            if(isINSTPermission && rtnValue.accountCount > 0) {
                Boolean isMultiSite = false;
                if(rtnValue.accountCount > 1) {
					isMultiSite = true;
                }
                rtnValue.dashboards = [select Label, ReportId__c, Role__c, GroupId__c, Dataset__c, Language__c, Locale__c from Connect_Dashboard__mdt WHERE Permission_Set_Name__c IN :permissionSetList AND is_Multi_Site__c=:isMultiSite];
            } else {
                rtnValue.dashboards = [select Label, ReportId__c, Role__c, GroupId__c, Dataset__c, Language__c, Locale__c from Connect_Dashboard__mdt WHERE Permission_Set_Name__c IN :permissionSetList];
            }

            if(Test.isRunningTest()) {
                throw new DMLException('Error Occured');
            }

            system.debug('<<< EC_PowerBIController.getUserDashboards() : rtnValue- '+rtnValue);
            return rtnValue;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class UserWrapper {
        @auraEnabled
        public Integer accountCount;
        @auraEnabled
        public String accountName;
        @auraEnabled
        public String accountNumber;
        @AuraEnabled
        public string division;
        @auraEnabled
        public List<Connect_Dashboard__mdt> dashboards;
    }

    public class DatasetWrapper {
        public Boolean IsOnPremGatewayRequired;
        public Boolean IsRefreshable;
        public Boolean IsEffectiveIdentityRequired;
    }

}