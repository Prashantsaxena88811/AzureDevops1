@istest
public class CaseCreationQueueableTest {
    public final static String failed = 'failed';
    public final static String subject = 'Contact person account name Contact person account name Contact person account name Contact person account name Contact person account name Contact person account name';
    public final static String response = '{"result": '+String.valueOf('{"case_number": "CS0088436", "state": "Open"}')+',"token_type": "Bearer", "expires_in": 3599, "ext_expires_in": 3599, "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImtnMkxZczJUMENUaklmajRydDZKSXluZW4zOCIsImtpZCI6ImtnMkxZczJUMENUaklmajRydDZKSXluZW4zOCJ9.eyJhdWQiOiJodHRwczovL25hbGNvLm1pY3Jvc29mdG9ubGluZS5jb20vNzRmNjE3OWEtODFjOC00N2NmLTgxMzEtM2E4NTRkZWU5M2ZiIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvYzFlYjUxMTItNzk0Ni00YzlkLWJjNTctNDAwNDBjZmUzYTkxLyIsImlhdCI6MTYwMTkwNDA1OCwibmJmIjoxNjAxOTA0MDU4LCJleHAiOjE2MDE5MDc5NTgsImFpbyI6IkUyUmdZSWpWdDVQcVhpanRkZjljNldRMWQ1VkZBQT09IiwiYXBwaWQiOiJjMjhmMDkxZC0yNjZmLTRjMTUtYWI2YS0xYzFiMWJlZDBhNTEiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jMWViNTExMi03OTQ2LTRjOWQtYmM1Ny00MDA0MGNmZTNhOTEvIiwicmgiOiIwLkFBQUFFbEhyd1VaNW5VeThWMEFFRFA0NmtSMEpqOEp2SmhWTXEyb2NHeHZ0Q2xFREFBQS4iLCJ0aWQiOiJjMWViNTExMi03OTQ2LTRjOWQtYmM1Ny00MDA0MGNmZTNhOTEiLCJ1dGkiOiJidGQtUFNfOGhVLXVkUk9iM2drWkFRIiwidmVyIjoiMS4wIn0.IdJPBFzxyByjrH4eoG98J5i1rUU_gW_SFibY9yzts4sPGMUZP4kH29uLrvVbUpCTFJ0K-cnNptIcYGpTDC_HwpatZN6knAaeJ7ZQ8q8fIl3Z_f5RJJP_WqFkkqKc3VrY0L2yX75Hb3j04OYYbxy7V-qqLbQpquQRkO7kF3x8c0nDH_Q2vCq7lp56qhT3KjWzSqaqT7Q0ftynbruuCUppNN_hNtO_GSiWyATrmqT5gcRthVJFex15uBCwXXG7swwHjQ4JkmHxrENDZNhKuKzRP7yMabuz6QPpSy8wFKFj6olVvkLYpUx7WJGA5Z5PKSCutQHD_7OwgQTq71hJv_iqiw"}';

