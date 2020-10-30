/* Class Name    :EC_PaymetricTokenizedAPIMockImpl
 * Description      Test Class to cover Paymetric classes
 * Created By       :Ashish 
 * Created On       :2019-10-7
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ashish                2019-10-7      BC-75711        Created the class   
 *
 */
@isTest
global class EC_PaymetricTokenizedAPIMockImpl implements HttpCalloutMock {
/***************************************************************************************************************************************
  Method Name : respond
  Description : Mock HTTPResponce class to used in Paymetric test classes
  Return type : HTTPResponse 
 *************************************************************************************************************************************/
    global HTTPResponse respond(HTTPRequest req) { // Implement this interface method
        // Create a fake response
        system.debug(req.getEndpoint());
        if (req.getEndpoint().startsWithIgnoreCase('http://www.guid.com/AccessToken')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String resp = '<?xml version="1.0"?>'
                +'<AccessTokenResponsePacket xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                +'<ResponsePacket>'
                +'<MerchantGuid>865ff5d3-9cfb-49e6-9390-14b6507fd816</MerchantGuid>'
                +'<AccessToken>e21f0b90-1b8d-409b-b5ff-af0c1d621472</AccessToken>'
                +'<Signature>hVYnQA7fAtqU0GTGqvnoGVugAYHcb3WbVuWB5iyK9Rc=</Signature>'
                +'</ResponsePacket>'
                +'</AccessTokenResponsePacket>';
            res.setBody(resp);
            res.setStatusCode(200);
            return res;
            
        }else if(req.getEndpoint().startsWithIgnoreCase('http://www.guid.com/ResponsePacket')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String resp = '<?xml version="1.0" encoding="utf-8"?><PaymetricResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema"'
                +'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Fields><FormField><Name>Card '
                +'Type</Name><Value>mc</Value><IsToTokenize>false</IsToTokenize></FormField><FormField><Name>Expiration '
                +'Month</Name><Value>10</Value><IsToTokenize>false</IsToTokenize></FormField><FormField><Name>Expiration '
                +'Year</Name><Value>2025</Value><IsToTokenize>false</IsToTokenize></FormField><FormField><Name>Card '
                +'Number</Name><Value>-E803-0026-28G8PCM0QSZD4F</Value><IsToTokenize>true</IsToTokenize></FormField><FormField><Name>Card Holder '
                +'Name</Name><Value>4012000033330026</Value><IsToTokenize>false</IsToTokenize></FormField><FormField><Name>Card Security '
                +'Code</Name><Value>999</Value><IsToTokenize>false</IsToTokenize></FormField></Fields></PaymetricResponse>';
            res.setBody(resp);
            res.setStatusCode(200);
            return res;
        }else if(req.getEndpoint().containsIgnoreCase('xipaynet')){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            res.setHeader('Accept-Encoding', 'gzip,deflate');
            res.setHeader('SOAPAction', 'Paymetric/XiPaySoap30/action/XiGGE.SoapOp');
            String resp =  '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"' 
                +'xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><s:Header><o:Security s:mustUnderstand="1" '
                +'xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><u:Timestamp '
                +'u:Id="_0"><u:Created>2019-10-07T12:03:50.931Z</u:Created><u:Expires>2019-10-07T12:08:50.931Z</u:Expires></u:Timestamp></o:Security></s:Header><s:Body '
                +'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><SoapOpResponse '
                +'xmlns="http://Paymetric/XiPaySoap30/message/"><SoapOpResult><count>1</count><xipayvbresult>true</xipayvbresult><packets><ITransactionHeader><AVSAddress/><AVSCode>Y</AVS'
                +'Code><AVSZipCode/><AccountingDocNumber/><ActionCode/><AdditionalInfo/><Amount>0.0000</Amount><AuthorizationCode>OK080C</AuthorizationCode><AuthorizationDate>2019-10-07T'
                +'07:03:49</AuthorizationDate><AuthorizationReferenceCode/><AuthorizationTime>07:03:0049</AuthorizationTime><AuthorizedThroughCartridge>XiPayCartFDMSNorth.FDMSNorth.1</Au'
                +'thorizedThroughCartridge><BankBatchID/><BankSubBatchID/><BankTransactionID/><BatchID/><BillingDate>1899-12-30T00:00:00</BillingDate><BillingPlanItem/><CaptureDate>1899-'
                +'12-30T00:00:00</CaptureDate><CaptureReferenceCode/><CardCVV2>999</CardCVV2><CardDataSource>E</CardDataSource><CardExpirationDate>12/25</CardExpirationDate><CardFollowOn'
                +'Number/><CardHolderAddress1>null</CardHolderAddress1><CardHolderAddress2/><CardHolderCity>null</CardHolderCity><CardHolderCountry>nul</CardHolderCountry><CardHolderDist'
                +'rict/><CardHolderName1/><CardHolderName2/><CardHolderName>4012000033330026</CardHolderName><CardHolderState>nul</CardHolderState><CardHolderZip>null</CardHolderZip><Car'
                +'dNumber>-E803-0026-28G8PCM0QSZD4F</CardNumber><CardPresent>0</CardPresent><CardType>Vi</CardType><CardValidFrom/><ChargeAmount>0.0000</ChargeAmount><Client/><CompanyCod'
                +'e/><CreationDate>2019-10-07T07:03:49</CreationDate><CurrencyKey>USD</CurrencyKey><CustTXN/><CustomerNumber/><FiscalYear/><GLAccount/><LastModificationDate>2019-10-07T07'
                +':03:50</LastModificationDate><LocationID/><MerchantID>NALCO_MID_USD</MerchantID><MerchantTXN/><MerchantTransactionID/><Message>APPROVAL        '
                +'</Message><ModifiedStatus>1</ModifiedStatus><OrderDate>1899-12-30T00:00:00</OrderDate><OrderID/><Origin>XiPay</Origin><PONumber/><PacketOperation>1</PacketOperation><Pr'
                +'eauthorized/><ReferenceCode/><ReferenceLineItem/><ResponseCode>00</ResponseCode><SalesDocNumber/><SettlementAmount>0.0000</SettlementAmount><SettlementDate>1899-12-30T0'
                +'0:00:00</SettlementDate><SettlementReferenceCode/><ShippingCaptureDate>1899-12-30T00:00:00</ShippingCaptureDate><ShippingLocationID/><ShippingMethod/><StatusCode>-101</S'
                +'tatusCode><StatusTXN>Authorized</StatusTXN><TaxLevel1>0.0000</TaxLevel1><TaxLevel2>0.0000</TaxLevel2><TaxLevel3>0.0000</TaxLevel3><TaxLevel4>0.0000</TaxLevel4><Terminal'
                +'ID/><TransactionID>165787925</TransactionID><TransactionType>Authorization</TransactionType><VATNumberCustomer/><VATNumberMerchant/><XIID>1756</XIID><InfoItems><InfoIte'
                +'m><Key>HOST_AUTH</Key><Value>LiiTON0iAAF4uneuAUqnvGRy6Zg=</Value></InfoItem><InfoItem><Key>IN_CARD_CMRCLIND</Key><Value> '
                +'</Value></InfoItem><InfoItem><Key>IN_POSCONDCODE</Key><Value>52</Value></InfoItem><InfoItem><Key>IN_POSENTRYMODE</Key><Value>010</Value></InfoItem><InfoItem><Key>IN_TRA'
                +'NS_AUTHDATETIME</Key><Value>10072019070349</Value></InfoItem><InfoItem><Key>IN_TRANS_VISAACI</Key><Value>N</Value></InfoItem><InfoItem><Key>IN_TRANS_VISACARDLVL</Key><V'
                +'alue>C </Value></InfoItem><InfoItem><Key>IN_TRANS_VISATRANSID</Key><Value>019280834942640</Value></InfoItem><InfoItem><Key>IN_TRANS_VISAVALCODE</Key><Value>IV  '
                +'</Value></InfoItem><InfoItem><Key>TR_CARD_CIDRESPCODE</Key><Value>M</Value></InfoItem><InfoItem><Key>TR_CARD_RESPCODE</Key><Value>00</Value></InfoItem><InfoItem><Key>TR'
                +'_ECOMM_IND</Key><Value>07</Value></InfoItem></InfoItems></ITransactionHeader></packets></SoapOpResult></SoapOpResponse></s:Body></s:Envelope>';
                res.setBody(resp);
            res.setStatusCode(200);
            return res;
        }else{
            return null;
        }
        
    }
}