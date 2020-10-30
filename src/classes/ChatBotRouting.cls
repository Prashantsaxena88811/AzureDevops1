/* Class Name      :ChatBotRouting
* Description      :class called from einstien bot
* Created By       :Graytitude Team
* Created On       :14.09.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          14.09.2020                                   helps bot to identify whether the chat session 
																		can be transferred to agent or to create case
*/
public without sharing class ChatBotRouting {
    
    public class RoutingRequest{
       @InvocableVariable
       public String category;
       @InvocableVariable
       public String subCategory;
        @InvocableVariable(required=true)
        public String routableId;
    }
    public class RoutingResponse{
       @InvocableVariable
       public Boolean showArticle;
       @InvocableVariable
       public Boolean transferAgent;
       @InvocableVariable
       public Boolean createCase;                   
    }
    
    @InvocableMethod(label='Chatbot Route Info')
    public static List<RoutingResponse> chatBotRoutingData(List<RoutingRequest> ChatBotRoutingRequest){
        List<RoutingResponse> ChatBotRoutings = new List<RoutingResponse>();   
        
        
        for(Chat_Bot_Routing__c routing : [select id, Sub_Category__c, Show_Walkme__c, Show_Article__c, Transfer_to_Agent__c, Create_Case__c,Division__c 
                                              FROM Chat_Bot_Routing__c where Category__c =: ChatBotRoutingRequest[0].category and 
                                              Sub_Category__c =: ChatBotRoutingRequest[0].subCategory limit 1])
        {             
            RoutingResponse routeRec = new RoutingResponse();
            routeRec.showArticle = routing.Show_Article__c || routing.Show_Walkme__c;            
            routeRec.transferAgent = routing.Transfer_to_Agent__c;            
            routeRec.createCase = routing.Create_Case__c;  
            ChatBotRoutings.add(routeRec);        
        }
        return ChatBotRoutings;
    }
    
    @TestVisible private ChatBotRouting(){} //added as per suggestion of codescan
    
}