    public static void createCase(){
        Account ac = new Account(name ='Grazitti Contact person account name Contact person account name Contact person account name Contact person account name',ShippingCity='Contact person account name Contact person account name Contact person') ;
        insert ac; 
        
        Contact conRec = new Contact(LastName ='testCon',firstName='Contact person account name',AccountId = ac.Id,EC_CDM_Contact__c='testcontact');
        insert conRec;
        Id groupId = [SELECT Id FROM Group where DeveloperName='DCS_Agents' limit 1].Id;
        Id supRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case newTestC = new Case();
        newTestC.RecordTypeId = supRecordTypeId;
        newTestC.OwnerId = groupId;
        newTestC.Category__c= 'Login';
        newTestC.Sub_Category__c = 'Forgot Username';
        newTestC.SuppliedPhone = '9004959554';
        newTestC.Contact_Email__c = 'test@test.com';   
        newTestC.Description = 'SFDC to Mulesoft Test';
        newTestC.External_Id__c = 'CS000001';
        newTestC.AccountId = ac.id; 
        newTestC.ContactId = conRec.id;
        newTestC.Subject = subject;
        insert newTestC;
    }
    @testSetup static void setup() {
        list<EC_Mulesoft_Integration__c> muleIntegrations = new list<EC_Mulesoft_Integration__c>();
        EC_Mulesoft_Integration__c muleIntegrationRec = new EC_Mulesoft_Integration__c();
        muleIntegrationRec.EC_Endpoint__c = 'https://login.microsoftonline.com/ecolab.com/oauth2/v2.0/token';
        muleIntegrationRec.EC_ClientId__c = 'c28f091d-266f-4c15-ab6a-1c1b1bed0a51';
        muleIntegrationRec.EC_Client_Secret__c = 'b52p3-TM_bd9H_.M__--KJmO.dQjpjv416';
        muleIntegrationRec.Name = 'ServiceNow Case Create';
        
        
        EC_Mulesoft_Integration__c muleIntegrationRec1 = new EC_Mulesoft_Integration__c();
        muleIntegrationRec1.EC_Endpoint__c = 'https://login.microsoftonline.com/ecolab.com/oauth2/v2.0/token';
        muleIntegrationRec1.EC_ClientId__c = 'c28f091d-266f-4c15-ab6a-1c1b1bed0a51';
        muleIntegrationRec1.EC_Client_Secret__c = 'b52p3-TM_bd9H_.M__--KJmO.dQjpjv416';
        muleIntegrationRec1.Name = 'ServiceNow Get Token';
        
        
        EC_Mulesoft_Integration__c muleIntegrationRec2 = new EC_Mulesoft_Integration__c();
        muleIntegrationRec2.EC_Endpoint__c = 'https://nalco.microsoftonline.com/74f6179a-81c8-47cf-8131-3a854dee93fb/.default';
        muleIntegrationRec2.EC_ClientId__c = 'c28f091d-266f-4c15-ab6a-1c1b1bed0a51';
        muleIntegrationRec2.EC_Client_Secret__c = 'b52p3-TM_bd9H_.M__--KJmO.dQjpjv416';
        muleIntegrationRec2.Name = 'ServiceNow Scope';
        
        muleIntegrations.add(muleIntegrationRec);
        muleIntegrations.add(muleIntegrationRec1);
        muleIntegrations.add(muleIntegrationRec2);
        insert muleIntegrations;
        
        Account ac = new Account(name ='Grazitti Contact person account name Contact person account name Contact person account name Contact person account name') ;
        insert ac; 
        
        Contact conRec = new Contact(LastName ='testCon',firstName='Contact person account name',AccountId = ac.Id,EC_CDM_Contact__c='testcontact');
        insert conRec;
        Id groupId = [SELECT Id FROM Group where DeveloperName='DCS_Agents' limit 1].Id;
        Id supRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case newTestC = new Case();
        newTestC.RecordTypeId = supRecordTypeId;
        newTestC.OwnerId = groupId;
        newTestC.Category__c= 'Login';
        newTestC.Sub_Category__c = 'Forgot Username';
        newTestC.SuppliedPhone = '2343454556';
        newTestC.Contact_Email__c = 'test@test.com';   
        newTestC.Description = 'SFDC to Tibco Test';
        newTestC.External_Id__c = 'CS000001';
        newTestC.AccountId = ac.id; 
        newTestC.ContactId = conRec.id;
        newTestC.Subject = 'Contact person account name Contact person account name Contact person account name Contact person account name Contact person account name Contact person account name';
        insert newTestC;
    }
    @istest
    public static void successRequest(){
        case c = [select id from case limit 1];
        EC_Mulesoft_Integration__c callOutDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        Map<String,String> headers = new Map<String, String>();
        headers.put(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        headers.put('client_id', callOutDetails.EC_ClientId__c);
        headers.put('client_secret', callOutDetails.EC_Client_Secret__c);
        Test.startTest();
        String response = response;
        Test.setMock(HttpCalloutMock.class, new ServiceNowCaseCreateHTTPMockFactory(201,'Success',response,headers));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        Test.stopTest();
        string actual = [select id,External_Id__c from case where id=:c.id limit 1].External_Id__c;
        system.assertEquals('CS0088436', actual);
    }
    @istest
    public static void failedRequestWithExceptionStatuscodes(){
        case c = [select id from case limit 1];
        EC_Mulesoft_Integration__c callOutDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        Map<String,String> headers = new Map<String, String>();
        headers.put(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        headers.put('client_id', callOutDetails.EC_ClientId__c);
        headers.put('client_secret', callOutDetails.EC_Client_Secret__c);
        Test.startTest();
        String response = response;
        Test.setMock(HttpCalloutMock.class, new ServiceNowCaseCreateHTTPMockFactory(400,failed,response,headers));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},null));
        Test.stopTest();
        string actual = [select id,External_Id__c,Integration_Status__c from case where id=:c.id limit 1].Integration_Status__c;
        system.assertEquals('Submitted Failure', actual);
    }
    /*@istest
    public static void failedWithoutToken(){
        case c = [select id from case limit 1];
        EC_Mulesoft_Integration__c callOutDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        Map<String,String> headers = new Map<String, String>();
        headers.put(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        headers.put('client_id', callOutDetails.EC_ClientId__c);
        headers.put('client_secret', callOutDetails.EC_Client_Secret__c);
        Test.startTest();
        String response = response;
        Test.setMock(HttpCalloutMock.class, new ServiceNowCaseCreateHTTPMockFactory(415,failed,response,headers));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},null));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        Test.stopTest();
        string actual = [select id,External_Id__c,Integration_Status__c from case where id=:c.id limit 1].Integration_Status__c;
        system.assertEquals(EC_Constants.submittedFailure, actual);
    }*/
    
    @istest
    public static void failedWithToken(){
        case c = [select id from case limit 1];
        EC_Mulesoft_Integration__c callOutDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        Map<String,String> headers = new Map<String, String>();
        headers.put(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        headers.put('client_id', callOutDetails.EC_ClientId__c);
        headers.put('client_secret', callOutDetails.EC_Client_Secret__c);
        Test.startTest();
        String response = response;
        Test.setMock(HttpCalloutMock.class, new ServiceNowCaseCreateHTTPMockFactory(415,failed,response,headers));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        Test.stopTest();
        Decimal retry_Counter = [select id,retry_Counter__c from Integration_Log__c].retry_Counter__c;
        system.assertEquals(true, retry_Counter>2);
    }
    @istest
    public static void failedExpiredToken(){
        case c = [select id from case limit 1];
        EC_Mulesoft_Integration__c callOutDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        Map<String,String> headers = new Map<String, String>();
        headers.put(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        headers.put('client_id', callOutDetails.EC_ClientId__c);
        headers.put('client_secret', callOutDetails.EC_Client_Secret__c);
        Test.startTest();
        String response = response;
        Test.setMock(HttpCalloutMock.class, new ServiceNowCaseCreateHTTPMockFactory(401,failed,response,headers));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        Test.stopTest();
        Decimal retry_Counter = [select id,retry_Counter__c from Integration_Log__c].retry_Counter__c;
        system.assertEquals(false, retry_Counter>0);
    }
    
    @istest
    public static void testCaseCreationSchedulable(){
        sobject c = [select id from case limit 1];
        EC_Mulesoft_Integration__c callOutDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        Map<String,String> headers = new Map<String, String>();
        headers.put(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        headers.put('client_id', callOutDetails.EC_ClientId__c);
        headers.put('client_secret', callOutDetails.EC_Client_Secret__c);
        String nextjobRun = '0 0 0 ? * * *';
        test.startTest();
        String response = response;
        Test.setMock(HttpCalloutMock.class, new ServiceNowCaseCreateHTTPMockFactory(201,'Success',response,headers));
        CaseCreationSchedulable s = new CaseCreationSchedulable(new list<String>{c.Id},null); 
        System.schedule('Job Started At ' + Datetime.now(), nextjobRun, s);
        test.stopTest();
        
        string actual = [select id,External_Id__c from case where id=:c.id limit 1].External_Id__c;
        system.assertEquals('CS000001', actual);
    }
    
    @istest
    public static void doException(){
        Id groupId = [SELECT Id FROM Group where DeveloperName='DCS_Agents' limit 1].Id;
        Id supRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case newTestC = new Case();
        newTestC.RecordTypeId = supRecordTypeId;
        newTestC.OwnerId = groupId;
        newTestC.Category__c= 'Login';
        newTestC.Sub_Category__c = 'Forgot Username';
        newTestC.SuppliedPhone = '2343454556';
        newTestC.Contact_Email__c = 'test@test.com';   
        newTestC.Description = 'SFDC to Mulesoft Test';
        newTestC.External_Id__c = 'CS000001';
        newTestC.status ='closed';
        newTestC.Subject = subject;
        insert newTestC;
        case c = [select id from case where id=:newTestC.Id limit 1];
        EC_Mulesoft_Integration__c callOutDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        Map<String,String> headers = new Map<String, String>();
        headers.put(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        headers.put('client_id', callOutDetails.EC_ClientId__c);
        headers.put('client_secret', callOutDetails.EC_Client_Secret__c);
        Test.startTest();
        String response = response;
        Test.setMock(HttpCalloutMock.class, new ServiceNowCaseCreateHTTPMockFactory(201,'Success',response,headers));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        Test.stopTest();
        string actual = [select id,External_Id__c from case where id=:c.id limit 1].External_Id__c;
        system.assertEquals('CS0088436', actual);
    }
    @istest
    public static void doMaxlength(){
        Id groupId = [SELECT Id FROM Group where DeveloperName='DCS_Agents' limit 1].Id;
        Id supRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case newTestC = new Case();
        newTestC.RecordTypeId = supRecordTypeId;
        newTestC.OwnerId = groupId;
        newTestC.Category__c= 'Login';
        newTestC.Sub_Category__c = 'Forgot Username';
        newTestC.SuppliedPhone = '2343454556';
        newTestC.Contact_Email__c = 'test@test.com';   
        newTestC.Description = 'SFDC to Mulesoft Test';
        newTestC.External_Id__c = 'CS000001';
        newTestC.status ='Resolved';
        newTestC.Subject = subject;
        insert newTestC;
        case c = [select id from case where id=:newTestC.Id limit 1];
        EC_Mulesoft_Integration__c callOutDetails = EC_QueryUtility.getHeader('ServiceNow Get Token');
        Map<String,String> headers = new Map<String, String>();
        headers.put(Label.EC_CONTENT_TYPE, Label.EC_CONTENT_TYPE_VALUE);
        headers.put('client_id', callOutDetails.EC_ClientId__c);
        headers.put('client_secret', callOutDetails.EC_Client_Secret__c);
        Test.startTest();
        String response = response;
        Test.setMock(HttpCalloutMock.class, new ServiceNowCaseCreateHTTPMockFactory(201,'Success',response,headers));
        System.enqueueJob(new CaseCreationQueueable(new list<String>{c.Id},'access_token'));
        Test.stopTest();
        string actual = [select id,External_Id__c from case where id=:c.id limit 1].External_Id__c;
        system.assertEquals('CS0088436', actual);
        new CaseCreateInServiceNow();
    }
}