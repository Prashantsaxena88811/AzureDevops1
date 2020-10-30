/* Class Name    : EC_CartDetailControllerHelper 
* Description      :Helper Class for EC_CartDetailController
* Created By       :Gaurav
* Created On       :2020-Aug-18


* Modification Log:
* ------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------
* Gaurav                  2020-Aug-18                      
*
*/
public with sharing  class EC_CartDetailControllerHelper {
    
    
/***************************************************************************************************************************************
Method Name : saveBillingArrangement
Description : Stamp the BillingArrangement on cartItem on ProceedTo Checkout
Return type : NA
*************************************************************************************************************************************/
 
    public  void  ECsaveBillingArrangement(String cartsfId) {
        List<ccrz__E_CartItem__c> currentItemLists = new List<ccrz__E_CartItem__c>();
        set<String> ProdskuSet = new set<String>();
        List<ccrz__E_Product__c> prodList= new List<ccrz__E_Product__c>();

        Map<String,ccrz__E_Pricelist__c> lineItemSkuStampBA =new Map<String,ccrz__E_Pricelist__c> ();
        if(ccrz__E_CartItem__c.sObjectType.getDescribe().isAccessible()) {
            currentItemLists = [SELECT ccrz__CartItemId__c,ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Taxonomy__c,ccrz__Cart__c,Billing_Arrangement__c,Id,Billing_Arrangement__r.ccrz__EndDate__c,Billing_Arrangement__r.ccrz__Enabled__c FROM ccrz__E_CartItem__c where ccrz__Cart__c =:cartsfId];
        }
        if(!currentItemLists.isEmpty()) { 
            for (ccrz__E_CartItem__c currentItemList : currentItemLists ) {
                ProdskuSet.add(currentItemList.ccrz__Product__r.ccrz__SKU__c);
                prodList.add(currentItemList.ccrz__Product__r);
                lineItemSkuStampBA.put(currentItemList.ccrz__Product__r.ccrz__SKU__c,currentItemList.Billing_Arrangement__r);
                ccrz.cclog.log('lineItemSkuStampBA----> ' , + lineItemSkuStampBA);
            }
        }
       
        Set<String> deleteStampBAset = new Set<String>();
		deleteStampBAset = deleteStampBAset(prodList,ProdskuSet,lineItemSkuStampBA);
        if(ccrz__E_CartItem__c.sObjectType.getDescribe().isAccessible()) {
            List<ccrz__E_CartItem__c> deleteBAs = new List<ccrz__E_CartItem__c>();
            deleteBAs = [SELECT ccrz__CartItemId__c,ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Taxonomy__c,ccrz__Cart__c,Billing_Arrangement__c,Id,Billing_Arrangement__r.ccrz__EndDate__c,Billing_Arrangement__r.ccrz__Enabled__c FROM ccrz__E_CartItem__c where ccrz__Cart__c =:cartsfId AND ccrz__Product__r.ccrz__SKU__c IN:deleteStampBAset];       
            if(!deleteBAs.isEmpty()) {
                for(ccrz__E_CartItem__c deleteBA :deleteBAs){
                    //deleteBA.Billing_Arrangement__c = null;
                    ccrz.cclog.log('deleteBA----> ' , + deleteBA);
                }
                update deleteBAs;
            }
        }
    }
    
   /***************************************************************************************************************************************
	Method Name : deleteStampBAset
	Description : to delete the stamp BA on proceed to checkout.
	Return type : Set<String>
	**************************************************************************************************************************************/

    public  Set<String> deleteStampBAset(List<ccrz__E_Product__c> prodList, set<String> ProdskuSet, Map<String,ccrz__E_Pricelist__c> lineItemSkuStampBA) {
        Set<String> deleteStampBAset = new Set<String>();
        Map<String,Set<ccrz__E_Pricelist__c>> lineItemSkuBAsetMap =new Map<String,Set<ccrz__E_Pricelist__c>> ();
        String effAccountId = ccrz.cc_CallContext.effAccountId;
        List<Account> effAccountList = new List<Account>();
        if(Account.sObjectType.getDescribe().isAccessible()) {
            effAccountList = [Select Id,EC_SalesOrg__c,EC_Division__c,ccrz__E_AccountGroup__c FROM Account WHERE Id=:effAccountId LIMIT 1];
        }   
        Map<String,List<ccrz__E_Pricelist__c>> productLineBAMap = EC_ProductDetailController.productLineBASetMap(effAccountList[0].ccrz__E_AccountGroup__c,ProdskuSet);
        for(ccrz__E_Product__c prod : prodList){
            Set<ccrz__E_Pricelist__c> baSet = new Set<ccrz__E_Pricelist__c>();
            String sku = prod.ccrz__SKU__c;
            String taxonomy = prod.Taxonomy__c;
            baSet = baSetResponse(taxonomy,sku,productLineBAMap);
            if(!baSet.isEmpty() ) {
                //prod.put('skuBAset',baSet);
                lineItemSkuBAsetMap.put(sku,baSet);
                ccrz.cclog.log('lineItemSkuBAsetMap-->'+lineItemSkuBAsetMap);
            }
        }  
        for(ccrz__E_Product__c prod : prodList){
            String sku = prod.ccrz__SKU__c;
            if(lineItemSkuBAsetMap.get(sku) == null && lineItemSkuStampBA.get(sku) != null ){
                deleteStampBAset.add(sku);
            }
        }
        return deleteStampBAset;
    }
    @TestVisible
    public static Set<ccrz__E_Pricelist__c> baSetResponse(String taxonomy,String sku,Map<String,List<ccrz__E_Pricelist__c>> productLineBAMap  ){
        String GenEquipment = System.label.GEN_EQUIPMENT; 
        String GenChemical = System.label.GEN_CHEMICAL;
        Set<ccrz__E_Pricelist__c> baSet = new Set<ccrz__E_Pricelist__c>();
        if(taxonomy == System.label.EC_Chemistry && productLineBAMap.containsKey(GenChemical) && !productLineBAMap.isEmpty()){
            baSet.AddAll(productLineBAMap.get(GenChemical));
        }
        if(taxonomy == System.label.EC_Equipment && productLineBAMap.containsKey(GenEquipment)&& !productLineBAMap.isEmpty()){
            baSet.AddAll(productLineBAMap.get(GenEquipment));
        }
        if(productLineBAMap.containsKey(sku) && !productLineBAMap.isEmpty()){
            baSet.AddAll(productLineBAMap.get(sku)); 
        }
        
        return baSet;
    }    
    
}