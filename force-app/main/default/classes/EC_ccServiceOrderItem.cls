global with sharing class EC_ccServiceOrderItem extends ccrz.ccServiceOrderItem {
 /***************************************************************************************************************************************
  Method Name : getFieldsMap
  Description : used to include object fields in the model on front end
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
  
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData){
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',ccrz__Product__r.EC_Product_Media_Url__r.ccrz__URI__c,Unloading_Point__c,Tank_Number__c,Unloading_Point__r.ccrz__CompanyName__c,Tank_Number__r.Tank_Number__c,Custom_UnitPrice__c,Custom_PricingUOM__c,Custom_Factor__c' ;
        inputData.put(ccrz.ccService.OBJECTFIELDS, objectFields);
        return inputData;
    }
}