global without sharing class EC_ccServicePLI extends ccrz.ccServicePLI{

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData)
    {
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',Custom_Factor__c,Custom_PricingUOM__c,Custom_UnitPrice__c' ;
        return new Map <String,Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
    }
}