/* Class Name    : EC_cc_hk_EffectiveAccountTest
 * Description      Test Class to cover EC_cc_hk_EffectiveAccount
 * Created By       :Viraj 
 * Created On       :2019-Jul-3
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj     2019-Jul-3      BC-76559        Created the class   
 *
 */
@isTest
public class EC_cc_hk_EffectiveAccountTest{
    /***************************************************************************************************************************************
  Method Name : fetchAccountsTest
  Description : Test method to cover fetchAccounts and EC_SetAccount_BillingNumber class
  Return type : void
 *************************************************************************************************************************************/
    @isTest 
    static void fetchAccountsTest(){
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];

        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            EC_TestData.setupTestUser();
            
            Map<String,Object> inData = new Map<String,Object>();
            Contact con =[SELECT id, FirstName, LastName from Contact limit 1]; //PBI-121283
            //Contact con =[SELECT id from Contact limit 1];
            CCRZ.cc_CallContext.currContact = con;
            
            AccountContactRelation accCon = new AccountContactRelation();
            accCon.AccountId = EC_TestData.testAccountSoldTo.id;
            accCon.ContactId = con.id;
            accCon.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            Insert accCon;
            
            accCon = new AccountContactRelation();
            accCon.AccountId = EC_TestData.testAccountShipTo.id;
            accCon.ContactId = con.id;
            accCon.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            Insert accCon;
			
            accCon = new AccountContactRelation();
            accCon.AccountId = EC_TestData.testAccountShipTo2.id;
            accCon.ContactId = con.id;
            Insert accCon;
            									  
            Account shipTo = EC_TestData.testAccountShipTo;
            Account shipTo2 = EC_TestData.testAccountShipTo2;
            Account shipTolone2 = EC_TestData.testAccountShipTolone2;
            Account shipTocorp2 = EC_TestData.testAccountShipTocorp2;
			Account soldToFaB = EC_TestData.testAccountShipToFaB;	
            soldToFaB.EC_Account_Number__c    = '';
            soldToFaB.EC_Billing_Account_Number__c = 'Test';
            update  soldToFaB;      
            soldToFaB.EC_Account_Number__c    = EC_TestData.generateRandomString(5);
            update soldToFaB;     												 
            
            accCon = new AccountContactRelation();
            accCon.AccountId = shipTolone2.id;
            accCon.ContactId = con.id;
            Insert accCon;
            
            accCon = new AccountContactRelation();
            accCon.AccountId = shipTocorp2.id;
            accCon.ContactId = con.id;
            Insert accCon;
            
			accCon = new AccountContactRelation();
            accCon.AccountId = soldToFaB.id;
            accCon.ContactId = con.id;
            accCon.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            Insert accCon;	
			
            ccrz.cc_CallContext.currAccountId = EC_TestData.testAccount.id;
            ccrz.cc_CallContext.effAccountId = shipTo.id;
            
            inData.put(ccrz.cc_hk_EffectiveAccount.PARAM_EFFACCOUNT_LIST,new List<ccrz.cc_bean_EffectiveAccount>{new ccrz.cc_bean_EffectiveAccount(EC_TestData.testAccountSoldTo)});
            Map<String,Object> outData = new Map<String,Object>();
            EC_cc_hk_EffectiveAccount classOb = new EC_cc_hk_EffectiveAccount();
            Test.startTest();
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
            
            ccrz.cc_CallContext.effAccountId = EC_TestData.testAccountSoldTo.id;
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
            
            ccrz.cc_CallContext.effAccountId = shipTolone2.id;
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
            
            ccrz.cc_CallContext.effAccountId = shipTocorp2.id;
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
            
			ccrz.cc_CallContext.effAccountId = soldToFaB.id;
            outData = classOb.fetchAccounts(inData);
			System.assertNotEquals(outData,null);			
			
            ccrz__E_Cart__c cartOb = EC_TestData.createCart();
			cartOb.EC_Ship_To_Account__c = EC_TestData.testAccountShipTo.id;
            update cartOb;
            CCRZ.cc_CallContext.currCartId = cartOb.ccrz__EncryptedId__c;
            inData.put('CartData',cartOb);
            outData = classOb.saveCart(inData);
            
            ccrz.cc_CallContext.effAccountId = shipTo.id;
            ccrz__E_AccountAddressBook__c addrBook = new ccrz__E_AccountAddressBook__c();
            ccrz__E_ContactAddr__c  conAddr = new ccrz__E_ContactAddr__c ();
            insert conAddr;
            addrBook.ccrz__Account__c= EC_TestData.testAccountShipTo.id;
            addrBook.ccrz__E_ContactAddress__c = conAddr.id;
            insert addrBook;
            
            outData = classOb.saveCart(inData);
            
            Account testAccount1 = new Account();
            Account testAccount2 = new Account();
            
            testAccount1.Name = 'testAccount2';
            testAccount1.EC_Division__c = 'WATER';
            testAccount1.EC_Account_Number__c = '000456456WA';
            testAccount1.RecordTypeId = EC_TestData.getRecordType('soldTo');
            insert  testAccount1;
            
            testAccount2.Name = 'testAccount1';
            testAccount2.EC_Division__c = 'WATER';
            testAccount2.EC_Account_Number__c = '000456456WA/000345346JIASJI';
            testAccount2.RecordTypeId = EC_TestData.getRecordType('shipTo');
            testAccount2.ParentId = testAccount1.Id;
            insert testAccount2;

            System.assertNotEquals(outData,null);
            
