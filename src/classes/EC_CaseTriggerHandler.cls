/* Class Name      :EC_CaseTriggerHandler
* Description      :helper class for EC_CaseTriggerHandler trigger
* Created By       :Venkatesh Paladugu
* Created On       :17-10-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Venkatesh Paladugu      17-10-2019                                   helper class for EC_CaseTriggerHandler trigger
* Sunil Prasad            04.01.2020                                    Added new fields (Case number->RequestID, OrganizationID and SourceSystem to the request
* Graytitude Team           14.09.2020                                  doAssignmentRulesRun - method added to perform assignment rules 
                                                                        on community related cases.
*/
public class EC_CaseTriggerHandler {

  static EC_WebServiceCalloutsLog__c calloutLog;
  static Integration_Log__c integrationLog;

  @SuppressWarnings('all')
  public static EC_CaseTextMyRepToSAP.ESRResponseType doAPICall(String RequestID, String SoldTo, String ShipTo, EC_CaseTextMyRepToSAP.CategoryType Category1, EC_CaseTextMyRepToSAP.CategoryType Category2, EC_CaseTextMyRepToSAP.CategoryType Category3, EC_CaseTextMyRepToSAP.CategoryType Category4, String Desc1, 
    EC_CaseTextMyRepToSAP.ContactType contact, String organizationID, String sourceSystem) {
    String METHOD_NAME = 'doAPICall';
    System.debug('Entering method ' + METHOD_NAME);
    EC_CaseTextMyRepToSAP.TextMyRepPortTypeEndpoint1 callout = new EC_CaseTextMyRepToSAP.TextMyRepPortTypeEndpoint1();
    System.debug('Submit ESR Details - RequestID:'+ RequestID + ' SoldTo' + SoldTo + ' ShipTo' + ShipTo + ' Category1' + Category1 + ' Category2' + Category2
                  + ' Category3' + Category3 + ' Category4' + Category4 + ' Desc1' + Desc1 + ' contact' + contact + ' organizationID' + organizationID + ' sourceSystem' + sourceSystem);
    EC_CaseTextMyRepToSAP.ESRResponseType response = callout.SubmitESR(RequestID, SoldTo, ShipTo, Category1, Category2, Category3, Category4, Desc1, contact, organizationID, sourceSystem);
    calloutLog = callout.logRec;
    System.debug('Submit ESR Response:'+response);
    return response;
  }

  //this method logs the exception in the integration log object
  public static Case updateCaseException(Case newCase,  EC_CaseTextMyRepToSAP.ESRResponseType response,String errorMessage) {
      //update the case status to send failed
      newCase.status = Label.EC_Status_Failed;
      String errMsg = '';
      String responseStatus = '';
      String calloutId = '';
      if(response == null){
        errMsg = errorMessage;
      }else{
        errMsg =  response.message;   
        responseStatus = String.valueOf(response.status);        
      }  
      if(calloutLog != null){
          calloutId = calloutLog.id;
          if(responseStatus == '')
          	responseStatus = calloutLog.EC_Status__c;
      }
      newCase.Integration_Status__c = EC_Constants.SERVICE_REQUEST_INTEGRATION_STATUS_FAIL;

    //update the integration log object    
    Integration_Log__c integraionLogRec = EC_Utility.logIntegrationError(errMsg,'Service Request', 'SFDC_To_TIBCO',
                                           'Case', calloutId, 0, responseStatus, String.valueOf(newCase.caseNumber));
    newCase.Integration_Error_Log__c = integraionLogRec.Id;
    return newCase;
  }

  @future(callout=true) 
  public static void doFutureCallout(List<id> vlist) {
      doCallout(vlist);
  }
    
