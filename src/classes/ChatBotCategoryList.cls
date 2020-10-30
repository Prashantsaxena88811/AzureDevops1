/* Class Name      :ChatBotCategoryList
* Description      :class called from einstien bot
* Created By       :Graytitude Team
* Created On       :14.09.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          14.09.2020                                      return list of categories from chat bot routing records
*/
public without sharing class ChatBotCategoryList {
    
    public class Input{
       @InvocableVariable
       public String category;
       @InvocableVariable(required=true)
        public String routableId;
    }
    
    @InvocableMethod(label='Get Categories')
    public static List<List<String>> getCategories(List<Input> input){
        List<List<String>> chatBotRoutings = new List<List<String>>();
        Set<String> setCategories = new Set<String>(); 
        try{            
            if(String.isNotBlank(input[0].category)) {
                setCategories = getSubCategories(input[0].category, input[0].routableId);
            } else {               
                setCategories = getCategory(input[0].routableId);
            }
            List<String> lstCategories = new List<String>(setCategories);
            lstCategories.sort();
            chatBotRoutings.add(new List<String>(lstCategories));
            return chatBotRoutings;
        }
        catch(Exception ex) { chatBotRoutings.add(new List<String>{'Error!!'}); return chatBotRoutings; }
    }
    
    private static Set<String> getSubCategories(String category, String routableId) {
        Set<String> setSubCategories = new Set<String>(); 
        LiveChatTranscript objCT;
        if(Schema.sObjectType.LiveChatTranscript.isAccessible()) {  
            objCT = [SELECT Id, Contact.account.EC_Division__c FROM LiveChatTranscript WHERE Id=:routableId];  
        }
        String division;
        if(objCT.contact.account.EC_Division__c!=null) {
            division = objCT.contact.account.EC_Division__c;
        }
        if(Schema.sObjectType.Chat_Bot_Routing__c.isAccessible()) {        
            for(Chat_Bot_Routing__c routing : [SELECT Sub_Category__c,Division__c FROM Chat_Bot_Routing__c where  Category__c =:category AND Sub_Category__c!=null])
            { 
                if(routing.Division__c==null || routing.Division__c=='All' || (division!=null && routing.Division__c.containsIgnoreCase(division)))
                    setSubCategories.add(routing.Sub_Category__c);                
            }
        }
        return setSubCategories;
    }
    
    private static Set<String> getCategory(String routableId) {
        Set<String> setCategories = new Set<String>(); 
        LiveChatTranscript objCT;
        if(Schema.sObjectType.LiveChatTranscript.isAccessible()) {  
            objCT = [SELECT Id, Contact.account.EC_Division__c FROM LiveChatTranscript WHERE Id=:routableId];  
        }
        String division;
        if(objCT.contact.account.EC_Division__c!=null) {
            division = objCT.contact.account.EC_Division__c;
        }
        if(Schema.sObjectType.Chat_Bot_Routing__c.isAccessible()) {        
            for(Chat_Bot_Routing__c routing : [SELECT Category__c,Division__c FROM Chat_Bot_Routing__c where Category__c!=null]) {
                if(routing.Division__c==null || routing.Division__c=='All' || (division!=null && routing.Division__c.containsIgnoreCase(division)))
                setCategories.add(routing.Category__c);                
            }
        }
        return setCategories;
    }
    
    @TestVisible private ChatBotCategoryList(){} //added as per suggestion of codescan
}