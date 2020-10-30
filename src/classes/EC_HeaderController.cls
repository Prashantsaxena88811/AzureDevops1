/* Class Name    : EC_HeaderController
 * Description      :Controller Class for Header Component
 * Created By       :Viraj
 * Created On       :2019-Jul-4


 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Jul-4      BC-76699                Created the class
 * lgcarrier@Coveo          2019-Sept-29                            Add function: getCoveoVariables
 */
public class EC_HeaderController {

    public string LogoutURL{get;set;}
    public string userId{get;set;}
    public string userDivision{get;set;}
    public Boolean buyOnline{get;set;}
    public string buyerPerm{get;set;}
    public Boolean viewPrice {get;set;}
    public string BAUser {get;set;}
    public Boolean viewDashboard {get;set;}
    public Boolean isCommunityActive{get;set;}
    public boolean isEligible{get;set;}
    public String hasNalcoAccount{get;set;}
    public Boolean enableIntelligence{get;set;}

    // COVEO START
    public String coveoUserFilters{get;set;}
    public String coveoCommerceQueryListing{get;set;}

    //Coveo Query format to fetch products matching entitlements (Nested query)
    static final String FILTER_TEMPLATE = '@objecttype==ccrz__E_Product__c [[@sfccrz_product_id] @sfccrz__pricelist__c==({0})]';

    // COVEO END

    /***************************************************************************************************************************************
    Constructor Name : EC_HeaderController
    Description : Constructor to initialize variables of EC_HeaderController to be used in the component
    Return type : N/A
    *************************************************************************************************************************************/
    public EC_HeaderController(){

       // List<EC_URL__mdt> urlLst = [SELECT EC_URL__c from EC_URL__mdt where DeveloperName='EC_LogoutURL' LIMIT 1];
       // LogoutURL=urlLst[0].EC_URL__c;

        getLogOutURL();
        userId = UserInfo.getUserId();
        isEligible = checkPayerPermission();

        getEffectiveAccountDivision();
        checkForNalcoAccount();
        getPermissionSets();
        isIntelligenceEnabled();
        getCoveoVariables();

        if(EC_OutageFlag__c.sObjectType.getDescribe().isAccessible())
        {
            List<EC_OutageFlag__c> outFlag = [SELECT EC_isCommunityActive__c from EC_OutageFlag__c where Name ='CommunityActive'];
            if(outFlag.size()>0)
            {
                isCommunityActive = outFlag[0].EC_isCommunityActive__c;
            }
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

     /************************************************************************************************************************************
    Method Name : getLogOutURL
    Description : sets the log out URL.
    Return type : void
    *************************************************************************************************************************************/
    private void getLogOutURL(){
        Id networkId = Network.getNetworkId();
        String loginURL = Network.getLoginUrl(networkId);
        String communityURL;
        String storeName  = System.Label.EC_CommerceURLStorefron;
        if(networkId !=null && loginURL.containsIgnoreCase(storeName)){
            loginURL = loginURL.substringBefore(storeName);
       }
        LogoutURL = '/secur/logout.jsp?retUrl='+ loginURL + 's/login';
     }


    /************************************************************************************************************************************
    Method Name : getEffectiveAccountDivision
    Description : getting Effective Account's Division.
    Return type : void
    *************************************************************************************************************************************/
    private void getEffectiveAccountDivision(){
     if (!Account.sObjectType.getDescribe().isAccessible()) {
	 		return;
	 	}
        Account effAcc = [Select EC_Division__c from Account Where Id=:ccrz.cc_CallContext.effAccountId Limit 1];
        userDivision = effAcc.EC_Division__c;

    }

      /************************************************************************************************************************************
    Method Name : getPermissionSets
    Description : getting permission sets.
    Return type : void
    *************************************************************************************************************************************/
    private void getPermissionSets(){
        viewDashboard = false;
        buyOnline = false;
        BAUser = 'false';
        List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermissionCacheInfo();
        ccrz.ccLog.log('permWrapperLst54'+permWrapperLst);
        for(EC_Utility.PermWrapper perm : permWrapperLst){
            if(perm.permName == 'View Dashboard'){
                viewDashboard= perm.permVal;
            }
            if(perm.permName == 'Buy Online'){
                buyOnline= perm.permVal;
                buyerPerm = string.valueof(perm.permVal);
            }
            if(perm.permName == 'View Price'){
                viewPrice = perm.permVal;
            }
            if(perm.permName == 'Billing Arrangement'){
                BAUser = String.valueof(perm.permVal);
            }

        }
    }

    /************************************************************************************************************************************
    Method Name : checkForNalcoAccount
    Description : to check atleast one Nalco account exist for the logged in contact.
    Return type : void
    *************************************************************************************************************************************/
    private void checkForNalcoAccount(){
        EC_CacheWrapper userCache = EC_CacheHelper.getCacheInfo();
        if(userCache!=NULL && userCache.hasNalcoAccount)
        {
            hasNalcoAccount = 'true';
            return;
        }
        hasNalcoAccount = 'false';
    }

    /************************************************************************************************************************************
    Method Name : isIntelligenceEnabled
    Description : Check if user has access to Intelligence tab
    Return type : void
    *************************************************************************************************************************************/
    private void isIntelligenceEnabled(){
        enableIntelligence = false;
        List<String> dashboardPermissions = new List<String>();

        EC_CacheWrapper userCache = EC_CacheHelper.getCacheInfo();

        for(Permision_Set_Mapping__mdt eachDashboard : [SELECT Permission_Set_Name__c FROM Permision_Set_Mapping__mdt WHERE Is_DashBoard__c = true]) {
            dashboardPermissions.add(eachDashboard.Permission_Set_Name__c);
        }

        for(PermissionSet eachPermission : userCache.lstPermisssionSet ) {
            if(dashboardPermissions.contains(eachPermission.Name)) {
                enableIntelligence = true;
            }
        }
    }

    /************************************************************************************************************************************
    Method Name : getCoveoVariables
    Description : public method to generate filter for Coveo Search Interface
    Return type : String
    *************************************************************************************************************************************/
    private void getCoveoVariables() {
        EC_CoveoProductListController coveoProductListController = new EC_CoveoProductListController();
        coveoUserFilters = coveoProductListController.getFilters();
        coveoCommerceQueryListing = coveoProductListController.getCommerceQueryListing();
    }
}