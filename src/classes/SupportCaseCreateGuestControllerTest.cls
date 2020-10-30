/* Class Name      :SupportCaseCreateGuestControllerTest
* Description      :Test class of Guest user Case Creation Form Controller
* Created By       :Graytitude Team
* Created On       :26-09-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team        26-09-2020                                        Test Class of Guest User Case Creation Form Controller
*/
@isTest
private class SupportCaseCreateGuestControllerTest{
    @isTest
    static void createAsGuest(){
        
        User customer = [select id, contactid from User where profile.name = 'Ecolab Profile' and isactive = true limit 1];
        
        knowledge__kav newArticle = new knowledge__kav(Title='How to checkout',summary='How to checkout',urlname='How-to-Checkout9876', category__c = 'Checkout', Sub_Category__c = 'How to checkout');
        insert newArticle;
        
        knowledge__kav viewArticle = SupportCaseCreateGuestController.getDefaultValues(newArticle.urlname);
        String caseId;
        Case objCase = SupportCaseCreateGuestControllerTest.createCase(viewArticle );
        system.RunAs(customer){
          caseId = SupportCaseCreateGuestController.saveCase(objCase);
        }
        System.AssertNotEquals(caseId, null);
        system.assertEquals(customer.Id, [select id, createdById from case where id=: caseId].createdById);
    }
    private static Case createCase(knowledge__kav viewArticle){
        return new Case(Category__c = viewArticle.Category__c,
                        Sub_Category__c = viewArticle.Sub_Category__c, Run_Assignment_Rule__c = TRUE);
    }    
}