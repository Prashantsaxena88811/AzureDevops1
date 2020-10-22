/* Class Name       : EC_EffectiveAccountControllerTest
 * Description      : Test class for the EC_EffectiveAccountController Class.
 * Created By       : Vishal  
 * Created On       : 8/22/2019

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Vishal                   8/22/2019     WI-75941                Created the test class   
 *
 */

@isTest
public class EC_EffectiveAccountControllerTest{  
     /***************************************************************************************************************************************
      Method Name : updateContactLocaleTest
      Description : Test Method for EC_EffectiveAccountController.updateContactLocale(cc_RemoteActionContext,String,String, String)
      Return type : Returns void
     *************************************************************************************************************************************/
    public static testMethod void updateContactLocaleTest(){
        EC_TestData.setupCatalog();
        ccrz__E_cart__c cart = EC_TestData.createCart();
        Account testAccount = EC_TestData.testAccountShipTo;
        Test.startTest();
        ccrz.cc_RemoteActionResult rar = new ccrz.cc_RemoteActionResult();
        ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
        EC_EffectiveAccountController eac = new EC_EffectiveAccountController();
        String locale = 'Canada';      
        rar  = EC_EffectiveAccountController.updateContactLocale(rac, locale,testAccount.id,cart.id);
        locale = 'US';
        rar  = EC_EffectiveAccountController.updateContactLocale(rac, locale,testAccount.id,cart.id);
        Test.stopTest();
        system.assertEquals(rar.success,true);
    }
}