            Test.stopTest();
        }
        
      
    }
    
    
      
    @isTest 
    static void fetchAccounts2Test(){
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];

        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            EC_TestData.setupTestUser();
            
            Map<String,Object> inData = new Map<String,Object>();
            Contact con =[SELECT id, FirstName, LastName from Contact limit 1]; //PBI-121283
            //Contact con =[SELECT id from Contact limit 1];
            CCRZ.cc_CallContext.currContact = con;
            
            AccountContactRelation accCon = new AccountContactRelation();
            accCon.AccountId = EC_TestData.testAccountSoldTo.id;
            accCon.ContactId = con.id;
            accCon.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            Insert accCon;
            
            
            Account testAccountShipTo = [Select Id,Name,ccrz__E_AccountGroup__c,ShippingStreet,ShippingCity,ShippingPostalCode,ShippingCountry,ShippingState,RecordTypeId,BillingStreet,BillingCity,
                                         BillingState,BillingCountry,BillingPostalCode,EC_Account_Number__c,ParentId,EC_Division__c from Account Where Id=:EC_TestData.testAccountShipTo.id Limit 1];
            testAccountShipTo.ParentId = EC_TestData.testAccountSoldTo.id;
            update testAccountShipTo;
            Account testAccountShipTo2 = [Select Id,Name,ccrz__E_AccountGroup__c,ShippingStreet,ShippingCity,ShippingPostalCode,ShippingCountry,ShippingState,RecordTypeId,BillingStreet,BillingCity,
                                         BillingState,BillingCountry,BillingPostalCode,EC_Account_Number__c,ParentId,EC_Division__c from Account Where Id=:EC_TestData.testAccountShipTo2.id Limit 1];
            testAccountShipTo2.ParentId = EC_TestData.testAccountSoldTo.id;
            update testAccountShipTo2;
            
            accCon = new AccountContactRelation();
            accCon.AccountId = testAccountShipTo.id;
            accCon.ContactId = con.id;
            accCon.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            Insert accCon;
			
            accCon = new AccountContactRelation();
            accCon.AccountId = testAccountShipTo2.id;
            accCon.ContactId = con.id;
            Insert accCon;
            									  
            Account shipTo = testAccountShipTo;
            Account shipTo2 = testAccountShipTo2;
            Account shipTolone2 = EC_TestData.testAccountShipTolone2;
            Account shipTocorp2 = EC_TestData.testAccountShipTocorp2;
			Account soldToFaB = EC_TestData.testAccountShipToFaB;	
            soldToFaB.EC_Account_Number__c    = '';
            soldToFaB.EC_Billing_Account_Number__c = 'Test';
            update  soldToFaB;      
            soldToFaB.EC_Account_Number__c    = EC_TestData.generateRandomString(5);
            update soldToFaB;     												 
            
            accCon = new AccountContactRelation();
            accCon.AccountId = shipTolone2.id;
            accCon.ContactId = con.id;
            Insert accCon;
            
            accCon = new AccountContactRelation();
            accCon.AccountId = shipTocorp2.id;
            accCon.ContactId = con.id;
            Insert accCon;
            
			accCon = new AccountContactRelation();
            accCon.AccountId = soldToFaB.id;
            accCon.ContactId = con.id;
            accCon.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            Insert accCon;	
			
            ccrz.cc_CallContext.currAccountId = EC_TestData.testAccount.id;
            ccrz.cc_CallContext.effAccountId = shipTo.id;
            
            inData.put(ccrz.cc_hk_EffectiveAccount.PARAM_EFFACCOUNT_LIST,new List<ccrz.cc_bean_EffectiveAccount>{new ccrz.cc_bean_EffectiveAccount(EC_TestData.testAccountSoldTo)});
            Map<String,Object> outData = new Map<String,Object>();
            EC_cc_hk_EffectiveAccount classOb = new EC_cc_hk_EffectiveAccount();
            Test.startTest();
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
            
            ccrz.cc_CallContext.effAccountId = EC_TestData.testAccountSoldTo.id;
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
            
            ccrz.cc_CallContext.effAccountId = shipTolone2.id;
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
            
            ccrz.cc_CallContext.effAccountId = shipTocorp2.id;
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
            
			ccrz.cc_CallContext.effAccountId = soldToFaB.id;
            outData = classOb.fetchAccounts(inData);
			System.assertNotEquals(outData,null);			
			
            ccrz__E_Cart__c cartOb = EC_TestData.createCart();
			cartOb.EC_Ship_To_Account__c = testAccountShipTo.id;
            update cartOb;
            CCRZ.cc_CallContext.currCartId = cartOb.ccrz__EncryptedId__c;
            inData.put('CartData',cartOb);
            outData = classOb.saveCart(inData);
            
            ccrz.cc_CallContext.effAccountId = shipTo.id;
            ccrz__E_AccountAddressBook__c addrBook = new ccrz__E_AccountAddressBook__c();
            ccrz__E_ContactAddr__c  conAddr = new ccrz__E_ContactAddr__c ();
            insert conAddr;
            addrBook.ccrz__Account__c= testAccountShipTo.id;
            addrBook.ccrz__E_ContactAddress__c = conAddr.id;
            insert addrBook;
            
            outData = classOb.saveCart(inData);
            
            Account testAccount1 = new Account();
            Account testAccount2 = new Account();
            
            testAccount1.Name = 'testAccount2';
            testAccount1.EC_Division__c = 'WATER';
            testAccount1.EC_Account_Number__c = '000456456WA';
            testAccount1.RecordTypeId = EC_TestData.getRecordType('soldTo');
            insert  testAccount1;
            
            testAccount2.Name = 'testAccount1';
            testAccount2.EC_Division__c = 'WATER';
            testAccount2.EC_Account_Number__c = '000456456WA/000345346JIASJI';
            testAccount2.RecordTypeId = EC_TestData.getRecordType('shipTo');
            testAccount2.ParentId = testAccount1.Id;
            insert testAccount2;

            System.assertNotEquals(outData,null);
            
            Test.stopTest();
        }
    }
}