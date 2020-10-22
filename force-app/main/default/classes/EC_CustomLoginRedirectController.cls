/* Class Name    : EC_CustomLoginRedirectController
 * Description      :Class to control the login redirection
 * Created By       :Ashish
 * Created On       :2019-7-5

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ashish                2019-7-5                                          Created the class   
 *
 */
global class EC_CustomLoginRedirectController {
    public static string startURL;
    /***************************************************************************************************************************************
  Constructor Name : EC_CustomLoginRedirectController 
  Description : N/A
  Return type : N/A
 *************************************************************************************************************************************/
    global EC_CustomLoginRedirectController () {        
        
    }
    
     /***************************************************************************************************************************************
  Method Name : redirectToCommunity
  Description : method to check user authorization and redirect user to login or community page based on authorization
  Return type : PageReference 
 *************************************************************************************************************************************/
    // Code we will invoke on page load.
    global PageReference redirectToCommunity() {
        startURL = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('startURL'));
        String pageUrl = Site.getBaseUrl();
        pageUrl = pageUrl.toLowerCase();
        if(pageURl.contains(System.label.EC_CommerceURLStorefron.toLowerCase())){
            pageURl = pageURl.substringBefore(System.label.EC_CommerceURLStorefron.toLowerCase());    
        }
        
        pageUrl = pageUrl + 's/login';
        PageReference pageRef = new PageReference(pageUrl);
        pageRef.getParameters().put('startURL',startURL);                                                 
        return pageRef;    
    }
    
    /***************************************************************************************************************************************
  Method Name : getCommunityURL
  Description : Fetched the community URL
  Return type : String 
 *************************************************************************************************************************************/
    @AuraEnabled
    public static String getCommunityURL(){
        String communityUrl = EC_Utility.getCommunityUrl();
        return communityUrl;
    }
    
/***************************************************************************************************************************************
  Method Name : getSamlSSOUrl
  Description : method to generate the SSO url
  Return type : String 
 *************************************************************************************************************************************/
    @AuraEnabled
    public static String getSamlSSOUrl(String startUrl){
        // String communityUrl = 'https://devec1-ecolabconnect--devec1.cs62.force.com';
        //  String startURL = 'https://devec1-ecolabconnect--devec1.cs62.force.com/DefaultStore/ccrz__MyAccount?cartId=ce51fa60-6192-4cb4-8c29-6b9f5c35a9b8&viewState=viewAccount&portalUser=&store=&cclcl=en_US';
        String communityUrl = EC_Utility.getCommunityUrl();
        String ssoUrl = '' ;
        
        if(!Test.isRunningTest()){            
            String samlId = getSamlID();
            ssoUrl = Auth.AuthConfiguration.getSamlSsoUrl(communityUrl, startURL, samlId);
        }
        ApexPages.PageReference lgn = new ApexPages.PageReference(ssoUrl);
        if(!Test.isRunningTest()){
            aura.redirect(lgn);
        }
        return ssoUrl;
    }
    
    /***************************************************************************************************************************************
  Method Name : getSelfRegistrationUrl
  Description : returns the selfregistration URL
  Return type : String
 *************************************************************************************************************************************/
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig ;
        authConfig= getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }
    
      /***************************************************************************************************************************************
  Method Name : getLoginUrl
  Description : returns the site login URL
  Return type : String 
 *************************************************************************************************************************************/
    @AuraEnabled
    public static String getLoginUrl() {
        return EC_Utility.getPageUrl();
    }
    
    /***************************************************************************************************************************************
  Method Name : getAuthConfig
  Description : helper method to get the standard Authorization config
  Return type : Auth.AuthConfiguration
 *************************************************************************************************************************************/
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }    
    
   /***************************************************************************************************************************************
  Method Name : getSamlID
  Description : helper method to get the SSO saml id
  Return type : String
 *************************************************************************************************************************************/
    @TestVisible
    private static String getSamlID(){        
        Auth.AuthConfiguration authConfig = getAuthConfig();
        
        String SamlId = '';
        
        List<SamlSsoConfig> ssoConfigList = authConfig.getSamlProviders();
        for(SamlSsoConfig sso : ssoConfigList){
            if(sso.DeveloperName == System.Label.EC_SSO_Developer){
                SamlId = sso.Id;
            }
        }
        return SamlId;
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