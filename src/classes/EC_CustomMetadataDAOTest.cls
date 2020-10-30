/*******************************************************************************************************************
* Apex Class Name     : EC_CustomMetadataDAOTest
* Created Date        : 18 July 2019
* Description         : Test Class for EC_CustomMetadataDAO
* Developer                        Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Shruti Sinha                 08/07/2019              Original Version
*************************************************************************************************************************/
@isTest
public class EC_CustomMetadataDAOTest {

/************************************************************************************************************************************
Method Name : testGetMetadata
Description : test method to get Custom Metadata
Parameter   : NA
Return type : void
Author      : Shruti Sinha
*************************************************************************************************************************************/

    static testMethod void testGetMetadata() {

       EC_LogTypes__mdt record;
       Test.startTest();
       record = new EC_CustomMetadataDAO().getCustomMetadataRecords('SELECT MasterLabel FROM EC_LogTypes__mdt');
       Test.stopTest();
       System.assertEquals( [ SELECT MasterLabel FROM EC_LogTypes__mdt ], record,'Size should match');
}

/************************************************************************************************************************************
Method Name : setMetadata
Description : method to set Custom Metadata
Parameter   : String, EC_LogTypes__mdt
Return type : void
Author      : Shruti Sinha
*************************************************************************************************************************************/

    public static void setMetadata( String query, EC_LogTypes__mdt records ) {
        EC_CustomMetadataDAO.customMetadataRecordsMap.put( query, records );
     }

}