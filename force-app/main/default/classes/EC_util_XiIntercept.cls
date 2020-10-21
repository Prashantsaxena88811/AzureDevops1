/* Class Name    : EC_util_XiIntercept 
 * Description      :Paymetrics class
 * Created By       :Ashish  
 * Created On       :2019-7-19

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ashish                 2019-7-19             BC-75711     Created the class   
 *
 */
public with sharing class EC_util_XiIntercept {

    private static final String REQUEST_TYPE_POST                   = 'POST';

    /**
     * retrieve XiIntercept Custom Settings
     */
    public static EC_PaymetricPaymentSetting__c settings {
        get {
            if (settings == null) {
            String storeFrontName = System.Label.StoreNameForIFrame;
              settings = getPaymentSetting(storeFrontName);
            }
            return settings;
        }
        private set;
    }
    
    

    /***************************************************************************************************************************************
  Method Name : retrieveAccessToken
  Description : performs callout to retrieve XiIntercept access token via direct  * call to XII-ECOMM
  Return type : Returns Map<String,Object>
 *************************************************************************************************************************************/
    public static Map<String, String> retrieveAccessToken(String baseURL, String store) {
        Map<String, String> returnMap = new Map<String, String>();
        try{
            //String baseURLWOApex = baseURL.replace('/apex','');
          /*  final String packetXml = '<?xml version="1.0" encoding="utf-8"?>'
                                    + '<merchantHtmlPacketModel xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="Paymetric:XiIntercept:MerchantHtmlPacketModel">'
                                    + '<iFramePacket>'
                                    + '<hostUri>https://devec1-ecolabconnect--devec1.cs62.force.com/</hostUri>'
                                    + '<cssUri>https://qaapp02.xisecurenet.com/diecomm/Content/IFrameStyleSheet.css</cssUri>'
                                    + '</iFramePacket>'
                                    + ' <templateHtml name="CreditCard">'
                                    + '<paymentTypes>'
                                    + '<paymentType type="american express" />'
                                    + '<paymentType type="mastercard" />'
                                    + '<paymentType type="maestro" />'
                                    + '<paymentType type="visa" />'
                                    + '<paymentType type="custom" value="HD" text="Home Depot" />'
                                    + '</paymentTypes>'
                                    + '</templateHtml>'
                                    + '</merchantHtmlPacketModel>';
https://devec1-ecolabconnect--devec1.cs62.force.com/Connect/resource/1568281925000/EC_EcoLabs_Theme/css3/payments.css
*/


            String staticResourceUrl = baseURL+'/'+store+ GetResourceURL('EC_EcoLabs_Theme')+'/css3/payments.css';
            final String packetXml = '<?xml version="1.0" encoding="UTF-8"?>'
                                        + ' <merchantHtmlPacketModel xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="Paymetric:XiIntercept:MerchantHtmlPacketModel">'
                                        +'<iFramePacket><hostUri>'+baseURL+'</hostUri><cssUri>'+staticResourceUrl+'</cssUri>'                
                                        +'</iFramePacket>'
                                        +'<merchantHtml><htmlSection class="merchant_paycontent"><xiProperties error-class="xiInputError">'
                                        +'<errorTooltip class="errorTooltip" show-effect="fadeIn" show-duration="5000" hide-effect="fadeOut" hide-duration="5000" />'
                                        +'</xiProperties>'
                                        +'<cardDropdownSection>'
                                        +'<tag name="div"><label text="'+System.Label.EC_Credit_Card_CardType +'" for="cardType" />'
                                        +'<ddlCardType required-msg="'+System.Label.EC_Credit_Card_SelectCardType+'" id="cd" default-text="'+System.Label.EC_Credit_Card_SelectCard +'"><items>'
                                        +'<item for="visa" />'
                                        +'<item for="mastercard" />'
                                        +'</items></ddlCardType></tag>'
                                        +'<tag name="div"><label text="'+System.Label.EC_Credit_Card_NameOnCard +'" for="cardholderName" />'
                                        +'<tboxCardHolderName placeholder="'+System.Label.EC_Credit_Card_EnterName+'" required="false"/>'
                                        +'<validationMsg for="cardholderName" class="valmsg" />'
                                        +'</tag>'
                                        +'<tag name="div"><label for="cardNumber" />'
                                        +'<tboxCardNumber tokenize="true" digits-only="true"  luhn-check-msg="'+System.Label.EC_Credit_Card_InvalidNumber+'" placeholder="'+System.Label.EC_Credit_Card_EnterCardNumber +'" digits-only-msg="'+System.Label.EC_Credit_Card_InvalidNumber+'" maxlength="16" maxlength-msg="'+System.Label.EC_Credit_Card_InvalidNumber+'" minlength="16" minlength-msg="'+System.Label.EC_Credit_Card_InvalidNumber+'" required-msg="'+System.Label.EC_Credit_Card_InvalidNumber+'" />' 
                                        +'<validationMsg for="cardNumber" class="valmsg" />'
                                        +'</tag>'
                                        +'<tag name="div"><label text="'+System.Label.EC_Credit_Card_ExpirationDate +'" for="expMonth" />'
                                        +'<ddlExpMonth default-text="'+System.Label.EC_Credit_Card_Month+'" class="merchant_combos" display-format="MM" required="true" exp-date="true" exp-date-msg="'+System.Label.EC_Credit_Card_validExpirationDate+'" required-msg="'+System.Label.EC_Credit_Card_validExpirationDate+'" />'
                                        +'<ddlExpYear default-text="'+System.Label.EC_Credit_Card_Year+'" class="merchant_combos" years-to-display="10" required="true" exp-date="true" exp-date-msg="'+System.Label.EC_Credit_Card_validExpirationDate+'" required-msg="'+System.Label.EC_Credit_Card_validExpirationDate+'" />'
                                        +'<validationMsg for="expYear" class="valmsg" />'
                                        +'</tag>'
                                        +'<tag name="div"><label text="'+System.Label.EC_Credit_Card_CardCVV +'" for="cvv" />'
                                        +'<tboxCvv class="xi-short-text" digits-only-msg="'+System.Label.EC_Credit_Card_validCVV+'" required-msg="'+System.Label.EC_Credit_Card_validCVV+'" minlength="3" error-msg-style="text" maxlength="3" minlength-msg="'+System.Label.EC_Credit_Card_validCVV+'" maxlength-msg="'+System.Label.EC_Credit_Card_validCVV+'" digits-only="true"/>'
                                        +'<validationMsg for="cvv" class="valmsg" />'
                                        +'</tag>'
                                        +'</cardDropdownSection>'
                                        +'</htmlSection></merchantHtml></merchantHtmlPacketModel>';

            /*
            final String packetXml = '<?xml version="1.0" encoding="UTF-8"?>'
                                        +'<merchantHtmlPacketModel xmlns="Paymetric:XiIntercept:MerchantHtmlPacketModel">'
                                        +'<iFramePacket>'
                                        +'<hostUri>https://devec1-ecolabconnect--devec1.cs62.force.com</hostUri>'
                                        +'<cssUri>https://qaapp02.xisecurenet.com/diecomm/Content/IFrameStyleSheet.css</cssUri>'
                                        +'<cardinal3DSecure amount="13.42" currencyCode="840" orderNumber="12345" redirectUri="https://devec1-ecolabconnect--devec1.cs62.force.com/DefaultStore" />'
                                        +'</iFramePacket>'
                                        +'<merchantHtml>'
                                        +'<htmlSection class="merchant_paycontent">'
                                        +'<xiProperties error-class="xiInputError">'
                                        +'<errorTooltip class="errorTooltip" show-effect="fadeIn" showduration=" 5000" hide-effect="fadeOut" hide-duration="5000" />'
                                        +'</xiProperties>'
                                        +'<paymentOptionRadioSection>'
                                        +'<tag name="div" class="PaymentDetailHeader">Select a payment option</tag>'
                                        +'<label text="echeck" for="echeck" />'
                                        +'<radPaymentOption for="echeck" />'
                                        +'<label text="credit card" for="card" />'
                                        +'<radPaymentOption for="card" />'
                                        +'</paymentOptionRadioSection>'
                                        +'<cardDropdownSection>'
                                        +'<tag name="div" class="PaymentDetailHeader">Enter your credit card information</tag>'
                                        +'<tag name="div">'
                                        +'<label for="cardType" text="card type" />'
                                        +'<ddlCardType id="cd">'
                                        +'<items>'
                                        +'<item for="american express" />'
                                        +'<item for="mastercard" />'
                                        +'<item for="visa" />'
                                        +'<item for="maestro" />'
                                        +'<customItem for="myCard" text="My Card" />'
                                        +'<customItem for="myCard2" text="My Card 2" />'
                                        +'</items>'
                                        +'</ddlCardType>'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="cardNumber" text="card number" />'
                                        +'<tboxCardNumber tokenize="true" />'
                                        +'<validationMsg for="cardNumber" class="valmsg" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="cardholderName" text="name on card" />'
                                        +'<tboxCardHolderName />'
                                        +'<validationMsg for="cardholderName" class="valmsg" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="startMonth" text="start date" />'
                                        +'<ddlStartMonth default-text="month" display-format="MMM" class="merchant_combos" required="false" />'
                                        +'<ddlStartYear default-text="year" class="merchant_combos" years-todisplay=" 10" required="false" start-date="true" />'
                                        +'<validationMsg for="startYear" class="valmsg" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="expMonth" text="exp date" />'
                                        +'<ddlExpMonth default-text="month" class="merchant_combos" required="false" />'
                                        +'<ddlExpYear default-text="year" class="merchant_combos" years-todisplay=" 10" required="false" exp-date="true" />'
                                        +'<validationMsg for="expYear" class="valmsg" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="cvv" text="card cvv" />'
                                        +'<tboxCvv />'
                                        +'<validationMsg for="cvv" class="valmsg" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="cardAmount" />'
                                        +'<tboxCardAmount />'
                                        +'<validationMsg for="cardAmount" class="valmsg" />'
                                        +'</tag>'
                                        +'</cardDropdownSection>'
                                        +'<echeckRadioSection>'
                                        +'<tag name="div" class="PaymentDetailHeader">Enter your bank information</tag>'
                                        +'<tag name="div">'
                                        +'<validationMsg for="accountType" class="valmsg-ac-type" />'
                                        +'<label for="checking" />'
                                        +'<radAccountType for="checking" />'
                                        +'<label for="savings" />'
                                        +'<radAccountType for="savings" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="accountNumber" text="account number" />'
                                        +'<tboxAccountNumber tokenize="true" error-msg-style="imageTooltip" />'
                                        +'<validationMsg for="accountNumber" error-class="valmsg-img" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="routingNumber" text="routing number" />'
                                        +'<tboxRoutingNumber error-msg-style="imageTooltip" />'
                                        +'<validationMsg for="routingNumber" error-class="valmsg-img" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="nameOnAccount" text="name on account" />'
                                        +'<tboxNameOnAccount error-msg-style="imageTooltip" />'
                                        +'<validationMsg for="nameOnAccount" error-class="valmsg-img" />'
                                        +'</tag>'
                                        +'<tag name="div">'
                                        +'<label for="bankName" text="bank name" />'
                                        +'<tboxBankName error-msg-style="imageTooltip" />'
                                        +'<validationMsg for="bankName" error-class="valmsg-img" />'
                                        +'</tag>'
                                        +'</echeckRadioSection>'
                                        +'</htmlSection>'
                                        +'</merchantHtml>'
                                        +'</merchantHtmlPacketModel>';
*/
            
            String signaturePre = EC_util_XiIntercept.generateSig(packetXml);
            System.debug('\n\n ------------ Signature 1 before encoding: ---------------------' + signaturePre);
            String signature = EncodingUtil.urlEncode(signaturePre, 'UTF-8');
            System.debug('\n\n ------------ Signature 1 after encoding: ---------------------' + signature);
    
            String guid = settings.MerchantGUID__c;
            string sharedKey = settings.SharedKey__c;
            String endPoint = settings.Access_Token_EndPoint__c;
            // String endPoint = settings.Response_Packet_Endpoint__c;
            String redirectURL = settings.RedirectURL__c;
            String ajaxEndpoint = settings.Ajax_Endpoint__c;
            final String payload = 'MerchantGuid='+guid+'&SessionRequestType=1&Signature='+signature+'&MerchantDevelopmentEnvironment=java&Packet='+packetXML;   
        
            
            final HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod(REQUEST_TYPE_POST);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('Content-Length', String.valueOf(payload.Length()));
            req.setHeader('Content-Language', 'en-US');
            req.setHeader('Cache-Control', 'no-cache, no-store, max-age=0, must-revalidate');
            req.setHeader('Pragma', 'no-cache');
            req.setBody(payload);
            //System.debug(payload);
    
            final HttpResponse resp = (new Http()).send(req);
    
            //System.debug(resp.getBody());
            String accessToken = resp.getBodyDocument().getRootElement().getChildElement('ResponsePacket', null).getChildElement('AccessToken', null).getText();
            String newSignature = resp.getBodyDocument().getRootElement().getChildElement('ResponsePacket', null).getChildElement('Signature', null).getText();
            
            //System.debug('\n\n ------------ Signature 2, returned from Paymetric: ---------------------\n\n' + newSignature);
            returnMap.put('signature', newSignature);
            returnMap.put('accessToken', accessToken);
        }
        catch(Exception e){
            returnMap.put('Error', e.getMessage());
        }
        return returnMap;
    }

     /***************************************************************************************************************************************
  Method Name : generateSig
  Description : to generate the encoded signature
  Return type : String
 *************************************************************************************************************************************/
    public static String generateSig(String data) {
        return EncodingUtil.base64Encode(
            Crypto.generateMac(
                'hmacSHA256'
                , Blob.valueOf(data)
                , Blob.valueOf(EC_util_XiIntercept.settings.SharedKey__c)));
    }
    /***************************************************************************************************************************************
  Method Name : getPaymentSetting
  Description : get paymetric related custom setting values
  Return type : EC_PaymetricPaymentSetting__c
 *************************************************************************************************************************************/
    public static EC_PaymetricPaymentSetting__c getPaymentSetting(string storeName){
        EC_PaymetricPaymentSetting__c paymentsettings = new EC_PaymetricPaymentSetting__c();
        if(!Test.isRunningTest()){
            paymentsettings = EC_PaymetricPaymentSetting__c.getValues(storeName);
        }else{
            paymentsettings.MerchantGUID__c = 'guid';
            paymentsettings.SharedKey__c = 'gukey';
            paymentsettings.EndPoint__c = 'http://www.guid.com';
            paymentsettings.RedirectURL__c = 'http://www.guid.com';
            paymentsettings.Access_Token_EndPoint__c = 'http://www.guid.com/AccessToken';
            paymentsettings.Ajax_Endpoint__c = 'http://www.guid.com';
            paymentsettings.XiPayEndpoint__c = 'http://www.xipaynet.com';
            paymentsettings.XiPaySoapaction__c = 'Paymetric/XiPaySoap30/action/XiGGE.SoapOp';
            paymentsettings.Name = 'DefaultStore';
        }
        return paymentsettings; 
    }
/***************************************************************************************************************************************
  Method Name : GetResourceURL
  Description : generate static resource url for stylesheet for iframe
  Return type : String
 *************************************************************************************************************************************/
    public static String GetResourceURL(String resourceName) {

        List<StaticResource> resourceList = [
        SELECT Name, NamespacePrefix, SystemModStamp 
        FROM StaticResource 
        WHERE Name = :resourceName
        ];
        String resourceURL = '';                   
        if (resourceList.size() == 1) {
        String namespace = resourceList[0].NamespacePrefix;
        resourceURL = '/resource/' 
            + resourceList[0].SystemModStamp.getTime() + '/' 
            + (namespace != null && namespace != '' ? namespace + '__' : '') 
            + resourceName; 
        }
        return resourceURL;
    }
}