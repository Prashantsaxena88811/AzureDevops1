/* Class Name       :EC_OrderInfo
 * Description      :This is the controller class for homepage order processing
 * Created By       :Harsha N
 * Created On       :06-27-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 *  Harsha N               06-27-2019                                   The functionality to pull the 6 recent products purchased by the logged in user is added
 *
 */

public without sharing class EC_OrderInfo {

/***************************************************************************************************************************************
Method Name : getRecentOrder
Description : to fetch recent orders
Parameter   : N/A
Return type : List<ProdInfo>
Author      : Harsha N
*************************************************************************************************************************************/
    @AuraEnabled
    public static List<ProdInfo> getRecentOrder(){
        List<ProdInfo> lstProdInfo = new List<ProdInfo>();
        Contact con = new Contact() ;

            User usr = EC_QueryUtility.getCurrentUser();

            //Check if Salesrep
            if(usr.User_Type__c !='External'){
                List<Contact> conlist = [Select Id,EC_SalesRep_User__c from Contact where EC_SalesRep_User__c =: UserInfo.getUserId() limit 1];
                if(conlist.size()>0){
                  con = conlist[0];
                 }

                }

                List<AccountContactRelation> lstAccContRel = new List<AccountContactRelation>();

            //to check if user has an associated contact
            if(usr!=null && usr.contactId != null){
               lstAccContRel = EC_QueryUtility.getAccountContactRelation(usr);
               } else {
            lstAccContRel = [SELECT id, accountId, account.ccrz__E_AccountGroup__c FROM AccountContactRelation WHERE contactId =: con.Id];
               }

            List<String> lstAccIds = new List<String>();

            //to check if contact record is associated to the account
            if(lstAccContRel!=null){
                    for(AccountContactRelation accContRec : lstAccContRel){
                        lstAccIds.add(accContRec.accountId);
                    }
                }
                    List<ccrz__E_OrderItem__c> lstOrderItem = EC_QueryUtility.getOrderListItemSortByName(lstAccIds);

                    //to check if the orders has order items present
                    if(lstOrderItem != null && lstOrderItem.size() > 0){
                        Set<Id> lstProduct = new Set<Id>();
                        Set<Id> setAccIds = new Set<Id>();
                        for(ccrz__E_OrderItem__c ordItemRec : lstOrderItem){
                            lstProduct.add(ordItemRec.ccrz__Product__c);
                            if(ordItemRec.ccrz__Order__r.ccrz__Account__r.EC_Division__c == EC_Constants.INSTITUTIONAL)
                	            setAccIds.add(ordItemRec.ccrz__Order__r.ccrz__Account__c);
                        }
                        Map<String, INST_Sales_Entitlement__c> mapInstSalesEntitlements = new Map<String, INST_Sales_Entitlement__c>();
                        if(setAccIds != null) mapInstSalesEntitlements = EC_QueryUtility.getInstSalesEntitlements(setAccIds);
                        
                        Map<Id, String> mapPrdctImg = new Map<Id, String>();
                        //To check if order items has associated products, then fetch their image
                        if(lstProduct!=null && lstProduct.size() > 0){
                            List<ccrz__E_ProductMedia__c> lstProdMedia = EC_QueryUtility.getListProdMedia(lstProduct);

                            //to check if the product has product image
                            if(lstProdMedia != null && lstProdMedia.size() > 0){
                                for(ccrz__E_ProductMedia__c prdMed : lstProdMedia){
                                    mapPrdctImg.put(prdMed.ccrz__Product__c, prdMed.ccrz__URI__c);
                                }
                            }
                        }
                        List<Chemical_Product_Type__c> pkgTypes = new List<Chemical_Product_Type__c>();
            			pkgTypes = [SELECT Active__c,Id,Name,Package_Code__c,Product_Type__c FROM Chemical_Product_Type__c];
                        for(ccrz__E_OrderItem__c ordItemRec : lstOrderItem){
                            ProdInfo prdInfoRec = new ProdInfo();
                            prdInfoRec.orderSFId = ordItemRec.ccrz__Order__c;

                            //prdInfoRec.orderId = String.valueOf(ordItemRec.ccrz__Order__r.ccrz__OrderNumber__c);
                            prdInfoRec.orderId = String.valueOf(ordItemRec.ccrz__Order__r.EC_ERP_Order_Number__c);

                            prdInfoRec.orderItemId = String.valueOf(ordItemRec.Id);
                            prdInfoRec.price = String.valueOf(ordItemRec.ccrz__Price__c);
                            prdInfoRec.uom = ordItemRec.Custom_PricingUOM__c;
                            prdInfoRec.unitPrice = String.valueOf(ordItemRec.Custom_UnitPrice__c);
                            prdInfoRec.taxonomy = String.valueOf(ordItemRec.ccrz__Product__r.Taxonomy__c);
                            String packageCode = String.valueOf(ordItemRec.ccrz__Product__r.Package_Code__c);
                            
            				Set<String> pkgCodeSet = new Set<String>();
            				if(!pkgTypes.isEmpty()) {
                				for (Chemical_Product_Type__c pkgType : pkgTypes) {
                    				if(pkgType.Active__c == true) {
                        			pkgCodeSet.add(pkgType.Package_Code__c);
                    				}
               				 	}
            				} 
                            if(!pkgCodeSet.isEmpty() && pkgCodeSet.contains(packageCode)) {
                                prdInfoRec.chemicalProductType = System.Label.EC_Bulk;
                    		} 
                            else {
                       			prdInfoRec.chemicalProductType = System.Label.NonBulk;
                   			}
                            
                            prdInfoRec.purchasedOn = formatDate(ordItemRec.ccrz__Order__r.ccrz__OrderDate__c);
                            String addressString = '';

                            //null check for shipping address line 1
                            if(ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressFirstline__c != null){
                                addressString = addressString + ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressFirstline__c + ', ';
                            }

                            //null check for shipping address line 2
                            if(ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressSecondline__c != null){
                                addressString = addressString + ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressSecondline__c + ', ';
                            }

                            //null check for shipping address line 3
                            if(ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressThirdline__c != null){
                                addressString = addressString + ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressThirdline__c + ', ';
                            }
                            prdInfoRec.shippedTo = addressString + ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__City__c + ', ' + ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__State__c + ', ' + ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__Country__c + ', ' + ordItemRec.ccrz__Order__r.ccrz__ShipTo__r.ccrz__PostalCode__c;
                            prdInfoRec.productName = ordItemRec.ccrz__Product__r.Name;
                            prdInfoRec.productCode = ordItemRec.ccrz__Product__r.ccrz__SKU__c;
                            prdInfoRec.productUnitMeasure = ordItemRec.ccrz__Product__r.ccrz__UnitOfMeasure__c ;
                            prdInfoRec.description = System.label.EC_Home_ProductDescription;
                            prdInfoRec.PDPUrl = generatePDPURL(usr.LanguageLocaleKey, ordItemRec.ccrz__Product__r.ccrz__SKU__c);

                            //to check if mapPrdctImg contains the product id for fetching the associated image.
                            if(mapPrdctImg != null && mapPrdctImg.containsKey(ordItemRec.ccrz__Product__c)){
                                prdInfoRec.image = mapPrdctImg.get(ordItemRec.ccrz__Product__c);
                            }

                            //PBI-139350
                            prdInfoRec.accountId = ordItemRec.ccrz__Order__r.ccrz__Account__c;
                            //INST HYBRID/DIRECT Account having SKU
                            if(mapInstSalesEntitlements.containsKey(prdInfoRec.productCode)) {
                                INST_Sales_Entitlement__c instSales = mapInstSalesEntitlements.get(prdInfoRec.productCode);
                                //Hide 'Add to Cart' button IF the Product's Account is present in the ISE List 
                                prdInfoRec.hideAddtoCart = (instSales.Account_Salesforce_Id__c == prdInfoRec.accountId) ? true : false;
                            //INST INDIRECT CORE Account
                            } else if(mapInstSalesEntitlements.containsKey(prdInfoRec.accountId)) {
                                INST_Sales_Entitlement__c instSales = mapInstSalesEntitlements.get(prdInfoRec.accountId);
                                //Hide 'Add to Cart' button IF Product Taxonomy is Chemical
                                prdInfoRec.hideAddtoCart = (instSales.Taxonomy__c == prdInfoRec.taxonomy) ? true : false;
                            } else {
                                prdInfoRec.hideAddtoCart = false;
                            }

                            lstProdInfo.add(prdInfoRec);
                        }
                    }



        return lstProdInfo;
    }

 /***************************************************************************************************************************************
Method Name : generatePDPURL
Description : to fetch Product Page URL
Parameter   : String,String
Return type : String
Author      : Harsha N
*************************************************************************************************************************************/

    private static String generatePDPURL(String localeValue, String skuValue){
        String tempURL = EC_Utility.getCommunityUrl() + System.label.EC_PDPTemplateUrl;
        tempURL = tempURL.replace(EC_Constants.LOCALE,localeValue);
        tempURL = tempURL.replace(EC_Constants.SKUVALUE,skuValue);
        return tempURL;
    }

    /***************************************************************************************************************************************
Method Name : formatDate
Description : to format date
Parameter   : Date
Return type : String
Author      : Harsha N
*************************************************************************************************************************************/
    private static String formatDate(Date dt){
        Map<Integer,String> monthNameMap=new Map<Integer, String>{EC_Constants.ONE =>EC_Constants.JAN, EC_Constants.TWO =>EC_Constants.FEB, EC_Constants.THREE =>EC_Constants.MAR, EC_Constants.FOUR =>EC_Constants.APR, EC_Constants.FIVE =>EC_Constants.MAY,
                                                                    EC_Constants.SIX =>EC_Constants.JUN, EC_Constants.SEVEN =>EC_Constants.JUL, EC_Constants.EIGHT =>EC_Constants.AUG, EC_Constants.NINE =>EC_Constants.SEP,EC_Constants.TEN =>EC_Constants.OCT,
                                                                    EC_Constants.ELEVEN =>EC_Constants.NOV, EC_Constants.TWELVE =>EC_Constants.DEC};
        return monthNameMap.get(dt.month()) + ' ' + dt.day() + ', ' + dt.year();
    }

    /***************************************************************************************************************************************
Method Name : getCartURL
Description : to redirect to the shopping cart
Parameter   : String
Return type : String
Author      : Harsha N
*************************************************************************************************************************************/

    @AuraEnabled
    public static String getCartURL(Id orderItemId){
        String cartURL = '';
        User usr = EC_QueryUtility.getCurrentUser();
        /*Map<String, Object> addToCartRequest = new Map<String, Object>();
        Map<String, Object> addToCartResponse = new Map<String, Object>();
        List<Map<String, Object>> lineItemData = new List<Map<String, Object>>();

        Map<String, Object> lineItemRec = new Map<String, Object>();
        lineItemRec.put(ccrz.ccApiCart.LINE_DATA_QUANTITY, 1);
        lineItemRec.put(ccrz.ccApiCart.LINE_DATA_SKU, prodSKU);
        lineItemData.add(lineItemRec);

        addToCartRequest.put(ccrz.ccApi.API_VERSION, ccrz.ccApi.CURRENT_VERSION);

        addToCartRequest.put(ccrz.ccApiCart.LINE_DATA, lineItemData);

        addToCartResponse = ccrz.ccApiCart.addTo(addToCartRequest);

        if(addToCartResponse.get(ccrz.ccApiCart.CART_ENCID) != null){
            List<ccrz__E_Cart__c> activeCartRec = EC_QueryUtility.getActiveCartRec(String.valueOf(addToCartResponse.get(ccrz.ccApiCart.CART_ENCID)));
            cartURL = EC_Utility.getCommunityUrl() +EC_Constants.CARTQURYSTRING1+ addToCartResponse.get(ccrz.ccApiCart.CART_ENCID) + EC_Constants.CARTQURYSTRING2+ activeCartRec[0].ccrz__EffectiveAccountID__c + EC_Constants.CARTQURYSTRING3 + usr.LanguageLocaleKey;
        }*/

		List<ccrz__E_OrderItem__c> orderItemRec = [SELECT  Id, ccrz__Product_Name__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.ccrz__UnitOfMeasure__c, ccrz__Quantity__c, ccrz__Price__c, ccrz__Product__c, ccrz__Order__r.ccrz__CurrencyISOCode__c, ccrz__OriginalQuantity__c, ccrz__UnitOfMeasure__c, ccrz__Order__r.ccrz__EffectiveAccountID__c FROM ccrz__E_OrderItem__c WHERE Id =: orderItemId LIMIT 1];

		ccrz__E_Cart__c activeCartRec = EC_Utility.getActiveCartForUser(orderItemRec[0].ccrz__Order__r.ccrz__EffectiveAccountID__c);

		String itemAddedStatus = EC_Utility.addItemsToCart(activeCartRec.id, orderItemRec[0].ccrz__Order__r.ccrz__EffectiveAccountID__c, orderItemRec, false);

		return cartURL;
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

    /***************************************************************************************************************************************
Method Name : compVisible
Description : to get list of custom permissions of user
Parameter   : N/A
Return type : List<EC_Utility.PermWrapper>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    @auraEnabled
    public static List<EC_Utility.PermWrapper>  compVisible(){
        return  EC_Utility.getPermCache();
    }

 /***************************************************************************************************************************************
Class Name  : ProdInfo
Description : wrapper class containing the product information
Author      : Harsha N
*************************************************************************************************************************************/
    public class ProdInfo{
        @auraEnabled
        public string chemicalProductType,taxonomy, unitPrice, uom, productName, productCode, image, orderId, purchasedOn, orderSFId, shippedTo, price, description, PDPUrl, productUnitMeasure, orderItemId, accountId;
        //PBI-139350
        @AuraEnabled
        public Boolean hideAddtoCart;
    }
}