/* Class Name    : EC_CartDetailController 
 * Description      :Controller Class for Cart Detail Component
 * Created By       :Viraj  
 * Created On       :2019-Sep-05
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Sep-05         BC-80775            Created the class   
 *
 */
    global class EC_CartDetailController{
    
    public boolean isSalesRep {get;set;}
    public Boolean viewPrice {get;set;}
    public Boolean buyOnline {get;set;}
    public Boolean isFlatFeeUser {get;set;}
    /***************************************************************************************************************************************
  Constructor Name : EC_CartDetailController
  Description : Constructor to initialize variables of EC_CartDetailController to be used in the component
  Return type : N/A
 *************************************************************************************************************************************/
    public EC_CartDetailController(){
        isSalesRep = false;        
        isFlatFeeUser = false;
        User user = [SELECT id, User_Type__c FROM User where id = :ccrz.cc_CallContext.currUser.id];
        if(user.User_Type__c  == System.label.EC_UserType_Internal){
            isSalesRep  = true;
        }
        Date today = Date.today();
        for(ccrz__E_AccountGroupPriceList__c accGroup : [SELECT EC_Price_List_Type__c 
                                                                 from ccrz__E_AccountGroupPriceList__c 
                                                                 where ccrz__StartDate__c <= :today 
                                                                 AND ccrz__EndDate__c >= :today 
                                                                 AND ccrz__Enable__c = true 
                                                                 AND ccrz__AccountGroup__c IN (Select ccrz__E_AccountGroup__c from Account Where Id=:ccrz.cc_CallContext.effAccountId)
                                                                 AND ccrz__Pricelist__r.ccrz__CurrencyISOCode__c=:ccrz.cc_CallContext.userCurrency
                                                                 AND ccrz__Pricelist__r.ccrz__Enabled__c = true
                                                                 AND ccrz__Pricelist__r.ccrz__StartDate__c <= :today 
                                                                 AND ccrz__Pricelist__r.ccrz__EndDate__c >= :today]){     
                                                                     if (accGroup.EC_Price_List_Type__c != null && (accGroup.EC_Price_List_Type__c.contains('Z1MP') || accGroup.EC_Price_List_Type__c.contains('ZFCP'))) {
                                                                        isFlatFeeUser = true; 
                                                                        break;
                                                                     }       
                                                                 } 
        viewPrice = false;
        buyOnline = false;
        List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermissionCacheInfo();
        ccrz.ccLog.log('permWrapperLst54'+permWrapperLst);
        for(EC_Utility.PermWrapper perm : permWrapperLst){
            if(perm.permName == 'View Price'){
                viewPrice = perm.permVal;
            }
            if(perm.permName == 'Buy Online'){
                buyOnline= perm.permVal;
            }
        }
    }

 /***************************************************************************************************************************************
  Method Name : saveUnloadingPoints
  Description : queries the unloading points for the account.
  Return type : ccrz.cc_RemoteActionResult
 *************************************************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveUnloadingPoints(final ccrz.cc_RemoteActionContext ctx,String cartsfId, List<Map<String,String>> prodList, string defaultPoint) {
    	ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
		res.success = false;
        try {
            List<ccrz__E_CartItem__c> currentItemLists = new List<ccrz__E_CartItem__c>();
        	currentItemLists = [SELECT ccrz__CartItemId__c,ccrz__Cart__c,Tank_Number__c,Unloading_Point__c,Id FROM ccrz__E_CartItem__c where ccrz__Cart__c =:cartsfId];
            if(currentItemLists.size() > 0) {
            	for(Map<String,String> Item : prodList) {
                    for (ccrz__E_CartItem__c currentItemList : currentItemLists ) {
                        if (String.valueOf(Item.get('sfid')) == currentItemList.Id) {
                            currentItemList.Tank_Number__c = String.valueOf(Item.get('tanknumber'));
                			currentItemList.Unloading_Point__c = String.valueOf(Item.get('unloadpoint'));
                        }                        
                    }                	
            	}
                update currentItemLists;
                List<ccrz__E_Cart__c> cart = new List<ccrz__E_Cart__c>();
                cart = [SELECT Id,Default_Unloading_Point__c FROM ccrz__E_Cart__c where id=:cartsfId limit 1];
                cart[0].Default_Unloading_Point__c = defaultPoint;
                update cart;
            	res.success = true;
        	}
        } catch(Exception ex) {
                system.debug('Exception occured on saving Unloading Points & Tank numbers'+ ex.getMessage());
            }
        ccrz.cclog.log('saveUnloadingPoints: ' , + res);
        return res;
    }

/***************************************************************************************************************************************
  Method Name : updateCartShipToSoldTo
  Description : Creates the Bill To and Ship To address for the cart and updates fields on CC Cart
  Return type : Void
 **************************************************************************************************************************************/        
    public static void updateCartShipToSoldTo() {
        boolean toUpdateCart = false;
        List<ccrz__E_Cart__c> cartOb = new List<ccrz__E_Cart__c>();
        
        cartOb = [SELECT id,EC_Ship_To_Account__c,EC_Sold_To_Account__c,ccrz__EncryptedId__c,ccrz__ShipTo__c,ccrz__BillTo__c,
                  ccrz__BuyerFirstName__c,ccrz__BuyerLastName__c,ccrz__BuyerEmail__c,ccrz__BuyerPhone__c,ccrz__BuyerMobilePhone__c
                  from ccrz__E_Cart__c where ccrz__EncryptedId__c = :CCRZ.cc_CallContext.currCartId or id =:CCRZ.cc_CallContext.currCartId LIMIT 1];
        if(!cartOb.isEmpty()){
            User loggedInUser = [Select User_Type__c,Phone,MobilePhone from User Where Id =: UserInfo.getUserId() Limit 1];
            if(String.isNotBlank(loggedInUser.User_Type__c) && loggedInUser.User_Type__c.equalsIgnoreCase('internal')){
                toUpdateCart = true;
                cartOb[0].ccrz__BuyerFirstName__c = UserInfo.getFirstName();
                cartOb[0].ccrz__BuyerLastName__c = UserInfo.getLastName();
                cartOb[0].ccrz__BuyerEmail__c = UserInfo.getUserEmail();
                if(String.isNotBlank(loggedInUser.Phone)){
                    cartOb[0].ccrz__BuyerPhone__c = loggedInUser.Phone;    
                }
                if(String.isNotBlank(loggedInUser.MobilePhone)){
                    cartOb[0].ccrz__BuyerMobilePhone__c = loggedInUser.MobilePhone;
                }   
            }
        }
        
        List<Account> shipToAccount= [SELECT id,EC_Division__c,EC_Account_Number__c,Ship_To_Name__c, Parent.RecordType.Name,RecordType.Name,RecordTypeId,ParentId,BillingAddress,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,ShippingAddress,ShippingCity,ShippingCountry,ShippingPostalCode, ShippingState,ShippingStreet,Parent.id,Parent.EC_Account_Number__c,Parent.EC_Division__c,Parent.RecordTypeId,Parent.BillingAddress,Parent.BillingCity,Parent.BillingCountry,Parent.BillingPostalCode,Parent.BillingState, Parent.BillingStreet, Parent.ShippingAddress,Parent.ShippingCity,Parent.ShippingCountry,Parent.ShippingPostalCode,Parent.ShippingState,Parent.ShippingStreet from Account where (Id=: ccrz.cc_CallContext.effAccountId)];
        List<Account> soldToAccount = new List<Account>();
        
        if(shipToAccount[0].ParentId != null &&  shipToAccount[0].Parent.RecordType.Name != System.Label.EC_Account_Corporate && shipToAccount[0].EC_Division__c!=null && !Label.EC_Institutional_Accounts.contains(shipToAccount[0].EC_Division__c.toLowerCase())){
            soldToAccount.add(shipToAccount[0].Parent);
        }else{
            soldToAccount = shipToAccount;
        }
        if(shipToAccount.size() >0 && cartOb[0].EC_Ship_To_Account__c!=shipToAccount[0].id){
            toUpdateCart = true;
            cartOb[0].EC_Ship_To_Account__c = shipToAccount[0].id;
        }
        if(soldToAccount.size() >0 && cartOb[0].EC_Sold_To_Account__c!=soldToAccount[0].id){
            toUpdateCart = true;
            cartOb[0].EC_Sold_To_Account__c = soldToAccount[0].id;
        }

        if(cartOb[0].ccrz__BillTo__c==null && soldToAccount.size() > 0){
            ccrz__E_ContactAddr__c billTo = new ccrz__E_ContactAddr__c();
            if(!String.isEmpty(soldToAccount[0].BillingStreet)){
                billTo.ccrz__AddressFirstline__c = soldToAccount[0].BillingStreet;
            }
            if(!String.isEmpty(soldToAccount[0].BillingCity)){
                billTo.ccrz__City__c = soldToAccount[0].BillingCity;
            }
            if(!String.isEmpty(soldToAccount[0].BillingState)){
                billTo.ccrz__State__c = soldToAccount[0].BillingState;
            }
            if(!String.isEmpty(soldToAccount[0].BillingCountry)){
                billTo.ccrz__Country__c = soldToAccount[0].BillingCountry;
            }
            if(!String.isEmpty(soldToAccount[0].BillingPostalCode)){
                billTo.ccrz__PostalCode__c = soldToAccount[0].BillingPostalCode;
            }
            if(!String.isEmpty(soldToAccount[0].EC_Account_Number__c)){
                billTo.EC_Account_Number__c = soldToAccount[0].EC_Account_Number__c;
            }
            insert billTo;
            toUpdateCart = true;
            cartOb[0].ccrz__BillTo__c = billTo.id;
        }

        if(cartOb[0].ccrz__ShipTo__c==null && shipToAccount.size()>0){
            ccrz__E_ContactAddr__c shipTo = new ccrz__E_ContactAddr__c();
            if(!String.isEmpty(shipToAccount[0].BillingStreet)){
                shipTo.ccrz__AddressFirstline__c = shipToAccount[0].BillingStreet;
            }
            if(!String.isEmpty(shipToAccount[0].BillingCity)){
                shipTo.ccrz__City__c = shipToAccount[0].BillingCity;
            }
            if(!String.isEmpty(shipToAccount[0].BillingState)){
                shipTo.ccrz__State__c = shipToAccount[0].BillingState;
            }
            if(!String.isEmpty(shipToAccount[0].BillingCountry)){
                shipTo.ccrz__Country__c = shipToAccount[0].BillingCountry;
            }
            if(!String.isEmpty(shipToAccount[0].BillingPostalCode)){
                shipTo.ccrz__PostalCode__c = shipToAccount[0].BillingPostalCode;
            }
            if(!String.isEmpty(shipToAccount[0].EC_Account_Number__c)){
                shipTo.EC_Account_Number__c = shipToAccount[0].EC_Account_Number__c;
            }
            if(!String.isEmpty(shipToAccount[0].Ship_To_Name__c)){
                shipTo.ShipTo_Name__c = shipToAccount[0].Ship_To_Name__c;
            }
            insert shipTo;
            toUpdateCart = true;
            cartOb[0].ccrz__ShipTo__c = shipTo.id;
        }        
        if(toUpdateCart){
            update cartOb;
        }
	}

	/***************************************************************************************************************************************
	Method Name : updateCartItemUOM
	Description : Creates the UOM fields for the cartItems and updates fields on CC CartItem
	Return type : Void
	**************************************************************************************************************************************/
    public static void updateCartItemUOM(String cartId) {
        Set<String> ProdIds = new Set<String>();
        List<ccrz__E_CartItem__c> cartItems = new List<ccrz__E_CartItem__c>();
        try {
            cartItems = [SELECT ccrz__Product__c,ccrz__Cart__c,ccrz__Cart__r.Id,Custom_Factor__c,Custom_PricingUOM__c,Custom_UnitPrice__c,Id,ccrz__Cart__r.ccrz__EncryptedId__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c=:cartId];
            if(!cartItems.isEmpty()) {
                for(ccrz__E_CartItem__c cartItem: cartItems) {
                    ProdIds.add(cartItem.ccrz__Product__c);
                }
                Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccAPIProduct.PRODUCTIDLIST => ProdIds,
                        ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true
                        };
                Map<String, Object> outputData = ccrz.ccAPIProduct.fetch(inputData);
                Map<String,Object> priceResult;
                Map<String,Object> priceEntries;
                if (outputData.get(ccrz.ccAPIProduct.PRODUCTPRICINGDATA) != null) {
                    Map<String, Object> outputPricingData = (Map<String, Object>)outputData.get(ccrz.ccAPIProduct.PRODUCTPRICINGDATA);                
                    ccrz.ccLog.log('outputPricingData--' + outputPricingData);
                    for(String productSFID : outputPricingData.keySet()){
                        priceResult = (Map<String,Object>)outputPricingData.get(productSFID); 
                        priceEntries = (Map<String,Object>)priceResult.get('productPrice');
                        ccrz.ccLog.log('priceResult--' + priceResult);
                        ccrz.ccLog.log('priceEntries--' + priceEntries);
                        for(ccrz__E_CartItem__c cartItem : cartItems) {
                            if(cartItem.ccrz__Product__c == productSFID) {
                                cartItem.Custom_Factor__c = Integer.Valueof(priceEntries.get('CustomFactor'));
                                cartItem.Custom_PricingUOM__c = String.ValueOf(priceEntries.get('CustomPricingUOM'));
                                cartItem.Custom_UnitPrice__c = (Decimal)priceEntries.get('CustomUnitPrice');
                            }
                        }
                    }
                    update cartItems;
                }
                ccrz.ccLog.log('Updated cartItems--' + cartItems);
            }
        } catch(Exception ex) {
             system.debug('Exception occured while Updating UOM on CartItems'+ ex.getMessage());
        }        
    }

	/***************************************************************************************************************************************
	Method Name : getTankNumbersbytmpltCodes
	Description : Get all tank numbers w.r.t delivery template codes.
	Return type : Void
	**************************************************************************************************************************************/
    global static Map<String,Set<Tank_Detail__c>> getTankNumbersbytmpltCodes(Set<String> delivryTmpltCodes ) {
        Map<String,Set<Tank_Detail__c>> materialDelTemplMap = new Map<String,Set<Tank_Detail__c>>();
        List<Tank_Detail__c> Tanks = new List<Tank_Detail__c>();
        Tank_Detail__c dropoff = new Tank_Detail__c();
            String effectiveAccountID = ccrz.cc_CallContext.effAccountId;
            Tanks = [SELECT Active__c,Delivery_Template_Code__c,Material_Delivery_Code__c,Material_Description__c,Tank_Number__c,Unloading_Point__c,Unloading_Point__r.Id,Unloading_Point__r.Primary_Unloading_Point__c,
                     Unloading_Point__r.ccrz__AddressFirstline__c,Account__c,Delivery_Priority__c FROM Tank_Detail__c where Material_Delivery_Code__c IN :delivryTmpltCodes AND Account__c =:effectiveAccountID AND Active__c = True];
            dropoff = [Select Active__c,Delivery_Template_Code__c,Material_Delivery_Code__c,Material_Description__c,Tank_Number__c,Unloading_Point__c,Unloading_Point__r.Id,Unloading_Point__r.Primary_Unloading_Point__c,
                    Unloading_Point__r.ccrz__AddressFirstline__c,Account__c,Delivery_Priority__c FROM Tank_Detail__c where Tank_Id__c =:System.Label.DropOff AND Active__c = True Limit 1];
        ccrz.cclog.log('Tank--->' + Tanks);
        if(!Tanks.isEmpty()) {
            for(Tank_Detail__c tank : Tanks){
                if(materialDelTemplMap.containsKey(tank.Material_Delivery_Code__c )){
                    materialDelTemplMap.get(tank.Material_Delivery_Code__c ).add(tank);
                }else{
                    materialDelTemplMap.put(tank.Material_Delivery_Code__c ,new Set<Tank_Detail__c>{tank});
                }
                if(tank.Delivery_Priority__c == System.Label.EC_DeliveryPriority_7 ){
                    materialDelTemplMap.get(tank.Material_Delivery_Code__c ).add(dropoff);
                }
            }
        }
		ccrz.cclog.log('Tanks--->' + Tanks);         
        return materialDelTemplMap;
    }
