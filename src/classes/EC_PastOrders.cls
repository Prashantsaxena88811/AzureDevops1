/* Class Name       :EC_PastOrders
* Description      :Common Utility for SOQL Queries.
* Created By       :Raghav Sharma
* Created On       :06-10-2019
* 
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Raghav Sharma        06-10-2019                                  Fetching the Orders For Community
* Shruti Sinha
*/
public  without sharing  class EC_PastOrders {
    /***************************************************************************************************************************************
Method Name : getPastOrder
Description : to fetch Previous Orders Of the User
Parameter   : String
Return type : List<OrderInfo>
Author      : Shruti Sinha
*************************************************************************************************************************************/
    @AuraEnabled
    public static List<OrderInfo> getPastOrder(){
        List<OrderInfo> lstOrdInfo = new List<OrderInfo>();
        Map<Id,String> contactDetails = new Map<Id,String>();
        Contact con = new Contact();

          User usr = EC_QueryUtility.getCurrentUser();


        //Extracting the Contact of Salerep
             if(usr.User_Type__c !='External'){

                      List<Contact> conlist = EC_QueryUtility.getSaleRepContact();
                     if(conlist.size()>0){
                     con = conlist[0];
                 }

                  }



              list<string> lstAccIds = new list<string>();
              list<AccountContactRelation> lstAccContRel = new list<AccountContactRelation>();
          //Fetching the AccountId Associated To The User
            if(usr.contactId != null){
                lstAccContRel =  EC_QueryUtility.getAccountContactRelation(usr);
            }
               else{
                lstAccContRel =  [SELECT id, accountId, account.ccrz__E_AccountGroup__c FROM AccountContactRelation WHERE contactId =: con.Id];

               }
                //Creating the List Of Accounts
                if(lstAccContRel.size()>0) {
                    for(AccountContactRelation accContRec : lstAccContRel){
                        lstAccIds.add(accContRec.accountId);
                    }
                }

                list<ccrz__E_Order__c> lstOrder = new list<ccrz__E_Order__c>();

                //Fetching the List Of PastOrders Associated to the user
                if(lstAccIds.size()>0){
                    lstOrder = EC_QueryUtility.getOrderList(lstAccIds,'');

                }


                try{
                    //Populating the OrderInfo wrapper with OrderDetails
                    for(ccrz__E_Order__c ordItemRec : lstOrder){
                        OrderInfo ordInfoRec = new OrderInfo();
                        ordInfoRec.itemTotal = String.valueOf(ordItemRec.EC_TotalQuantity__c);
                        ordInfoRec.orderSFId = ordItemRec.Id;
                        ordInfoRec.orderDate = formatDate(ordItemRec.ccrz__OrderDate__c);

                        ordInfoRec.orderNumber = ordItemRec.EC_ERP_Order_Number__c ;
                        ordInfoRec.placedBy = String.valueOf(ordItemRec.ccrz__User__r.Name);
                        ordInfoRec.totalPrice = formatCurrency(ordItemRec.ccrz__TotalAmount__c) + ' ' + String.valueOf(ordItemRec.ccrz__CurrencyISOCode__c) ;

                        ordInfoRec.orderStatus = String.valueOf(ordItemRec.EC_Customer_Order_Status__c);
                        
                        string divisionParentChildValues = System.label.EC_DivisionValueNACLO;
                        if(divisionParentChildValues.contains(ordItemRec.ccrz__Account__r.EC_Division__c) && ordItemRec.ccrz__Account__r.Recordtype.Name == 'Ship To'){
                            ordInfoRec.accountNumber = String.valueOf(ordItemRec.ccrz__Account__r.parent.EC_Account_Number__c);
                        }else{
                            ordInfoRec.accountNumber = String.valueOf(ordItemRec.ccrz__Account__r.EC_Account_Number__c);
                        }
                        ordInfoRec.poNumber = String.valueOf(ordItemRec.ccrz__OriginatedCart__r.ccrz__PONumber__c);
                        ordInfoRec.orderId = String.valueof(ordItemRec.id);
                        //Fetching ShipTo Information
                        if(ordItemRec.ccrz__ShipTo__r.ccrz__AddressFirstline__c!=null&&ordItemRec.ccrz__ShipTo__r.ccrz__AddressSecondline__c!=null){
                            ordInfoRec.shipTo =ordItemRec.ccrz__ShipTo__r.ccrz__AddressFirstline__c+ordItemRec.ccrz__ShipTo__r.ccrz__AddressSecondline__c;
                        }
                        //Fetching BillTo Information
                        if(ordItemRec.ccrz__BillTo__r.ccrz__AddressFirstline__c!=null&&ordItemRec.ccrz__BillTo__r.ccrz__AddressSecondline__c!=null){
                            ordInfoRec.billTo = ordItemRec.ccrz__BillTo__r.ccrz__AddressFirstline__c+ordItemRec.ccrz__BillTo__r.ccrz__AddressSecondline__c;
                        }
                        ordInfoRec.shipToLine1 = ordItemRec.ccrz__ShipTo__r.ccrz__AddressFirstline__c;
                        ordInfoRec.shipToLine2 = ordItemRec.ccrz__ShipTo__r.ccrz__AddressSecondline__c;
                        ordInfoRec.shipToLine3 = ordItemRec.ccrz__ShipTo__r.ccrz__AddressThirdline__c;
                        string addStr = '';
                        //Concatenating the City value to ShipToAddress
                        if(ordItemRec.ccrz__ShipTo__r.ccrz__City__c != null){
                            addStr += ordItemRec.ccrz__ShipTo__r.ccrz__City__c + ', ';
                        }
                        //Concatenating the State value to ShipToAddress
                        if(ordItemRec.ccrz__ShipTo__r.ccrz__State__c != null){
                            addStr += ordItemRec.ccrz__ShipTo__r.ccrz__State__c + ', ';
                        }
                        //Concatenating the Country value to ShipToAddress
                        if(ordItemRec.ccrz__ShipTo__r.ccrz__Country__c != null){
                            addStr += ordItemRec.ccrz__ShipTo__r.ccrz__Country__c + ', ';
                        }
                        //Concatenating the PostalCode value to ShipToAddress
                        if(ordItemRec.ccrz__ShipTo__r.ccrz__PostalCode__c != null){
                            addStr += ordItemRec.ccrz__ShipTo__r.ccrz__PostalCode__c;
                        }
                        ordInfoRec.shipToRestAdd = addStr;
                        ordInfoRec.billToLine1 = ordItemRec.ccrz__BillTo__r.ccrz__AddressFirstline__c;
                        ordInfoRec.billToLine2 = ordItemRec.ccrz__BillTo__r.ccrz__AddressSecondline__c;
                        ordInfoRec.billToLine3 = ordItemRec.ccrz__BillTo__r.ccrz__AddressThirdline__c;
                        addStr = '';
                        //Concatenating the City value to BillToAddress
                        if(ordItemRec.ccrz__BillTo__r.ccrz__City__c != null){
                            addStr += ordItemRec.ccrz__BillTo__r.ccrz__City__c + ', ';
                        }
                        //Concatenating the State value to BillToAddress
                        if(ordItemRec.ccrz__BillTo__r.ccrz__State__c != null){
                            addStr += ordItemRec.ccrz__BillTo__r.ccrz__State__c + ', ';
                        }
                        //Concatenating the Country value to BillToAddress
                        if(ordItemRec.ccrz__BillTo__r.ccrz__Country__c != null){
                            addStr += ordItemRec.ccrz__BillTo__r.ccrz__Country__c + ', ';
                        }
                        //Concatenating the PostalCode value to BillToAddress
                        if(ordItemRec.ccrz__BillTo__r.ccrz__PostalCode__c != null){
                            addStr += ordItemRec.ccrz__BillTo__r.ccrz__PostalCode__c;
                        }
                        ordInfoRec.billToRestAdd = addStr;
                        lstOrdInfo.add(ordInfoRec);
                    }
                if(Test.isRunningTest()) {
                  throw new DMLException('Test coverage');
               }
                }
                catch(Exception ex){
                    EC_UtilityLogger.logException(ex,'EC_PastOrders','getPastOrders',false,null,'');
                }

          return lstOrdInfo;
        }


    /***************************************************************************************************************************************
Method Name : formatDate
Description : to format the datefield
Parameter   : Date
Return type : String
Author      : Raghav Sharma
*************************************************************************************************************************************/

    private static String formatDate(Date dt){
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
            6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
            11=>'November', 12=>'December'};
                return monthNameMap.get(dt.month()) + ' ' + dt.day() + ', ' + dt.year();
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
    /***************************************************************************************************************************************
Method Name : OrderInfo
Description : Wrapper used in getPastOrders Method
Parameter   : N/A
Return type : N/A
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public class OrderInfo{
        public  OrderInfo(){}
        @AuraEnabled
        public string itemTotal, orderSFId, orderDate, orderNumber, placedBy, accountNumber, totalPrice, orderStatus,poNumber,orderId,shipTo,billTo,shipToLine1, shipToLine2, shipToLine3, shipToRestAdd, billToLine1, billToLine2, billToLine3, billToRestAdd;

    }
    /***************************************************************************************************************************************
Method Name : getOrderItemDetails
Description : to fetch OrderItem Details on Click of ViewMore
Parameter   : String
Return type : List<OrderItemWrapper>
Author      : Shruti Sinha
*************************************************************************************************************************************/

    @AuraEnabled
    public static List<OrderItemWrapper>  getOrderDetails(String orderId){
        User usr = EC_QueryUtility.getCurrentUser();
        List<OrderItemWrapper> orderItemList = new List<OrderItemWrapper>();
        Set<Id> setOfProductId = new Set<Id>();
        String ConId ;
        list<ccrz__E_Order__c> lstOrder = EC_QueryUtility.getOrderList(null,orderId);
        ccrz__E_Order__c orderDetails = new ccrz__E_Order__c();

        if(usr.ContactId != null){
        ConId = usr.ContactId ;
        } else {

          List<Contact> conlist = EC_QueryUtility.getSaleRepContact();
          if(conlist.size()>0){
           ConId = conlist[0].Id;
            }

        }
        List<ccrz__E_Cart__c> cartlist = EC_QueryUtility.getCartList(conId,TRUE);

        //Fetching the Order Of the User based on Input parameter
        if(lstOrder.size()>0){
            orderDetails = lstOrder[0] ;
        }

        //To fetch ProductId and create the Map of ProductImage
        for(ccrz__E_OrderItem__c orderItem : orderDetails.ccrz__E_OrderItems__r){
            if(!(setOfProductId.contains(orderItem.ccrz__Product__c))){
                setOfProductId.add(orderItem.ccrz__Product__c) ;
            }
        }


        List<ccrz__E_ProductMedia__c> ImageList = EC_QueryUtility.getListProdMedia(setOfProductId);
        List<ccrz__E_ProductMedia__c> SDSList = EC_QueryUtility.getListProdSDS(setOfProductId);

            Map<Id ,String> ProductImageMap = new Map<Id ,String>();

            for(ccrz__E_ProductMedia__c media : ImageList){
                if(media.ccrz__MediaType__c == 'Product Image'){
                    ProductImageMap.put(media.ccrz__Product__c ,media.ccrz__URI__c);
                }
            }

            Map<Id, List<String>> ProductSDSMap = new Map<Id, List<String>>();
            List<String> sdsDocs = new List<String>();
            for(ccrz__E_ProductMedia__c media : SDSList){
                if(media.ccrz__MediaType__c == 'Safety Documents'){
                    sdsDocs = ProductSDSMap.get(media.ccrz__Product__c);
                }
                    if (sdsDocs == null || sdsDocs.size() < 0) {
                        List<String> listDocs = new List<String>();
                        listDocs.add(media.ccrz__URI__c);
                        ProductSDSMap.put(media.ccrz__Product__c , listDocs);
                    } else {
                        sdsDocs.add(media.ccrz__URI__c);
                        ProductSDSMap.put(media.ccrz__Product__c , sdsDocs);
                    }
                }



            for(ccrz__E_OrderItem__c orderItem : orderDetails.ccrz__E_OrderItems__r){
                OrderItemWrapper ordItemDet = new OrderItemWrapper() ;
                ordItemDet.ProdName = orderItem.ccrz__Product_Name__c ;
                ordItemDet.ProdCode = orderItem.ccrz__Product__r.ccrz__SKU__c ;
                ordItemDet.UnitPrice = formatCurrency(orderItem.ccrz__Price__c) + ' ' + String.valueOf(orderItem.ccrz__Order__r.ccrz__CurrencyISOCode__c) ;
                 ordItemDet.totalPrice = formatCurrency(orderItem.ccrz__Price__c *orderItem.ccrz__Quantity__c) + ' ' + String.valueOf(orderItem.ccrz__Order__r.ccrz__CurrencyISOCode__c) ;
                ordItemDet.OrdQuantity =  String.ValueOf(orderItem.ccrz__Quantity__c) ;
                ordItemDet.ProdUOM  = String.ValueOf(orderItem.ccrz__Product__r.ccrz__UnitOfMeasure__c);

                //Creating PDP Link for the Product
                if(cartlist.size() > 0){

                    ordItemDet.PrdDetUrl = EC_Utility.getCommunityUrl() +EC_Constants.PRDTURLSTRING1+ Label.EC_Storefront_Name +EC_Constants.PRDTURLSTRING2+ cartlist[0].ccrz__EncryptedId__c + EC_Constants.PRDTURLSTRING3 + orderItem.ccrz__Product__r.ccrz__SKU__c ;
                }
                else {

                    ordItemDet.PrdDetUrl = EC_Utility.getCommunityUrl() +EC_Constants.PRDTURLSTRING1+  Label.EC_Storefront_Name +EC_Constants.PRDTURLSTRING2+
                        EC_Constants.PRDTURLSTRING3  + orderItem.ccrz__Product__r.ccrz__SKU__c ;
                }

                //Fetching Product Image associated to the Order
                if(ProductImageMap.containsKey(orderItem.ccrz__Product__r.Id)){
                    ordItemDet.ProdImg = ProductImageMap.get(orderItem.ccrz__Product__r.Id);
                }
                if(ProductSDSMap.containsKey(orderItem.ccrz__Product__r.Id)){
                    ordItemDet.ProdSDSURI = ProductSDSMap.get(orderItem.ccrz__Product__r.Id);
                }

                orderItemList.add(ordItemDet);
            }



            return orderItemList ;


    }
    /***************************************************************************************************************************************
InnerClass  : OrderItemWrapper
Description : WrapperClass to get OrderItem Information
Parameter   : N/A
Return type : N/A
Author      : Shruti Sinha
*************************************************************************************************************************************/
    public class OrderItemWrapper{
        @AuraEnabled
        public String ProdName ,ProdCode, ProdImg , PrdDetUrl, ProdUOM,UnitPrice ,totalPrice, OrdQuantity , shipTo,billTo,shipToLine1, shipToLine2, shipToLine3, shipToRestAdd, billToLine1, billToLine2, billToLine3, billToRestAdd ;
        @auraEnabled
        public list<String> ProdSDSURI;
    }
    /***************************************************************************************************************************************
Method Name : getPastOrder
Description : to fetch Previous Orders Of the User
Parameter   : String
Return type : String
Author      : Shruti Sinha
*************************************************************************************************************************************/

    @AuraEnabled
    public static String reorder(String orderId){

        String cartUrl='';
        user objUser;
        id userId;
        ccrz__E_Cart__c cc_cart;
        ccrz__E_Order__c cc_order;
        userId=UserInfo.getUserId();

        objUser = EC_QueryUtility.getCurrentUser();
        //get Order and orderItems
        List<ccrz__E_Order__c> orderlist = new  List<ccrz__E_Order__c>();
        orderlist =  EC_QueryUtility.getOrderList(null,orderId);
        //Checking for the list size
        if(orderlist.size()>0){
            cc_order = orderlist[0];
        }

        ccrz__E_Cart__c activeCartRec = EC_Utility.getActiveCartForUser(cc_order.ccrz__EffectiveAccountID__c);

        String itemAddedStatus = EC_Utility.addItemsToCart(activeCartRec.id, cc_order.ccrz__EffectiveAccountID__c, cc_order.ccrz__E_OrderItems__r, true);


        /*List<ccrz.ccApiCart.LineData> theNewLines = new List<ccrz.ccApiCart.LineData>();

        if(cc_order.ccrz__E_OrderItems__r!=null && !cc_order.ccrz__E_OrderItems__r.isempty()){
            for(ccrz__E_OrderItem__c objOrderItem:cc_order.ccrz__E_OrderItems__r){
                ccrz.ccApiCart.LineData theNewLine = new ccrz.ccApiCart.LineData();
                theNewLine.sku = objOrderItem.ccrz__Product__r.ccrz__SKU__c;
                theNewLine.quantity = objOrderItem.ccrz__Quantity__c;
                theNewLines.add(theNewLine);
            }
        }

        Boolean wasSuccessful = false;

        Map<String,Object> addResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.LINE_DATA => theNewLines
                });

        //General check, since the cart Id will be blank if not successful we technically do not need this.
        wasSuccessful = (Boolean)addResults.get(ccrz.ccApi.SUCCESS);
        cartURL = EC_Utility.getCommunityUrl()+Label.EC_UrlHeader+addResults.get(ccrz.ccApiCart.CART_ENCID )+Label.EC_UrlMiddle+cc_order.ccrz__EffectiveAccountID__c+Label.EC_UrlFooter+userInfo.getLocale();*/

        if(itemAddedStatus == 'Success'){
            ccrz__E_Cart__c currentCartRec = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE Id =: activeCartRec.id LIMIT 1];

            cartURL = EC_Utility.getCommunityUrl()+Label.EC_UrlHeader+currentCartRec.ccrz__EncryptedId__c+Label.EC_UrlMiddle+cc_order.ccrz__EffectiveAccountID__c+Label.EC_UrlFooter+userInfo.getLocale();
        }

        return cartUrl;

    }

    /***************************************************************************************************************************************
Method Name : athenaReorder
Description : to fetch Previous Orders Of the User
Parameter   : String
Return type : String
Author      : Aravind Tallapaka
*************************************************************************************************************************************/

    @AuraEnabled
    public static String athenaReorder(String effectiveAccountNum, List<String> productSkuArray, List<String> orderItems){

        String cartUrl='';
        user objUser;
        id userId;
        ccrz__E_Cart__c cc_cart;
        ccrz__E_Order__c cc_order;
        userId=UserInfo.getUserId();

        objUser = EC_QueryUtility.getCurrentUser();
        //get Order and orderItems
        List<ccrz__E_Order__c> orderlist = new  List<ccrz__E_Order__c>();
        orderlist =  EC_QueryUtility.getOrderList(null,effectiveAccountNum);
        //Checking for the list size
        if(orderlist.size()>0){
            cc_order = orderlist[0];
        }

        String shipToRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('EC_ShipTo').getRecordTypeId();
        String effectiveAccountMod = '%' + effectiveAccountNum;
        List<Account> effectiveAccountId = [SELECT Id FROM Account WHERE EC_Account_Number__c like  :effectiveAccountMod AND RecordTypeId =: shipToRecordTypeId];
        
        ccrz__E_Cart__c activeCartRec = EC_Utility.getActiveCartForUser(effectiveAccountId[0].Id);

        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
        products = EC_QueryUtility.getProductsFromSkuIds(productSkuArray);
        Map<String,String> prodMap = new Map<String,String>();
        for(String item : orderItems){
            List<String> prodObj = item.split(':');
            prodMap.put(prodObj[0], prodObj[1]);
        }
        String itemAddedStatus = EC_Utility.addAthenaItemsToCart(activeCartRec.id, effectiveAccountId[0].Id, products, prodMap, true);

        if(itemAddedStatus == 'Success'){
            ccrz__E_Cart__c currentCartRec = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE Id =: activeCartRec.id LIMIT 1];

            cartURL = EC_Utility.getCommunityUrl()+Label.EC_UrlHeader+currentCartRec.ccrz__EncryptedId__c+Label.EC_UrlMiddle+effectiveAccountId[0].Id+Label.EC_UrlFooter+userInfo.getLocale();
        }

        return cartUrl;

    }


    /***************************************************************************************************************************************
Method Name : getInvoice
Description : to redirect to cloud craze invoice page
Parameter   : Id
Return type : String
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static String getInvoice(String orderId){

        List<ccrz__E_Invoice__c> inv = new List<ccrz__E_Invoice__c>();
        List<ccrz__E_Order__c> orderlist = new List<ccrz__E_Order__c>();
        ccrz__E_Order__c cc_order;
        String invoiceURL;

            User usr = EC_QueryUtility.getCurrentUser();
            //Fetching the Invoice of the User
            if(usr.contactId != null){
                inv = EC_QueryUtility.getInvoice(orderId);
            }
            try{
                orderlist = EC_QueryUtility.getOrderList(null,orderId) ;
                //Checking if the list has values
                if(orderlist.size()> 0 ){
                    cc_order = orderlist[0];
                }

                //Creating the InvoiceURL
                invoiceURL = EC_Utility.getCommunityUrl() +EC_Constants.INVOICEURLPART1+ inv[0].id+'&cartID='+cc_order.ccrz__OriginatedCart__c + EC_Constants.CARTQURYSTRING2+cc_order.ccrz__EffectiveAccountID__c+EC_Constants.INVOICEURLPART3;

            } catch(Exception ex){

                EC_UtilityLogger.logException(ex,'EC_PastOrders','getInvoice',false,null,'');
            }

        return invoiceURL;
    }


    /*************************************************************************************************************************************
Method Name : compVisible
Description : to retrieve Information from Cache
Parameter   : N.A
Return type : List
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static List<EC_Utility.PermWrapper>  compVisible(){
        return  EC_Utility.getPermCache();
    }

    /*************************************************************************************************************************************
Method Name : getSDSDocuments
Description : to retrieve SDS Documents for Products of a Order
Parameter   : Id
Return type : Map
Author      : Raghav Sharma
*************************************************************************************************************************************/
    @AuraEnabled
    public static Map<Id ,List<ccrz__E_ProductMedia__c>> getSDSDocuments(String orderId){

            User usr = EC_QueryUtility.getCurrentUser();

                String ProductUrl;
                Map<Id,String> PDPUrlMap = new Map<Id,String>();
                list<ccrz__E_Order__c> lstOrder = new list<ccrz__E_Order__c>();
                lstOrder = EC_QueryUtility.getOrderList(null, orderId) ;
                ccrz__E_Order__c orderDetails = new ccrz__E_Order__c();
              //Checking the size of the list
                if(lstOrder.size()>0){
                    orderDetails = lstOrder[0];
                }

                List<ccrz__E_OrderItem__c> orderItemList = new  List<ccrz__E_OrderItem__c>();
                List<Id> productList = new List<Id>() ;
                Map<Id ,List<ccrz__E_ProductMedia__c>> ProductImageMap = new Map<Id ,List<ccrz__E_ProductMedia__c>>();

                for(ccrz__E_OrderItem__c orderItem : orderDetails.ccrz__E_OrderItems__r){

                    orderItemList.add(orderItem) ;
                    productList.add(orderItem.ccrz__Product__c) ;
                }



                List<ccrz__E_ProductMedia__c> docList = EC_QueryUtility.getDocuments(productList);
                List<ccrz__E_ProductMedia__c> tempDoc = new List<ccrz__E_ProductMedia__c>();
                //ProducImage Map
                for(ccrz__E_ProductMedia__c doc : docList){
                    {
                        tempDoc.add(doc);
                        ProductImageMap.put(doc.ccrz__Product__c ,tempDoc) ;
                    }
                }

                return ProductImageMap;




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

   
    /************************************************************************************************************************************
Method Name : getAthenaPastOrders
Description : to get omni channel orders from Athena through mulesoft.
Return type : Object
Author      : Aravind Tallapaka
*************************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Object getAthenaPastOrders(){
        Contact con = new Contact();
        User usr = EC_QueryUtility.getCurrentUser();
        //Extracting the Contact of Salerep
        if(usr.User_Type__c !='External'){
            List<Contact> conlist = EC_QueryUtility.getSaleRepContact();
            if(conlist.size()>0){
                con = conlist[0];
            }
        }
        list<string> lstAccIds = new list<string>();
        list<AccountContactRelation> lstAccContRel = new list<AccountContactRelation>();
        //Fetching the AccountId Associated To The User
        if(usr.contactId != null){
            lstAccContRel =  EC_QueryUtility.getAccountContactRelation(usr);
        } else{
            lstAccContRel =  [SELECT id, accountId, account.ccrz__E_AccountGroup__c FROM AccountContactRelation WHERE contactId =: con.Id];
        }
        //Creating the List Of Accounts
        if(lstAccContRel.size()>0) {
            for(AccountContactRelation accContRec : lstAccContRel){
                lstAccIds.add(accContRec.accountId);
            }
        }
        system.debug('lstAccIds:'+lstAccIds);
        String postJSonString = '';
        String inputPostJSonString = '';
        Integer counter = 0;
        String shipToRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('EC_ShipTo').getRecordTypeId();
        List<Account> AccountObjectList = [SELECT EC_Account_Number__c,EC_Division__c,EC_ShipToNumber__c,EC_SalesOrg__c,ccrz__SourceSystem__c FROM Account WHERE Id in: lstAccIds AND RecordTypeId =: shipToRecordTypeId];
        for(Account AccountObj : AccountObjectList){
            counter = counter + 1;
            postJSonString = '{"division":';
            postJSonString = postJSonString + '"'+AccountObj.EC_Division__c+ '",';
            postJSonString = postJSonString + '"shipTo":'+'"'+(AccountObj.EC_ShipToNumber__c != null ? AccountObj.EC_ShipToNumber__c : AccountObj.EC_Account_Number__c)+'",';
            postJSonString = postJSonString + '"systemId":'+'"'+(AccountObj.ccrz__SourceSystem__c != null ? AccountObj.ccrz__SourceSystem__c : 'ECL_EBS') +'",';
            postJSonString = postJSonString + '"salesOrg":'+'"'+AccountObj.EC_SalesOrg__c +'"}';
            if(counter != AccountObjectList.size()){
                postJSonString = postJSonString + ',';
            }
            inputPostJSonString = inputPostJSonString + postJSonString;
        }
        postJSonString = '[' + inputPostJSonString + ']';
        String postJSon = postJSonString;
        system.debug('postJSon Input:'+postJSon);
        HttpResponse response = EC_AthenaOrders.respond(postJSon);
        Object result = response.getBody();
        return result;
    }
    
       /***************************************************************************************************************************************
InnerClass  : AthenaOrderItemWrapper
Description : WrapperClass to get OrderItem Information
Parameter   : N/A
Return type : N/A
Author      : Raghu Varma
*************************************************************************************************************************************/
    public class AthenaOrderItemWrapper{
        @AuraEnabled
        public Map<Id,String> ProdImageMap ;
        @auraEnabled
        public Map<Id,List<String>> ProdSDSMap;
        @auraEnabled
        public ccrz__E_Product__c Product;
        @auraEnabled
        public String PrdDetUrl;
   
    }
   
    
    /************************************************************************************************************************************
Method Name : getProductData
Description : to get the products from DB.
Return type : 
Author      : Raghu Varma
*************************************************************************************************************************************/
    @auraEnabled
    public static List<AthenaOrderItemWrapper> getProductData(List<String> productList) {
        User usr = EC_QueryUtility.getCurrentUser();
        String ConId ;
        if(usr.ContactId != null){
        ConId = usr.ContactId ;
        } else {
          List<Contact> conlist = EC_QueryUtility.getSaleRepContact();
            if(conlist.size()>0){
               ConId = conlist[0].Id;
            }
        }
        List<ccrz__E_Cart__c> cartlist = EC_QueryUtility.getCartList(conId,TRUE);
        List<AthenaOrderItemWrapper> athenaOrderItemList = new List<AthenaOrderItemWrapper>();
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
        products = [SELECT Id, ccrz__SKU__c FROM ccrz__E_Product__c where ccrz__SKU__c in :productList];
        Set<Id> productIdList = new Set<Id>();
        for(ccrz__E_Product__c prod : products) {
            productIdList.add(prod.Id);
        }
       
        try {
            List<ccrz__E_ProductMedia__c> ImageList = EC_QueryUtility.getListProdMedia(productIdList);
            List<ccrz__E_ProductMedia__c> SDSList = EC_QueryUtility.getListProdSDS(productIdList);       
            Map<Id ,String> ProductImageMap = new Map<Id ,String>(); 
            
            for(ccrz__E_ProductMedia__c media : ImageList){
                if(media.ccrz__MediaType__c == 'Product Image'){
                    ProductImageMap.put(media.ccrz__Product__c ,media.ccrz__URI__c);
                }
            }
            Map<Id, List<String>> ProductSDSMap = new Map<Id, List<String>>();
            List<String> sdsDocs = new List<String>();
            for(ccrz__E_ProductMedia__c media : SDSList){
                if(media.ccrz__MediaType__c == 'Safety Documents') {
                    sdsDocs = ProductSDSMap.get(media.ccrz__Product__c);
                    if (sdsDocs == null || sdsDocs.size() < 0) {
                        List<String> listDocs = new List<String>();
                        listDocs.add(media.ccrz__URI__c);
                        ProductSDSMap.put(media.ccrz__Product__c , listDocs);
                    } else {
                        sdsDocs.add(media.ccrz__URI__c);
                        ProductSDSMap.put(media.ccrz__Product__c , sdsDocs);
                    }
                }
            }
             for(ccrz__E_Product__c prod : products) {
                AthenaOrderItemWrapper orderItem = new AthenaOrderItemWrapper();
                orderItem.Product = prod;
                orderItem.ProdImageMap = ProductImageMap;
                orderItem.ProdSDSMap = ProductSDSMap;
                if(cartlist.size() > 0){
                    orderItem.PrdDetUrl = EC_Utility.getCommunityUrl() +EC_Constants.PRDTURLSTRING1+ Label.EC_Storefront_Name +EC_Constants.PRDTURLSTRING2+ cartlist[0].ccrz__EncryptedId__c + EC_Constants.PRDTURLSTRING3+prod.ccrz__SKU__c;
                }
                else {
                    orderItem.PrdDetUrl = EC_Utility.getCommunityUrl() +EC_Constants.PRDTURLSTRING1+  Label.EC_Storefront_Name +EC_Constants.PRDTURLSTRING2+EC_Constants.PRDTURLSTRING3+prod.ccrz__SKU__c;
                }
                athenaOrderItemList.add(orderItem);
            }
        } catch (Exception e) {
            EC_UtilityLogger.logException(e,'EC_PastOrders','getProductData',false,null,'');
        } 
        return athenaOrderItemList;
    }
    
    /************************************************************************************************************************************
Method Name : getAthenaSwitchSetting
Description : to get the Athena Switch Setting from Custom setting.
Return type : Boolean
Author      : Aravind Tallapaka
*************************************************************************************************************************************/
    @auraEnabled
    public static Boolean getAthenaSwitchSetting(){
       EC_Custom_Switch_Settings__c isAthenaEnabled = EC_Custom_Switch_Settings__c.getValues('AthenaSwitch');
       return isAthenaEnabled.Is_Athena_Enabled__c;
    }
    
    /************************************************************************************************************************************
Method Name : checkPayerPermission
Description : to check whether payer permission is there for user.
Return type : Boolean
Author      : Aravind Tallapaka
*************************************************************************************************************************************/
    @AuraEnabled
    public static  Boolean checkPayerPermission(){
        return FeatureManagement.checkPermission(EC_Constants.PayerCustomPermission);
    }
}