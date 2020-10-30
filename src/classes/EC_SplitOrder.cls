/* Class Name      : EC_BillingArrangementController
* Description      : Controller Class for Splitting order
* Created By       : Bharath Kn
* Created On       : 2020-Sept-03


* Modification Log:
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bharath Kn            2020-Sept-03         PBI-                  Created the class
*
*/
public class EC_SplitOrder {
    
    @InvocableMethod
    public static void orderSubmitFlow(List<Id> orderIds){
        String orderId = orderIds.get(0);
        Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap = orderItemSplitLogic(orderId);
        List<ccrz__E_OrderItemGroup__c> OIGroupRecords = createOrderItemGroups(BA_ULOrderItemMap.size(),orderId);
        assOIwithOIGroup(OIGroupRecords,BA_ULOrderItemMap);
        
    }
    
    public static Map<String,List<ccrz__E_OrderItem__c>> orderItemSplitLogic(String orderId){
        Map<String,List<ccrz__E_OrderItem__c>> skuOrderItemMap =  (Map<String,List<ccrz__E_OrderItem__c>>) fetchSKUOrderItemMap(orderId).get('skuOrderItemMap');
        Map<String,ccrz__E_PriceListItem__c> skuSBAPriceListMap = (Map<String,ccrz__E_PriceListItem__c>) fetchSKUOrderItemMap(orderId).get('skuSBAPriceListMap');
        
        Map<String,String> skuPriceListMap = (Map<String,String>) fetchSKUOrderItemMap(orderId).get('skuPriceListMap');
        Map<String,List<String>> pricelistSKUMap = (Map<String,List<String>>) fetchSKUOrderItemMap(orderId).get('pricelistSKUMap');
        
        system.debug(skuSBAPriceListMap);
        Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap = new Map<String,List<ccrz__E_OrderItem__c>>();

        //ccrz__Order__r.ccrz__EffectiveAccountID__c
        for(String sku : skuOrderItemMap.keySet()){
            Boolean isBulk = false;
            List<ccrz__E_OrderItem__c> orderItems = skuOrderItemMap.get(sku);
            if(orderItems.size() == 1){
                isBulk = EC_SplitOrderHelper.checkIsBulk(orderItems[0]);
                processOrderItem(orderItems[0], isBulk,skuSBAPriceListMap,BA_ULOrderItemMap);
            }
            if(orderItems.size() > 1){
                for(ccrz__E_OrderItem__c orderItem : orderItems){
                    isBulk = EC_SplitOrderHelper.checkIsBulk(orderItem);
                    processOrderItems(orderItem, isBulk,skuSBAPriceListMap,BA_ULOrderItemMap);
                }
            }
        }
        
        for(String key : BA_ULOrderItemMap.keySet()){
            system.debug('key '+ key);
            system.debug('value '+ BA_ULOrderItemMap.get(key));
            String keyWithoutSPA = key.removeStartIgnoreCase('SPA_');
            if(key.startsWithIgnoreCase('SPA_Ship_and_Bill_') && BA_ULOrderItemMap.containsKey(keyWithoutSPA)){
                BA_ULOrderItemMap.get(keyWithoutSPA).addAll(BA_ULOrderItemMap.get(key));
                BA_ULOrderItemMap.remove(key);
            }
        }

        if((Boolean) fetchSKUOrderItemMap(orderId).get('multipleSPAAssociated')){
            system.debug('split');
            splitMultipleSPA(BA_ULOrderItemMap,skuPriceListMap,pricelistSKUMap);
        }
        return BA_ULOrderItemMap;
    }
    
    
    public static void splitMultipleSPA(Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap,Map<String,String> skuPriceListMap, Map<String,List<String>> pricelistSKUMap){
        for(String key : BA_ULOrderItemMap.keySet()){
            system.debug('key split'+ key);
            system.debug('value split'+ BA_ULOrderItemMap.get(key));
            if((key.startsWithIgnoreCase('Ship_and_Bill_') || key.startsWithIgnoreCase('SPA_Ship_and_Bill_')) && BA_ULOrderItemMap.get(key).size()> 1){
                for(String pricelist : pricelistSKUMap.keySet()){
                    for(ccrz__E_OrderItem__c orderItem : BA_ULOrderItemMap.get(key)){
                        splitMultipleSPAHelper(orderItem,pricelist,key,BA_ULOrderItemMap,skuPriceListMap,pricelistSKUMap);
                    }
                }
            }
        }
    }
	public static void splitMultipleSPAHelper(ccrz__E_OrderItem__c orderItem, String pricelist, String key, Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap,Map<String,String> skuPriceListMap, Map<String,List<String>> pricelistSKUMap){
        
        if(skuPriceListMap.containsKey(orderItem.ccrz__Product__r.ccrz__SKU__c) && !pricelistSKUMap.get(priceList).contains(orderItem.ccrz__Product__r.ccrz__SKU__c)){
            if(BA_ULOrderItemMap.containsKey(pricelist)){
                BA_ULOrderItemMap.get(pricelist).add(orderItem);
            }else{
                BA_ULOrderItemMap.put(pricelist, new List<ccrz__E_OrderItem__c>{orderItem});
            }
            BA_ULOrderItemMap.get(key).remove(BA_ULOrderItemMap.get(key).indexOf(orderItem));
            if(BA_ULOrderItemMap.get(key).size() == 0){
                BA_ULOrderItemMap.remove(key);
            }
        }
    }
    