/***************************************************************************************************************************************
Method Name : getECUnloadingPoints
Description : queries the unloading points for the account.
Return type : ccrz.cc_RemoteActionResult
*************************************************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getECUnloadingPoints(final ccrz.cc_RemoteActionContext ctx, string effecAcntID) {
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        try {
            Map<String,Object> responseMap = new Map<String,Object>();
            List<ccrz__E_ContactAddr__c> unloadingPoints = new List<ccrz__E_ContactAddr__c>();
            Account Acc = [Select Id,EC_Account_Number__c,EC_Billing_Account_Number__c from Account where id =:effecAcntID limit 1];
            if(Acc != null) {
                String AccountNumber = Acc.EC_Billing_Account_Number__c;
                if(!String.isBlank(AccountNumber)) {
                    unloadingPoints = [SELECT ccrz__AddressFirstline__c,ccrz__FirstName__c,Id,Name,EC_Account_Number__c,ccrz__CompanyName__c, Primary_Unloading_Point__c,Type__c,Active__c FROM ccrz__E_ContactAddr__c where EC_Account_Number__c =: AccountNumber AND EC_Account_Number__c!=null AND ccrz__CompanyName__c!=null AND Active__c = True AND Type__c='Unloading Point'];
                }
            }
            Map<String,UOM_Quantity_Mapping__mdt> uomRecordMap = EC_CartDetailController.getMinMaxQtyMessage();
            responseMap.put('uomRecordMap',uomRecordMap);
            responseMap.put('unloadingPoints',unloadingPoints);
            res.data=responseMap;
            res.success = true;
        } catch(Exception ex) {
            system.debug('Exception occured on fetching Unloading Points'+ ex.getMessage());
        }
        ccrz.cclog.log('getECUnloadingPoints: ' , + res.data);
        return res;
    }   

    /***************************************************************************************************************************************
	Method Name : getMinMaxQtyMessage
	Description : Get min max quantity.
	Return type : Map<String,UOM_Quantity_Mapping__mdt>
	**************************************************************************************************************************************/
    global static Map<String,UOM_Quantity_Mapping__mdt> getMinMaxQtyMessage() {
        Map<String,UOM_Quantity_Mapping__mdt> uomWrapperMap = new Map<String,UOM_Quantity_Mapping__mdt>();        
        List<AsyncApexJob> apexJobs = new List<AsyncApexJob>();
        apexJobs = [SELECT ApexClass.Name,Status FROM AsyncApexJob WHERE ApexClass.Name Like 'ccProductIndex%' AND Status = 'Processing'];
        if(apexJobs.isEmpty()){
			List<UOM_Quantity_Mapping__mdt> uomQtyList = new List<UOM_Quantity_Mapping__mdt>();               
            uomQtyList =  [Select Minimum_Quantity__c,Maximum_Quantity__c,Minimum_quantity_message__c,Maximum_quantity_message__c,UOM__c,DeveloperName from UOM_Quantity_Mapping__mdt Limit 100];
            if(!uomQtyList.isEmpty()){
                for(UOM_Quantity_Mapping__mdt metaRecord : uomQtyList){
					uomWrapperMap.put(metaRecord.DeveloperName,metaRecord);
                }
            }
        }
        return uomWrapperMap;
    }  
}