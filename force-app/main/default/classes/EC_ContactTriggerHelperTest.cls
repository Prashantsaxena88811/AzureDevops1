/* Class Name       :EC_ContactTriggerHelperTest
* Description      :Test class for EC_ContactTrigger
* Created By       :Shridevi Kamble
* Created On       :07-30-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
*Shridevi Kamble          07-30-2019                                   Test class for EC_ContactTrigger
* 
*/

@isTest
Public class EC_ContactTriggerHelperTest {
    
    /***************************************************************************************************************************************
Method Name : sendWelcomeEmailTest
Description : Covers the code for 'sendWelcomeEmail' method of EC_ContactTrigger
Author      : Shridevi Kamble
*************************************************************************************************************************************/
    private static testmethod void sendWelcomeEmailTest() {     
        
        Test.startTest();
        Insert new et4ae5__Configuration__c(et4ae5__Support_Ticket_Recipient__c = 'example@example.com');
        Contact c = new Contact(LastName='TestExample');
        insert c;
        
        // If no exceptions occurred, it was successful 
        c.email='Test@test.com';
        Update c;
        System.assert(!String.isBlank(c.Id));
        Test.stopTest();
        
    }// End of method sendWelcomeEmailTest 
    
}//End of class EC_ContactTriggerHelperTest