/* Class Name       :EC_CacheHelperTest
* Description      :Test Class classfor EC_CacheComponent 
* Created By       :Shruti Sinha
* Created On       :07-05-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Shivam Vats         07-05-2019                                   controller class for EC_CacheComponent
* 
*/
@isTest

public class EC_CacheHelperTest {
	
	/***************************************************************************************************************************************
	 Method Name :  getCacheInfoTest
	 Description : test method for getCacheInfo
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
    
    public static testmethod void  getUpdateCacheTest(){
        EC_TestData.setupTestSalesRepUser() ;
        User usr = [Select Id,FirstName,LastName,ProfileId,ContactId from User where LastName= 'SalesRepUser'];
        EC_TestData.createContactForSalesrep(2);
        ccrz.cc_CallContext.effAccountId = EC_TestData.testAccount.id;
        test.startTest();
        System.runAs(usr){
            EC_CacheHelper.updateCache(); 
            EC_CacheWrapper wrp = EC_CacheHelper.getCacheInfo();
            System.assertEquals(wrp!=null, true);
            test.stopTest();
        }  

    }
	/***************************************************************************************************************************************
	 Method Name :  getCacheInfoTest
	 Description : test method for getCacheInfo
	 Return type : void
	 Author      : Shruti Sinha
	 *************************************************************************************************************************************/
    
    public static testmethod void  getCacheInfoTest(){
        EC_TestData.setupTestSalesRepUser() ;
        User usr = [Select Id,FirstName,LastName,ProfileId,ContactId from User where LastName= 'SalesRepUser'];
        EC_TestData.createContactForSalesrep(2);
        
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(EC_Constants.USRCACHE);
        System.runAs(usr){
            test.startTest();
            EC_CacheWrapper wrp = EC_CacheHelper.getCacheInfo(); 

            EC_CacheHelper.clearCache();
            test.stopTest();  
			          
        }  


    }
    
    /***************************************************************************************************************************************
Method Name :  getUpdateCacheTestForSalesRep
Description : to Update CacheFor SalesRep
Return type : void
Author      : Shruti Sinha
*************************************************************************************************************************************/    
    public static testmethod void getUpdateCacheforSalesRep(){
        
        EC_TestData.setupTestSalesRepUser() ;
        User usr = [Select Id,FirstName,LastName,ProfileId,ContactId from User where LastName= 'SalesRepUser'];
        test.startTest();
        System.runAs(usr){
            EC_TestData.createContactForSalesrep(2);
            EC_CacheHelper.updateCache(); 
            test.stopTest();
        }
    }
    
    
    /***************************************************************************************************************************************
Method Name :  getUpdateCacheTestForUser
Description : to Update Cache For User
Return type : void
Author      : Shruti Sinha
*************************************************************************************************************************************/    
    public static testmethod void getUpdateCacheTestForUser(){
        EC_TestData.setupTestUser();
        EC_TestData.setupCatalog();
        User usr = [Select Id,FirstName,LastName,ProfileId,ContactId,UserRoleId from User where LastName= 'TestUser'];
        system.assert(usr!=null);
        System.runAs(usr){
            test.startTest();             
            EC_CacheHelper.updateCache();            
            test.stopTest();
        }
    }
}