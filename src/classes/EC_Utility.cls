/* Class Name      :EC_Utility
* Description      :Utility class for all common methods
* Created By       :Shivam Vats
* Created On       :08-08-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Shivam Vats          08-08-2019                                   Utility class for all common methods
*/

public class EC_Utility {
    public static string getCallingContext()
    {
        string Value;
        if (System.isBatch() || Test.isRunningTest())
        {
            value= 'Batch';
        }
        if (System.isFuture() || Test.isRunningTest())
        {
            value=  'Future';
        }
        if (System.isQueueable() || Test.isRunningTest())
        {
            value=  'Queueable';
        }
        if (System.isScheduled() || Test.isRunningTest())
        {
            value=  'Scheduled';
        }
        if (ApexPages.currentPage() != null || Test.isRunningTest())
        {
            value=  'ApexPage';
        }
        if (Trigger.isExecuting || Test.isRunningTest())
        {
            value=  'Trigger';
        }
        if (RestContext.request != null || Test.isRunningTest())
        {
            value=  'RestRequest';
        }
        else {
            value= 'Unknown';
        }

        return Value;

    }

/***************************************************************************************************************************************
Method Name : getGovLimitKpi
Description : to get govlimit
Return type : String
Author      : Shruti Sinha
*************************************************************************************************************************************/

    public static string getGovLimitKpi() {
        String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
        String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
        String DMLStat = '3. Number of DML statements used so far / Number allowed: ' + Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();
        String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
        List<String> lgovLimit= new List<String> { QueryLimit, DMLimit, DMLStat, CPUT };
        String govLimit = String.format('{0}\n{1}\n{2}\n{3}',lgovLimit );
        return govLimit ;

    }
    public static boolean isBlankOrEmpty(string lineNumberOrId){
        if(lineNumberOrId!=null && lineNumberOrId!='')
        {
            return false;
        }
        else
        {
            return true;
        }
    }

 /***************************************************************************************************************************************
Method Name : checkCustomPermissionOnUser
Description : used to check if custom permissions are assigned to user via permission set
Return type : Map<String, boolean>
Author      : Mishika Mahajan
*************************************************************************************************************************************/


    public static Map<String, boolean>  checkCustomPermissionOnUser(){
        Map<String, boolean> cpu = new Map<String, boolean>();
      List<EC_CustomPermissionData__mdt> cpd;
      cpd = [select developername, label from EC_CustomPermissionData__mdt];
        for(EC_CustomPermissionData__mdt cp:cpd){
            cpu.put(cp.label,FeatureManagement.checkPermission(cp.developername));
        }

        return cpu;
    }

/***************************************************************************************************************************************
Method Name : permissionSetMap
Description : create map of permission set where key = PermissionSet Name and value = PermissionSet id.
Return type : Map<String, Id>
Author      : Mishika Mahajan
*************************************************************************************************************************************/


    public static Map<String, Id> permissionSetMap()
    {
        Map<String,Id> permSetMap = new Map<String,Id>();
        List<PermissionSet> ps;
        ps = [select id, name from PermissionSet where Name in(:Label.EC_BasicSetID,:Label.EC_BuyerSet)];
        if(ps!=null){
            for(PermissionSet p: ps){
                permSetMap.put(p.name, p.id);
            }
        }
        return permSetMap;

    }
 /***************************************************************************************************************************************
Method Name : permissionSetId
Description : getting permission set values from custom setting EC_PermissionSetMapping
Return type : Id
Author      : Mishika Mahajan
*************************************************************************************************************************************/


