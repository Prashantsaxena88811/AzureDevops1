/* Class Name    : EC_ccServiceCartItem
 * Description      :Class to extend the Cloudcraze Logic Class ccServiceCartItem
 * Created By       :Viraj
 * Created On       :2019-Jul-19
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Jul-19           BC-76559        Created the class   
 *
 */
global with sharing class EC_ccServiceCartItem extends ccrz.ccServiceCartItem{
    /***************************************************************************************************************************************
  Method Name : getFieldsMap
  Description : used to include object fields in the model on front end
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData){
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',ccrz__Product__r.ccrz__LongDescRT__c,ccrz__Product__r.ccrz__LongDesc__c,ccrz__Product__r.ccrz__ShortDescRT__c,ccrz__Product__r.ccrz__ShortDesc__c,Tank_Number__c,Unloading_Point__c,Tank_Number__r.Tank_Number__c,Unloading_Point__r.ccrz__CompanyName__c,Custom_Factor__c,Custom_PricingUOM__c,Custom_UnitPrice__c' ;
        inputData.put(ccrz.ccService.OBJECTFIELDS, objectFields);
        return inputData;
    }
}