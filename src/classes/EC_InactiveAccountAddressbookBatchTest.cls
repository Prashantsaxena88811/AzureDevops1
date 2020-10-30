/********************************************************************************************************
* @Class Name    EC_InactiveAccountAddressbookBatchTest  
* @description   EC_InactiveAccountAddressbookBatchTest is used to test the functionality of EC_InactiveAccountAddressbookBatch
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
public class EC_InactiveAccountAddressbookBatchTest {

 /***************************************************************************************************************************************
      Method Name : InactiveAccountAddressbook
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
      
    @isTest
    public static void InactiveAccountAddressbook(){
        EC_TestData.setupCatalog();
        EC_TestData.setupTestUser();
        ccrz__E_AccountAddressBook__c book = new ccrz__E_AccountAddressBook__c();
        Account a = [Select id from Account limit 1];
        book.ccrz__Account__c = a.Id;
        book.ccrz__AddressBookId__c = 'bookId';
        book.ccrz__AddressType__c = 'Billing';
        insert book;
        
        Datetime dt= system.now();
        EC_InactiveAccountAddressbookBatch ecpi= new EC_InactiveAccountAddressbookBatch(dt);
        Database.BatchableContext dbc ;
        ecpi.start(dbc);      
        List<ccrz__E_AccountAddressBook__c> scope= new List<ccrz__E_AccountAddressBook__c>();
        scope=[SELECT ccrz__Account__c,ccrz__AddressBookId__c,ccrz__AddressType__c,ccrz__E_ContactAddress__c from ccrz__E_AccountAddressBook__c];
        
        ecpi.execute(dbc,scope);
        ecpi.finish(dbc);
        system.assertNotEquals(ecpi.start(dbc), null);
        
    }
}