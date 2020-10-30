/* Class Name    : EC_ccServiceCart
 * Description      :Class to extend the Cloudcraze Logic Class ccServiceCart
 * Created By       :Viraj
 * Created On       :2019-Jul-18
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Jul-18           BC-76559        Created the class   
 *
 */
global with sharing class EC_ccServiceCart extends ccrz.ccServiceCart{
    /***************************************************************************************************************************************
  Method Name : getFieldsMap
  Description : used to include object fields in the model on front end
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData){
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',EC_Is_Requested_Date_Valid__c,EC_Ship_To_Account__r.EC_Division__c,EC_AttentionTo__c,EC_Ship_To_Account__c,EC_Ship_To_Account__r.Name,EC_Ship_To_Account__r.EC_PaymentMode__c,'
            +'EC_Ship_To_Account__r.EC_Account_Number__c,EC_Sold_To_Account__c,EC_Sold_To_Account__r.Name,EC_Sold_To_Account__r.EC_Account_Number__c,EC_Delivery_Lead_Time__c,EC_Sold_To_Account__r.EC_PaymentMode__c,EC_Attention_To_Number__c,Default_Unloading_Point__c' ;
        inputData.put(ccrz.ccService.OBJECTFIELDS, objectFields);
        return inputData;
    }
}