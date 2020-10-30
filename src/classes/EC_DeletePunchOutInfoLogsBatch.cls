/* Class Name      :EC_DeletePunchOutInfoLogsBatch
* Description      :Batch class to delete PunchOutInfo Log records having lifetime of 30 days or more.
* Created By       :Raghav Sharma
* Created On       :01-08-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Raghav Sharma        01-08-2020                                        Batch class to delete PunchOutInfo Log records having lifetime of 30 days or more.
*
*/
global class EC_DeletePunchOutInfoLogsBatch implements Database.Batchable<Sobject>{


    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer noOfDays = Integer.valueOf(label.EC_StagingLogRecordsLife);
        Date todayDate = system.today().addDays(noOfDays);
        String query = 'SELECT id, createddate from EC_PunchOutInfo__c where createddate <= :todayDate';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<EC_PunchOutInfo__c> records){
        if(records!=null && !records.isEmpty()){
            Database.delete(records, false);
        }
    }

    global void finish(Database.BatchableContext bc){

    }
}