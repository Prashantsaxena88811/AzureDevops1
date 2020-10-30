/* Class Name      :SupportCaseCreateGuestController
* Description      :Guest User Case Creation Form Controller
* Created By       :Graytitude Team
* Created On       :25-09-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team       25-09-2020                                         Community Case Creation Form Controller for Guest
*/
public without sharing class SupportCaseCreateGuestController{
    
    
    
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
        }catch(Exception e){ throw new AuraHandledException(e.getMessage()); }        
    }
    //Create a case record for guest user.
    @AuraEnabled
    public static String saveCase(Case objCase){   
        try{
            objCase.Origin = 'Web Support';
            objCase.Run_Assignment_Rule__c = true;            
            objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
            if(Schema.sObjectType.Case.isCreateable()){
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                objCase.setOptions(dmlOpts);
                Insert objCase; 
            }
            return objCase.id; 
        }catch(Exception e){ throw new AuraHandledException(e.getMessage());  }
    }
}