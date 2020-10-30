/* Class Name      :ChatBotTest
* Description      :Test class for all einstien bot related classes
* Created By       :Graytitude Team
* Created On       :24.09.2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team          24.09.2020                                      create test class
*/
@isTest
private class ChatBotTest {    

    testmethod static void Test_ChatBotArticleSearch() {        
        User runUser = getUser();
 
        system.runAs(runUser){
            knowledge__kav newArticle = new knowledge__kav(Title='How to checkout',summary='How to checkout',urlname='How-to-Checkout1', category__c = 'Checkout', Sub_Category__c = 'How to checkout',IsVisibleInCsp=true);
            insert newArticle;
            knowledge__kav newArticle2 = new knowledge__kav(Title='How to Login',summary='How to Login',urlname='How-to-Login1', category__c = 'Login', Sub_Category__c = 'How to Login',IsVisibleInCsp=true, Walkme_Url__c='www.walkme.com');
            insert newArticle2;
            Id kAId = [SELECT KnowledgeArticleId FROM knowledge__kav WHERE Id=:newArticle.Id LIMIT 1].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(kAId, true);
            Id kAId2 = [SELECT KnowledgeArticleId FROM knowledge__kav WHERE Id=:newArticle2.Id LIMIT 1].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(kAId2, true);
            
            ChatBotArticleSearch.SearchInput input = new ChatBotArticleSearch.SearchInput();
            input.category = 'Checkout';
            input.subCategory = 'How to checkout';
            Test.startTest();
            List<ChatBotArticleSearch.SearchOutput> lstResult = ChatBotArticleSearch.searchFAQ(new List<ChatBotArticleSearch.SearchInput>{input});
            input.category = 'Login';
            input.subCategory = 'How to Login';
            lstResult = ChatBotArticleSearch.searchFAQ(new List<ChatBotArticleSearch.SearchInput>{input});
            ChatBotArticleSearch inst = new ChatBotArticleSearch();
            Test.stopTest();
            System.assertNotEquals(lstResult.size(), 0);
            System.assertNotEquals(inst, null);
        }
    }
    
    testmethod static void Test_ChatBotRouting() {        
        User runUser = getUser();
        system.runAs(runUser){       
            String category = 'Checkout';
            String subcategory = 'How to Checkout';
           
            Chat_Bot_Routing__c objCBR = new Chat_Bot_Routing__c(
                Category__c=category,
                Sub_Category__c=subcategory, 
                Show_Walkme__c=true,  
                Show_Article__c=true, 
                Transfer_to_Agent__c=true, 
                Create_Case__c=true,
                Division__c='All' 
            );              
            insert objCBR;
            
            ChatBotRouting.RoutingRequest input = new ChatBotRouting.RoutingRequest();
            input.category = category;
            input.subCategory = subCategory;
            Test.startTest();
            List<ChatBotRouting.RoutingResponse> lstResult = ChatBotRouting.chatBotRoutingData(new List<ChatBotRouting.RoutingRequest>{input});
            ChatBotRouting inst = new ChatBotRouting();
            Test.stopTest();
            System.assertNotEquals(lstResult.size(), 0);
            System.assertNotEquals(inst, null);
        }
    }
    
    testmethod static void Test_ChatBotcategoryList() {        
        User runUser = getUser();
 
        system.runAs(runUser){        
            String category = 'Checkout';
            String subcategory = 'How to Checkout';
           
            Chat_Bot_Routing__c objCBR = new Chat_Bot_Routing__c(
                Category__c=category,
                Sub_Category__c=subcategory, 
                Show_Walkme__c=true,  
                Show_Article__c=true, 
                Transfer_to_Agent__c=true, 
                Create_Case__c=true,
                Division__c='All' 
            );              
            insert objCBR;
            
            Account ac = new Account(name ='Grazitti') ;
            ac.EC_Division__c = 'INSTITUTIONAL';
            insert ac;         
            Contact conRec = new Contact(LastName ='testCon',AccountId=ac.Id,EC_CDM_Contact__c='test');
            insert conRec; 
            
            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid = lcv.id;
            lct.ContactId=conRec.Id;
            insert lct;
            
            ChatBotCategoryList.Input input = new ChatBotCategoryList.Input();        
            input.routableId=lct.Id;
            Test.startTest();
            List<List<String>> lstResult = ChatBotCategoryList.getCategories(new List<ChatBotCategoryList.Input>{input});
            input.category = category;
            lstResult = ChatBotCategoryList.getCategories(new List<ChatBotCategoryList.Input>{input});
            ChatBotCategoryList inst = new ChatBotCategoryList();
            Test.stopTest();
            System.assertNotEquals(lstResult.size(), 0);
            System.assertNotEquals(inst, null);
        }
    }
    
