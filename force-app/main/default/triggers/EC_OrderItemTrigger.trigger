trigger EC_OrderItemTrigger on ccrz__E_OrderItem__c(after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        EC_OrderItemTriggerHandler.orderUpdate(Trigger.newMap);
    }
}