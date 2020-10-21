/* Class Name    : EC_HeaderController
 * Description      :Controller Class for Header Component
 * Created By       :Viraj
 * Created On       :2019-Jul-4
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Jul-4         BC-76699        Created the class   
 *
 */
public class EC_HeaderController {
    
    public string LogoutURL{get;set;}
    public string userId{get;set;}
    public string userDivision{get;set;}
     public Boolean buyOnline{get;set;}
    public Boolean viewPrice {get;set;}
    public Boolean viewDashboard {get;set;}
    public Boolean isCommunityActive{get;set;}
    public boolean isEligible{get;set;}
    /***************************************************************************************************************************************
    Constructor Name : EC_HeaderController
    Description : Constructor to initialize variables of EC_HeaderController to be used in the component
    Return type : N/A
    *************************************************************************************************************************************/
    public EC_HeaderController(){
        
       // List<EC_URL__mdt> urlLst = [SELECT EC_URL__c from EC_URL__mdt where DeveloperName='EC_LogoutURL' LIMIT 1];
       // LogoutURL=urlLst[0].EC_URL__c;
        
        Id networkId = Network.getNetworkId();
        String loginURL = Network.getLoginUrl(networkId);
        String communityURL;
        String storeName  = System.Label.EC_CommerceURLStorefron;
        if(networkId !=null && loginURL.containsIgnoreCase(storeName)){
            loginURL = loginURL.substringBefore(storeName);
       }
        
        LogoutURL = '/secur/logout.jsp?retUrl='+ loginURL + 's/login';
        userId = UserInfo.getUserId();
        viewDashboard = false;
        buyOnline = false;
        isEligible = checkPayerPermission();
        if (!Account.sObjectType.getDescribe().isAccessible()) {
	 		return;
	 	}
        Account effAcc = [Select EC_Division__c from Account Where Id=:ccrz.cc_CallContext.effAccountId Limit 1];
        userDivision = effAcc.EC_Division__c;
        //List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermCache();
        List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermissionCacheInfo();
        ccrz.ccLog.log('permWrapperLst54'+permWrapperLst);
        for(EC_Utility.PermWrapper perm : permWrapperLst){
            if(perm.permName == 'View Dashboard'){
                viewDashboard= perm.permVal;
            }
            if(perm.permName == 'Buy Online'){
                buyOnline= perm.permVal;
            }
            if(perm.permName == 'View Price'){
                viewPrice = perm.permVal;
            }
        }

        List<EC_OutageFlag__c> outFlag = [SELECT EC_isCommunityActive__c from EC_OutageFlag__c where Name ='CommunityActive'];
        if(outFlag.size()>0){
            isCommunityActive = outFlag[0].EC_isCommunityActive__c;
        }
    }
    /************************************************************************************************************************************
	Method Name : checkPayerPermission
    Description : to check whether payer permission is there for user.
    Return type : Boolean
	PBI: 117174
    *************************************************************************************************************************************/
     public static Boolean checkPayerPermission(){
       return FeatureManagement.checkPermission(EC_Constants.PayerCustomPermission);
    }
}