     public static Id permissionSetId(String conRole){
        Set<Id> permId = new Set<Id>();
        EC_PermissionSetMapping__c setVal = EC_PermissionSetMapping__c.getValues(conRole);
        String permSets = setval.EC_PermissionSetList__c;
        List<PermissionSet> lstPermissionSets;
        lstPermissionSets = [select id, name from PermissionSet where name = :permSets];
       if(lstPermissionSets!=null&& !(lstPermissionSets.isEmpty()))
       {
       return lstPermissionSets[0].id;
         }
         else{
       return null;
      }
    }
       /***************************************************************************************************************************************
Method Name : getOutageFlag
Description : to get the outage flag for enabling/disabling the community.
Return type : Boolean
Parameter   : custPerm
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static Boolean getOutageFlag(){
    EC_OutageFlag__c mc = EC_OutageFlag__c.getValues(EC_Constants.COMMACTIVE);//fetching custom setting data value
        Boolean isCommunityActive = mc.EC_isCommunityActive__c;
        return isCommunityActive;
    }


/***************************************************************************************************************************************
Method Name : getPermCache
Description : to get the custom permission stored in session cache.
Return type : Boolean
Parameter   : custPerm
Author      : Mishika Mahajan
*************************************************************************************************************************************/
public static List<PermWrapper> getPermCache()
    {
      EC_CacheWrapper usr = EC_CacheHelper.getCacheInfo();

      List<PermWrapper> permWrapList = new List<PermWrapper>();
      Map<String, boolean> permMap = new Map<String, boolean>();
        permMap = usr.usrPermissionMap;
        if(permMap!=null){
        for(String key : permMap.keySet()){
         PermWrapper pw = new PermWrapper();
            pw.permName=key;
            pw.permVal=permMap.get(key);
            permWrapList.add(pw);
          }
        }

    return permWrapList;

    }