    testmethod static void Test_ChatBotRelatedAccountList() { 
        User runUser = getUser();
 
        system.runAs(runUser){      
            Account ac = new Account(name ='Grazitti') ;
            ac.EC_Account_Number__c = '981276345';
            insert ac;         
            Contact conRec = new Contact(LastName ='testCon',AccountId=ac.Id,EC_CDM_Contact__c='test');
            insert conRec; 
            
            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid = lcv.id;
            lct.ContactId=conRec.Id;
            insert lct;
            
            ChatBotRelatedAccountList.Input input = new ChatBotRelatedAccountList.Input();        
            input.routableId=lct.Id;
            Test.startTest();
            List<List<String>> lstResult = ChatBotRelatedAccountList.getRelatedAccount(new List<ChatBotRelatedAccountList.Input>{input});
            ChatBotRelatedAccountList inst = new ChatBotRelatedAccountList();
            Test.stopTest();
            System.assertNotEquals(lstResult.size(), 0);
            System.assertNotEquals(inst, null);
        }   
    }
    
    testmethod static void Test_ChatBotGetContactInfo() { 
        User runUser = getUser();
 
        system.runAs(runUser){      
            Account ac = new Account(name ='Grazitti') ;
            ac.EC_Account_Number__c = '981276345';
            insert ac;         
            Contact conRec = new Contact(LastName ='testCon',AccountId=ac.Id,EC_CDM_Contact__c='test');
            insert conRec; 
            
            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid = lcv.id;
            lct.ContactId=conRec.Id;
            insert lct;
            
            ChatBotGetContactInfo.Input input = new ChatBotGetContactInfo.Input();        
            input.routableId=lct.Id;
            Test.startTest();
            List<ChatBotGetContactInfo.Output> lstResult = ChatBotGetContactInfo.getContactInfo(new List<ChatBotGetContactInfo.Input>{input});
            ChatBotGetContactInfo inst = new ChatBotGetContactInfo();
            Test.stopTest();
            System.assertNotEquals(lstResult.size(), 0);
            System.assertNotEquals(inst, null);
        }
    }
    
    testmethod static void Test_ChatBotCaseCreate() { 
        User runUser = getUser();
 
        system.runAs(runUser){       
            String category = 'Checkout';
            String subcategory = 'How to Checkout';
            
            Account ac = new Account(name ='Grazitti') ;
            ac.EC_Account_Number__c = '981276345';
            insert ac;         
            Contact conRec = new Contact(LastName ='testCon',AccountId=ac.Id,EC_CDM_Contact__c='test');
            insert conRec; 
            
            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
            LiveChatTranscript lct = new LiveChatTranscript();
            lct.LiveChatVisitorid = lcv.id;
            lct.ContactId=conRec.Id;
            insert lct;
            
            ChatBotCaseCreate.Request input = new ChatBotCaseCreate.Request();        
            input.routableId = lct.Id;
            input.category = category;
            input.subcategory = subcategory;
            input.accountnumber = ac.Name + ':' + ac.EC_Account_Number__c;
            Test.startTest();
            List<String> lstResult = ChatBotCaseCreate.createCase(new List<ChatBotCaseCreate.Request>{input});        
            ChatBotCaseCreate inst = new ChatBotCaseCreate();
            Test.stopTest();
            System.assertNotEquals(lstResult.size(), 0);
            System.assertNotEquals(inst, null);
        }
    }
    
    private static User getUser() {
        // Create a unique UserName
        String uniqueUserName = 'systemadmin' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        return new User(Alias = 'standt', Email='systemadmin@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName, 
        UserPermissionsKnowledgeUser = true);  
    } 
}