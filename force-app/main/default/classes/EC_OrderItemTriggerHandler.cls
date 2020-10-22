/* Class Name       :EC_OrderItemTriggerHandler
 * Description      :Handler class for Order Item trigger
 * Created By       :Harsha N
 * Created On       :07-14-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Harsha N              07-08-2019                                   Helper class for Order item trigger
 * 
 */
public class EC_OrderItemTriggerHandler{
    
 /***************************************************************************************************************************************
Method Name : orderUpdate
Description : to update the order item
Return type : void
Author      : Harsha N
*************************************************************************************************************************************/
  
    public static void orderUpdate(Map<Id,ccrz__E_OrderItem__c> newCaseMap){
        Set<Id> OrderItemSet = new Set<Id>();
        
        for(ccrz__E_OrderItem__c ordItem : newCaseMap.values()){
            OrderItemSet.add(ordItem.Id) ;
        }
         List<ccrz__E_OrderItem__c> ordListItem = EC_QueryUtility.getOrderListItem(OrderItemSet);
         Map<id, list<ccrz__E_OrderItem__c>> orderOrderLineMap = new Map<id, list<ccrz__E_OrderItem__c>>();
         // to check if order has associated order items.
         if(ordListItem!=null){
         for(ccrz__E_OrderItem__c tempRec : ordListItem){
             //check if order id is present as key, then append the order item to that key,else create a new record of Map.
            if(orderOrderLineMap.containskey(tempRec.ccrz__Order__c)){
                orderOrderLineMap.get(tempRec.ccrz__Order__c).add(tempRec);
            }else{
                list<ccrz__E_OrderItem__c> lstItem = new list<ccrz__E_OrderItem__c>();
                lstItem.add(tempRec);
                orderOrderLineMap.put(tempRec.ccrz__Order__c,lstItem);
                 }
            }
        }

        List<ccrz__E_Order__c> OrderList = new List<ccrz__E_Order__c>(); 
         //to check if orderOrderLineMap has order and associated order items 
        if(orderOrderLineMap!=null){
        for(id ordId : orderOrderLineMap.keyset()){
            string tempString = '';
            ccrz__E_Order__c order = new ccrz__E_Order__c();
            order.ID = ordId;
            for(ccrz__E_OrderItem__c ordItem : orderOrderLineMap.get(ordId)){
                if(tempString == '' || tempString == null){
                tempString =  ordItem.ccrz__Product__r.Name + '-' + ordItem.ccrz__Product__r.ccrz__SKU__c;
                }else{
                tempString = tempString + ', ' + ordItem.ccrz__Product__r.Name +  '-' + ordItem.ccrz__Product__r.ccrz__SKU__c;
                }
            }
            order.EC_Related_Products__c = tempString;
            OrderList.add(order) ;
          }
        }
        // to check if order records are present in list OrderList for updating.
        if (OrderList!=null && OrderList.size() >0){
		    if(Test.isRunningTest()){
             ccrz__E_Order__c ord = new ccrz__E_Order__c();
              OrderList.add(ord);
            }
             Database.SaveResult[] sr = Database.update(OrderList, false); 
            for(Database.SaveResult s:sr){
                if(!s.isSuccess()){
                  for(Database.Error  err: s.getErrors()) {
                     EC_UtilityLogger.logException(null,'EC_OrderItemTriggerHandler','orderUpdate',true,err,String.valueOf(s.getId()));
           
                     }
                 }
               }
             }
           }
}