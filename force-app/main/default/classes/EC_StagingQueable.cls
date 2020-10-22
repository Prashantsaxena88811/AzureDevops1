public class EC_StagingQueable implements Queueable {
 private List<EC_Mulesoft_CDM_Staging__c> stgList = new List<EC_Mulesoft_CDM_Staging__c>();
    public EC_StagingQueable(List<EC_Mulesoft_CDM_Staging__c> stgObjs){
       stgList = stgObjs ;
    }
    
    public void execute(QueueableContext context) {
         EC_StagingHelper.stagingtriggerHelper(stgList, 'queueable'); 
     }
  }