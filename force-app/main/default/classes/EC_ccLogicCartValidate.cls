/* Class Name    : EC_ccLogicCartValidate
 * Description      :Class to extend the Cloudcraze Logic Class ccLogicCartValidate
 * Created By       :Viraj  
 * Created On       :2019-Jul-18

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Jul-18        BC-76559            Created the class   
 *
 */
global virtual with sharing class EC_ccLogicCartValidate extends ccrz.ccLogicCartValidate{
    
    /***************************************************************************************************************************************
  Method Name : process
  Description : process creates the Bill To and Ship To address for the cart and updates fields on CC Cart
  Return type : Returns Map<String,Object
 **************************************************************************************************************************************/
    global virtual override Map<String, Object> process(Map<String, Object> inputData) {
        
        Map<String, Object> retData = new Map<String, Object>();
		retData = super.process(inputData);
        EC_CartDetailController.updateCartShipToSoldTo();
        return retData;
    }
}