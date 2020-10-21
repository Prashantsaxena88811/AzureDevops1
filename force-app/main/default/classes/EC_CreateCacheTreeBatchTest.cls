/* Class Name    : EC_CreateCacheTreeBatchTest
 * Description      Test class for Storing/Creating the cache tree of all categories
 * Created By       :Jitan Goyal 
 * Created On       :07-31-2019
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Jitan Goyal          07-31-2019     BC-74102       Created the class   
 *
 */
@isTest
public class EC_CreateCacheTreeBatchTest {
   /***************************************************************************************************************************************
  Method Name : createdata
  Description : sets the test data
  Return type : void
 *************************************************************************************************************************************/
    public static void createdata(){
        ccrz__E_Product__c pro = new ccrz__E_Product__c(
            Name                       = 'product 601',
            ccrz__SKU__c               = '9782721',
            ccrz__ProductId__c         = '978273',
            ccrz__ProductStatus__c     = 'Released',
            ccrz__UnitOfMeasure__c     = 'BG',
            ccrz__StartDate__c         = Date.today().addDays(-7),
            ccrz__EndDate__c           = Date.today().addDays(7),
            ccrz__Storefront__c        = EC_TestData.STOREFRONT_NAME,
            ccrz__ProductWeight__c     = 500,
            ccrz__HazardousFlag__c     = false,
            ccrz__ShortDesc__c       ='SIEMENS 6012',
            ccrz__LongDesc__c       ='SIEMENS 6012345',
            ccrz__ProductIndexStatus__c = Label.EC_ProductIndexCurrent 
        );
        insert pro;
        
        // all root
        ccrz__E_Category__c testAllRoot = new ccrz__E_Category__c(
            Name                = 'Products',
            ccrz__CategoryID__c = '0',
            ccrz__StartDate__c  = Date.today().addDays(-3),
            ccrz__EndDate__c    = Date.today().addDays(3)
        );
        insert testAllRoot;
        
        ccrz__E_Category__c storefrontRoot = new ccrz__E_Category__c(
            Name                    = EC_TestData.STOREFRONT_CATEGORY_ROOT,
            ccrz__CategoryID__c     = EC_TestData.STOREFRONT_CATEGORY_ROOT_EXT_ID,
            ccrz__StartDate__c      = Date.today().addDays(-1),
            ccrz__EndDate__c        = Date.today().addDays(1),
            ccrz__ParentCategory__c = testAllRoot.Id
        );
        insert storefrontRoot;
        
        ccrz__E_ProductCategory__c product001subbrand1 = new ccrz__E_ProductCategory__c(
            ccrz__Product__c  = pro.Id,
            ccrz__Category__c = storefrontRoot.Id
        );
        insert product001subbrand1; 
        
        ccrz__E_AccountGroup__c acGrp = EC_TestData.testAccountGroup;
        
        ccrz__E_PriceList__c priceLists = new ccrz__E_PriceList__c(
            Name                     = 'PL002',
            ccrz__CurrencyISOCode__c = 'USD',
            ccrz__Enabled__c         = true,
            ccrz__Storefront__c      = EC_TestData.STOREFRONT_NAME,
            ccrz__StartDate__c       = Date.today().addDays(-7),
            ccrz__EndDate__c         = Date.today().addDays(7),
            //  ccrz__Seller__c          = sellers[0].Id,
            ccrz__PricelistId__c  = '250287-SIEMENS'
            
        );
        insert priceLists;
        
        ccrz__E_AccountGroupPriceList__c accGrppricelist = new ccrz__E_AccountGroupPriceList__c(
            ccrz__AccountGroup__c = acGrp.Id,
            ccrz__PriceList__c    = priceLists.Id,
            ccrz__Enable__c       = true
        );
        insert accGrppricelist;
        
        ccrz__E_PriceListItem__c pitem =  new ccrz__E_PriceListItem__c(
            ccrz__Pricelist__c = priceLists.Id,
            ccrz__Product__c   = pro.Id,
            ccrz__StartDate__c = Date.today().addDays(-7),
            ccrz__EndDate__c   = Date.today().addDays(7),
            ccrz__Price__c     = EC_TestData.DEFAULT_PRICE
        );
        insert pitem;
        
    }
    
