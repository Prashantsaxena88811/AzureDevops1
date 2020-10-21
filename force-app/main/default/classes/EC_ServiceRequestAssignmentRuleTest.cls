@isTest
private class EC_ServiceRequestAssignmentRuleTest {
    @isTest    
    private static void caseRulesTest () {

        
        case testingVar = new case();
        
        // testingVar.EC_Request_Service_Type__c = 'Request Service';
        testingVar.status = 'New';
        testingVar.Origin = 'Portal';
        testingVar.Type = 'Request Service';
        insert testingVar;
        EC_ServiceRequestAssignmentRule ruleRunning = new EC_ServiceRequestAssignmentRule();
        testingVar = ruleRunning.caseRules(testingVar);
        
        /* system.assertEquals (testingVar.OwnerId=queueItem.Queue.Id;); */
        system.assertnotequals(testingVar, null);
      
    }
    
    @testSetup
    static void getTestDataServiceRequest(){  
        EC_TestData.setupTestUser();
		User testUser = [SELECT Id, contactId FROM User WHERE LastName = 'TestUser'];      
        Account testAccount = EC_TestData.testAccountServiceRequest;
              	
        User testOwner = [SELECT TimeZoneSidKey, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(testOwner) {  
            EC_TestData.insertSettings();
            EC_TestData.insertGlobalStaticSettings();
            Test.setMock(WebServiceMock.class, new EC_CaseTextMyRepToSAPMockUp());
            Case caseRec = EC_TestData.insertCase();
            String base64Data = '' +'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +'abcdefghijklmnopqrstuvwxyz'+'0123456789+/';
            String contentType = 'image/jpeg';
            EC_ServiceRequestHandler.saveChunk(caseRec.Id, 'test.png',base64Data,contentType);
            List<Portal_ESR_Category_Lookup__c> lookupdata = new List<Portal_ESR_Category_Lookup__c>();
            Portal_ESR_Category_Lookup__c record = EC_TestData.getRecord1();
            Portal_ESR_Category_Lookup__c record2 = EC_TestData.getRecord2();
            lookupdata.add(record);
            lookupdata.add(record2);
            insert lookupdata;
            EC_ServiceRequestHandler.addSAPFields(caseRec,'INSTITUTIONAL','PRICING');  
        }
        system.runAs(testUser){
            ccrz__E_Cart__c cart=new ccrz__E_Cart__c(ccrz__ActiveCart__c=TRUE,ccrz__EffectiveAccountID__c=testAccount.ID,ccrz__AnonymousId__c=false, ccrz__Contact__c=testUser.contactId);
            insert cart;
        }	
        EC_TestData.insertContentVersion();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> cdLinkList  = new List<ContentDocumentLink>();
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=testUser.contactId;
        contentlink.ShareType= 'V'; 
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        cdLinkList.add(contentlink);
        insert cdLinkList;
    }
}