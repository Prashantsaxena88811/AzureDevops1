/* Class Name    : EC_ccLogicCartValidateTest 
 * Description      Test Class to cover EC_ccLogicCartValidate
 * Created By       :Priyanka Priya  
 * Created On       :2019-Aug-19
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Priyanka Priya     2019-Aug-19       BC-76559            Created the class   
 *
 */
@isTest
public class EC_ccLogicCartValidateTest {
     /***************************************************************************************************************************************
  Method Name : processPositiveTest
  Description : Test method to cover process method
  Return type : void
 *************************************************************************************************************************************/
    @isTest 
    static void processPositiveTest(){
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        
        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            EC_TestData.setupTestUser();
            ccrz__E_Cart__c cart = EC_TestData.createCart();
            
            ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
            Contact con =[SELECT id from Contact limit 1];
            rac.priceGroupId = con.id;
            
            AccountContactRelation accCon = new AccountContactRelation();
            accCon.AccountId = EC_TestData.testAccountSoldTo.id;
            accCon.ContactId = con.id;
            Insert accCon;
            
            Account shipTo = EC_TestData.testAccountShipTo;
            shipTo.EC_Division__c = 'WATER';
            update shipTo;
            Account shipTo2 = EC_TestData.testAccountShipTo2;
            rac.userLocale = EC_TestData.testAccount.id;
            rac.effAccountId = shipTo.id;
            rac.currentCartId = cart.ccrz__EncryptedId__c;
            ccrz.cc_CallContext.initRemoteContext(rac);
            
            
            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccAPICart.CART_ID => cart.id,
                    ccrz.ccAPI.API_VERSION => 8
                };
            

            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartValidate classOb = new EC_ccLogicCartValidate();
            Test.startTest();
            thisUser.User_Type__c='Internal';
            thisUser.Phone='123456';
            thisUser.MobilePhone='98765432';
            update thisUser;
            outData = classOb.process(inputData);
            System.assertNotEquals(outData,null);
                        
            /*
            rac.effAccountId = EC_TestData.testAccountSoldTo.id;
            ccrz.cc_CallContext.initRemoteContext(rac);
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
*/
            Test.stopTest();
        }
    }
    /***************************************************************************************************************************************
  Method Name : processNegativeTest
  Description : Test method to cover process method
  Return type : void
 *************************************************************************************************************************************/
    @isTest 
    static void processNegativeTest(){
        
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        
        system.runas(thisUser){
            
            EC_TestData.setupCatalog();
            EC_TestData.setupTestUser();
            ccrz__E_Cart__c cart = EC_TestData.createCart();
            cart = [Select ccrz__BillTo__c, ccrz__ShipTo__c from ccrz__E_Cart__c Where Id=: cart.id Limit 1];
            cart.ccrz__BillTo__c = null;
            cart.ccrz__ShipTo__c = null;
            update cart;

            ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
            Contact con =[SELECT id from Contact limit 1];
            rac.priceGroupId = con.id;
            
            AccountContactRelation accCon = new AccountContactRelation();
            accCon.AccountId = EC_TestData.testAccountSoldTo.id;
            accCon.ContactId = con.id;
            Insert accCon;
            
            Account shipTo = EC_TestData.testAccountShipTo;
            shipTo.EC_Division__c = 'WATER';
            update shipTo;
            Account shipTo2 = EC_TestData.testAccountShipTo2;
            rac.userLocale = EC_TestData.testAccount.id;
            rac.effAccountId = shipTo.id;
            rac.currentCartId = cart.id;
            ccrz.cc_CallContext.initRemoteContext(rac);
            
            
            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccAPICart.CART_ID => cart.id,
                    ccrz.ccAPI.API_VERSION => 8
                };
            

            Map<String,Object> outData = new Map<String,Object>();
            EC_ccLogicCartValidate classOb = new EC_ccLogicCartValidate();
            Test.startTest();
            outData = classOb.process(inputData);
            
            System.assertNotEquals(outData,null);
            /*
            rac.effAccountId = EC_TestData.testAccountSoldTo.id;
            ccrz.cc_CallContext.initRemoteContext(rac);
            outData = classOb.fetchAccounts(inData);
            System.assertNotEquals(outData,null);
*/
            Test.stopTest();
        }
    }
    
}