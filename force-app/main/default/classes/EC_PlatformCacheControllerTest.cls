@isTest
public class EC_PlatformCacheControllerTest{
    
    @isTest 
    static void cacheDataTest(){
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];

        List<String> cacheValue= new List<String>();
         system.runas(thisUser){
            
            Test.startTest();
            
            cacheValue = null;
            System.assertEquals(EC_PlatformCacheController.cacheData('local.UserCache.cacheValue',cacheValue),null);
            
            cacheValue= new List<String>{'cacheValue','cachevalue2'};
            System.assertEquals(EC_PlatformCacheController.cacheData('local.UserCache.cacheValue',cacheValue),cacheValue);
            
            System.assertEquals(EC_PlatformCacheController.cacheData('local.UserCache.cacheValue',cacheValue),cacheValue);
            
            Test.stopTest();
             
         }
        
    }
    

}