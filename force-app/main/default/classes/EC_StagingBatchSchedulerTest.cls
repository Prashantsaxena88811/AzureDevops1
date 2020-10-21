/* Class Name       :EC_StagingBatchSchedulerTest
* Description      :TestClass for EC_StagingBatchScheduler.
* Created By       :Shruti Sinha
* Created On       :09-07-2019   
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Shruti Sinha          08-23-2019                                   TestClass for EC_StagingBatchScheduler.
* 
*/


@isTest
public class EC_StagingBatchSchedulerTest{

 public static testmethod void method1(){
 Test.startTest();
 
 EC_TestData.setupTestUser();
 EC_TestData.setupCatalog();
 EC_Mulesoft_CDM_Staging__c  updAcc = new  EC_Mulesoft_CDM_Staging__c();
 updAcc.EC_Parent_Account_Number__c = '15081950';
 updAcc.EC_Account_Key__c = '2234412';
 updAcc.EC_Account_Name_English__c = 'Updated Account here';
 updAcc.EC_Account_Number__c = '2234412';
 updAcc.EC_Partner_Function__c = 'SHIPTO';
 updAcc.EC_Account_Global_Business_Unit_Name__c = 'WATER';
 updAcc.EC_Source_Table__c = 'Account';
 updAcc.EC_Action__c = 'InsertAction';
 insert  updAcc; 
 
 String CRON_EXP = '0 0 0 3 9 ? 2022';
 EC_StagingBatchScheduler sch = new EC_StagingBatchScheduler();
 String jobId = system.schedule('schedule job Test', CRON_EXP, sch);
  Test.stopTest();
 
 
 }
 }