/*
* Class Name	: EC_AccontContactRelationInsert
* Description	: Batch Job to call EC_ShipToInsertQueueable
*/
global with sharing class EC_AccontContactRelationInsert implements Database.Batchable<sObject>, Database.Stateful{
	private List<AccountContactRelation> lstShipToInserts;
    global EC_AccontContactRelationInsert(List<AccountContactRelation> lstShipToInserts) {
        this.lstShipToInserts = lstShipToInserts;
    } 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id from user where id=\''+Userinfo.getUserId()+'\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> scope) {
        System.enqueueJob(new EC_ShipToInsertQueueable(lstShipToInserts));
    }
    global void finish(Database.BatchableContext BC) {
    }
}