    public static List<ccrz__E_OrderItemGroup__c> createOrderItemGroups(Integer numOfOrderItemGroup, String OrderId){
        List<ccrz__E_OrderItemGroup__c> OIGroupRecords = new List<ccrz__E_OrderItemGroup__c>();
        for(Integer i=1; i<=numOfOrderItemGroup; i++){
            ccrz__E_OrderItemGroup__c obj = new ccrz__E_OrderItemGroup__c();
            obj.ccrz__Order__c = OrderId;
            OIGroupRecords.add(obj);
        }
        
        insert OIGroupRecords;
        System.debug('OIGroupRecords size'+OIGroupRecords.size());
        return OIGroupRecords;
    }
    
    public static void assOIwithOIGroup(List<ccrz__E_OrderItemGroup__c> OIGroupRecords, Map<String,List<ccrz__E_OrderItem__c>> OrderItemBA_ULMap){        
        Map<id,ccrz__E_OrderItem__c> updateorderItem = new Map<id,ccrz__E_OrderItem__c>();
        Map<id,ccrz__E_OrderItemGroup__c> UpdateOIGroupRecords = new Map<id,ccrz__E_OrderItemGroup__c>();
        integer n =0;
        for(String key : OrderItemBA_ULMap.keyset()){           
            List<ccrz__E_OrderItem__c> OrderItems = OrderItemBA_ULMap.get(key);
            for(ccrz__E_OrderItem__c orderItem : OrderItems) {
                orderItem.ccrz__OrderItemGroup__c = OIGroupRecords[n].Id;
                OIGroupRecords[n].Order_Item_Group_Status__c='Order not submitted';
                if(orderItem.Billing_Arrangement__c == null){
                    OIGroupRecords[n].Order_Type__c = 'ZOS1';
                }else {
                    OIGroupRecords[n].Billing_Arrangement__c = orderItem.Billing_Arrangement__c;
                    map<string,string> batypeOrderTypeMap = batypeOrderTypeMap();
                    system.debug('EC_SplitOrder batypeOrderTypeMap-->'+batypeOrderTypeMap);
                    OIGroupRecords[n].Order_Type__c = batypeOrderTypeMap.get(orderItem.Billing_Arrangement__r.EC_Price_List_Type__c);
                }
                UpdateOIGroupRecords.put(OIGroupRecords[n].id,OIGroupRecords[n]);
                updateorderItem.put(orderItem.Id,orderItem);
            }
            n++;
        }
        update updateorderItem.values();
        update UpdateOIGroupRecords.values();
    }
    
    
    public static map<string,string> batypeOrderTypeMap () {
        List<Billing_Arrangement_Types__mdt> BATypes = new List<Billing_Arrangement_Types__mdt>();
        if (Billing_Arrangement_Types__mdt.sObjectType.getDescribe().isAccessible()) { 
            BATypes = [Select Label,BA_Type_Code__c,Active__c from Billing_Arrangement_Types__mdt where Active__c = true];
        }
        Map<String,String> batypeOrderTypeMap = new Map<String,String>();
        if(!BATypes.isEmpty()) {
            for(Billing_Arrangement_Types__mdt BAType: BATypes ) {
                batypeOrderTypeMap.put(BAType.Label,BAType.BA_Type_Code__c);
            }
        }        
        return batypeOrderTypeMap;
    }    
    
