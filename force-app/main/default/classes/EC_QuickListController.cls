/* Class Name    : EC_QuickListController
 * Description      :Controller Class for Quick List Component
 * Created By       :Viraj
 * Created On       :2019-Aug-29
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Aug-29        BC-80775        Created the class   
 *
 */
public with sharing class EC_QuickListController {

     public Boolean viewPrice {get;set;}
     public Boolean buyOnline {get;set;}
     public PageReference pageURL {get;set;}
 /***************************************************************************************************************************************
  Constructor Name : EC_QuickListController
  Description : Constructor to initialize variables of EC_QuickListController to be used in the component
  Return type : N/A
 *************************************************************************************************************************************/
     public EC_QuickListController(){
        
        viewPrice = false;
        buyOnline = false;
        
        List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermissionCacheInfo();
        ccrz.ccLog.log('permWrapperLst54'+permWrapperLst);
        for(EC_Utility.PermWrapper perm : permWrapperLst){
            if(perm.permName == 'View Price'){
                viewPrice = perm.permVal;
            }
            if(perm.permName == 'Buy Online'){
                buyOnline= perm.permVal;
            }
        }
        pageURL = redirectToProductLandingPage();
    }
    
  /***************************************************************************************************************************************
  Method Name : redirectToProductLandingPage
  Description : redirectToProductLandingPage is use to form Url
  Return type : PageReference
 *************************************************************************************************************************************/
    
    public PageReference redirectToProductLandingPage(){
        Id categoryId = [select name from ccrz__E_Category__c where Name =:EC_Constants.PRODUCT_CATEGORY_NAME].Id ;
	    PageReference pReference = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/commerce/ccrz__ProductList?categoryId='+categoryId);
	    pReference.setRedirect(true);
	    return pReference;
    }
    
}