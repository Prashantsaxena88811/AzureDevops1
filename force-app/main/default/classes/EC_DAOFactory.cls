/********************************************************************************************************
* @Class Name    EC_DAOFactory
* @description   EC_DAOFactory is used to create mock DAO and actual DAO for Tibco service
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 

public with sharing class EC_DAOFactory {
    private static final Boolean TEST_OVERRIDE = false;
    public Boolean IsRunningAsTest {
        get {
            if (IsRunningAsTest == null) {
                IsRunningAsTest = TEST_OVERRIDE || Test.isRunningTest();
            }
            return IsRunningAsTest;
        }
        set;
    }

    /***************************************************************************************************************************************
      Method Name : getEcolabTIBCODao
      Description : This method is used to return DAO for order submit api.
      Return type : EC_OrderDAO
     **************************************************************************************************************************************/
     

    public EC_OrderDAO getEcolabTIBCODao(){
        EC_OrderDAO result = null;
        system.debug('test ' + IsRunningAsTest );
        result = new EC_OrderDAO();
        if( IsRunningAsTest ){
            result = new EC_OrderMockDAO();
        }
        return result;
    }
}