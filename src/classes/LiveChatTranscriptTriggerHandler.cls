/* Class Name      :LiveChatTranscriptTriggerHandler
* Description      :handler class for LiveChatTranscriptTrigger trigger
* Created By       :Graytitude Team
* Created On       :13.10.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          13.10.2020                                      updateCase - update the case owner
*/
public without sharing class LiveChatTranscriptTriggerHandler {
    
    public static void updateCase(List<LiveChatTranscript> lstLCT, Map<Id,LiveChatTranscript> oldMap) {
        try{            
            List<LiveChatTranscript> lstScope = getScope(lstLCT, oldMap);                     
            Set<Id> setCaseId = getCaseId(lstScope);
            Map<Id,Case> mapCase = getCaseMap(setCaseId);
            for(LiveChatTranscript objLCT : lstScope) { 
                if(!mapCase.containsKey(objLCT.CaseId)) continue;                  
                Case objCase = mapCase.get(objLCT.CaseId);
                updateCaseafterChatComplete(objLCT, objCase);
                updateCaseafterChatInProgress(objLCT, objCase);                        
            }            
        } catch(exception ex){ System.debug('Error while updating case from LiveChatTranscript Trigger : ' + ex.getMessage()); }
    }
    
    private static List<LiveChatTranscript> getScope(List<LiveChatTranscript> lstLCT, Map<Id,LiveChatTranscript> oldMap) {
        List<LiveChatTranscript> lstScope = new List<LiveChatTranscript>();
        for(LiveChatTranscript objLCT : lstLCT) {
            if((objLCT.Status!=OldMap.get(objLCT.Id).Status && objLCT.CaseId!=null && ( objLCT.Status=='Completed' || objLCT.Status=='InProgress')) || isInprogress) {
                lstScope.add(objLCT);
            }
        } 
        return lstScope;
    }
    
    private static Set<Id> getCaseId(List<LiveChatTranscript> lstScope) {
        Set<Id> setCaseId = new Set<Id>();
        for(LiveChatTranscript objLCT : lstScope) {
            setCaseId.add(objLCT.CaseId);
        } 
        return setCaseId;
    }
    
    private static Map<Id,Case> getCaseMap(Set<Id> setCaseId) {
        Map<Id,Case> mapCase = new Map<Id,Case>();
        if(Schema.sObjectType.Case.isAccessible()) { 
            mapCase = new Map<Id,Case>([SELECT Id,Status,OwnerId,Owner.Name,Hide_from_Customer__c,Contact.Account.EC_Division__c,Assigned_To_Queue__c 
                                        FROM Case WHERE Id IN :setCaseId AND Case.RecordType.Name='Support']);
        }
        return mapCase;
    }
    
    private static void updateCaseafterChatComplete(LiveChatTranscript objLCT, Case objCase) {
        if(objLCT.Status=='Completed' && (objCase.Owner.Name=='Chat Pending' || (Test.isRunningTest() && objCase.Assigned_To_Queue__c=='Chat Pending'))) {
            if(objCase.Hide_from_Customer__c==true && objCase.Status!='Resolved' && Group.sObjectType.getDescribe().isAccessible()) {
                Group grouprec = [SELECT Id FROM Group where DeveloperName='Abandoned_Cases' limit 1];
                objCase.Status = 'Resolved';
                objCase.Resolution_Category__c = 'Case Abandoned';
                objCase.Resolution_Description__c = 'No follow up requested';
                objCase.OwnerId = grouprec.Id;                               
            } else {
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                objCase.setOptions(dmlOpts);
            }
            if(Schema.sObjectType.Case.isUpdateable()) update objCase; 
        }
    }
    
    private static void updateCaseafterChatInProgress(LiveChatTranscript objLCT, Case objCase) {
        if(objLCT.Status=='InProgress' || isInprogress) {
            objCase.Assigned_To_Queue__c = null;
            objCase.OwnerId = objLCT.OwnerId;
            String EBSDivisions = getConstantValue('EBS_Division');
            String NSAPDivisions = getConstantValue('NSAP_Division');
            Set<String> lstEBS = new Set<String>(EBSDivisions.split(','));
            Set<String> lstNSAP = new Set<String>(NSAPDivisions.split(','));
            if(String.isNotBlank(objCase.Contact.Account.EC_Division__c) && containsIgnoreCase(lstEBS, objCase.Contact.Account.EC_Division__c)) {
                objCase.Assigned_To_Queue__c = 'EBS Agents';
            } else if(String.isNotBlank(objCase.Contact.Account.EC_Division__c) && containsIgnoreCase(lstNSAP, objCase.Contact.Account.EC_Division__c)) {
                objCase.Assigned_To_Queue__c = 'NSAP Agents';
            }       
            objCase.Status = 'Assigned';
            if(Schema.sObjectType.Case.isUpdateable()) update objCase;
        }
    }
    
    private static Boolean containsIgnoreCase(Set<String> setValues, String toCompare) {
        for(String strVal : setValues) {
            if(strVal.equalsIgnoreCase(toCompare)) return true;
        }
        return false;
    }
    
    private static String getConstantValue(String keyname) {   
        String value;
        if(Schema.sObjectType.Service_Cloud_Constant__mdt.isAccessible()) { 
            List<Service_Cloud_Constant__mdt> objSCV = [SELECT Id,Value__c FROM Service_Cloud_Constant__mdt WHERE QualifiedApiName=:keyname LIMIT 1];
            if(!objSCV.isEmpty()) value = objSCV[0].Value__c;
        }
        return value;
    }
    
    @Testvisible private static boolean isInprogress = false;
    
    @TestVisible private LiveChatTranscriptTriggerHandler(){} //added as per suggestion of codescan
}