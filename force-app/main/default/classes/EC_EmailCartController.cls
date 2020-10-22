/* Class Name      :EC_EmailCartController
* Description      :RemoteAction controller for Email Cart
* Created By       :Rajkishor
* Created On       :29-08-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------------------------
* Developer                     Date                                        Description
* ----------------------------------------------------------------------------------------------------------------------------------
* Rajkishor                         29-08-2019                                Base code added.
*/  
global without sharing class EC_EmailCartController {
    
    /***************************************************************************************************************************************
      Method Name : sendMailCart
      Description : sendMail Remote call to send a mail to emailTo address with conditions
                      a) Search the user based on emailToAddress 
                      b) Check the user is tagged to the same effective account 
      Return type : cc_RemoteActionResult 
     **************************************************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult sendMailCart(final ccrz.cc_RemoteActionContext ctx,String emailToAddress, String emailCcAddress, String subject, String description){
        ccrz.cc_CallContext.initRemoteContext(ctx);
        String effAccount = ccrz.cc_CallContext.effAccountId; 
        String currEncrptCartId =ccrz.cc_CallContext.currCartId ;
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();       
        List<Contact> listContact = [SELECT Id, EC_SalesRep_User__c   FROM Contact WHERE email = :emailToAddress and Id in (Select ContactId from User) and Id in (Select ContactId from AccountContactRelation where AccountId = :effAccount)];
        if(listContact.isEmpty()){
            List<Contact> listExtrnContact = [SELECT Id, EC_SalesRep_User__c   FROM Contact WHERE email = :emailToAddress and   EC_SalesRep_User__c != null and Id in (Select ContactId from AccountContactRelation where AccountId = :effAccount)];
            if(listExtrnContact.isEmpty()){
                res.data= Label.EC_EmailUser;
                res.success = false;
            }else{ 
                String userId = listExtrnContact[0].EC_SalesRep_User__c;
                Map<String,String> cloneCartResultMap = cloneCart(currEncrptCartId,userId, listExtrnContact[0].Id,description,subject);
                String cartUrl = cloneCartResultMap.get('cartURL');
                ccrz__E_Cart__c cart = [Select Id from ccrz__E_Cart__c Where ccrz__EncryptedId__c=:currEncrptCartId];
                //sendEmail(emailToAddress, emailCcAddress, subject, description,cartUrl);
                
                 sendEmailTemplate(emailToAddress, emailCcAddress, subject, description,cartUrl,'Email Cart',listExtrnContact[0].Id,cloneCartResultMap.get('clonedCartId'));
                updateCartOwner(cloneCartResultMap.get('newEncrptCartId'),userId, listExtrnContact[0].Id);
                res.data=cartUrl;
                res.success = true;
            }
        }else{    
            User user = [Select Id from User where contactId = :listContact[0].Id];
            Map<String,String> cloneCartResultMap = cloneCart(currEncrptCartId,user.Id,listContact[0].Id,description,subject);
            String cartUrl = cloneCartResultMap.get('cartURL');
            ccrz__E_Cart__c cart = [Select Id from ccrz__E_Cart__c Where ccrz__EncryptedId__c=:currEncrptCartId];
            //sendEmail(emailToAddress, emailCcAddress, subject, description,cartUrl);
            
            sendEmailTemplate(emailToAddress, emailCcAddress, subject, description,cartUrl,'Email Cart',listContact[0].Id,cloneCartResultMap.get('clonedCartId'));
            updateCartOwner(cloneCartResultMap.get('newEncrptCartId'),user.Id,listContact[0].Id);
            res.data=cartUrl;
            res.success = true;
            
        }         
        
        return res;
    }
    
    /***************************************************************************************************************************************
      Method Name : sendMail
      Description : sendMail Remote call to send a mail to emailTo address 
      Return type : void 
     **************************************************************************************************************************************/
     
    
    public static void sendEmail(String emailToAddress,String emailCcAddress, String subject, String description,String cartUrl) {          
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { emailToAddress };
        if(emailCcAddress != null && emailCcAddress.length() > 0) {
            message.ccAddresses= new String[] { emailCcAddress };
        }
        message.optOutPolicy = 'FILTER'; // SEND
        message.subject = subject;
        message.plainTextBody = description +'      Here is the cart link : '+cartUrl;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
    /***************************************************************************************************************************************
      Method Name : sendEmailTemplate
      Description : sendEmailTemplate Remote call to send a mail to emailTo address 
      Return type : void 
     **************************************************************************************************************************************/
    
    public static void sendEmailTemplate(String emailToAddress, String emailCCAddress, String subject, String description, String cartUrl, String templateName, String targetContactId, String cartId){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { emailToAddress };
            if(emailCcAddress != null && emailCcAddress.length() > 0){
                message.ccAddresses= new String[] { emailCcAddress };
            }
        message.optOutPolicy = 'FILTER'; // SEND
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.setTargetObjectId(targetContactId); 
        /*
        message.setSenderDisplayName('Company Support'); 
        message.setReplyTo(‘no-reply@company.com’);
        */
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =:templateName Limit 1];
        message.setTemplateID(emailTemplate.Id); 
        message.setWhatId(cartId);
        system.debug(message);
       
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
    }
    
    /***************************************************************************************************************************************
      Method Name : cloneCart
      Description : This method clones the cart and generates a URL for cloned cart  
      Return type : String
     **************************************************************************************************************************************/
    public static Map<String,String> cloneCart(String encrptCartId, String userId, String contactId, String userComments,String subject){
        Map<String,String> resultMap = new Map<String,String>();
        String cartURL =URL.getSalesforceBaseUrl().toExternalForm() + '/' ;
        Savepoint sp = Database.setSavepoint();
        Boolean wasSuccessful = false;
        
        try{            
            Map<String, Object> inputData = new Map<String,Object>{
                ccrz.ccApiCart.CART_ENCID => encrptCartId,
                    ccrz.ccApi.API_VERSION => 9
                    };                        
             Map<String, Object> outputData = ccrz.ccAPICart.cloneCart(inputData);
                                      
            wasSuccessful = (Boolean)outputData.get(ccrz.ccApi.SUCCESS);            
            if(wasSuccessful){
                String newEncrptCartId =(String)outputData.get(ccrz.ccApiCart.CART_ENCID);
                String clonedCartId = (String)outputData.get(ccrz.ccApiCart.CART_ID);
               //pricing 
                Map<String, Object> input = new Map<String,Object>{
                ccrz.ccApiCart.CART_ENCID => newEncrptCartId,
                    ccrz.ccApi.API_VERSION => 9
                    };  
                
                ccrz.ccAPICart.price(input);
                 //end pricing
                ccrz__E_Cart__c clCart = [SELECT Id,OwnerId,ccrz__Contact__c,ccrz__User__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :newEncrptCartId];

                clCart.EC_User_Comments__c = userComments;
                clCart.EC_Cart_Email_Subject__c = subject;
                update clCart;                
                cartURL = '<a href="' + EC_Utility.getPageUrl() + '/'+Label.EC_Storefront_Name+'/ccrz__Cart?cartId=' + newEncrptCartId + '&effectiveAccount='+ccrz.cc_CallContext.effAccountId+'">' + clonedCartId + '</a>';
                resultMap.put('cartURL',cartURL);
                resultMap.put('newEncrptCartId',newEncrptCartId);
                resultMap.put('clonedCartId',clonedCartId);
                               
            }           
            
        }catch(Exception e){
            System.debug(e);
        }
        return resultMap;        
    }
    
        /***************************************************************************************************************************************
      Method Name : updateCartOwner
      Description : This method updates the owner for the given cart
      Return type : void
     **************************************************************************************************************************************/
   
    public static void updateCartOwner(String encrptCartId, String userId, String contactId){
        
        ccrz__E_Cart__c clCart = [SELECT Id,OwnerId,ccrz__Contact__c,ccrz__User__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :encrptCartId];
        clCart.OwnerId = userId;
        clCart.ccrz__User__c= userId;
        clCart.ccrz__Contact__c = contactId;
        update clCart;
    
    }
}