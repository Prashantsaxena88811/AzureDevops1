/********************************************************************************************************
* @Class Name    EC_OrderServiceOutputTest
* @description   Test Class for EC_OrderServiceOutput
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 

@isTest
public class EC_OrderServiceOutputTest {
    
    public static testmethod void serviceOutputResponse(){
        
        EC_OrderServiceOutput.OrderOutput_element element = new EC_OrderServiceOutput.OrderOutput_element();
        element.Message = 'message';
        element.status = true;
        System.assertNotEquals(null, element);
    }

}