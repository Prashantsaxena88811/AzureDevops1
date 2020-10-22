/* Trigger Name    :EC_AccAccessSalesRep
* Description      :Trigger on AccountContactRelation for creating/deleting AccountShare records for sales rep
* Created By       :Mishika Mahajan
* Created On       :08-08-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          08-08-2019                                   Trigger on AccountContactRelation
*/
trigger EC_AccAccessSalesRep on AccountContactRelation (after insert, before delete) {
    // after insertion of AccountContactRelation, accountShare record is created for sales rep user.
    if(Trigger.isAfter && Trigger.isInsert){
    EC_AccAccessSalesRepHelper.createAccUserShare(Trigger.newMap);
    }
    // before deletion of AccountContactRelation, accountShare record is deleted for sales rep user.
    if (Trigger.isBefore && Trigger.isDelete){
    EC_AccAccessSalesRepHelper.deleteAccUserShare(Trigger.oldMap);
    }
  
}