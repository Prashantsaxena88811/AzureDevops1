/********************************************************************************************************
* @Class Name    EC_OrderDAO
* @description   EC_OrderDAO is used to as DAO class for Tibco order submission
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 


public virtual class EC_OrderDAO {

    public static String DEFAULT_TRADING_PARTNER_ID = 'SALESFORCEEBS';
     public static String DEFAULT_STOREFRONT = 'shopecolab';
     
    public static final String EQUIPMENT_ORDERING_ORDER_SUBMISSION_TYPE = 'equipment_ordering';

    private EC_WebService_Setting__c wsConfig = EC_WebService_Setting__c.getAll().get('TIBCO');
    
    /***************************************************************************************************************************************
      Method Name : createPurchaseOrder
      Description : This method is used to create input for Tibco order submission and submits it to Tibco
      Return type : CalloutResult 
     **************************************************************************************************************************************/
     
    
    public CalloutResult createPurchaseOrder(ccrz__E_Order__c ccOrder) {
        
        EC_Order_Submit_Settings__mdt orderSubmitSettings = [SELECT Storefront__c,Trading_Partner_Id__c,MasterLabel FROM EC_Order_Submit_Settings__mdt Where MasterLabel = 'TIBCO' limit 1];
        
        if(orderSubmitSettings.Trading_Partner_Id__c != null && orderSubmitSettings.Trading_Partner_Id__c != '') {
            DEFAULT_TRADING_PARTNER_ID = orderSubmitSettings.Trading_Partner_Id__c;
        }
        
        if(orderSubmitSettings.Storefront__c != null && orderSubmitSettings.Storefront__c != '') {
            DEFAULT_STOREFRONT = orderSubmitSettings.Storefront__c;
        }

        String tmpFirstName;
        String tmpLastName;
        
        EC_OrderServiceCallout.HttpsEndpoint port = new EC_OrderServiceCallout.HttpsEndpoint();
        port.endpoint_x = this.wsConfig.Endpoint__c;
        
        system.debug('==== > ' + port.endpoint_x );
        

        EC_OrderServiceInput.PurchaseOrder_element wsOrder = new EC_OrderServiceInput.PurchaseOrder_element();
        wsOrder.OrderNumber             = ccOrder.Name;
        wsOrder.CustomerNumber          = ccOrder.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c;
        wsOrder.PODate                  = ccOrder.ccrz__OrderDate__c;
        wsOrder.PaymentMethod           = ccOrder.ccrz__PaymentMethod__c;
        wsOrder.RequestedDeliveryDate   = ccOrder.ccrz__RequestDate__c;
        wsOrder.StoreFront              = ccOrder.ccrz__Storefront__c;
        wsOrder.TradingPartnerID = DEFAULT_TRADING_PARTNER_ID;
        
        if(!Test.isRunningTest()){
            wsOrder.StoreFront              = DEFAULT_STOREFRONT;
        }        
        wsOrder.StoreFront = wsOrder.StoreFront.toLowerCase();
        wsOrder.TradingPartnerID = wsOrder.TradingPartnerID.toUpperCase();
  
        //System.debug('order.StoreFront: ' + wsOrder.StoreFront);
        // Guest buyers will be providing the ship and bill address.  We will use the address on file in ERP for everyone else.
        
        EC_OrderServiceInput.keyValue kv = new EC_OrderServiceInput.keyValue();
        kv.Key = 'UseAddressOnFile';
        kv.Value = 'True';

        wsOrder.KeyValues = new list<EC_OrderServiceInput.keyValue> { kv };        
        
        EC_OrderServiceInput.addressType address_Bill = new EC_OrderServiceInput.addressType();
        address_Bill.AddressLine = new list<String>{ ccOrder.ccrz__BillTo__r.ccrz__AddressFirstline__c, ccOrder.ccrz__BillTo__r.ccrz__AddressSecondline__c };
        address_Bill.City        = ccOrder.ccrz__BillTo__r.ccrz__City__c;
        address_Bill.State       = ccOrder.ccrz__BillTo__r.ccrz__StateISOCode__c;
        address_Bill.Postalcode  = ccOrder.ccrz__BillTo__r.ccrz__PostalCode__c;
        address_Bill.Country     = ccOrder.ccrz__BillTo__r.ccrz__CountryISOCode__c;
        
        EC_OrderServiceInput.contactMethod contact = new EC_OrderServiceInput.contactMethod();
        contact.type_x           = 'PR';
        contact.Phone            = ccOrder.ccrz__BuyerPhone__c;
        Contact.Email            = ccOrder.ccrz__BuyerEmail__c;
        address_Bill.Contact     = new list<EC_OrderServiceInput.contactMethod>{ Contact };
            
        EC_OrderServiceInput.partyType party_Bill = new EC_OrderServiceInput.partyType();
        party_Bill.Id          = ccOrder.ccrz__BillTo__r.Id;
        if (String.isEmpty(ccOrder.ccrz__BillTo__r.ccrz__FirstName__c)) {
            tmpFirstName = '';
        } else {
            tmpFirstName = ccOrder.ccrz__BillTo__r.ccrz__FirstName__c;
        }        
        if (String.isEmpty(ccOrder.ccrz__BillTo__r.ccrz__LastName__c)) {
            tmpLastName = '';
        } else {
            tmpLastName = ccOrder.ccrz__BillTo__r.ccrz__LastName__c;
        }
        party_Bill.Name        = (tmpFirstName + ' ' + tmpLastName).trim();
        System.debug('party_Bill.Name: ' + party_Bill.Name);
        
        party_Bill.type_x      = 'BT';
        party_Bill.Address     = address_Bill;
        
        EC_OrderServiceInput.addressType address_Ship = new EC_OrderServiceInput.addressType();
        address_Ship.AddressLine = new list<String>{ ccOrder.ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccOrder.ccrz__ShipTo__r.ccrz__AddressSecondline__c };
        address_Ship.City        = ccOrder.ccrz__ShipTo__r.ccrz__City__c;
        address_Ship.State       = ccOrder.ccrz__ShipTo__r.ccrz__StateISOCode__c;
        address_Ship.Postalcode  = ccOrder.ccrz__ShipTo__r.ccrz__PostalCode__c;
        address_Ship.Country     = ccOrder.ccrz__ShipTo__r.ccrz__CountryISOCode__c;
        
        EC_OrderServiceInput.contactMethod contact_ship = new EC_OrderServiceInput.contactMethod();
        contact_ship.type_x           = 'PR';
        contact_ship.Phone            = ccOrder.ccrz__ShipTo__r.ccrz__DaytimePhone__c;
        contact_ship.Email       = ccOrder.ccrz__BuyerEmail__c;
        address_Ship.Contact     = new list<EC_OrderServiceInput.contactMethod>{ contact_ship };
            
        EC_OrderServiceInput.partyType party_Ship = new EC_OrderServiceInput.partyType();        
        party_Ship.Id          = ccOrder.ccrz__ShipTo__r.Id;
        if (String.isEmpty(ccOrder.ccrz__ShipTo__r.ccrz__FirstName__c)) {
            tmpFirstName = '';
        } else {
            tmpFirstName = ccOrder.ccrz__ShipTo__r.ccrz__FirstName__c;
        }        
        if (String.isEmpty(ccOrder.ccrz__ShipTo__r.ccrz__LastName__c)) {
            tmpLastName = '';
        } else {
            tmpLastName = ccOrder.ccrz__ShipTo__r.ccrz__LastName__c;
        }
        party_Ship.Name        = tmpFirstName + ' ' + tmpLastName;
        System.debug('party_Ship.Name: ' + party_Ship.Name);
        party_Ship.type_x      = 'ST';
        party_Ship.Address     = address_Ship;
        
        EC_OrderServiceInput.partyType party_buyer = new EC_OrderServiceInput.partyType();        
        party_buyer.Name        = ccOrder.ccrz__BuyerFirstName__c + ' ' + ccOrder.ccrz__BuyerLastName__c;
        party_buyer.type_x      = 'BY';
        
        wsOrder.Party = new list<EC_OrderServiceInput.partyType>{ party_Bill, party_Ship, party_buyer };
        
        if(ccOrder.ccrz__PONumber__c != null && ccOrder.ccrz__PONumber__c != ''){
            
            wsOrder.PONumber = ccOrder.ccrz__PONumber__c;
            
        }
        
        

/*

        if( ccOrder.ccrz__TransactionPayments__r != null && !ccOrder.ccrz__TransactionPayments__r.isEmpty() )
        {
        
            ccrz__E_TransactionPayment__c pmtDetails = ccOrder.ccrz__TransactionPayments__r[0];
            if( ccOrder.ccrz__TransactionPayments__r[0].EC_Payment_Method__c == 'Credit Card' ) {
                //CC Details
                wsOrder.CCDetails        = new EC_OrderServiceInput.ccType();
                wsOrder.CCDetails.TokenNumber = pmtDetails.ccrz__Token__c;
                wsOrder.CCDetails.CreditCardType = pmtDetails.ccrz__PaymentType__c;
                Datetime dt = datetime.newInstance(Integer.valueOf('20' + pmtDetails.ccrz__ExpirationYear__c), Integer.valueOf(pmtDetails.ccrz__ExpirationMonth__c), 1);
                wsOrder.CCDetails.CreditCardExpirationDate = dt.format('yyyyMMdd');
                
            } else if( ccOrder.ccrz__TransactionPayments__r[0].EC_Payment_Method__c == 'PO' ) {
                wsOrder.PONumber = pmtDetails.ccrz__AccountNumber__c;
            }
            
        }
        */
        // Order Comments
        List<EC_OrderServiceInput.noteType> orderComments = new List<EC_OrderServiceInput.noteType>();

        if ( ccOrder.ccrz__ShipTo__r.ccrz__ShippingComments__c != null && ccOrder.ccrz__ShipTo__r.ccrz__ShippingComments__c != '' ) {
            System.debug('ShipTo ShippingComments = ' + ccOrder.ccrz__ShipTo__r.ccrz__ShippingComments__c);
            EC_OrderServiceInput.noteType comment = new EC_OrderServiceInput.noteType();
            comment.NoteType         = '2';
            comment.NoteText         = ccOrder.ccrz__ShipTo__r.ccrz__ShippingComments__c.replaceAll('\n',' ').replaceAll('   ',' ').replaceAll('–', '-');
            
            //wsOrder.OrderComments    = new list<EC_OrderServiceInput.noteType>{ comment };
            orderComments.add(comment);
        }
     /*   System.debug('nazia - attention : ' + ccOrder.ccrz__ShipTo__r.Attention__c);
        //Mark for attention (ECOMM-533)
        if (ccOrder.ccrz__ShipTo__r.Attention__c != null && ccOrder.ccrz__ShipTo__r.Attention__c != '' ) {
            EC_OrderServiceInput.noteType comment = new EC_OrderServiceInput.noteType();
            comment.NoteType = 'MARK_FOR_ATTENTION';
            comment.NoteText = ccOrder.ccrz__ShipTo__r.Attention__c.replaceAll('\n',' ').replaceAll('   ',' ').replaceAll('–', '-');

            orderComments.add(comment);
        }
*/
        if(orderComments.size() > 0){
            wsOrder.OrderComments = orderComments;
            System.debug('OrderComments = ' + wsOrder.OrderComments);
        }
        
        //Product Order Line Items
        wsOrder.POLineItems      = new LIST<EC_OrderServiceInput.lineItems>();
        
       LIST<ccrz__E_OrderItem__c> lineItems = ccOrder.ccrz__E_OrderItems__r;
        
        for(ccrz__E_OrderItem__c i : lineItems) { 
            if ( i.ccrz__ProductType__c != 'Coupon' ) {
                EC_OrderServiceInput.lineItems lItems = new EC_OrderServiceInput.lineItems(); 
                EC_OrderServiceInput.itemCodeType ItemCode = new EC_OrderServiceInput.itemCodeType();
                EC_OrderServiceInput.noteType lItems_comment = new EC_OrderServiceInput.noteType();
            
                ItemCode.type_x                               = 'EC';
                ItemCode.Code                                 = i.ccrz__Product__r.ccrz__SKU__c;
                lItems.ItemCode                               = new list<EC_OrderServiceInput.itemCodeType>{ ItemCode };           

                lItems.OrderedQuantity                        = i.ccrz__Quantity__c;
                lItems.UnitPrice                              = i.ccrz__Price__c;
                lItems.ProductDescription                     = i.ccrz__Product__r.Name;
                if ( i.ccrz__Comments__c != null && i.ccrz__Comments__c != '' ) {
                    lItems_comment.NoteType         = '0';
                    lItems_comment.NoteText         = i.ccrz__Comments__c;
                    lItems.LineComments = new EC_OrderServiceInput.noteType[]{ lItems_comment };
                }

                wsOrder.POLineItems.add(lItems); 
            }
        }
        
   
        wsOrder.Coupons = new LIST<EC_OrderServiceInput.couponType>();
        if ( ccOrder.ccrz__OriginatedCart__c != null ) {

            List<ccrz__E_CartCoupon__c> cartCoupons = 
                [select ccrz__Coupon__r.ccrz__CouponName__c, ccrz__Coupon__r.ccrz__CouponCode__c, ccrz__Coupon__r.ccrz__DiscountAmount__c
                 from ccrz__E_CartCoupon__c
                 where ccrz__Cart__c = :ccOrder.ccrz__OriginatedCart__c];
            System.debug('cartCoupons: ' + cartCoupons);

            for ( ccrz__E_CartCoupon__c cCoupon : cartCoupons ) {
                EC_OrderServiceInput.couponType coupon = new EC_OrderServiceInput.couponType();
                coupon.Name     = cCoupon.ccrz__Coupon__r.ccrz__CouponName__c;
                coupon.Code     = cCoupon.ccrz__Coupon__r.ccrz__CouponCode__c;
                coupon.Quantity = 1;
                coupon.Value    = cCoupon.ccrz__Coupon__r.ccrz__DiscountAmount__c;
                wsOrder.Coupons.add( coupon );
            }
        }

        wsOrder.TransportDetails = new EC_OrderServiceInput.transportationDetail();

        System.debug( 'wsOrder: ' + wsOrder );
        
       CalloutResult result = new CalloutResult();
        
        try{
            
            EC_OrderServiceOutput.OrderOutput_element resp = doCreatePurchaseOrderCallout(port, wsOrder);
            System.debug('resp: ' + resp);
            
            result.status = resp.Status;
            result.message = resp.Message;
            
            String inputReq = String.valueOf(wsOrder);
            String response = String.valueOf(result);
            String errorMessage = '';
            if(result.status != true){
                errorMessage = result.message;
            }
            String status = String.valueOf(result.status);
            result.logRec = logServiceCall(inputReq,response,errorMessage,status);
        
        }catch(Exception e){

            String inputReq = String.valueOf(wsOrder);
            String errorMessage = e.getMessage();
            result.logRec = logServiceCall(inputReq,'',errorMessage,'');
            result.ex = e;
        
        }
        
      
        return result;
    }
    
     /***************************************************************************************************************************************
      Method Name : doCreatePurchaseOrderCallout
      Description : This method is used to call submit the orders to Tibco
      Return type : EC_OrderServiceOutput.OrderOutput_element 
     **************************************************************************************************************************************/
     

    public virtual EC_OrderServiceOutput.OrderOutput_element doCreatePurchaseOrderCallout(
            EC_OrderServiceCallout.HttpsEndpoint port, EC_OrderServiceInput.PurchaseOrder_element order) {
        return port.createPurchaseOrder(order);
    }

    public class CalloutResult {
        public Boolean status;
        public String message;
        public EC_WebServiceCalloutsLog__c logRec;
        public Exception ex;
    }
    
    /***************************************************************************************************************************************
      Method Name : logServiceCall
      Description : This method is used for logging service input & output
      Return type : EC_WebServiceCalloutsLog__c 
     **************************************************************************************************************************************/
     
    
    public static EC_WebServiceCalloutsLog__c logServiceCall(String inputReq,String response,String errorMessage,String status){
        
        EC_WebServiceCalloutsLog__c logRec = new EC_WebServiceCalloutsLog__c();
        logRec.EC_RequestName__c = 'TIBCO Order Submit';
        logRec.EC_RequestCall__c = inputReq;
        logRec.EC_ResponseCall__c = response;
        logRec.EC_ErrorMessage__c = errorMessage;
        logRec.EC_Status__c = status;
        System.debug('insertLog:'+logRec);
        return logRec;

    }
}