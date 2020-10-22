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
			
            /*
            ccrz__E_Product__c prod = [Select Id,ccrz__SKU__c from ccrz__E_Product__c Where Id =:cartwishlist[0].ccrz__E_CartItems__r[0].ccrz__Product__c Limit 1];
            prod.ccrz__SKU__c = 'ST70.91';
            update prod;
			*/
            Chemical_Product_Type__c packTypeCS = new Chemical_Product_Type__c();
            packTypeCS.Active__c = true;
            packTypeCS.Package_Code__c = '91';
            packTypeCS.Name = '91';
            insert packTypeCS;
            prodMap.put('sfid',cartwishlist[0].ccrz__E_CartItems__r[0].ccrz__Product__c);
            prodMap.put('packageCode','91');
            prodMap.put('materialDescription','ST70');
            prodList.add(prodMap);
            Map<String,Object> inputData = new Map<String,Object>();
            inputData.put('productList', prodList);
            Map<String,Object> inputData1 = new Map<String,Object>();
            inputData1.put('E_ProductMedias__r',prodList);
            
            Tank_Detail__c tankDetail = new Tank_Detail__c();
            tankDetail.Active__c = true;
            tankDetail.Tank_Id__c = System.Label.DropOff;
            tankDetail.Account__c = shipTo.Id;
            tankDetail.Tank_Number__c = '1223';
            tankDetail.Delivery_Priority__c = '7';
            tankDetail.Material_Description__c = '123';
            tankDetail.Delivery_Template_Code__c = '.91';
            insert tankDetail;
                        
            EC_ccServiceProduct extend= new EC_ccServiceProduct();
            CCRZ.cc_CallContext.currPageName =  'ccrz__Cart';
            
            List<Delivery_Template_Package_Code_Mapping__mdt> Dtemplates = Database.query('SELECT Delivery_Template_Code__c,DeveloperName,Package_Code__c,QualifiedApiName,Sales_Org__c FROM Delivery_Template_Package_Code_Mapping__mdt');
            system.debug(Dtemplates);
            
            Map<String, Object> res=extend.fetch(inputData);
            Map<String, Object> SubQueryMap = extend.getSubQueryMap(inputData1);
            system.debug('SubQueryMap' + SubQueryMap);
  
            
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
}