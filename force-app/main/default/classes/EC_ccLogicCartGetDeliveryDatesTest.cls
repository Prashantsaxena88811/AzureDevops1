/* Class Name    : EC_ccLogicCartGetDeliveryDatesTest
 * Description      Test Class to cover EC_ccLogicCartGetDeliveryDates
 * Created By       :Viraj  
 * Created On       :2019-Aug-03
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Aug-03       BC-76559         Created the class   
 *
 */
@isTest
public class EC_ccLogicCartGetDeliveryDatesTest{

    /***************************************************************************************************************************************
  Method Name : test1
  Description : Test method to cover getDeliveryDates method
  Return type : void
 *************************************************************************************************************************************/
    @isTest 
    static void test1(){
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        EC_TestData.setupCatalog();
        Account ship1 = EC_TestData.testAccountShipTo;
        ship1.EC_Division__c = 'Institutional';
        update ship1;
        Account sold1 = EC_TestData.testAccountSoldTo;
		sold1.EC_Division__c = 'WATER';
        update sold1;
        system.runas(thisUser){
            
            Test.startTest();
            EC_ccLogicCartGetDeliveryDates classOb = new EC_ccLogicCartGetDeliveryDates();
			EC_ccLogicCartGetDeliveryDates.today = date.today().toStartOfMonth().toStartOfWeek().addDays(5);
            Map<String,Object> inpData = new Map<String,Object>();
            inpData.put(ccrz.ccApi.API_VERSION,4);
			
            ccrz.cc_CallContext.effAccountId = ship1.id;
            System.assertNotEquals(classOb.getDeliveryDates(inpData) ,null);
			
			ccrz.cc_CallContext.effAccountId = sold1.id;
            System.assertNotEquals(classOb.getDeliveryDates(inpData) ,null);
            
            Test.stopTest();
            
        }
    }
    
    }