    public static Map<String,Object> fetchSKUOrderItemMap(String orderId){
        Map<String,Object> responseMap = new Map<String,Object>();
         Map<String,List<ccrz__E_OrderItem__c>> skuOrderItemMap = new Map<String,List<ccrz__E_OrderItem__c>>();
        String effectiveAccount = ''; 
        for(ccrz__E_OrderItem__c orderItem : [select id,ccrz__Order__c,Billing_Arrangement__r.BA_Number__c,Unloading_Point__r.ccrz__CompanyName__c,ccrz__Product__r.ccrz__SKU__c,Tank_Number__c,
                                              Billing_Arrangement__r.EC_Price_List_Type__c,ccrz__Order__r.ccrz__EffectiveAccountID__c 
                                              from ccrz__E_OrderItem__c where ccrz__Order__r.Id =:orderId]) {
                                                  effectiveAccount = orderItem.ccrz__Order__r.ccrz__EffectiveAccountID__c;
                                                  if(!skuOrderItemMap.containsKey(orderItem.ccrz__Product__r.ccrz__SKU__c)){
                                                      skuOrderItemMap.put(orderItem.ccrz__Product__r.ccrz__SKU__c,new List<ccrz__E_OrderItem__c>{orderItem});                                   
                                                  }else{
                                                      skuOrderItemMap.get(orderItem.ccrz__Product__r.ccrz__SKU__c).add(orderItem);   
                                                  }
                                              }
        Map<String,ccrz__E_PriceListItem__c> skuSBAPriceListMap = new Map<String,ccrz__E_PriceListItem__c>();
        
        String acgrp = [Select ccrz__E_AccountGroup__c from Account Where Id=:effectiveAccount Limit 1].ccrz__E_AccountGroup__c;
        Map<String,String> skuPriceListMap = new Map<String,String>();
        Map<String,List<String>> pricelistSKUMap = new Map<String,List<String>>();
        
        for(ccrz__E_PriceListItem__c sbaPLI : [Select Id,ccrz__Product__r.ccrz__SKU__c,ccrz__Pricelist__r.Name from ccrz__E_PriceListItem__c where ccrz__Product__r.ccrz__SKU__c in:skuOrderItemMap.keySet() and ccrz__Pricelist__r.EC_Price_List_Type__c = 'SBA'
                                               and ccrz__Pricelist__c in (SELECT ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c 
                                                                          where ccrz__AccountGroup__c=:acgrp )]){
                                                                              skuSBAPriceListMap.put(sbaPLI.ccrz__Product__r.ccrz__SKU__c,sbaPLI);
                                                                              skuPriceListMap.put(sbaPLI.ccrz__Product__r.ccrz__SKU__c,sbaPLI.ccrz__Pricelist__r.Name);
                                                                              
                                                                              if(pricelistSKUMap.containsKey(sbaPLI.ccrz__Pricelist__r.Name)){
                                                                                  pricelistSKUMap.get(sbaPLI.ccrz__Pricelist__r.Name).add(sbaPLI.ccrz__Product__r.ccrz__SKU__c);
                                                                              }else{
                                                                                  pricelistSKUMap.put(sbaPLI.ccrz__Pricelist__r.Name, new List<String>{sbaPLI.ccrz__Product__r.ccrz__SKU__c});
                                                                              }
                                                                          }
        
        responseMap.put('skuOrderItemMap',skuOrderItemMap);
        responseMap.put('skuSBAPriceListMap',skuSBAPriceListMap);
        responseMap.put('skuPriceListMap',skuPriceListMap);
        responseMap.put('pricelistSKUMap',pricelistSKUMap);
        responseMap.put('multipleSPAAssociated',false);
        if(skuPriceListMap.values().size() > 1 ){
            responseMap.put('multipleSPAAssociated',true);
        }
        return responseMap;
    }

