/********************************************************************************************************
* @Class Name    EC_InactivePriceListItemBatchTest 
* @description   EC_InactivePriceListItemBatchTest is used to test the functionality of EC_InactivePriceListItemBatch
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
public class EC_InactivePriceListItemBatchTest {
    @isTest
    public static void InactivePriceListItem(){
        Datetime dt= system.now();
        EC_InactivePriceListItemBatch ecpi= new EC_InactivePriceListItemBatch(dt);
        Database.BatchableContext dbc ;
        ecpi.start(dbc);
        EC_TestData.setupCatalog();
        ccrz__E_AccountGroup__c accGroup = EC_TestData.testAccountGroup;
        List<ccrz__E_PriceListItem__c> scope= new List<ccrz__E_PriceListItem__c>();
        scope=[SELECT ccrz__Price__c,ccrz__Pricelist__c,ccrz__PricelistItemId__c,ccrz__EndDate__c from ccrz__E_PriceListItem__c];
        scope[0].ccrz__EndDate__c = System.today()-1;
        system.debug('scope==='+scope);
        update scope;
        ccrz__E_AccountGroupPriceList__c testAccountGroupPriceList = new ccrz__E_AccountGroupPriceList__c();
                testAccountGroupPriceList.ccrz__AccountGroup__c = accGroup.Id;
                testAccountGroupPriceList.EC_Price_List_Type__c = 'Z1MP';
                testAccountGroupPriceList.ccrz__PriceList__c    = scope[0].ccrz__Pricelist__c;
                testAccountGroupPriceList.ccrz__Enable__c       = true;
        insert testAccountGroupPriceList;     
        EC_ProductIndexBatchStatus__c indexBatch = new EC_ProductIndexBatchStatus__c();
        indexBatch.EC_InActive_PriceListItem_Batch__c = true;
        indexBatch.EC_Category_Batch_Schedule_Interval__c = 15;
        indexBatch.EC_Product_Index_Interval__c = 5;
        insert indexBatch;
        ecpi.execute(dbc,scope);
        ecpi.finish(dbc);
        system.assertNotEquals(ecpi.start(dbc), null);
       
    }
}