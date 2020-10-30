/* Class Name      :Support_Control_RelatedArticlesCtrlTest 
* Description      :Test class for Support_Control_RelatedArticlesCtrl
* Created By       :Graytitude Team
* Created On       :24-09-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team       24-09-2020                                         Test Class created
*/
@isTest
public class Support_Control_RelatedArticlesCtrlTest {
    @isTest
    public static void TestMethod1(){
        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'systemadmin' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User runUser = new User(Alias = 'standt', Email='systemadmin@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName, 
        UserPermissionsKnowledgeUser = true);
 
        system.runAs(runUser){
        Knowledge__kav article = new Knowledge__kav();
        article.Title = 'test';
        article.Article_Content__c = 'test content';
        article.UrlName = 'test';
        insert article;        
        Knowledge__DataCategorySelection dataCategory = new Knowledge__DataCategorySelection();
        dataCategory.ParentId = article.Id;
        dataCategory.DataCategoryGroupName = 'Support';
        dataCategory.DataCategoryName = 'Login';
        insert dataCategory;
        Test.startTest();
        String datacategoryStr = Support_Control_RelatedArticlesCtrl.getDataCategory(article.UrlName);
        Test.stopTest();
        System.assertNotEquals(datacategoryStr, null);
        System.assertEquals(datacategoryStr, dataCategory.DataCategoryName);
        }
    }
}