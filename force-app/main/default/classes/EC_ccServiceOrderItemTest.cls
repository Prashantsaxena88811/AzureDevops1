/* Class Name    : EC_ccServiceOrderItemTest 
 * Description      Test Class to cover EC_ccServiceOrderItem
 * Created By       :Bharath KN
 * Created On       :2020-APR-29
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Bharath KN            2020-APR-29              Created the class   
 *
 */
@isTest
public class EC_ccServiceOrderItemTest {
    /***************************************************************************************************************************************
  Method Name : test_getFieldsMap
  Description : Test method to cover getFieldsMap method
  Return type : void
 *************************************************************************************************************************************/
    
    static testMethod void test_getFieldsMap(){
                
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      
        system.runas(thisUser){
          
            Map<String,Object> inputData = new Map<String,Object>();
            
            EC_ccServiceOrderItem extend= new EC_ccServiceOrderItem();
            
            Map<String, Object> res=extend.getFieldsMap(inputData);
            
            System.assert(null != res);
            
        }        
    }

}