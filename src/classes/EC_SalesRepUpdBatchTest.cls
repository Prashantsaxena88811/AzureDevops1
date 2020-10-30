/* Class Name       :EC_SalesRepUpdBatchTest
* Description      :Test class for EC_SalesRepUpdBatch
* Created By       :Shivam Vats
* Created On       :08-23-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Shivam Vats        08-23-2019                                    Test class for EC_SalesRepUpdBatch
*
*/
@istest
public class EC_SalesRepUpdBatchTest {
  @istest
    public static void processSalesRep(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'Sales Rep'];
        User portalUser = new User(
        UserRoleId = portalRole.Id,
        ProfileId = profile1.Id,
        Username = System.now().millisecond() + 'usernameSales@test.com',
        Alias = 'batman',
        Email='bruce1113.wayne@wayneenterprises.com',
        EmailEncodingKey='UTF-8',
        Firstname='Bruce',
        Lastname='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago',
        User_Type__c = 'Internal',
        EC_CDM_User_Status__c= true);

        insert portalUser;

        system.runAs(portalUser){
         List<RecordType> lstRecordTypeSoldTO =  [SELECT id,DeveloperName from RecordType where Name = :Label.EC_Account_SoldTo];
            Account testSoldto = new Account();
            testSoldto.Name = 'TESTSOLD TO';
            testSoldto.EC_Account_Number__c = '150819471';
            testSoldto.RecordTypeId = lstRecordTypeSoldTO[0].Id;
            Insert testSoldto;

       Contact con = new Contact();
                    con.FirstName = 'Con' ;
                    con.LastName = 'LastName'+'221' ;
                    con.Email = 'abc@ccemail.com' ;
                    con.Phone ='123456'+'32';
                    con.EC_SalesRep_User__c = portalUser.Id;
                    con.AccountId= testSoldto.Id ;
        Insert con;
        }
       test.startTest();
        EC_SalesRepUpdBatch batchObj = new EC_SalesRepUpdBatch();
        Id batchId = Database.executeBatch(batchObj,10);
       test.stopTest();

     }


               }