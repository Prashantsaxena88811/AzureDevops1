/********************************************************************************************************
* @Class Name    EC_OrderServiceOutput
* @description   Outputclass for Tibco Api, Generated using WSDL
* @Created By -  Ravindra Singh  
* @Created On -  2019-08-25
* *********************************************************************************************************

 * Modification Log:  
 * ------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID             Description 
 * ------------------------------------------------------------------------------------------------------
 * Ravindra               2019-08-25                                   Initial version
 *********************************************************************************************************/ 
public class EC_OrderServiceOutput {
    public class OrderOutput_element {
        public Boolean Status;
        public String Message;
        private String[] Status_type_info = new String[]{'Status','http://www.ecolab.com/services/schemas/OrderOutput',null,'1','1','false'};
        private String[] Message_type_info = new String[]{'Message','http://www.ecolab.com/services/schemas/OrderOutput',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ecolab.com/services/schemas/OrderOutput','false','false'};
        private String[] field_order_type_info = new String[]{'Status','Message'};
    }
}