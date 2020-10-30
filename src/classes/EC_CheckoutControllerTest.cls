/* Class Name    : EC_CheckoutControllerTest
 * Description      Test Class to cover EC_CheckoutController
 * Created By       :Ashish
 * Created On       :2019-8-3
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ashish                 2019-8-3      BC-79847        Created the class   
 *
 */
@isTest
public class EC_CheckoutControllerTest {
    /***************************************************************************************************************************************
  Method Name : getProductDetailsTest
  Description : Test method to cover some methods of EC_CheckoutController
  Return type : void
 *************************************************************************************************************************************/
    @isTest
    static void getProductDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new EC_PaymetricAPIMockImpl());
       // Test.setMock(HttpCalloutMock.class, new EC_PaymetricTokenAPIMockImpl());
       // Test.setMock(HttpCalloutMock.class, new EC_PaymetricXiPayAPIMockImpl());
        
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        
        system.runas(thisUser){
            EC_TestData.setupCatalog();
            ccrz.cc_CallContext.pageLabels.put('EC_NALCO','water,energy,paper');
            ccrz__E_Cart__c cart = EC_TestData.createCart();
            List<ccrz__E_Order__c> ordList = EC_TestData.createOrders(1);
            
            Test.startTest();
            
            ccrz.cc_CallContext.userCurrency = 'USD';
            Account testAccount = EC_Testdata.testAccount;
			testAccount.EC_Division__c = 'water';
	        update testAccount;

            ccrz.cc_CallContext.effAccountId = testAccount.Id;
            EC_CheckoutController checkoutController = new EC_CheckoutController();
            
            EC_CheckoutController.billingObjWrapper billingObj = new EC_CheckoutController.billingObjWrapper();            
            billingObj.address1 = 'address1';
            billingObj.address2 = 'address2';
            billingObj.address3 = 'address3';
            billingObj.address4 = 'address4';
            billingObj.city = 'New York';
            billingObj.state = 'New York';
            billingObj.countryCode = 'USA';
            billingObj.postalCode = '77044';
            string billingObjString = JSON.serialize(billingObj);
            
            EC_CheckoutController.generateIframeURL(ctx);            
            EC_CheckoutController.generateIframeURL();
            ctx.queryParams = new Map<String,String>{
                'cartID' => cart.ccrz__EncryptedId__c
            };
            EC_CheckoutController.getTokenResults(ctx,'123','123','USD',billingObjString);
            
            
            EC_CacheWrapper usrInformation = new EC_CacheWrapper();
            usrInformation.userFirstName = 'testFirstName' ;
            usrInformation.userLastName = 'testLastName' ;
            usrInformation.userProfile = 'Sales Rep';

            Cache.SessionPartition orgPart = Cache.Session.getPartition('local.UserCache');
            orgPart.put('UserInfo1', usrInformation);
            list<ccrz__E_Product__c> prodMap = [SELECT id,ccrz__LongDesc__c,ccrz__LongDescRT__c FROM ccrz__E_Product__c];
            
            //System.assertNotEquals(null, checkoutController);
            ccrz.cc_RemoteActionContext rCon = new ccrz.cc_RemoteActionContext();
            List<Account> accountGroup = [Select id from Account];
            rCon.effAccountId =accountGroup[0].id;
            ccrz.cc_CallContext.initRemoteContext(rCon);
            checkoutController = new EC_CheckoutController();
            System.assertNotEquals(null, checkoutController);
            List<String> prodList = new List<String>();
            for(ccrz__E_Product__c prod : prodMap){
                prodList.add(prod.id);
            }
            
            
            System.assertNotEquals(null, EC_CheckoutController.getProductDetails( ctx, prodList,true,cart.id));
            System.assertNotEquals(null, EC_CheckoutController.getDataDetails( ctx, prodList,ordList[0].id));
            
            ccrz__E_ContactAddr__c billTo = [Select Name,EC_Account_Number__c,ccrz__AddressFirstline__c,ccrz__AddressSecondline__c,
                                             ccrz__AddressThirdline__c,ccrz__AddrReadOnly__c,ccrz__City__c,ccrz__CompanyName__c,ccrz__ContactAddrId__c,
                                             ccrz__Country__c,ccrz__CountryISOCode__c,ccrz__DaytimePhone__c,ccrz__Email__c,ccrz__FirstName__c,
                                             ccrz__HomePhone__c,ccrz__LastName__c,ccrz__MailStop__c,ccrz__MiddleName__c,ccrz__Partner_Id__c,
                                             ccrz__PostalCode__c,ccrz__ShippingComments__c,ccrz__State__c,ccrz__StateISOCode__c 
                                             from ccrz__E_ContactAddr__c where Id=: cart.ccrz__BillTo__c Limit 1];
            billTo.ccrz__Email__c = 'test@email.com';
            billTo.ccrz__MailStop__c = 'mailStop';
            billTo.ccrz__MiddleName__c = 'middleName';
            billTo.ccrz__Partner_Id__c = '123';
            billTo.ccrz__ShippingComments__c ='comments';
            
            update billTo;
            
            System.assertNotEquals(null, EC_CheckoutController.saveAdditionalCartData(ctx, 'attentionTo', 'attenNumber','12345', cart.ccrz__EncryptedId__c, billTo.id,'', true));
            
            
           
            
            Test.stopTest();
        }
    }
    /***************************************************************************************************************************************
  Method Name : getProductDetailsTest2
  Description : Test method to cover some methods of EC_CheckoutController
  Return type : void
 *************************************************************************************************************************************/
    @isTest
    static void getProductDetailsTest2(){
       Test.setMock(HttpCalloutMock.class, new EC_PaymetricXiPayAPIMockImpl());
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        
        system.runas(thisUser){
            EC_TestData.setupCatalog();
            ccrz__E_Cart__c cart = EC_TestData.createCart();
            List<ccrz__E_Order__c> ordList = EC_TestData.createOrders(1);
            
            Test.startTest();
            
            ccrz.cc_CallContext.userCurrency = 'USD';
            ccrz.cc_CallContext.effAccountId = [Select Id from Account Limit 1].id;
            EC_CheckoutController checkoutController = new EC_CheckoutController();
            
            EC_CheckoutController.billingObjWrapper billingObj = new EC_CheckoutController.billingObjWrapper();            
            billingObj.address1 = 'address1';
            billingObj.address2 = 'address2';
            billingObj.address3 = 'address3';
            billingObj.address4 = 'address4';
            billingObj.city = 'New York';
            billingObj.state = 'New York';
            billingObj.countryCode = 'USA';
            billingObj.postalCode = '77044';
            string billingObjString = JSON.serialize(billingObj);
            
            EC_CheckoutController.generateIframeURL(ctx);            
            EC_CheckoutController.generateIframeURL();
            ctx.queryParams = new Map<String,String>{
                'cartID' => cart.ccrz__EncryptedId__c
            };
            EC_CheckoutController.getTokenResults(ctx,'123','123','USD',billingObjString);
            
            
            EC_CacheWrapper usrInformation = new EC_CacheWrapper();
            usrInformation.userFirstName = 'testFirstName' ;
            usrInformation.userLastName = 'testLastName' ;
            usrInformation.userProfile = 'Sales Rep';

            Cache.SessionPartition orgPart = Cache.Session.getPartition('local.UserCache');
            orgPart.put('UserInfo1', usrInformation);
            list<ccrz__E_Product__c> prodMap = [SELECT id,ccrz__LongDesc__c,ccrz__LongDescRT__c FROM ccrz__E_Product__c];
            
            //System.assertNotEquals(null, checkoutController);
            ccrz.cc_RemoteActionContext rCon = new ccrz.cc_RemoteActionContext();
            List<Account> accountGroup = [Select id from Account];
            rCon.effAccountId =accountGroup[0].id;
            ccrz.cc_CallContext.initRemoteContext(rCon);
            checkoutController = new EC_CheckoutController();
            System.assertNotEquals(null, checkoutController);
            List<String> prodList = new List<String>();
            for(ccrz__E_Product__c prod : prodMap){
                prodList.add(prod.id);
            }
            System.assertNotEquals(null, EC_CheckoutController.getProductDetails( ctx, prodList,true,cart.id));
            System.assertNotEquals(null, EC_CheckoutController.getDataDetails( ctx, prodList,ordList[0].id));
            
            ccrz__E_ContactAddr__c billTo = [Select Name,EC_Account_Number__c,ccrz__AddressFirstline__c,ccrz__AddressSecondline__c,
                                             ccrz__AddressThirdline__c,ccrz__AddrReadOnly__c,ccrz__City__c,ccrz__CompanyName__c,ccrz__ContactAddrId__c,
                                             ccrz__Country__c,ccrz__CountryISOCode__c,ccrz__DaytimePhone__c,ccrz__Email__c,ccrz__FirstName__c,
                                             ccrz__HomePhone__c,ccrz__LastName__c,ccrz__MailStop__c,ccrz__MiddleName__c,ccrz__Partner_Id__c,
                                             ccrz__PostalCode__c,ccrz__ShippingComments__c,ccrz__State__c,ccrz__StateISOCode__c 
                                             from ccrz__E_ContactAddr__c where Id=: cart.ccrz__BillTo__c Limit 1];
            billTo.ccrz__Email__c = 'test@email.com';
            billTo.ccrz__MailStop__c = 'mailStop';
            billTo.ccrz__MiddleName__c = 'middleName';
            billTo.ccrz__Partner_Id__c = '123';
            billTo.ccrz__ShippingComments__c ='comments';
            
            update billTo;
            
            System.assertNotEquals(null, EC_CheckoutController.saveAdditionalCartData(ctx, 'attentionTo', 'attenNumber','12345', cart.ccrz__EncryptedId__c, billTo.id,'', true));
            Test.stopTest();
        }
    }
    /***************************************************************************************************************************************
  Method Name : getProductDetailsTest3
  Description : Test method to cover some methods of EC_CheckoutController
  Return type : void
 *************************************************************************************************************************************/
    @isTest
    static void getProductDetailsTest3(){
       Test.setMock(HttpCalloutMock.class, new EC_PaymetricTokenizedAPIMockImpl());
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext(); 
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        
        system.runas(thisUser){
            EC_TestData.setupCatalog();
            ccrz__E_Cart__c cart = EC_TestData.createCart();
            List<ccrz__E_Order__c> ordList = EC_TestData.createOrders(1);
            
            Test.startTest();
            
            ccrz.cc_CallContext.userCurrency = 'USD';
            ccrz.cc_CallContext.effAccountId = [Select Id from Account Limit 1].id;
            EC_CheckoutController checkoutController = new EC_CheckoutController();
            
            EC_CheckoutController.billingObjWrapper billingObj = new EC_CheckoutController.billingObjWrapper();            
            billingObj.address1 = 'address1';
            billingObj.address2 = 'address2';
            billingObj.address3 = 'address3';
            billingObj.address4 = 'address4';
            billingObj.city = 'New York';
            billingObj.state = 'New York';
            billingObj.countryCode = 'USA';
            billingObj.postalCode = '77044';
            string billingObjString = JSON.serialize(billingObj);
            
            EC_CheckoutController.generateIframeURL(ctx);            
            EC_CheckoutController.generateIframeURL();
            ctx.queryParams = new Map<String,String>{
                'cartID' => cart.ccrz__EncryptedId__c
            };
            EC_CheckoutController.getTokenResults(ctx,'123','123','USD',billingObjString);
            
            
            EC_CacheWrapper usrInformation = new EC_CacheWrapper();
            usrInformation.userFirstName = 'testFirstName' ;
            usrInformation.userLastName = 'testLastName' ;
            usrInformation.userProfile = 'Sales Rep';

            Cache.SessionPartition orgPart = Cache.Session.getPartition('local.UserCache');
            orgPart.put('UserInfo1', usrInformation);
            list<ccrz__E_Product__c> prodMap = [SELECT id,ccrz__LongDesc__c,ccrz__LongDescRT__c FROM ccrz__E_Product__c];
            
            //System.assertNotEquals(null, checkoutController);
            ccrz.cc_RemoteActionContext rCon = new ccrz.cc_RemoteActionContext();
            List<Account> accountGroup = [Select id from Account];
            rCon.effAccountId =accountGroup[0].id;
            ccrz.cc_CallContext.initRemoteContext(rCon);
            checkoutController = new EC_CheckoutController();
            System.assertNotEquals(null, checkoutController);
            List<String> prodList = new List<String>();
            for(ccrz__E_Product__c prod : prodMap){
                prodList.add(prod.id);
            }
            System.assertNotEquals(null, EC_CheckoutController.getProductDetails( ctx, prodList,true,cart.id));
            System.assertNotEquals(null, EC_CheckoutController.getDataDetails( ctx, prodList,ordList[0].id));
            
            ccrz__E_ContactAddr__c billTo = [Select Name,EC_Account_Number__c,ccrz__AddressFirstline__c,ccrz__AddressSecondline__c,
                                             ccrz__AddressThirdline__c,ccrz__AddrReadOnly__c,ccrz__City__c,ccrz__CompanyName__c,ccrz__ContactAddrId__c,
                                             ccrz__Country__c,ccrz__CountryISOCode__c,ccrz__DaytimePhone__c,ccrz__Email__c,ccrz__FirstName__c,
                                             ccrz__HomePhone__c,ccrz__LastName__c,ccrz__MailStop__c,ccrz__MiddleName__c,ccrz__Partner_Id__c,
                                             ccrz__PostalCode__c,ccrz__ShippingComments__c,ccrz__State__c,ccrz__StateISOCode__c 
                                             from ccrz__E_ContactAddr__c where Id=: cart.ccrz__BillTo__c Limit 1];
            billTo.ccrz__Email__c = 'test@email.com';
            billTo.ccrz__MailStop__c = 'mailStop';
            billTo.ccrz__MiddleName__c = 'middleName';
            billTo.ccrz__Partner_Id__c = '123';
            billTo.ccrz__ShippingComments__c ='comments';
            
            update billTo;
            
            System.assertNotEquals(null, EC_CheckoutController.saveAdditionalCartData(ctx, 'attentionTo', 'attenNumber','12345', cart.ccrz__EncryptedId__c, billTo.id,'', true));
            Test.stopTest();
        }
    }
}