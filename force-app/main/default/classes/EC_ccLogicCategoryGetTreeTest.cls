/* Class Name    : EC_ccLogicCategoryGetTreeTest
 * Description      Test Class to cover EC_ccLogicCategoryGetTree
 * Created By       :Viraj  
 * Created On       :2019-Jul-01
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Jul-01       BC-74102            Created the class   
 *
 */
@isTest
public class EC_ccLogicCategoryGetTreeTest{
    /***************************************************************************************************************************************
	Method Name : getTreeTest
	Description : Test method to cover getTree method
	Return type : void
	*************************************************************************************************************************************/
    @isTest 
    static void getTreeTest(){
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];

         system.runas(thisUser){
         	
            Map<String,Object> inData = new Map<String,Object>();
            Map<String,String> queryParamIn = new Map<String,String>();
            EC_TestData.setupTestUser();  
            EC_TestData.setupCatalog();
            ccrz.cc_RemoteActionContext rCon = new ccrz.cc_RemoteActionContext();
            List<Account> accountGroup = [Select id from Account];
            queryParamIn.put('currAccountGroup',accountGroup[0].id);
	        rCon.effAccountId =accountGroup[0].id;
	        rCon.queryParams = queryParamIn;
	        ccrz.cc_CallContext.initRemoteContext(rCon);
	        
	        ccrz__E_Category__c cat1 = new ccrz__E_Category__c();
	        cat1.ccrz__CategoryID__c='ECOLAB-ROOT';
	        cat1.ccrz__SEOId__c='ecolabroot';
	        cat1.name='EcoLabRoot';
	        insert cat1;
	        ccrz__E_Category__c cat2 = new ccrz__E_Category__c();
	        cat2.ccrz__CategoryID__c='ECOLAB-ROOT2';
	        cat2.ccrz__ParentCategory__c=cat1.id;
	        cat2.ccrz__SEOId__c='ecolabroot2';
	        cat2.name='EcoLabRoot2';
	        insert cat2;
	        ccrz__E_Category__c cat3 = new ccrz__E_Category__c();
	        cat3.ccrz__CategoryID__c='ECOLAB-ROOT3';
	        cat3.ccrz__ParentCategory__c=cat1.id;
	        cat3.ccrz__SEOId__c='ecolabroot3';
	        cat3.name='EcoLabRoot3';
	        insert cat3;
	        
	        List<ccrz__E_Product__c> prodList = [SELECT id,name from ccrz__E_Product__c where name ='product001 Bag'];
	        
	        ccrz__E_ProductCategory__c prodcat1 = new ccrz__E_ProductCategory__c();
	        prodcat1.ccrz__Category__c=cat1.id;
	        prodcat1.ccrz__Product__c=prodList[0].id;
	        insert prodcat1;
	        ccrz__E_ProductCategory__c prodcat2 = new ccrz__E_ProductCategory__c();
	        prodcat2.ccrz__Category__c=cat2.id;
	        prodcat2.ccrz__Product__c=prodList[0].id;
	        //insert prodcat2;
	        ccrz__E_ProductCategory__c prodcat3 = new ccrz__E_ProductCategory__c();
	        prodcat3.ccrz__Category__c=cat3.id;
	        prodcat3.ccrz__Product__c=prodList[0].id;
	        //insert prodcat3;
	        
            String jsonString='[ { "sfid":"'+cat1.id+'", "categoryID":"ECOLAB-ROOT", "SEOId":"ecolabroot", "name":"EcoLabRoot", "children":[ { "sfid":"'+cat2.id+'", "categoryID":"EcoCat1", "SEOId":"ecocat1", "parentCategory":"'+cat1.id+'", "name":"EcoCat1", "children":[ { "sfid":"'+cat3.id+'", "categoryID":"EcoCat1SubCat1", "SEOId":"ecocat1subcat1", "parentCategory":"'+cat2.id+'", "name":"EcoCat1SubCat1" } ] } ] } ]';
            inData.put(ccrz.ccApiCategory.CATEGORYTREE,JSON.deserializeUntyped(jsonString));
            EC_ccLogicCategoryGetTree classOb = new EC_ccLogicCategoryGetTree();
            
            Test.startTest();
          
            Map<String,Object> outData = new Map<String,Object>();
            outData = classOb.getTree(inData);
            System.assertNotEquals(outData,null);
            
            jsonString='[ { "categoryID":"ECOLAB-ROOT", "SEOId":"ecolabroot", "name":"EcoLabRoot", "children": { "categoryID":"EcoCat1", "SEOId":"ecocat1", "parentCategory":"'+cat1.id+'", "name":"EcoCat1", "children": { "categoryID":"EcoCat1SubCat1", "SEOId":"ecocat1subcat1", "parentCategory":"'+cat2.id+'", "name":"EcoCat1SubCat1" }  }  } ]';
            inData.put(ccrz.ccApiCategory.CATEGORYTREE,JSON.deserializeUntyped(jsonString));
            outData = classOb.getTree(inData);
            System.assertNotEquals(outData,null);
            
            jsonString='[ { "sfid":"'+cat1.id+'", "categoryID":"ECOLAB-ROOT", "SEOId":"ecolabroot", "name":"EcoLabRoot", "children":[ { "sfid":"'+cat2.id+'", "categoryID":"EcoCat1", "SEOId":"ecocat1", "parentCategory":"'+cat1.id+'", "name":"EcoCat1", "children":[ { "sfid":"'+cat3.id+'", "categoryID":"EcoCat1SubCat1", "SEOId":"ecocat1subcat1", "parentCategory":"'+cat2.id+'", "name":"EcoCat1SubCat1" } ] } ] } ]';
            inData.put(ccrz.ccApiCategory.CATEGORYTREE,JSON.deserializeUntyped(jsonString));
            outData = classOb.getTree(inData);
            System.assertNotEquals(outData,null);
            Test.stopTest();
             
         }
        
    }
    

}