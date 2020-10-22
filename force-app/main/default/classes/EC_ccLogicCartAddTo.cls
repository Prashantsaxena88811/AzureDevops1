/* Class Name    : EC_ccLogicCartAddTo
 * Description      : Class to extend the Cloudcraze Logic Class ccLogicCartAddTo
 * Created By       :Viraj  
 * Created On       :2019-Nov-04
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                 2019-Nov-04       Tech-Debt         Created the class   
 *
 */
global with sharing class EC_ccLogicCartAddTo extends ccrz.ccLogicCartAddTo{
     /***************************************************************************************************************************************
  Method Name : processInputData
  Description : prefixes the sku entered in the quick order with the source name
  Return type : Returns Map<String,Object>
 **************************************************************************************************************************************/
    global override  Map<String, Object> processInputData(Map<String, Object> inputData){
        ccrz.ccLog.log('inputdata1234' + inputdata);
        if(inputData.get(ccrz.ccApiCart.LINE_DATA) instanceof List<ccrz.ccApiCart.LineData>){
            List<ccrz.ccApiCart.LineData> lineData = (List<ccrz.ccApiCart.LineData>)inputData.get(ccrz.ccApiCart.LINE_DATA);
            List<String> displaySKUs = new List<String>();
            Map<String,String> skuMap = new Map<String,String>();
            for(ccrz.ccApiCart.LineData lineDataItem : lineData){
                String displaySKU = lineDataItem.sku;
                if(!displaySKU.contains('/')){
                    displaySKUs.add('%' + displaySKU);
                }
            }
            if(displaySKUs.size()>0){
                List<ccrz__E_ProductIndex__c> prodList = [SELECT ccrz__SKU__c from ccrz__E_ProductIndex__c where ccrz__SKU__c like :displaySKUs];
                for(ccrz__E_ProductIndex__c prodInd : prodList){
                    if(!prodInd.ccrz__SKU__c.split('/')[0].equals(prodInd.ccrz__SKU__c)){
                        skuMap.put(prodInd.ccrz__SKU__c.split('/')[1],prodInd.ccrz__SKU__c);
                    }
                }
                for(ccrz.ccApiCart.LineData lineDataItem : lineData){
                    String displaySKU = lineDataItem.sku;
                    if(!displaySKU.contains('/') && skuMap.containsKey(displaySKU)){
                        lineDataItem.sku = skuMap.get(displaySKU);
                    }
                }
            }
            inputData.put(ccrz.ccApiCart.LINE_DATA, lineData);
            Map<String, Object> retData = super.processInputData(inputdata);
            /*for(Object key : ((List<Object>)retData.get('lineData'))){
                ccrz.ccLog.log('inputdata1234retDatakey' + key);
                //ccrz.ccLog.log('inputdata1234retDatavalue' + retData.get(key));
            }*/
            ccrz.ccLog.log('inputdata1234retData' + retData.get(ccrz.ccApi.MESSAGES));
            return retData;  
        }else{
            EC_CartDetailController.updateCartShipToSoldTo();
            Map<String, Object> retData = super.processInputData(inputdata);
            
            return retData;  
        }
    }
}