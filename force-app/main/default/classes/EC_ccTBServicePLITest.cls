/* Class Name    : EC_ccTBServicePLITest
 * Description      :Storing/Creating the cache tree of all categories
 * Created By       :Ravindra Singh  
 * Created On       :2019-11-22

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ravindra Singh              2019-11-22        Indexing    Created the class   
 *
 */
@isTest
public class EC_ccTBServicePLITest {
    /***************************************************************************************************************************************
    Method Name : getServiceAddress
    description : Test method to cover fetch
    Return type : void
    *************************************************************************************************************************************/
     @isTest
    public static void getServiceAddress(){
       Map<String, Object>  inputdata= new Map<String, Object> ();
       inputdata.put('ignoreStorefront','TRUE');
       EC_ccTBServicePLI ecServicePLI= new EC_ccTBServicePLI();
       ecServicePLI.fetch(inputdata);
        system.assertNotEquals(ecServicePLI,null);
    }

}