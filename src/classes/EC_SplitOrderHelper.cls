public class EC_SplitOrderHelper {
    private EC_SplitOrderHelper() { }
    public static void addOrderItemToMap_V2(ccrz__E_OrderItem__c orderItem, Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap,String BANumberValue, String unloadingPointValue,  Boolean isBulk ){
        String BANumber = createBANumber(orderItem,BANumberValue);
        String unloadingPoint = createUnloadingPoint(orderItem,unloadingPointValue,isBulk);
        String BAULMapKey = '';
        system.debug(BANumber);
        system.debug(unloadingPoint);
        BAULMapKey = BANumber + '_' + unloadingPoint;
        processBAULMap(BA_ULOrderItemMap,BAULMapKey,orderItem);
    }
    
    public static String createBANumber(ccrz__E_OrderItem__c orderItem,String BANumber){
        return BANumber == null ? orderItem.Billing_Arrangement__r.BA_Number__c == null ? 'Ship_and_Bill'  : orderItem.Billing_Arrangement__r.BA_Number__c : BANumber;
        //return BANumber != null ? BANumber : orderItem.Billing_Arrangement__r.BA_Number__c !=null
        // ? orderItem.Billing_Arrangement__r.BA_Number__c : 'Ship_and_Bill';
    }
    public static boolean checkIsBulk(ccrz__E_OrderItem__c orderItem){
       return orderItem.Tank_Number__c == null ? false: true;
    }
    public static String createUnloadingPoint(ccrz__E_OrderItem__c orderItem,String unloadingPoint,Boolean isBulk){
        String unloadingPointnew = unloadingPoint == null ? orderItem.Unloading_Point__r.ccrz__CompanyName__c == null ? '' : orderItem.Unloading_Point__r.ccrz__CompanyName__c : unloadingPoint ;
        //String unloadingPointnew = unloadingPoint != null ? unloadingPoint: orderItem.Unloading_Point__r.ccrz__CompanyName__c != null
        // ? orderItem.Unloading_Point__r.ccrz__CompanyName__c : '';
        unloadingPointnew = isBulk ? 'bulk' : unloadingPointnew;
        return unloadingPointnew;
    }
    
    public static void updateBAULOrderItemMap( Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap,String newBAULMapKey,ccrz__E_OrderItem__c orderItem){
        
        if(BA_ULOrderItemMap.containsKey(newBAULMapKey)){
            BA_ULOrderItemMap.get(newBAULMapKey).add(orderItem);
            
        }else{
            BA_ULOrderItemMap.put(newBAULMapKey, new List<ccrz__E_OrderItem__c>{orderItem});
        }
    }
    
    public static void processBAULMap(Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap,String BAULMapKey,ccrz__E_OrderItem__c orderItem){
        if(BA_ULOrderItemMap.containsKey(BAULMapKey)){
            processBAULMapforDuplicates(BA_ULOrderItemMap,BAULMapKey,orderItem);
             
        }else{
            BA_ULOrderItemMap.put(BAULMapKey, new List<ccrz__E_OrderItem__c>{orderItem});  
        }
    }
    
    public static void processBAULMapforDuplicates(Map<String,List<ccrz__E_OrderItem__c>> BA_ULOrderItemMap,String BAULMapKey,ccrz__E_OrderItem__c orderItem){
        String newBAULMapKey = BAULMapKey;

        Boolean skuAlreadyPresentInList = false;
        for(String BAULMapKeyIterate : BA_ULOrderItemMap.keySet()){
			system.debug('BAULMapKeyIterate :: '+ BAULMapKeyIterate);
            if(BAULMapKeyIterate.contains(BAULMapKey)){
                for(ccrz__E_OrderItem__c orderlineItem : BA_ULOrderItemMap.get(BAULMapKeyIterate)){
                    if(orderlineItem.ccrz__Product__r.ccrz__SKU__c == orderItem.ccrz__Product__r.ccrz__SKU__c && !BAULMapKey.startsWithIgnoreCase('FBA') && !BAULMapKey.startsWithIgnoreCase('USR') && !BAULMapKey.startsWithIgnoreCase('Ship_and_Bill')){
                        skuAlreadyPresentInList = true;
                        newBAULMapKey = BAULMapKeyIterate + orderlineItem.id;
                        system.debug('newBAULMapKey :: '+ newBAULMapKey);
                        break;
                    }else{
                        skuAlreadyPresentInList = false;
                        newBAULMapKey = BAULMapKeyIterate;
                        continue;
                    }
                }
                if(!skuAlreadyPresentInList){
                    system.debug('skuAlreadyPresentInList false');
                    break;
                }
            }
        }
        system.debug('newBAULMapKey '+ newBAULMapKey );
        updateBAULOrderItemMap(BA_ULOrderItemMap,newBAULMapKey,orderItem);
    }
}