/********************************************************************************************************
* @Class Name    EC_InactivePriceListTest 
* @description   EC_InactivePriceListTest is used to test the functionality of EC_InactivePriceList
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
public class EC_InactivePriceListTest {
    @isTest
    public static void InactivePriceList(){
        Datetime dt= system.now();
        EC_InactivePriceList ecp= new EC_InactivePriceList(dt);
        Database.BatchableContext dbc ;
        ecp.start(dbc);
        EC_TestData.setupCatalog();
        ccrz__E_AccountGroup__c accGroup = EC_TestData.testAccountGroup;
        List<ccrz__E_PriceList__c> scope= new List<ccrz__E_PriceList__c>();
        scope=[SELECT ccrz__PricelistId__c,ccrz__Enabled__c,ccrz__EndDate__c,EC_Price_List_Type__c,ccrz__Seller__c   from ccrz__E_PriceList__c];
        //scope[0].ccrz__Enabled__c=false;
        system.debug('scope==='+scope);
        update scope;
        ccrz__E_AccountGroupPriceList__c testAccountGroupPriceList = new ccrz__E_AccountGroupPriceList__c();
        testAccountGroupPriceList.ccrz__AccountGroup__c = accGroup.Id;
        testAccountGroupPriceList.EC_Price_List_Type__c = 'Z1MP';
        testAccountGroupPriceList.ccrz__PriceList__c    = scope[0].Id;
        testAccountGroupPriceList.ccrz__Enable__c       = true;
        insert testAccountGroupPriceList;      
        EC_ProductIndexBatchStatus__c indexBatch = new EC_ProductIndexBatchStatus__c();
        indexBatch.EC_InActive_PriceListItem_Batch__c = true;
        indexBatch.EC_Category_Batch_Schedule_Interval__c = 15;
        indexBatch.EC_Product_Index_Interval__c = 5;
        insert indexBatch;
        ecp.execute(dbc,scope);
        ecp.finish(dbc);
        system.assertNotEquals(ecp.start(dbc), null);
        
    }

 

}