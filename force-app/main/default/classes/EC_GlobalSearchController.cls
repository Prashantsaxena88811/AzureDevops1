//EC_GlobalSearchController
//This is the controller class for homepage order processing
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Harsha N    11th July, 2019     The functionality to handle the Global search
//
public without sharing class EC_GlobalSearchController{

/***************************************************************************************************************************************
	Method Name : getSuggestionResultsAura
	Description : Explicit AuraEnabled method for abstraction
	Return type : List<string> list of suggestions as a searchList
	Author      : Harsha
************************************************************************************************************************************/

	@AuraEnabled
    public static List<string> getSuggestionResultsAura(string searchText){
        return getSuggestionResults(searchText);
    }

/***************************************************************************************************************************************
	Method Name : getProdSearchResultsAura
	Description : Explicit AuraEnabled method for abstraction
	Return type : List<prodBean> list of Products details searched
	Author      : Harsha
************************************************************************************************************************************/

	@AuraEnabled
    public static List<prodBean> getProdSearchResultsAura(string searchText){
        return getProdSearchResults(searchText);
    }

/***************************************************************************************************************************************
	Method Name : getOrderSearchResultsAura
	Description : Explicit AuraEnabled method for abstraction
	Return type : List<orderBean> list of Orders Details searched
	Author      : Harsha
************************************************************************************************************************************/

    @AuraEnabled
    public static List<orderBean> getOrderSearchResultsAura(string searchText){
        return getOrderSearchResults(searchText);
    }

/***************************************************************************************************************************************
	Method Name : getDocsSearchResultsAura
	Description : Explicit AuraEnabled method for abstraction
	Return type : List<sdsDocBeanGrouped> list of Documents Details searched
	Author      : Harsha
************************************************************************************************************************************/

    @AuraEnabled
    public static List<sdsDocBeanGrouped> getDocsSearchResultsAura(string searchText){
        return getDocsSearchResults(searchText);
    }

    @AuraEnabled
    public static Map<String, List<prodBean>> getQuickListAura(string searchText){
        return getQuickList(searchText);
    }

/***************************************************************************************************************************************
	Method Name : getSuggestionResults
	Description : To get suggestion on TypeAhead on global search input box case of type access request
	Return type : List<string> list of suggestions as a searchList
	Author      : Harsha
************************************************************************************************************************************/

    private static List<string> getSuggestionResults(string searchText){
        EC_QueryUtility queryObj = new EC_QueryUtility();
         EC_CacheWrapper user = EC_CacheHelper.getCacheInfo();
        set<string> setEntitledPriceList = new set<string>();
        List<string> lstEntitledPriceList = new List<string>();
        for(List<string> tempPriceLstId : user.accGrpPriceListMap.values()){
            lstEntitledPriceList.addAll(tempPriceLstId);
        }
		if(lstEntitledPriceList!=null && !lstEntitledPriceList.isEmpty()){
		  setEntitledPriceList.addAll(lstEntitledPriceList);
		}

        searchText = searchText.replace('+',' ');

		//fetch priceListItems

        List<ccrz__E_PriceListItem__c> lstProdRecs = EC_QueryUtility.getPriceListItemsAutoSuggest(setEntitledPriceList,searchText);


        Set<string> suggestionSet = new Set <string>();
        List<string> suggestionList = new List <string>();

        integer recCount = 0;
        for(ccrz__E_PriceListItem__c prodRec : lstProdRecs){
         // fetch only 10 suggestion results
            if(recCount < 10){
                if(!suggestionSet.contains(prodRec.ccrz__Product__r.Name)){
                    suggestionSet.add(prodRec.ccrz__Product__r.Name);
                    recCount++;
                }
            }else{
                break;
            }
        }
        suggestionList.addAll(suggestionSet);

        return suggestionList;
    }

/***************************************************************************************************************************************
	Method Name : getProdSearchResults
	Description : Search the list of Products based on the search text
	Return type : List<prodBean> which is a wrapper of product details
	Author      : Harsha
************************************************************************************************************************************/

    private static List<prodBean> getProdSearchResults(string searchText){
        EC_QueryUtility queryObj = new EC_QueryUtility();
        EC_CacheWrapper user = EC_CacheHelper.getCacheInfo();

        set<string> setEntitledPriceList = new set<string>();
        List<string> lstEntitledPriceList = new List<string>();
        for(List<string> tempPriceLstId : user.accGrpPriceListMap.values()){
            lstEntitledPriceList.addAll(tempPriceLstId);
        }
        setEntitledPriceList.addAll(lstEntitledPriceList);

        List<prodBean> prodBeanList = new List <prodBean>();

        searchText = searchText.replace('+',' ');

       // fetch priceListItems
       List<ccrz__E_PriceListItem__c>  lstPricelstItem = EC_QueryUtility.getPriceListItems(setEntitledPriceList,searchText);

        List<ccrz__E_PriceListItem__c> recentRecs = new List<ccrz__E_PriceListItem__c>();
        Map<String, ccrz__E_PriceListItem__c> recentRecMap = new Map<String, ccrz__E_PriceListItem__c>();
        List<ccrz__E_ProductMedia__c> lstProductMedia = new List<ccrz__E_ProductMedia__c>();
        Map<String, String> prdImgUrlMap = new Map<String, String>();

		//creating a map of unique products based on their most recent purchase
        for(ccrz__E_PriceListItem__c priceLstItmRec : lstPricelstItem){
            if(!recentRecMap.containsKey(priceLstItmRec.ccrz__Product__r.ccrz__SKU__c)){
                recentRecMap.put(priceLstItmRec.ccrz__Product__r.ccrz__SKU__c, priceLstItmRec);
            }
        }

		// fetch productMediaList
		lstProductMedia =  EC_QueryUtility.getProductmediaList(recentRecMap);

		//creating a map of Product image URL related to each product
        for(ccrz__E_ProductMedia__c prodMediaRec : lstProductMedia){
            prdImgUrlMap.put(prodMediaRec.ccrz__Product__r.ccrz__SKU__c, prodMediaRec.ccrz__URI__c);
        }
        Map<String,Date> productCartItemMap = getProductLastPurchaseDate() ;
        for(ccrz__E_PriceListItem__c pricelstItemRec : recentRecMap.values()){
            prodBean prodBeanRec = new prodBean();
            prodBeanRec.Name = pricelstItemRec.ccrz__Product__r.Name;
            prodBeanRec.Sku = pricelstItemRec.ccrz__Product__r.ccrz__SKU__c;
            prodBeanRec.productDesc = pricelstItemRec.ccrz__Product__r.ccrz__UnitOfMeasure__c;
            if(productCartItemMap.containsKey(pricelstItemRec.ccrz__Product__r.ccrz__SKU__c)){
                if(productCartItemMap.get(pricelstItemRec.ccrz__Product__r.ccrz__SKU__c)!=null){
            prodBeanRec.purchasedOn = formatDate(productCartItemMap.get(pricelstItemRec.ccrz__Product__r.ccrz__SKU__c));
                }else{
                   prodBeanRec.purchasedOn = label.EC_DummyPurchaseDate;
                }
            }
            else{
                   prodBeanRec.purchasedOn = label.EC_DummyPurchaseDate;
                }

            prodBeanRec.pdpUrl = generatePDPURL(user.userLocaleStr, pricelstItemRec.ccrz__Product__r.ccrz__SKU__c);
            //Fetch the Product image URL from the map
            if(prdImgUrlMap.containsKey(pricelstItemRec.ccrz__Product__r.ccrz__SKU__c)){
                prodBeanRec.prodImg = prdImgUrlMap.get(pricelstItemRec.ccrz__Product__r.ccrz__SKU__c);
            }
            prodBeanList.add(prodBeanRec);
        }
        return prodBeanList;
    }

/***************************************************************************************************************************************
    Method Name : getOrderSearchResults
    Description : Search the list of Order based on the search text
    Return type : List<orderBean> which is a wrapper of Order details
    Author      : Harsha
************************************************************************************************************************************/

    private static List<orderBean> getOrderSearchResults(string searchText){
        EC_QueryUtility queryObj = new EC_QueryUtility();
        EC_CacheWrapper user = EC_CacheHelper.getCacheInfo();


        searchText = searchText.replace('+',' ');

        // fetch orderItems
        List<ccrz__E_Order__c>   lstAllOrderItems = EC_QueryUtility.getOrderList(user);

        List<ccrz__E_Order__c> lstOrderItems = new List<ccrz__E_Order__c>();
        for(ccrz__E_Order__c orderRec : lstAllOrderItems){
            //Fetch all those orders that match the search criteria
			if(orderRec.EC_Related_Products__c.containsIgnoreCase(searchText)){
                lstOrderItems.add(orderRec);
            }
        }

        List<orderBean> lstOrdBean = new List<orderBean>();
        for(ccrz__E_Order__c orderRec : lstOrderItems){
            orderBean temOrdBeanRec = new orderBean();
            temOrdBeanRec.itemTotal = orderRec.EC_TotalQuantity__c;
            temOrdBeanRec.orderSFId = orderRec.id;
            temOrdBeanRec.orderId = string.valueof(orderRec.id);
            temOrdBeanRec.orderDate = formatDate(orderRec.ccrz__OrderDate__c);
            temOrdBeanRec.orderNumber = String.valueOf(orderRec.EC_ERP_Order_Number__c);
            temOrdBeanRec.placedBy = orderRec.ccrz__User__r.Name;

			string divisionParentChildValues = System.label.EC_DivisionValueNACLO;
            if(divisionParentChildValues.contains(orderRec.ccrz__Account__r.EC_Division__c) && orderRec.ccrz__Account__r.Recordtype.Name == 'Ship To'){
                temOrdBeanRec.accountNumber = orderRec.ccrz__Account__r.parent.EC_Account_Number__c;
            }else{
                temOrdBeanRec.accountNumber = orderRec.ccrz__Account__r.EC_Account_Number__c;
            }
            temOrdBeanRec.totalPrice = formatCurrency(orderRec.ccrz__TotalAmount__c) + ' ' + String.valueOf(orderRec.ccrz__CurrencyISOCode__c) ;
            temOrdBeanRec.orderStatus = orderRec.EC_Customer_Order_Status__c;
            temOrdBeanRec.poNumber = String.valueOf(orderRec.ccrz__OriginatedCart__r.ccrz__PONumber__c);

            temOrdBeanRec.shipToLine1 = orderRec.ccrz__ShipTo__r.ccrz__AddressFirstline__c;
            temOrdBeanRec.shipToLine2 = orderRec.ccrz__ShipTo__r.ccrz__AddressSecondline__c;
            temOrdBeanRec.shipToLine3 = orderRec.ccrz__ShipTo__r.ccrz__AddressThirdline__c;
            string addStr = '';
            if(orderRec.ccrz__ShipTo__r.ccrz__City__c != null){
                addStr += orderRec.ccrz__ShipTo__r.ccrz__City__c + ', ';
            }
            if(orderRec.ccrz__ShipTo__r.ccrz__State__c != null){
                addStr += orderRec.ccrz__ShipTo__r.ccrz__State__c + ', ';
            }
            if(orderRec.ccrz__ShipTo__r.ccrz__Country__c != null){
                addStr += orderRec.ccrz__ShipTo__r.ccrz__Country__c + ', ';
            }
            if(orderRec.ccrz__ShipTo__r.ccrz__PostalCode__c != null){
                addStr += orderRec.ccrz__ShipTo__r.ccrz__PostalCode__c;
            }
            temOrdBeanRec.shipToRestAdd = addStr;

            temOrdBeanRec.billToLine1 = orderRec.ccrz__BillTo__r.ccrz__AddressFirstline__c;
            temOrdBeanRec.billToLine2 = orderRec.ccrz__BillTo__r.ccrz__AddressSecondline__c;
            temOrdBeanRec.billToLine3 = orderRec.ccrz__BillTo__r.ccrz__AddressThirdline__c;
            addStr = '';
            if(orderRec.ccrz__BillTo__r.ccrz__City__c != null){
                addStr += orderRec.ccrz__BillTo__r.ccrz__City__c + ', ';
            }
            if(orderRec.ccrz__BillTo__r.ccrz__State__c != null){
                addStr += orderRec.ccrz__BillTo__r.ccrz__State__c + ', ';
            }
            if(orderRec.ccrz__BillTo__r.ccrz__Country__c != null){
                addStr += orderRec.ccrz__BillTo__r.ccrz__Country__c + ', ';
            }
            if(orderRec.ccrz__BillTo__r.ccrz__PostalCode__c != null){
                addStr += orderRec.ccrz__BillTo__r.ccrz__PostalCode__c;
            }
            temOrdBeanRec.billToRestAdd = addStr;

            lstOrdBean.add(temOrdBeanRec);
        }
        return lstOrdBean;
    }

/***************************************************************************************************************************************
	Method Name : getDocsSearchResults
	Description : Search the list of Docs based on the search text
	Return type : List<sdsDocBeanGrouped> which is a wrapper of Document details
	Author      : Harsha
************************************************************************************************************************************/


    private static List<sdsDocBeanGrouped> getDocsSearchResults(string searchText){

        Map<String, List<sdsDocBean>> sdsDocUrlMap = new Map<String, List<sdsDocBean>>();
        EC_QueryUtility queryObj = new EC_QueryUtility();
        EC_CacheWrapper user = EC_CacheHelper.getCacheInfo();

        set<string> setEntitledPriceList = new set<string>();
        List<string> lstEntitledPriceList = new List<string>();
        for(List<string> tempPriceLstId : user.accGrpPriceListMap.values()){
            lstEntitledPriceList.addAll(tempPriceLstId);
        }
        setEntitledPriceList.addAll(lstEntitledPriceList);

        searchText = searchText.replace('+',' ');

		//  fetch priceListItems
		List<ccrz__E_PriceListItem__c>   lstProdRecs = EC_QueryUtility.getPriceListItems(setEntitledPriceList,searchText);

        Map<String,Date> productCartItemMap = getProductLastPurchaseDate() ;
        Set<String> resultProdIdLst = new Set<String>();
        for(ccrz__E_PriceListItem__c priceLstRec : lstProdRecs){
            resultProdIdLst.add(priceLstRec.ccrz__Product__c);
        }

		//fetch ProductMediaList
		List<ccrz__E_ProductMedia__c>   lstProductMedia = EC_QueryUtility.getProductMediaDocSearch(resultProdIdLst);

        //creating a map of sds documents related to each product
		for(ccrz__E_ProductMedia__c prodMediaRec : lstProductMedia){
            if(sdsDocUrlMap.containsKey(prodMediaRec.ccrz__Product__r.ccrz__SKU__c)){
                sdsDocBean sdsDocBeanRec = new sdsDocBean();
                sdsDocBeanRec.sdsDocName = prodMediaRec.ccrz__ProductDescription__c;
                sdsDocBeanRec.sdsDocLink = prodMediaRec.ccrz__URI__c;
                sdsDocBeanRec.prodName = prodMediaRec.ccrz__Product__r.Name;
                if(productCartItemMap.containsKey(prodMediaRec.ccrz__Product__r.ccrz__SKU__c) ){
                sdsDocBeanRec.prodPurchaseOn = productCartItemMap.get(prodMediaRec.ccrz__Product__r.ccrz__SKU__c);
                          }
                sdsDocUrlMap.get(prodMediaRec.ccrz__Product__r.ccrz__SKU__c).add(sdsDocBeanRec);
            }else{
                List<sdsDocBean> tempSDSBeanLst = new List<sdsDocBean>();
                sdsDocBean sdsDocBeanRec = new sdsDocBean();
                sdsDocBeanRec.sdsDocName = prodMediaRec.ccrz__ProductDescription__c;
                sdsDocBeanRec.sdsDocLink = prodMediaRec.ccrz__URI__c;
                sdsDocBeanRec.prodName = prodMediaRec.ccrz__Product__r.Name;
                 if(productCartItemMap.containsKey(prodMediaRec.ccrz__Product__r.ccrz__SKU__c)){
                sdsDocBeanRec.prodPurchaseOn = productCartItemMap.get(prodMediaRec.ccrz__Product__r.ccrz__SKU__c);
                     }

                tempSDSBeanLst.add(sdsDocBeanRec);
                sdsDocUrlMap.put(prodMediaRec.ccrz__Product__r.ccrz__SKU__c, tempSDSBeanLst);
            }
        }

      list<sdsDocBeanGrouped> tempLstGroupedSDSBean = new list<sdsDocBeanGrouped>();
         list<sdsDocBeanGrouped> tempLstGroupedSDSBeanReverse = new list<sdsDocBeanGrouped>();
        for(string skuKey : sdsDocUrlMap.keyset()){
            sdsDocBeanGrouped tempGroupedSDSBean = new sdsDocBeanGrouped();
            list<sdsDocBean> tempLstsdsDocBean = new list<sdsDocBean>();
            tempLstsdsDocBean.addAll(sdsDocUrlMap.get(skuKey));
            tempGroupedSDSBean.prodName = tempLstsdsDocBean[0].prodName;
            if(tempLstsdsDocBean[0].prodPurchaseOn!=null){
            tempGroupedSDSBean.productPurchaseDate = formatDate(tempLstsdsDocBean[0].prodPurchaseOn);
            }
            else{
            tempGroupedSDSBean.productPurchaseDate = label.EC_DummyPurchaseDate;
            }
            tempGroupedSDSBean.lstGroupedSDSBean = tempLstsdsDocBean;
            tempLstGroupedSDSBean.add(tempGroupedSDSBean);
        }

        for(Integer i = tempLstGroupedSDSBean.size() - 1; i >= 0; i--){
          tempLstGroupedSDSBeanReverse.add(tempLstGroupedSDSBean[i]);
        }
      return tempLstGroupedSDSBeanReverse;
    }

   public static Map<String, List<prodBean>> getQuickList(String searchText){
        EC_CacheWrapper user = EC_CacheHelper.getCacheInfo();

        set<string> setEntitledPriceList = new set<string>();
        List<string> lstEntitledPriceList = new List<string>();
        for(List<string> tempPriceLstId : user.accGrpPriceListMap.values()){
            lstEntitledPriceList.addAll(tempPriceLstId);
        }
        setEntitledPriceList.addAll(lstEntitledPriceList);

        searchText = searchText.replace('+',' ');
        searchText = '%'+searchText+'%';

        List<User> UserInfo = [Select contactId from User where Id=:UserInfo.getUserId()];
        List<ccrz__E_PriceListItem__c> lstProdRecs = [SELECT id, ccrz__Product__c, ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_PriceListItem__c WHERE ccrz__Pricelist__c IN: setEntitledPriceList AND (ccrz__Product__r.Name LIKE: searchText OR ccrz__Product__r.ccrz__SKU__c LIKE: searchText)];

        Set<String> resultProdIdLst = new Set<String>();
        for(ccrz__E_PriceListItem__c priceLstRec : lstProdRecs){
            resultProdIdLst.add(priceLstRec.ccrz__Product__c);
        }

        List<ccrz__E_CartItem__c> listCart = [SELECT ccrz__Product__c,ccrz__Cart__c FROM ccrz__E_CartItem__c where ccrz__Product__c IN: resultProdIdLst and ccrz__Cart__c in (Select id from ccrz__E_Cart__c where ccrz__CartType__c = 'WishList' AND ccrz__Contact__c=: UserInfo[0].contactId)];

        List<String> prdIds = new List<String>();
        List<String> prdCartMap = new List<String>();
        for(ccrz__E_CartItem__c cart:listCart){
            prdIds.add(cart.ccrz__Product__c);
            prdCartMap.add(String.valueOf(cart.ccrz__Product__c)+':::'+String.valueOf(cart.ccrz__Cart__c));
        }
        Map<String, ccrz__E_Cart__c> quickItems = new Map<String, ccrz__E_Cart__c>([Select id,ccrz__Name__c,LastModifiedDate from ccrz__E_Cart__c where ccrz__CartType__c = 'WishList' AND ccrz__Contact__c=: UserInfo[0].contactId]);
        List<ccrz__E_Product__c> listqukList = new List<ccrz__E_Product__c>();
        listqukList =  [SELECT Name, ccrz__UnitOfMeasure__c, ccrz__SKU__c FROM ccrz__E_Product__c where Id in:prdIds];

        List<ccrz__E_ProductMedia__c> lstProductMedia = new List<ccrz__E_ProductMedia__c>();

        lstProductMedia = [SELECT id, ccrz__URI__c, ccrz__MediaType__c, ccrz__ProductDescription__c, ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__c IN: listqukList AND ccrz__MediaType__c = 'Product Image'];
        Map<String, String> prdImgUrlMap = new Map<String, String>();
        for(ccrz__E_ProductMedia__c prodMediaRec : lstProductMedia){
            prdImgUrlMap.put(prodMediaRec.ccrz__Product__r.ccrz__SKU__c, prodMediaRec.ccrz__URI__c);
        }
        Map<String, prodBean> prodBeans = new Map<String, prodBean>();
        for(ccrz__E_Product__c prodRec : listqukList){
            prodBean prodBeanRec = new prodBean();
            prodBeanRec.Name = prodRec.Name;
            prodBeanRec.Sku = prodRec.ccrz__SKU__c;
            prodBeanRec.productDesc = prodRec.ccrz__UnitOfMeasure__c;
            prodBeanRec.pdpUrl = generatePDPURL(user.userLocaleStr, prodRec.ccrz__SKU__c);
            prodBeanRec.prodImg = prdImgUrlMap.get(prodRec.ccrz__SKU__c);
            prodBeans.put(prodRec.Id,prodBeanRec);
        }

        Map<String, List<prodBean>> prodBeanMap = new Map<String, List<prodBean>>();
        for(String cartId:prdCartMap){
            List<String> name = cartId.split(':::');
            prodBean existingProduct = prodBeans.get(name[0]);
            prodBean product = new prodBean();
            product.Name = existingProduct.Name;
            product.Sku = existingProduct.Sku;
            product.productDesc = existingProduct.productDesc;
            product.pdpUrl = existingProduct.pdpUrl;
            product.prodImg = existingProduct.prodImg;
            List<prodBean> items = prodBeanMap.get(name[1]);
            if (items == null) {
                List<prodBean> item = new List<prodBean>();
                product.cartInfo = quickItems.get(name[1]);
                product.quickUrl = generateQuickListURL(user.userLocaleStr,product.cartInfo.Id);
                item.add(product);
                prodBeanMap.put(name[1],item);
            } else {
                items.add(product);
                prodBeanMap.put(name[1],items);
            }
        }
        return prodBeanMap;
    }
    /***************************************************************************************************************************************
    Method Name : getProductLastPurchaseDate
    Description : Method to generate the lastPurchasedDate of Product by loggedin user
    Return type : Map<String,DateTime>
    Author      : Mishika Mahajan
************************************************************************************************************************************/

    public static Map<String,Date> getProductLastPurchaseDate(){
        List<ccrz__E_Cart__c> wishlist = new List<ccrz__E_Cart__c>();
         wishList = [Select Name,Id from ccrz__E_Cart__c Where OwnerId =:userinfo.getUserId() AND ccrz__CartType__c='WishList' AND EC_PurchasedWishlist__c=true Limit 1];
        List<ccrz__E_CartItem__c> wishListCartItems = new List<ccrz__E_CartItem__c>();
            if(wishList!= null && !wishList.isEmpty()){
             //wishlist found - check for cart items
            wishListCartItems = [Select Id,ccrz__Product__c,ccrz__Product__r.ccrz__SKU__c,EC_Last_Purchased_Date__c,ccrz__Quantity__c,ccrz__Price__c,ccrz__SubAmount__c from ccrz__E_CartItem__c where ccrz__Cart__c=:wishList[0].id order by EC_Last_Purchased_Date__c desc];
            }
        Map<String,Date> productCartItemMap = new Map<String,Date>();
                       if(wishListCartItems!=null && !(wishListCartItems.isEmpty())){
                        for(ccrz__E_CartItem__c cartItem : wishListCartItems){

                            if(!(productCartItemMap.containsKey(cartItem.ccrz__Product__r.ccrz__SKU__c))){
                            productCartItemMap.put(cartItem.ccrz__Product__r.ccrz__SKU__c,cartItem.EC_Last_Purchased_Date__c);
                             }
                          }
                       }
      return productCartItemMap;
    }

/***************************************************************************************************************************************
	Method Name : generatePDPURL
	Description : Method to generate the PDPUrl based on the product chosen and user's locale
	Return type : String with the URL to redirect
	Author      : Harsha
************************************************************************************************************************************/

    private static String generatePDPURL(String localeValue, String skuValue){
        String tempURL = EC_Utility.getCommunityUrl() + System.label.EC_PDPTemplateUrl;
        tempURL = tempURL.replace('userLocale',localeValue);
        tempURL = tempURL.replace('productSKU',skuValue);
        return tempURL;
    }

    private static String generateQuickListURL(String localeValue, String quickListId){
        String tempURL = System.label.EC_QuickListTemplateUrl;
        tempURL = tempURL.replace('userLocale',localeValue);
        tempURL = tempURL.replace('quickID',quickListId);
        return tempURL;
    }

/***************************************************************************************************************************************
	Method Name : formatDate
	Description : Method to generate date string in the Following format - (January 12 2019)
	Return type : String with the date in the above format
	Author      : Harsha
************************************************************************************************************************************/

    private static String formatDate(Datetime dt){
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
                                                                    6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
                                                                    11=>'November', 12=>'December'};
        return monthNameMap.get(dt.month()) + ' ' + dt.day() + ', ' + dt.year();
    }
 /************************************************************************************************************************************
Method Name : compVisible
Description : to check component visibility on console based on permission set assigned.
Return type : List<EC_Utility.PermWrapper>
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static List<EC_Utility.PermWrapper>  compVisible(){
     return  EC_Utility.getPermCache();
    }
    /***************************************************************************************************************************************
    Method Name : formatDate
    Description : Method to generate date string in the Following format - (January 12 2019)
    Return type : String with the date in the above format
    Author      : Raghav Sharma
************************************************************************************************************************************/

    private static String formatDate(Date dt){
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'Jan', 2=>'Feb', 3=>'Mar', 4=>'Apr', 5=>'May',
                                                                    6=>'Jun', 7=>'Jul', 8=>'Aug', 9=>'Sep',10=>'Oct',
                                                                    11=>'Nov', 12=>'Dec'};
        return monthNameMap.get(dt.month()) + ' ' + dt.day() + ', ' + dt.year();
    }

