/*******************************************************************************************************************
* Apex Class Name     : EC_MyCart
* Created Date        : 18 July 2019
* Description         : Class to make header component links working
* Developer                        Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Ayusha Patnaik                  10/06/2019              Original Version
*************************************************************************************************************************/
public without sharing class EC_MyCart {

/************************************************************************************************************************************
Method Name : cartInfoLoad
Description : to load mini cart with the active cart of user.
Parameter   : void
Return type : Class
Author      : Raghav Sharma
*************************************************************************************************************************************/

    @AuraEnabled
    public static CartWrapper cartInfoLoad(){
        CartWrapper cart = new CartWrapper();
            cart.UserName = UserInfo.getName();

            List<ccrz__E_Cart__c> lstCart = EC_QueryUtility.getActiveCart();
            if(lstCart != null && lstCart.size()>0){ //checks if the list is not blank then assign the values wrapper
                cart.totalAmount = String.valueOf(lstCart[0].ccrz__TotalAmount__c);
                cart.totalItems = String.valueOf(lstCart[0].ccrz__TotalQuantity__c);
                cart.cartUrl = Label.EC_MyCartUrl+Label.EC_UrlHeader+lstCart[0].ccrz__EncryptedId__c+
                    Label.EC_UrlMiddle+lstCart[0].ccrz__EffectiveAccountID__c;
            } else {
                cart.totalAmount = Label.EC_DefaultAmount;
                cart.totalItems = Label.EC_Header_cartVal;
            }

        return cart;
    }

/************************************************************************************************************************************
Method Name : getHeaderLinks
Description : to form the header name and url.
Parameter   : void
Return type : List<>
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    @AuraEnabled(cacheable=true)
        public static List<HeaderWrapper> getHeaderLinks(){
            Boolean enableIntelligence = false;
            Boolean isBasicBuyerCheck = false;
            List<String> dashboardPermissions = new List<String>();
            
            for(Permision_Set_Mapping__mdt eachDashboard : [SELECT Permission_Set_Name__c FROM Permision_Set_Mapping__mdt WHERE Is_DashBoard__c = true]) {
                dashboardPermissions.add(eachDashboard.Permission_Set_Name__c);
            }
    
            List<HeaderWrapper> lstRetVal = new List<HeaderWrapper>();
            Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => 9,
                    ccrz.ccApiMenu.STOREFRONT => Label.EC_StoreFront,
                    ccrz.ccApiMenu.LOCALE => userInfo.getLocale()
                    };
    
            Map<String, Object> outputData = ccrz.ccApiMenu.fetch(inputData);
            
            List<Object> menuList = (List<Object>) outputData.get(ccrz.ccApiMenu.MENULIST);
            EC_CacheWrapper userCache = EC_CacheHelper.getCacheInfo();
            
            for(PermissionSet eachPermission : userCache.lstPermisssionSet ) {
                if(eachPermission.Name == EC_Constants.BasicPermissionSet|| eachPermission.Name == EC_Constants.BuyerPermissionSet) {
                    isBasicBuyerCheck = true;
                }
                else if(dashboardPermissions.contains(eachPermission.Name)) {
                    enableIntelligence = true;
                }
            }

            lstRetVal = getHeaderLinksHelper(userCache, menuList, isBasicBuyerCheck, enableIntelligence);
            
            return lstRetVal;
        }

/************************************************************************************************************************************
    Method Name : getHeaderLinksHelper
    Description : Helper Method to split the Header Link Load
    Parameter   : EC_CacheWrapper, List<Objecy>, Boolean, Boolean
    Return type : List<HeaderWrapper>
    *************************************************************************************************************************************/
        private static List<HeaderWrapper> getHeaderLinksHelper(EC_CacheWrapper userCache, List<Object> menuList, Boolean isBasicBuyerCheck, Boolean enableIntelligence) {
            String communityUrl = EC_Utility.getCommunityUrl();
            
            Map<String,String> mapDisplayNamevsUrl = new Map<String,String>();
            mapDisplayNamevsUrl.put(Label.EC_Header_Products,communityUrl + Label.EC_MyCart_ProdListUrl);
            mapDisplayNamevsUrl.put(Label.EC_BillingArrangement,communityUrl +'/'+EC_Constants.PUNCHOUT_DEFAULTSTORE+'/');

            List<HeaderWrapper> lstRetVal = new List<HeaderWrapper>();

            for(Object men : menuList) {
                Map<String,Object> menu = (Map<String,Object>) men;
                    HeaderWrapper head = new HeaderWrapper();
                    head.displayName = (String) menu.get(Label.EC_DisplayName);
                
                    if(mapDisplayNamevsUrl.containsKey(head.displayName))
                    {
                        head.url = mapDisplayNamevsUrl.get(head.displayName)+ (String)menu.get(Label.EC_LinkUrl);
                    } else
                    {
                        head.url = (String) menu.get(Label.EC_LinkUrl);
                    }
                    
                    //Skipping Billing Arrangement
                    lstRetVal = hideMenus(lstRetVal, head, isBasicBuyerCheck, enableIntelligence);
    
                   //Adding Billing Arrangement, if atleast one Nalco Account exists for the logged in contact
                    if(userCache!=NULL && userCache.hasNalcoAccount == true)
                    {
                        head.hasNalcoAccount = true;
                    }             
            }
            return lstRetVal;
        }

/************************************************************************************************************************************
Method Name : hideMenus
Description : Helper Method to handle Pest Menu
Parameter   : List<HeaderWrapper>, HeaderWrapper, Boolean, Boolean
Return type : List<HeaderWrapper>
*************************************************************************************************************************************/
    private static List<HeaderWrapper> hideMenus(List<HeaderWrapper> lstRetVal, HeaderWrapper head, Boolean isBasicBuyerCheck, Boolean enableIntelligence) {
        List<String> pestHideMenus = new List<String> {'PRODUCTS','ORDERS','INTELLIGENCE'};

        if(head.displayName != Label.EC_BillingArrangement)
        {
            if(!isBasicBuyerCheck && !pestHideMenus.contains(head.displayName.toUpperCase())) {
                lstRetVal.add(head);
            }
            else if(isBasicBuyerCheck && head.displayName.toUpperCase() != EC_Constants.INTELLIGENCE) {
                lstRetVal.add(head);
            }
        }
    
        if(enableIntelligence && head.displayName.toUpperCase() == EC_Constants.INTELLIGENCE) {
            lstRetVal.add(head);
        }

        return lstRetVal;
    }
/************************************************************************************************************************************
Method Name : getContact
Description : to form the header name and url.
Parameter   : void
Return type : List<>
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    @auraEnabled
    public static String getContact(){


       User usr =  EC_QueryUtility.getCurrentUser() ;
        String UserName = usr.Name ;
        return UserName ;


    }

/***************************************************************************************************************************************
Method Name : isBasicBuyerCheck
Description : Check Basic Buyer PermissionSet
Parameter   : N/A
Return type : Boolean
*************************************************************************************************************************************/
@auraEnabled
public static Boolean isBasicBuyerCheck() {
    Boolean rtnValue = false;
    try {
        EC_CacheWrapper userCache = EC_CacheHelper.getCacheInfo();

        for(PermissionSet eachPermission : userCache.lstPermisssionSet ) {
            if(eachPermission.Name == EC_Constants.BasicPermissionSet || eachPermission.Name == EC_Constants.BuyerPermissionSet) {
                rtnValue = true;
            }
        }
        return rtnValue;
    }
    catch(Exception ex) {
        throw new AuraHandledException(ex.getMessage());
    }
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
/************************************************************************************************************************************
Method Name : getLogoutUrl
Description : to form the logout url.
Parameter   : void
Return type : String
Author      : Ayusha Patnaik
*************************************************************************************************************************************/


    @auraEnabled
    public static String getLogoutUrl(){
         EC_CacheHelper.clearCache();
        Id networkId = Network.getNetworkId();
        String loginURL = Network.getLoginUrl(networkId);
        String communityUrl = '';
        String redirectURL = '';
        communityUrl = EC_Utility.getCommunityUrl();
        redirectURL = communityUrl + Label.EC_MyCart_LogoutUrl+loginURL;
        return redirectURL;
    }

/************************************************************************************************************************************
Method Name : getQuickListUrl
Description : to form the quicklist url.
Parameter   : void
Return type : String
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    @auraEnabled
    public static String getQuickListUrl(){
        Id networkId = Network.getNetworkId();
        String loginURL = Network.getLoginUrl(networkId);

        String communityUrl = '';
        String redirectURL = '';
        communityUrl = EC_Utility.getCommunityUrl();
        redirectURL = communityUrl + Label.EC_MyCart_MyAccountUrl;
        return redirectURL;
    }

/************************************************************************************************************************************
Method Name : cartQuantity
Description : to form the quicklist url.
Parameter   : void
Return type : Class
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    @auraEnabled
    public static CartInfo cartQuantity(){
        CartInfo ci = new CartInfo();
        List<ccrz__E_Cart__c> cartVal = EC_QueryUtility.getActiveOpenCart();
        if(cartVal != null && cartVal.size() > 0){ //checks if the list is not null.
        ci.cartItemNo = String.valueOf(cartVal[0].ccrz__TotalQuantity__c);
        String cartURL = EC_Utility.getCommunityUrl() +Label.EC_UrlHeader+ cartVal[0].ccrz__EncryptedId__c +Label.EC_UrlMiddle+ cartVal[0].ccrz__EffectiveAccountID__c + Label.EC_UrlFooter+ userInfo.getLocale();
        ci.cartURL = cartURL;
    }
        return ci;
}
/************************************************************************************************************************************
Method Name : compVisible
Description : to get the permission from cache.
Parameter   : void
Return type : List<EC_Utility.PermWrapper>
Author      : Ayusha Patnaik
*************************************************************************************************************************************/
    @auraEnabled
    public static List<EC_Utility.PermWrapper>  compVisible(){
        return  EC_Utility.getPermCache();
    }

/************************************************************************************************************************************
Method Name : CartInfo
Description : wrapper class to store cartItem and cartUrl.
Parameter   : void
Return type : void
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    public class CartInfo{
        @AuraEnabled
        public String cartURL,cartItemNo;
    }

/************************************************************************************************************************************
Method Name : HeaderWrapper
Description : wrapper class to store headerName and url.
Parameter   : void
Return type : void
Author      : Ayusha Patnaik
*************************************************************************************************************************************/

    public class HeaderWrapper {
        @AuraEnabled
        public String displayName, url;
        @AuraEnabled
        public Boolean hasNalcoAccount = false;
    }

/************************************************************************************************************************************
Method Name : CartWrapper
Description : wrapper class to store totalItems,totalAmount, UserName, cartUrl
Parameter   : void
Return type : void
Author      : Raghav Sharma
*************************************************************************************************************************************/

    public class CartWrapper {
        @AuraEnabled
        public String totalItems,totalAmount, UserName, cartUrl;
    }
    /************************************************************************************************************************************
	Method Name : checkPayerPermission
    Description : to check whether payer permission is there for user.
    Return type : Boolean
	PBI: 117174
    *************************************************************************************************************************************/
   @AuraEnabled public static  Boolean checkPayerPermission(){
       try{
        return FeatureManagement.checkPermission(EC_Constants.PayerCustomPermission);
       }
       catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
    }
    /*******************************************************************************************
    * @description: UserInfo
    * @param: 
    * @return: String
    *************************************************************************************************/
    @auraEnabled
    public static String getUserAccountDivision(){
        String userDivision = ''; 
        system.debug('userDivision:'+userDivision);
        if (!user.sObjectType.getDescribe().isAccessible()) {
	 		return userDivision;
	 	}
        User u= [select Id,contact.account.EC_Division__c from user where Id =: UserInfo.getUserId()];
		if(u != null && u.contact != null && u.contact.account != null){
            userDivision = u.contact.account.EC_Division__c;
        } 
        system.debug('userDivision:'+userDivision);
        return userDivision;
    } 
}