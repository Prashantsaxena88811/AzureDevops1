/* Class Name    : EC_ccServiceCartTest 
 * Description      Test Class to cover EC_ccServiceCart
 * Created By       :Ravindra Singh
 * Created On       :2019-Aug-08
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ravindra Singh    2019-Aug-08      BC-76559        Created the class   
 *
 */
@isTest
public class EC_ccServiceCartTest {
     /***************************************************************************************************************************************
  Method Name : test_getFieldsMap
  Description : Test method to cover getFieldsMap method
  Return type : void
 *************************************************************************************************************************************/
    static testMethod void test_getFieldsMap(){
                
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      
        system.runas(thisUser){
          
            Map<String,Object> inputData = new Map<String,Object>();
            
            EC_ccServiceCart extend= new EC_ccServiceCart();
            
            Map<String, Object> res=extend.getFieldsMap(inputData);
            
            System.assert(null != res);
            
        }        
    }

}