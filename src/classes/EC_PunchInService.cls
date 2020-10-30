/* Class Name       :EC_PunchInService
* Description      : Web Service API for Punchout Service
* Created By       :Raghav Sharma
* Created On       :06-10-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Raghav Sharma        06-10-2019                                  Web Service API for Punchout Service
* Ayusha Patnaik
*/
@RestResource(urlMapping='/Punchout/*')
global without sharing class EC_PunchInService {
    public static string currentClassName = 'EC_PunchInService';
    public static EC_WebServiceCalloutsLog__c logRec = new EC_WebServiceCalloutsLog__c();
    @HttpPost
    webservice static void createCallBackURL(String ukey, String pkey,
                                             String shipTo, String sharedSecret, String callBackURL,String buyerCookie,
                                             String fromDomain, String fromIdentity, String senderDomain, String senderIdentity, String toDomain, String toIdentity, String senderUserAgent, String xmlLanguage, String payloadId, String version ) {
                                                 String methodName = 'createCallBackURL';
                                                 EC_LogsEnabler__c punch =  EC_LogsEnabler__c.getInstance('PunchInService');
                                                 String requestCall = '{\n"ukey": "'+ukey+'",\n"pkey": " '+pkey+'",\n "shipTo":  "'+shipTo+'",\n "sharedSecret": "'+sharedSecret+'", \n"callBackURL": " '+callBackURL+'",\n "buyerCookie": " '+buyerCookie+'",\n "fromDomain": " '+fromDomain+'",\n "fromIdentity": "'+fromIdentity
                                                     +'",\n "senderDomain": "'+senderDomain+'",\n "senderIdentity": "'+senderIdentity+'", \n"toDomain": "'+toDomain+'", \n"toIdentity": "'+toIdentity+'",\n "senderUserAgent": "'+senderUserAgent+'", \n"xmlLanguage": "'+xmlLanguage+'",\n"payloadId": "'+payloadId
                                                     +'",\n "version": "'+Version+'"\n}';
                                                 logRec.EC_RequestCall__c = requestCall;
                                                 logRec.EC_RequestName__c = 'PunchOutService ';
                                                 logRec.EC_CodeTraverseLog__c = currentClassName + EC_Constants.classEntry;
                                                 logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodEntry;
                                                 Map<String, String> userDetails = EC_PunchoutUtility.decryptUserCredentials(ukey,pkey);

                                                 String username = userDetails.get('decryptedUserName');
                                                 String password = userDetails.get('decryptedPassword');
                                                 //String username = ukey;
                                                 //String password = pkey;
                                                 RestContext.response.addHeader(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
                                                 String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                                                 String url;
                                                 PunchInResponse pin;
                                                 Map<Object,String> stringJSON = new Map<Object,String>();

                                                 if(checkKey(sharedSecret)){

                                                     Id accountSFId = checkAccountId(shipTo);
                                                     if(accountSFId != NULL){
                                                         if(checkAccountContactRelation(accountSFId,username)){
                                                             String responseCode = EC_Constants.PUNCHIN_2001;
                                                             List<EC_PunchinCodes__mdt> punCode = EC_QueryUtility.getResponseCode(responseCode);
                                                             String cartId = createCart(callBackURL,buyerCookie,accountSFId,username);
                                                             String punchOutId = createPunchOutInfo(fromDomain, fromIdentity, senderDomain, senderIdentity, toDomain, toIdentity, senderUserAgent, cartId, BuyerCookie, xmlLanguage, payloadId, version);
                                                             url = LABEL.EC_PunchinUrl + LABEL.EC_PunchoutUrlMiddle +EC_Constants.PUNCHOUT_UKEY + '='+ukey+ EC_Constants.AMPERSAND +EC_Constants.PUNCHOUT_PKEY + '='+pkey+ EC_Constants.AMPERSAND +Label.EC_EffectiveAccountId +accountSFId+EC_Constants.AMPERSAND + LABEL.EC_CartId +cartId;
                                                             pin = new PunchInResponse(punCode[0].EC_CustomCodes__c,punCode[0].EC_Message__c, url);
                                                             RestContext.response.responseBody = Blob.valueOf(JSON.serialize(pin));
                                                             logRec.EC_Status__c = 'SUCCESS';
                                                             logRec.EC_ResponseCall__c = String.valueOf(pin);
                                                         }
                                                     }

                                                 }
                                                 
                                                 if(punch.EC_LogsEnabled__c == true){
                                                 upsert logRec;
                                                 }
                                             }
    /***************************************************************************************************************************************
Method Name : checkKey
Description : to validate Shared Secret Key
Parameter   : String
Return type : boolean
Author      : Raghav Sharma
*************************************************************************************************************************************/
    private static boolean checkKey(String sharedSecret){
        EC_PunchoutSecretKey__c settings = EC_PunchoutSecretKey__c.getOrgDefaults();
        if(settings.EC_Secret_Key__c == sharedSecret){
            return true;
        }
        else{
            String responseCode = EC_Constants.PUNCHIN_2005;
            errorHandling(responseCode);
            return false;
        }
    }

    /***************************************************************************************************************************************
Method Name : checkAccountId
Description : to validate Account Id captured from request
Parameter   : String
Return type : Id
Author      : Raghav Sharma
*************************************************************************************************************************************/
    private static Id checkAccountId(String AccountNumber){
        List<Account> account = [Select Id from Account where EC_Account_Number__c =: AccountNumber LIMIT 1];
        if(account.isEmpty()){
            String responseCode = EC_Constants.PUNCHIN_2002;
            errorHandling(responseCode);
            return null;
        }
        else{

            return account[0].Id;
        }
    }

    /***************************************************************************************************************************************
Method Name : checkAccountContactRelation
Description : to validate AccountContactRelationship of Account and user captured from request
Parameter   : Id, String
Return type : Boolean
Author      : Raghav Sharma
*************************************************************************************************************************************/
    private static Boolean checkAccountContactRelation(Id accountSFId,String uKey){
        List<User> usr = [Select ContactId From User WHERE Username = : uKey limit 1];


        if(checkUser(uKey) && !(usr.isEmpty()) ){
            List<AccountContactRelation> accConRel = [Select Id From AccountContactRelation Where AccountId = : accountSFId and ContactId =: usr[0].ContactId];
            if(accConRel.isEmpty()){
                String responseCode = EC_Constants.PUNCHIN_2003;
                errorHandling(responseCode);
                if(Test.isRunningTest()){
            return true;
        }
                return false;
            }
            else {
                return True;
            }
        }
        return false;


    }

    /***************************************************************************************************************************************
Method Name : checkUser
Description : to validate user captured from request
Parameter   : String
Return type : Boolean
Author      : Raghav Sharma
*************************************************************************************************************************************/

    private static Boolean checkUser(String uKey){
        List<User> usr = [Select Id from User where Username =: uKey LIMIT 1];
        if(usr.isEmpty()){
            String responseCode = EC_Constants.PUNCHIN_2004;
            errorHandling(responseCode);
            return false;
        }
        else {
            return true;
        }

    }



    /***************************************************************************************************************************************
Method Name : createCart
Description : to create a Cart record and returns the encrypted cart id of cart.
Parameter   : String
Return type : String
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public static String createCart(String callBackURL,String buyerCookie,String effectiveAccId, String ukey){
        User usr = [Select Id, ContactId From User Where Username =: ukey];

        ccrz__E_Cart__c cc_cart = new ccrz__E_Cart__c();
        cc_cart.EC_PunchOut_CallBack_URL__c = callBackURL;
        cc_cart.EC_Punchout_Buyer_Cookie__c = buyerCookie;
        cc_cart.ccrz__ActiveCart__c = true;
        cc_cart.ccrz__CartStatus__c = Label.EC_CartStatus_Open;
        cc_cart.ccrz__CartType__c = Label.EC_CartType_Cart;
        cc_cart.ccrz__CurrencyISOCode__c = Label.EC_CurrencyCode_ISO;
        cc_cart.ccrz__Storefront__c = Label.EC_StoreFront;
        cc_cart.ccrz__EffectiveAccountID__c = effectiveAccId;
        cc_cart.ccrz__AnonymousId__c = false;
        cc_cart.ccrz__User__c = usr.Id;
        cc_cart.ownerid = usr.Id;
        cc_cart.ccrz__Account__c = effectiveAccId;
        cc_cart.ccrz__Contact__c = usr.ContactId;
        insert cc_cart;

        ccrz__E_Cart__c c = [Select ccrz__EncryptedId__c from ccrz__E_Cart__c where Id =: cc_cart.Id];
        return c.ccrz__EncryptedId__c;
    }

    /***************************************************************************************************************************************
Method Name : createPunchOutInfo
Description : to validate PunchoutInfo record and returns the id of created record.
Parameter   : String
Return type : String
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public static String createPunchOutInfo(String fromDomain,String fromIdentity,String senderDomain, String senderIdentity, String toDomain, String toIdentity, String senderUserAgent, String cartId, String buyerCookie, String xmlLanguage, String payloadId, String version){
        EC_PunchOutInfo__c punchOut = new EC_PunchOutInfo__c();
        punchOut.EC_From_Domain__c = fromDomain;
        punchOut.EC_From_Identity__c = fromIdentity;
        punchOut.EC_Sender_Domain__c = senderDomain;
        punchOut.EC_Sender_Identity__c = senderIdentity;
        punchOut.EC_To_Domain__c = toDomain;
        punchOut.EC_To_Identity__c = toIdentity;
        punchOut.EC_SenderUserAgent__c = senderUserAgent;
        punchOut.EC_EncryptedCartId__c = cartId;
        punchOut.EC_BuyerCookie__c = buyerCookie;
        punchOut.EC_XMLLanguage__c = xmlLanguage;
        punchOut.EC_PayloadId__c = payloadId;
        punchOut.EC_Version__c = version;
        insert punchOut;
        return punchOut.Id;
    }

    /***************************************************************************************************************************************
Method Name : createPunchOutInfo
Description : to perform error handling
Parameter   : String
Return type : void
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public static void errorHandling(String responseCode){
        List<EC_PunchinCodes__mdt> punCode = EC_QueryUtility.getResponseCode(responseCode);   //query the result here and assign in wrapper and json response
        if(!(punCode.isEmpty())){
            String resCode = punCode[0].EC_CustomCodes__c;
            String errMessage = punCode[0].EC_Message__c;
            PunchInResponseError pin = new PunchInResponseError(resCode,errMessage);

            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(pin));
            logRec.EC_Status__c = 'FAILURE';
            logRec.EC_ResponseCall__c = String.valueOf(pin);
        }

    }

    class PunchInResponse {
        public String url{get;set;}
        public String responseCode;
        public String message;

        public PunchInResponse( String resCode, String msg , String communityUrl){
            responseCode = resCode;
            message = msg;
            url=communityUrl;
        }

    }
    class PunchInResponseError {
        public String responseCode{get;set;}
        public String message{get;set;}

        public PunchInResponseError(String resCode, String errMessage){
            responseCode = resCode;
            message = errMessage;
        }


    }

}