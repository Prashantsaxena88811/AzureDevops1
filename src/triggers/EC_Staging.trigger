/* Trigger Name    :EC_Mulesoft_CDM_Staging__c
* Description      :Trigger on EC_Mulesoft_CDM_Staging__c for creating staging
* Created By       :Shivam Vats
* Created On       :08-08-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Shivam Vats          08-08-2019                                   Trigger on EC_Mulesoft_CDM_Staging__c for creating staging
*/

trigger EC_Staging on EC_Mulesoft_CDM_Staging__c (before insert, after insert) {
    List<EC_Mulesoft_CDM_Staging__c> lstnewInserts = new List<EC_Mulesoft_CDM_Staging__c>();
    for(EC_Mulesoft_CDM_Staging__c stgObj:trigger.new){
        if((stgObj.EC_Source_Table__c == EC_Constants.USER && stgObj.EC_Action__c == EC_Constants.INSERTACTION) || (stgObj.EC_Source_Table__c == EC_Constants.ACCOUNT)||(stgObj.EC_Source_Table__c == EC_Constants.User_Account))
        {
           lstnewInserts.add(stgObj);
        }
    }
    if (trigger.isInsert && trigger.isBefore){
        if(lstnewInserts!=null && !lstnewInserts.isEmpty()){
             EC_StagingHelper.AccountHelperBeforeInsert(lstnewInserts);
        }

    }
    if (trigger.isInsert && trigger.isAfter){
        if(lstnewInserts!=null && !lstnewInserts.isEmpty()){
             EC_StagingHelper.stagingtriggerHelper(lstnewInserts,'trigger');
        }

    }


  }