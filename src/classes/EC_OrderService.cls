/********************************************************************************************************
* @Class Name    EC_OrderService 
* @description   EC_OrderService is used to process orders and submit them to Tibco
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 
public class EC_OrderService {

    public class ServiceResponse {
        public Map<ID,ccrz__E_Order__c> orders;
        public Map<ID,EC_Order_Submission_Error__c> errors;
        public List<EC_WebServiceCalloutsLog__c> servicelogs = new List<EC_WebServiceCalloutsLog__c>();
        public ServiceResponse() {
            orders = new Map<ID,ccrz__E_Order__c>();
            errors = new Map<ID,EC_Order_Submission_Error__c>();
        }
    }
    
    /***************************************************************************************************************************************
      Method Name : processOrder
      Description : This method is called from process builder and submit orders to Tibco
      Return type : void
     **************************************************************************************************************************************/
     
    
   //method to be called from process builder when order is submitted
    @InvocableMethod
    public static void processOrder(List<Id> orderIds){
        
              
        EC_OrderService.processOrderFuture(orderIds);
        
    }
    
    /***************************************************************************************************************************************
      Method Name : processOrderFuture
      Description : This method is used to submit Orders to Tibco
      Return type : void
     **************************************************************************************************************************************/
     
    
   @future(callout=true)
   public static void processOrderFuture(List<Id> orderIds){
      
        System.debug('orders-->'+orderIds);
        
        String query  = EC_OrderService.getOrderQuery();
        Id orderId = orderIds.get(0);
        query += ' Where Id = \''+orderId +'\'';
        
        List<ccrz__E_Order__c> orders = Database.query(query);
        
        System.debug('orders size'+orders.size());
        System.debug('orders-->'+orders);
        
        EC_OrderService.processOrders(orders);
   
   
   }
   
   /***************************************************************************************************************************************
      Method Name : processOrders
      Description : This method calls Tibco API and submit the order.
      Return type : ServiceResponse
     **************************************************************************************************************************************/
     
    
    
    public static ServiceResponse processOrders(list<ccrz__E_Order__c> orders){
        
        
        List<EC_Order_Submission_Error__c> orderSubmissionError = null;
        orderSubmissionError = new list<EC_Order_Submission_Error__c>();
        ServiceResponse response = null;
        response = new ServiceResponse();

        if( orders != null && !orders.isEmpty() ){

            EC_OrderDAO dao = null;
            dao = new EC_DAOFactory().getEcolabTIBCODao();
            String errMsg = '';
            EC_Order_Submission_Error__c error;

            for( ccrz__E_Order__c order : orders ){
                error = null;
                EC_OrderDAO.CalloutResult result;
                try{
                    result = dao.createPurchaseOrder(order);
                    
                    if(result.ex != null){
                        throw result.ex;
                    }
                    
                    System.debug('CC_OrderService: WS Response: ' + result);
                    if ( result.status == true ) {
                       order.ccrz__OrderStatus__c = 'Submitted';
                    }else {
                        error = processFailedOrder(order, result.message);
                        orderSubmissionError.add( error );
                        response.errors.put(order.Id, error);
                    }
                } catch( Exception exc ){
                    error = processFailedOrder(order, exc.getMessage());
                    orderSubmissionError.add( error );
                    response.errors.put(order.Id, error);
                }
                response.orders.put(order.ID, order);
                response.servicelogs.add(result.logRec);
            }

            try{
                List<Database.SaveResult> srResult = database.update(orders, false);
            } catch (Exception e) {
                //Write out exception for every order because they are out of sync.
                for( ccrz__E_Order__c order : orders ){
                    orderSubmissionError.add(createOrderError(order.ID,e.getLineNumber() + ': ' + e.getTypeName() + ' : '+ e.getMessage(), 'ORDER_EXCEPTION_ERROR'));
                }
            }

            if( orderSubmissionError.size() > 0 ){
                    database.insert(orderSubmissionError, false);
            }
            if(response.servicelogs.size() > 0){
                
                database.insert(response.servicelogs, false);
                    
            }

        }

        return response;
    }

/***************************************************************************************************************************************
      Method Name : createOrderError
      Description : This method is used to create error log for failed orders
      Return type : EC_Order_Submission_Error__c 
     **************************************************************************************************************************************/
     
    public static EC_Order_Submission_Error__c createOrderError(string OrderID, string errMsg, string webServiceName){
        EC_Order_Submission_Error__c error = new EC_Order_Submission_Error__c();
        error.EC_CC_Order__c               = OrderID;
        if(errMsg.length() > 255){
            errMsg = errMsg.left(255);
        }
        error.EC_Error_Description__c      = errMsg;
        error.EC_Request__c                = '';
        error.EC_Web_Service_Name__c       = webServiceName;
        return error;
    }
    
    
