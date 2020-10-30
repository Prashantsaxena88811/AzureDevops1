/* Class Name      :SupportCaseCreateController
* Description      :Community Case Creation Form Controller
* Created By       :Graytitude Team
* Created On       :14-09-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team       14-09-2020                                         Community Case Creation Form Controller
*/
public without sharing class SupportCaseCreateController{
    
    //Method to get Contact Id
    //Contact Id for Community user or CDM Contact in case of Sales Rep user.
    @AuraEnabled
    public static Contact getContactId(Id userId){        
        try{
            contact objContact = new contact();
            if(Schema.sObjectType.User.isAccessible()){
                list<user> users = [select contactid, contact.Email, contact.Phone, EC_CDM_User__c from user where id=:userId];
                if(users[0].contactid == null){    
                    //It's for Sales Rep user because it's internal user. Through CDM User field match with CDM Contact.
                    if(users[0].EC_CDM_User__c!=null && Schema.sObjectType.Contact.isAccessible()){
                        list<contact> contacts  = [select id, Email, Phone from contact where EC_CDM_Contact__c=:users[0].EC_CDM_User__c];
                        objContact = contacts.isEmpty() ? new Contact() : contacts[0];
                    }                           
                }
                else{
                    objContact = new Contact(Id = users[0].contactId, Email = users[0].contact.Email, Phone = users[0].contact.Phone);
                }
            }
            return objContact;
        }catch(Exception e){ throw new AuraHandledException(e.getMessage()); }
    }
    
    //On Case form, populate "Account" dropdown to show all accounts which are related to either Customer's contact or Sales Rep's Contact.
    @AuraEnabled(cacheable=true)
    public static list<AccountContactRelation> getContactRelatedAccounts(Id contactId){
        list<AccountContactRelation> lstACR = new list<AccountContactRelation>();
        try{
            if(Schema.sObjectType.AccountContactRelation.isAccessible()){
                lstACR = [SELECT Id, AccountId, Account.Name, ContactId FROM AccountContactRelation where ContactId=:contactId];
            }
        }catch(Exception e){ throw new AuraHandledException(e.getMessage()); }
        return lstACR;
    }
    
    //Get record type of Case to set once we create a case record from community.
    @AuraEnabled
    public static Id getIssueRecordTypeId(){
        try{
            return Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        }catch(Exception e){ throw new AuraHandledException(e.getMessage()); }
    }
    //Get category and sub category value of Knowledge record on which user click on contact support button.
    @AuraEnabled
    public static Knowledge__kav getDefaultValues(String articleUrl){
        try{
            Knowledge__kav artical = new Knowledge__kav();
            if(Schema.sObjectType.Knowledge__kav.isAccessible()){
                artical = [SELECT Title, UrlName, Id, Category__c, Sub_Category__c
                    FROM Knowledge__kav 
                    Where UrlName =: articleUrl];
            }
            return artical;
        }catch(Exception e){   throw new AuraHandledException(e.getMessage());  }        
    }
    //Create a case and share record if case is created as sales rep. Because case is private, so need to share with sales rep user.
    @AuraEnabled
    public static String saveCase(Case objCase){      
        try{
            if(Schema.sObjectType.Case.isCreateable()){
                Insert objCase; 
            }
            if(Schema.sObjectType.User.isAccessible()){
                List<User> currentUser = [Select Id from User Where Id = : userInfo.getUserId() AND ContactId = null];
                if(!currentUser.isEmpty()) {
                
                    CaseShare caseShr  = new CaseShare();
                    caseShr.CaseId = objCase.id;
                    caseShr.UserOrGroupId = userInfo.getUserId();
                    caseShr.CaseAccessLevel = 'Edit';
                    caseShr.RowCause = Schema.CaseShare.RowCause.Manual;
                    if(Schema.sObjectType.CaseShare.isCreateable()){
                        Insert caseShr;
                    }
                }      
            }  
            return objCase.id;   
        }catch(Exception e){ throw new AuraHandledException(e.getMessage());  }
    }
}