/* Class Name       :EC_ccTBServicePLI
 * Description      :Storing/Creating the cache tree of all categories
 * Created By       :Ravindra Singh  
 * Created On       :2019-11-11

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ravindra Singh          2019-11-11        Indexing           Created the class   
 *
 */
global class EC_ccTBServicePLI extends ccrz.ccServicePLI{
    /***************************************************************************************************************************************
    Method Name : fetch
    Description : This method has been overridden to increase the query limit for pricelistitems before creating corresponding CC Product Index records
    Return type : Map<String, Object>
    *************************************************************************************************************************************/    
    global override Map<String, Object> fetch(Map<String, Object> inputData) {
            if(ccrz.ccUtil.isTrue(inputData, 'ignoreStorefront')) {//THIS PARAMETER IS SET WHEN FETCH IS CALL FROM LOGIC CREATE CLASS. A BACKHANDED WAY OF CHECKING WHERE ARE WE CALLING FROM
                Integer NEW_QUERY_LIMIT = 20000;
                inputData.put(ccrz.ccService.QUERYLIMIT, NEW_QUERY_LIMIT);
            }
            return super.fetch(inputData);
    }
}