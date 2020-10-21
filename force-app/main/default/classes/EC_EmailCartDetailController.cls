public class EC_EmailCartDetailController {

    public String cartId{get;set;}
    public EC_EmailCartDetailController(){
    }

    public cartDetailsInfoWrapper getCartDetailsInfo(){
        cartDetailsInfoWrapper cartDetailInfoObj = new cartDetailsInfoWrapper();
        
        //fetch the cart and set cart details in wrapper
        ccrz__E_Cart__c cart = [Select Name,EC_Ship_To_Account__c,ccrz__CurrencyISOCode__c,ccrz__TotalAmount__c,EC_User_Comments__c,ccrz__EncryptedId__c,ccrz__ShipTo__c,createdBy.Name from ccrz__E_Cart__c Where ID=:cartId Limit 1];
        cartDetailInfoObj.user = cart.createdBy.Name;
        cartDetailInfoObj.cartId = cart.id;
        cartDetailInfoObj.currencyIsoCode = cart.ccrz__CurrencyISOCode__c;
        cartDetailInfoObj.cartTotal = cart.ccrz__TotalAmount__c;
        cartDetailInfoObj.userComments = cart.EC_User_Comments__c;
        cartDetailInfoObj.cartUrl =  Label.EC_BaseURL + '/'+Label.EC_Storefront_Name+'/ccrz__Cart?cartId=' + cart.ccrz__EncryptedId__c + '&effectiveAccount=' + cart.EC_Ship_To_Account__c; //+ccrz.cc_CallContext.effAccountId;
        //fetch cart items and product media and set cart items details in child wrapper
        List<ccrz__E_CartItem__c> cartItemsList = new List<ccrz__E_CartItem__c>();
        cartItemsList = [Select Id,ccrz__Quantity__c,ccrz__Price__c,ccrz__ItemTotal__c,ccrz__Product__r.Name,ccrz__Product__r.ccrz__SKU__c from ccrz__E_CartItem__c Where ccrz__Cart__c =: cartId];
        List<cartItemInforWrapper> cartItemWrapperList = new List<cartItemInforWrapper>();
        Map<String,String> productMediaMap = new Map<String,String>();
        
        if(!cartItemsList.isEmpty()){
            
            for(ccrz__E_CartItem__c item : cartItemsList){
                productMediaMap.put(item.ccrz__Product__c,'');
            }
            
            List<ccrz__E_ProductMedia__c> productMediaList = new List<ccrz__E_ProductMedia__c>();
            productMediaList = [Select ccrz__URI__c,ccrz__MediaType__c,ccrz__Product__c  from ccrz__E_ProductMedia__c Where ccrz__Product__c In:productMediaMap.keySet() and ccrz__MediaType__c = 'Product Image Thumbnail' and ccrz__enabled__c = true];
            if(!productMediaList.isEmpty()){
                for(ccrz__E_ProductMedia__c media : productMediaList){
                    if(productMediaMap.containsKey(media.ccrz__Product__c)){
                        productMediaMap.put(media.ccrz__Product__c,media.ccrz__URI__c);
                    }
                }
            }
            for(ccrz__E_CartItem__c item : cartItemsList){
                cartItemInforWrapper itemObj = new cartItemInforWrapper ();
                itemObj.quantity = item.ccrz__Quantity__c;
                itemObj.productCode = item.ccrz__Product__r.ccrz__SKU__c;
                itemObj.cartItemName = item.ccrz__Product__r.Name;
                itemObj.cartItemImage = productMediaMap.get(item.ccrz__Product__c) != null ? productMediaMap.get(item.ccrz__Product__c) : '';
                itemObj.cartItemUnitPrice = item.ccrz__Price__c;
                itemObj.cartItemTotalPrice = item.ccrz__ItemTotal__c;
                cartItemWrapperList.add(itemObj);                
            }
            cartDetailInfoObj.cartItemInfoList = cartItemWrapperList;
        }
        
        return cartDetailInfoObj;
    }   
    
    
    public class cartDetailsInfoWrapper{
        public string user{get;set;}
        public string cartId {get;set;}
        public string currencyIsoCode {get;set;}
        public decimal cartTotal {get;set;}
        public string cartUrl {get;set;}
        public string userComments {get;set;}
        public List<cartItemInforWrapper> cartItemInfoList {get;set;}
    }
    
    public class cartItemInforWrapper {
        public decimal quantity {get;set;}
        public decimal cartItemUnitPrice {get;set;}
        public decimal cartItemTotalPrice {get;set;}
        public string productCode {get;set;}
        public String cartItemName {get;set;}
        public String cartItemImage {get;set;}
    }
    
}