   /***************************************************************************************************************************************
  Method Name : createCacheFromBatch
  Description : Test method to cover process method
  Return type : void
 *************************************************************************************************************************************/
    public static testMethod void createCacheFromBatch(){
        Map<String,Object> inData = new Map<String,Object>();
        Map<String,String> queryParamIn = new Map<String,String>();
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            //createdata();
            String curr = 'USD';
			String loc = 'en_US';
            String front = EC_TestData.STOREFRONT_NAME;
            
            List<ccrz__E_AccountGroup__c> accountGroup = [Select ID FROM ccrz__E_AccountGroup__c];
            Account acc = EC_TestData.testAccount;
            acc.ccrz__E_AccountGroup__c = accountGroup[0].id;
            update acc; 
               
            System.debug('accountGroup'+accountGroup);
            ccrz.cc_CallContext.storefront = EC_TestData.STOREFRONT_NAME;
            ccrz.cc_CallContext.userLocale = 'en_US';
            ccrz.cc_CallContext.effAccountId = acc.id;
           // ccrz.cc_CallContext.currAccountGroup = accountGroup[0].id;
            
            /**Test Start Here**/
            Test.startTest();
            EC_CreatePriceListCategoryMappingBatch allowedCatJob=new EC_CreatePriceListCategoryMappingBatch(EC_TestData.STOREFRONT_NAME,curr,loc);
            Database.executebatch(allowedCatJob,5);
            Test.stopTest();
            /**Test Stop Here**/
            
            EC_GetTreeByAcountGroupFromCache cacheObj = new EC_GetTreeByAcountGroupFromCache();
            inData.put(ccrz.ccApiCategory.CATEGORYTREE,'');
            Map<String,Object> outData = cacheObj.process(inData);
            
            /*Assert Check Here*/
            System.assertNotEquals(null, outData);
        }
    }
    
   /***************************************************************************************************************************************
  Method Name : withExistingPricelist
  Description : Test method to cover process method
  Return type : void
 *************************************************************************************************************************************/
    public static testMethod void withExistingPricelist(){
        Map<String,Object> inData = new Map<String,Object>();
        Map<String,String> queryParamIn = new Map<String,String>();
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            //createdata();
            String curr = 'USD';
			String loc = 'en_US';
            String front = EC_TestData.STOREFRONT_NAME;
            
            List<ccrz__E_AccountGroup__c> accountGroup = [Select ID FROM ccrz__E_AccountGroup__c];
              List<Account> accList = [SELECT ID FROM Account];
            Account acc = EC_TestData.testAccount;
            acc.ccrz__E_AccountGroup__c = accountGroup[0].id;
            update acc; 
            System.debug('accountGroup'+accountGroup);
            ccrz.cc_CallContext.storefront = EC_TestData.STOREFRONT_NAME;
            ccrz.cc_CallContext.userLocale = 'en_US';
           // ccrz.cc_CallContext.currAccountGroup = accountGroup[0];
 			  ccrz.cc_CallContext.effAccountId = acc.id;
            /**Test Start Here**/
            Test.startTest();
            EC_CreatePriceListCategoryMappingBatch allowedCatJob=new EC_CreatePriceListCategoryMappingBatch(EC_TestData.STOREFRONT_NAME,curr,loc);
            Database.executebatch(allowedCatJob,5);
           
            Test.stopTest();
            /**Test Stop Here**/
            EC_CreatePriceListCategoryMappingBatch allowedCatJob2=new EC_CreatePriceListCategoryMappingBatch(EC_TestData.STOREFRONT_NAME,curr,loc);
            Database.executebatch(allowedCatJob2,5);
            EC_GetTreeByAcountGroupFromCache cacheObj = new EC_GetTreeByAcountGroupFromCache();
            inData.put(ccrz.ccApiCategory.CATEGORYTREE,'');
            Map<String,Object> outData = cacheObj.process(inData);
            
            /*Assert Check Here*/
            System.assertNotEquals(null, outData);
        }
    }
    
    /***************************************************************************************************************************************
  Method Name : withoutAnyCacheFromBatch
  Description : Test method to cover process
  Return type : void
 *************************************************************************************************************************************/
    public static testMethod void withoutAnyCacheFromBatch(){
        Map<String,Object> inData = new Map<String,Object>();
        Map<String,String> queryParamIn = new Map<String,String>();
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            
            List<String> curr= new List<String>();
            curr.add('USD');
            List<String> loc= new List<String>();
            String front = EC_TestData.STOREFRONT_NAME;
            loc.add('en_US');
            
            List<ccrz__E_AccountGroup__c> accountGroup = [Select ID FROM ccrz__E_AccountGroup__c];
            Account acc = EC_TestData.testAccount;
            acc.ccrz__E_AccountGroup__c = accountGroup[0].id;
            update acc; 
            ccrz.cc_CallContext.storefront = EC_TestData.STOREFRONT_NAME;
            ccrz.cc_CallContext.userLocale = 'en_US';
           // ccrz.cc_CallContext.currAccountGroup = accountGroup[1];
               ccrz.cc_CallContext.effAccountId = acc.id;
            /**Test Start Here**/
            Test.startTest();
            
            EC_GetTreeByAcountGroupFromCache cacheObj = new EC_GetTreeByAcountGroupFromCache();
            inData.put(ccrz.ccApiCategory.CATEGORYTREE,'');
            Map<String,Object> outData = cacheObj.process(inData);
            
            Test.stopTest();
            /**Test Stop Here**/
 
            /*Assert Check Here*/
            System.assertEquals(null, outData);
        }
    }
}