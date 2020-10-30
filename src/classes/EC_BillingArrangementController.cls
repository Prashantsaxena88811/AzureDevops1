/* Class Name      : EC_BillingArrangementController
* Description      :Controller Class for Billing Arrangement and Billing Arrangement Detail PAge
* Created By       :Moin Sawar
* Created On       :2020-Aug-27


* Modification Log:
* ---------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ---------------------------------------------------------------------------------------------------------------------
* Moin Sawar            2020-Aug-27         PBI-                    Created the class
*
*/
global with sharing class EC_BillingArrangementController {
    //public List<baWrapper> bas{get;set;}
    public String baJSON {get;set;}
    public class baWrapper{
        public String profile{get;set;}
        public String baNumber{get;set;}
        public String baId{get;set;}
        public String baType{get;set;}
        public String baDesc{get;set;}
        public String startDate{get;set;}
        public String EndDate{get;set;}
        public List<ItemWrapper> prodLineItems {get;set;}
        public List<ItemWrapper> ItemWrapper{get;set;}
    }
    public class ItemWrapper{
        public Decimal price{get;set;}
        public String taxonomy{get;set;}
        public String customPricingUOM{get;set;}
        public Decimal customUnitPrice{get;set;}
        public String packageTypeUOM{get;set;}
        Public Integer PricePer{get;set;}
        public String startDate{get;set;}
        public String EndDate{get;set;}
        public ccrz__E_Product__c product{get;set;}
        public List<ccrz__E_PriceListItem__c> priceListItem{get;set;}
        public String uri{get;set;}
    }

    public class ProfileAndBAWrapper
    {
        public String loggedInUserProfile{get;set;}
        public List<baWrapper> baWrapper{get;set;}
        public ProfileAndBAWrapper(String loggedInUserProfile,List<baWrapper> baWrapper)
        {
            this.loggedInUserProfile=loggedInUserProfile;
            this.baWrapper = baWrapper;
        }
    } 

    public Boolean checkNALCO(){
        return true;
    }    
    
    /***************************************************************************
  Method Name : getBANums
  Description : queries all the pricelists 
  Return type : ccrz.cc_RemoteActionResult
***********************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getBANums(final ccrz.cc_RemoteActionContext ctx, string effAccountId) {
        
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        try { 
            Set<String> BATypeSet = new Set<String>();
            List<Billing_Arrangement_Types__mdt> BATypes = new List<Billing_Arrangement_Types__mdt>();
            if(Billing_Arrangement_Types__mdt.sObjectType.getDescribe().isAccessible()){
                BATypes = [Select Label,BA_Type_Code__c,Active__c,Applicable_On_BADP__c from Billing_Arrangement_Types__mdt where Active__c = true AND Applicable_On_BADP__c =true];
                for (Billing_Arrangement_Types__mdt BAType : BATypes) {
                    BATypeSet.add(BAType.Label);
                }
            }
            
            List<baWrapper> baWrapperList =new List<baWrapper> ();
            Date today = Date.today();
            if(Account.sObjectType.getDescribe().isAccessible() && String.isNotBlank(effAccountId)){             
                List<Account> effAccountList = [Select Id,EC_SalesOrg__c,EC_Division__c,ccrz__E_AccountGroup__c FROM Account WHERE Id=:effAccountId LIMIT 1];
                if(ccrz__E_PriceList__c.sObjectType.getDescribe().isAccessible()){                                       
                    for(ccrz__E_PriceList__c pl: [select ID, BA_Allocated__c,Name,BA_Number__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__Desc__c,Price_List_Type_Expansion__c from ccrz__E_PriceList__c where EC_Price_List_Type__c IN: BATypeSet and ccrz__StartDate__c <= :today and ccrz__EndDate__c>=:today and ccrz__Enabled__c = true 
                                                  AND ID IN (select ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c where ccrz__AccountGroup__c=:effAccountList[0].ccrz__E_AccountGroup__c and ccrz__StartDate__c <= :today and ccrz__EndDate__c>=:today and ccrz__Enable__c = true)  order by ccrz__Desc__c asc ] ){
                                                      baWrapper baWrapperObj = new baWrapper();
                                                      baWrapperObj.baNumber = pl.BA_Number__c;
                                                      baWrapperObj.baId = pl.ID;
                                                      baWrapperObj.baType = pl.Price_List_Type_Expansion__c;
                                                      baWrapperObj.baDesc = pl.ccrz__Desc__c;
                                                      DateTime startDate = pl.ccrz__StartDate__c;
                                                      DateTime EndDate = pl.ccrz__EndDate__c;                         
                                                      String formattedordStartDate = startDate.formatGMT(EC_Constants.MMM)+' '+startDate.formatGMT(EC_Constants.d)+', '+startDate.formatGMT(EC_Constants.yyyy);
                                                      String formattedordEndDate = EndDate.formatGMT(EC_Constants.MMM)+' '+EndDate.formatGMT(EC_Constants.d)+', '+EndDate.formatGMT(EC_Constants.yyyy);
                                                      baWrapperObj.startDate = formattedordStartDate; 
                                                      baWrapperObj.EndDate = formattedordEndDate; 
                                                      baWrapperObj.profile = EC_QueryUtility.getProfile();  
                                                      baWrapperList.add(baWrapperObj);
                                                  }
                } 
                ProfileAndBAWrapper varWrapper = new ProfileAndBAWrapper(EC_QueryUtility.getProfile(),baWrapperList);
                res.success = true;
                res.data = varWrapper;
            }
        } catch(Exception ex) {
            system.debug('Exception occured on saving Billing Arrangement'+ ex.getMessage());
        }
        ccrz.cclog.log('saveBillingArrangement: ' , + res);
        return res;
    }        
/***************************************************************************
  Method Name : getBADetail
  Description : queries the price list item for particular Price List.
  Return type : ccrz.cc_RemoteActionResult
***********************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getBADetail(final ccrz.cc_RemoteActionContext ctx, string baId) {
         
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        try {
            EC_BillingArrangementDetailHelper.fetchBADPData(res,baId);  
        } catch(Exception ex) {
            system.debug('Exception occured on saving Billing Arrangement'+ ex.getMessage());
        }
        ccrz.cclog.log('saveBillingArrangement: ' , + res);
        return res;
    }
    
/***************************************************************************
  Method Name : getPackageCode
  Description : return package code set.
  Return type : Set<String>
***********************************************************************************/
    
    public static Set<String> getPackageCode(){
        
        List<Chemical_Product_Type__c> pkgTypes = new List<Chemical_Product_Type__c>();
        pkgTypes = Chemical_Product_Type__c.getall().values();
        Set<String> pkgCodeSet = new Set<String>();
            for (Chemical_Product_Type__c pkgType : pkgTypes) {
                if(pkgType.Active__c == true) {
                    pkgCodeSet.add(pkgType.Package_Code__c);
                }
            }
        
        return pkgCodeSet;
    }

    /****************************************************************
Method Name : addToCartBADP
Description : add to cart from BADP
Return type : ccrz.cc_RemoteActionResult
**********************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult addToCartBADP(final ccrz.cc_RemoteActionContext ctx, string productId, string cartEncId,String baSFID) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        Savepoint sp = Database.setSavepoint();
        Boolean wasSuccessful = false;
        List<Map<string,Object>> cartItemsToInsert = new List<Map<string,Object>>();
        Map<string,Object> cartItem = new Map<string,Object>{
            'productId' => productId,
            ccrz.ccApiCart.LINE_DATA_QUANTITY => 1,
            'baSFID' => baSFID
        };
        cartItemsToInsert.add(cartItem);
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'cartItemsToInsert',cartItemsToInsert);
        
        try {
            Map<String,Object> addResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.CART_ENCID => cartEncId,
                    ccrz.ccApiCart.LINE_DATA => cartItemsToInsert
                    });          
            //General check, since the cart Id will be blank if not successful we technically do not need this.
            wasSuccessful = (Boolean)addResults.get(ccrz.ccApi.SUCCESS);
            res.data = cartEncId;
            res.success = wasSuccessful;
        } catch(Exception ex) {
            system.debug('Exception occured on stamping '+ ex.getMessage());
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR',ex.getMessage());
        }finally{
            ccrz.ccLog.log(System.LoggingLevel.INFO,'M:X','myMethod');
            ccrz.ccLog.close(res);
        }
        if(!wasSuccessful){
            Database.rollback(sp);
        }
        return res;
    }  
    
}