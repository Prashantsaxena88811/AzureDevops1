/* Class Name    : EC_OrderAcknowledgement
 * Description      :Controller Class for Order Acknowledgement Email Component
 * Created By       :Priyanka Priya
 * Created On       :2019-Jul-31


 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Priyanka Priya    2019-Jul-31       BC-74097        Created the class
 *
 */
public class EC_OrderAcknowledgement {

    public String resourcePath { get; set; }

    public Id ordId {get;set;}
    /***************************************************************************************************************************************
  Method Name : getOrderInfoWrapper
  Description : prepares the order and order item data for the email
  Return type : Returns orderInfoWrapper
 **************************************************************************************************************************************/
    public orderInfoWrapper getOrderInfoWrapper()
    {
        orderInfoWrapper orderInfoWrapper= new orderInfoWrapper();
        List<ccrz__E_Order__c> orders = new List<ccrz__E_Order__c>();
        orders = [SELECT id,ccrz__OrderNumber__c,ccrz__OriginatedCart__r.ccrz__BuyerEmail__c,ccrz__OriginatedCart__r.ccrz__BuyerPhone__c,ccrz__OrderName__c,
                    ccrz__OriginatedCart__r.EC_Ship_To_Account__r.Name,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.Ship_To_Name__c,ccrz__Account__r.EC_Account_Number__c,ccrz__CurrencyISOCode__c, ccrz__PaymentMethod__c, createdDate,
                    ccrz__RequestDate__c,EC_TotalQuantity__c, Name,ccrz__TotalAmount__c,ccrz__SubtotalAmount__c,ccrz__BuyerEmail__c,ccrz__BuyerFirstName__c,ccrz__BuyerLastName__c,
                    ccrz__OrderDate__c,ccrz__BuyerPhone__c,ccrz__ShipTo__r.ccrz__AddressFirstline__c,ccrz__ShipTo__r.ccrz__AddressSecondline__c,ccrz__ShipTo__r.ccrz__AddressThirdline__c,
                    ccrz__ShipTo__r.ccrz__City__c,ccrz__ShipTo__r.ccrz__Country__c,ccrz__ShipTo__r.ccrz__PostalCode__c,ccrz__ShipTo__r.ccrz__State__c,
                    ccrz__OriginatedCart__r.EC_AttentionTo__c,ccrz__OriginatedCart__r.EC_Attention_To_Number__c,ccrz__OriginatedCart__r.EC_Is_Requested_Date_Valid__c,
                    ccrz__OriginatedCart__r.EC_Sold_To_Account__r.EC_Account_Number__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c,
                    ccrz__OriginatedCart__r.ccrz__PONumber__c, ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__AddressSecondline__c,
                    ccrz__BillTo__r.ccrz__AddressThirdline__c,ccrz__BillTo__r.ccrz__City__c,ccrz__BillTo__r.ccrz__Country__c,ccrz__BillTo__r.ccrz__PostalCode__c,
                    ccrz__BillTo__r.ccrz__State__c,ccrz__BillTo__r.ccrz__CountryISOCode__c,ccrz__Account__r.EC_Division__c,EC_Division__c,ccrz__OriginatedCart__r.ccrz__EffectiveAccountID__c FROM ccrz__E_Order__c where id=:ordId];
        List<ccrz__E_OrderItem__c> orderItemList = [Select Id,Tank_Number__c,Tank_Number__r.Tank_Number__c,Unloading_Point__r.ccrz__CompanyName__c,Billing_Arrangement__r.BA_Number__c,ccrz__Product_Name__c,ccrz__Order__c,ccrz__Product__r.ccrz__SKU__c,
                                                    ccrz__Product__r.EC_Display_SKU__c,ccrz__Product__r.ccrz__ShortDesc__c,ccrz__Product__r.ccrz__UnitOfMeasure__c,ccrz__Product__r.Package_Code__c,ccrz__Product__r.Taxonomy__c,
                                                    ccrz__Quantity__c,ccrz__Price__c,ccrz__ItemTotal__c,ccrz__Product__c,Custom_UnitPrice__c,Custom_PricingUOM__c,Custom_Factor__c,Price_Per__c
                                                     from ccrz__E_OrderItem__c where ccrz__Order__c=:orders[0].id];

        List<ccrz__E_PaymentDetail__c> paymentDetail = [SELECT id,ccrz__Payment_Method__c,ccrz__CC_Order__c,ccrz__Cart__c,ccrz__Credit_Card_Type__c from ccrz__E_PaymentDetail__c where ccrz__Cart__c = :orders[0].ccrz__OriginatedCart__c Order By CreatedDate DESC];
        List<ccrz__E_CartCoupon__c> cartCoupon = [SELECT id,ccrz__Cart__c ,ccrz__Coupon__r.ccrz__CouponCode__c FROM ccrz__E_CartCoupon__c WHERE ccrz__Cart__c = :orders[0].ccrz__OriginatedCart__c];
        ccrz.ccLog.log('orderItemList-' + orderItemList );
        if(orders.size()>0)
        {
            if(paymentDetail.size()>0 && orders[0].ccrz__PaymentMethod__c == 'CC'){
                orderInfoWrapper.cardType= paymentDetail[0].ccrz__Credit_Card_Type__c;
            }
            if(cartCoupon.size()>0){
                orderInfoWrapper.couponCode = cartCoupon[0].ccrz__Coupon__r.ccrz__CouponCode__c;
            }
            orderInfoWrapper.buyerFirstName=orders[0].ccrz__BuyerFirstName__c;
            orderInfoWrapper.buyerLastName= orders[0].ccrz__BuyerLastName__c;
            orderInfoWrapper.buyerEmail=orders[0].ccrz__OriginatedCart__r.ccrz__BuyerEmail__c;
            orderInfoWrapper.buyerPhone=orders[0].ccrz__OriginatedCart__r.ccrz__BuyerPhone__c;
            orderInfoWrapper.isRequesteDateValid = orders[0].ccrz__OriginatedCart__r.EC_Is_Requested_Date_Valid__c;
            orderInfoWrapper.paymentMethod = orders[0].ccrz__PaymentMethod__c;
            List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermCache();
            for(EC_Utility.PermWrapper perm : permWrapperLst){
                if(perm.permName == 'Billing Arrangement'){
                    orderInfoWrapper.BAUser = String.valueOf(perm.permVal);
                }
            }
            
            if(orders[0].EC_Division__c!=null) {
                String division = System.label.EC_Division;
                String divisions = System.label.EC_DivisionValueNACLO;
                List<String> lst = divisions.split(',');
                if(lst.contains(String.valueof(orders[0].EC_Division__c))) {
                    orderInfoWrapper.ECDivision = String.valueof(division);
                }
            }
            integer hours;
            string amPm;
            if(orders[0].createdDate!=null){
            DateTime ordDate=orders[0].createdDate;
                string odate=ordDate.format('MMM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().getID());
                string omonth=ordDate.format('MMMMM', UserInfo.getTimeZone().getID());
                //string month=odate.substring(0, 3);
                string day = odate.substring(4, 6);
                string year = odate.substring(7,11);
                string hourss = odate.substring(12,14);
                string minutes= odate.substring(15,17);
                if(integer.valueOf(hourss)>12){
                    hours = integer.valueOf(hourss) - 12;
                    amPm = 'pm';
                }
                else if(integer.valueOf(hourss)==12){
                    hours = integer.valueOf(hourss);
                    amPm = 'pm';
                }
                else{
                    hours=integer.valueOf(hourss);
                    amPm = 'am';
                }
                string formatteddatetimeZone= omonth+ ' '+day+', '+year+' at '+ hours + ':'+minutes+amPm;
                 formatteddatetimeZone = formatteddatetimeZone + ' '+ UserInfo.getTimeZone();
            orderInfoWrapper.orderDate=formatteddatetimeZone;
            }
            if(orders[0].ccrz__RequestDate__c!=null){
            DateTime reqDate = orders[0].ccrz__RequestDate__c;
            String formattedReqDate=reqDate.format('MM/dd/yyyy','GMT');
            orderInfoWrapper.requestedDate= formattedReqDate;
            }
            orderInfoWrapper.subTotal=orders[0].ccrz__SubtotalAmount__c;
            orderInfoWrapper.total=orders[0].ccrz__TotalAmount__c;
            orderInfoWrapper.totalQuantity=orders[0].EC_TotalQuantity__c;
            orderInfoWrapper.orderNum=orders[0].ccrz__OrderName__c;
            orderInfoWrapper.accountNumber=orders[0].ccrz__OriginatedCart__r.EC_Sold_To_Account__r.EC_Account_Number__c;
            orderInfoWrapper.shipToId=orders[0].ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c;
            orderInfoWrapper.accountName=orders[0].ccrz__OriginatedCart__r.EC_Ship_To_Account__r.Name;
            orderInfoWrapper.shipToName = orders[0].ccrz__OriginatedCart__r.EC_Ship_To_Account__r.Ship_To_Name__c;
            orderInfoWrapper.shipTostate = orders[0].ccrz__ShipTo__r.ccrz__State__c;
            orderInfoWrapper.shipTocity = orders[0].ccrz__ShipTo__r.ccrz__City__c;
            orderInfoWrapper.shipTocountry = orders[0].ccrz__ShipTo__r.ccrz__Country__c;
            orderInfoWrapper.shipTopostalCode = orders[0].ccrz__ShipTo__r.ccrz__PostalCode__c;
            orderInfoWrapper.billTostate = orders[0].ccrz__BillTo__r.ccrz__State__c;
            orderInfoWrapper.billTocity = orders[0].ccrz__BillTo__r.ccrz__City__c;
            orderInfoWrapper.billTocountry = orders[0].ccrz__BillTo__r.ccrz__Country__c;
            orderInfoWrapper.billTopostalCode = orders[0].ccrz__BillTo__r.ccrz__PostalCode__c;
            orderInfoWrapper.attentionTo = orders[0].ccrz__OriginatedCart__r.EC_AttentionTo__c;
            orderInfoWrapper.attentionToNumber = orders[0].ccrz__OriginatedCart__r.EC_Attention_To_Number__c;
            orderInfoWrapper.poNumber= orders[0].ccrz__OriginatedCart__r.ccrz__PONumber__c;
            orderInfoWrapper.billToaddressLine1=orders[0].ccrz__BillTo__r.ccrz__AddressFirstline__c;
            orderInfoWrapper.billToaddressLine2=orders[0].ccrz__BillTo__r.ccrz__AddressSecondline__c;
            orderInfoWrapper.billToaddressLine3=orders[0].ccrz__ShipTo__r.ccrz__AddressThirdline__c;
            orderInfoWrapper.shipToaddressLine1=orders[0].ccrz__ShipTo__r.ccrz__AddressFirstline__c;
            orderInfoWrapper.shipToaddressLine2=orders[0].ccrz__ShipTo__r.ccrz__AddressSecondline__c;
            orderInfoWrapper.shipToaddressLine3=orders[0].ccrz__ShipTo__r.ccrz__AddressThirdline__c;
            orderInfoWrapper.baNums = '';
            orderInfoWrapper.currencyIsoCode=orders[0].ccrz__CurrencyISOCode__c;
        }
        List<ccrz__E_ProductMedia__c> imageList;
        List<OrderItemWrapper> orderItems= new List<OrderItemWrapper>();
        Set<Id> orderItemIds = new Set<Id>();
        for(ccrz__E_OrderItem__c orderItem : orderItemList){
            orderItemIds.add(orderItem.ccrz__Product__c);
        }
        String effAccountId = orders[0].ccrz__OriginatedCart__r.ccrz__EffectiveAccountID__c;
        List<Account> effAccountList = [Select Id,EC_SalesOrg__c,EC_Division__c,ccrz__E_AccountGroup__c FROM Account WHERE Id=:effAccountId LIMIT 1];
        Set<Id> acctGrpSet = new Set<Id>();
        if(!effAccountList.isEmpty()) {
            for(Account effAccount: effAccountList) {
                acctGrpSet.add(effAccount.ccrz__E_AccountGroup__c);
            }
        }
        Map<Id, Boolean> mapOrderItemFlatfee = EC_QueryUtility.getProdPricelistItems(orderItemIds,acctGrpSet);
        Map<Id, ccrz__E_ProductMedia__c> mapOrderItem = new Map<Id, ccrz__E_ProductMedia__c>([Select ccrz__URI__c,ccrz__MediaType__c,ccrz__Product__c  from ccrz__E_ProductMedia__c where ccrz__Product__c IN :orderItemIds and ccrz__enabled__c = true]);
        imageList = mapOrderItem.values();
        if(orderItemList.size()>0){
            for(ccrz__E_OrderItem__c orderItem : orderItemList){
                OrderItemWrapper ordItemDet = new OrderItemWrapper() ;
                 if(mapOrderItemFlatfee != null) {
                    if(mapOrderItemFlatfee.containsKey(orderItem.ccrz__Product__c)){
                        ordItemDet.isFlatFeeProduct = true;
                        orderInfoWrapper.isFlatFeeOrder = true;
                    } else {
                        ordItemDet.isFlatFeeProduct = false;
                    }
                }
                ordItemDet.ProdName = orderItem.ccrz__Product_Name__c ;
                ordItemDet.orderItemTotalPrice = orderItem.ccrz__ItemTotal__c;
                ordItemDet.ProdCode = orderItem.ccrz__Product__r.ccrz__SKU__c;
                ordItemDet.TankNumber = orderItem.Tank_Number__r.Tank_Number__c;
                ordItemDet.UnloadingPoint = orderItem.Unloading_Point__r.ccrz__CompanyName__c;
                ordItemDet.paymentType = orderItem.Billing_Arrangement__r.BA_Number__c;
                if (orderItem.Billing_Arrangement__c!=NULL && orderItem.Billing_Arrangement__r.BA_Number__c != null) {
                    if (orderInfoWrapper.baNums.indexOf(orderItem.Billing_Arrangement__r.BA_Number__c) < 0) {
                        orderInfoWrapper.baNums += ordItemDet.paymentType +', ';
                    }
                    ordItemDet.paymentType = 'BA: ' + orderItem.Billing_Arrangement__r.BA_Number__c;
                    ordItemDet.hasBillingArrangement = true;
                } else {
                    ordItemDet.paymentType = orderInfoWrapper.paymentMethod + ': ' + orderInfoWrapper.poNumber;
                    ordItemDet.hasBillingArrangement = false;
                    if (orderInfoWrapper.paymentMethod == 'CC') {
                        ordItemDet.paymentType = 'Credit Card';
                    }
                }
                if(orderItem.Custom_UnitPrice__c !=null) {ordItemDet.CustomUnitPrice = orderItem.Custom_UnitPrice__c;}
                if(orderItem.Custom_PricingUOM__c !=null) {ordItemDet.CustomPricingUOM = orderItem.Custom_PricingUOM__c;}
                if(orderItem.Custom_Factor__c !=null) {ordItemDet.CustomFactor = Integer.ValueOf(orderItem.Custom_Factor__c);}
                if(orderItem.Price_Per__c !=null) {ordItemDet.PricePer = Integer.ValueOf(orderItem.Price_Per__c);}
                if(orderItem.ccrz__Product__r.Taxonomy__c !=null) {ordItemDet.Taxonomy =  orderItem.ccrz__Product__r.Taxonomy__c;}                      
                        if(orderItem.ccrz__Price__c !=null)
                        {
                            ordItemDet.UnitPrice = String.ValueOf(orderItem.ccrz__Price__c );
                        }
                        if(orderItem.ccrz__Quantity__c !=null)
                        {
                            ordItemDet.OrdQuantity =  String.ValueOf(orderItem.ccrz__Quantity__c) ;
                        }
                        if(orderItem.ccrz__Product__r.ccrz__UnitOfMeasure__c !=null)
                        {
                            ordItemDet.ProdUOM  = String.ValueOf(orderItem.ccrz__Product__r.ccrz__UnitOfMeasure__c);
                        }
                        if(orderItem.ccrz__Product__r.ccrz__ShortDesc__c !=null)
                        {
                            ordItemDet.shortDesc= orderItem.ccrz__Product__r.ccrz__ShortDesc__c;
                        }
                        for(ccrz__E_ProductMedia__c images : imageList){
                            if(orderItem.ccrz__Product__c==images.ccrz__Product__c){
                            if(images.ccrz__MediaType__c=='Product Image Thumbnail'){
                            ordItemDet.productMediaURI=images.ccrz__URI__c;
                            }
                            }
                        }
                List<Chemical_Product_Type__c> pkgTypes = new List<Chemical_Product_Type__c>();
                pkgTypes = Chemical_Product_Type__c.getall().values();
                Set<String> pkgCodeSet = new Set<String>();
                if(!pkgTypes.isEmpty()) {
                    for (Chemical_Product_Type__c pkgType : pkgTypes) {
                        if(pkgType.Active__c == true) {
                            pkgCodeSet.add(pkgType.Package_Code__c);
                        }
                    }
                }
                if(!pkgCodeSet.isEmpty() && pkgCodeSet.contains(orderItem.ccrz__Product__r.Package_Code__c)) {
                    ordItemDet.packageTypeUOM = 'Bulk';
                } else {
                    ordItemDet.packageTypeUOM = 'NonBulk';
                }

                orderItems.add(ordItemDet);
            }
        }
        
        if(orderInfoWrapper.baNums!=NULL && orderInfoWrapper.baNums.endsWith(', ')) {
            orderInfoWrapper.baNums= orderInfoWrapper.baNums.substring(0, orderInfoWrapper.baNums.length() - 2);
         }
        orderInfoWrapper.orderItem=orderItems;
        return orderInfoWrapper;
    }
    /***************************************************************************************************************************************
  Class Name : orderInfoWrapper
  Description : Wrapper Class for CC Order Data
  Return type : N/A
 *************************************************************************************************************************************/
    public class orderInfoWrapper{
        public string ECDivision{get;set;}
        public string buyerFirstName{get;set;}
        public string buyerLastName{get;set;}
        public string buyerEmail{get;set;}
        public String buyerPhone{get;set;}
        public string orderDate{get;set;}
        public string poNumber{get;set;}
        public string requestedDate{get;set;}
        public decimal subTotal{get;set;}
        public decimal total{get;set;}
        public decimal totalQuantity{get;set;}
        public String accountNumber{get;set;}
        public string shipToId{get;set;}
        public string accountName{get;set;}
        public string shipToName{get;set;}
        public String shipTocity{get;set;}
        public String shipTocountry{get;set;}
        public String shipTopostalCode{get;set;}
        public String shipToaddressLine1{get;set;}
        public String shipToaddressLine2{get;set;}
        public String shipToaddressLine3{get;set;}
        public String shipTostate{get;set;}
        public string attentionTo{get;set;}
        public string attentionToNumber{get;set;}
        public String billTocity{get;set;}
        public String billTocountry{get;set;}
        public String billTopostalCode{get;set;}
        public String billToaddressLine1{get;set;}
        public String billToaddressLine2{get;set;}
        public String billToaddressLine3{get;set;}
        public String billTostate{get;set;}
        public String currencyIsoCode{get;set;}
        public String paymentMethod{get;set;}
        public String baNums{get;set;}
        public String BAUser{get;set;}
        public String cardType{get;set;}
        public String couponCode{get;set;}
        public String orderNum{get;set;}
        public boolean isRequesteDateValid{get;set;}
        public boolean isFlatFeeOrder{get;set;}
        public List<OrderItemWrapper> orderItem{get;set;}
    }
   /***************************************************************************************************************************************
  Class Name : OrderItemWrapper
  Description : Wrapper Class for CC Order Item Data
  Return type : N/A
 *************************************************************************************************************************************/
    public class OrderItemWrapper{

        public String ProdName{get;set;}
        public String ProdCode{get;set;}
        public String UnitPrice{get;set;}
        public String OrdQuantity{get;set;}
        public String ProdUOM{get;set;}
        public String shortDesc{get;set;}
        public String productMediaURI{get;set;}
        public decimal orderItemTotalPrice{get;set;}
        public string TankNumber{get;set;}
        public String UnloadingPoint{get;set;}
        public String paymentType{get;set;}
        public Decimal CustomUnitPrice{get;set;}
        public String CustomPricingUOM{get;set;}
        public Integer CustomFactor{get;set;}
        Public Integer PricePer{get;set;}
        public String Taxonomy{get;set;}
        public String packageTypeUOM{get;set;}
        public boolean hasBillingArrangement {get;set;}
        public boolean isFlatFeeProduct {get;set;}
    }
}