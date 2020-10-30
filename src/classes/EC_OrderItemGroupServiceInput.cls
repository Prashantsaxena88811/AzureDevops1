/* Class Name      : EC_OrderItemGroupServiceInput
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
public class EC_OrderItemGroupServiceInput {
    /** Added for test coverage */
    public EC_OrderItemGroupServiceInput(){}
    public orderRequestClass orderRequest;
    public class orderRequestClass {
        //Public String whoPlacedTheOrder;
        Public String orderNumberFromSource;
        Public String orderType;
        Public String contactEmail;
        Public String billingArrangementNumber; // Header level ???
        Public long soldToNumber;
        //Public String soldToName;
        Public long billToNumber;
        Public long shipToNumber;
        public String purchaseOrderNumber;
        public String freightForwarder;// Also in line level
        Public String relationshipWithEcolab;
        Public String orderChannel;
        public String shippingNotes;//Also in line level
        public String requestedDeliveryDate;//Also in line level
        //public String deliveryContact;//Also in line level
        public String deliveryContactPhoneNumber;
        public String deliveryContactLastName;
        public String deliveryContactFirstName;
        Public long payerNumber;
        Public Integer salesOrg;
        Public Integer distributionChannel;
        Public Integer division;        
        Public Integer employeeResponsibleID;
        Public String employeeResponsibleFirstName;
        Public String employeeResponsibleLastName;
        Public String creditcardToken;
        Public String creditcardName;
        Public String creditcardExpiry;
        Public String creditcardType;
        Public String callbackURL;        
        public EC_OrderItemGroupServiceInput.Products[] lineItems;
    }
    public class Products {
        public String billingArrangementLineNumber;
        public String productSku;
        public Integer quantity;
        public String UOM;
        public String tankNumber;
        public String unloadingPoint;
        public String freightForwarder; // Also in Header level
        public Boolean rushOrder;
        public String requestedDeliveryDate; //Also in header level
        public String shippingNotes; // Also in header level
        public String COA;
        public String deliveryContact; // Also in header level
        public long shipToNumber;
    }
}
