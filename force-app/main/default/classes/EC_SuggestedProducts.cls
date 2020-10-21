/* Class Name    : EC_SuggestedProducts 
 * Description      :Controller Class for Suggested Product Component
 * Created By       :Ashish
 * Created On       :2019-Jun-26
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ashish            2019-Jun-26         BC-74097        Created the class   
 *
 */
global class EC_SuggestedProducts {
    
    public Boolean viewPrice {get;set;}
    public Boolean buyOnline {get;set;}
    /***************************************************************************************************************************************
    Constructor Name : EC_SuggestedProducts
    Description : set the field values to be used in the component
    **************************************************************************************************************************************/
    public EC_SuggestedProducts (){
        
        viewPrice = false;
        buyOnline = false;
        List<EC_Utility.PermWrapper> permWrapperLst =   new List<EC_Utility.PermWrapper>();
        permWrapperLst =   EC_Utility.getPermissionCacheInfo();
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
  Method Name : addToCartItems
  Description : adds suggested product items to the cart
  Return type : Returns ccrz.cc_RemoteActionResult
 **************************************************************************************************************************************/
    @RemoteAction
        global static ccrz.cc_RemoteActionResult addToCartItems(final ccrz.cc_RemoteActionContext ctx, list<EC_SuggestedProductWrapper> listAddToCartProducts, String encryptCart){
         
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult res;
        res = new ccrz.cc_RemoteActionResult();
        
        res.success = false;
        
        Map<String,Object> createResults;
        map<String,Object> theNewLine;
        List<map<String,Object>> theNewLines;
        theNewLines = new List<map<String,Object>>();
        try{
            if(listAddToCartProducts!=null){
                for(EC_SuggestedProductWrapper objItem:listAddToCartProducts){
                    if(objItem.sku!=null && objItem.quantity!=null){
                        theNewLine = new map<String,Object>();
                        theNewLine.put(ccrz.ccApiCart.LINE_DATA_SKU,objItem.sku);
                        theNewLine.put(ccrz.ccApiCart.LINE_DATA_QUANTITY,objItem.quantity);
                        theNewLines.add(theNewLine);
                    }
                }
            }
            if(theNewLines!=null && !theNewLines.isempty()){
                createResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
                                                ccrz.ccApi.API_VERSION => 6,
                                                ccrz.ccApiCart.CART_ENCID =>(string.isBlank(encryptCart))?null:encryptCart,
                                                ccrz.ccApiCart.LINE_DATA => theNewLines                                                 
                });
            }
            //ccrz.ccLog.log(System.LoggingLevel.INFO, 'LSB: cart creation' + createResults);
            
            res.success=true;
            res.data = (String)createResults.get(ccrz.ccApiCart.CART_ENCID);
        }catch (Exception error){
            System.debug('Exception-->'+error.getCause() + ' '+ error.getLineNumber() + ' '+ error.getStackTraceString() +' '+error.getTypeName());
        }
        ccrz.ccLog.close(res);
        return res;
    }

}