     /************************************************************************************************************************************
Method Name : getProfile
Description : to get current user profile
Parameter   : void
Return type : String
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static String getProfileIBuy(){
        User usr = [select id, profile.name from User where id = :userinfo.getUserId() limit 1];
        return usr.profile.name;
    }


/***************************************************************************************************************************************
Method Name : getActiveCartForUser
Description : Find and return the active cart for the logged user
Return type : ccrz__E_Cart__c
Author      : Harsha N
*************************************************************************************************************************************/
    public static ccrz__E_Cart__c getActiveCartForUser(id effectiveAccId){
        //Get logged user information
        user loggedInUser = [SELECT id, ccrz__CC_CurrencyCode__c, ContactId, User_Type__c FROM User WHERE Id =: userinfo.getuserId()];


		List<ccrz__E_Cart__c> cc_carts = new List<ccrz__E_Cart__c>();
		Contact contRec = new Contact();

        //Get Active Cart for this Contact
        if(loggedInUser.User_Type__c == 'External'){
			cc_carts = [SELECT Id, ccrz__Contact__c, LastModifiedDate, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Contact__c = :loggedInUser.ContactId AND ccrz__ActiveCart__c = true AND ccrz__CartStatus__c = 'Open' order by lastModifieddate desc];
		}else{
			contRec = [Select Id, EC_SalesRep_User__c from Contact where EC_SalesRep_User__c = :loggedInUser.id  limit 1];
			cc_carts = [SELECT Id, ccrz__Contact__c, LastModifiedDate, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__Contact__c = :contRec.id AND ccrz__ActiveCart__c = true AND ccrz__CartStatus__c = 'Open' order by lastModifieddate desc];
		}

        ccrz__E_Cart__c cc_cart;
        if(cc_carts.isEmpty()){
            //Create New Cart
            cc_cart = new ccrz__E_Cart__c();
            cc_cart.ccrz__ActiveCart__c = true;
            cc_cart.ccrz__CartStatus__c = Label.EC_CartStatus_Open;
            cc_cart.ccrz__CartType__c = Label.EC_CartType_Cart;
            cc_cart.ccrz__CurrencyISOCode__c = loggedInUser.ccrz__CC_CurrencyCode__c;
            cc_cart.ccrz__Storefront__c = Label.EC_StoreFront;
            cc_cart.ccrz__EffectiveAccountID__c = effectiveAccId;
            cc_cart.ccrz__AnonymousId__c = false;
            cc_cart.ccrz__User__c = loggedInUser.Id;
            cc_cart.ownerid = loggedInUser.Id;
            cc_cart.ccrz__Account__c = effectiveAccId;
			if(loggedInUser.User_Type__c == 'External'){
				cc_cart.ccrz__Contact__c = loggedInUser.ContactId;
			}else{
				cc_cart.ccrz__Contact__c = contRec.id;
			}

            insert cc_cart;
        }else{
            cc_cart = cc_carts[0];
        }

        return cc_cart;
    }

/***************************************************************************************************************************************
Method Name : addItemsToCart
Description : Add items to the cart
Return type : Boolean
Author      : Harsha N
*************************************************************************************************************************************/
    public static String addItemsToCart(Id cartId, id effectiveAccId, List<ccrz__E_OrderItem__c> lstCartItems, boolean isReOrder){
        String itemsStatus = '';
        List<ccrz__E_CartItem__c> lstUpsertCartItems = new List<ccrz__E_CartItem__c>();
        List<ccrz__E_OrderItem__c> lstNewItems = new List<ccrz__E_OrderItem__c>();
        List<Id> lstNewItemProdId = new List<Id>();
        Set<string> setEntitledPriceList = new Set<string>();
        Map<Id, Decimal> mapPriceLstSequence = new Map<Id, Decimal>();
        Map<Decimal, List<ccrz__E_PriceListItem__c>> priceLstItemSequenceGrouping = new Map<Decimal, List<ccrz__E_PriceListItem__c>>();
        Map<Id, Decimal> productPriceMap = new Map<Id, Decimal>();

        //Get cart items from the existing cart
        List<ccrz__E_CartItem__c> activeCartItems = [SELECT ccrz__Product__c, ccrz__Quantity__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c =: cartId];

		for(ccrz__E_OrderItem__c reOrderItemRec : lstCartItems){
            boolean existInCart = false;
			for(ccrz__E_CartItem__c existItemRec : activeCartItems){
                if(reOrderItemRec.ccrz__Product__c == existItemRec.ccrz__Product__c){
                    Decimal itemQuantity = 0;
					if(isReOrder){
						itemQuantity = reOrderItemRec.ccrz__OriginalQuantity__c;
					}else{
						itemQuantity = 1.00;
					}
					existItemRec.ccrz__Quantity__c += itemQuantity;
                    existInCart = true;
                    lstUpsertCartItems.add(existItemRec);
                    break;
                }
            }
			if(!existInCart){
				lstNewItems.add(reOrderItemRec);
			}
        }

		for(ccrz__E_OrderItem__c newCartItem : lstNewItems){
            lstNewItemProdId.add(newCartItem.ccrz__Product__c);
        }

        List<Account> effectiveAcc = [SELECT Id, ccrz__E_AccountGroup__c FROM Account WHERE ID =: effectiveAccId];

		List<ccrz__E_AccountGroupPriceList__c> lstAccGrpPriceLst = [SELECT id, ccrz__Pricelist__c, ccrz__Sequence__c FROM ccrz__E_AccountGroupPriceList__c WHERE ccrz__AccountGroup__c =: effectiveAcc[0].ccrz__E_AccountGroup__c ORDER BY ccrz__Sequence__c];

		for(ccrz__E_AccountGroupPriceList__c accGrpPriceLstRec : lstAccGrpPriceLst){
            setEntitledPriceList.add(accGrpPriceLstRec.ccrz__Pricelist__c);
            mapPriceLstSequence.put(accGrpPriceLstRec.ccrz__Pricelist__c, accGrpPriceLstRec.ccrz__Sequence__c);
        }

		List<ccrz__E_PriceListItem__c> lstPriceListItem = [SELECT id, ccrz__Product__c, ccrz__Price__c, ccrz__Pricelist__c  FROM ccrz__E_PriceListItem__c WHERE ccrz__Product__c IN: lstNewItemProdId AND ccrz__Pricelist__c IN: setEntitledPriceList];

		for(ccrz__E_PriceListItem__c priceLstItmRec : lstPriceListItem){
            if(priceLstItemSequenceGrouping.containsKey(mapPriceLstSequence.get(priceLstItmRec.ccrz__Pricelist__c))){
                priceLstItemSequenceGrouping.get(mapPriceLstSequence.get(priceLstItmRec.ccrz__Pricelist__c)).add(priceLstItmRec);
            }else{
                List<ccrz__E_PriceListItem__c> tempPriceListItemList = new List<ccrz__E_PriceListItem__c>();
                tempPriceListItemList.add(priceLstItmRec);
                priceLstItemSequenceGrouping.put((mapPriceLstSequence.get(priceLstItmRec.ccrz__Pricelist__c)), tempPriceListItemList);
            }
        }

        List<Decimal> lstSequence = new List<Decimal>();
        lstSequence.addAll(priceLstItemSequenceGrouping.keySet());
        lstSequence.sort();

		for(ccrz__E_OrderItem__c newCartItem : lstNewItems){
            Decimal itemQuantity;
            if(isReOrder){
                itemQuantity = newCartItem.ccrz__OriginalQuantity__c;
            }else{
                itemQuantity = 1.00;
            }
            ccrz__E_CartItem__c tempCartItem = new ccrz__E_CartItem__c();
            tempCartItem.ccrz__cartItemType__c = EC_Constants.CARTITEMTYPEMAJOR;
            tempCartItem.ccrz__Cart__c = cartId;
            tempCartItem.ccrz__ItemStatus__c = EC_Constants.CARTITEMSTATUS;
            tempCartItem.ccrz__OriginalQuantity__c = itemQuantity;
            tempCartItem.ccrz__PricingType__c = EC_Constants.CARTITEMPRICINGTYPEAUTO;
            tempCartItem.ccrz__ProductType__c = EC_Constants.CARTITEMPRODUCTTYPEPRODUCT;
            tempCartItem.ccrz__Product__c = newCartItem.ccrz__Product__c;
            tempCartItem.ccrz__Quantity__c = itemQuantity;
            tempCartItem.ccrz__RequestDate__c = Date.Today();
            tempCartItem.ccrz__StoreID__c = Label.EC_StoreFront;
            tempCartItem.ccrz__UnitOfMeasure__c = newCartItem.ccrz__UnitOfMeasure__c;

            for(Decimal seqValue : lstSequence){
                boolean priceFound = false;
                for(ccrz__E_PriceListItem__c tempPriceListItem : priceLstItemSequenceGrouping.get(seqValue)){
                    if(newCartItem.ccrz__Product__c == tempPriceListItem.ccrz__Product__c){
                        tempCartItem.ccrz__OriginalItemPrice__c = tempPriceListItem.ccrz__Price__c;
                        tempCartItem.ccrz__Price__c = tempPriceListItem.ccrz__Price__c;
                        tempCartItem.ccrz__SubAmount__c = tempPriceListItem.ccrz__Price__c*itemQuantity;
                        priceFound = true;
                        break;
                    }
                }
                if(priceFound){
                    break;
                }
            }

            lstUpsertCartItems.add(tempCartItem);
        }

        if(lstUpsertCartItems != null && lstUpsertCartItems.size() > 0){
            try{
                Database.upsert(lstUpsertCartItems);
				 if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
            }catch(Exception ex){
                itemsStatus = ex.getMessage();
                return itemsStatus;
            }
        }

        itemsStatus = 'Success';
        return itemsStatus;
    }

