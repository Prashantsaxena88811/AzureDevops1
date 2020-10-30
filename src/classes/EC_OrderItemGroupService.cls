/* Class Name      : EC_OrderItemGroupService
* Description      : Service Class for Splitting order for Mulesoft API
* Created By       : Bharath Kn
* Created On       : 2020-Sept-03


* Modification Log:
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bharath Kn            2020-Sept-03         PBI-                  Created the class
*
*/
public class EC_OrderItemGroupService {
    
    public class ServiceResponse {
        public Map<ID,ccrz__E_OrderItemGroup__c> orderItemGroups;
        public Map<ID,EC_Order_Submission_Error__c> errors;
        public List<EC_WebServiceCalloutsLog__c> servicelogs = new List<EC_WebServiceCalloutsLog__c>();
        public ServiceResponse() {
            orderItemGroups = new Map<ID,ccrz__E_OrderItemGroup__c>();
            errors = new Map<ID,EC_Order_Submission_Error__c>();
        }
    }
    
    //method to be called from process builder when order is submitted
    @InvocableMethod
    public static void processOrderItemGroup(List<Id> orderGroupItemIds){
        System.debug('orderGroupItemIdss-->'+orderGroupItemIds);
        EC_OrderItemGroupService.processOItemGroupFuture(orderGroupItemIds);
    }
    
    @future(callout=true)
    public static void processOItemGroupFuture(List<Id> orderIds){
        System.debug('orderGroupItemIdsLogCheck-->'+orderIds);
        //for(Id orderGroupItemId : orderGroupItemIds){
            String query  = EC_OrderItemGroupService.getOrderItemGroupQuery();
            query += ' Where ccrz__Order__c = \''+orderIds[0] +'\'';
            List<ccrz__E_OrderItemGroup__c> orderItemGroups = Database.query(query);
            System.debug('orderItemGroups-->'+orderItemGroups);
            EC_OrderItemGroupService.processOrderItemGroups(orderItemGroups);
            
       // }
    }
    
    public static ServiceResponse processOrderItemGroups(List<ccrz__E_OrderItemGroup__c> orderItemGroups){        
        List<EC_Order_Submission_Error__c> orderSubmissionError = new list<EC_Order_Submission_Error__c>();
        
        
        ServiceResponse response = null;
        response = new ServiceResponse();
        Map<String,String> requestConfigMap = new Map<String,String>();
        
       
        if( orderItemGroups != null && !orderItemGroups.isEmpty() ){
            
            String errMsg = '';
            EC_Order_Submission_Error__c error;
            for(MulesoftOrderSubmitAPIConfig__mdt orderSubmitConfig : [Select Key__c,Value__c from MulesoftOrderSubmitAPIConfig__mdt where Label = 'Order Submit']){
                requestConfigMap.put(orderSubmitConfig.Key__c,orderSubmitConfig.Value__c);
            }
            String accessToken = EC_CalloutUtility.doTokenCallout();
            requestConfigMap.put('Authorization','Bearer '+ accessToken); 
            for( ccrz__E_OrderItemGroup__c orderItemGroup : orderItemGroups ){
                error = null;                
                HttpResponse result;
                
                try{                    

                    EC_OrderItemGroupServiceInput payloadRequest = EC_OrderItemGroupDAO.createOrderPayload(orderItemGroup);

                    System.debug('MuleSoftAPI Request----->'+JSON.serialize(payloadRequest));
                    result = EC_CalloutUtility.doOrderSubmitApiCallout(JSON.serialize(payloadRequest), requestConfigMap);
                    System.debug('result----->'+result);
                    if(orderItemGroup.SAP_OrderNumber__c == null)    { 
                        response = updateOrdertItemGroupStatus(result,orderItemGroup,orderSubmissionError);
                    }
          } catch( Exception exc ){
                    system.debug(exc.getMessage() +'  '+exc.getLineNumber());
                    error = processFailedOrder(orderItemGroup, exc.getMessage());
                    orderSubmissionError.add( error );
                    response.errors.put(orderItemGroup.Id, error);
                }
                response.orderItemGroups.put(orderItemGroup.ID, orderItemGroup);
                System.debug('logRec-->'+result);
                // response.servicelogs.add(error);
            }
            try{
                System.debug('Service Output--GKM>'+orderItemGroups);
                List<Database.SaveResult> srResult = database.update(orderItemGroups, false);
            } catch (Exception e) {
                //Write out exception for every order because they are out of sync.
                for( ccrz__E_OrderItemGroup__c orderItemGroup : orderItemGroups ){
                    orderSubmissionError.add(createOrderItemGroupError(orderItemGroup.ID,e.getLineNumber() + ': ' + e.getTypeName() + ' : '+ e.getMessage(), 'ORDER_EXCEPTION_ERROR'));
                }
            }

            createRemoteLogs(orderSubmissionError,response);
        }
        
        return response;
    }    
    
