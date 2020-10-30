/* Class Name      :PreChatFormController
* Description      :Controller class for PreChatForm Aura Component
* Created By       :Graytitude Team
* Created On       :14.09.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          14.09.2020                                      fetchContact - method to fetch contact related to passed userid
*/
public without sharing class PreChatFormController {
    
    @AuraEnabled 
    public static Contact fetchContact(String userId){
        try{
            // query current user information  
            List<User> lstUser;            
            if(Schema.sObjectType.User.isAccessible()) {
                lstUser = [select Id,ContactId,Contact.FirstName,Contact.LastName,EC_CDM_User__c FROM User WHERE Id=:userId LIMIT 1]; 
            }
            if(!lstUser.isEmpty()) {
                if(isexemption) lstUser = null;
                return getContact(lstUser[0]);
            }			
        } catch(Exception e) { throw new AuraHandledException(e.getMessage()); } return null;        
    }
    
    private static contact getContact(User objUser) {
        Contact objCon;
        if(objUser.ContactId!=null && Schema.sObjectType.User.isAccessible()) {
            objCon = new Contact(Id=objUser.ContactId, FirstName=objUser.Contact.FirstName, LastName=objUser.Contact.LastName);
        }
        else if(objUser.EC_CDM_User__c!=null && Schema.sObjectType.Contact.isAccessible()) {            
            List<Contact> lstContact = [SELECT Id,FirstName,LastName FROm Contact WHERE EC_CDM_Contact__c=:objUser.EC_CDM_User__c LIMIT 1];
            if(!lstContact.isEmpty()) { objCon = lstContact[0]; }
        }
        return objCon;
    }
        
    @Testvisible private static boolean isexemption = false;
    
}