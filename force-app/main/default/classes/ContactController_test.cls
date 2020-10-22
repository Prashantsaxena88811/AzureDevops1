@isTest
public class ContactController_test {
    static testMethod void validateSave() {
        Test.startTest();
        System.debug('11');
        ContactController aa = new ContactController();
        aa.save();
        Test.stopTest();
        System.debug('depl11oyed from release1');
    }
}