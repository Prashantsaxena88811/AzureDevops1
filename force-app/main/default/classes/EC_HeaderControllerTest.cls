/* Class Name    : EC_HeaderControllerTest
 * Description      Test Class to cover EC_HeaderController
 * Created By       :Viraj 
 * Created On       :2019-Aug-29
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                 2019-Aug-29              BC-76699        Created the class   
 *
 */
@isTest
public class EC_HeaderControllerTest{
    /***************************************************************************************************************************************
    Method Name : headerTest
    Description : Test method to cover multiple controller classes
    Return type : void
    *************************************************************************************************************************************/
    @isTest 
    static void headerTest(){
        
        
        User thisUser = [SELECT Id,ContactId,Contact.AccountId  FROM User WHERE Id = :UserInfo.getUserId()];
        
        List<PermissionSet> permSetList = [Select Id,Name from PermissionSet where Name = 'EC_BuyerSet'];
        PermissionSetAssignment permSet = new PermissionSetAssignment ();
        permSet.AssigneeId = thisUser.id;
        if(permSetList.size()>0){
            permSet.PermissionSetId = permSetList[0].id;
            insert permSet;
        }
        EC_CacheWrapper usrInfo;
        usrInfo = new EC_CacheWrapper();
        //usrInfo.lstPermisssionSet = permissionSetList;
        EC_CacheHelper.updateCache();
        //Cache.Session.put('local.UserCache.UserInfo1',usrInfo);
        
        system.runas(thisUser){
            
            
            Test.startTest();
            
            ccrz.cc_CallContext.effAccountId = EC_TestData.testAccount.id;
            
            EC_HeaderController classOb = new EC_HeaderController();
            EC_ProductDetailController classOb2  = new EC_ProductDetailController();
            EC_ProductListController classOb3 = new EC_ProductListController();
            EC_MiniCartController classOb4 = new EC_MiniCartController();
            EC_QuickOrderController classOb5 = new EC_QuickOrderController();
            EC_SuggestedProducts classOb6 = new EC_SuggestedProducts();
            ccrz__E_Category__c testAllRoot = new ccrz__E_Category__c(
                    Name                = 'Products',
                    ccrz__CategoryID__c = '0',
                    ccrz__StartDate__c  = Date.today().addDays(-1),
                    ccrz__EndDate__c    = Date.today().addDays(1)
            );
            insert testAllRoot;
            EC_QuickListController  classOb7 = new EC_QuickListController();
            EC_CartDetailController classOb8 = new EC_CartDetailController();
            
            System.assertNotEquals(classOb ,null);
              
            Test.stopTest();
            
        }
    }
    /***************************************************************************************************************************************
    Method Name : headerTest2
    Description : Test method to cover multiple controller classes
    Return type : void
    *************************************************************************************************************************************/
    @isTest 
    static void headerTest2(){
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        
        EC_OutageFlag__c outFlag  = new EC_OutageFlag__c();
        outFlag.EC_isCommunityActive__c = true;
        outFlag.Name ='CommunityActive';
        insert outFlag;
        
        EC_TestData.setupTestUser();
        EC_TestData.setupcatalog();
        User TestUser = [SELECT id,ContactId,Contact.AccountId,LastName  from User where LastName = 'TestUser' and Alias = 'cctest'];
        
        Contact currCon = TestUser.Contact;
        String accId = currCon.AccountId;
        currCon.AccountId = EC_TestData.testAccountShipTo.id;
        currCon.EC_SalesRep_User__c = UserInfo.getUserId();
        update currCon;
        
        system.runas(TestUser){
            
            EC_CacheWrapper usrInfo  ;
            usrInfo = new EC_CacheWrapper();
            //usrInfo.lstPermisssionSet = permissionSetList;
            EC_CacheHelper.updateCache();
            //Cache.Session.put('local.UserCache.UserInfo1',usrInfo);
        
            Test.startTest();
            
            ccrz.cc_CallContext.effAccountId = currCon.AccountId;
            
            EC_HeaderController classOb = new EC_HeaderController();
             EC_CartDetailController classOb8 = new EC_CartDetailController();
            System.assertNotEquals(classOb ,null);
              
            Test.stopTest();
            
        }
    }
}