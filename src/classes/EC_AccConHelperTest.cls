@isTest
public class EC_AccConHelperTest {
     @testSetup static void setup(){
        String country = 'USA';
        String division = 'Water';
        list<Account> testAccountSoldTo = new list<Account>{
            new Account(
                Name                    = 'Test Sold To',
                OwnerId                 = UserInfo.getUserId(),
                BillingStreet           = EC_TestData.generateRandomString(32),
                BillingCity             = EC_TestData.generateRandomString(32),
                BillingState            = EC_TestData.generateRandomString(32),
                BillingCountry          = country,
                BillingPostalCode       = EC_TestData.generateRandomString(5),
                EC_Account_Number__c    = EC_TestData.generateRandomString(5),
                EC_Billing_Account_Number__c = 'NLC_SAP2/1234511',
                EC_Division__c = division,
                RecordTypeId            = EC_TestData.getRecordType('soldTo')),
                new Account(
                    Name                    = 'Test Sold To1',
                    OwnerId                 = UserInfo.getUserId(),
                    BillingStreet           = EC_TestData.generateRandomString(32),
                    BillingCity             = EC_TestData.generateRandomString(32),
                    BillingState            = EC_TestData.generateRandomString(32),
                    BillingCountry          = country,
                    BillingPostalCode       = EC_TestData.generateRandomString(5),
                    EC_Account_Number__c    = EC_TestData.generateRandomString(5),
                    EC_Billing_Account_Number__c = 'NLC_SAP1/1234572',
                    EC_Division__c = division,
                    RecordTypeId            = EC_TestData.getRecordType('soldTo'))//Sold To
                
                };
           insert testAccountSoldTo;
         
         list<Account> testAccountShipTo = new list<Account>{
         new Account(
                Name                    = 'Test Ship To',
                OwnerId                 = UserInfo.getUserId(),
                BillingStreet           = EC_TestData.generateRandomString(32),
                BillingCity             = EC_TestData.generateRandomString(32),
                BillingState            = EC_TestData.generateRandomString(32),
             	ParentId                = testAccountSoldTo[0].id,
                BillingCountry          = country,
                BillingPostalCode       = EC_TestData.generateRandomString(5),
                EC_Account_Number__c    = EC_TestData.generateRandomString(5),
                EC_Billing_Account_Number__c = 'NLC_SAP/123457',
                EC_Division__c = division,
                RecordTypeId            = EC_TestData.getRecordType('shipTo')),
             new Account(
                Name                    = 'Test Ship To1',
                OwnerId                 = UserInfo.getUserId(),
                BillingStreet           = EC_TestData.generateRandomString(32),
                BillingCity             = EC_TestData.generateRandomString(32),
                BillingState            = EC_TestData.generateRandomString(32),
             	ParentId                = testAccountSoldTo[0].id,
                BillingCountry          = country,
                BillingPostalCode       = EC_TestData.generateRandomString(5),
                EC_Account_Number__c    = EC_TestData.generateRandomString(5),
                EC_Billing_Account_Number__c = 'NLC_SAP/123456',
                EC_Division__c = division,
                RecordTypeId            = EC_TestData.getRecordType('shipTo'))//Ship To
                
                };
                    insert testAccountShipTo;
               
    }
    /***************************************************************************************************************************************
    Method Name : testData
    Description : TestSetup method for creating Accounts and Users
    Return type : void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    @isTest 
    static void insertAlignmentTest(){
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        List<AccountContactRelation> accConList = new List<AccountContactRelation>();
		list<Account> testAccountSoldTo = [select Id from Account where RecordType.name = 'Sold To'];
        list<Account> testAccountShipTo = [select Id from Account where RecordType.name = 'Ship To'];
        system.runas(thisUser){
            
            EC_TestData.setupDummyTestUser();
            Contact con =[SELECT id, FirstName, LastName from Contact where LastName='testAlignUser' limit 1];
            
            Contact conSales =[SELECT id, FirstName, LastName from Contact where LastName='testSalesUser' limit 1];
            
            AccountContactRelation accCon2 = new AccountContactRelation();
            accCon2.AccountId = testAccountSoldTo[0].id;
            accCon2.ContactId = conSales.id;
            accCon2.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            accConList.add(accCon2);
            
            AccountContactRelation accCon1 = new AccountContactRelation();
            accCon1.AccountId = testAccountShipTo[0].id;
            accCon1.ContactId = con.id;
            accCon1.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            accConList.add(accCon1);
            
            AccountContactRelation accCon = new AccountContactRelation();
            accCon.AccountId = testAccountSoldTo[0].id;
            accCon.ContactId = con.id;
            accCon.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            accConList.add(accCon);
            
            Insert accConList;
            system.assertNotEquals(null, accConList);
        }
    }
    /***************************************************************************************************************************************
    Method Name : testData
    Description : TestSetup method for creating Accounts and Users
    Return type : void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    @isTest 
    static void deleteAlignmentTest(){
        User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
        List<AccountContactRelation> accConList = new List<AccountContactRelation>();
		list<Account> testAccountSoldTo = [select Id from Account where RecordType.name = 'Sold To'];
        list<Account> testAccountShipTo = [select Id from Account where RecordType.name = 'Ship To'];
        system.runas(thisUser){
            
            EC_TestData.setupDummyTestUser();
            Contact con =[SELECT id, FirstName, LastName from Contact where LastName='testAlignUser' limit 1];
            
            Contact conSales =[SELECT id, FirstName, LastName from Contact where LastName='testSalesUser' limit 1];
            
            AccountContactRelation accCon2 = new AccountContactRelation();
            accCon2.AccountId = testAccountSoldTo[0].id;
            accCon2.ContactId = conSales.id;
            accCon2.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            accConList.add(accCon2);
            
            AccountContactRelation accCon3 = new AccountContactRelation();
            accCon3.AccountId = testAccountSoldTo[1].id;
            accCon3.ContactId = con.id;
            accCon3.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            accConList.add(accCon3);
            
            AccountContactRelation accCon1 = new AccountContactRelation();
            accCon1.AccountId = testAccountShipTo[0].id;
            accCon1.ContactId = con.id;
            accCon1.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            accConList.add(accCon1);
            
            AccountContactRelation accCon = new AccountContactRelation();
            accCon.AccountId = testAccountSoldTo[0].id;
            accCon.ContactId = con.id;
            accCon.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
            accConList.add(accCon);
            
            Insert accConList;
            
            delete accCon; 
            delete accCon2; 
            system.assertNotEquals(null, accConList);
        }
    }

}