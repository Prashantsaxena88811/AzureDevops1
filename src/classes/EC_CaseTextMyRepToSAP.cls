/*********************************************************************************
Class Name      : EC_CaseTextMyRepToSAP
Description     : This class is used for the Webservice call for TIBCO SAP
Created By      : Venkatesh Paladugu
Created Date    : 17-10-2019
Modification Log:
---------------------------------------------------------------------------------- 
Developer                 Date                   Description
----------------------------------------------------------------------------------            
Venkatesh Paladugu      17-10-2019             Initial Version 
Sunil Prasad            04.01.2020             Added new fields (Case number->RequestID, OrganizationID and SourceSystem to the request
*********************************************************************************/ 

public class EC_CaseTextMyRepToSAP {
    @SuppressWarnings('all')
    public class ESRRequestType {
        public String RequestID;
        public String SoldToPartnerNo;
        public String ShipToPartnerNo;       
        public EC_CaseTextMyRepToSAP.CategoryType Category1;
        public EC_CaseTextMyRepToSAP.CategoryType Category2;
        public EC_CaseTextMyRepToSAP.CategoryType Category3;
        public EC_CaseTextMyRepToSAP.CategoryType Category4;
        public String FreeText;
        public EC_CaseTextMyRepToSAP.ContactType Contact;
        public String OrganizationID;
        public String SourceSystem;
        private String[] RequestID_type_info = new String[]{'RequestID','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] SoldToPartnerNo_type_info = new String[]{'SoldToPartnerNo','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] ShipToPartnerNo_type_info = new String[]{'ShipToPartnerNo','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] Category1_type_info = new String[]{'Category1','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] Category2_type_info = new String[]{'Category2','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] Category3_type_info = new String[]{'Category3','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] Category4_type_info = new String[]{'Category4','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] FreeText_type_info = new String[]{'FreeText','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] Contact_type_info = new String[]{'Contact','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] OrganizationID_type_info = new String[]{'OrganizationID','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] SourceSystem_type_info = new String[]{'SourceSystem','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};       
        private String[] apex_schema_type_info = new String[]{'http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'RequestID','SoldToPartnerNo','ShipToPartnerNo','Category1','Category2','Category3','Category4','FreeText','Contact','OrganizationID','SourceSystem'};
    }
    public class ESRResponseType {
        public Boolean status;
        public String message;
        private String[] status_type_info = new String[]{'status','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] message_type_info = new String[]{'message','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'status','message'};
    }
    public class ContactType {
        public String ContactFullName;
        public String ContactPhone;
        public String ContactEmail;
        private String[] ContactFullName_type_info = new String[]{'ContactFullName','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] ContactPhone_type_info = new String[]{'ContactPhone','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] ContactEmail_type_info = new String[]{'ContactEmail','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'ContactFullName','ContactPhone','ContactEmail'};
    }
    public class CategoryType {
        public String CodeGroup;
        public String Code;
        public String Description;
        private String[] CodeGroup_type_info = new String[]{'CodeGroup','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] Code_type_info = new String[]{'Code','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'1','1','false'};
        private String[] Description_type_info = new String[]{'Description','http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'CodeGroup','Code','Description'};
    }
    @SuppressWarnings('all')
    public class TextMyRepPortTypeEndpoint1 {
        public String endpoint_x = SAP_TIBCO_URL__c.getValues('Destination URL').TIBCO_End_Point_Url__c;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://ecolab.com/https/services/esr/textmyrep', 'EC_CaseTextMyRepToSAP', 'http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd', 'EC_CaseTextMyRepToSAP'};
        public EC_WebServiceCalloutsLog__c logRec;

        public EC_CaseTextMyRepToSAP.ESRResponseType submitESR(String RequestID,String SoldToPartnerNo,String ShipToPartnerNo,EC_CaseTextMyRepToSAP.CategoryType Category1,EC_CaseTextMyRepToSAP.CategoryType Category2,EC_CaseTextMyRepToSAP.CategoryType Category3,EC_CaseTextMyRepToSAP.CategoryType Category4,String FreeText,EC_CaseTextMyRepToSAP.ContactType Contact, String OrganizationID,String SourceSystem) {
            EC_CaseTextMyRepToSAP.ESRRequestType request_x = new EC_CaseTextMyRepToSAP.ESRRequestType();
            request_x.RequestID = RequestID;
            request_x.SoldToPartnerNo = SoldToPartnerNo;
            request_x.ShipToPartnerNo = ShipToPartnerNo;
            request_x.Category1 = Category1;
            request_x.Category2 = Category2;
            request_x.Category3 = Category3;
            request_x.Category4 = Category4;
            request_x.FreeText = FreeText;
            request_x.OrganizationID = OrganizationID;
            request_x.SourceSystem = SourceSystem;
            request_x.Contact = Contact;
            System.debug('Service Request submit to Tibco Request: ' + String.valueOf(request_x));
            EC_CaseTextMyRepToSAP.ESRResponseType response_x;
            Map<String, EC_CaseTextMyRepToSAP.ESRResponseType> response_map_x = new Map<String, EC_CaseTextMyRepToSAP.ESRResponseType>();
            response_map_x.put('response_x', response_x);
            try{
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '/CloudServices/Inbound/SubmitESRService.serviceagent/TextMyRepPortTypeEndpoint1/submitESR',
              'http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',
              'ESRRequest',
              'http://www.tibco.com/schemas/CloudCraze_Integration/CloudServices/SharedResources/schemas/TextMyRep/Schema.xsd',
              'ESRResponse',
              'EC_CaseTextMyRepToSAP.ESRResponseType'}
            );
            }catch (Exception e){
                //catch  service call exceptions and log them in the EC_WebServiceCalloutsLog__c
                System.debug('Exception when calling Tibco for Service Request Submit' + e.getMessage());
                logRec = EC_Utility.logCallouts(EC_Constants.SERVICE_REQUEST_SFDC_TO_TIBCO,String.valueOf(request_x), e.getMessage(), e.getMessage(), '0');
                return null;
            }
            response_x = response_map_x.get('response_x');
            //log the callout            
            Boolean status = response_x.status;
            String result = '';
            if(!status){
                System.debug('An error response recieved from Tibco for Service Request Submit' + response_x.message);
                logRec = EC_Utility.logCallouts(EC_Constants.SERVICE_REQUEST_SFDC_TO_TIBCO,String.valueOf(request_x), response_x.message, response_x.message, String.valueOf(status));
                return null;
            }else{
                logRec = EC_Utility.logCallouts(EC_Constants.SERVICE_REQUEST_SFDC_TO_TIBCO, String.valueOf(request_x), response_x.message, '', String.valueOf(status)); 
            }          
            return response_x;
        }
    } 
}