    public static void processOrderItem(ccrz__E_OrderItem__c orderItem, Boolean isBulk,Map<String,ccrz__E_PriceListItem__c> skuSBAPriceListMap, Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap){
        
        if(orderItem.Billing_Arrangement__r != null){
            if(orderItem.Billing_Arrangement__r.EC_Price_List_Type__c == 'FBA' || orderItem.Billing_Arrangement__r.EC_Price_List_Type__c =='USR'){
                String BANumber = orderItem.Billing_Arrangement__r.EC_Price_List_Type__c +'_'+ orderItem.Billing_Arrangement__r.BA_Number__c;
                EC_SplitOrderHelper.addOrderItemToMap_V2(orderItem,BA_ULOrderItemMap,BANumber,null,isBulk);
            }else if(orderItem.Billing_Arrangement__r.EC_Price_List_Type__c == 'USG'){
                EC_SplitOrderHelper.addOrderItemToMap_V2(orderItem,BA_ULOrderItemMap,null,null,isBulk);
            }
        }else{
            if(skuSBAPriceListMap.containsKey(orderItem.ccrz__Product__r.ccrz__SKU__c)){
                EC_SplitOrderHelper.addOrderItemToMap_V2(orderItem,BA_ULOrderItemMap,null,null,isBulk);
            }else{
                //Ship and bill without SPA
                EC_SplitOrderHelper.addOrderItemToMap_V2(orderItem,BA_ULOrderItemMap,'Ship_and_Bill',null,isBulk);
            }
        }
    }
    public static void processOrderItems(ccrz__E_OrderItem__c orderItem, Boolean isBulk,Map<String,ccrz__E_PriceListItem__c> skuSBAPriceListMap, Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap){
        
        if(orderItem.Billing_Arrangement__r == null){
            if(skuSBAPriceListMap.containsKey(orderItem.ccrz__Product__r.ccrz__SKU__c)){
                EC_SplitOrderHelper.addOrderItemToMap_V2(orderItem,BA_ULOrderItemMap,'SPA_Ship_and_Bill',null,isBulk);
            }else{
                //Ship and bill without SPA
                EC_SplitOrderHelper.addOrderItemToMap_V2(orderItem,BA_ULOrderItemMap,'Ship_and_Bill',null,isBulk);
            }
        }else{
            if(orderItem.Billing_Arrangement__r.EC_Price_List_Type__c == 'FBA' || orderItem.Billing_Arrangement__r.EC_Price_List_Type__c =='USR'){
                String BANumber = orderItem.Billing_Arrangement__r.EC_Price_List_Type__c +'_'+orderItem.Billing_Arrangement__r.BA_Number__c;
                EC_SplitOrderHelper.addOrderItemToMap_V2(orderItem,BA_ULOrderItemMap,BANumber,null,isBulk);
            }else if(orderItem.Billing_Arrangement__r.EC_Price_List_Type__c == 'USG'){
                EC_SplitOrderHelper.addOrderItemToMap_V2(orderItem,BA_ULOrderItemMap,null,null,isBulk);
            }
        }
    }
}