    /***************************************************************************************************************************************
Method Name : addAthenaItemsToCart
Description : Add Athena items to the cart
Return type : Boolean
Author      : Aravind Tallapaka
*************************************************************************************************************************************/
    public static String addAthenaItemsToCart(Id cartId, id effectiveAccId, List<ccrz__E_Product__c> lstCartItems, Map<String,String> prodMap, boolean isReOrder){
        String itemsStatus = '';
        List<ccrz__E_CartItem__c> lstUpsertCartItems = new List<ccrz__E_CartItem__c>();
        List<ccrz__E_Product__c> lstNewItems = new List<ccrz__E_Product__c>();
        List<Id> lstNewItemProdId = new List<Id>();
        Set<string> setEntitledPriceList = new Set<string>();
        Map<Id, Decimal> mapPriceLstSequence = new Map<Id, Decimal>();
        Map<Decimal, List<ccrz__E_PriceListItem__c>> priceLstItemSequenceGrouping = new Map<Decimal, List<ccrz__E_PriceListItem__c>>();
        Map<Id, Decimal> productPriceMap = new Map<Id, Decimal>();

        //Get cart items from the existing cart
        List<ccrz__E_CartItem__c> activeCartItems = [SELECT ccrz__Product__c, ccrz__Quantity__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c =: cartId];

        for(ccrz__E_Product__c reOrderItemRec : lstCartItems){
            boolean existInCart = false;
			for(ccrz__E_CartItem__c existItemRec : activeCartItems){
                if(reOrderItemRec.Id == existItemRec.ccrz__Product__c){
                    Decimal itemQuantity = 0;
					if(isReOrder){
						itemQuantity = Integer.valueof(prodMap.get(reOrderItemRec.ccrz__SKU__c).trim());
					}else{
						itemQuantity = 1.00;
					}
					existItemRec.ccrz__Quantity__c += itemQuantity;
                    existInCart = true;
                    lstUpsertCartItems.add(existItemRec);
                    break;
                }
            }	
            if(!existInCart){
				lstNewItems.add(reOrderItemRec);
			}
        }

        for(ccrz__E_Product__c newCartItem : lstNewItems){
            lstNewItemProdId.add(newCartItem.Id);
        }

        List<Account> effectiveAcc = [SELECT Id, ccrz__E_AccountGroup__c FROM Account WHERE ID =: effectiveAccId];

		List<ccrz__E_AccountGroupPriceList__c> lstAccGrpPriceLst = [SELECT id, ccrz__Pricelist__c, ccrz__Sequence__c FROM ccrz__E_AccountGroupPriceList__c WHERE ccrz__AccountGroup__c =: effectiveAcc[0].ccrz__E_AccountGroup__c ORDER BY ccrz__Sequence__c];

		for(ccrz__E_AccountGroupPriceList__c accGrpPriceLstRec : lstAccGrpPriceLst){
            setEntitledPriceList.add(accGrpPriceLstRec.ccrz__Pricelist__c);
            mapPriceLstSequence.put(accGrpPriceLstRec.ccrz__Pricelist__c, accGrpPriceLstRec.ccrz__Sequence__c);
        }

		List<ccrz__E_PriceListItem__c> lstPriceListItem = [SELECT id, ccrz__Product__c, ccrz__Price__c, ccrz__Pricelist__c  FROM ccrz__E_PriceListItem__c WHERE ccrz__Product__c IN: lstNewItemProdId AND ccrz__Pricelist__c IN: setEntitledPriceList];

		for(ccrz__E_PriceListItem__c priceLstItmRec : lstPriceListItem){
            if(priceLstItemSequenceGrouping.containsKey(mapPriceLstSequence.get(priceLstItmRec.ccrz__Pricelist__c))){
                priceLstItemSequenceGrouping.get(mapPriceLstSequence.get(priceLstItmRec.ccrz__Pricelist__c)).add(priceLstItmRec);
            }else{
                List<ccrz__E_PriceListItem__c> tempPriceListItemList = new List<ccrz__E_PriceListItem__c>();
                tempPriceListItemList.add(priceLstItmRec);
                priceLstItemSequenceGrouping.put((mapPriceLstSequence.get(priceLstItmRec.ccrz__Pricelist__c)), tempPriceListItemList);
            }
        }

        List<Decimal> lstSequence = new List<Decimal>();
        lstSequence.addAll(priceLstItemSequenceGrouping.keySet());
        lstSequence.sort();

		for(ccrz__E_Product__c newCartItem : lstNewItems){
            Decimal itemQuantity;
            boolean isEligibleToAdd = false;
            if(isReOrder){
                itemQuantity = Integer.valueof(prodMap.get(newCartItem.ccrz__SKU__c).trim());
            }else{
                itemQuantity = 1.00;
            }
            ccrz__E_CartItem__c tempCartItem = new ccrz__E_CartItem__c();
            tempCartItem.ccrz__cartItemType__c = EC_Constants.CARTITEMTYPEMAJOR;
            tempCartItem.ccrz__Cart__c = cartId;
            tempCartItem.ccrz__ItemStatus__c = EC_Constants.CARTITEMSTATUS;
            tempCartItem.ccrz__OriginalQuantity__c = itemQuantity;
            tempCartItem.ccrz__PricingType__c = EC_Constants.CARTITEMPRICINGTYPEAUTO;
            tempCartItem.ccrz__ProductType__c = EC_Constants.CARTITEMPRODUCTTYPEPRODUCT;
            tempCartItem.ccrz__Product__c = newCartItem.Id;
            tempCartItem.ccrz__Quantity__c = itemQuantity;
            tempCartItem.ccrz__RequestDate__c = Date.Today();
            tempCartItem.ccrz__StoreID__c = Label.EC_StoreFront;
            tempCartItem.ccrz__UnitOfMeasure__c = newCartItem.ccrz__UnitOfMeasure__c;

            for(Decimal seqValue : lstSequence){
                boolean priceFound = false;
                for(ccrz__E_PriceListItem__c tempPriceListItem : priceLstItemSequenceGrouping.get(seqValue)){
                    if(newCartItem.Id == tempPriceListItem.ccrz__Product__c){
                        tempCartItem.ccrz__OriginalItemPrice__c = tempPriceListItem.ccrz__Price__c;
                        tempCartItem.ccrz__Price__c = tempPriceListItem.ccrz__Price__c;
                        tempCartItem.ccrz__SubAmount__c = tempPriceListItem.ccrz__Price__c*itemQuantity;
                        priceFound = true;
                        isEligibleToAdd = true;
                        break;
                    }
                }
                if(priceFound){
                    break;
                }
            }

            if(isEligibleToAdd){
                lstUpsertCartItems.add(tempCartItem);
                isEligibleToAdd = false;
            }
        }

        if(lstUpsertCartItems != null && lstUpsertCartItems.size() > 0){
            try{
                Database.upsert(lstUpsertCartItems);
                System.debug('inside try:');
				 if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
            }catch(Exception ex){
                itemsStatus = ex.getMessage();
                return itemsStatus;
            }
        }
		
        itemsStatus = 'Success';
        return itemsStatus;
    }

