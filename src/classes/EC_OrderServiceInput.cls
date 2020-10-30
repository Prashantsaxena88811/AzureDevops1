/********************************************************************************************************
* @Class Name    EC_OrderServiceInput
* @description   Input class for Tibco Api, Generated using WSDL
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 

public class EC_OrderServiceInput {
    public class transportationDetail {
        public String ShipComplete;
        public String Mode;
        public String Method;
        public String Carrier;
        public String Description;
        public String CarrierSCAC;
        public String RoutingSequenceCode;
        public String CarrierProNumber;
        public String CarrierMethodOfPayment;
        public String EquipmentDescriptionCode;
        public String EquipmentNumber;
        public String SealNumber;
        public String CarrierBuyerAccount;
        public String CarierCODMethodOfPayment;
        public String CarrierCODAmount;
        public String StorageLocation;
        public EC_OrderServiceInput.handlingDetail HandlingRequirements;
        private String[] ShipComplete_type_info = new String[]{'ShipComplete','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Mode_type_info = new String[]{'Mode','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Method_type_info = new String[]{'Method','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Carrier_type_info = new String[]{'Carrier','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Description_type_info = new String[]{'Description','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CarrierSCAC_type_info = new String[]{'CarrierSCAC','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] RoutingSequenceCode_type_info = new String[]{'RoutingSequenceCode','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CarrierProNumber_type_info = new String[]{'CarrierProNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CarrierMethodOfPayment_type_info = new String[]{'CarrierMethodOfPayment','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] EquipmentDescriptionCode_type_info = new String[]{'EquipmentDescriptionCode','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] EquipmentNumber_type_info = new String[]{'EquipmentNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] SealNumber_type_info = new String[]{'SealNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CarrierBuyerAccount_type_info = new String[]{'CarrierBuyerAccount','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CarierCODMethodOfPayment_type_info = new String[]{'CarierCODMethodOfPayment','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CarrierCODAmount_type_info = new String[]{'CarrierCODAmount','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] StorageLocation_type_info = new String[]{'StorageLocation','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] HandlingRequirements_type_info = new String[]{'HandlingRequirements','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'ShipComplete','Mode','Method','Carrier','Description','CarrierSCAC','RoutingSequenceCode','CarrierProNumber','CarrierMethodOfPayment','EquipmentDescriptionCode','EquipmentNumber','SealNumber','CarrierBuyerAccount','CarierCODMethodOfPayment','CarrierCODAmount','StorageLocation','HandlingRequirements'};
    }
    public class itemCodeType {
        public String Code;
        public String type_x;
        private String[] Code_type_info = new String[]{'Code','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] type_x_att_info = new String[]{'type'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'Code'};
    }
    public class keyValue {
        public String Key;
        public String Value;
        private String[] Key_type_info = new String[]{'Key','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Value_type_info = new String[]{'Value','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'Key','Value'};
    }
    public class addressType {
        public String[] AddressLine;
        public String City;
        public String State;
        public String Postalcode;
        public String Country;
        public EC_OrderServiceInput.contactMethod[] Contact;
        private String[] AddressLine_type_info = new String[]{'AddressLine','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] City_type_info = new String[]{'City','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] State_type_info = new String[]{'State','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Postalcode_type_info = new String[]{'Postalcode','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Contact_type_info = new String[]{'Contact','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'AddressLine','City','State','Postalcode','Country','Contact'};
    }
    public class PurchaseOrder_element {
        public String PONumber;
        public String OrderNumber;
        public String CustomerNumber;
        public Date PODate;
        public Date RequestedDeliveryDate;
        public String TradingPartnerID;
        public String StoreFront;
        public String PaymentMethod;
        public EC_OrderServiceInput.partyType[] Party;
        public EC_OrderServiceInput.ccType CCDetails;
        public EC_OrderServiceInput.transportationDetail TransportDetails;
        public EC_OrderServiceInput.noteType[] OrderComments;
        public EC_OrderServiceInput.keyValue[] KeyValues;
        public EC_OrderServiceInput.couponType[] Coupons;
        public EC_OrderServiceInput.lineItems[] POLineItems;
        private String[] PONumber_type_info = new String[]{'PONumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] OrderNumber_type_info = new String[]{'OrderNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CustomerNumber_type_info = new String[]{'CustomerNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] PODate_type_info = new String[]{'PODate','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] RequestedDeliveryDate_type_info = new String[]{'RequestedDeliveryDate','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] TradingPartnerID_type_info = new String[]{'TradingPartnerID','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] StoreFront_type_info = new String[]{'StoreFront','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] PaymentMethod_type_info = new String[]{'PaymentMethod','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Party_type_info = new String[]{'Party','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] CCDetails_type_info = new String[]{'CCDetails','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] TransportDetails_type_info = new String[]{'TransportDetails','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] OrderComments_type_info = new String[]{'OrderComments','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] KeyValues_type_info = new String[]{'KeyValues','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] Coupons_type_info = new String[]{'Coupons','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] POLineItems_type_info = new String[]{'POLineItems','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'PONumber','OrderNumber','CustomerNumber','PODate','RequestedDeliveryDate','TradingPartnerID','StoreFront','PaymentMethod','Party','CCDetails','TransportDetails','OrderComments','KeyValues','Coupons','POLineItems'};
    }
    public class partyType {
        public String Id;
        public String Name;
        public EC_OrderServiceInput.addressType Address;
        public String type_x;
        private String[] Id_type_info = new String[]{'Id','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Name_type_info = new String[]{'Name','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Address_type_info = new String[]{'Address','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] type_x_att_info = new String[]{'type'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'Id','Name','Address'};
    }
    public class ccType {
        public String CreditCardType;
        public String CreditCardNumber;
        public String TokenNumber;
        public String CreditCardExpirationDate;
        public String CreditCardHolderName;
        public String CreditCardCVV;
        public String Currency_x;
        public EC_OrderServiceInput.authorizationType Authorization;
        private String[] CreditCardType_type_info = new String[]{'CreditCardType','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CreditCardNumber_type_info = new String[]{'CreditCardNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] TokenNumber_type_info = new String[]{'TokenNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] CreditCardExpirationDate_type_info = new String[]{'CreditCardExpirationDate','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CreditCardHolderName_type_info = new String[]{'CreditCardHolderName','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] CreditCardCVV_type_info = new String[]{'CreditCardCVV','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Currency_x_type_info = new String[]{'Currency','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Authorization_type_info = new String[]{'Authorization','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'CreditCardType','CreditCardNumber','TokenNumber','CreditCardExpirationDate','CreditCardHolderName','CreditCardCVV','Currency_x','Authorization'};
    }
    public class lineItems {
        public String LineNumber;
        public EC_OrderServiceInput.itemCodeType[] ItemCode;
        public Decimal OrderedQuantity;
        public Decimal UnitPrice;
        public String ProductDescription;
        public EC_OrderServiceInput.noteType[] LineComments;
        public EC_OrderServiceInput.keyValue[] KeyValues;
        private String[] LineNumber_type_info = new String[]{'LineNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] ItemCode_type_info = new String[]{'ItemCode','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','-1','false'};
        private String[] OrderedQuantity_type_info = new String[]{'OrderedQuantity','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] UnitPrice_type_info = new String[]{'UnitPrice','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] ProductDescription_type_info = new String[]{'ProductDescription','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] LineComments_type_info = new String[]{'LineComments','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] KeyValues_type_info = new String[]{'KeyValues','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'LineNumber','ItemCode','OrderedQuantity','UnitPrice','ProductDescription','LineComments','KeyValues'};
    }
    public class noteType {
        public String NoteType;
        public String NoteText;
        private String[] NoteType_type_info = new String[]{'NoteType','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] NoteText_type_info = new String[]{'NoteText','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'NoteType','NoteText'};
    }
    public class couponType {
        public String Name;
        public String Code;
        public Decimal Quantity;
        public Decimal Value;
        private String[] Name_type_info = new String[]{'Name','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Code_type_info = new String[]{'Code','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Quantity_type_info = new String[]{'Quantity','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Value_type_info = new String[]{'Value','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'Name','Code','Quantity','Value'};
    }
    public class authorizationType {
        public String AuthAmount;
        public String AuthNumber;
        public String AuthRef;
        public String PreAuth;
        public String AuthTimestamp;
        public String AuthCallStatus;
        public String AuthResponse;
        public String AuthRespCode;
        private String[] AuthAmount_type_info = new String[]{'AuthAmount','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] AuthNumber_type_info = new String[]{'AuthNumber','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] AuthRef_type_info = new String[]{'AuthRef','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] PreAuth_type_info = new String[]{'PreAuth','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] AuthTimestamp_type_info = new String[]{'AuthTimestamp','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] AuthCallStatus_type_info = new String[]{'AuthCallStatus','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] AuthResponse_type_info = new String[]{'AuthResponse','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] AuthRespCode_type_info = new String[]{'AuthRespCode','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'AuthAmount','AuthNumber','AuthRef','PreAuth','AuthTimestamp','AuthCallStatus','AuthResponse','AuthRespCode'};
    }
    public class partyId {
        public String type_x;
        private String[] type_x_att_info = new String[]{'type'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class contactMethod {
        public String Phone;
        public String Email;
        public String type_x;
        private String[] Phone_type_info = new String[]{'Phone','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Email_type_info = new String[]{'Email','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] type_x_att_info = new String[]{'type'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'Phone','Email'};
    }
    public class handlingDetail {
        public String MultipleShipmentFlag;
        public String DaysClosed;
        public String LiftGate;
        public String PackSlip;
        public String PalletExcIndicator;
        public String AppointmentRequired;
        public String DriverResponsible;
        public String ReceivingHours;
        public String BackOrderIndicator;
        public String FormIndicator;
        public EC_OrderServiceInput.noteType[] Instructions;
        public String DeliveryLocation;
        public String ShipToRepresentative;
        private String[] MultipleShipmentFlag_type_info = new String[]{'MultipleShipmentFlag','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] DaysClosed_type_info = new String[]{'DaysClosed','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] LiftGate_type_info = new String[]{'LiftGate','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] PackSlip_type_info = new String[]{'PackSlip','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] PalletExcIndicator_type_info = new String[]{'PalletExcIndicator','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] AppointmentRequired_type_info = new String[]{'AppointmentRequired','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] DriverResponsible_type_info = new String[]{'DriverResponsible','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] ReceivingHours_type_info = new String[]{'ReceivingHours','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] BackOrderIndicator_type_info = new String[]{'BackOrderIndicator','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] FormIndicator_type_info = new String[]{'FormIndicator','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] Instructions_type_info = new String[]{'Instructions','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','-1','false'};
        private String[] DeliveryLocation_type_info = new String[]{'DeliveryLocation','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] ShipToRepresentative_type_info = new String[]{'ShipToRepresentative','http://www.ecolab.com/services/schemas/PurchaseOrderInput',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/PurchaseOrderInput','false','false'};
        private String[] field_order_type_info = new String[]{'MultipleShipmentFlag','DaysClosed','LiftGate','PackSlip','PalletExcIndicator','AppointmentRequired','DriverResponsible','ReceivingHours','BackOrderIndicator','FormIndicator','Instructions','DeliveryLocation','ShipToRepresentative'};
    }
}