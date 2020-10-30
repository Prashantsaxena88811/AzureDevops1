/********************************************************************************************************
* @Class Name    EC_InactiveProductMediaBatchTest 
* @description   EC_InactiveProductMediaBatchTest is used to test the functionality of EC_InactiveProductMediaBatch
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
public class EC_InactiveProductMediaBatchTest {

 /***************************************************************************************************************************************
      Method Name : InactiveProductMedia
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
      

    @isTest
    public static void InactiveProductMedia(){
        Datetime dt= system.now();
        EC_InactiveProductMediaBatch ecpi= new EC_InactiveProductMediaBatch(dt);
        Database.BatchableContext dbc ;
        ecpi.start(dbc);
        EC_TestData.setupCatalog();
        List<ccrz__E_ProductMedia__c> scope= new List<ccrz__E_ProductMedia__c>();
        scope=[SELECT ccrz__EndDate__c,ccrz__Enabled__c from ccrz__E_ProductMedia__c];
        system.debug('scope==='+scope);
        update scope;
        ecpi.execute(dbc,scope);
        ecpi.finish(dbc);
        system.assertNotEquals(ecpi.start(dbc), null);
    }
        
}