/***************************************************************************************************************************************
      Method Name : gerOrderQuery
      Description : This method is used to return query for CC Object record
      Return type : String
     **************************************************************************************************************************************/
  

    public static String getOrderQuery(){
        // Build Query

       String query =
                'Select  Id,ccrz__Account__r.EC_Account_Number__c,ccrz__EffectiveAccountID__c,ccrz__Account__r.EC_Division__c,Name, ccrz__Storefront__c, ccrz__OrderStatus__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c,ccrz__BuyerEmail__c, ccrz__BuyerPhone__c, ' +
                        ' ccrz__BuyerMobilePhone__c, ccrz__PaymentMethod__c, ccrz__ShipComplete__c, ccrz__ShipMethod__c, ccrz__SubTotalAmount__c, ccrz__TotalDiscount__c, ' +
                        ' ccrz__ShipAmount__c, ccrz__TaxAmount__c, ccrz__TotalAmount__c, ccrz__OrderDate__c, EC_Submission_Failure_Count__c, ' +
                        ' ccrz__Account__r.Name, ccrz__BillTo__r.ccrz__FirstName__c , ccrz__BillTo__r.ccrz__MiddleName__c, ccrz__BillTo__r.ccrz__LastName__c,' +
                        ' ccrz__BillTo__r.ccrz__Email__c,    ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondLine__c, ccrz__BillTo__r.ccrz__City__c,' +
                        ' ccrz__BillTo__r.ccrz__DaytimePhone__c, ccrz__BillTo__r.ccrz__HomePhone__c, ccrz__ShipTo__r.ccrz__DaytimePhone__c, ccrz__ShipTo__r.ccrz__HomePhone__c, ' +
                        ' ccrz__BillTo__r.ccrz__StateISOCode__c, ccrz__BillTo__r.ccrz__CountryISOCode__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__FirstName__c    ,' +
                        ' ccrz__ShipTo__r.ccrz__MiddleName__c, ccrz__ShipTo__r.ccrz__LastName__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondLine__c, ' +
                        ' ccrz__ShipTo__r.ccrz__City__c, ccrz__ShipTo__r.ccrz__StateISOCode__c, ccrz__ShipTo__r.ccrz__CountryISOCode__c, ccrz__ShipTo__r.ccrz__PostalCode__c,' +
                        ' ccrz__ShipTo__r.ccrz__ShippingComments__c, ccrz__ShipTo__r.ccrz__Partner_Id__c, ccrz__OriginatedCart__c, ccrz__PONumber__c, ccrz__RequestDate__c,EC_Order_Submission_Type__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Division__c,ccrz__OriginatedCart__r.EC_Ship_To_Account__r.EC_Account_Number__c, '+ 
 
                        '( Select Id, Name, ccrz__ProductType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.Name, ccrz__Quantity__c,' +
                        '         ccrz__Price__c, ccrz__SubAmount__c, ccrz__Comments__c from ccrz__E_OrderItems__r ), ' +

                        '( Select Id, Name, ccrz__Token__c,ccrz__Amount__c, ccrz__PaymentType__c, ccrz__Comments__c,ccrz__RequestAmount__c,ccrz__TransactionTS__c,' +
                        '         ccrz__ExpirationMonth__c, ccrz__ExpirationYear__c, ccrz__AccountNumber__c, ccrz__TransactionCode__c,ccrz__CurrencyISOCode__c,ccrz__TransactionSubcode__c' +
                        '     From ccrz__TransactionPayments__r ) ' +

                        'From ccrz__E_Order__c ';
        return query;
    }
    
    
/***************************************************************************************************************************************
      Method Name : processFailedOrder
      Description : This method is used to create error log for failed orders and creates entry in log table
      Return type : EC_Order_Submission_Error__c 
     **************************************************************************************************************************************/
  

    @TestVisible
    private static EC_Order_Submission_Error__c processFailedOrder(ccrz__E_Order__c order, String errMessage) {
       
        System.debug('EC_OrderService: Failed Result Message: ' + errMessage);

        order.ccrz__OrderStatus__c = 'Failed';

        if( order.EC_Submission_Failure_Count__c == null ){
            order.EC_Submission_Failure_Count__c = 0;
        }

        order.EC_Submission_Failure_Count__c++;
        String errMsg;
        if (errMessage != null && errMessage.length() >= 131072 ) {
            errMsg = errMessage.substring(0,131072);
        } else {
            errMsg = errMessage;
        }

        EC_Order_Submission_Error__c error = new EC_Order_Submission_Error__c();
        error.EC_CC_Order__c               = order.Id;
        error.EC_Error_Description__c      = errMsg;
        error.EC_Request__c                = '';
        error.EC_Web_Service_Name__c       = 'TIBCO';
        return error;
    }
}