/***************************************************************************************************************************************
	Class Name  : prodBean
	Description : Wrapper class to hold all the product infomation
	Author      : Harsha
************************************************************************************************************************************/

    public class prodBean{
        @auraEnabled
        public string Name, Sku, productDesc, purchasedOn, prodImg, pdpUrl, quickUrl;
        @auraEnabled
        public ccrz__E_Cart__c cartInfo;
    }

/***************************************************************************************************************************************
	Class Name  : orderBean
	Description : Wrapper class to hold all the order infomation
	Author      : Harsha
************************************************************************************************************************************/

    public class orderBean{
        @AuraEnabled
        public string orderSFId, orderDate, orderNumber, placedBy, accountNumber, orderStatus, poNumber, orderId, shipToLine1, shipToLine2, shipToLine3, shipToRestAdd, billToLine1, billToLine2, billToLine3, billToRestAdd, totalPrice;
        @AuraEnabled
        public decimal itemTotal;
    }

/***************************************************************************************************************************************
	Class Name  : sdsDocBeanGrouped
	Description : Wrapper class to hold all the SDS Document information grouped by name
	Author      : Harsha
************************************************************************************************************************************/

    public class sdsDocBeanGrouped{
        @auraEnabled
        public String productPurchaseDate;
        @auraEnabled
        public string prodName;
        @auraEnabled
        public list<sdsDocBean> lstGroupedSDSBean;
    }

/***************************************************************************************************************************************
	Class Name  : sdsDocBean
	Description : Wrapper class to hold all the SDS docuement infomation
	Author      : Harsha
************************************************************************************************************************************/

    public class sdsDocBean{
        @auraEnabled
        public string sdsDocName, sdsDocLink, prodName;
         @auraEnabled
        public Date prodPurchaseOn;
    }
     /***************************************************************************************************************************************
Method Name : formatCurrency
Description : to format currency values
Parameter   : String
Return type : Decimal
Author      : Raghav Sharma
*************************************************************************************************************************************/

    private static String formatCurrency(Decimal totalAmount ){
        return(totalAmount.format().contains('.')?totalAmount.format():(totalAmount.format()+'.00'));
    }
      /************************************************************************************************************************************
Method Name : outageRedirect
Description : to get the permission from cache.
Return type : Boolean
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static Boolean outageRedirect(){
       return EC_Utility.getOutageFlag();
    }

}