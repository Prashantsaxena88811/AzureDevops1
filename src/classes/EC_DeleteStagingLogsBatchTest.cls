/* Class Name      :EC_DeleteStagingLogsBatchTest
* Description      :TestClass for EC_DeleteStagingLogsBatch.
* Created By       :Mishika Mahajan
* Created On       :12-16-2019   
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          12-16-2019                                    TestClass for EC_DeleteStagingLogsBatch.
* 
*/


@isTest
public class EC_DeleteStagingLogsBatchTest{

 public static testmethod void testStagingLogBatch(){
 		
 
 		EC_StagingExceptionLog__c  stageLog = new  EC_StagingExceptionLog__c();
     	stageLog.EC_ClassName__c ='EC_DeleteStagingLogsBatchTest';
     	stageLog.EC_MethodName__c = 'testStagingLogBatch';
     	stageLog.EC_ExceptionMessage__c ='Null pointer exception';
     	insert  stageLog; 
        
        Test.startTest();
        EC_DeleteStagingLogsBatch deletebatch = new EC_DeleteStagingLogsBatch();
        List<EC_StagingExceptionLog__c> lstScope = [SELECT id from EC_StagingExceptionLog__c where id = :stageLog.id];
        Id BatchId =  DataBase.executeBatch(deletebatch, 10);
        deletebatch.execute(null, lstScope);        
        Test.stopTest();
      }
  }