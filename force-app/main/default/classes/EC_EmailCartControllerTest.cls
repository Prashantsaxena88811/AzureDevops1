/* Class Name      :EC_EmailCartControllerTest
* Description      :Test class for EC_EmailCartController
* Created By       :Ravindra Singh
* Created On       :29-08-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------------------------
* Developer                     Date                                        Description
* ----------------------------------------------------------------------------------------------------------------------------------
* Ravindra                    29-08-2019                                Base code added.
*/

@isTest
public class EC_EmailCartControllerTest {

/***************************************************************************************************************************************
      Method Name : sendMailCartTest
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
      
    
    @isTest
    private static void sendMailCartTest(){
        
        EC_TestData.setupTestUser();
         User thisUser = [SELECT Id,ContactId FROM User WHERE LastName = 'TestUser'];
        EC_TestData.setupCatalog();
        List<ccrz__E_Cart__c> carts = EC_TestData.createCarts(1);
        
        ccrz__E_Product__c proditem = [SELECT id, ccrz__sku__c FROM ccrz__E_Product__c  LIMIT 1  ];
        
       ccrz__E_ProductMedia__c media =  new ccrz__E_ProductMedia__c(
                            ccrz__Product__c            = proditem.Id,                        
                            ccrz__ProductMediaSource__c = 'static',
                            //ccrz__StaticResourceName__c = generateRandomString(10),
                            ccrz__MediaType__c='Product Image Thumbnail');
        insert media;
        ccrz__E_CartItem__c  cartitems = EC_TestData.addCartItem(carts[0], proditem.id ,1 ,1);
        
        Contact c = [Select id,AccountId,Email from Contact where id = :thisUser.ContactId];
        
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.effAccountId = c.AccountId;
        ctx.currentCartId = carts[0].ccrz__EncryptedId__c;
       // ccrz.cc_CallContext.initRemoteContext(ctx);
        //ccrz.cc_CallContext.effAccountId = accnt.id;
        Test.startTest();
        //System.runas (thisUser){            
            Map<String,String> result = EC_EmailCartController.cloneCart(carts[0].ccrz__EncryptedId__c,String.valueOf(thisUser.Id), String.valueOf(thisUser.ContactId), '', 'subject');
            EC_EmailCartController.sendEmail('cpadia@deloitte.com', 'rajkyadav@deloitte.com', 'Test...', 'Test...','Test');
            ccrz.cc_RemoteActionResult resultTrue = EC_EmailCartController.sendMailCart(ctx,c.Email, 'rajkyadav@deloitte.com', 'Test...', 'Test...');
           ccrz.cc_RemoteActionResult resultFalse =  EC_EmailCartController.sendMailCart(ctx,'cpadia@deloitte.com', 'rajkyadav@deloitte.com', 'Test...', 'Test...');
           System.assertEquals(true, resultTrue.success); 
           System.assertEquals(false,resultFalse.success); 
            
            Test.stopTest();
       // }
        
    }
    
    /***************************************************************************************************************************************
      Method Name : sendMailCartTest_SalesRep
      Description : This method is used to test positive scenario
      Return type : void
     **************************************************************************************************************************************/
     
    
        @isTest
    private static void sendMailCartTest_SalesRep(){
        
        EC_TestData.setupTestUser();
         User thisUser = [SELECT Id,ContactId FROM User WHERE LastName = 'TestUser'];
        EC_TestData.setupCatalog();
        List<ccrz__E_Cart__c> carts = EC_TestData.createCarts(1);
        Account a = [Select Id from Account limit 1];
        Contact c = new Contact();
        c.LastName = 'test';
        c.AccountId = a.Id;
        c.Email = 'test@test.com';
        c.EC_SalesRep_User__c = thisUser.Id;
        insert c;
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.effAccountId = c.AccountId;
        ctx.currentCartId = carts[0].ccrz__EncryptedId__c;
       // ccrz.cc_CallContext.initRemoteContext(ctx);
        //ccrz.cc_CallContext.effAccountId = accnt.id;
        Test.startTest();
       // System.runas (thisUser){            
            Map<String,String> result = EC_EmailCartController.cloneCart(carts[0].ccrz__EncryptedId__c,String.valueOf(thisUser.Id), String.valueOf(thisUser.ContactId), '', 'subject');
            EC_EmailCartController.sendEmail('cpadia@deloitte.com', 'rajkyadav@deloitte.com', 'Test...', 'Test...','Test');
           ccrz.cc_RemoteActionResult resultTrue =  EC_EmailCartController.sendMailCart(ctx,c.Email, 'rajkyadav@deloitte.com', 'Test...', 'Test...');
           ccrz.cc_RemoteActionResult resultFalse =  EC_EmailCartController.sendMailCart(ctx,'cpadia@deloitte.com', 'rajkyadav@deloitte.com', 'Test...', 'Test...');
           System.assertEquals(true, resultTrue.success); 
           System.assertEquals(false,resultFalse.success); 
            
            Test.stopTest();
       // }
        
    }

}