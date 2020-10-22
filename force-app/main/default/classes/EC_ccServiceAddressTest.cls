/* Class Name    : EC_ccServiceAddressTest 
 * Description      Test Class to cover    EC_ccServiceAddress
 * Created By       :Priyanka Priya
 * Created On       :2019-Aug-5
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Priyanka Priya    2019-Aug-5             BC-75723        Created the class   
 *
 */
 @isTest
public class EC_ccServiceAddressTest {
     /***************************************************************************************************************************************
  Method Name : getServiceAddress
  Description : Test method to cover getFieldsMap method
  Return type : void
 *************************************************************************************************************************************/
     @isTest
    public static void getServiceAddress(){
    Map<String, Object>  inputdata= new Map<String, Object> ();
    EC_ccServiceAddress ecserviceaddress= new EC_ccServiceAddress();
    ecserviceaddress.getFieldsMap(inputdata);
    system.assertNotEquals(ecserviceaddress,null);
    }

}