@isTest
public class EC_UnsubscribeTest {

    static testMethod void testupdateContact(){
        Contact cont = new Contact();
        cont.FirstName = 'TestFirst';
        cont.LastName = 'TestLast';
        cont.Email = 'test@test.com';
        cont.Unsubscribe__c = false;
        insert cont;
        
        ccrz__E_Cart__c cart = new ccrz__E_Cart__c();
        cart.ccrz__Contact__c = cont.Id;
        cart.ccrz__ActiveCart__c = true;
        cart.ccrz__CartStatus__c = 'Open';
		insert cart;		        
        
        Test.setCurrentPageReference(new PageReference('Page.EC_Unsubscribe'));
		System.currentPageReference().getParameters().put('Email', cont.Email);
		System.currentPageReference().getParameters().put('contactId', cont.Id);
        
        

    }
}