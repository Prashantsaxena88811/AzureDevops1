/* Class Name    : EC_ccServiceOrder
 * Description      :Class to extend the Cloudcraze Logic Class ccServiceOrder
 * Created By       :Priyanka Priya
 * Created On       :2019-Jul-17
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Jul-17           BC-79847        Created the class   
 *
 */
global with sharing class EC_ccServiceOrder extends ccrz.ccServiceOrder{

    /***************************************************************************************************************************************
  Method Name : getFieldsMap
  Description : used to include object fields in the model on front end
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData){
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',ccrz__OriginatedCart__r.EC_AttentionTo__c,ccrz__OriginatedCart__r.EC_Attention_To_Number__c,ccrz__OriginatedCart__r.EC_Is_Requested_Date_Valid__c,EC_Division__c' ;
        inputData.put(ccrz.ccService.OBJECTFIELDS, objectFields);
        return inputData;
    }
}