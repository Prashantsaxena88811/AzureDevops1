/* Class Name      :LiveChatTranscriptTriggerTest
* Description      :Test class for LiveChatTranscriptTrigger
* Created By       :Graytitude Team
* Created On       :13.10.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          13.10.2020                                      create test class
*/
@isTest
private class LiveChatTranscriptTriggerTest {
    
    @testSetup static void SetupData() {
        String category = 'Checkout';
        String subcategory = 'How to Checkout';
        
        Account ac = new Account(name ='Grazitti', EC_Division__c='WATER', EC_Account_Number__c='981276345') ;
        insert ac;         
        Contact conRec = new Contact(LastName ='testCon',AccountId=ac.Id,EC_CDM_Contact__c='test');
        insert conRec; 
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.ContactId=conRec.Id;
        insert lct;
        
        LiveChatTranscriptEvent le = new LiveChatTranscriptEvent();
        le.LiveChatTranscriptId = lct.id;
        le.type = 'ChatRequest';
        le.time = System.now();
        insert le;
        
        ChatBotCaseCreate.Request input = new ChatBotCaseCreate.Request();        
        input.routableId = lct.Id;
        input.category = category;
        input.subcategory = subcategory;
        input.accountnumber = ac.Name + ':' + ac.EC_Account_Number__c;
        ChatBotCaseCreate.createCase(new List<ChatBotCaseCreate.Request>{input});
    }
    
    testmethod static void Test_LiveChatTranscriptTriggerHandler_InProgress1() {         
        LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];        
        Test.startTest();
        LiveChatTranscriptTriggerHandler.isInprogress = true;
        update lct;
        Test.stopTest();
        Case objCase = [SELECT Assigned_To_Queue__c FROM Case LIMIT 1];
        System.assertNotEquals(objCase.Assigned_To_Queue__c, ChatPendingQueueName);
    }
    
    testmethod static void Test_LiveChatTranscriptTriggerHandler_InProgress2() {         
        LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1]; 
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        objAcc.EC_Division__c='INSTITUTIONAL';
        update objAcc;
        Test.startTest();
        new LiveChatTranscriptTriggerHandler();
        LiveChatTranscriptTriggerHandler.isInprogress = true;
        update lct;
        Test.stopTest();
        Case objCase = [SELECT Assigned_To_Queue__c FROM Case LIMIT 1];
        System.assertNotEquals(objCase.Assigned_To_Queue__c, ChatPendingQueueName);
    }
    
    testmethod static void Test_LiveChatTranscriptTriggerHandler_Completed() {         
        LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];        
        Test.startTest();
        lct.EndedBy = 'Visitor';
        lct.Status = 'Completed';
        update lct;
        Test.stopTest();
        Case objCase = [SELECT Assigned_To_Queue__c FROM Case LIMIT 1];
        System.assertNotEquals(objCase.Assigned_To_Queue__c, ChatPendingQueueName);
    }
    
    testmethod static void Test_LiveChatTranscriptTriggerHandler_Completed2() {         
        LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];  
        Case objCase = [SELECT Id,Hide_from_Customer__c FROM Case LIMIT 1];
        objCase.Hide_from_Customer__c = false;
        update objCase;
        Test.startTest();
        lct.EndedBy = 'Visitor';
        lct.Status = 'Completed';
        update lct;
        Test.stopTest();
        objCase = [SELECT Assigned_To_Queue__c FROM Case LIMIT 1];
        System.assertNotEquals(objCase.Assigned_To_Queue__c, ChatPendingQueueName);
    }
    
    private static String ChatPendingQueueName = 'Chat Pending';
}