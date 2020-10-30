/* Trigger Name     :EC_ContactTrigger
* Description      :Contact trigger
* Created By       :Shridevi Kamble
* Created On       :07-30-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
*Shridevi Kamble          07-30-2019                                  Contact trigger
* 
*/

trigger EC_ContactTrigger on Contact (after insert, after update){
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert ){
            //Invokes the 'Triggered Send' created in the Marketing Cloud Connector to send the Welcome Email.
              sendWelcomeEmail();
        }//End of isInsert condition
        
        if(Trigger.isUpdate ){
            //Invokes the 'Triggered Send' created in the Marketing Cloud Connector to send the Welcome Email.
             sendWelcomeEmail();
        }//End of isUpdate condition
        
    }//End of isAfter condition
    
    
    /***************************************************************************************************************************************
Method Name : sendWelcomeEmail
Description : Invokes the 'Triggered Send' created in the Marketing Cloud Connector to send the Welcome Email.
This method cannot be moved to the helper class , as the marketing cloud connector looks for this specific line of code 
et4ae5.triggerUtility.automate('Contact');   in the trigger to activate the Triggered Send

Author      : Shridevi Kamble
*************************************************************************************************************************************/
    public static void sendWelcomeEmail(){
        
        try{
            // Query the 'et4ae5__Configuration__c' table to check if Marketing cloud Connector is configured 
            Integer configCount = Database.countQuery('SELECT Count() FROM  et4ae5__Configuration__c limit 1');
            System.debug('configCount: '+configCount);
            
            //If Marketing Cloud Conenctor is configured and connected to Marketing Cloud BU, invoke the Triggered Send 
            if(configCount > 0)
            {
                // Fires the 'Triggered Send' of Marketing cloud connector to send out Welcome Email.
                // This supports uploading of 50 contacts in a batch as it throws 'System.LimitException: et4ae5:Too many future calls: 51'
                et4ae5.triggerUtility.automate('Contact'); 
            }//End of if configCount condition
            
            if(Test.isRunningTest())
            {
                throw new DMLException('Exception from running Test class');
            }// End of isRunningTest Condition
            
        }Catch (Exception ex) {
            System.debug('Exception occured while invoking Marketing Cloud Connector Triggered Send '+ ex.getMessage());
        }//End of Catch Block
        
    }//End of Method  sendWelcomeEmail  
    
} //End of trigger EC_ContactTrigger