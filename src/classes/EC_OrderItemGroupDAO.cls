/* Class Name      : EC_OrderItemGroupDAO
* Description      : Service Class for creating payload for order submit
* Created By       : Bharath Kn
* Created On       : 2020-Sept-03


* Modification Log:
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bharath Kn            2020-Sept-03         PBI-                  Created the class
*
*/
public with sharing class EC_OrderItemGroupDAO {
    public static final String freightForwarder = '';
    public static final String relationshipWithEcolab = 'TM';
    public static final String orderChannel =  System.label.EC_OrderChannel;
    public static final Integer distributionChannel = 01;
    public static final Integer division = 1;
    
    public static EC_OrderItemGroupServiceInput createOrderPayload(ccrz__E_OrderItemGroup__c ccOrderItemGroup) {
        
		String STNumber = String.valueof(ccOrderItemGroup.ccrz__Order__r.ccrz__Account__r.EC_ShipToNumber__c);
        String SolNumber = String.valueof(ccOrderItemGroup.ccrz__Order__r.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c);
        EC_OrderItemGroupServiceInput.orderRequestClass wsOrder = new EC_OrderItemGroupServiceInput.orderRequestClass();
        wsOrder.orderNumberFromSource                           =       ccOrderItemGroup.Name;
        wsOrder.orderType                                       =       checkNull(ccOrderItemGroup.Order_Type__c);
        wsOrder.contactEmail                                    =       ccOrderItemGroup.ccrz__Order__r.ccrz__BuyerEmail__c;
        wsOrder.billingArrangementNumber                        =       checkNull(ccOrderItemGroup.Billing_Arrangement__r.BA_Number__c);
        wsOrder.soldToNumber                                    =       checkLong(SolNumber);
        
        wsOrder.shipToNumber 									= 		checkLong(STNumber);
        wsOrder.billToNumber                                    =       checkLong(ccOrderItemGroup.ccrz__Order__r.ccrz__BillTo__r.ccrz__Partner_Id__c);
        wsOrder.purchaseOrderNumber                             =       checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__PONumber__c);// If Credit card - Credit card+'' DOT /if BA = ''
        wsOrder.freightForwarder                                =       freightForwarder;
        wsOrder.relationshipWithEcolab                          =       relationshipWithEcolab; // Will be Blank
        wsOrder.orderChannel                                    =       orderChannel;
        //wsOrder.shippingNotes                                   =       checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__Account__r.Carrier_Haulier_Note__c);
        wsOrder.shippingNotes                                   =       '';
        wsOrder.requestedDeliveryDate                           =       String.valueOf(ccOrderItemGroup.ccrz__Order__r.ccrz__RequestDate__c).remove('-');
        wsOrder.deliveryContactPhoneNumber 						= 		checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__BuyerPhone__c);
        wsOrder.deliveryContactLastName							= 		checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__Contact__r.LastName);
        wsOrder.deliveryContactFirstName						= 		checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__Contact__r.FirstName);
        wsOrder.payerNumber                                     =       checkLong(ccOrderItemGroup.ccrz__Order__r.ccrz__BillTo__r.ccrz__Partner_Id__c); // Bill to number
        wsOrder.salesOrg                                        =       checkInteger(ccOrderItemGroup.ccrz__Order__r.ccrz__Account__r.EC_SalesOrg__c);
        wsOrder.distributionChannel                             =       distributionChannel;//Static
        wsOrder.division                                        =       division;//Static
        wsOrder.employeeResponsibleID                           =       checkInteger(ccOrderItemGroup.ccrz__Order__r.ccrz__Contact__r.EC_CDM_Contact__c); //CDM User key
        wsOrder.employeeResponsibleFirstName					=       checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__Account__r.EC_SalesRepresentative__r.FirstName);
        wsOrder.employeeResponsibleLastName						=       checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__Account__r.EC_SalesRepresentative__r.LastName);
        // Just in case if Transaction record is empty
        wsOrder.creditcardToken                                 =       '';//Exact tag name TBD
        wsOrder.creditcardName                                  =       '';//Exact tag name TBD
        wsOrder.creditcardExpiry                                =       '';//Exact tag name TBD
        wsOrder.creditcardType                                  =       '';//Exact tag name TBD  
        //CC Token details
        if (ccrz__E_PaymentDetail__c.sObjectType.getDescribe().isAccessible() && ccrz__E_OrderItemGroup__c.sObjectType.getDescribe().isAccessible()) {    
            List<ccrz__E_PaymentDetail__c> paymentDetails = [select id,ccrz__Credit_Card_Type__c,ccrz__Payment_Method__c,ccrz__Payment_Token__c,ccrz__Expiration_Month__c, ccrz__Expiration_Year__c
                                                                  from ccrz__E_PaymentDetail__c where ccrz__CC_Order__c in (select ccrz__Order__c from ccrz__E_OrderItemGroup__c where id = :ccOrderItemGroup.Id)];
            system.debug('paymentDetails--'+paymentDetails);
            if(paymentDetails != null && !paymentDetails.isEmpty()){
                Datetime dt = datetime.newInstance(Integer.valueOf(paymentDetails[0].ccrz__Expiration_Year__c), Integer.valueOf(paymentDetails[0].ccrz__Expiration_Month__c), 1);
                wsOrder.creditcardToken = checkNull(paymentDetails[0].ccrz__Payment_Token__c);
                wsOrder.creditcardName= checkNull(paymentDetails[0].ccrz__Payment_Method__c);//Exact tag name TBD
                wsOrder.creditcardExpiry = checkNull(dt.format('MMyyyy'));
                wsOrder.creditcardType= checkCCType(String.Valueof(paymentDetails[0].ccrz__Credit_Card_Type__c));
            }
        }
        wsOrder.callbackURL= URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/sobjects/ccrz__E_OrderItemGroup__c/'+ccOrderItemGroup.Id;//Exact tag name TBD

        wsOrder.lineItems = new LIST<EC_OrderItemGroupServiceInput.Products>();        
        Map<id,id> PLprodMap = new Map<id,id>();
        Set<Id> SPAProductIds = new Set<Id>();
        for(ccrz__E_OrderItem__c i : ccOrderItemGroup.ccrz__E_OrderItems__r) {
            if(i.Billing_Arrangement__c == null){
               SPAProductIds.add(i.ccrz__Product__c); // check if in query
            }else{
                PLprodMap.put(i.Billing_Arrangement__c, i.ccrz__Product__c);
            }
        }
        
        map<id,id> prodItemNoMap = new map<id,id>();
        if(!PLprodMap.isEmpty()) {
            system.debug('Inside if PLprodMap--'+PLprodMap);
            for(ccrz__E_PriceListItem__c PLI : [select Item_Number__c,ccrz__Product__c from ccrz__E_PriceListItem__c
                                                where Id IN:PLprodMap.keySet() AND ccrz__Product__c IN:PLprodMap.values() AND Item_Number__c != null]) {
                                                    prodItemNoMap.put(PLI.ccrz__Product__c,PLI.Item_Number__c);
                                                }
        }
        String effectiveAccount = ccOrderItemGroup.ccrz__Order__r.ccrz__EffectiveAccountID__c;
        Map<String,ccrz__E_PriceListItem__c> productSPAPLIItemMAp = SPApriceListMap(SPAProductIds,effectiveAccount);
		returnBANumber(wsOrder,productSPAPLIItemMAp);
		
        wsOrder.lineItems = getLineItems(ccOrderItemGroup,prodItemNoMap,productSPAPLIItemMAp);
      
        
        EC_OrderItemGroupServiceInput parentNode = new EC_OrderItemGroupServiceInput();
        parentNode.orderRequest = wsOrder;
        return parentNode;
    }
    public static string checkCCType(String value)   {
        String creditCardType ='';
        if(value == 'Visa') {
            creditCardType = 'VISA';
        }
        if (value == 'Mastercard'){
            creditCardType = 'MC';
        }
        return creditCardType;
    }
    public static String checkNull(String value) {
        return String.isNotBlank(value)? value : '';
    }
    public static Integer checkInteger(String value) {
        if(value == null) {
            return 0;
        } else {
            return Integer.valueof(value)>0 ? Integer.valueof(value) : 0;
        }
    }
    public static Long checkLong(String value) {
        if(value == null) {
            return 0;
        } else {
            String delimiter = '/';
            String firstSplit = value.substringBefore(delimiter); 
            return Long.valueof(firstSplit)>0 ? Long.valueof(firstSplit) : 0; 
        }
    }
    public static LIST<EC_OrderItemGroupServiceInput.Products> getLineItems (ccrz__E_OrderItemGroup__c ccOrderItemGroup, map<id,id> prodItemNoMap,Map<String,ccrz__E_PriceListItem__c> productSPAPLIItemMAp){
        LIST<EC_OrderItemGroupServiceInput.Products> lineItems = new LIST<EC_OrderItemGroupServiceInput.Products>(); 
        for(ccrz__E_OrderItem__c i : ccOrderItemGroup.ccrz__E_OrderItems__r) {
            EC_OrderItemGroupServiceInput.Products lItems = new EC_OrderItemGroupServiceInput.Products();
            lItems.billingArrangementLineNumber = '';
            if(prodItemNoMap.containsKey(i.ccrz__Product__c)) {
                lItems.billingArrangementLineNumber = checkNull(prodItemNoMap.get(i.ccrz__Product__c));// New field on PriceList Item
            }else{
                if(productSPAPLIItemMAp.containsKey(i.ccrz__Product__c)){
                    lItems.billingArrangementLineNumber = checkNull(productSPAPLIItemMAp.get(i.ccrz__Product__c).Item_Number__c);// New field on PriceList Item
                }
            }
            lItems.productSku = i.ccrz__Product__r.ccrz__SKU__c;
            lItems.quantity = Integer.valueof(i.ccrz__Quantity__c) ;
            String lower = checkNull(i.Custom_PricingUOM__c).toLowerCase();
            lItems.UOM = lower;
            lItems.tankNumber = checkNull(i.Tank_Number__r.Tank_Number__c);
            lItems.unloadingPoint= checkNull(i.Unloading_Point__r.ccrz__CompanyName__c);
            lItems.freightForwarder=freightForwarder; //Blank for Connect Oct Release
            lItems.rushOrder= ccOrderItemGroup.ccrz__Order__r.OrderRushEmail__c;//Boolean. @RJohn and Steve to confirm default rush code
            lItems.requestedDeliveryDate=String.valueOf(ccOrderItemGroup.ccrz__Order__r.ccrz__RequestDate__c).remove('-');//yyyymmdd
            //lItems.shippingNotes = checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__Account__r.Carrier_Haulier_Note__c);
            lItems.shippingNotes = '';
            lItems.COA = checkNull(i.Unloading_Point__r.ccrz__CompanyName__c); // Same as unloadingPoint
            lItems.deliveryContact = checkNull(ccOrderItemGroup.ccrz__Order__r.ccrz__BuyerPhone__c+ccOrderItemGroup.ccrz__Order__r.ccrz__Contact__r.FirstName+ccOrderItemGroup.ccrz__Order__r.ccrz__Contact__r.LastName);//phone+fisrtname+lastname
            String STNumber = String.valueof(ccOrderItemGroup.ccrz__Order__r.ccrz__Account__r.EC_ShipToNumber__c);
            lItems.shipToNumber = checkLong(STNumber);
            lineItems.add(lItems); 
        }
        return lineItems;
    }
    private static Map<String,ccrz__E_PriceListItem__c> SPApriceListMap (Set<Id> SPAProductIds, String effectiveAccount) {
        map<String,ccrz__E_PriceListItem__c> SPAPLmap = new map<String,ccrz__E_PriceListItem__c>();
        String acgrp = '';
        if(Account.sObjectType.getDescribe().isAccessible()) {
          acgrp = [Select ccrz__E_AccountGroup__c from Account Where Id=:effectiveAccount Limit 1].ccrz__E_AccountGroup__c;
        }
        for(ccrz__E_PriceListItem__c sbaPLI : [Select Id,ccrz__Product__c,Item_Number__c,ccrz__Pricelist__r.BA_Number__c from ccrz__E_PriceListItem__c 
                                               where ccrz__Product__c in:SPAProductIds and ccrz__Pricelist__r.EC_Price_List_Type__c = 'SBA'
                                               and ccrz__Pricelist__c in (SELECT ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c 
                                                                          where ccrz__AccountGroup__c=:acgrp )]){
                                                                              SPAPLmap.put(sbaPLI.ccrz__Product__c,sbaPLI);
                                                                          }
        system.Debug('SPAPLmap---'+SPAPLmap);
        return SPAPLmap;
    }
	
	private static void returnBANumber(EC_OrderItemGroupServiceInput.orderRequestClass wsOrder, Map<String,ccrz__E_PriceListItem__c> productSPAPLIItemMAp){
		if(!productSPAPLIItemMAp.isEmpty()){
			for(String prod : productSPAPLIItemMAp.keySet()){
				wsOrder.billingArrangementNumber = checkNull(productSPAPLIItemMAp.get(prod).ccrz__Pricelist__r.BA_Number__c);
				if(String.isNotBlank(wsOrder.billingArrangementNumber)){
					break;
				}
			}
		}
	}
}