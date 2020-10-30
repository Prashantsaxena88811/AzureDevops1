/* Class Name       :EC_EntitlementCacheTest
* Description      :Test Class classfor EC_EntitlementCache 
* Created By       :Ranganath C N
* Created On       :20-08-2020
*
*/
@isTest

public class EC_EntitlementCacheTest {
    
    /***************************************************************************************************************************************
    Method Name : getCacheInfoTest
    Description : test method to get cacheinfo
    Return type : NA
    Author      : Ranganath C N
    *************************************************************************************************************************************/
    public static testmethod void  getCacheInfoTest(){
        
        Account acc = EC_ISETestDataFactory.testAccount_ISEIndirect;
        EC_ISETestDataFactory.setupInstSalesEntitlements();
        
        test.startTest();
        /*code coverage private constructor*/
        EC_EntitlementCacheUtility ent = new EC_EntitlementCacheUtility();
        system.debug(ent);

        EC_EntitlementCacheDTO DTO = EC_EntitlementCacheUtility.getINSTSalesEntitlementCache(acc.Id);
        System.assert(DTO != null);
        EC_EntitlementCacheUtility.clearCache(acc.Id);
        test.stopTest();
        
    }
    
	/***************************************************************************************************************************************
	Method Name : getINSTSalesEntitlementsTest
	Description : test method to setupInstSalesEntitlements
	Return type : NA
	Author      : Ranganath C N
	*************************************************************************************************************************************/
    
    public static testmethod void  getINSTSalesEntitlementsTest(){
        
        Account acc = EC_ISETestDataFactory.testAccount_ISEDirect;
        EC_ISETestDataFactory.setupInstSalesEntitlements();
        
        test.startTest();
        EC_EntitlementCacheDTO DTOCache = EC_EntitlementCacheUtility.getINSTSalesEntitlements(acc.Id);
        System.assert(DTOCache !=null);
        test.stopTest();
    } 
}