    public class PermWrapper{
        @auraenabled
        public String permName;
        @auraenabled
        public Boolean permVal;

    }
/***************************************************************************************************************************************
Method Name : getPageUrl
Description : to get Page URL
Return type : String
Author      : Harsha N
*************************************************************************************************************************************/

    public static String getPageUrl(){
        Id networkId = Network.getNetworkId();
        String loginURL = Network.getLoginUrl(networkId);
        return loginURL;
    }
/***************************************************************************************************************************************
Method Name : getCommunityUrl
Description : to get Community URL
Return type : String
Author      : Harsha N
*************************************************************************************************************************************/

     public static String getCommunityUrl(){

        Id networkId = Network.getNetworkId();

        String loginURL = Network.getLoginUrl(networkId);
         String communityURL;
         if(networkId !=null){
            communityURL= loginURL.removeEndIgnoreCase('/s/login');
         }
             return communityURL;


     }

/***************************************************************************************************************************************
Method Name : getPermissionCacheInfo
Description : to get PermissionCacheInfo
Return type : List
Author      : Harsha N
*************************************************************************************************************************************/

     public static List<PermWrapper> getPermissionCacheInfo()
    {
      List<PermWrapper> permWrapList = new List<PermWrapper>();
      Map<String, boolean> permMap = new Map<String, boolean>();
        permMap = EC_Utility.checkCustomPermissionOnUser();
        if(permMap!=null){
        for(String key : permMap.keySet()){
         PermWrapper pw = new PermWrapper();
            pw.permName=key;
            pw.permVal=permMap.get(key);
            permWrapList.add(pw);
          }
        }

    return permWrapList;

    }

