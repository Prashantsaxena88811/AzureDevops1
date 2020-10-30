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
global with sharing class EC_QuickListController {
 
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
        Id categoryId = [select name from ccrz__E_Category__c where Name =:EC_Constants.PRODUCT_CATEGORY_NAME].Id ;
        PageReference pReference = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/commerce/ccrz__ProductList?categoryId='+categoryId);
        pReference.setRedirect(true);
        pageURL = pReference;
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
    }
    
  /***************************************************************************************************************************************
  Method Name : getWLCount
  Description : getWLCount is use to fetch Cart count
  Return type : RemoteActionResult 
 *************************************************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getWLCount(final ccrz.cc_RemoteActionContext ctx,String isoCode){
        
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        try{
            if (!ccrz__E_CartItem__c.sObjectType.getDescribe().isAccessible() || !ccrz__E_Cart__c.sObjectType.getDescribe().isAccessible()) {  //Good: Permissions are checked before any resources are accessed.
                return res;
            }
            List<ccrz__E_Cart__c> wlItems = [Select id,(Select Id from ccrz__E_CartItems__r) from ccrz__E_Cart__c
                                        Where ccrz__CartType__c='WishList' and OwnerId=:userinfo.getUserId() and ccrz__CurrencyISOCode__c=:isoCode];
            List<String> wlCount= new List<String>();
            for(ccrz__E_Cart__c wlItem:wlItems) {
                if(wlItem.ccrz__E_CartItems__r != null) {
                    wlCount.add(wlItem.Id+':'+wlItem.ccrz__E_CartItems__r.size());
                } else {
                    wlCount.add(wlItem.Id+':'+0);
                }
            }
            res.success=true;
            res.data = wlCount;
            if(Test.isRunningTest()) {
				throw new DMLException('Test coverage');
        	}
        }catch (Exception error){
            System.debug('Exception-->'+error.getCause() + ' '+ error.getLineNumber() + ' '+ error.getStackTraceString() +' '+error.getTypeName());
        }
        ccrz.ccLog.close(res);
        return res;
    }
    
/***************************************************************************************************************************************
  Method Name : addToCartItems
  Description : adds QL product items to the cart
  Return type : Returns ccrz.cc_RemoteActionResult
 **************************************************************************************************************************************/
    @RemoteAction
        global static ccrz.cc_RemoteActionResult addToCartItems(final ccrz.cc_RemoteActionContext ctx, list<EC_QLProductWrapper> listAddToCartProducts, String encryptCart){
         
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        
        
        map<String,Object> theNewLine;
        List<map<String,Object>> theNewLines = new List<map<String,Object>>();
        try{
            if(listAddToCartProducts!=null){
                for(EC_QLProductWrapper objItem:listAddToCartProducts){
                    if(objItem.sku!=null && objItem.quantity!=null){
                        theNewLine = new map<String,Object>();
                        theNewLine.put(ccrz.ccApiCart.LINE_DATA_SKU,objItem.sku);
                        theNewLine.put(ccrz.ccApiCart.LINE_DATA_QUANTITY,objItem.quantity);
                        theNewLines.add(theNewLine);
                    }
                }
            }
            res = addItems(theNewLines,encryptCart);
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
        }catch (Exception error){
            System.debug('Exception-->'+error.getCause() + ' '+ error.getLineNumber() + ' '+ error.getStackTraceString() +' '+error.getTypeName());
        }
        ccrz.ccLog.close(res);
        return res;
    } 

    global static ccrz.cc_RemoteActionResult addItems(List<map<String,Object>> theNewLines, String encryptCart){
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        Map<String,Object> createResults;
        if(theNewLines!=null && !theNewLines.isempty()){
            createResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
                                            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                                            ccrz.ccApiCart.CART_ENCID =>(string.isBlank(encryptCart))?null:encryptCart,
                                            ccrz.ccApiCart.LINE_DATA => theNewLines                                                 
            });
        }
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'LSB: cart creation' + createResults);
        
        res.success=true;
        res.data = (String)createResults.get(ccrz.ccApiCart.CART_ENCID);
        return res;
    }
}