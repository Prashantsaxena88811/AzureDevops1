/* Class Name    	: EC_ccServicePLITest 
* Description      	: Test Class to cover EC_ccServicePLI
* Created By       	: Bharath KN
* Created On       	: 2020-May-27
* Modification Log:
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bharath KN   		 2020-May-27      			01			   Created the class   
*
*/
@isTest
public class EC_ccServicePLITest {
/***************************************************************************************************************************************
Method Name : test_getFieldsMap
Description : Test method to cover getFieldsMap method
Return type : void
*************************************************************************************************************************************/
    static testMethod void test_getFieldsMap(){                
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];      
        system.runas(thisUser){          
            Map<String,Object> inputData = new Map<String,Object>();            
            EC_ccServicePLI extend= new EC_ccServicePLI();            
            Map<String, Object> res=extend.getFieldsMap(inputData);            
            System.assert(null != res);
            
        }        
    }
}