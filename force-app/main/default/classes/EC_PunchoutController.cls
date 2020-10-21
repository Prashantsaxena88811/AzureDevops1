/* Class Name       :EC_PunchoutController
 * Description      :This is the controller class that helps the iBuy user to punch out of the system
 * Created By       :Ayusha Patnaik
 * Created On       :17-10-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Ayusha Patnaik          17-10-2019                                  This is the controller class that helps the iBuy user to punch out of the system
 *
 */

global without sharing class EC_PunchoutController {
	public static string startURL;
	public String returnValue { get; set; }
	public String cXMLStr { get; set; }
	public String punchOutCallbackURL { get; set; }

	/*************************************************************************************************************************************
	 Method Name : generateCXMLWithCart
	 Description : A remote action call to create the CXML with the Cart Id
	 Parameter   : String - Encrypted cart Id
	 Return type : String - CXML string
	 Author      : Harsha N
	 *************************************************************************************************************************************/
	@RemoteAction
	global static Map<String, String> generateCXMLWithCart(String cardId) {

		Map<String, String> responseMap = new Map<String, String>();

		ccrz__E_Cart__c cart = [Select id, name, EC_PunchOut_CallBack_URL__c from ccrz__E_Cart__c Where ccrz__EncryptedId__c = :cardId Limit 1];
		String punchOutCallbackLink = cart.EC_PunchOut_CallBack_URL__c;
		responseMap.put('punchOutCallbackURL', punchOutCallbackLink);
		List<ccrz__E_CartItem__c> cartItemList = [SELECT id, ccrz__Quantity__c, ccrz__Price__c, ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c, ccrz__UnitOfMeasure__c, ccrz__Cart__r.ccrz__CurrencyISOCode__c, ccrz__Cart__r.ccrz__TotalAmount__c, ccrz__Cart__r.ccrz__EncryptedId__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cardId];


		List<EC_PunchOutInfo__c> punchInfoRec = [SELECT Id, EC_Version__c, EC_PayloadId__c, EC_XMLLanguage__c, EC_BuyerCookie__c, EC_From_Domain__c, EC_From_Identity__c, EC_To_Domain__c, EC_To_Identity__c, EC_Sender_Domain__c, EC_Sender_Identity__c, EC_SenderUserAgent__c, EC_EncryptedCartId__c FROM EC_PunchOutInfo__c WHERE EC_EncryptedCartId__c = :cartItemList [0].ccrz__Cart__r.ccrz__EncryptedId__c];

		string cxmlString = '';

		if(cartItemList != null && cartItemList.size() > 0 && punchInfoRec != null && punchInfoRec.size() > 0) {
			XmlStreamWriter xml = new XmlStreamWriter();
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_CXML, null);
			xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_XMLLANG, punchInfoRec [0].EC_XMLLanguage__c);
			xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_PAYLOADID, punchInfoRec [0].EC_PayloadId__c);
			xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_TIMESTAMP, datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssZ'));
			xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_VERSION, punchInfoRec [0].EC_Version__c);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_HEADER, null);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_FROM, null);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_CREDENTIAL, null);
			if(punchInfoRec [0].EC_To_Domain__c != null && punchInfoRec [0].EC_To_Domain__c != '') {
				xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_DOMAIN, punchInfoRec [0].EC_To_Domain__c);
			}
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_IDENTITY, null);
			if(punchInfoRec [0].EC_To_Identity__c != null && punchInfoRec [0].EC_To_Identity__c != '') {
				xml.writeCharacters(punchInfoRec [0].EC_To_Identity__c);
			}
			xml.writeEndElement();
			xml.writeEndElement();
			xml.writeEndElement();

			xml.writeStartElement(null, EC_Constants.PUNCHOUT_TO, null);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_CREDENTIAL, null);
			if(punchInfoRec [0].EC_From_Domain__c != null && punchInfoRec [0].EC_From_Domain__c != '') {
				xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_DOMAIN, punchInfoRec [0].EC_From_Domain__c);
			}
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_IDENTITY, null);
			if(punchInfoRec [0].EC_From_Identity__c != null && punchInfoRec [0].EC_From_Identity__c != '') {
				xml.writeCharacters(punchInfoRec [0].EC_From_Identity__c);
			}
			xml.writeEndElement();
			xml.writeEndElement();
			xml.writeEndElement();

			xml.writeStartElement(null, EC_Constants.PUNCHOUT_SENDER, null);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_CREDENTIAL, null);
			if(punchInfoRec [0].EC_Sender_Domain__c != null && punchInfoRec [0].EC_Sender_Domain__c != '') {
				xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_DOMAIN, punchInfoRec [0].EC_Sender_Domain__c);
			}
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_IDENTITY, null);
			if(punchInfoRec [0].EC_Sender_Identity__c != null && punchInfoRec [0].EC_Sender_Identity__c != '') {
				xml.writeCharacters(punchInfoRec [0].EC_Sender_Identity__c);
			}
			xml.writeEndElement();
			xml.writeEndElement();

			xml.writeStartElement(null, EC_Constants.PUNCHOUT_USERAGENT, null);
			if(punchInfoRec [0].EC_SenderUserAgent__c != null && punchInfoRec [0].EC_SenderUserAgent__c != '') {
				xml.writeCharacters(punchInfoRec [0].EC_SenderUserAgent__c);
			}
			xml.writeEndElement();
			xml.writeEndElement();
			xml.writeEndElement();

			xml.writeStartElement(null, EC_Constants.PUNCHOUT_MESSAGE, null);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_PUNCHOUTORDERMESSAGE, null);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_BUYERCOOKIE, null);
			if(punchInfoRec [0].EC_BuyerCookie__c != null && punchInfoRec [0].EC_BuyerCookie__c != '') {
				xml.writeCharacters(punchInfoRec [0].EC_BuyerCookie__c);
			}
			xml.writeEndElement();

			xml.writeStartElement(null, EC_Constants.PUNCHOUT_ORDERMESSAGEHEADER, null);
			xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_OPERATIONALLOWED, EC_Constants.PUNCHOUT_EDIT);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_TOTAL, null);
			xml.writeStartElement(null, EC_Constants.PUNCHOUT_MONEY, null);
			xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_CURRENCY, cartItemList [0].ccrz__Cart__r.ccrz__CurrencyISOCode__c);
			if(string.valueof(cartItemList [0].ccrz__Cart__r.ccrz__TotalAmount__c) != null && string.valueof(cartItemList [0].ccrz__Cart__r.ccrz__TotalAmount__c) != '') {
				xml.writeCharacters(string.valueof(cartItemList [0].ccrz__Cart__r.ccrz__TotalAmount__c));
			}
			xml.writeEndElement();
			xml.writeEndElement();
			xml.writeEndElement();

			Integer itemNumber = 0;
			for(ccrz__E_CartItem__c itemRec :cartItemList) {
				itemNumber += 1;
				xml.writeStartElement(null, EC_Constants.PUNCHOUT_ITEMIN, null);
				xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_LINENUMBER, string.valueof(itemNumber));
				xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_QUANTITY, string.valueof(itemRec.ccrz__Quantity__c));
				xml.writeStartElement(null, EC_Constants.PUNCHOUT_ITEMID, null);
				xml.writeStartElement(null, EC_Constants.PUNCHOUT_SUPPLIEDPARTID, null);
				xml.writeCharacters(itemRec.ccrz__Product__r.ccrz__SKU__c);
				xml.writeEndElement();

				xml.writeStartElement(null, EC_Constants.PUNCHOUT_SUPPLIERPARTAUXID, null);
				xml.writeEndElement();
				xml.writeEndElement();

				xml.writeStartElement(null, EC_Constants.PUNCHOUT_ITEMDETAIL, null);
				xml.writeStartElement(null, EC_Constants.PUNCHOUT_UNITPRICE, null);
				xml.writeStartElement(null, EC_Constants.PUNCHOUT_MONEY, null);
				xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_CURRENCY, itemRec.ccrz__Cart__r.ccrz__CurrencyISOCode__c);
				if(string.valueof(itemRec.ccrz__Price__c) != null && string.valueof(itemRec.ccrz__Price__c) != '') {
					xml.writeCharacters(string.valueof(itemRec.ccrz__Price__c));
				}
				xml.writeEndElement();
				xml.writeEndElement();

				xml.writeStartElement(null, EC_Constants.PUNCHOUT_DESCRPTION, null);
				xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_XMLLANG, punchInfoRec [0].EC_XMLLanguage__c);
				xml.writeStartElement(null, EC_Constants.PUNCHOUT_SHORTNAME, null);
				if(itemRec.ccrz__Product__r.Name != null && itemRec.ccrz__Product__r.Name != '') {
					xml.writeCharacters(itemRec.ccrz__Product__r.Name);
				}
				xml.writeEndElement();
				xml.writeEndElement();

				xml.writeStartElement(null, EC_Constants.PUNCHOUT_UOM, null);
				if(itemRec.ccrz__UnitOfMeasure__c != null && itemRec.ccrz__UnitOfMeasure__c != '') {
					xml.writeCharacters(itemRec.ccrz__UnitOfMeasure__c);
				}
				xml.writeEndElement();

				xml.writeStartElement(null, EC_Constants.PUNCHOUT_CLASSIFICATION, null);
				xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_DOMAIN, EC_Constants.PUNCHOUT_UNSPSC);
				xml.writeEndElement();
				xml.writeEndElement();
				xml.writeEndElement();
			}
			xml.writeEndElement();
			xml.writeEndElement();
			xml.writeEndElement();

			cxmlString = xml.getXmlString();
			xml.close();

		}
		responseMap.put('cxmlString', cxmlString);
		//return cxmlString;
		return responseMap;
		// return System.Label.EC_PunchOut_CXMLPrefix + cxmlString;
	}
	/*************************************************************************************************************************************
	 Method Name : generateCXMLWIthError
	 Description : A remote action call to create the CXML with the error thrown
	 Parameter   : Error message
	 Return type : String - CXML string
	 Author      : Harsha N
	 *************************************************************************************************************************************/
	@RemoteAction
	global static string generateCXMLWIthError(String errorThrown) {
		string cxmlErrorString = '';

		XmlStreamWriter xml = new XmlStreamWriter();
		xml.writeStartElement(null, EC_Constants.PUNCHOUT_CXML, null);
		//xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_XMLLANG, 'en');
		xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_PAYLOADID, '20060111154256.123.@buyefficient.com');
		xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_TIMESTAMP, datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssZ'));
		xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_VERSION, '1.0');
		xml.writeStartElement(null, EC_Constants.PUNCHOUT_RESPONSE, null);
		xml.writeStartElement(null, EC_Constants.PUNCHOUT_STATUS, null);
		xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_CODE, '3000');
		xml.writeAttribute(null, null, EC_Constants.PUNCHOUT_TEXT, errorThrown);
		xml.writeEndElement();
		xml.writeEndElement();
		xml.writeEndElement();

		cxmlErrorString = xml.getXmlString();

		xml.close();

		return System.Label.EC_PunchOut_CXMLPrefix + cxmlErrorString;
	}

	/*************************************************************************************************************************************
	 Method Name : redirectToPunchoutLogin
	 Description : To redirect to the IFrame Custom page created, which in turn would be redirecting to the Commerce store during the Punch in request
	 Parameter   : None
	 Return type : PageReference
	 Author      : Ayusha Patnaik
	 *************************************************************************************************************************************/
	global static PageReference redirectToPunchoutLogin() {

		String ukey = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get(EC_Constants.PUNCHOUT_UKEY));
		String pkey = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get(EC_Constants.PUNCHOUT_PKEY));

		if(String.isNotBlank(ukey) && String.isNotBlank(pkey)) {
			Map<String, String> userDetails = EC_PunchoutUtility.decryptUserCredentials(ukey, pkey);
			String username = userDetails.get('decryptedUserName');
			String password = userDetails.get('decryptedPassword');
			List<ccrz__E_Category__c> categoryList = [SELECT Id FROM ccrz__E_Category__c WHERE ccrz__CategoryID__c = :System.Label.EC_CATEGORIES_ALLPRODUCTS LIMIT 1];
			String u = System.Label.EC_Punchout_IFrameCustonUrl1 + categoryList [0].Id + EC_Constants.PUNCHOUT_URLEFFECTIVEACCOUNT + String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get(EC_Constants.PUNCHOUT_URLEFFECTIVEACCATTR)) + EC_Constants.PUNCHOUT_URLCARTID + String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get(EC_Constants.PUNCHOUT_URLCARTIDATTR));
			PageReference pagek = Site.login(username, password, u);
			system.debug(pagek);
			return pagek;

		}

		startURL = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get(EC_Constants.PUNCHOUT_STARTURL));
		String pageUrl = Site.getBaseUrl();
		pageURl = pageURl.substringBefore(EC_Constants.PUNCHOUT_DEFAULTSTORE);
		pageUrl = pageUrl + System.Label.EC_PunchOut_LoginURL;
		PageReference pageRef = new PageReference(pageUrl);
		pageRef.getParameters().put(EC_Constants.PUNCHOUT_STARTURL, startURL);
		return pageRef;
	}
}