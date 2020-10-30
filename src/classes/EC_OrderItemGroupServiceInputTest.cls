@isTest
public class EC_OrderItemGroupServiceInputTest {
    
    static testMethod void test_serviceInput(){
        
        EC_OrderItemGroupServiceInput.orderRequestClass wsOrder = new EC_OrderItemGroupServiceInput.orderRequestClass();
        wsOrder.orderNumberFromSource                           =       'FirstName LastName';
        wsOrder.orderType                                       =       'ZOS1';
        wsOrder.contactEmail                                    =       'test@email.com';
        wsOrder.billingArrangementNumber                        =       '9239919';
        wsOrder.soldToNumber                                    =       long.valueOf('10347008886357572');
        wsOrder.shipToNumber 									= 		long.valueOf('8886357572');
        wsOrder.billToNumber                                    =       18361;
        wsOrder.purchaseOrderNumber                             =       '';
        wsOrder.freightForwarder                                =       '1';
        wsOrder.relationshipWithEcolab                          =       'TM'; 
        wsOrder.orderChannel                                    =       '';
        wsOrder.shippingNotes                                   =       'Notes';
        wsOrder.requestedDeliveryDate                           =       '20201023';
        wsOrder.deliveryContactPhoneNumber 						= 		'9898989898';
        wsOrder.deliveryContactLastName							= 		'LastName';
        wsOrder.deliveryContactFirstName						= 		'FirstName';
        wsOrder.payerNumber                                     =       18361;
        wsOrder.salesOrg                                        =       1001;
        wsOrder.distributionChannel                             =       1;//Static
        wsOrder.division                                        =       1;//Static
        wsOrder.employeeResponsibleID                           =       12123; //CDM User key
        // Just in case if Transaction record is empty
        wsOrder.creditcardToken                                 =       '-E-12323424';//Exact tag name TBD
        wsOrder.creditcardName                                  =       'Credit Card';//Exact tag name TBD
        wsOrder.creditcardExpiry                                =       '012020';//Exact tag name TBD
        wsOrder.creditcardType                                  =       'VISA';//Exact tag name TBD  
        
        wsOrder.callbackURL = '/services/data/v49.0/sobjects/ccrz__E_OrderItemGroup__c/123232';
        
        LIST<EC_OrderItemGroupServiceInput.Products> lineItems = new LIST<EC_OrderItemGroupServiceInput.Products>(); 
        
        EC_OrderItemGroupServiceInput.Products lItems = new EC_OrderItemGroupServiceInput.Products();
        lItems.billingArrangementLineNumber = '';
        lItems.productSku = 'ST70.15';
        lItems.quantity = 1;
        lItems.UOM = 'EA';
        lItems.tankNumber = 'C5435';
        lItems.unloadingPoint = 'CHEMICAL RECEIVING';
        lItems.freightForwarder = '1'; 
        lItems.rushOrder = false;
        lItems.requestedDeliveryDate = '20201023'; 
        lItems.shippingNotes = 'Notes';
        lItems.COA = 'CHEMICAL RECEIVING'; 
        lItems.deliveryContact = '9898989898FirstNameLastName';
        lItems.shipToNumber = long.valueOf('12323');
        lineItems.add(lItems); 
        wsOrder.lineItems = lineItems;
        
        EC_OrderItemGroupServiceInput parentNode = new EC_OrderItemGroupServiceInput();
        parentNode.orderRequest = wsOrder;
        System.assertNotEquals(null, parentNode);
        
    }
}