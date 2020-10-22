/* Class Name      :EC_ccServiceProductIndex
* Description      :ServiceProductIndex Related inherited cloud craze interface
* Created By       :Rajeshwar Bachu. 
* Created On       :25-05-2020

* Modification Log:
* ------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------------------------------------------
* Rajeshwar bachu         25-05-2020                             Initial version (log modification)
*
*
*/


global without sharing class EC_ccServiceProductIndex extends ccrz.ccServiceProductIndex {
  /***************************************************************************************************************************************
  Method Name : getFieldsMap
  Description : used to include object fields in the model on front end
  Return type : Returns Map<String,Object>
**************************************************************************************************************************************/
	global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData)
    {
        Map<String, Object> ccInputData = super.getFieldsMap(inputData);
        String objectFields = (String)ccInputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',ERP_Product_Description__c' ;
        ccInputData.put(ccrz.ccService.OBJECTFIELDS,objectFields);
        return ccInputData;
    }
    
}