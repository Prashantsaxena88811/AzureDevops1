/* Class Name       :EC_UtilityLoggerTest
 * Description      :Test Class for EC_UtilityLoggerTest
 * Created By       :Shruti Sinha
 * Created On       :08-07-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Shruti Sinha        08-07-2019                                  Test Class for EC_UtilityLoggerTest
 *
 */

@isTest
public class EC_UtilityLoggerTest {

   public String Message{get;set;}
   public String Type{get;set;}
   public String SubType{get;set;}
    @isTest
    public static void logInfoTest(){
        EC_UtilityLogger.logInfo('message');
        EC_UtilityLogger.logInfo('message',true);
        EC_UtilityLogger.logInfo('message',false);
        EC_UtilityLogger.calloutErrorResponse('statusCode','className','methodName','status');
        List<Id> slId= new List<Id>();
        slId.add('a1F5C000000aeHE');
        EC_UtilityLogger.logInfo('message','className', 'methodName', slId,true);
        ccrz__E_Product__c cp=new ccrz__E_Product__c();
        EC_UtilityLogger.logInfo(cp, false);

        EC_UtilityLogger.createLogSync('Message','Type','SubType','10', 'stackTrace',
                                  'className', 'methodName', 'salesforceRecordIds',
                                  'govLimitKpi','callingContext', 'contextUserId');
        EC_UtilityLogger.createLogSync('Message','Type','SubType','10.1', 'stackTrace',
                                  'className', 'methodName', 'salesforceRecordIds',
                                  'govLimitKpi','callingContext', 'contextUserId');

        Test.startTest();

        EC_LogTypes__mdt metadatarecord = new EC_LogTypes__mdt();
        metadatarecord.EC_WriteApexLogsSynchronously__c = false;
        metadatarecord.EC_write_Apex_Logs_Asynchronously__c = true;

        EC_CustomMetadataDAOTest.setMetadata(
            'SELECT EC_WriteApexLogsSynchronously__c,EC_write_Apex_Logs_Asynchronously__c FROM EC_LogTypes__mdt',
             metadatarecord
        );

        try{
            integer i;
            i=5;
            integer j=i/0;

        }
        catch(Exception e)
        {

            EC_UtilityLogger.logInfo(e);
            EC_UtilityLogger.logException(e,'abc','method',false,null,null);
            EC_UtilityLogger.logException(e);
            EC_UtilityLogger.logException(e,false);

        }
        List<Id> salesforceRecId= new List<Id>();
        salesforceRecId.add('a1F5C000000aeHE');
        EC_UtilityLogger.LogEvent('eventName', 'message',salesforceRecId, 'contextId');
        EC_UtilityLogger es= new  EC_UtilityLogger();
        EC_UtilityLogger.ServiceLog esl = new EC_UtilityLogger.ServiceLog('endpointUrl','serviceName', 'httpMethod', 'requestBody', 'responseCode','responseBody');
       /// es.Log log1=new es.Log();
        es.logServiceCall(esl);
        es.logCallouts(esl);

        Test.stopTest();
    }
/***************************************************************************************************************************************
Method Name : logInfoTest1
Description : to create log Test
Return type : Void
Author      : Shruti Sinha
*************************************************************************************************************************************/

    @isTest
        public static void logInfoTest1(){
             Test.startTest();

        EC_LogTypes__mdt metadatarecord = new EC_LogTypes__mdt();
        metadatarecord.EC_WriteApexLogsSynchronously__c = true;
        metadatarecord.EC_write_Apex_Logs_Asynchronously__c = false;

        EC_CustomMetadataDAOTest.setMetadata(
            'SELECT EC_WriteApexLogsSynchronously__c,EC_write_Apex_Logs_Asynchronously__c FROM EC_LogTypes__mdt',
             metadatarecord
        );
        }

/***************************************************************************************************************************************
Method Name : logInfoTest2
Description : to create log Test
Return type : Void
Author      : Shruti Sinha
*************************************************************************************************************************************/
    @isTest
        public static void logInfoTest2(){
             Test.startTest();

        EC_LogTypes__mdt metadatarecord = new EC_LogTypes__mdt();
        metadatarecord.EC_WriteApexLogsSynchronously__c = false;
        metadatarecord.EC_write_Apex_Logs_Asynchronously__c = false;

        EC_CustomMetadataDAOTest.setMetadata(
            'SELECT EC_WriteApexLogsSynchronously__c,EC_write_Apex_Logs_Asynchronously__c FROM EC_LogTypes__mdt',
             metadatarecord
        );
        }

/***************************************************************************************************************************************
Method Name : logDmlError
Description : to create log Test
Return type : Void
Author      : Shruti Sinha
*************************************************************************************************************************************/

    @isTest
    public static void logDmlError(){
    contact con = new contact();
      Database.SaveResult sr = Database.insert(con,false);
         if(!sr.isSuccess()){
                for(Database.Error  err: sr.getErrors()) {
             EC_UtilityLogger.logException(null,'classname','methodname',true,err,'');
                }
            }
    }


}