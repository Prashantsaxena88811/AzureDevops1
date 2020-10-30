/* Class Name      :EC_DeletePunchOutInfoLogsBatchTest
* Description      :TestClass for EC_DeletePunchOutInfoLogsBatch.
* Created By       :Raghav Sharma
* Created On       :01/08/2020   
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Raghav Sharma         01/08/2020                                    TestClass for EC_DeletePunchOutInfoLogsBatch.
* 
*/


@isTest
public class EC_DeletePunchOutInfoLogsBatchTest{
    
    public static testmethod void testPunchOutLogBatch(){
        
        
        EC_PunchOutInfo__c  punch = new  EC_PunchOutInfo__c();
        punch.EC_BuyerCookie__c = 'test123';
        punch.Name = 'Test';
        insert  punch; 
        
        Test.startTest();
        EC_DeletePunchOutInfoLogsBatch deletebatch = new EC_DeletePunchOutInfoLogsBatch();
        List<EC_PunchOutInfo__c> lstScope = [SELECT id from EC_PunchOutInfo__c where id = :punch.id];
        Id BatchId =  DataBase.executeBatch(deletebatch, 10);
        deletebatch.execute(null, lstScope);        
        Test.stopTest();
    }
}