/*******************************************************************************************************************
* Apex Class Name     : EC_CustomMetadataDAO
* Created Date        : 18 July 2019
* Description         : DAO Class for Custom Metadata
* Developer                        Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Shruti Sinha                 08/07/2019              Original Version
*************************************************************************************************************************/
public class EC_CustomMetadataDAO {

/************************************************************************************************************************************
Method Name : getCustomMetadataRecords
Description : to get Custom Metadata
Parameter   : String
Return type : EC_LogTypes__mdt
Author      : Shruti Sinha
*************************************************************************************************************************************/

    @testVisible static private Map<String,EC_LogTypes__mdt> customMetadataRecordsMap = new Map<String,EC_LogTypes__mdt>();

    public EC_LogTypes__mdt getCustomMetadataRecords(String query) {
        if ( !customMetadataRecordsMap.containsKey( query ) ) {
            customMetadataRecordsMap.put( query, Database.query( query ) );
        }
        return customMetadataRecordsMap.get( query );
    }
}