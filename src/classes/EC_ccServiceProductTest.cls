/* Class Name    : EC_ccServiceProductTest 
 * Description      Test Class to cover EC_ccServiceProduct
 * Created By       :Viraj
 * Created On       :2019-Oct-21
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                2019-Oct-21      BC-91590        Created the class   
 *
 */
@isTest
public class EC_ccServiceProductTest {
    private static final String productList = 'productList';
    static testMethod void test_getFieldsMap(){
        
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE id = :EC_TestData.testUser.id LIMIT 1];
        system.runas(thisUser){

            EC_TestData.setupCatalog();
            List<ccrz__E_Cart__c> quicklists = EC_TestData.createQuickLists(1);
            
            List<ccrz__E_Cart__c> cartwishlist = [Select Name,OwnerId,EC_PurchasedWishlist__c, (Select Id,ccrz__Product__c,EC_Last_Purchased_Date__c,EC_LastPurchasedDateFormatted__c from ccrz__E_CartItems__r) from ccrz__E_Cart__c Where OwnerId = :thisUser.id AND ccrz__CartType__c='WishList' AND EC_PurchasedWishlist__c = TRUE Limit 1]; 
            
            List<Map<String,Object>> prodList = new List<Map<String,Object>>();
            Map<String,Object> prodMap = new Map<String,Object>();
            
            //Account shipTo = EC_TestData.testAccountShipTo;
            Account shipTo = [Select EC_SalesOrg__c from Account Where Id=:EC_TestData.testAccountShipTo.id];
            shipTo.EC_SalesOrg__c = '1001';
            update shipTo;
            ccrz.cc_CallContext.effAccountId = shipTo.id;
			
            List<ccrz__E_Product__c> prods = [Select Id from ccrz__E_Product__c  Limit 2];
			List<String> ProdIds = new List<String>();
            for(ccrz__E_Product__c prod: Prods) {
                ProdIds.add(prod.Id);
            }
            Chemical_Product_Type__c packTypeCS = new Chemical_Product_Type__c();
            packTypeCS.Active__c = true;
            packTypeCS.Package_Code__c = '91';
            packTypeCS.Name = '91';
            insert packTypeCS;
            prodMap = getProdMap(cartwishlist, shipTo); 
            prodList.add(prodMap);
            Map<String,Object> inputData = new Map<String,Object>();
            inputData.put(productList, prodList);
            Map<String,Object> inputData1 = new Map<String,Object>();
            inputData1.put('E_ProductMedias__r',prodList);
            
            Tank_Detail__c tankDetail = new Tank_Detail__c();
            tankDetail.Active__c = true;
            tankDetail.Tank_Id__c = System.Label.DropOff;
            tankDetail.Account__c = shipTo.Id;
            tankDetail.Tank_Number__c = '1223';
            tankDetail.Delivery_Priority__c = '7';
            tankDetail.Material_Description__c = 'ST70';
            tankDetail.Delivery_Template_Code__c = '91';
            insert tankDetail;
                        
            EC_ccServiceProduct extend= new EC_ccServiceProduct();
            CCRZ.cc_CallContext.currPageName =  'ccrz__Cart';
            
            List<Delivery_Template_Package_Code_Mapping__mdt> Dtemplates = Database.query('SELECT Delivery_Template_Code__c,DeveloperName,Package_Code__c,QualifiedApiName,Sales_Org__c FROM Delivery_Template_Package_Code_Mapping__mdt');
            system.debug(Dtemplates);
            
            Map<String, Object> res=extend.fetch(inputData);
            Map<String, Object> SubQueryMap = extend.getSubQueryMap(inputData1);
            system.debug('SubQueryMap' + SubQueryMap);
            //EC_ccServiceProduct.showHideAddtoCart(prodIds, shipTo.id, 'PLUS10.91', 'Chemistry');
            
            System.assert(null != res);
            
        }        
    }

    static testMethod void getFieldsMapMethod()
    {
        EC_ccServiceProduct var=new EC_ccServiceProduct();
        Test.startTest();
        Map<String, Object> testData=new Map<String, Object>();
        var.getFieldsMap(testData);
        system.assertEquals(0, testData.size());
        Test.stopTest();
    } 

    /***************************************************************************************************************************************
    Method Name : test_getFieldsMapISEDirect
    Description : Test method for Inst Sales Entitlement Direct Account   
    Return type : NA
	*************************************************************************************************************************************/  
    static testMethod void test_getFieldsMapISEDirect(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE id = :EC_TestData.testUser.id LIMIT 1];
        EC_ISETestDataFactory.setupInstSalesEntitlements();
        Account acc = EC_ISETestDataFactory.testAccount_ISEDirect;
        
        EC_TestData.setupCatalog();
        List<ccrz__E_Cart__c> quicklists = EC_ISETestDataFactory.createQuickListsforISEDirect(1);
        System.debug('quicklists' + quicklists);     
        List<ccrz__E_Cart__c> cartwishlist = [Select Name,OwnerId,EC_PurchasedWishlist__c, 
                                              (Select Id,ccrz__Product__c,EC_Last_Purchased_Date__c,
                                               EC_LastPurchasedDateFormatted__c from ccrz__E_CartItems__r) 
                                              from ccrz__E_Cart__c Where OwnerId = :thisUser.id 
                                              AND ccrz__CartType__c='WishList' AND EC_PurchasedWishlist__c = TRUE 
                                              Limit 1]; 
        
        ccrz.cc_CallContext.effAccountId = acc.Id; 
        system.debug('@test_getFieldsMapISE->effAccountId:' + acc.Id);
        List<Map<String,Object>> prodList = new List<Map<String,Object>>();
        Map<String,Object> productMap = new Map<String,Object>();
        productMap = getProdMap(cartwishlist, acc); 
        prodList.add(productMap);
        
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put(productList, prodList);
        
        Test.startTest();
        EC_ccServiceProduct extend= new EC_ccServiceProduct();
        Map<String, Object> result = extend.fetch(inputData);          
        System.assert(!result.isEmpty());
        Test.stopTest();
        
    }
     /***************************************************************************************************************************************
    Method Name : test_getFieldsMapISEIndirect
    Description : Test method for Inst Sales Entitlement InDirect Account   
    Return type : NA
	*************************************************************************************************************************************/  
   
    static testMethod void test_getFieldsMapISEIndirect(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE id = :EC_TestData.testUser.id LIMIT 1];
        EC_ISETestDataFactory.setupInstSalesEntitlements();
        Account acc = EC_ISETestDataFactory.testAccount_ISEIndirect;
        
        EC_TestData.setupCatalog();
        List<ccrz__E_Cart__c> quicklists = EC_ISETestDataFactory.createQuickListsforISEIndirect(1);
         System.debug('quicklists' + quicklists);     
        List<ccrz__E_Cart__c> cartwishlist = [Select Name,OwnerId,EC_PurchasedWishlist__c, 
                                              (Select Id,ccrz__Product__c,EC_Last_Purchased_Date__c,
                                               EC_LastPurchasedDateFormatted__c from ccrz__E_CartItems__r) 
                                              from ccrz__E_Cart__c Where OwnerId = :thisUser.id 
                                              AND ccrz__CartType__c='WishList' AND EC_PurchasedWishlist__c = TRUE 
                                              Limit 1]; 
        
        ccrz.cc_CallContext.effAccountId = acc.Id; 
        system.debug('@test_getFieldsMapISE->effAccountId:' + acc.Id);
        List<Map<String,Object>> prodList = new List<Map<String,Object>>();
        Map<String,Object> productMap = new Map<String,Object>();
        productMap = getProdMap(cartwishlist, acc); 
        prodList.add(productMap);
        
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put(productList, prodList);
        
        Test.startTest();
        EC_ccServiceProduct extend= new EC_ccServiceProduct();
        Map<String, Object> result = extend.fetch(inputData);          
        System.assert(!result.isEmpty());
        Test.stopTest();
        
    }
    static testMethod void test_getFieldsMapIStreetBrand(){
        EC_TestData.setupTestUser();
        User thisUser = [SELECT Id FROM User WHERE id = :EC_TestData.testUser.id LIMIT 1];
        EC_ISETestDataFactory.setupInstSalesEntitlements();
        Account acc = EC_ISETestDataFactory.testAccount_IStreetBrand;
        
        EC_TestData.setupCatalog();
        List<ccrz__E_Cart__c> quicklists = EC_ISETestDataFactory.createQuickListsforIStreetBrand(1);
        System.debug('quicklists' + quicklists);    
        List<ccrz__E_Cart__c> cartwishlist = [Select Name,OwnerId,EC_PurchasedWishlist__c, 
                                              (Select Id,ccrz__Product__c,EC_Last_Purchased_Date__c,
                                               EC_LastPurchasedDateFormatted__c from ccrz__E_CartItems__r) 
                                              from ccrz__E_Cart__c Where OwnerId = :thisUser.id 
                                              AND ccrz__CartType__c='WishList' AND EC_PurchasedWishlist__c = TRUE 
                                              Limit 1]; 
        
        ccrz.cc_CallContext.effAccountId = acc.Id; 
        system.debug('@test_getFieldsMapISE->effAccountId:' + acc.Id);
        List<Map<String,Object>> prodList = new List<Map<String,Object>>();
        Map<String,Object> productMap = new Map<String,Object>();
        productMap = getProdMap(cartwishlist, acc); 
        prodList.add(productMap);
        
        Map<String,Object> inputData = new Map<String,Object>();
        inputData.put(productList, prodList);
        
        Test.startTest();
        EC_ccServiceProduct extend= new EC_ccServiceProduct();
        Map<String, Object> result = extend.fetch(inputData);          
        System.assert(!result.isEmpty());
        Test.stopTest();
        
    }

    private static Map<String,Object> getProdMap(List<ccrz__E_Cart__c> cartwishlist, Account acc){
        Map<String,Object> productMap = new Map<String,Object>();
        
        productMap.put('sfid',cartwishlist[0].ccrz__E_CartItems__r[0].ccrz__Product__c);
        productMap.put('packageCode','91');
        productMap.put('materialDescription','ST70');
        productMap.put('effAccountId', acc.Id);
        productMap.put('taxonomy', 'Chemical');
        
        return productMap;
    }

}