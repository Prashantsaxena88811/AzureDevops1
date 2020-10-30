/* Class Name    : EC_SuggestedProductsTest
 * Description      Test Class to cover EC_SuggestedProducts
 * Created By       :Vishal
 * Created On       :2019-Jun-28
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Vishal            2019-Jun-28              BC-74097        Created the class   
 *
 */
@isTest
public class EC_SuggestedProductsTest{
    /***************************************************************************************************************************************
  Method Name : addToCartItemsTest
  Description : Test method to cover addToCartItems method
  Return type : void
 *************************************************************************************************************************************/
    public static testMethod void addToCartItemsTest(){
        
        /** creating test data for EC_SuggestedProductWrapper **/
        User thisUserAdmin = [SELECT ID FROM User WHERE ID =: UserInfo.getUserId() LIMIT 1]; 
        System.runas(thisUserAdmin){
            EC_TestData.setupTestUser();
            EC_TestData.setupCatalog();
        }
        User thisUser = [SELECT Id FROM User WHERE LastName = 'TestUser' LIMIT 1];    
        System.runas(thisUserAdmin){
            /** Test Start Here **/
            Test.startTest();
            EC_SuggestedProducts classOb = new EC_SuggestedProducts();
            ccrz__E_Product__c product = [SELECT ccrz__SKU__c, Name FROM ccrz__E_Product__c LIMIT 1];
            List <EC_SuggestedProductWrapper> listAddToCartProducts = new List<EC_SuggestedProductWrapper>(); 
            EC_SuggestedProductWrapper suggestedProductWarpper = new EC_SuggestedProductWrapper();
            suggestedProductWarpper.sku = product.ccrz__SKU__c;
            suggestedProductWarpper.quantity = 2;
            suggestedProductWarpper.price = 2;
            listAddToCartProducts.add(suggestedProductWarpper);
            
            ccrz__E_Cart__c cart = EC_TestData.createCart();            
            ccrz__E_Cart__c ocart = [Select ccrz__EncryptedId__c from ccrz__E_Cart__c where id=:cart.id limit 1];
            String encryptedID = ocart.ccrz__EncryptedId__c;
            ccrz.cc_RemoteActionContext rac = new ccrz.cc_RemoteActionContext();
            EC_SuggestedProducts.addToCartItems(rac,listAddToCartProducts,encryptedID);
            Test.stopTest();  
            /** Test Stop Here **/
        }         
    }
}