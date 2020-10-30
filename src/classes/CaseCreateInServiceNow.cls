/**************************************************************************************************************
** Name             : CaseCreateInServiceNow
** Description      : This class is used for handling case related activities
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Graytitude Team                   Sep-2020                    1.0                          Created    
**************************************************************************************************************/
global class CaseCreateInServiceNow {
    @InvocableMethod(label='DCS Case creation callout' description='Making callout to ServiceNow')
    global static void createCaseForDCSAgents(list<Id> caseid)
    {
        System.enqueueJob(new CaseCreationQueueable(caseid,null));
    }
    @TestVisible
    private CaseCreateInServiceNow(){}
}