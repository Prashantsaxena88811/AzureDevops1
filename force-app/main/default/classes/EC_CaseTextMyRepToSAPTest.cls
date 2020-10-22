@isTest
public class EC_CaseTextMyRepToSAPTest {
    static testMethod void test_serviceInput(){
        EC_CaseTextMyRepToSAP.CategoryType category1 = new EC_CaseTextMyRepToSAP.CategoryType();
        category1.CodeGroup = '23eser';
        category1.Code = 'wewdsad';
        category1.Description = '';

        EC_CaseTextMyRepToSAP.CategoryType category2 = new EC_CaseTextMyRepToSAP.CategoryType();
        category1.CodeGroup = '2w3ser';
        category1.Code = 'wewdsad';
        category1.Description = '';

        EC_CaseTextMyRepToSAP.CategoryType category3 = new EC_CaseTextMyRepToSAP.CategoryType();
        category1.CodeGroup = 'q23ser';
        category1.Code = 'wewdsad';
        category1.Description = '';

        EC_CaseTextMyRepToSAP.CategoryType category4 = new EC_CaseTextMyRepToSAP.CategoryType();
        category1.CodeGroup = '23swer';
        category1.Code = 'wewdsad';
        category1.Description = '';

        EC_CaseTextMyRepToSAP.ContactType contact = new EC_CaseTextMyRepToSAP.ContactType();
        contact.ContactFullName = 'testname';
        contact.ContactPhone = '9848832452';
        contact.ContactEMail = 'test@test.com';
        
        EC_CaseTextMyRepToSAP.ESRRequestType requestType = new EC_CaseTextMyRepToSAP.ESRRequestType();
        requestType.RequestID = '1233342';
        requestType.SoldToPartnerNo = '234567';
        requestType.ShipToPartnerNo = '334444';
        requestType.Category1 = category1;
        requestType.Category2 = category2;
        requestType.Category3 = category3;
        requestType.Category4 = category4;
        requestType.FreeText = 'FreeTextmessgae';
        requestType.OrganizationID = '12121212';
        requestType.SourceSystem = 'Connect';

        SAP_TIBCO_URL__c settings = new SAP_TIBCO_URL__c();
        settings.Name = 'Destination URL';
        settings.TIBCO_End_Point_Url__c = '__https://local'; 
        insert settings;
        
        EC_CaseTextMyRepToSAP.TextMyRepPortTypeEndpoint1 serviceMethod = new EC_CaseTextMyRepToSAP.TextMyRepPortTypeEndpoint1();
        serviceMethod.submitESR('1233342','12345','34565',category1,category2,category3,category4,'testmessage',contact, '12121212', 'SFDC_ESR');
    }
}