/* Class Name      :Support_Control_RelatedArticlesCtrl
* Description      :Community Article related Controller
* Created By       :Graytitude Team
* Created On       :24-09-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team       24-09-2020                                         fetches the data category from article record
*/
public without sharing class Support_Control_RelatedArticlesCtrl {
    @AuraEnabled
    public static String getDataCategory(String UrlName){
        String dataCategory;
        try{
            if(Schema.sObjectType.Knowledge__DataCategorySelection.isAccessible()){
                List<Knowledge__DataCategorySelection> lstDC = [SELECT Id,DataCategoryName FROM Knowledge__DataCategorySelection WHERE Parent.UrlName=:UrlName limit 1];        
                if(!lstDC.isEmpty()) {
                    dataCategory = lstDC[0].DataCategoryName;
                }
            }
         } catch(Exception e){ throw new AuraHandledException(e.getMessage()); }
        return dataCategory;
    }
}