    public static String getOrderItemGroupQuery(){
        // Build Query
       String query =
                'Select  Id,Name,Order_Item_Group_Status__c,SAP_OrderNumber__c,Mulesoft_Response_Description__c,Billing_Arrangement__c,Order_Type__c,ccrz__Order__r.ccrz__Account__r.EC_Account_Number__c,ccrz__Order__r.ccrz__EffectiveAccountID__c,ccrz__Order__r.ccrz__Account__r.EC_Division__c,ccrz__Order__r.Name, ccrz__Order__r.ccrz__Storefront__c, ccrz__Order__r.ccrz__OrderStatus__c, ccrz__Order__r.ccrz__BuyerFirstName__c, ccrz__Order__r.ccrz__BuyerLastName__c,ccrz__Order__r.ccrz__BuyerEmail__c, ccrz__Order__r.ccrz__BuyerPhone__c, ' +
                        ' ccrz__Order__r.ccrz__BuyerMobilePhone__c, ccrz__Order__r.ccrz__PaymentMethod__c, ccrz__Order__r.ccrz__ShipComplete__c, ccrz__Order__r.ccrz__ShipMethod__c, ccrz__Order__r.ccrz__SubTotalAmount__c, ccrz__Order__r.ccrz__TotalDiscount__c,Billing_Arrangement__r.BA_Number__c,ccrz__Order__r.ccrz__Account__r.EC_SalesRepresentative__r.FirstName, ' +
                        ' ccrz__Order__r.ccrz__ShipAmount__c, ccrz__Order__r.ccrz__TaxAmount__c, ccrz__Order__r.ccrz__TotalAmount__c, ccrz__Order__r.ccrz__OrderDate__c, Submission_Failure_Count__c,ccrz__Order__r.ccrz__Account__r.Parent.Name,ccrz__Order__r.ccrz__Account__r.EC_SalesOrg__c,ccrz__Order__r.ccrz__Account__r.EC_SalesRepresentative__r.LastName, ' +
                        ' ccrz__Order__r.ccrz__Account__r.Name, ccrz__Order__r.ccrz__BillTo__r.ccrz__FirstName__c , ccrz__Order__r.ccrz__BillTo__r.ccrz__MiddleName__c, ccrz__Order__r.ccrz__BillTo__r.ccrz__LastName__c,ccrz__Order__r.ccrz__BillTo__r.Name,ccrz__Order__r.ccrz__Account__r.EC_Billing_Account_Number__c, ' +
                        ' ccrz__Order__r.ccrz__BillTo__r.ccrz__Email__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__Order__r.ccrz__BillTo__r.ccrz__AddressSecondLine__c, ccrz__Order__r.ccrz__BillTo__r.ccrz__City__c,ccrz__Order__r.OrderRushEmail__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__Partner_Id__c,' +
                        ' ccrz__Order__r.ccrz__BillTo__r.ccrz__DaytimePhone__c, ccrz__Order__r.ccrz__BillTo__r.ccrz__HomePhone__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__DaytimePhone__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__HomePhone__c,ccrz__Order__r.ccrz__Account__r.EC_ShipToNumber__c,' +
                        ' ccrz__Order__r.ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__Order__r.ccrz__BillTo__r.ccrz__CountryISOCode__c, ccrz__Order__r.ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__FirstName__c,ccrz__Order__r.ccrz__Contact__r.FirstName,ccrz__Order__r.ccrz__Contact__r.LastName,' +
                        ' ccrz__Order__r.ccrz__ShipTo__r.ccrz__MiddleName__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__LastName__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressSecondLine__c,ccrz__Order__r.ccrz__Contact__r.EC_CDM_Contact__c, ' +
                        ' ccrz__Order__r.ccrz__ShipTo__r.ccrz__City__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__StateISOCode__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__CountryISOCode__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__PostalCode__c,ccrz__Order__r.ccrz__Account__r.Carrier_Haulier_Note__c,' +
                        ' ccrz__Order__r.ccrz__ShipTo__r.ccrz__ShippingComments__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__Partner_Id__c, ccrz__Order__r.ccrz__OriginatedCart__c, ccrz__Order__r.ccrz__PONumber__c, ccrz__Order__r.ccrz__RequestDate__c,ccrz__Order__r.EC_Order_Submission_Type__c,ccrz__Order__r.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Division__c,ccrz__Order__r.ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c, '+ 
 
                        '( Select Id, Name, ccrz__ProductType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.Name, ccrz__Quantity__c,Billing_Arrangement__r.Price_List_Type_Expansion__c,ccrz__Order__r.ccrz__PONumber__c,Custom_PricingUOM__c,Tank_Number__r.Tank_Number__c,Unloading_Point__r.ccrz__CompanyName__c,' +
                        '         ccrz__Price__c, ccrz__SubAmount__c, ccrz__Comments__c from ccrz__E_OrderItems__r ) ' +

                      /*  '( Select Id, Name, ccrz__Token__c,ccrz__Amount__c, ccrz__PaymentType__c, ccrz__Comments__c,ccrz__RequestAmount__c,ccrz__TransactionTS__c,' +
                        '         ccrz__ExpirationMonth__c, ccrz__ExpirationYear__c, ccrz__AccountNumber__c, ccrz__TransactionCode__c,ccrz__CurrencyISOCode__c,ccrz__TransactionSubcode__c' +
                        '     From ccrz__TransactionPayments__r ) ' +*/

                        'From ccrz__E_OrderItemGroup__c ';
        //ccrz__Order__r.
        return query;
    }
    
