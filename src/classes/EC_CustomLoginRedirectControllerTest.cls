/* Class Name    : EC_CustomLoginRedirectControllerTest
 * Description      Test Class to cover EC_CustomLoginRedirectController
 * Created By       :Ravindra
 * Created On       :2019-7-8
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ravindra            2019-7-8                               Created the class   
 *
 */
@isTest
global class EC_CustomLoginRedirectControllerTest{
    /***************************************************************************************************************************************
  Method Name : testPositive
  Description : Test method to cover EC_CustomLoginRedirectController
  Return type : void
 *************************************************************************************************************************************/
    static testMethod void testPositive() {
        EC_CustomLoginRedirectController.getProfile();
        EC_OutageFlag__c CommunityActiveCS = new EC_OutageFlag__c();
        CommunityActiveCS.Name = 'CommunityActive';
        CommunityActiveCS.EC_isCommunityActive__c = true;
        insert CommunityActiveCS;
        Test.startTest();
        
        EC_CustomLoginRedirectController controller = new EC_CustomLoginRedirectController();
        EC_CustomLoginRedirectController.outageRedirect();
        PageReference pagerefTest1= Page.ccrz__HomePage;
        pagerefTest1.getParameters().put('startURL', 'ecolab.com');
        Test.setCurrentPage(pagerefTest1);
        controller.redirectToCommunity();
        System.assertNotEquals(null, EC_CustomLoginRedirectController.getAuthConfig());
        System.assertEquals('', EC_CustomLoginRedirectController.getSamlID());
        System.assertEquals(null,EC_CustomLoginRedirectController.getLoginUrl());
        System.assertEquals(null,EC_CustomLoginRedirectController.getCommunityURL());
        
        //EC_CustomLoginRedirectController.getSamlSSOUrl('startUrl');
        System.assertEquals(null,EC_CustomLoginRedirectController.getSelfRegistrationUrl());
        System.assertEquals(true, EC_CustomLoginRedirectController.outageRedirect());
        Test.stopTest();
        
    }
    /***************************************************************************************************************************************
  Method Name : testPositive
  Description : Test method to cover getSamlSSOUrl
  Return type : void
 *************************************************************************************************************************************/
    static testMethod void testPositive2() {
        
        Test.startTest();
        String commerceURL = system.label.EC_CommerceURLStorefron;
        String testLbl = Label.EC_SSO_Developer;
        system.debug(logginglevel.error,testLbl);
        String startURL = '/'+commerceURL+'/ccrz__MyAccount?cartId=ce51fa60-6192-4cb4-8c29-6b9f5c35a9b8&viewState=viewAccount&portalUser=&store=&cclcl=en_US';
        System.assertEquals(null,EC_CustomLoginRedirectController.getSamlSSOUrl(startURL));
        Test.stopTest();
        
    }    
}