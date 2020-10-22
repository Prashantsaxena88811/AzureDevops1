/* Class Name    : EC_OrderSubmitEmail
 * Description      :Controller Class for Order Submit Email component
 * Created By       :Ravindra Singh
 * Created On       :2019-7-31



 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ravindra Singh            2019-7-31        BC-75723       Created the class
 * Aqeeb Ahamed            26-05-2020        PBI-121182       included unloading point and tank number logic
 *
 */
public class EC_OrderSubmitEmail{

    public String ordId{get;set;}
    /***************************************************************************************************************************************
  Method Name : getOrderInfoWrapper
  Description : queries and sets the field values which are required in the Order Submit Email component
  Return type : OrderInfoWrapper
  *************************************************************************************************************************************/
   public OrderInfoWrapper getOrderInfoWrapper(){

        ccrz__E_Order__c order = [Select  Id, ccrz__Note__c,ccrz__Account__r.EC_Account_Number__c, ccrz__EffectiveAccountID__c, ccrz__Contact__r.Email , ccrz__Account__r.EC_Division__c,
        Name, ccrz__Storefront__c, ccrz__OrderStatus__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c,ccrz__BuyerEmail__c, ccrz__BuyerPhone__c, ccrz__BuyerMobilePhone__c, ccrz__PaymentMethod__c,
        ccrz__ShipComplete__c, ccrz__ShipMethod__c, ccrz__SubTotalAmount__c, ccrz__TotalDiscount__c, ccrz__ShipAmount__c, ccrz__TaxAmount__c, ccrz__TotalAmount__c, ccrz__OrderDate__c, EC_Submission_Failure_Count__c,
        ccrz__Account__r.Name, ccrz__BillTo__r.ccrz__FirstName__c , ccrz__BillTo__r.ccrz__MiddleName__c, ccrz__BillTo__r.ccrz__LastName__c, ccrz__BillTo__r.ccrz__Email__c,    ccrz__BillTo__r.ccrz__AddressFirstline__c,
        ccrz__BillTo__r.ccrz__AddressSecondLine__c, ccrz__BillTo__r.ccrz__City__c, ccrz__BillTo__r.ccrz__DaytimePhone__c, ccrz__BillTo__r.ccrz__HomePhone__c,ccrz__BillTo__r.ccrz__Partner_Id__c,
        ccrz__ShipTo__r.EC_Account_Number__c,ccrz__ShipTo__r.ccrz__DaytimePhone__c, ccrz__ShipTo__r.ccrz__HomePhone__c, ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__BillTo__r.ccrz__CountryISOCode__c,
        ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__FirstName__c    ,ccrz__ShipTo__r.ccrz__MiddleName__c, ccrz__ShipTo__r.ccrz__LastName__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c,
        ccrz__ShipTo__r.ccrz__AddressSecondLine__c,ccrz__ShipTo__r.ccrz__AddressThirdline__c,ccrz__ShipTo__r.ccrz__City__c,
        ccrz__ShipTo__r.ccrz__State__c,ccrz__ShipTo__r.ccrz__StateISOCode__c,ccrz__ShipTo__r.ccrz__CountryISOCode__c,ccrz__ShipTo__r.ccrz__Country__c, ccrz__ShipTo__r.ccrz__PostalCode__c,
        ccrz__ShipTo__r.ccrz__ShippingComments__c, ccrz__ShipTo__r.ccrz__Partner_Id__c, ccrz__OriginatedCart__c,ccrz__OriginatedCart__r.ccrz__PONumber__c,ccrz__OriginatedCart__r.EC_AttentionTo__c,
        ccrz__OriginatedCart__r.EC_Attention_To_Number__c, ccrz__PONumber__c, ccrz__RequestDate__c,EC_Order_Submission_Type__c,
        ( Select Id, Name, ccrz__ProductType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.EC_Display_SKU__c,ccrz__Product__r.Name, ccrz__Product__r.Taxonomy__c, ccrz__Quantity__c, Custom_PricingUOM__c,ccrz__Product__r.Package_Code__c,ccrz__Price__c, ccrz__SubAmount__c, ccrz__Comments__c, Tank_Number__c,Unloading_Point__c,Tank_Number__r.Tank_Number__c,Unloading_Point__r.ccrz__CompanyName__c from ccrz__E_OrderItems__r ),
        ( Select Id, Name, ccrz__Token__c,ccrz__Amount__c, ccrz__PaymentType__c, ccrz__Comments__c,ccrz__RequestAmount__c,ccrz__TransactionTS__c,ccrz__ExpirationMonth__c, ccrz__ExpirationYear__c, ccrz__AccountNumber__c,
        ccrz__TransactionCode__c,ccrz__CurrencyISOCode__c,ccrz__TransactionSubcode__c  From ccrz__TransactionPayments__r ),
        (Select Name,ccrz__Payment_Token__c,ccrz__Expiration_Month__c,ccrz__Expiration_Year__c,EC_Card_Holder_Name__c,ccrz__Credit_Card_Type__c from ccrz__E_PaymentDetails__r),
        ccrz__User__r.User_Type__c,ccrz__Contact__r.Name,ccrz__Contact__r.Phone,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.ccrz__E_AccountGroup__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c,ccrz__OriginatedCart__r.EC_Sold_To_Account__r.Name,ccrz__OriginatedCart__r.EC_Sold_To_Account__r.EC_Account_Number__c,ccrz__OriginatedCart__r.Default_Unloading_Point__c,ccrz__OriginatedCart__r.Default_Unloading_Point__r.ccrz__CompanyName__c From ccrz__E_Order__c Where id = :ordId Limit 1];


    //       ccrz__E_PaymentDetail__c paymentDetails = [Select Name,ccrz__Payment_Token__c,ccrz__Expiration_Month__c,ccrz__Expiration_Year__c,EC_Card_Holder_Name__c from ccrz__E_PaymentDetail__c where ccrz__CC_Order__c=:ordId Limit 1];



        OrderInfoWrapper orderInfoWrapper = new OrderInfoWrapper();
        OrderInfoWrapper.orderNumber = order.Name;
        orderInfoWrapper.contactEmail = order.ccrz__Contact__r.Email;
        orderInfoWrapper.soldToNumber = order.ccrz__OriginatedCart__r.EC_Sold_To_Account__r.EC_Account_Number__c;
        orderInfoWrapper.soldToName = order.ccrz__OriginatedCart__r.EC_Sold_To_Account__r.Name;
        orderInfoWrapper.BillToNumber = order.ccrz__BillTo__r.ccrz__Partner_Id__c;
        orderInfoWrapper.shipToNumber = order.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c;
        orderInfoWrapper.locationAddressLine1 = order.ccrz__ShipTo__r.ccrz__AddressFirstline__c;
        orderInfoWrapper.locationAddressLine2 = order.ccrz__ShipTo__r.ccrz__AddressSecondline__c;
        orderInfoWrapper.locationAddressLine3 = order.ccrz__ShipTo__r.ccrz__AddressThirdline__c;
        orderInfoWrapper.locationCity = order.ccrz__ShipTo__r.ccrz__City__c;
        orderInfoWrapper.locationState = order.ccrz__ShipTo__r.ccrz__State__c;
        orderInfoWrapper.locationCountry = order.ccrz__ShipTo__r.ccrz__Country__c;
        orderInfoWrapper.locationPostalCode = order.ccrz__ShipTo__r.ccrz__PostalCode__c;
        orderInfoWrapper.PONumber = order.ccrz__OriginatedCart__r.ccrz__PONumber__c;
        orderInfoWrapper.requestDeliveryDate = order.ccrz__RequestDate__c;
        orderInfoWrapper.shippingNotes = order.ccrz__Note__c;
        if(order.ccrz__OriginatedCart__r.Default_Unloading_Point__c !=null){
            orderInfoWrapper.defaultUnloadingPoint = String.isBlank(order.ccrz__OriginatedCart__r.Default_Unloading_Point__r.ccrz__CompanyName__c) ? '' :
                                                        String.valueOf(order.ccrz__OriginatedCart__r.Default_Unloading_Point__r.ccrz__CompanyName__c);
        }


        //payment details
        if(order.ccrz__E_PaymentDetails__r != null &&  !order.ccrz__E_PaymentDetails__r.isEmpty()){

            orderInfoWrapper.tokenizedCard = order.ccrz__E_PaymentDetails__r[0].ccrz__Payment_Token__c != null ? order.ccrz__E_PaymentDetails__r[0].ccrz__Payment_Token__c : '' ;
            orderInfoWrapper.cardHolderName = order.ccrz__E_PaymentDetails__r[0].EC_Card_Holder_Name__c != null ? order.ccrz__E_PaymentDetails__r[0].EC_Card_Holder_Name__c : '';
            orderInfoWrapper.cardCVV = '';
            orderInfoWrapper.cardType = order.ccrz__E_PaymentDetails__r[0].ccrz__Credit_Card_Type__c != null ? order.ccrz__E_PaymentDetails__r[0].ccrz__Credit_Card_Type__c : '' ;
            if(order.ccrz__E_PaymentDetails__r[0].ccrz__Expiration_Month__c != null && order.ccrz__E_PaymentDetails__r[0].ccrz__Expiration_Year__c != null){
                orderInfoWrapper.cardExpiration = String.valueOf(order.ccrz__E_PaymentDetails__r[0].ccrz__Expiration_Month__c) + '/' + String.valueOf(order.ccrz__E_PaymentDetails__r[0].ccrz__Expiration_Year__c);
            }else{
                orderInfoWrapper.cardExpiration = '';
            }
        }

        String accountGroup = order.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.ccrz__E_AccountGroup__c;

        List<ccrz__E_AccountGroupPriceList__c> accGrpPLList = [Select id,ccrz__AccountGroup__c,ccrz__Pricelist__r.EC_Price_List_Type__c,ccrz__Pricelist__r.Name  from ccrz__E_AccountGroupPriceList__c where ccrz__AccountGroup__c = :accountGroup and ccrz__Pricelist__r.EC_Price_List_Type__c  ='SBA'];

        List<String> spaList = new List<String>();

        if(accGrpPLList != null && accGrpPLList.size()>0){

            for(ccrz__E_AccountGroupPriceList__c accGrpPL : accGrpPLList){

            String spa = accGrpPL.ccrz__Pricelist__r.Name.subStringBefore('_SBA');

            if(spa != null && !String.isEmpty(spa)){

                spaList.add(spa);

            }

            }


        }

        if(spaList.size()>0){

            orderInfoWrapper.spaNumber = String.join(spaList,',');

        }

        orderInfoWrapper.deliveryContactNamePhone = '';

        if(order.ccrz__OriginatedCart__r.EC_AttentionTo__c != null && order.ccrz__OriginatedCart__r.EC_AttentionTo__c != ''){

            orderInfoWrapper.deliveryContactNamePhone = order.ccrz__OriginatedCart__r.EC_AttentionTo__c + ' ';

        }
        if(order.ccrz__OriginatedCart__r.EC_Attention_To_Number__c != null && order.ccrz__OriginatedCart__r.EC_Attention_To_Number__c != ''){

            orderInfoWrapper.deliveryContactNamePhone += order.ccrz__OriginatedCart__r.EC_Attention_To_Number__c ;

        }


        if(order.ccrz__TransactionPayments__r != null &&  !order.ccrz__TransactionPayments__r.isEmpty()){

                orderInfoWrapper.creditTokenNumber = order.ccrz__TransactionPayments__r[0].ccrz__Token__c;

        }
        orderInfoWrapper.bulkOrderItemsMap = new Map<String,List<OrderItemInfoWrapper>>();
        orderInfoWrapper.nonBulkOrderItemsMap = new Map<String,List<OrderItemInfoWrapper>>();
        if(order.ccrz__E_OrderItems__r != null && !order.ccrz__E_OrderItems__r.isEmpty()){
            orderInfoWrapper.isMultipleOrdersNeeded = False;
            Set<String> unloadingPointSet = new Set<String>();
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
            
            for(ccrz__E_OrderItem__c orderItem : order.ccrz__E_OrderItems__r){
                String packageCode =orderItem.ccrz__Product__r.Package_Code__c;
                OrderItemInfoWrapper orderItemInfoWrp= new OrderItemInfoWrapper();
                orderItemInfoWrp.productSku = orderItem.ccrz__Product__r.ccrz__SKU__c;
                orderItemInfoWrp.quantity = String.valueOf(orderItem.ccrz__Quantity__c);
                if(orderItem.ccrz__Product__r.Taxonomy__c == System.label.EC_Equipment){
                    orderItemInfoWrp.customPricingUOM = System.label.EC_Price_Each;
                }else{
                    if(!pkgCodeSet.isEmpty() && !pkgCodeSet.contains(packageCode)) {
                        orderItemInfoWrp.customPricingUOM = System.label.EC_Price_Each;
                    } else {
                        if(String.isNotBlank(orderItem.Custom_PricingUOM__c)){
                            orderItemInfoWrp.customPricingUOM = String.valueOf(orderItem.Custom_PricingUOM__c);
                        }
                    }
                }

                if(!String.isBlank(orderInfoWrapper.defaultUnloadingPoint)){
                    if(orderItem.Unloading_Point__c != null && !String.isBlank(orderItem.Unloading_Point__r.ccrz__CompanyName__c)){
                        String unloadingPoint = String.valueOf(orderItem.Unloading_Point__r.ccrz__CompanyName__c).toUpperCase();
                        if(String.isNotBlank(orderItem.Tank_Number__c) || orderInfoWrapper.defaultUnloadingPoint == unloadingPoint){
                            unloadingPointSet.add(orderInfoWrapper.defaultUnloadingPoint);
                            if(!orderInfoWrapper.bulkOrderItemsMap.containsKey(orderInfoWrapper.defaultUnloadingPoint)) {
                                orderInfoWrapper.bulkOrderItemsMap.put(orderInfoWrapper.defaultUnloadingPoint, new List<OrderItemInfoWrapper>());
                            }
                            if(orderItem.Tank_Number__c != null && !String.isBlank(orderItem.Tank_Number__r.Tank_Number__c)){
                                orderItemInfoWrp.tankNumber = orderItem.Tank_Number__r.Tank_Number__c;
                            }
                            orderInfoWrapper.bulkOrderItemsMap.get(orderInfoWrapper.defaultUnloadingPoint).add(orderItemInfoWrp);
                        } else{
                            unloadingPointSet.add(unloadingPoint);
                            //orderInfoWrapper.isMultipleOrdersNeeded = True;
                            if(!orderInfoWrapper.nonBulkOrderItemsMap.containsKey(unloadingPoint)) {
                                orderInfoWrapper.nonBulkOrderItemsMap.put(unloadingPoint, new List<OrderItemInfoWrapper>());
                            }
                            orderInfoWrapper.nonBulkOrderItemsMap.get(unloadingPoint).add(orderItemInfoWrp);

                        }
                    } 
                }
            }
            
            if(!unloadingPointSet.isEmpty() && unloadingPointSet.size()>1){
                orderInfoWrapper.isMultipleOrdersNeeded = True;
            }
        }
        return orderInfoWrapper;
    }
  /***************************************************************************************************************************************
  Method Name : OrderInfoWrapper
  Description : Wrapper Class for CC Order data
  *************************************************************************************************************************************/
    public class OrderInfoWrapper{
        public String orderNumber{get;set;}
        public String contactEmail{get;set;}
        public String soldToNumber{get;set;}
        public String soldToName{get;set;}
        public String BillToNumber{get;set;}
        public String shipToNumber{get;set;}
        public String locationAddressLine1{get;set;}
        public String locationAddressLine2{get;set;}
        public String locationAddressLine3{get;set;}
        public String locationCity{get;set;}
        public String locationPostalCode{get;set;}
        public String locationState{get;set;}
        public String locationCountry{get;set;}
        public String PONumber{get;set;}
        public String creditTokenNumber{get;set;}
        public Date requestDeliveryDate{get;set;}
        public String shippingNotes{get;set;}
        public String deliveryContactNamePhone{get;set;}
        public String spaNumber{get;set;}
        public String staticResourceUrl{get;set;}
        public Map<String,List<OrderItemInfoWrapper>> bulkOrderItemsMap{get;set;}
        public Map<String,List<OrderItemInfoWrapper>> nonBulkOrderItemsMap{get;set;}
        public String defaultUnloadingPoint{get;set;}
        public Boolean isMultipleOrdersNeeded{get;set;}

        //payment details
        public String tokenizedCard {get;set;}
        public String cardExpiration {get;set;}
        public String cardHolderName {get;set;}
        public String cardCVV {get;set;}
        public String cardType {get;set;}
    }
  /***************************************************************************************************************************************
  Class Name : OrderItemInfoWrapper
  Description : Wrapper Class for CC Order Item data
  *************************************************************************************************************************************/
    public class OrderItemInfoWrapper{
        public String productSku{get;set;}
        public String quantity{get;set;}
        public String tankNumber{get;set;}
        public String customPricingUOM{get;set;}
    }
  }