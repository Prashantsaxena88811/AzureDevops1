@istest
public class CaseUpdateRestResourceTest {
    public static void createCase(){
        Id supRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case newTestC = new Case();
        newTestC.RecordTypeId = supRecordTypeId;
        newTestC.Origin = 'Portal';
        newTestC.Order_Type__c = 'ZESR';
        newTestC.Sold_To__c = '2345';
        newTestC.Ship_To__c = '2312';
        newTestC.SuppliedName = 'testname';
        newTestC.SuppliedPhone = '2343454556';
        newTestC.SuppliedEMail = 'test@test.com'; 
        newTestC.Subject = 'Pest Portal - Request Service Visit';
        newTestC.Description = 'SFDC to Tibco Test';
        newTestC.External_Id__c = 'CS000001';
        newTestC.Category__c= 'Login';
        newTestC.Sub_Category__c = 'Forgot Username';
        newTestC.Resolution_Category__c = 'No Workaround Applied';
        newTestC.Resolution_Description__c = 'test';
        insert newTestC;
    }
    @istest
    public static void doPost(){
        createCase();
        String caseNumber = [select casenumber from case limit 1].casenumber;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/caseapi';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        try{
            CaseUpdateRestResource.doPatch('',null,null,null,null,null);
            CaseUpdateRestResource.doPatch('11633910071',null,null,null,null,null);
            CaseUpdateRestResource.doPatch(caseNumber,null,null,null,null,null);
            CaseUpdateRestResource.doPatch(caseNumber,null,null,null,null,'Group');
            string actual = [select id,Integration_Error_Log__c,Integration_Status__c from case where CaseNumber=:caseNumber limit 1].Integration_Error_Log__c;
        	system.assertEquals(true, actual!=null);
        }
        catch(exception e){
             system.debug('-------Error Message-------'+e.getMessage());
        }
    }
    
    @istest
    public static void doPostResolved(){
        createCase();
        String caseNumber = [select casenumber from case limit 1].casenumber;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/caseapi';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        try{
            CaseUpdateRestResource.doPatch(caseNumber,'Resolved','test description',null,null,null);
            CaseUpdateRestResource.doPatch(caseNumber,'Resolved','test description',null,null,'Group');
            CaseUpdateRestResource.doPatch(caseNumber,'Resolved','test description',null,null,null);
            CaseUpdateRestResource.doPatch(caseNumber,null,null,'unResolved','test description','Agents');
            string actual = [select id,External_Id__c,Integration_Status__c from case where CaseNumber=:caseNumber limit 1].Integration_Status__c;
        	system.assertEquals('Received Resolved', actual);
        }
        catch(exception e){
             system.debug('-------Error Message-------'+e.getMessage());
        }
    }
    @istest
    public static void doPostResolvedWithoutResolutionNotes(){
        createCase();
        String caseNumber = [select casenumber from case limit 1].casenumber;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/caseapi';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        try{
            CaseUpdateRestResource.doPatch(caseNumber,'Resolved',null,null,null,null);
            string actual = [select id,Integration_Error_Log__c,Integration_Status__c from case where CaseNumber=:caseNumber limit 1].Integration_Error_Log__c;
        	system.assertEquals(true, actual!=null);
        }
        catch(exception e){
             system.debug('-------Error Message-------'+e.getMessage());
        }
    }
    @istest
    public static void doPostUnResolved(){
        createCase();
        String caseNumber = [select casenumber from case limit 1].casenumber;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/caseapi';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        try{
            CaseUpdateRestResource.doPatch(caseNumber,null,null,'unResolved','test description','L3_Agents');
            CaseUpdateRestResource.doPatch(caseNumber,'unResolved',null,'unResolved','test description',null);
            string actual = [select id,owner.name from case where CaseNumber=:caseNumber limit 1].Integration_Error_Log__c;
        	system.assertEquals('L3_Agents', actual);
        }
        catch(exception e){
             system.debug('-------Error Message-------'+e.getMessage());
        }
    }
    @istest
    public static void doPostException(){
        Id supRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case newTestC = new Case();
        newTestC.RecordTypeId = supRecordTypeId;
        newTestC.Origin = 'Portal';
        newTestC.Order_Type__c = 'ZESR';
        newTestC.Sold_To__c = '2345';
        newTestC.Ship_To__c = '2312';
        newTestC.SuppliedName = 'testname';
        newTestC.SuppliedPhone = '2343454556';
        newTestC.SuppliedEMail = 'test@test.com'; 
        newTestC.Subject = 'Pest Portal - Request Service Visit';
        newTestC.Description = 'SFDC to Tibco Test';
        newTestC.External_Id__c = 'CS000001';
        newTestC.Category__c= 'Login';
        newTestC.Sub_Category__c = 'Forgot Username';
        newTestC.Resolution_Category__c = 'No Workaround Applied';
        newTestC.Resolution_Description__c = 'test';
        newTestC.status = 'Closed';
        insert newTestC;
        String caseNumber = [select casenumber from case where id=:newTestC.Id limit 1].casenumber;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/caseapi';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        
        RestContext.request = req;
        RestContext.response= res;
        
        try{
            CaseUpdateRestResource.doPatch(caseNumber,'Resolved','test description',null,null,null);
            string actual = [select id,Integration_Error_Log__c,Integration_Status__c from case where CaseNumber=:caseNumber limit 1].Integration_Error_Log__c;
        	system.assertEquals(true, actual!=null);
        }
        catch(exception e){
            system.debug('-------Error Message-------'+e.getMessage());
        }
    }
}