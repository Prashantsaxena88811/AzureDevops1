/* Class Name      :SupportCaseCreateControllerTest
* Description      :Test class of Community Case Creation Form Controller
* Created By       :Graytitude Team
* Created On       :20-09-2020
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Graytitude Team        20-09-2020                                        Test Class of Community Case Creation Form Controller
*/
@isTest
private class SupportCaseCreateControllerTest{
    static String lang = 'en_US';
    @isTest
    static void createAsCustomer(){
        SupportCaseCreateController.getIssueRecordTypeId();
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        Id p = [select id from profile where name = 'Ecolab Customer Community Plus Users' limit 1].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
        Contact conRec = new Contact(LastName ='testCon',AccountId = ac.Id,EC_CDM_Contact__c='testcontact');
        insert conRec;  
        
        User customer = new User(alias = 'test1234', email='test1234@noemail.com'+ uid,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey=lang,contactid=conRec.id,
                                 localesidkey=lang , profileid = p, country='United States',IsActive =true,EC_CDM_User__c='testuser',
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com'+ uid);
        
        insert customer;       
        Contact con = SupportCaseCreateController.getContactId(customer.Id);
        System.assertEquals(customer.contactid, con.id);
        SupportCaseCreateController.getContactRelatedAccounts(con.Id);
        
        knowledge__kav newArticle = new knowledge__kav(Title='How to checkout',summary='How to checkout',urlname='How-to-Checkout123', category__c = 'Checkout', Sub_Category__c = 'How to checkout');
        insert newArticle;
        
        knowledge__kav viewArticle = SupportCaseCreateController.getDefaultValues(newArticle.urlname);
        String caseId;
        Case objCase = SupportCaseCreateControllerTest.createCase(con.Id, ac.Id, viewArticle );
        system.RunAs(customer){
          caseId = SupportCaseCreateController.saveCase(objCase);
        }
        System.AssertNotEquals(caseId, null);
    }
    private static Case createCase(String contactId, String accId, knowledge__kav viewArticle){
        return new Case(recordtypeid = SupportCaseCreateController.getIssueRecordTypeId(),
                        origin = 'Portal Support', 
                        ContactId = contactId, accountid = accId, 
                        Category__c = viewArticle.Category__c,
                        Sub_Category__c = viewArticle.Sub_Category__c, Run_Assignment_Rule__c = TRUE);
    }    
    @isTest
    static void createAsSalesRep(){
        SupportCaseCreateController.getIssueRecordTypeId();
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        Contact con = SupportCaseCreateController.getContactId(UserInfo.getUserId());
        list<AccountContactRelation> acrList = SupportCaseCreateController.getContactRelatedAccounts(con.id);
        system.assertEquals(acrList.size(), 0);
        
        knowledge__kav newArticle = new knowledge__kav(Title='Cannot Checkout Rush Order',summary='Cannot Checkout Rush Order',urlname='Cannot-Checkout-Rush-Order1', category__c = 'Checkout', Sub_Category__c = 'Cannot Checkout Rush Order');
        insert newArticle;
        
        knowledge__kav viewArticle = SupportCaseCreateController.getDefaultValues(newArticle.urlname);
        String caseId = SupportCaseCreateController.saveCase(SupportCaseCreateControllerTest.createCase(con.Id, ac.Id, viewArticle ));
        
        system.AssertEquals(caseId, [select id, caseid from CaseShare where caseId =: caseId limit 1].caseId);
        system.AssertEquals(UserInfo.getUserId(), [select id, caseid, UserOrGroupId from CaseShare where caseId =: caseId limit 1].UserOrGroupId);
        System.AssertNotEquals(caseId, null);
    }
    @isTest
    static void getContactId(){
        SupportCaseCreateController.getIssueRecordTypeId();
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        Id p = [select id from profile where name like '%salesforce%' limit 1].id;
        
        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
        
        Contact conRec = new Contact(LastName ='testCon',AccountId = ac.Id,EC_CDM_Contact__c='testcontact2');
        insert conRec;  
        
        User user = new User(alias = 'test123', email='test123@noemail.com'+ uid,
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey=lang ,
                             localesidkey=lang , profileid = p, country='United States',IsActive =true,EC_CDM_User__c='testuser2',
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com'+ uid);
        
        insert user;
        Contact con = SupportCaseCreateController.getContactId(user.Id);
        SupportCaseCreateController.getContactRelatedAccounts(con.Id);
        System.AssertNotEquals(con, null);
    }
}