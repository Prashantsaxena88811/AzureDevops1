/* Class Name       :	EC_ccServiceWishList
 * Description      :	To render wishlist pages
 * Created By       : 	Venkatesh & Rajeshwar
 * Created On       :	2020-05-02
 * Modification Log	:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Venkatesh & Rajeshwar        2020-05-02                              Created the class   
 */
global with sharing class EC_ccServiceWishList extends ccrz.ccServiceWishList{
    /***************************************************************************************************************************************
    Method Name : getFilterMap
    Description : This method has been overridden to fetch the Wishlists only for current effective account for iBuy user
    Return type : Map<String, Object>
    *************************************************************************************************************************************/    
    global override Map<String, Object> getFilterMap(Map<String, Object> inputData) {
        
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Ecolab Connect iBuy CCP User'];
        Id profileId = UserInfo.getProfileId();
        Map<String, Object> ccInputData = super.getFilterMap(inputData);
        if (userProfile.Id == profileId && ccInputData != null) {
            String wishListType = (String) ccInputData.get('WLTYPE');
            wishListType = wishListType + ' AND ccrz__EffectiveAccountID__c = \''+ccrz.cc_CallContext.effAccountId+'\'';
            ccInputData.put('WLTYPE', wishListType );
		}
        
        return ccInputData;
    }
}