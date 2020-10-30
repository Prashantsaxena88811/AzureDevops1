/********************************************************************************************************
* @Class Name    EC_InactiveAccountGroupPriceListTest 
* @description   EC_InactiveAccountGroupPriceListTest is used to test the functionality of EC_InactiveAccountGroupPriceList
* @Created By -  Ravindra Singh  
* @Created On -  2019-09-10
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-09-10                                   Initial version
 *********************************************************************************************************/ 
@isTest
public class EC_InactiveAccountGroupPriceListTest {
    @isTest
    public static void InactiveAccountGroupPriceList(){
        Datetime dt= system.now();
        
       
        EC_TestData.setupCatalog();
        ccrz__E_AccountGroup__c accGroup = EC_TestData.testAccountGroup;
        List<ccrz__E_AccountGroupPriceList__c> scope= new List<ccrz__E_AccountGroupPriceList__c>();
        scope=[SELECT ccrz__Enable__c,ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c];
        system.debug('scope==='+scope);
        ccrz__E_AccountGroupPriceList__c testAccountGroupPriceList = new ccrz__E_AccountGroupPriceList__c();
                testAccountGroupPriceList.ccrz__AccountGroup__c = accGroup.Id;
                testAccountGroupPriceList.EC_Price_List_Type__c = 'Z1MP';
                testAccountGroupPriceList.ccrz__PriceList__c    = scope[0].ccrz__Pricelist__c;
                testAccountGroupPriceList.ccrz__Enable__c       = true;
        
        insert testAccountGroupPriceList; 
        
        ccrz__E_AccountGroup__c AnonymousACCGrp = new ccrz__E_AccountGroup__c();
        AnonymousACCGrp.Name ='Anonymous';
        AnonymousACCGrp.ccrz__AccountGroupID__c = 'ANONYMOUS';
        insert AnonymousACCGrp;
        
        ccrz__E_Pricelist__c pl = new ccrz__E_Pricelist__c(                
            	Name                     = 'Enterprise',
                ccrz__CurrencyISOCode__c = 'USD',
                ccrz__Enabled__c         = true,
                ccrz__Storefront__c      = EC_TestData.STOREFRONT_NAME,
                ccrz__StartDate__c       = Date.today().addDays(-7),
                ccrz__EndDate__c         = Date.today().addDays(7),
                ccrz__PricelistId__c     = 'ENTERPRISE-USD');
        
        insert pl;
        
        ccrz__E_AccountGroupPriceList__c newAccGrpPL = new ccrz__E_AccountGroupPriceList__c();
                newAccGrpPL.ccrz__AccountGroup__c = AnonymousACCGrp.Id;
                newAccGrpPL.ccrz__PriceList__c    = pl.id;
                newAccGrpPL.ccrz__Enable__c       = true;
        
        insert newAccGrpPL; 
        scope=[SELECT ccrz__Enable__c,ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c];
        EC_ProductIndexBatchStatus__c indexBatch = new EC_ProductIndexBatchStatus__c();
        indexBatch.EC_InActive_PriceListItem_Batch__c = true;
        indexBatch.EC_Category_Batch_Schedule_Interval__c = 15;
        indexBatch.EC_Product_Index_Interval__c = 5;
        insert indexBatch;        
        update scope;
        EC_InactiveAccountGroupPriceList ecpi= new EC_InactiveAccountGroupPriceList(dt);
        Database.BatchableContext dbc ;
        ecpi.start(dbc);
        
        ecpi.execute(dbc,scope);
        ecpi.finish(dbc);
        system.assertNotEquals(ecpi.start(dbc), null);
        
    }
}