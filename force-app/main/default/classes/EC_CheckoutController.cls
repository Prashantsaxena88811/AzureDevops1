/*******************************************************************************************************
* @Class Name       EC_CheckoutController 
* @description      Controller Class for Checkout Component
* @Created By       Viraj 
* @Created On       2019-Jul-22
********************************************************************************************************
* Modification Log:  
* ------------------------------------------------------------------------------------------------------
* Developer                Date                         Description 
* ------------------------------------------------------------------------------------------------------
* Viraj                  2019-Jul-22              Created the class
********************************************************************************************************/
global class EC_CheckoutController {
    
    public boolean isSalesRep {get;set;}
    
  
    global static Boolean allowCC{get; set;} 
    global static Boolean allowPO{get; set;}
    global static Boolean error{get; set;}
    global static String iframesrc{get;set;}
    global static String accessToken{get;set;}
    Public Boolean isAttentionFieldsRequired {get;set;}
    global static String signature{get;set;}
    private static EC_PaymetricPaymentSetting__c settings {get;set;}
    public Boolean isFlatFeeUser {get;set;}
    global static Boolean creditCardPayment{get;set;}
    public Boolean isFBUser {get;set;}
    /***************************************************************************************************************************************
  Constructor Name : EC_CheckoutController
  Description : Constructor to initialize variables of EC_CheckoutController to be used in the component
  Return type : N/A
 *************************************************************************************************************************************/
    global EC_CheckoutController(){
        isSalesRep = false;   
        isFlatFeeUser = false;     
        isFBUser = false;
        isAttentionFieldsRequired = false;
        /*
        EC_CacheWrapper userCache = EC_CacheHelper.getCacheInfo();     
        if(userCache != null && !String.isBlank(userCache.userProfile))   {
            if(userCache.userProfile == System.Label.EC_User_Profile_Name){
                isSalesRep = true;    
            }
        }*/
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
																 
		Account effAcc = [Select EC_Division__c from Account Where Id=:ccrz.cc_CallContext.effAccountId Limit 1];
        String ccAllowedDivision = ccrz.cc_CallContext.pageLabels.get('EC_NALCO');
        if(effAcc != null && effAcc.EC_Division__c != null && effAcc.EC_Division__c == 'FOOD & BEVERAGE') {
            isFBUser = true;
        } 
           
        if(effAcc != null && effAcc.EC_Division__c != null && (effAcc.EC_Division__c == 'WATER' || effAcc.EC_Division__c == 'PAPER' || effAcc.EC_Division__c == 'ENERGY')) {
            isAttentionFieldsRequired = true;
        }
   

        EC_Payment_Setting__c paymentSettings  = EC_Payment_Setting__c.getOrgDefaults();

        creditCardPayment = paymentSettings.EC_Credit_Card_Hide__c; 
     
        if(creditCardPayment == false){
            if(effAcc != null && effAcc.EC_Division__c != null && ccAllowedDivision!=null && ccAllowedDivision.containsIgnoreCase(effAcc.EC_Division__c)){
                error = false;
                allowPO = false;  
                String storeName = System.Label.StoreNameForIFrame;
                String urlPrefix = System.Label.EC_URLPostFixCommerce;
                settings = EC_util_XiIntercept.getPaymentSetting(storeName);
                String hostname = System.Label.EC_HostNameForIframe;
                
                Map<String, String> sigValues = EC_util_XiIntercept.retrieveAccessToken(hostname, urlPrefix);
                if(sigValues.get('Error') == null){
                    iframesrc = settings.Access_Token_Endpoint__c.replace('/AccessToken','') + '/view/iframe/' + settings.MerchantGUID__c + '/' + sigValues.get('accessToken');
                    accessToken = sigValues.get('accessToken');
                    signature = sigValues.get('signature');
                    allowCC = true;
                }       
                else{
                    error = true;
                    allowCC = false;
                }
            }
				
        }
        
    }
/***************************************************************************************************************************************
  Method Name : generateIframeURL
  Description : method to generate iframe url
  Return type : ccrz.cc_RemoteActionResult
 *************************************************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult generateIframeURL(final ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult rac = new ccrz.cc_RemoteActionResult();
        rac.success = false;
        Map<String,Object> iframeResultMap = new Map<String,Object>();
        error = false;
        allowPO = false;  
        String storeName = System.Label.StoreNameForIFrame;
        String urlPrefix = System.Label.EC_URLPostFixCommerce;
        settings = EC_util_XiIntercept.getPaymentSetting(storeName);
        
        String hostname = System.Label.EC_HostNameForIframe;
        
        Map<String, String> sigValues = EC_util_XiIntercept.retrieveAccessToken(hostname, urlPrefix);
        if(sigValues.get('Error') == null){
            iframesrc = settings.Access_Token_Endpoint__c.replace('/AccessToken','') + '/view/iframe/' + settings.MerchantGUID__c + '/' + sigValues.get('accessToken');
            accessToken = sigValues.get('accessToken');
            signature = sigValues.get('signature');
            allowCC = true;
            iframeResultMap.put('iframesrc',iframesrc);
            iframeResultMap.put('accessToken',accessToken);
            iframeResultMap.put('signature',signature);
            rac.success = true;
            //return iframeResultMap;
        }       
        else{
            error = true;
            allowCC = false;
        } 
     	//return iframeResultMap;  
     	rac.data = iframeResultMap; 
     	return rac;
    }
/***************************************************************************************************************************************
  Method Name : generateIframeURL
  Description : method to regenerate iframe url if authorization gets failed
  Return type : Map<String,String>
 *************************************************************************************************************************************/
    global static Map<String,String> generateIframeURL(){
        Map<String,String> iframeResultMap = new Map<String,String>();
        error = false;
        allowPO = false;  
        String storeName = System.Label.StoreNameForIFrame;
        String urlPrefix = System.Label.EC_URLPostFixCommerce;
        settings = EC_util_XiIntercept.getPaymentSetting(storeName);
        
        String hostname = System.Label.EC_HostNameForIframe;
        
        Map<String, String> sigValues = EC_util_XiIntercept.retrieveAccessToken(hostname, urlPrefix);
        if(sigValues.get('Error') == null){
            iframesrc = settings.Access_Token_Endpoint__c.replace('/AccessToken','') + '/view/iframe/' + settings.MerchantGUID__c + '/' + sigValues.get('accessToken');
            accessToken = sigValues.get('accessToken');
            signature = sigValues.get('signature');
            allowCC = true;
            iframeResultMap.put('iframesrc',iframesrc);
            iframeResultMap.put('accessToken',accessToken);
            iframeResultMap.put('signature',signature);
            return iframeResultMap;
        }       
        else{
            error = true;
            allowCC = false;
        } 
     	return iframeResultMap;   
    }
    /***************************************************************************************************************************************
  Method Name : getProductDetails
  Description : queries the required product data for the order review page
  Return type : ccrz.cc_RemoteActionResult
 *************************************************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getProductDetails(final ccrz.cc_RemoteActionContext ctx, List<string> sfids, Boolean reqDate , String cartId) { 
        
        ccrz.cc_RemoteActionResult rac = new ccrz.cc_RemoteActionResult();
        List<ccrz__E_Cart__c> cartOb = [SELECT id,EC_Is_Requested_Date_Valid__c,ccrz__EncryptedId__c,ccrz__EffectiveAccountID__c,ccrz__BillTo__c from ccrz__E_Cart__c where id =:cartId];
        List<ccrz__E_ContactAddr__c> contacAddrList = [SELECT id,EC_Account_Number__c,ccrz__Partner_Id__c  from ccrz__E_ContactAddr__c where id=:cartOb[0].ccrz__BillTo__c];    
        
        //contacAddrList [0].ccrz__Partner_Id__c = cartOb[0].ccrz__EffectiveAccountID__c + '-' + String.valueOf(cartOb[0].id);
        cartOb[0].EC_Is_Requested_Date_Valid__c = reqDate;
        update cartOb;
        update contacAddrList;
        
        List<ccrz__E_Product__c> prodList = [SELECT id,ccrz__LongDesc__c,ccrz__LongDescRT__c,ccrz__ShortDesc__c,ccrz__ShortDescRT__c, EC_Display_SKU__c FROM ccrz__E_Product__c where id in :sfids];
        Map<String,Object> retData = new Map<String,Object>();
        retData.put('prodDetails', prodList );
        rac.data = retData ;
        return rac;
    }
    /***************************************************************************************************************************************
  Method Name : getDataDetails
  Description : queries the required product and order data for the order confirmation page
  Return type : ccrz.cc_RemoteActionResult
 *************************************************************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getDataDetails(final ccrz.cc_RemoteActionContext ctx, List<string> sfids,String orderID) { 
        
        ccrz.cc_RemoteActionResult rac = new ccrz.cc_RemoteActionResult();
        List<ccrz__E_Product__c> prodList = [SELECT id,ccrz__LongDesc__c,ccrz__LongDescRT__c,ccrz__ShortDesc__c,ccrz__ShortDescRT__c  FROM ccrz__E_Product__c where id in :sfids];
        ccrz__E_Order__c orderData = [SELECT id,ccrz__PaymentMethod__c,ccrz__OriginatedCart__r.EC_Sold_To_Account__r.Name,ccrz__OriginatedCart__r.EC_Sold_To_Account__r.EC_Account_Number__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.Name,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c from ccrz__E_Order__c where id = :orderID LIMIT 1];
        update orderData;
        Map<String,Object> retData = new Map<String,Object>();
        retData.put('orderDetails',orderData);
        retData.put('prodDetails', prodList );
        rac.data = retData ;
        return rac;
    }
    /***************************************************************************************************************************************
  Method Name : saveAdditionalCartData
  Description : saves cartdata to the cart record on click of Review Order in Order Info page
  Return type : ccrz.cc_RemoteActionResult
 *************************************************************************************************************************************/
@RemoteAction
global static ccrz.cc_RemoteActionResult saveAdditionalCartData(final ccrz.cc_RemoteActionContext ctx, String attentionTo,String attentionToNumber, String poNumber, String encryptID, String contactAddressId, String paymentMethod, Boolean isRushOrder) {         
    ccrz.cc_RemoteActionResult rac = new ccrz.cc_RemoteActionResult();
    rac.success = false;
    Map<String,Object> retData = new Map<String,Object>();
    try{           
        ccrz__E_Cart__c currentCart = [Select ccrz__PONumber__c,EC_AttentionTo__c,EC_Attention_To_Number__c,ccrz__BillTo__c,ccrz__PaymentMethod__c from ccrz__E_Cart__c Where ccrz__EncryptedId__c =:encryptID Limit 1];
        currentCart.ccrz__PaymentMethod__c= paymentMethod;
        Map<Id,ccrz__E_ContactAddr__c> billToContactAddressMap = new Map<ID,ccrz__E_ContactAddr__c> ([Select Name,EC_Account_Number__c,ccrz__AddressFirstline__c,ccrz__AddressSecondline__c,
                                                                                                   ccrz__AddressThirdline__c,ccrz__AddrReadOnly__c,ccrz__City__c,ccrz__CompanyName__c,ccrz__ContactAddrId__c,
                                                                                                   ccrz__Country__c,ccrz__CountryISOCode__c,ccrz__DaytimePhone__c,ccrz__Email__c,ccrz__FirstName__c,
                                                                                                   ccrz__HomePhone__c,ccrz__LastName__c,ccrz__MailStop__c,ccrz__MiddleName__c,ccrz__Partner_Id__c,
                                                                                                   ccrz__PostalCode__c,ccrz__ShippingComments__c,ccrz__State__c,ccrz__StateISOCode__c 
                                                                                                   from ccrz__E_ContactAddr__c where Id=: currentCart.ccrz__BillTo__c or id=:contactAddressId]);
        
        if(!billToContactAddressMap.isEmpty()){
            ccrz__E_ContactAddr__c billingAddress = billToContactAddressMap.get(currentCart.ccrz__BillTo__c);
            ccrz__E_ContactAddr__c contactAddr = billToContactAddressMap.get(contactAddressId);
            
            if(!String.isBlank(contactAddr.ccrz__AddressFirstline__c)){
                billingAddress.ccrz__AddressFirstline__c = contactAddr.ccrz__AddressFirstline__c;
            }
            if(!String.isBlank(contactAddr.ccrz__AddressSecondline__c)){
                billingAddress.ccrz__AddressSecondline__c = contactAddr.ccrz__AddressSecondline__c;
            }
            if(!String.isBlank(contactAddr.ccrz__AddressThirdline__c)){
                billingAddress.ccrz__AddressThirdline__c = contactAddr.ccrz__AddressThirdline__c;
            }
            if(!String.isBlank(contactAddr.ccrz__City__c)){
                billingAddress.ccrz__City__c = contactAddr.ccrz__City__c;
            }
            if(!String.isBlank(contactAddr.ccrz__CompanyName__c)){
                billingAddress.ccrz__CompanyName__c = contactAddr.ccrz__CompanyName__c;
            }
            if(!String.isBlank(contactAddr.ccrz__AddressFirstline__c)){
                billingAddress.ccrz__AddressFirstline__c = contactAddr.ccrz__AddressFirstline__c;
            }
            if(!String.isBlank(contactAddr.ccrz__Country__c)){
                billingAddress.ccrz__Country__c = contactAddr.ccrz__Country__c;
            }
            if(!String.isBlank(contactAddr.ccrz__CountryISOCode__c)){
                billingAddress.ccrz__CountryISOCode__c = contactAddr.ccrz__CountryISOCode__c;
            }
            if(!String.isBlank(contactAddr.ccrz__DaytimePhone__c)){
                billingAddress.ccrz__DaytimePhone__c = contactAddr.ccrz__DaytimePhone__c;
            }
            if(!String.isBlank(contactAddr.ccrz__Email__c)){
                billingAddress.ccrz__Email__c = contactAddr.ccrz__Email__c;
            }
            if(!String.isBlank(contactAddr.ccrz__FirstName__c)){
                billingAddress.ccrz__FirstName__c = contactAddr.ccrz__FirstName__c;
            }
            if(!String.isBlank(contactAddr.ccrz__HomePhone__c)){
                billingAddress.ccrz__HomePhone__c = contactAddr.ccrz__HomePhone__c;
            }
            if(!String.isBlank(contactAddr.ccrz__LastName__c)){
                billingAddress.ccrz__LastName__c = contactAddr.ccrz__LastName__c;
            }
            if(!String.isBlank(contactAddr.ccrz__MailStop__c)){
                billingAddress.ccrz__MailStop__c = contactAddr.ccrz__MailStop__c;
            }
            if(!String.isBlank(contactAddr.ccrz__MiddleName__c)){
                billingAddress.ccrz__MiddleName__c = contactAddr.ccrz__MiddleName__c;
            }
            if(!String.isBlank(contactAddr.ccrz__Partner_Id__c)){
                billingAddress.ccrz__Partner_Id__c = contactAddr.ccrz__Partner_Id__c;
            }
            if(!String.isBlank(contactAddr.ccrz__PostalCode__c)){
                billingAddress.ccrz__PostalCode__c = contactAddr.ccrz__PostalCode__c;
            }
            if(!String.isBlank(contactAddr.ccrz__ShippingComments__c)){
                billingAddress.ccrz__ShippingComments__c = contactAddr.ccrz__ShippingComments__c;
            }
            if(!String.isBlank(contactAddr.ccrz__State__c)){
                billingAddress.ccrz__State__c = contactAddr.ccrz__State__c;
            }
            if(!String.isBlank(contactAddr.ccrz__StateISOCode__c)){
                billingAddress.ccrz__StateISOCode__c = contactAddr.ccrz__StateISOCode__c;
            }   
            update billingAddress;
        }
            
            if(currentCart != null){
                if(!String.isEmpty(poNumber)){
                    currentCart.ccrz__PONumber__c = poNumber;    
                }
                if(!String.isEmpty(attentionTo)){
                    currentCart.EC_AttentionTo__c = attentionTo;
                }
                if(!String.isEmpty(attentionToNumber)){
                    currentCart.EC_Attention_To_Number__c= attentionToNumber;
                }
                if(isRushOrder) {
                    currentCart.OrderRushEmail__c= true;
                } else {
                    currentCart.OrderRushEmail__c= false;
                }
                update currentCart;
            }
            retData.put('poNumber', poNumber);
            rac.data = retData ;
            rac.success = true;
        }catch(Exception ex){
            system.debug('Exception occured '+ ex.getMessage());
        }        
        return rac;
    }
     /***************************************************************************************************************************************
  Method Name : getTokenResults 
  Description : method to get tokenized card value
  Return type : ccrz.cc_RemoteActionResult
 *************************************************************************************************************************************/
        @RemoteAction
        global static ccrz.cc_RemoteActionResult getTokenResults(final ccrz.cc_RemoteActionContext ctx, String signature, String accessToken, String currencyCode, String billingObjString){
            ccrz.cc_CallContext.initRemoteContext(ctx);
            signature = EncodingUtil.urlEncode(signature, 'UTF-8');
            Map<String, Object> dataMap = new Map<String, Object>();
            Map<String,String> queryParams = ctx.queryParams;
            String cartGUID = queryParams.get('cartID');
            ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
            res.success = false;
            
            try{    
                ccrz__E_Cart__c cart = [Select c.ccrz__Storefront__c, c.Name, c.Id, c.ccrz__TotalQuantity__c, c.ccrz__TotalDiscount__c, c.ccrz__TotalAmount__c, 
                                        c.ccrz__TaxAmount__c, c.ccrz__SubtotalAmount__c , c.ccrz__TotalSurcharge__c
                                        From ccrz__E_Cart__c c
                                        Where c.ccrz__EncryptedId__c =: cartGUID][0];
                
                system.debug('AK billingObjString'+billingObjString );
                billingObjWrapper billingObj = new billingObjWrapper();
                
                billingObj  = (billingObjWrapper )JSON.deserialize(billingObjString , billingObjWrapper .class);
                
                Decimal cartSubtotal = cart.ccrz__SubtotalAmount__c;
                
                
                Decimal shippingUpcharge = cart.ccrz__TotalSurcharge__c != null ? cart.ccrz__TotalSurcharge__c.setScale(2) : 0;
                cartSubtotal += shippingUpcharge;

                
                Boolean showMinUpcharge = cartSubtotal < 50;
                Decimal upchargeAmount = 50 - cartSubtotal;
                Decimal totalAmount = showMinUpcharge? cart.ccrz__TotalAmount__c + upchargeAmount : cart.ccrz__TotalAmount__c;
                
                dataMap.put('subtotal', cartSubtotal);
                dataMap.put('upcharge', upchargeAmount);
                dataMap.put('totalAmount', totalAmount);
                
                String erpSource = 'DefaultStore'.equalsIgnoreCase(cart.ccrz__Storefront__c) ? 'DefaultStore' : 'MAPICS';
                
                
                //first need to get the tokenized credit card data
                res.success = false;
                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setHeader('Content-Length', '0');
                req.setMethod('GET');
                req.setTimeout(120000);
                
                req.setEndpoint(EC_util_XiIntercept.settings.Access_Token_Endpoint__c.replace('/AccessToken','') + '/ResponsePacket?MerchantGUID=' + EC_util_XiIntercept.settings.MerchantGUID__c + '&Signature=' + signature + '&AccessToken=' + accessToken);
                dataMap.put('PACKETREQ', req.getEndpoint());
                httpResponse response = null;
                Http http = new Http();
                String timeStamp = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
                response = http.send(req);
                dataMap.put('TIMESTAMP', timeStamp);
                dataMap.put('PACKETRESPONSE', response.getBody());
                
                
                ccrz.cc_hk_Payment.TransactionPaymentParams transact = new ccrz.cc_hk_Payment.TransactionPaymentParams();
                
                
                String responseBody = response.getBody();
                System.debug('\n\n-----LSB response: ' + responseBody + '\n\n');
                
                ccrz.cclog.log(System.LoggingLevel.DEBUG, 'AK Credit card', responseBody);
                
                Integer index = responseBody.indexOf('<statuscode>');
                String rpStatusCode = responseBody.subString(index + 12, index + 15);
                if('102'.equalsIgnoreCase(rpStatusCode)){
                    dataMap.put('ERROR', 'DID NOT GET STATUS 100 FROM TOKEN REQUEST, GOT ' + rpStatusCode);
                }
                else{
                    
                    Integer indexStart = responseBody.indexOf('Card Holder Name</Name><Value>');                    
                    Integer indexEnd = responseBody.indexOf('</Value>',indexStart);
                    String cardHolderName = '';
                    if(indexStart != -1){
                        cardHolderName = responseBody.substring(indexStart+30, indexEnd);
                    }
                     
                    index = responseBody.indexOf('Card Number</Name><Value>');
                    String pan = '';
                    if(index != -1){
                        pan = responseBody.subString(index + 25, index + 50);
                    }
                    index = responseBody.indexOf('Card Security Code</Name><Value>');
                    String secCode = '';
                    if(index != -1){
                        secCode = responseBody.subString(index + 32, index + 36);
                    }
                    if(secCode.subString(3,4) == '<') {
                        secCode = secCode.subString(0,3);
                    }
                    
                    String cardType = '';
                    index = responseBody.indexOf('Card Type</Name><Value>');
                    if(index != -1){
                        cardType = responseBody.subString(index + 23, index + 25);
                    }

                    index = responseBody.indexOf('Expiration Year</Name><Value>');
                    String expYear = responseBody.subString(index + 29, index + 33);
                    index = responseBody.indexOf('Expiration Month</Name><Value>');
                    String expMonth = responseBody.subString(index + 30, index + 32);
                    if(expMonth.subString(1,2) == '<') { 
                        expMonth = '0' + expMonth.subString(0,1); 
                    }
                    
                    
                    
                    ccrz__E_PaymentDetail__c paymentTransact = new ccrz__E_PaymentDetail__c();
                    String tokenizedCard = pan;  
                    String cardTypeCode = '';
                    paymentTransact.ccrz__Cart__c = cart.id;
                    if(cardType.endsWithIgnoreCase('vi')){
                        paymentTransact.ccrz__Credit_Card_Type__c = 'Visa';
                        cardTypeCode = '001';
                    }else if(cardType.endsWithIgnoreCase('mc')){
                        paymentTransact.ccrz__Credit_Card_Type__c = 'Mastercard';
                        cardTypeCode = '002';
                    }
                    
                    paymentTransact.ccrz__Expiration_Month__c = expMonth;
                    paymentTransact.ccrz__Expiration_Year__c = Decimal.valueOf(expYear);
                    paymentTransact.ccrz__Payment_Method__c = 'Credit Card';
                    paymentTransact.ccrz__Payment_Token__c = tokenizedCard ; //pan.subString(pan.length() - 4, pan.length());
                    paymentTransact.ccrz__Transaction_Amount__c = totalAmount;
                    
                    paymentTransact.ccrz__Masked_Card_Number__c = tokenizedCard.substring(0,20);
                    
                    
                    //build JSON object for creating cc transaction record
                    transact.token = pan.subString(pan.length() - 4, pan.length());
                    transact.expirationMonth = Decimal.valueOf(expMonth);
                    transact.expirationYear = Decimal.valueOf(expYear);
                    transact.accountType = 'Credit Card';
                    transact.amount = totalAmount;
                    transact.requestAmount = totalAmount;
                    transact.accountNumber = '999999';
                    dataMap.put('cardType', cardType); 
                    dataMap.put('txObject', transact);
                    
                    Map<String,String> responseValidate = new Map<String,String>();
                    
                    ccrz.ccLog.log(' ashish billingObj.address1 ' + billingObj.address1);
                    ccrz.ccLog.log(' ashish billingObj.address2 ' + billingObj.address2);                    
                    responseValidate = xiPayValidate( String.valueOf(totalAmount), cardHolderName, expMonth, expYear , cardTypeCode, tokenizedCard , currencyCode, billingObj.address1, billingObj.address2, billingObj.address3, billingObj.address4,  billingObj.city,  billingObj.countryCode,  billingObj.state,  billingObj.postalCode, secCode, cart.ccrz__Storefront__c);
                    ccrz.ccLog.log(' ashish responseValidate ' + responseValidate);
                    if(!responseValidate.isEmpty()){

                        String cvv2Response = '';
                        String statusCode = '';
                        if(responseValidate.containsKey('TR_CARD_CIDRESPCODE')){
                            cvv2Response = responseValidate.get('TR_CARD_CIDRESPCODE');
                        }
                        
                        if(responseValidate.containsKey('StatusCode')){
                            statusCode = responseValidate.get('StatusCode');
                        }
                        
                        if(String.isNotBlank(cvv2Response) && !cvv2Response.equalsIgnoreCase('M')){
                            dataMap.put('ERROR', 'EXEPTION'); 
                            //generate new iframe url
                            Map<String,String> iframeMap = generateIframeURL();
                            dataMap.put('iframesrc', iframeMap.get('iframesrc'));
                            dataMap.put('accessToken', iframeMap.get('accessToken'));
                            dataMap.put('signature', iframeMap.get('signature'));                               
                            res.success = false;
                            return res;
                        }
                        
                        if(String.isNotBlank(statusCode) && !statusCode.equalsIgnoreCase('100')){
                            dataMap.put('ERROR', 'EXEPTION'); 
                            //generate new iframe url
                            Map<String,String> iframeMap = generateIframeURL();
                            dataMap.put('iframesrc', iframeMap.get('iframesrc'));
                            dataMap.put('accessToken', iframeMap.get('accessToken'));
                            dataMap.put('signature', iframeMap.get('signature'));                               
                            res.success = false;
                            return res;
                        }

                        /*
                        if(responseValidate.containsKey('AuthRespCode')){
                            if(responseValidate.get('AuthRespCode') == 'FAILED'){
                                dataMap.put('ERROR', 'EXEPTION');  
                                
                                //generate new iframe url
                                Map<String,String> iframeMap = generateIframeURL();
                                dataMap.put('iframesrc', iframeMap.get('iframesrc'));
                                dataMap.put('accessToken', iframeMap.get('accessToken'));
                                dataMap.put('signature', iframeMap.get('signature'));                               
                                res.success = false;
                                return res;
                            }
                        }*/

                    }

                    paymentTransact.ccrz__Transaction_Code__c = responseValidate.get('TransactionCode');
                    paymentTransact.ccrz__Transaction_Date__c = DateTime.now();
                    //paymentTransact.EC_Card_Holder_Name__c = cardHolderName;
                    insert paymentTransact;
                    res.success = true;
                }
            }
            catch(Exception e){
                ccrz.ccLog.log(System.LoggingLevel.DEBUG,'EXCEPTION',e);
                System.debug('\n\n ------------ InException Block: ---------------------: ' + e.getMessage());
                dataMap.put('ERROR', 'EXEPTION');          
            }
            finally{
                ccrz.ccLog.close(res);
                res.data = dataMap;
            }
            return res;
        }
        
         /***************************************************************************************************************************************
  Method Name : xiPayValidate 
  Description : method to do preauthorization of credit card
  Return type : ccrz.cc_RemoteActionResult
 *************************************************************************************************************************************/
         global static map<string, string> xiPayValidate(string totalAmount, string ccHolderName, string ccExpMon, string ccExpYear, string ccType, string ccNum, string ccCurrency, string ccAddr1, string ccAddr2, string ccAddr3, string ccAddr4,  string ccCity,  string ccCountry,  string ccState,  string ccZip, string ccCVV2, string ccStore){
            
            EC_PaymetricPaymentSetting__c setting = EC_util_XiIntercept.settings;
            map<string, string> responseStr = new map<string, string>();
            
            if(setting != null){
                String xpSoapAction = setting.XiPaySoapaction__c;
                string xpEndpoint = setting.XiPayEndpoint__c;
                String xpUN = setting.XiPayUsername__c;
                String xpPW = setting.XiPayPassword__c;
                String xpMID = setting.XiPayMerchantID__c;
                String xpAmount = '0';
                String authType = '';
                if(setting.Pre_Auth_Only__c){
                    xpAmount = setting.PreAuthAmount__c;
                    authType = 'pre_authorization';
                }else{
                    xpAmount = totalAmount;
                    authType = 'authorization';
                }
                
                String xmlBody = getXMLBody(ccHolderName, ccExpMon, ccExpYear, ccType, ccNum, ccCurrency, ccAddr1, ccAddr2, ccAddr3, ccAddr4,  ccCity,  ccCountry,  ccState,  ccZip, ccCVV2, xpMID, xpUN, xpPW, xpAmount);
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(xpEndpoint);
                req.setMethod('POST');
                
                //system.debug(s);
                req.setBody(xmlBody);
                req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                req.setHeader('Accept-Encoding', 'gzip,deflate');
                req.setHeader('SOAPAction', xpSoapAction);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                responseStr = parseXiPayResponse(res.getBody());
                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'AK ', responseStr);
                //for debugging
                responseStr.put('xmlBody',xmlBody);
                responseStr.put('authType',authType);
            }else{
                responseStr.put('StatusCode','NPSF');
                responseStr.put('Message', 'ERROR: No payment setting found.');
                
            }
            
            
            return responseStr;
        }    
        /***************************************************************************************************************************************
  Method Name : getXMLBody
  Description : helper method to generate request body for preauthorization api callout
  Return type : string
 *************************************************************************************************************************************/
          global static string getXMLBody(string ccHolderName, string ccExpMon, string ccExpYear, string ccType, string ccNum, string ccCurrency, string ccAddr1, string ccAddr2, string ccAddr3, string ccAddr4,  string ccCity,  string ccCountry,  string ccState,  string ccZip, string ccCVV2, string xpMID, string xpUN, string xpPW, string xpAmount ){
            
            string cardType = '';
            if(ccType == '001'){ cardType = 'Vi'; }
            else if(ccType== '002'){ cardType = 'Mc'; }
            else if(ccType== '003'){ cardType = 'Ax'; }
            else if(ccType== '004'){ cardType = 'Di'; }
            
            string s = '<soapenv:Envelope xmlns:mes="http://Paymetric/XiPaySoap30/message/" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'+
                '<soapenv:Header>'+
                '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'+
                '<wsse:UsernameToken wsu:Id="UsernameToken-32259181" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
                '<wsse:Username>'+
                xpUN +
                '</wsse:Username>'+
                '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+
                xpPW +
                '</wsse:Password>'+
                '</wsse:UsernameToken>'+
                '</wsse:Security>'+
                '</soapenv:Header>'+
                '<soapenv:Body>'+
                '<mes:SoapOp>'+
                '<mes:pPacketsIn>'+
                '<mes:count>1</mes:count>'+
                '<mes:xipayvbresult>false</mes:xipayvbresult>'+
                '<mes:packets>'+
                '<mes:ITransactionHeader>'+
                '<mes:Amount>'+xpAmount+'</mes:Amount>'+
                '<mes:CardExpirationDate>'+ccExpMon+'/'+ccExpYear.substring(2,4)+'</mes:CardExpirationDate>'+
                '<mes:CardHolderName>'+ccHolderName+'</mes:CardHolderName>'+
                '<mes:CardNumber>'+ccNum+'</mes:CardNumber>'+
                '<mes:CardType>'+cardType+'</mes:CardType>'+                                
                '<mes:CardDataSource>E</mes:CardDataSource>'+
                '<mes:PacketOperation>1</mes:PacketOperation>'+
                '<mes:MerchantID>'+xpMID+'</mes:MerchantID>'+
                '<mes:CurrencyKey>'+ccCurrency+'</mes:CurrencyKey>'+
                '<mes:PONumber></mes:PONumber>'+
                '<mes:CardHolderAddress1>'+ccAddr1+'</mes:CardHolderAddress1>'+
                '<mes:CardHolderCity>'+ccCity+'</mes:CardHolderCity>'+
                '<mes:CardHolderCountry>'+ccCountry+'</mes:CardHolderCountry>'+
                '<mes:CardHolderState>'+ccState+'</mes:CardHolderState>'+
                '<mes:CardHolderZip>'+ccZip+'</mes:CardHolderZip>'+
                '<mes:CardCVV2>'+ccCVV2+'</mes:CardCVV2>'+
                '</mes:ITransactionHeader>'+
                '</mes:packets>'+
                '</mes:pPacketsIn>'+
                '</mes:SoapOp>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';
            return s;
        }
        /***************************************************************************************************************************************
  Method Name : parseXiPayResponse
  Description : helper method to parse the response of preauthorization api callout
  Return type : map<string, string>
 *************************************************************************************************************************************/
        public static map<string, string> parseXiPayResponse(string respStr){
            map<string, string> returnMe= new map<string, string>();
            
            returnMe.put('RespStr',respStr);
            
            string envNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            string xiPayNS = 'http://Paymetric/XiPaySoap30/message/';
            Dom.Document doc = new Dom.Document();
            doc.load(respStr);
            
            Dom.XMLNode env = doc.getRootElement();
            Dom.XMLNode xmlBody = env.getChildElement('Body', envNS);
            Dom.XMLNode node1 = xmlBody.getChildElement('SoapOpResponse', xiPayNS);
            Dom.XMLNode node2 = node1.getChildElement('SoapOpResult', xiPayNS);
            Dom.XMLNode node3 = node2.getChildElement('packets', xiPayNS);
            Dom.XMLNode iTHeader = node3.getChildElement('ITransactionHeader', xiPayNS); 
            
            string statusCode = '';
            if(iTHeader.getChildElement('StatusCode', xiPayNS) != null){
                statusCode =  iTHeader.getChildElement('StatusCode', xiPayNS).getText();
            }
            returnMe.put('StatusCode',statusCode);
            returnMe.put('Message',iTHeader.getChildElement('Message', xiPayNS).getText());
            
            string transactionCode = '';
            if(iTHeader.getChildElement('TransactionID', xiPayNS) != null){
                transactionCode =  iTHeader.getChildElement('TransactionID', xiPayNS).getText();
            }
            returnMe.put('TransactionCode',transactionCode);
            
            string authorizationCode = '';
            if(iTHeader.getChildElement('AuthorizationCode', xiPayNS) != null){
                authorizationCode =  iTHeader.getChildElement('AuthorizationCode', xiPayNS).getText();
            }
            returnMe.put('TransactionSubCode',authorizationCode);
            
            //AA: These two attributes are added for Catalyst.
            //StatusTXN ==> AuthRespCode renamed 
            
            string authorizationDate = '';
            if(iTHeader.getChildElement('AuthorizationDate', xiPayNS) != null){
                authorizationDate =  iTHeader.getChildElement('AuthorizationDate', xiPayNS).getText();
            }
            returnMe.put('AuthorizationDate',authorizationDate);
            
            string statusTXN = '';
            if(iTHeader.getChildElement('StatusTXN', xiPayNS) != null){
                statusTXN =  iTHeader.getChildElement('StatusTXN', xiPayNS).getText();
            }
            returnMe.put('AuthRespCode',statusTXN);
            
            string aVSCode = '';
            if(iTHeader.getChildElement('AVSCode', xiPayNS) != null){
                aVSCode =  iTHeader.getChildElement('AVSCode', xiPayNS).getText();
            }
            returnMe.put('AVSCode',aVSCode);
            
            string responseCode = '';
            if(iTHeader.getChildElement('ResponseCode', xiPayNS) != null){
                responseCode =  iTHeader.getChildElement('ResponseCode', xiPayNS).getText();
            }
            returnMe.put('ResponseCode',responseCode);
            
            for(Dom.XMLNode infoItem : iTHeader.getChildElement('InfoItems', xiPayNS).getChildElements()) {
                if(infoItem.getChildElement('Key', xiPayNS).getText() == 'TR_CARD_CIDRESPCODE'){
                    returnMe.put('TR_CARD_CIDRESPCODE',infoItem.getChildElement('Value', xiPayNS).getText());
                }
            }
            
            return returnMe;
        }        
        
    /***************************************************************************************************************************************
  Class Name : billingObjWrapper
  Description : Wrapper class for the billing address data
 *************************************************************************************************************************************/
         global class billingObjWrapper{      
            global String address1{get;set;}
            global String address2{get;set;}
            global String address3{get;set;}
            global String address4{get;set;}
            global String city{get;set;}  
            global String state{get;set;}  
            global String countryCode{get;set;}  
            global String postalCode{get;set;}  
             /***************************************************************************************************************************************
  Constructor Name : billingObjWrapper
  Description : Constructor to initialize variables of billingObjWrapper
  Return type : N/A
 *************************************************************************************************************************************/
            global billingObjWrapper(){
                address1 = '';
                address2 = '';
                address3 = '';
                address4 = '';
                city = '';
                countryCode = '';
                state = '';
                postalCode = '';
            }
        }   
    }