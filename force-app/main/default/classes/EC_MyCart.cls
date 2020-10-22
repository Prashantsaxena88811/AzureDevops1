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
        List<HeaderWrapper> lstRetVal = new List<HeaderWrapper>();
        Map<String, Object> inputData = new Map<String, Object>{
            ccrz.ccAPI.API_VERSION => 9,
                ccrz.ccApiMenu.STOREFRONT => Label.EC_StoreFront,
                ccrz.ccApiMenu.LOCALE => userInfo.getLocale()
                };

                    Map<String, Object> outputData = ccrz.ccApiMenu.fetch(inputData);

        List<Object> menuList = (List<Object>) outputData.get(ccrz.ccApiMenu.MENULIST);
        if(menuList != null && menuList.size() > 0){ // checks the menuList as not null
            for(Object men : menuList){
                Map<String,Object> menu = (Map<String,Object>) men;
                HeaderWrapper head = new HeaderWrapper();
                head.displayName = (String) menu.get(Label.EC_DisplayName);
                if(head.displayName==Label.EC_Header_Products){ //checks if the list is not blank then assign the values in header wrapper
                    head.url = EC_Utility.getCommunityUrl()+Label.EC_MyCart_ProdListUrl + (String)menu.get(Label.EC_LinkUrl);
                }else{
                    head.url = (String) menu.get(Label.EC_LinkUrl);
                }
                lstRetVal.add(head);
            }
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

}