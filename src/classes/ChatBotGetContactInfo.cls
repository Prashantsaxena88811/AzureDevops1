/* Class Name      :ChatBotGetContactInfo
* Description      :class called from einstien bot
* Created By       :Graytitude Team
* Created On       :14.09.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          14.09.2020                                      return list of related accounts to a contact
*/
public without sharing class ChatBotGetContactInfo {
    
    public class Input{
       @InvocableVariable(required=true)
        public String routableId;
    }
    
    public class Output{
        @InvocableVariable
        public String info_caseemail;
        @InvocableVariable
        public String info_casephone;
        @InvocableVariable
        public String info_division;
    }
    
    @InvocableMethod(label='Get Contact Info') 
    public static List<Output> getContactInfo(List<Input> input){
        List<Output> lstResponse = new List<Output>();   
        if(Schema.sObjectType.LiveChatTranscript.isAccessible()) {    
            LiveChatTranscript objCT = [SELECT Id,ContactId,Contact.Email,Contact.Phone,Contact.Division__c FROM LiveChatTranscript WHERE Id=:input[0].routableId];
            Output response = new Output();
            response.info_caseemail = objCT.Contact.Email;
            response.info_casephone = objCT.Contact.Phone;
            response.info_division = objCT.Contact.Division__c;
            if(String.isNotBlank(response.info_division))  response.info_division = response.info_division.toUpperCase();
            lstResponse.add(response);
        }
        return lstResponse;
    }
    
    @TestVisible private ChatBotGetContactInfo(){} //added as per suggestion of codescan
}