/* Class Name    : EC_ccServiceAddress 
 * Description      :Class to extend the Cloudcraze Logic Class ccServiceAddress
 * Created By       :Ashish
 * Created On       :2019-Jul-19
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ashish                2019-Jul-19           BC-75723        Created the class   
 *
 */
 global with sharing class EC_ccServiceAddress extends ccrz.ccServiceAddress{
   /***************************************************************************************************************************************
  Method Name : getFieldsMap
  Description : used to include object fields in the model on front end
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData){
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',EC_Account_Number__c,ShipTo_Name__c' ;
        inputData.put(ccrz.ccService.OBJECTFIELDS, objectFields);
        return inputData;
    }
}