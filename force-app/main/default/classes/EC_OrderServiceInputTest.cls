/********************************************************************************************************
* @Class Name    EC_OrderServiceInputTest
* @description   Test Class for EC_OrderServiceInput
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 

@isTest
public class EC_OrderServiceInputTest {
    
    static testMethod void test_serviceInput(){
        
        EC_OrderServiceInput.transportationDetail inputTransportDetail = new EC_OrderServiceInput.transportationDetail();
        inputTransportDetail.ShipComplete='testdata';
        inputTransportDetail.Mode='testdata';
        inputTransportDetail.Method='testdata';
        inputTransportDetail.Carrier='testdata';
        inputTransportDetail.Description='testdata';
        inputTransportDetail.CarrierSCAC='testdata';
        inputTransportDetail.RoutingSequenceCode='testdata';
        inputTransportDetail.CarrierProNumber='testdata';
        inputTransportDetail.CarrierMethodOfPayment='testdata';
        inputTransportDetail.EquipmentDescriptionCode='testdata';
        inputTransportDetail.EquipmentNumber='testdata';
        inputTransportDetail.SealNumber='testdata';
        inputTransportDetail.CarrierBuyerAccount='testdata';
        inputTransportDetail.CarierCODMethodOfPayment='testdata';
        inputTransportDetail.CarrierCODAmount='testdata';
        inputTransportDetail.StorageLocation='testdata';

        EC_OrderServiceInput.itemCodeType itemData = new EC_OrderServiceInput.itemCodeType();
        itemData.Code = 'testcode';
        itemData.type_x = 'testCode';
        
        EC_OrderServiceInput.keyValue keyData = new EC_OrderServiceInput.keyValue();
        keyData.Key = 'testKey';
        keyData.Value = 'testValue';
        
        EC_OrderServiceInput.addressType addressData = new EC_OrderServiceInput.addressType();
        addressData.AddressLine = new List<String>();
        addressData.City='testdata';
        addressData.State='testdata';
        addressData.Postalcode='testdata';
        addressData.Country='testdata';
        
        EC_OrderServiceInput.PurchaseOrder_element poElement = new EC_OrderServiceInput.PurchaseOrder_element();
        poElement.PONumber='testdata';
        poElement.OrderNumber='testdata';
        poElement.CustomerNumber='testdata';
        poElement.TradingPartnerID='testdata';
        poElement.StoreFront='testdata';
        poElement.PaymentMethod='testdata';
        poElement.PODate = System.today();
        poElement.RequestedDeliveryDate = System.today();
        poElement.CCDetails = new EC_OrderServiceInput.ccType();
        poElement.Party = new List<EC_OrderServiceInput.partyType>();
        poElement.TransportDetails = new EC_OrderServiceInput.transportationDetail();
        poElement.OrderComments = new List<EC_OrderServiceInput.noteType>();
        poElement.KeyValues = new List<EC_OrderServiceInput.keyValue>();
        poElement.Coupons = new List<EC_OrderServiceInput.couponType>();
        poElement.POLineItems = new List<EC_OrderServiceInput.lineItems>();
        
        EC_OrderServiceInput.partyType partyData = new EC_OrderServiceInput.partyType();
        EC_OrderServiceInput.lineItems lineData = new EC_OrderServiceInput.lineItems();
        EC_OrderServiceInput.noteType noteData = new EC_OrderServiceInput.noteType();
        EC_OrderServiceInput.couponType couponTypeData = new EC_OrderServiceInput.couponType();
        EC_OrderServiceInput.authorizationType authorizationTypeData = new EC_OrderServiceInput.authorizationType();
        EC_OrderServiceInput.partyId partyIdData = new EC_OrderServiceInput.partyId();
        EC_OrderServiceInput.handlingDetail handlingDetailData = new EC_OrderServiceInput.handlingDetail();
        EC_OrderServiceInput.contactMethod contactMethodData = new EC_OrderServiceInput.contactMethod();
        System.assertNotEquals(null, poElement);
    }

}