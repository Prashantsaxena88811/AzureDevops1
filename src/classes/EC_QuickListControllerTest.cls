/* Class Name    : EC_QuickListControllerTest
 * Description      Test Class to cover EC_QuickListController
 * Created By       :Venkatesh
 * Created On       :2020-Sep-01
 

 * Modification Log:
 * -----------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------
 * Venkatesh            2020-Sep-01                           Created the class   
 *
 */
@isTest
public class EC_QuickListControllerTest{
    /***************************************************************************************************************************************
  Method Name : addToCartItemsTest
  Description : Test method to cover addToCartItems method
  Return type : void
 *************************************************************************************************************************************/
    public static testMethod void addToCartItemsTest(){
         
        /** creating test data for EC_QLProductWrapper **/
        User thisUserAdmin = [SELECT ID FROM User WHERE ID =: UserInfo.getUserId() LIMIT 1]; 
        System.runas(thisUserAdmin){
            EC_TestData.setupTestUser();
            EC_TestData.setupCatalog();
        }
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' LIMIT 1];    
        System.runas(thisUser){
            /** Test Start Here **/
            Test.startTest();
            ccrz__E_Product__c product = [SELECT ccrz__SKU__c, Name FROM ccrz__E_Product__c LIMIT 1];
            List <EC_QLProductWrapper> listAddToCartProducts = new List<EC_QLProductWrapper>(); 
            EC_QLProductWrapper suggestedProductWarpper = new EC_QLProductWrapper();
            suggestedProductWarpper.sku = product.ccrz__SKU__c;
            suggestedProductWarpper.quantity = 2;
            listAddToCartProducts.add(suggestedProductWarpper);
            
            ccrz__E_Cart__c cart = EC_TestData.createCart();
			cart.ccrz__CartType__c = 'Wishlist';
			update cart;
            
            ccrz__E_Cart__c ocart = [Select ccrz__EncryptedId__c from ccrz__E_Cart__c where id=:cart.id limit 1];
            String encryptedID = ocart.ccrz__EncryptedId__c;
            ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
            new EC_QuickListController();
            EC_QuickListController.addToCartItems(rac,listAddToCartProducts,encryptedID);
            EC_QuickListController.getWLCount(rac,'USD');
            System.assertNotEquals(listAddToCartProducts,null);
            Test.stopTest();  
            /** Test Stop Here **/
        }          
    }
}