    @TestVisible
    private static EC_Order_Submission_Error__c processFailedOrder(ccrz__E_OrderItemGroup__c orderItemGroup, String errMessage) {
        
        System.debug('EC_OrderItemGroupService: Failed Result Message: ' + errMessage);
        
        orderItemGroup.Order_Item_Group_Status__c = 'Failed';
        
        if( orderItemGroup.Submission_Failure_Count__c == null ){
            System.debug('EC_OrderItemGroupService: Failed Result Messag  comming here ');
            orderItemGroup.Submission_Failure_Count__c = 0;
        }
        
        orderItemGroup.Submission_Failure_Count__c++;
        String errMsg;
        if (errMessage != null && errMessage.length() >= 131072 ) {
            errMsg = errMessage.substring(0,131072);
        } else {
            errMsg = errMessage;
        }
        
        EC_Order_Submission_Error__c error = new EC_Order_Submission_Error__c();
        error.EC_CC_Order__c               = orderItemGroup.Id;
        error.EC_Error_Description__c      = errMsg;
        error.EC_Request__c                = '';
        error.EC_Web_Service_Name__c       = 'MuleSoft';
        return error;
    }
    public static EC_Order_Submission_Error__c createOrderItemGroupError(string OrderItemGroupID, string errMsg, string webServiceName){
        EC_Order_Submission_Error__c error = new EC_Order_Submission_Error__c();
        error.EC_CC_Order__c               = OrderItemGroupID;
        if(errMsg.length() > 255){
            errMsg = errMsg.left(255);
        }
        error.EC_Error_Description__c      = errMsg;
        error.EC_Request__c                = '';
        error.EC_Web_Service_Name__c       = webServiceName;
        return error;
    }

    public static ServiceResponse updateOrdertItemGroupStatus(HttpResponse result, ccrz__E_OrderItemGroup__c orderItemGroup,List<EC_Order_Submission_Error__c> orderSubmissionError){
                    ServiceResponse response = new ServiceResponse();
        			EC_Order_Submission_Error__c error;
                    System.debug('result----->'+result);
                    OrderSubmitResponse orderResponse = OrderSubmitResponse.parse(result.getBody());
                    OrderSubmitResponse.Response orderSubmitResponseResult = orderResponse.response;
                    if (result.getStatusCode() == 202) {
                        System.debug('orderSubmitResponseResult----->'+orderSubmitResponseResult);
                        if(orderSubmitResponseResult.orderStatus!=Null  && orderItemGroup.SAP_OrderNumber__c == null){
                            System.debug('orderSubmitResponseResult status----->'+orderSubmitResponseResult.orderStatus);
                            orderItemGroup.Order_Item_Group_Status__c = getOrderResponseStatus(orderSubmitResponseResult.orderStatus);
                            System.debug('MuleSoftAPI orderStatus Updated----->'+orderItemGroup.Order_Item_Group_Status__c);
                            orderItemGroup.Submission_Failure_Count__c = 0;
                            orderItemGroup.Mulesoft_Response_Description__c = orderSubmitResponseResult.orderStatusDesc;
                        }
                    }else {
                        error = processFailedOrder(orderItemGroup, String.valueOf(result.getStatusCode()));
                        //System.debug('Error comming GKM hence else codtition' + error);
                        orderSubmissionError.add( error );
                        response.errors.put(orderItemGroup.Id, error);
                    }
        return response;
        
    }
    
    public static void createRemoteLogs(List<EC_Order_Submission_Error__c> orderSubmissionError, ServiceResponse response){
        if( orderSubmissionError.size() > 0 ){
            database.insert(orderSubmissionError, false);
        }
        if(response.servicelogs.size() > 0){
            database.insert(response.servicelogs, false);
        }
    }
    public static String getOrderResponseStatus (String muleSoftStatus) {
        map<string,String> statusMap = new map<string,String>();
        for(Mulesoft_Status_Response__mdt item : [Select Label, Connect_Order_Status__c,Mulesoft_Status_Response__c from Mulesoft_Status_Response__mdt]) {
            statusMap.put(item.Mulesoft_Status_Response__c, item.Connect_Order_Status__c);
        }
        System.debug('statusMap----->'+statusMap);
        System.debug('statusMap status----->'+statusMap.get(muleSoftStatus));
        return statusMap.get(muleSoftStatus);
    }
}
