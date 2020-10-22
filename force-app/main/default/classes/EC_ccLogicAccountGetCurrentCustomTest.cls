/* Class Name    : EC_ccLogicAccountGetCurrentCustomTest
 * Description      Test Class to cover EC_ccLogicAccountGetCurrentCustom
 * Created By       :Viraj  
 * Created On       :2019-Oct-15
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Oct-15        BC-75723          Created the class   
 *
 */
@isTest
public class EC_ccLogicAccountGetCurrentCustomTest{
     /***************************************************************************************************************************************
  Method Name : test1
  Description : Test method to cover getContactData and getAccountData method
  Return type : void
 *************************************************************************************************************************************/
    @isTest 
    static void test1(){
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        thisUser.User_Type__c = 'internal';
        update thisUser;
        EC_TestData.setupCatalog();
        Account acc1 = EC_TestData.testAccount;
        Contact contactCC = new Contact(
                FirstName = 'CloudCraze',
                LastName  = 'TestUser2',
                Email = 'abc@xyz.com',
                AccountId = acc1.Id,
                MailingStreet = 'abc',
                EC_SalesRep_User__c = thisUser.id
        );
        insert contactCC;
        system.runas(thisUser){
            
            Test.startTest();
            EC_ccLogicAccountGetCurrentCustom classOb = new EC_ccLogicAccountGetCurrentCustom();
			EC_ccLogicUserGetProfileDataCustom classObProfile = new EC_ccLogicUserGetProfileDataCustom();
            Map<String,Object> inpData = new Map<String,Object>();
            inpData.put(ccrz.ccApi.API_VERSION,4);
            ccrz.cc_CallContext.effAccountId = acc1.id;
            System.assertNotEquals(classOb.process(inpData) ,null);
            classObProfile.getContactData(inpData);
            classObProfile.getAccountData(inpData);
            ccrz.cc_CallContext.effAccountId = '';
            System.assertNotEquals(classOb.process(inpData) ,null);
            classObProfile.getContactData(inpData);
            classObProfile.getAccountData(inpData);						   
            Test.stopTest();
            
        }
    }
    /***************************************************************************************************************************************
  Method Name : test2
  Description : Test method to cover getContactData and getAccountData method
  Return type : void
 *************************************************************************************************************************************/
    @isTest 
    static void test2(){
        User thisUser = [SELECT Id,User_Type__c FROM User WHERE Id = :UserInfo.getUserId()];
        thisUser.User_Type__c = 'external';
        update thisUser;
        EC_TestData.setupCatalog();
        Account acc1 = EC_TestData.testAccount;
        Contact contactCC = new Contact(
                FirstName = 'CloudCraze',
                LastName  = 'TestUser2',
                Email = 'abc@xyz.com',
                AccountId = acc1.Id,
                MailingStreet = 'abc',
                EC_SalesRep_User__c = thisUser.id
        );
        insert contactCC;
        system.runas(thisUser){            
            Test.startTest();
            EC_ccLogicAccountGetCurrentCustom classOb = new EC_ccLogicAccountGetCurrentCustom();
			EC_ccLogicUserGetProfileDataCustom classObProfile = new EC_ccLogicUserGetProfileDataCustom();
            Map<String,Object> inpData = new Map<String,Object>();
            inpData.put(ccrz.ccApi.API_VERSION,4);
            ccrz.cc_CallContext.effAccountId = acc1.id;
            classObProfile.getContactData(inpData);
            classObProfile.getAccountData(inpData);
            System.assertNotEquals(classOb.process(inpData) ,null);
			
            Test.stopTest();
        }
    }
    /*@isTest 
    static void test2(){
        User thisUser = [SELECT Id,AccountId  FROM User WHERE Id = :UserInfo.getUserId()];
        EC_TestData.setupCatalog();
        Account acc1 = EC_TestData.testAccount;
        Contact contactCC = new Contact(
                FirstName = 'CloudCraze',
                LastName  = 'TestUser2',
                Email = 'abc@xyz.com',
                AccountId = acc1.Id,
                MailingStreet = 'abc',
                EC_SalesRep_User__c = thisUser.id
        );
        insert contactCC;
        system.runas(thisUser){
            
            Test.startTest();
            EC_ccLogicAccountGetCurrentCustom classOb = new EC_ccLogicAccountGetCurrentCustom();
            Map<String,Object> inpData = new Map<String,Object>();
            inpData.put(ccrz.ccApi.API_VERSION,4);
            ccrz.cc_CallContext.effAccountId = acc1.id;
            System.assertNotEquals(classOb.process(inpData) ,null);
            ccrz.cc_CallContext.effAccountId = null;
            System.assertNotEquals(classOb.process(inpData) ,null);
            Test.stopTest();
            
        }
    }*/
}