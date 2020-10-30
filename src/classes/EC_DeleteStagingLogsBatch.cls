/* Class Name      :EC_DeleteStagingLogsBatch
* Description      :Batch class to delete Staging Exception Log records having lifetime of 30 days or more.
* Created By       :Mishika Mahajan
* Created On       :12-16-2019   
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan        12-16-2019                                        to delete Staging Exception Log records having lifetime of 30 days or more.
* 
*/global class EC_DeleteStagingLogsBatch implements Database.Batchable<Sobject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer noOfDays = Integer.valueOf(label.EC_StagingLogRecordsLife);
        Date todayDate = system.today().addDays(noOfDays);
        String query = 'SELECT id, createddate from EC_StagingExceptionLog__c where createddate <= :todayDate';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<EC_StagingExceptionLog__c> records){
        if(records!=null && !records.isEmpty()){
      Database.delete(records, false);
        }
    } 
   
    global void finish(Database.BatchableContext bc){
        
    }
}