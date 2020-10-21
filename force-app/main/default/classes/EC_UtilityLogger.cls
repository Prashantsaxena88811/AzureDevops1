/* Class Name       :EC_UtilityLogger
 * Description      :Class for creating logs
 * Created By       :Shruti Sinha
 * Created On       :08-07-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Shruti Sinha        08-07-2019                                  Class for creating logs
 *
 */

public class EC_UtilityLogger {
   private virtual class Log {
   public String Message;
   public String Type;
   public String SubType;

   }

   public class ServiceLog extends Log {
   public String EndpointUrl;
   public String HttpMethod;
   public String RequestBody;
   public String ResponseCode;

   public ServiceLog(String endpointUrl, String serviceName, String httpMethod, String requestBody, String responseCode, String responseBody) {
        this.Type = 'ServiceLog';
        this.Message = responseBody;
        this.SubType = serviceName;
        this.EndpointUrl = endpointUrl;
        this.HttpMethod = httpMethod;
        this.RequestBody = requestBody;
        this.ResponseCode = responseCode;
   }


   }

/***************************************************************************************************************************************
Method Name : createLog
Description : to create log
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

    private static void createLog(String message, String type, String subType, String lineNumber, String stackTrace,
                              String className, String methodName, string salesforceRecordIds) {


    EC_LogTypes__mdt logTypes = new EC_CustomMetadataDAO().getCustomMetadataRecords('SELECT EC_WriteApexLogsSynchronously__c,EC_write_Apex_Logs_Asynchronously__c FROM EC_LogTypes__mdt');
    Boolean writeApexLogs = logTypes.EC_WriteApexLogsSynchronously__c;
    Boolean writeApexLogsAsynchronously = logTypes.EC_write_Apex_Logs_Asynchronously__c;

	string contextUserId = '';
	if (ApexPages.currentPage() != null || Trigger.isExecuting ||System.isFuture() || System.isBatch()) {
		contextUserId = UserInfo.getUserId();
	}

	if(writeApexLogs) {
		//system.debug('Where am : 1');
		createLogSync(message, type, subType, lineNumber, stackTrace,
		              className, methodName, salesforceRecordIds, EC_Utility.getGovLimitKpi(),
		              EC_Utility.getCallingContext(), contextUserId);
	}
	else if(writeApexLogsAsynchronously) {
		if(!System.isFuture() && !System.isBatch()) {

			createLogAsync(message, type, subType, lineNumber, stackTrace,
			               className, methodName, salesforceRecordIds,
			               EC_Utility.getGovLimitKpi(),
			               EC_Utility.getCallingContext(), contextUserId);
		}
		else {

			createLogSync(message, type, subType, lineNumber, stackTrace,className, methodName, salesforceRecordIds,EC_Utility.getGovLimitKpi(), EC_Utility.getCallingContext(), contextUserId);
		}
	}


}

/***************************************************************************************************************************************
Method Name : createLogAsync
Description : to create log async
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

@Future
private static void createLogAsync(String message, String type, String subType, String lineNumber, String stackTrace,
                                   String className, String methodName, string salesforceRecordIds,
                                   string govLimitKpi, string callingContext, string contextUserId) {

	createLogSync(message, type, subType, lineNumber, stackTrace,
	              className, methodName, salesforceRecordIds,
	              govLimitKpi, callingContext, contextUserId);

}
/***************************************************************************************************************************************
Method Name : createLogAsync
Description : to create log async
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

@TestVisible private static void createLogSync(String message, String type, String subType, String lineNumber, String stackTrace,
                                  String className, String methodName, string salesforceRecordIds,
                                  string govLimitKpi, string callingContext, string contextUserId) {
	try {
		/*
		   Ensure that we're well within the Governor Limits.
		   The creation of the Log shouldn't disturb the execution
		   of that Apex Class that utilizes this method to
		   create a log.
		 */
		if ((Limits.getDMLRows() < Limits.getLimitDMLRows()) &&
		    (Limits.getDMLStatements() < Limits.getLimitDMLStatements())) {
			EC_ApexException__c apexDebuglog = new EC_ApexException__c();


			apexDebuglog.EC_Class_Name__c = className;
			apexDebuglog.EC_Exception_Type__c = subType;
			apexDebuglog.EC_Error_Message__c = message;
			apexDebuglog.EC_Stack_Trace__c = stackTrace;
			apexDebuglog.EC_Calling_Context__c = callingContext;
			apexDebuglog.EC_Method_Name__c = methodName;
			apexDebuglog.Name = 'Ecolab CloudCraze-'+type;
			apexDebuglog.EC_Trigger__c = stackTrace;
			apexDebuglog.EC_GovLimitKpi__c = govLimitKpi;
			if(!EC_Utility.isBlankOrEmpty(lineNumber)) {
				apexDebuglog.EC_Line_Number__c = Integer.valueOf(lineNumber);
			}
			if (!EC_Utility.isBlankOrEmpty(contextUserId)) {
				apexDebuglog.EC_Reporting_User__c = contextUserId;
			}
			if (!EC_Utility.isBlankOrEmpty(salesforceRecordIds)) {
				apexDebuglog.EC_Note__c = salesforceRecordIds;
			}

			Database.SaveResult sr = Database.insert(apexDebuglog, FALSE);
		}
		else {
			ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EXCEPTION', 'The Governor Limits have already been exhausted and hence failed to create a Log!');
			System.debug(LoggingLevel.Error, 'The Governor Limits have already been exhausted and hence failed to create a Log!');
		}
	}
	catch(Exception ex) {
		String messageText = 'Something fatal has occurred and hence failed to create a Log.';
		String fullMessage = String.format('Message: {0}, Line Number: {1}, Stack Trace: {2}',
		                                   new String[] { messageText, String.valueOf(ex.getLineNumber()), ex.getStackTraceString()});
		System.debug(LoggingLevel.Error,fullMessage);
		ccrz.ccLog.log (System.LoggingLevel.DEBUG, 'EXCEPTION', fullMessage);
	}

}

