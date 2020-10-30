/* Class Name    : EC_ccLogicCartValidate
 * Description      :Class to extend the Cloudcraze Logic Class ccLogicCartValidate
 * Created By       :Viraj  
 * Created On       :2019-Jul-18
*/

/* Modification Log:
 * -------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Jul-18        BC-76559            Created the class   
 */
global virtual with sharing class EC_ccLogicCartValidate extends ccrz.ccLogicCartValidate {
    
    /***********************************************************************************************************************************
      Method Name : process
      Description : process creates the Bill To and Ship To address for the cart and updates fields on CC Cart
      Return type : Returns Map<String,Object>
     **********************************************************************************************************************************/
        global virtual override Map<String, Object> process(Map<String, Object> inputData) {
            
            Map<String, Object> retData = new Map<String, Object>();
            retData = super.process(inputData);        
            EC_CartDetailController.updateCartShipToSoldTo();
            return retData;
        }
    
    /***********************************************************************************************************************************
      Method Name : processValidate
      Description : Validates the Cart Products against ISE Products
      Return type : Returns Map<String,Object>
     **********************************************************************************************************************************/
        public virtual override Map<String, Object> processValidate(Map<String, Object> inputData) {
            Map<String, Object> retData = new Map<String, Object>();
            retData = super.processValidate(inputData);
    
            String cartId = String.valueof(retData.get('cartId'));
            List<ccrz__E_CartItem__c> cartItems = new List<ccrz__E_CartItem__c>();
            if(!ccrz__E_CartItem__c.sObjectType.getDescribe().isAccessible()) {
                    return new Map<String, Object>();
                }
    
            cartItems = [SELECT Id,ccrz__Product__r.ccrz__sku__c,ccrz__Product__r.Taxonomy__c, ccrz__Cart__r.EC_Ship_To_Account__r.EC_Division__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.Id=:cartId];
            if(!cartItems.isEmpty() && cartItems[0].ccrz__Cart__r.EC_Ship_To_Account__r.EC_Division__c == System.label.EC_DivisionValueInsitituional) {
                retData = ISE_Validation(cartItems, retData);
            }
            ccrz.ccLog.log('ccLogicCartAddTo retData' + retData);
            return retData;
        }

    /***********************************************************************************************************************************
      Method Name : ISE_Validation
      Description : Validates the Cart Products against ISE Products
      Return type : Returns Map<String,Object>
    **********************************************************************************************************************************/
        private Map<String, Object> ISE_Validation(List<ccrz__E_CartItem__c> cartItems, Map<String, Object> retData) {
            // <PBI-150126> This is used to identify the Product Taxonomy for ReOrder SKUs
                String effAccountId = ccrz.cc_CallContext.effAccountId;
                EC_EntitlementCacheDTO lstCacheProducts = EC_EntitlementCacheUtility.getINSTSalesEntitlementCache(effAccountId);
                List<String> prodIds = new List<String>();
                if(lstCacheProducts != null && lstCacheProducts.productIds != null) {
                    prodIds = lstCacheProducts.productIds;
                } 
                Boolean isValidCart = true;
                
                for(ccrz__E_CartItem__c cartItem: cartItems) { 
                    String sku = cartItem.ccrz__Product__r.ccrz__sku__c;
                    String prodTaxanomy = cartItem.ccrz__Product__r.Taxonomy__c;
                    // <PBI-150126> logic to skip products for INST Entitlements
                    if(!prodIds.isEmpty() && prodIds.contains(sku+EC_Constants.ISE_HYBRIDDIRECT) || (prodIds.contains(effAccountId+EC_Constants.ISE_INDIRECTCORE) && prodTaxanomy ==EC_Constants.TAXONOMY_CHEMICAL)){
                            isValidCart = false;
                            break;
                    }
                }
                retData.put(ccrz.ccApiCart.ALLOW_CHECKOUT, isValidCart);
            
            return retData;
        }
    }