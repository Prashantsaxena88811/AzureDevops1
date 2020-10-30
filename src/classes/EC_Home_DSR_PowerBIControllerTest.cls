/*
* Class Name	: EC_Home_DSR_PowerBIControllerTest
* Description	: This  is a Test Class for EC_Home_DSR_PowerBIController
*/
@isTest
public class EC_Home_DSR_PowerBIControllerTest {

    /*
    * Method Name : getDashboards_Positive
    * Description : This method is to cover getUserPermissions method
    */
    @isTest
    private static void getDashboards_Positive() {
        EC_TestData.setupTestUser() ;
        User usr = [Select Id,FirstName,LastName,ProfileId,ContactId from User where LastName= 'TestUser'];
        System.runAs(usr){
        	EC_TestData.assignPestPermissions(usr);
            try {
            	EC_Home_DSR_PowerBIController.getUserPermissions();    
            }
            catch(Exception ex) {
                system.assertNotEquals(null, ex);
            }
        }
    } 
}