/***************************************************************************************************************************************
Method Name : logException
Description : to store log exception
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

public static void logException(Exception ex) {
	logException(ex, true);
}

/***************************************************************************************************************************************
Method Name : logException
Description : to store log exception
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

public static void logException(Exception ex, boolean skipObjectLogs)
{
	logException(ex, skipObjectLogs, '');
}

/***************************************************************************************************************************************
Method Name : logException
Description : to store log exception
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

public static void logException(Exception ex, boolean skipObjectLogs, string contextId) {


	string fullMessage = string.format('Message: {0}, ExceptionType:{1}, LineNumber:{2}, StackTrace: {3}',
	                                   new List<String> {
			ex.getMessage(), ex.getTypeName(), (ex.getLineNumber() != null ? string.valueOf(ex.getLineNumber()) : ''), ex.getStackTraceString()
		});
	if (ApexPages.currentPage() != null  || (ccrz.cc_CallContext.isRemoteCall)) {
		ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'EC_EXCEPTION', fullMessage);
	}
	//Add to debug logs
	System.debug(LoggingLevel.Error,'EC_EXCEPTION:' + fullMessage);
	//Add to Apex Logs
	if(!skipObjectLogs) {
		createLog(ex.getMessage(), 'Exception', ex.getTypeName(), (ex.getLineNumber() != null ? string.valueOf(ex.getLineNumber()) : ''),
		          ex.getStackTraceString(), EC_Utility.isBlankOrEmpty(contextId) ? '' : contextId, '', '');
	}
}

/***************************************************************************************************************************************
Method Name : logServiceCall
Description : to store log service Call
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

public void logServiceCall(ServiceLog serviceLog) {

        //Add to cloudcraze logs
        if (ApexPages.currentPage() != null || (ccrz.cc_CallContext.isRemoteCall)) {
                ccrz.ccLog.log(System.LoggingLevel.INFO, 'EC_SERVICELOG', 'Service Call Invocation : ' + serviceLog.EndpointUrl);
        }
        //Add to debug logs
        System.debug(LoggingLevel.Debug,serviceLog);

        //Add to Apex Logs
        createLog(serviceLog.Message, serviceLog.Type, serviceLog.SubType, '', '', '', '', '');
   }

public static void logInfo(string message) {
	logInfo(message, '', '', null, 'Generic', true);
}

public static void logInfo(string message, boolean skipObjectLogs) {
	logInfo(message, '', '', null, 'Generic', skipObjectLogs);
}
public static void logInfo(string message, string className, string methodName,
                            List<Id> salesforceRecordIds,boolean skipObjectLogs) {
	logInfo(message, className, methodName, salesforceRecordIds, 'Generic', skipObjectLogs);
}

public static void logInfo(Object logObject) {
	logInfo(logObject, true);
}

/***************************************************************************************************************************************
Method Name : logInfo
Description : to store log info
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

public static void logInfo(Object logObject, boolean skipObjectLogs) {

	if (ApexPages.currentPage() != null || (ccrz.cc_CallContext.isRemoteCall)) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'EC_INFO', logObject);
	}
	//Add to debug logs
	System.debug(LoggingLevel.Debug, logObject);
	//Add to Apex Logs
	if(!skipObjectLogs) {
		String message = JSON.serialize(logObject);
		//Info info = new Info(message, '', '', '', '');
		createLog(message, 'Info', '', '', '', '', '', '');
	}
}

/***************************************************************************************************************************************
Method Name : logInfo
Description : to store log info
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

private static void logInfo(string message, string className, string methodName,
                            List<Id> salesforceRecordIds, string eventName,boolean skipObjectLogs) {

	string concatenatedRecordIds = '';
	string logMessage = 'Message : ' + message;

	if (!EC_Utility.isBlankOrEmpty(className)) {
		logMessage += ' \n ClassName : ' + className;
	}

	if (!EC_Utility.isBlankOrEmpty(methodName)) {
		logMessage += ' \n MethodName : ' + methodName;
	}

	if (salesforceRecordIds != null && salesforceRecordIds.size() > 0) {
		concatenatedRecordIds = String.join(salesforceRecordIds, ',');
		logMessage += ' \n RecordIds : ' + concatenatedRecordIds;
	}
	//Add to cloudcraze logs
	if (ApexPages.currentPage() != null || (ccrz.cc_CallContext.isRemoteCall)) {
		ccrz.ccLog.log(System.LoggingLevel.INFO, 'EC_INFO', logMessage);
	}
	//Add to debug logs
	System.debug(LoggingLevel.Debug,logMessage);
	//Add to Apex Logs

	if(!skipObjectLogs) {
		//Info info = new Info(message, eventName, className, methodName, concatenatedRecordIds);
		createLog(message, 'Info', eventName, '', '', className, methodName, concatenatedRecordIds);
	}
}

/***************************************************************************************************************************************
Method Name : LogEvent
Description : to store log event
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

public static void LogEvent(string eventName, string message, List<Id> salesforceRecordIds, string contextId) {

	string concatenatedRecordIds = '';
	if (salesforceRecordIds != null && salesforceRecordIds.size() > 0) {
		concatenatedRecordIds = String.join(salesforceRecordIds, ',');
	}
	//logInfo(message, contextId, '', salesforceRecordIds, eventName, false);
	createLog(message, 'Event', '', '', '', contextId, eventName, concatenatedRecordIds);
}
/***************************************************************************************************************************************
Method Name : logException
Description : to store log exception
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static void logException(Exception ex, String className, String methodName,Boolean dmlError ,Database.Error dmlErrTrace,String recordId){

        if(!dmlError){
        createLog(ex.getMessage(), ex.getTypeName(),'', String.valueOf(ex.getLineNumber()), '',
                              className, methodName,'');
        }else{
            createLog(dmlErrTrace.getMessage() ,'','','',String.valueOf(dmlErrTrace.getFields()),
                              className, methodName,'');

        }


    }

	/***************************************************************************************************************************************
Method Name : calloutErrorResponse
Description : to store callount error response
Return type : Void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static void calloutErrorResponse(String statusCode,String className, String methodName,String status){
        createLog(statusCode+''+status ,'','','','',
                              className, methodName,'');

    }

	/***************************************************************************************************************************************
Method Name : logCallouts
Description : to store log service Call
Return type : Void
Author      : 
*************************************************************************************************************************************/

public void logCallouts(ServiceLog serviceLog) {

        //Add to cloudcraze logs
        if (ApexPages.currentPage() != null || (ccrz.cc_CallContext.isRemoteCall)) {
                ccrz.ccLog.log(System.LoggingLevel.INFO, 'EC_SERVICELOG', 'Service Call Invocation : ' + serviceLog.EndpointUrl);
        }
        //Add to debug logs
        System.debug(LoggingLevel.Debug,serviceLog);

        //Add to Apex Logs
        createLog(serviceLog.Message, serviceLog.Type, serviceLog.SubType, '', '', '', '', '');
   }


}