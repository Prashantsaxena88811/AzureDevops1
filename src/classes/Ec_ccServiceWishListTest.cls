/* Class Name    : Ec_ccServiceWishListTest 
* Description    : Test Class to cover Ec_ccServiceWishList
* Created By     : Rajeshwar
* Created On     : 2020-May-04


* Modification Log:
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------
* Rajeshwar               2020-May-04     BC-76559                 Created the class   
*
*/
@isTest
public class Ec_ccServiceWishListTest {
    
/***************************************************************************************************************************************
Method Name : test_getFilterMap
Description : Test method to cover getFilterMap method
Return type : void
*************************************************************************************************************************************/
    
    static testMethod void test_getFilterMap() {
        system.runAs(getCommunityUser()) {
            Test.startTest();
            EC_ccServiceWishList extend= new EC_ccServiceWishList();
            Map<String,Object> inputData = new Map<String,Object>();
            Map<String, Object> res=extend.getFilterMap(inputData);
            System.assert(null != res);
            Test.stopTest();
        } 
    }
    
    private static User getCommunityUser() {
        User communityUser = new User();
        //Create account  
        Account portalAccount = new Account(  
            Name = 'portalAccount',  
            OwnerId = UserInfo.getUserId()  
        );  
        Database.insert(portalAccount);  
        //Create contact  
        Contact portalContact = new Contact(  
            FirstName = 'portalContactFirst',  
            Lastname = 'portalContactLast',  
            AccountId = portalAccount.Id,  
            Email = 'portalContact' + System.currentTimeMillis() + '@test.com'  
        );  
        Database.insert(portalContact);  
        communityUser = new User(  
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Ecolab Connect iBuy CCP User'].Id,  
            FirstName = 'CommunityUserFirst',  
            LastName = 'CommunityUserLast',  
            Email = 'community.user@test.com',  
            Username = 'community.user.' + System.currentTimeMillis() + '@test.com',  
            Title = 'Title',  
            Alias = 'Alias',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            EmailEncodingKey = 'UTF-8',  
            LanguageLocaleKey = 'en_US',  
            LocaleSidKey = 'en_US',  
            ContactId = portalContact.id  
        );  
        Database.insert(communityUser);  
        return communityUser;
    }
    
}