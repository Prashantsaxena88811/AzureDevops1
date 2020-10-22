/*******************************************************************************************************************
Apex Class Name     : EC_cc_hk_Order
Created Date        : 19 July 2019
Description         : Class for extending ccrz.cc_hk_Order
* Developer                        Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Vishal                           19 July 2019           Class for extending ccrz.cc_hk_Order
*************************************************************************************************************************/

global without sharing class EC_cc_hk_Order extends ccrz.cc_hk_Order {

    /************************************************************************
    Method Name: place
    Description: This method overrides the place method
    Parameters: Map<String,Object> inputData
    Returns: Map<String,Object>
    *************************************************************************/

    global override Map<String,Object> place(Map<String,Object> inputData){
        inputData = super.place(inputData);
        string currentStep = (String)inputData.get('placeStep');
        if(currentStep == ccrz.cc_hk_Order.STEP_CREATE_ORDER_ITEMS_POST && inputData.containsKey('order')){
            //Unloading & Tank Number Logic
            set<Id> orderItemsIdSet = new set<Id>();
            List<ccrz__E_OrderItem__c> orderItems = (List<ccrz__E_OrderItem__c>) inputData.get('orderItems');
            ccrz__E_Order__c currentOrder = (ccrz__E_Order__c)inputData.get('order');
            ccrz__E_Order__c oOrder = [select ccrz__EffectiveAccountID__c,OrderRushEmail__c, ccrz__Account__r.EC_Division__c,ccrz__Account__c, ccrz__OriginatedCart__r.OrderRushEmail__c, ccrz__OriginatedCart__c,ccrz__ShipTo__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ShipTo_Name__c,ccrz__OriginatedCart__r.ccrz__PaymentMethod__c,ccrz__OriginatedCart__r.ccrz__PONumber__c,ccrz__PaymentMethod__c, ccrz__BillTo__c,OwnerId,ccrz__OriginatedCart__r.ccrz__BillTo__c FROM ccrz__E_Order__c where id=:currentOrder.id];
            String originatedCartId = currentOrder.ccrz__OriginatedCart__c;
            List<ccrz__E_OrderItem__c> oItems = new List<ccrz__E_OrderItem__c>();
            List<ccrz__E_CartItem__c> cItems = new List<ccrz__E_CartItem__c>();
            if(OrderItems != null && !orderItems.isEmpty()){
                        for(ccrz__E_OrderItem__c orderItem : orderItems){
                            orderItemsIdSet.add(orderItem.id);
                        }
                    }
            if(!orderItemsIdSet.isEmpty()) {

               oItems = [SELECT ccrz__Order__c,ccrz__Product__c,Id,Tank_Number__c,Unloading_Point__c,Custom_UnitPrice__c,Custom_PricingUOM__c,Custom_Factor__c,ccrz__Product__r.Taxonomy__c FROM ccrz__E_OrderItem__c where ID in :orderItemsIdSet];
               cItems = [SELECT ccrz__CartItemId__c,ccrz__Product__c,ccrz__Cart__c,Tank_Number__c,Unloading_Point__c,Id,Custom_UnitPrice__c,Custom_PricingUOM__c,Custom_Factor__c FROM ccrz__E_CartItem__c where ccrz__Cart__c =:originatedCartId];

               Map<Id,unloadingPointTankWrapper> unloadingTankWrapperMap = new Map<Id,unloadingPointTankWrapper>();
               for(ccrz__E_CartItem__c cartItem: cItems)  {
                   unloadingTankWrapperMap.put(cartItem.ccrz__Product__c, new unloadingPointTankWrapper(cartItem.Unloading_Point__c,cartItem.Tank_Number__c,cartItem.ccrz__Product__c,cartItem.Custom_UnitPrice__c,cartItem.Custom_PricingUOM__c,Integer.valueOf(cartItem.Custom_Factor__c)));
               }
               for(ccrz__E_OrderItem__c orderItem: oItems ) {
                   if(unloadingTankWrapperMap.containsKey(orderItem.ccrz__Product__c)){
                        orderItem.Tank_Number__c = unloadingTankWrapperMap.get(orderItem.ccrz__Product__c).tankNumber;
                        orderItem.Unloading_Point__c = unloadingTankWrapperMap.get(orderItem.ccrz__Product__c).unloadingpoint;
                        orderItem.Custom_UnitPrice__c = unloadingTankWrapperMap.get(orderItem.ccrz__Product__c).CustomUnitPrice;
                        orderItem.Custom_PricingUOM__c = unloadingTankWrapperMap.get(orderItem.ccrz__Product__c).CustomPricingUOM;
                        orderItem.Custom_Factor__c = unloadingTankWrapperMap.get(orderItem.ccrz__Product__c).CustomFactor;
                    }
                }
                update oItems;
               }
            oOrder.OrderRushEmail__c = oOrder.ccrz__OriginatedCart__r.OrderRushEmail__c;
            update oOrder;
          // End of UL & TankNumber Logic
        }
        if(currentStep == ccrz.cc_hk_Order.STEP_END && inputData.containsKey('order')){
            ccrz__E_Order__c currentOrder = (ccrz__E_Order__c)inputData.get('order');
            ccrz__E_Order__c oOrder = [select ccrz__EffectiveAccountID__c, ccrz__Account__c, ccrz__OriginatedCart__c,ccrz__ShipTo__c,ccrz__OriginatedCart__r.ccrz__ShipTo__r.ShipTo_Name__c,ccrz__OriginatedCart__r.ccrz__PaymentMethod__c,ccrz__OriginatedCart__r.ccrz__PONumber__c,ccrz__PaymentMethod__c, ccrz__BillTo__c,OwnerId,ccrz__OriginatedCart__r.ccrz__BillTo__c FROM ccrz__E_Order__c where id=:currentOrder.id];
            String poNumber = oOrder.ccrz__OriginatedCart__r.ccrz__PONumber__c;
            oOrder.ccrz__PONumber__c = poNumber;

            //NALCOENHANCEMENT : AK
            List<ccrz__E_ContactAddr__c> orderShipAddress = [SELECT Id, ShipTo_Name__c FROM ccrz__E_ContactAddr__c WHERE Id =:oOrder.ccrz__ShipTo__c Limit 1];
            if(orderShipAddress != null && !orderShipAddress.isEmpty()){
                orderShipAddress[0].ShipTo_Name__c = oOrder.ccrz__OriginatedCart__r.ccrz__ShipTo__r.ShipTo_Name__c;
                update orderShipAddress;
            }

            Map<Id,ccrz__E_ContactAddr__c> billToContactAddressMap = new Map<ID,ccrz__E_ContactAddr__c> ([Select Id,ccrz__Partner_Id__c,ccrz__ContactAddrId__c from ccrz__E_ContactAddr__c Where Id =:oOrder.ccrz__BillTo__c OR Id=: oOrder.ccrz__OriginatedCart__r.ccrz__BillTo__c Limit 2]);

            if(!billToContactAddressMap.isEmpty()){
                ccrz__E_ContactAddr__c billingAddress = billToContactAddressMap.get(oOrder.ccrz__BillTo__c);
                ccrz__E_ContactAddr__c cartContactAddr = billToContactAddressMap.get( oOrder.ccrz__OriginatedCart__r.ccrz__BillTo__c);
                if(!String.isBlank(cartContactAddr.ccrz__ContactAddrId__c)){
                  billingAddress.ccrz__Partner_Id__c = cartContactAddr.ccrz__ContactAddrId__c;
                }
                update billingAddress;
            }

            List<ccrz__E_PaymentDetail__c> paymentDetail = [SELECT id,ccrz__Payment_Method__c,ccrz__CC_Order__c,ccrz__Cart__c from ccrz__E_PaymentDetail__c where ccrz__Cart__c = :oOrder.ccrz__OriginatedCart__c Order By CreatedDate DESC];
            if(paymentDetail.size()>0){
                paymentDetail[0].ccrz__CC_Order__c = oOrder.id;
                oOrder.ccrz__PaymentMethod__c = oOrder.ccrz__OriginatedCart__r.ccrz__PaymentMethod__c;
                //oOrder.ccrz__PONumber__c = oOrder.ccrz__OriginatedCart__r.ccrz__PONumber__c ;
                update paymentDetail;
            }

            ccrz.ccLog.log('AK', 'order hook inputData' + inputData );
            String effectiveAccountID = oOrder.ccrz__EffectiveAccountID__c;
            if (effectiveAccountID != null){
                ccrz.ccLog.log('VT', 'Effective ID is' + effectiveAccountID);
                Account orderEffectiveAccount = [Select Id FROM Account WHERE Id=:effectiveAccountID];
                oOrder.ccrz__Account__c = orderEffectiveAccount.Id;
                try{
                    List<ccrz__E_OrderItem__c> orderItems = (List<ccrz__E_OrderItem__c>) inputData.get('orderItems');
                    Map<Id,ccrz__E_OrderItem__c> productOrderItems = new Map<Id,ccrz__E_OrderItem__c>();
                    if(OrderItems != null && !orderItems.isEmpty()){
                        for(ccrz__E_OrderItem__c orderItem : orderItems){
                            productOrderItems.put(orderItem.ccrz__Product__c,orderItem);
                        }
                    }

                    //get existing wishlist
                    List<ccrz__E_Cart__c> wishList = new List<ccrz__E_Cart__c>();
                    wishList = [Select Name,Id, OwnerId from ccrz__E_Cart__c Where OwnerId =: oOrder.OwnerId AND ccrz__CartType__c='WishList' AND EC_PurchasedWishlist__c=true Limit 1];
                    List<ccrz__E_CartItem__c> newWishListCartItems = new List<ccrz__E_CartItem__c>();
                    ccrz.ccLog.log('PK wishList', 'existing wishList is' + wishList);
                    if(wishList!= null && !wishList.isEmpty()){
                        List<ccrz__E_CartItem__c> wishListCartItems = new List<ccrz__E_CartItem__c>();
                        //wishlist found - check for cart items
                        wishListCartItems = [Select Id,ccrz__Product__c,EC_Last_Purchased_Date__c,ccrz__Quantity__c,ccrz__Price__c,ccrz__SubAmount__c from ccrz__E_CartItem__c where ccrz__Cart__c=:wishList[0].id];

                        Map<Id,ccrz__E_CartItem__c> productCartItemMap = new Map<Id,ccrz__E_CartItem__c>();
                        for(ccrz__E_CartItem__c cartItem : wishListCartItems){
                            productCartItemMap.put(cartItem.ccrz__Product__c,cartItem);
                        }

                        for(Id prod : productOrderItems.keySet()){
                            if(productCartItemMap.containsKey(prod)){
                                productCartItemMap.get(prod).EC_Last_Purchased_Date__c = system.today();
                                newWishListCartItems.add(productCartItemMap.get(prod));
                            }else{
                                //cart items not matching order items - create new cart items and add them to list
                                ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c(ccrz__Product__c = prod,ccrz__Quantity__c =1,ccrz__Price__c = 0.0,ccrz__SubAmount__c=0.0,
                                                                                       EC_Last_Purchased_Date__c =  System.today(),ccrz__Cart__c = wishList[0].id);
                                newWishListCartItems.add(cartItem);
                            }
                        }
                        ccrz.ccLog.log('PK before wishlist creation', 'newWishListCartItems is' + newWishListCartItems);
                        upsert newWishListCartItems;

                    }else{
                        //no existing wishlist and no wishlist items
                        ccrz__E_Cart__c newWishList = new ccrz__E_Cart__c(OwnerId = oOrder.OwnerId,
                                                                          ccrz__CartType__c = 'WishList',
                                                                          ccrz__Storefront__c = 'DefaultStore',
                                                                          EC_PurchasedWishlist__c = true);
                        ccrz.ccLog.log('PK', 'newWishList is' + newWishList);
                        insert newWishList;
                        for(Id products : productOrderItems.keySet()){
                            ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c(ccrz__Product__c = products,ccrz__Quantity__c =1,ccrz__Price__c =0.0,ccrz__SubAmount__c =0.0,
                                                                                   EC_Last_Purchased_Date__c =  System.today(),ccrz__Cart__c =newWishList.id );
                            newWishListCartItems.add(cartItem);
                        }
                        ccrz.ccLog.log('PK', 'newWishListCartItems is' + newWishListCartItems);
                        insert newWishListCartItems;
                    }

                }catch(Exception ex){
                    ccrz.ccLog.log('AK: orderhook wishlist '+ ex.getMessage() + ' ' + ex.getLineNumber());
                }
            }

            update oOrder;
        }
        return inputData;
    }

    public class unloadingPointTankWrapper {
        public Id unloadingpoint {get;set;}
        public Id tankNumber {get;set;}
        public Id product {get;set;}
		public Decimal CustomUnitPrice{get;set;}
        public String CustomPricingUOM{get;set;}
        public Integer CustomFactor{get;set;}
        public unloadingPointTankWrapper(Id unloadingpoint, Id tankNumber, Id product, Decimal CustomUnitPrice,String CustomPricingUOM,Integer CustomFactor){
            this.unloadingpoint = unloadingpoint;
            this.tankNumber = tankNumber;
            this.product = product;
            this.CustomUnitPrice = CustomUnitPrice;
            this.CustomPricingUOM = CustomPricingUOM;
            this.CustomFactor = CustomFactor;
        }
    }
}