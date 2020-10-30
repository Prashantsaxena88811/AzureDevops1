/* Class Name      :ChatBotCaseCreate
* Description      :class called from einstien bot
* Created By       :Graytitude Team
* Created On       :14.09.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          14.09.2020                                      create case from the einstien bot
*/
public without sharing class ChatBotCaseCreate {
    
    public class Request{
        @InvocableVariable(required=true)
        public String routableId;
        @InvocableVariable(required=true)
        public String category;
        @InvocableVariable(required=true)
        public String subcategory;
        @InvocableVariable(required=true)
        public String accountnumber;
        @InvocableVariable
        public String description;
        @InvocableVariable
        public String phone;
        @InvocableVariable
        public String email;
    }
    
    @InvocableMethod(label='Create Case')
    public static List<String> createCase(List<Request> input){
        List<String> response = new List<String>(); 
        try {
            LiveChatTranscript objCT;
            if(Schema.sObjectType.LiveChatTranscript.isAccessible()) { 
                objCT = [SELECT Id,AccountId,ContactId,CaseId FROM LiveChatTranscript WHERE Id=:input[0].routableId];
            }
            Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
            if(objCT.CaseId!=null) return response;
            
            Case objCase = new Case(
                RecordTypeId = caseRTId,
                ContactId = objCT.ContactId,
                Category__c = input[0].category,
                Sub_Category__c = input[0].subcategory,
                SuppliedPhone = input[0].phone,
                Contact_Email__c = input[0].email,
                Subject = input[0].description,
                Origin = 'Chatbot',
                Run_Assignment_Rule__c = true,                
                Hide_from_Customer__c = true
            );
            if(String.isNotBlank(input[0].accountnumber) && input[0].accountnumber.contains(':') && Schema.sObjectType.Account.isAccessible()) {
                String accNum = input[0].accountnumber.split(':')[1];
                accNum = accNum.trim();
                for(Account objAcc : [SELECT Id FROM Account WHERE EC_Account_Number__c=:accNum]) {
                    objCase.AccountId = objAcc.Id;
                }
            }         
            objCase = createCase(objCase);
            updateChatTranscript(objCT.Id,objCase.Id);            
            response.add(objCase.CaseNumber);
        } catch(Exception ex) { response.add('error'); }
        return response;
    }
    
    private static void updateChatTranscript(Id ctId, Id caseId) {
        if(Schema.sObjectType.LiveChatTranscript.isUpdateable()) {
            LiveChatTranscript newLCT = new LiveChatTranscript(Id=ctId, caseId=caseId);
            update newLCT;
        }
    }
    
    private static Case createCase(Case objCase) {
        if(Schema.sObjectType.Case.isCreateable()) {
            insert objCase;
        }
        Case caseRec;
        if(Schema.sObjectType.Case.isAccessible()){
            caseRec = [SELECT Id,CaseNumber FROM Case WHERE Id=:objCase.Id LIMIT 1];
        }
        return caseRec;
    }
    
    @TestVisible private ChatBotCaseCreate(){} //added as per suggestion of codescan
}