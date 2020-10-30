/*
* Class Name	: EC_AccontContactRelationDelete
* Description	: Batch Job to call EC_ShipToDeleteQueueable
*/
global with sharing class EC_AccontContactRelationDelete implements Database.Batchable<sObject>, Database.Stateful{
	private List<AccountContactRelation> lstShipToDeletes;
    global EC_AccontContactRelationDelete(List<AccountContactRelation> lstShipToDeletes) {
        this.lstShipToDeletes = lstShipToDeletes;
    } 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id from user where id=\''+Userinfo.getUserId()+'\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> scope) {
        System.enqueueJob(new EC_ShipToDeleteQueueable(lstShipToDeletes));
    }
    global void finish(Database.BatchableContext BC) {
    }
}