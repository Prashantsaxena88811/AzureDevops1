/* Class Name      :ChatBotRelatedAccountList
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
public without sharing class ChatBotRelatedAccountList {
    
    public class Input{
       @InvocableVariable(required=true)
        public String routableId;
    }
    
    @InvocableMethod(label='Get Related Account')
    public static List<List<String>> getRelatedAccount(List<Input> input){
        List<String> lstAccount = new List<String>();  
        LiveChatTranscript objCT;
        if(Schema.sObjectType.LiveChatTranscript.isAccessible()) { 
            objCT = [SELECT Id,ContactId,ContactId__c FROM LiveChatTranscript WHERE Id=:input[0].routableId];
        }
        if(Schema.sObjectType.AccountContactRelation.isAccessible()) { 
            for(AccountContactRelation objACR : [SELECT Account.Name,Account.EC_Account_Number__c FROM AccountContactRelation WHERE ContactId=:objCT.ContactId AND Account.EC_Account_Number__c!=null AND IsActive=true]) {
                lstAccount.add(objACR.Account.Name + ' : ' + objACR.Account.EC_Account_Number__c);
            }
        }
        return new List<List<String>>{lstAccount};
    }
    
    @TestVisible private ChatBotRelatedAccountList(){} //added as per suggestion of codescan
}