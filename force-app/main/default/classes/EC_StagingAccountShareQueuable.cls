/* Class Name      :EC_StagingAccountShareQueuable
* Description      :Queuable to create accountshare records on user activation
* Created By       :Mishika Mahajan
* Created On       :09-05-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          09-05-2019                                    create accountshare records on user activation
*
*/
public class EC_StagingAccountShareQueuable implements Queueable{
   private List<Id> usrIdList = new List<Id>();
   private List<Id> inactiveUserList = new List<Id>();
   private List<EC_Mulesoft_CDM_Staging__c> stagObjs = new List<EC_Mulesoft_CDM_Staging__c>();
   private List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
    public EC_StagingAccountShareQueuable(List<Id> uIdList,List<EC_Mulesoft_CDM_Staging__c> stgObj,List<Id> userList,List <EC_StagingExceptionLog__c> stageExecpWrapList){
        if(uIdList!=null && !uIdList.isEmpty()){
            usrIdList.addAll(uIdList);
        }
        inactiveUserList =userList;
        stagObjs = stgObj;
        stageLogWrapList = stageExecpWrapList;
    }
    /********************************************************************************************************
    * @author        Deloitte
    * @date          2019-09-05
    * @description   create accountshare records on user activation
    * @return        None
    *********************************************************************************************************/
    public void execute(QueueableContext qc) {


     if(usrIdList!=null && !(usrIdList.isEmpty())){
       Map<Id,AccountContactRelation> accContRelMap = new Map<Id,AccountContactRelation>([select id ,contactId,accountId from AccountContactRelation where contact.EC_SalesRep_User__c in :usrIdList]);
        if(accContRelMap!=null && !(accContRelMap.isEmpty())){
        EC_AccAccessSalesRepHelper.createAccUserShare(accContRelMap);
        }
        }

    List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        for(EC_Mulesoft_CDM_Staging__c successStg:stagObjs){
            EC_Mulesoft_CDM_Staging__c stageRecUpdate = new EC_Mulesoft_CDM_Staging__c();
            stageRecUpdate.Id = successStg.Id;
            stageRecUpdate.EC_IsProcessed__c= true;
            if(stageRecUpdate.Id != null && !String.isBlank(stageRecUpdate.Id)){
                existRecords.add(stageRecUpdate);
            }
                }
        if(existRecords!=null && !existRecords.isEmpty()){
            update existRecords;
        }

        if(inactiveUserList!=null && !inactiveUserList.isEmpty()){
           EC_UpdateSalesRepOnAccount.updateSalesRepOnUserInactive(inactiveUserList);
        }

        EC_StagingLogger.stageLogException(stageLogWrapList);

    }
}