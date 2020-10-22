/*********************************************************************************
Class Name      : EC_ServiceRequestHandler
Description     : This class is used as the handler for Service Request lightning component
Created By      : Deloitte
Created Date    : 21-July-19
Modification Log:
---------------------------------------------------------------------------------- 
Developer                 Date                   Description
----------------------------------------------------------------------------------            
Deloitte                  02-July-19             Initial Version 
*********************************************************************************/ 

@isTest
public class EC_ServiceRequestHandlerTest{
    @testSetup
    static void getTestData(){  
        List<User> lstTestUsers = new List<User>();  
        List<Account> lstAccounts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();
        
        Account testAccount1= new Account();
        testAccount1 = new Account(
            Name                    = 'Testaccount1',
            OwnerId                 = UserInfo.getUserId(),
            Type                    = 'Customer' ,
            EC_Division__c          = 'Institutional',
            EC_Account_Number__c    = '234555',
            ShippingStreet			= 'Street',
			RecordTypeId            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId()
        );
        lstAccounts.add(testAccount1);
        Account testAccount2 = new Account(
            Name                    = 'Testaccount2',
            OwnerId                 = UserInfo.getUserId(),
            Type                    = 'Customer' ,
            EC_Division__c          = 'Water',
            EC_Account_Number__c    = '234005',
            ShippingStreet			= 'ShippingStreet',
            ShippingCity			= 'ShippingCity',
            ShippingState			= 'ShippingState',
            ShippingPostalCode		= 'ShippingPostalCode',
            ShippingCountry			= 'ShippingCountry',
			RecordTypeId            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId()
        );
        lstAccounts.add(testAccount2);
        Account testAccount3 = new Account(
            Name                    = 'Testaccount3',
            OwnerId                 = UserInfo.getUserId(),
            Type                    = 'Customer' ,
            EC_Division__c          = 'FOOD & BEVERAGE',
            EC_Account_Number__c    = '234005',
			RecordTypeId            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Ship To').getRecordTypeId()
        );
        lstAccounts.add(testAccount3);
        Database.insert(lstAccounts);
        
        Contact contact1 = new Contact(FirstName = 'CommunityUser1',LastName  = 'TestUser124',Email = 'abcd@xyz.com',AccountId = testAccount1.Id,MailingStreet = 'abc');
        lstContacts.add(contact1);
        
        Contact contact2 = new Contact(FirstName = 'CommunityUser2',LastName  = 'TestUser124',Email = 'abcd@xyz.com',AccountId = testAccount2.Id,MailingStreet = 'abc');
        lstContacts.add(contact2);
        
        Contact contact3 = new Contact(FirstName = 'CommunityUser3',LastName  = 'TestUser124',Email = 'abcd@xyz.com',AccountId = testAccount3.Id,MailingStreet = 'abc');
        lstContacts.add(contact3);
        Database.insert(lstContacts);        	
        
        AccountContactRelation accRel =[Select Id, Contact.FirstName, Contact.LastName FROM AccountContactRelation LIMIT 1]; 
        accRel.Alignment_Type__c = EC_Constants.PRIMARY_ALIGNMENT_TYPE;
        upsert accRel;
        
        User testOwner = [SELECT TimeZoneSidKey, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(testOwner) {  
            EC_TestData.insertGlobalStaticSettings();
            SAP_TIBCO_URL__c settings = new SAP_TIBCO_URL__c();
            settings.Name = 'Destination URL';
            settings.TIBCO_End_Point_Url__c = '___https://localhost';
            insert settings;
            Test.setMock(WebServiceMock.class, new EC_CaseTextMyRepToSAPMockUp());
            Case caseRec = new case();
            caseRec.Status = 'New';
            caseRec.Type ='Request Service' ;
            caseRec.Origin = 'Portal';
            caseRec.EC_Request_Service_Type__c = 'INSTITUTIONAL' ;
            caseRec.EC_Category_Values__c = 'TRAINING' ;
            caseRec.Description = 'Notes' ;
            insert caseRec;  
            String base64Data = '' +
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                'abcdefghijklmnopqrstuvwxyz' +
                '0123456789+/';
            String contentType = 'image/jpeg';
            EC_ServiceRequestHandler.saveChunk(caseRec.Id, 'test.png',base64Data,contentType);
            UserRole role = new UserRole(DeveloperName = 'TestUser5', Name = 'TestRole5');
            insert role;            
            Profile profile = [SELECT Id
                               FROM Profile
                               WHERE Name = 'Ecolab Customer Community Plus Users' LIMIT 1];
            System.assert(profile != null);
            List<Portal_ESR_Category_Lookup__c> lookupdata = new List<Portal_ESR_Category_Lookup__c>();
            Portal_ESR_Category_Lookup__c record = new Portal_ESR_Category_Lookup__c();
            record.Cat_1_Text__c = 'Test Category';
            record.Cat_2_Text__c = 'Test Sub Category';
            record.Show_on_Portal__c = true;
            record.Cat_1_Code__c = 'ABC';
            record.Cat_2_Code__c = '123';
            
            Portal_ESR_Category_Lookup__c record2 = new Portal_ESR_Category_Lookup__c();
            record2.Cat_1_Text__c = 'INSTITUTIONAL';
            record2.Cat_2_Text__c = 'PRICING';
            record2.Show_on_Portal__c = true;
            record2.Cat_1_Code__c = 'ABC';
            record2.Cat_2_Code__c = '123';
            
            lookupdata.add(record);
            lookupdata.add(record2);
            
            insert lookupdata;
            EC_ServiceRequestHandler.addSAPFields(caseRec,'INSTITUTIONAL','PRICING');
            
            String emailAddress = String.valueOf(System.now().getTime() + '@cc-test.mail');
            User testUser1 = new User(
                Alias                    = 'sample1',
                Email                    = emailAddress,
                EmailEncodingKey         = 'UTF-8',
                LastName                 = 'TestUserRequestsample1',
                LanguageLocaleKey        = 'en_US',
                LocaleSidKey             = 'en_US',
                ProfileId                = profile.Id,
                TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                Username                 = emailAddress,
                isActive                 = true,
                ContactId                = contact1.Id,
                Contact                  = contact1,
                UserRole                 = role                    
            );
            lstTestUsers.add(testUser1);
            User testUser2 = new User(
                Alias                    = 'sample2',
                Email                    = emailAddress,
                EmailEncodingKey         = 'UTF-8',
                LastName                 = 'TestUserRequestsample2',
                LanguageLocaleKey        = 'en_US',
                LocaleSidKey             = 'en_US',
                ProfileId                = profile.Id,
                TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                Username                 = 'test2@cc-test.mail',
                isActive                 = true,
                ContactId                = contact2.Id,
                Contact                  = contact2,
                UserRole                 = role                    
            );
            lstTestUsers.add(testUser2);
            User testUser3 = new User(
                Alias                    = 'sample3',
                Email                    = emailAddress,
                EmailEncodingKey         = 'UTF-8',
                LastName                 = 'TestUserRequestsample3',
                LanguageLocaleKey        = 'en_US',
                LocaleSidKey             = 'en_US',
                ProfileId                = profile.Id,
                TimeZoneSidKey           = testOwner.TimeZoneSidKey,
                Username                 = 'test3@cc-test.mail',
                isActive                 = true,
                ContactId                = contact3.Id,
                Contact                  = contact3,
                UserRole                 = role                    
            );
            lstTestUsers.add(testUser3);
            Database.insert(lstTestUsers);
        }
        
        User usr =[select id, name, contactId from user where lastname='TestUserRequestsample1' limit 1];
        system.runAs(usr){
            ccrz__E_Cart__c cart=new ccrz__E_Cart__c(ccrz__ActiveCart__c=TRUE,ccrz__EffectiveAccountID__c=testAccount1.ID,ccrz__AnonymousId__c=false, ccrz__Contact__c=contact1.Id);
            insert cart;
        }	
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cdLinkList  = new List<ContentDocumentLink>();
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=contact1.id;
        contentlink.ShareType= 'V'; 
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        cdLinkList.add(contentlink);
        insert cdLinkList;
    }
    
    @isTest 
    static void testServiceRequestTestData(){ 
        user u=[select id, name, contactId from user where lastname='TestUserRequestsample1' limit 1];
        
        String key='';
        EC_ServiceRequestHandler.getContactAccounts(key);
        key='Test';            
        test.startTest();
        system.runAs(u){
            EC_ServiceRequestHandler.getContactAccounts(key);
            EC_ServiceRequestHandler.getUserDetailsCache();  
            EC_ServiceRequestHandler.createSRCase('Success');
            Map<String, String> registrationDetails = new Map<String, String>();
            registrationDetails.put('Account','234555');
            registrationDetails.put('RequestType','INSTITUTIONAL');
            registrationDetails.put('Category','PRICING');
            registrationDetails.put('Note','Test message');
            registrationDetails.put('Phone','9845674567');
            registrationDetails.put('email','test@gmail.com');
            registrationDetails.put('soldTo','9845674567');
            EC_ServiceRequestHandler.createServiceRequestCase(registrationDetails);
            EC_ServiceRequestHandler.updateCancel();
            EC_ServiceRequestHandler.decimalToBinary(10);
            EC_ServiceRequestHandler.getContactName();
            EC_ServiceRequestHandler.getDependentMap('EC_Request_Service_Type__c','EC_Category_Values__c');              
        }        
        test.stopTest();
    }
    
    @isTest
    static void testAccountAddressNotNull(){
        user u=[select id, name, contactId from user where lastname='TestUserRequestsample2' limit 1];
        
        String key='';
        EC_ServiceRequestHandler.getContactAccounts(key);
        key='Test';            
        test.startTest();
        system.runAs(u){
            System.assertNotEquals(null, EC_ServiceRequestHandler.getContactAccounts(key));
        }
        test.stopTest();
    }
    
    @isTest
    static void testAccountAddressNull(){
        user u=[select id, name, contactId from user where lastname='TestUserRequestsample3' limit 1];
        
        String key='';
        EC_ServiceRequestHandler.getContactAccounts(key);        
        key='Test';            
        test.startTest();
        system.runAs(u){
            System.assertNotEquals(null, EC_ServiceRequestHandler.getContactAccounts(key));
        }
        test.stopTest();
    }
}