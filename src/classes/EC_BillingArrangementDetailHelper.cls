/* Class Name      : EC_BillingArrangementDetailHelper
* Description      :Controller Class for Billing Arrangement and Billing Arrangement Detail PAge
* Created By       :Moin Sawar
* Created On       :2020-Aug-27


* Modification Log:
* -------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -------------------------------------------------------------------------------------------------------
* Moin Sawar            2020-Aug-27         PBI-                    Created the class
*
*/
public with sharing class EC_BillingArrangementDetailHelper {

    private EC_BillingArrangementDetailHelper(){
    
    }
    public static ccrz.cc_RemoteActionResult fetchBADPData(ccrz.cc_RemoteActionResult res,String baId){
           
            EC_BillingArrangementController.baWrapper baWrapperObj = new EC_BillingArrangementController.baWrapper();
            Date today = Date.today();
            set<string> BAProdLineSet = EC_ProductDetailController.getBAProductLines();
            if(ccrz__E_PriceListItem__c.sObjectType.getDescribe().isAccessible()){ 
                
                List<ccrz__E_PriceListItem__c> pli = getProductlistBADP(baId,BAProdLineSet);
                if(!pli.isEmpty()){                     
                    baWrapperObj.profile = EC_QueryUtility.getProfile();
                    baWrapperObj.baNumber = pli[0].ccrz__Pricelist__r.BA_Number__c;
                    baWrapperObj.baId = pli[0].ccrz__Pricelist__r.ID;
                    baWrapperObj.baType = pli[0].ccrz__Pricelist__r.Price_List_Type_Expansion__c;
                    baWrapperObj.baDesc = pli[0].ccrz__Pricelist__r.ccrz__Desc__c;
                    DateTime startDate = pli[0].ccrz__Pricelist__r.ccrz__StartDate__c;
                    DateTime EndDate = pli[0].ccrz__Pricelist__r.ccrz__EndDate__c;                       
                    String formattedBAStartDate = startDate.formatGMT(EC_Constants.MMM)+' '+startDate.formatGMT(EC_Constants.d)+', '+startDate.formatGMT(EC_Constants.yyyy);
                    String formattedBAEndDate = EndDate.formatGMT(EC_Constants.MMM)+' '+EndDate.formatGMT(EC_Constants.d)+', '+EndDate.formatGMT(EC_Constants.yyyy);
                    baWrapperObj.startDate = formattedBAStartDate; 
                    baWrapperObj.EndDate = formattedBAEndDate;
                    Map<Id,ccrz__E_PriceListItem__c> prodIDPLI = new Map<Id,ccrz__E_PriceListItem__c> ();
                    for(ccrz__E_PriceListItem__c plItem : pli){
                        prodIDPLI.put(plItem.ccrz__Product__r.Id,plItem); 
                    }
                    Map<Id,ccrz__E_ProductMedia__c> prodIDMedia = new Map<Id,ccrz__E_ProductMedia__c> ();
                    for(ccrz__E_ProductMedia__c prodMedia : [select id ,ccrz__EndDate__c,ccrz__StartDate__c,ccrz__MediaType__c,ccrz__Enabled__c,ccrz__URI__c,ccrz__Product__r.Id from ccrz__E_ProductMedia__c where ccrz__Product__r.Id IN:prodIDPLI.KeySet() AND ccrz__Enabled__c =true AND ccrz__MediaType__c ='Product Image']){
                        prodIDMedia.put(prodMedia.ccrz__Product__r.Id,prodMedia);   
                    }
                    Set<String> pkgCodeSet = EC_BillingArrangementController.getPackageCode();
                    List<EC_BillingArrangementController.ItemWrapper> itemWrapperList = new List<EC_BillingArrangementController.ItemWrapper>();
                    List<EC_BillingArrangementController.ItemWrapper> prodLineItemWrapperList = new List<EC_BillingArrangementController.ItemWrapper>();
                    for(ccrz__E_PriceListItem__c plItem : pli){
                        if(BAProdLineSet.contains(plItem.ccrz__Product__r.ccrz__SKU__c)){
                            EC_BillingArrangementController.ItemWrapper ItemWrapperObj2 = new EC_BillingArrangementController.ItemWrapper();
                            ItemWrapperObj2.product = plItem.ccrz__Product__r;
                            ItemWrapperObj2.uri = prodIDMedia.containsKey(plItem.ccrz__Product__r.Id) ? prodIDMedia.get(plItem.ccrz__Product__r.Id).ccrz__URI__c : '';
                            prodLineItemWrapperList.add(ItemWrapperObj2);
                        }
                        else{
                            EC_BillingArrangementController.ItemWrapper ItemWrapperObj = createItemWrapperObj(plItem,prodIDMedia,pkgCodeSet);
                            itemWrapperList.add(ItemWrapperObj);
                        }
                        
                    }
                    
                    baWrapperObj.prodLineItems =prodLineItemWrapperList;
                    baWrapperObj.ItemWrapper = itemWrapperList;
                }
            }
            res.success = true;
            res.data = baWrapperObj;
            return res;
    }
    
    public static EC_BillingArrangementController.ItemWrapper createItemWrapperObj(ccrz__E_PriceListItem__c plItem, Map<Id,ccrz__E_ProductMedia__c> prodIDMedia,Set<String> pkgCodeSet){
            
            EC_BillingArrangementController.ItemWrapper ItemWrapperObj = new EC_BillingArrangementController.ItemWrapper();
            ItemWrapperObj.price =plItem.ccrz__Price__c;
            ItemWrapperObj.customPricingUOM = plItem.Custom_PricingUOM__c;
            ItemWrapperObj.customUnitPrice = plItem.Custom_UnitPrice__c;
            ItemWrapperObj.PricePer = Integer.valueOf(plItem.Price_Per__c);
            ItemWrapperObj.taxonomy =plItem.ccrz__Product__r.Taxonomy__c;
            String packageCode = plItem.ccrz__Product__r.Package_Code__c;
            ItemWrapperObj.packageTypeUOM = !pkgCodeSet.isEmpty() && pkgCodeSet.contains(packageCode) ? 'Bulk':'NonBulk';
            DateTime sDate= plItem.ccrz__StartDate__c;
            DateTime eDate=plItem.ccrz__EndDate__c; 
            String formattedPLIStartDate=sDate.formatGMT(EC_Constants.MMM)+' '+sDate.formatGMT(EC_Constants.d)+', '+sDate.formatGMT(EC_Constants.yyyy);
            String formattedPLIEndDate=eDate.formatGMT(EC_Constants.MMM)+' '+eDate.formatGMT(EC_Constants.d)+', '+eDate.formatGMT(EC_Constants.yyyy);
            ItemWrapperObj.startDate= formattedPLIStartDate;
            ItemWrapperObj.EndDate=  formattedPLIEndDate;
            ItemWrapperObj.product = plItem.ccrz__Product__r;
            ItemWrapperObj.uri = prodIDMedia.containsKey(plItem.ccrz__Product__r.Id) ? prodIDMedia.get(plItem.ccrz__Product__r.Id).ccrz__URI__c : '';
            return ItemWrapperObj;
    }

        public static Set<String> getDifferentBAType(){
        Set<String> baTypeSet = new Set<String>();
        List<Billing_Arrangement_Types__mdt> baTypes = new List<Billing_Arrangement_Types__mdt>();
        if(Billing_Arrangement_Types__mdt.sObjectType.getDescribe().isAccessible()){
            BATypes = [Select Label,BA_Type_Code__c,Active__c,Applicable_On_BADP__c from Billing_Arrangement_Types__mdt where Active__c = true AND Applicable_On_BADP__c =true];
            for (Billing_Arrangement_Types__mdt baType : baTypes) {
                baTypeSet.add(baType.Label);
            }
        }
        return baTypeSet;
    }

        
     public static  List<ccrz__E_PriceListItem__c> getProductlistBADP(String baId,set<string> BAProdLineSet){
        String productIndexStatus = System.label.EC_ProductIndexCurrent; 
        Map<String,ccrz__E_PriceListItem__c> plItemSkus = new Map<String,ccrz__E_PriceListItem__c>();
        Date today = Date.today();
        List<ccrz__E_PriceListItem__c> pli = new  List<ccrz__E_PriceListItem__c>();
        Set<ccrz__E_PriceListItem__c> pliTemp = new Set<ccrz__E_PriceListItem__c>();
        for(ccrz__E_PriceListItem__c plItem : [select Id,name,ccrz__Price__c,ccrz__Pricelist__r.BA_Number__c,ccrz__Pricelist__r.ID,ccrz__Pricelist__r.ccrz__Desc__c,ccrz__Pricelist__r.Price_List_Type_Expansion__c,ccrz__Pricelist__r.ccrz__StartDate__c,
                                               ccrz__Pricelist__r.ccrz__EndDate__c,ccrz__Product__r.ccrz__sku__c,ccrz__Product__r.ccrz__ProductStatus__c,ccrz__EndDate__c,ccrz__Product__r.Name,ccrz__Product__r.ccrz__UnitOfMeasure__c,
                                               ccrz__Product__r.Taxonomy__c,ccrz__Product__r.Package_Code__c,ccrz__Product__r.ccrz__ProductIndexStatus__c,Custom_PricingUOM__c,Custom_UnitPrice__c,Price_Per__c,ccrz__Product__r.ccrz__StartDate__c,ccrz__Product__r.ccrz__EndDate__c,ccrz__StartDate__c 
                                               from ccrz__E_PriceListItem__c where ccrz__StartDate__c <= :today AND ccrz__EndDate__c>=:today AND ccrz__Product__r.ccrz__StartDate__c <= :today AND ccrz__Product__r.ccrz__EndDate__c>=:today 
                                               AND ccrz__Pricelist__c =:baId  AND ((ccrz__Product__r.ccrz__ProductIndexStatus__c =:productIndexStatus AND ccrz__Product__r.ccrz__ProductStatus__c IN('Released','Not Orderable')) OR ccrz__Product__r.ccrz__sku__c IN:BAProdLineSet) order by ccrz__Product__r.ccrz__sku__c asc]){
                                                   
                                                   plItemSkus.put(plItem.ccrz__Product__r.ccrz__sku__c,plItem);
                                               }                
        
        for(ccrz__E_PriceListItem__c plItem : [select Id,ccrz__Product__r.ccrz__sku__c from ccrz__E_PriceListItem__c where ccrz__StartDate__c <= :today 
                                               AND ccrz__EndDate__c>=:today AND ccrz__Product__r.ccrz__StartDate__c <= :today AND ccrz__Product__r.ccrz__EndDate__c>=:today 
                                               AND ccrz__Pricelist__r.EC_Price_List_Type__c NOT IN :getDifferentBAType() AND ccrz__Product__r.ccrz__sku__c IN :plItemSkus.keySet() order by ccrz__Product__r.ccrz__sku__c asc]){
                                                   if(plItemSkus.containsKey(plItem.ccrz__Product__r.ccrz__sku__c)){
                                                       pliTemp.add(plItemSkus.get(plItem.ccrz__Product__r.ccrz__sku__c));
                                                   }  
                                               }
        for(String genLines: BAProdLineSet){
            if(plItemSkus.containsKey(genLines)){
                pliTemp.add(plItemSkus.get(genLines));
            } 
        }
        pli.addAll(pliTemp);
        return pli;
    }
}