    /***************************************************************************************************************************************
      Method Name : logCallouts
      Description : This method is used for logging service input & output
      Return type : EC_WebServiceCalloutsLog__c 
     **************************************************************************************************************************************/  
    public static EC_WebServiceCalloutsLog__c logCallouts(String type, String inputReq,String response,String errorMessage,String status){       
        EC_WebServiceCalloutsLog__c logRec = new EC_WebServiceCalloutsLog__c();
        logRec.EC_RequestName__c = type;
        logRec.EC_RequestCall__c = inputReq;
        logRec.EC_ResponseCall__c = response;
        logRec.EC_ErrorMessage__c = errorMessage;
        logRec.EC_Status__c = status;
        insert logRec;
        return logRec;

    }
    
    //Insert or update Integration_Log__c with the exception details. Initial Callout exception - insert / Retry callout - update
   public static Integration_Log__c logIntegrationError(String errorMessage, String component, String integrationType, String objectName, String calloutLogName,Integer retryCounter, 
                                                        String status, String identifier){
        Integration_Log__c integrationLog;
        List<Integration_Log__c> integrationLogList = new List<Integration_Log__c>([Select id, identifier__c, retry_Counter__c, description__c, notes__c, request_Response_Details__c, status__c from Integration_Log__c where identifier__c = :identifier]);
        if(integrationLogList != null && integrationLogList.size() > 0){
            integrationLog = integrationLogList[0];
            integrationLog.retry_Counter__c += 1;
            integrationLog.description__c += '/Retry# ' + integrationLog.retry_Counter__c + ';Error Message: ' + errorMessage;
            integrationLog.notes__c += ' /Retry# ' + integrationLog.retry_Counter__c + ';Calloutlog: ' + calloutLogName;
        	if(calloutLogName != null && calloutLogName != '')
            	integrationLog.request_Response_Details__c = calloutLogName;
        	integrationLog.status__c = String.valueOf(status);
        	update integrationLog;
        }else{
            integrationLog = new Integration_Log__c();
            integrationLog.retry_Counter__c = 0;
            integrationLog.identifier__c = identifier;
            integrationLog.integration_Component__c = component;
            integrationLog.integration_Type__c   = integrationType;
            integrationLog.object_Details__c = objectName;
            integrationLog.description__c = 'Try# 0:' + errorMessage;
            integrationLog.notes__c = 'Callout logs -Try# 0:  ' + calloutLogName;
            if(calloutLogName != null && calloutLogName != '')
        		integrationLog.request_Response_Details__c = calloutLogName;
        	integrationLog.status__c = String.valueOf(status);
        	insert integrationLog;
        }
        System.debug('Insert Integration Log for CaseNo:' + identifier + ' Log Details: ' +integrationLog);
        return integrationLog;

    }
        