  @SuppressWarnings('all')
  public static void doCallout(List<id> vlist) {
    System.debug('Inside doCallout: ');    
    List<Case> getCases = [SELECT Id, CaseNumber, Sold_To__c, Ship_To__c, Order_Type__c, Category_1_8__c, Category_1_4__c, Category_2_8__c, Category_2_4__c, Category_3_8__c, Category_3_4__c, Category_4_4__c, Category_4_8__c, Description, SuppliedName, SuppliedEMail, SuppliedPhone
                          FROM Case WHERE Id IN : vList];
    List<Case> updateCase = new List<Case>();
    For (Case newCase : getCases){
      System.debug('Get Cases' + newCase);
      String RequestID = newCase.CaseNumber;
      String SoldTo = newCase.Sold_To__c;
      String ShipTo = newCase.Ship_To__c;
      //if the soldTo and shipTo's have a '/' in the number, then we need to take the second part of integraionLogRec
      if(!String.isBlank(SoldTo) && SoldTo.indexOf('/') != -1)
          SoldTo = SoldTo.substringAfter('/');
      if(!String.isBlank(ShipTo) && ShipTo.indexOf('/') != -1)
          ShipTo = ShipTo.substringAfter('/');

      String desc1 = newCase.Description;
      //limit the description to 80 chars
      if(desc1 != null && desc1 != '' && desc1.length() > EC_Constants.SERVICE_REQUEST_DESC_LENGTH){
        desc1 = desc1.substring(0,EC_Constants.SERVICE_REQUEST_DESC_LENGTH);
      }

      EC_CaseTextMyRepToSAP.CategoryType category1 = new EC_CaseTextMyRepToSAP.CategoryType();
      category1.CodeGroup = newCase.Category_1_8__c;
      category1.Code = newCase.Category_1_4__c;
      category1.Description = '';

      EC_CaseTextMyRepToSAP.CategoryType category2 = new EC_CaseTextMyRepToSAP.CategoryType();
      category2.CodeGroup = newCase.Category_2_8__c;
      category2.Code = newCase.Category_2_4__c;
      category2.Description = '';

      EC_CaseTextMyRepToSAP.CategoryType category3 = new EC_CaseTextMyRepToSAP.CategoryType();
      category3.CodeGroup = newCase.Category_3_8__c;  
      category3.Code = newCase.Category_3_4__c;
      category3.Description = '';

      EC_CaseTextMyRepToSAP.CategoryType category4 = new EC_CaseTextMyRepToSAP.CategoryType();
      category4.CodeGroup = newCase.Category_4_8__c;
      category4.Code = newCase.Category_4_4__c;
      category4.Description = '';

      EC_CaseTextMyRepToSAP.ContactType contact = new EC_CaseTextMyRepToSAP.ContactType();
      contact.ContactFullName = newCase.SuppliedName;
      contact.ContactPhone = newCase.SuppliedPhone;
      contact.ContactEMail = newCase.SuppliedEMail;

      //OrganizationID
      String organizationID = UserInfo.getOrganizationId();
      //limit the organizationID to 15 chars
      if(organizationID != null && organizationID != '' && organizationID.length() > EC_Constants.ORGANIZATION_ID_15_CHARS_LENGTH){
        organizationID = organizationID.substring(0,EC_Constants.ORGANIZATION_ID_15_CHARS_LENGTH);
      }

      //SourceSystem
      String sourceSystem = Global_Static__c.getValues('Source_System').value__c;

      try {
        EC_CaseTextMyRepToSAP.ESRResponseType ESRResponse = doAPICall(RequestID, SoldTo, ShipTo, Category1, Category2, Category3, Category4, desc1, contact, 
        organizationID, sourceSystem);
        if(ESRResponse != null){
            if(ESRResponse.status) {
              newCase.status = Label.EC_Status_Sent;
              newCase.integration_Status__c = EC_Constants.SERVICE_REQUEST_INTEGRATION_STATUS;
              //check if a record exists in the integration log for a request that failed earlier and if so, update the count and status
              EC_Utility.integrationLogCheck(RequestID);
            } 
        }else{
            newCase = updateCaseException(newCase,null, calloutLog.EC_ErrorMessage__c);
        }
      } catch (Exception e){
        newCase = updateCaseException(newCase,null, calloutLog.EC_ErrorMessage__c);
      } finally{
        updateCase.add(newCase);
      }
    }
    update updateCase;
  }  

  public static void retryServiceRequestSubmit(List<id> vlist){   
    System.debug('Inside retryServiceRequestSubmit: '); 
    doCallout(vlist);     
    }
    //To perform assignment rules on Community related cases
    public static void doAssignmentRulesRun(map<id,case> cases){
        list<case> updatedCases = new list<case>();
        
        //Run assignment rules for "Support" record type of case and If it's created from Community.
        for(Case c:[select id,ownerid from case where id in:cases.keySet() and recordtype.name='Support' and Run_Assignment_Rule__c=true]){
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            c.setOptions(dmlOpts);
            updatedCases.add(c);     
        }
        if(!updatedCases.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
            update updatedCases;
        }
  }
}