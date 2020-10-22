/* Class Name    : EC_ccServiceOrderTest 
 * Description      Test Class to cover EC_ccServiceOrder
 * Created By       :Priyanka Priya
 * Created On       :2019-Jul-17
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Priyanka Priya    2019-Jul-17      BC-76559        Created the class   
 *
 */
@isTest
public class EC_ccServiceOrderTest {
    /***************************************************************************************************************************************
  Method Name : getServiceOrder
  Description : Test method to cover getFieldsMap method
  Return type : void
 *************************************************************************************************************************************/
    @isTest
    public static void getServiceOrder(){
    Map<String, Object>  inputdata= new Map<String, Object> ();
    EC_ccServiceOrder ecserviceorder= new EC_ccServiceOrder();
    ecserviceorder.getFieldsMap(inputdata);
    system.assertNotEquals(ecserviceorder,null);
    }
}