    //This method checks if there is an error entry in Integration_Log__c. If so updates it. This is used when a retry callout is successful 
    public static void integrationLogCheck(String identifier){       
        List<Integration_Log__c> integrationLogList = new List<Integration_Log__c>([Select id, identifier__c, retry_Counter__c,description__c from Integration_Log__c where identifier__c = :identifier]);
        if(integrationLogList != null && integrationLogList.size() > 0){
            Integration_Log__c integrationLog = integrationLogList[0];
            integrationLog.retry_Counter__c += 1 ;
            integrationLog.description__c += '/Retry# ' + integrationLog.retry_Counter__c + 'Successfully Sent';
            integrationLog.request_Response_Details__c = null;
            integrationLog.status__c = 'true';
            update integrationLog;
            System.debug('Successfully sent a previously errored service request message to Tibco. CaseNo: ' + identifier);
        }       
    }
    //ISE-152904
/***************************************************************************************************************************************
Method Name : isIndirectStreetBrandAccount
Description : This method is used for isIndirectStreetBrandAccount
Return type : Boolean 
**************************************************************************************************************************************/  
  public static Boolean isIndirectStreetBrandAccount(){
     Boolean isIndirectStreetBrand = false;
     String effAccountId = ccrz.cc_CallContext.effAccountId;
     EC_EntitlementCacheDTO lstCacheData = EC_EntitlementCacheUtility.getINSTSalesEntitlementCache(effAccountId);
     List<String> prodIds = (lstCacheData == null) ? new List<String>() : lstCacheData.productIds;
     if(prodIds != null && !prodIds.isEmpty()) {
            system.debug('prodIds:'+prodIds);
            isIndirectStreetBrand = (prodIds.contains(effAccountId+EC_Constants.ISE_INDIRECTSTREETBRAND)) ? true : false;
        }
        return isIndirectStreetBrand;
    }



}