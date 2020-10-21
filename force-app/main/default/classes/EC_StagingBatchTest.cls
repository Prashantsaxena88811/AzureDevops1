@istest
public class EC_StagingBatchTest {

    @istest
   public static void processCDMStagingUser()
    {
       EC_Mulesoft_CDM_Staging__c  updAcc = new  EC_Mulesoft_CDM_Staging__c();
          updAcc.EC_Parent_Account_Number__c = '15081950';
          updAcc.EC_Account_Key__c = '2234412';
          updAcc.EC_Account_Name_English__c = 'Updated Account here';
          updAcc.EC_Account_Number__c = '2234412';
          updAcc.EC_Partner_Function__c = 'SHIPTO';
          updAcc.EC_Account_Global_Business_Unit_Name__c = 'WATER';
          updAcc.EC_Source_Table__c = 'Account';
          updAcc.EC_Action__c = 'InsertAction';
          updAcc.EC_IsProcessed__c  = false;
       insert  updAcc;


        Test.startTest();
        EC_StagingBatch obj = new EC_StagingBatch();
        List<EC_Mulesoft_CDM_Staging__c> lstScope = [SELECT EC_User_Status_Code__c,EC_Account_Key__c,EC_Account_Global_Business_Unit_Name__c,EC_Account_Name_English__c,EC_Account_Number__c,EC_Account_Type_Code__c,EC_Account__c,EC_Action__c,EC_Alias__c,EC_Alignment_Type__c,EC_Application_code__c,EC_Business_Unit__c,EC_City__c,EC_Community_Nickname__c,EC_Contact__c,EC_Context_Point_Key__c,EC_Context_Point_Type__c,EC_Corporate_Reference_Number__c,EC_Country_Code__c,EC_Created_By__c,EC_Created_On__c,EC_Currency__c,EC_Customer_Access__c,EC_Customer_Key__c,EC_Customer__c,EC_Data_Intg_Exec_Id__c,EC_Division__c,EC_Email_Encoding_Key__c,EC_Email__c,EC_Employee_Number__c,EC_Event_ID__c,EC_Event_Name__c,EC_Event_State__c,EC_Event_Status__c,EC_FederationIdentifier__c,EC_First_Name__c,EC_Friendly_Name__c,EC_IsProcessed__c,EC_Is_Active__c,EC_Is_Demo__c,EC_Language_Key__c,EC_Last_Name__c,EC_Last_Processed__c,EC_Locale__c,EC_MDM_ID__c,EC_Modified_By__c,EC_Modified_On__c,EC_MultiSite__c,EC_Account_Name__c,EC_Country_ISO3_Code__c,EC_Name__c,EC_Parent_Account_Key__c,EC_Parent_Account_Number__c,EC_Parent_Customer_Account__c,EC_Partner_Function__c,EC_Permission_Code__c,EC_Phone__c,EC_Port_Enabled__c,EC_Postal_Code__c,EC_Primary_Key__c,EC_Processing_Log__c,EC_Profile_ID__c,EC_Profile_Name__c,EC_Program_Persona_Key__c,EC_Program_Persona__c,EC_RecordType_ID__c,EC_RecordType_Name__c,EC_SF_Country_Code__c,EC_SF_Currency__c,EC_SF_Language_Key__c,EC_SF_Locale__c,EC_SF_Notification_Frequency__c,Redemption_URL__c,EC_SF_Status__c,EC_SF_Street_Address__c,EC_SF_Time_Zone__c,EC_Site_Name_English__c,EC_Sold_To_Account_Number__c,EC_Source_Table__c,EC_State_Province__c,EC_Status_Code__c,EC_Status__c,EC_Street_Address_1__c,EC_Street_Address_2__c,EC_Street_Address_3__c,EC_Street_Address_4__c,EC_Target_Object_ID__c,EC_Target_Object__c,EC_Territory_Name__c,EC_Territory_Number__c,EC_Time_Zone__c,EC_Title__c,EC_Username__c,EC_User_Key__c,EC_User_Type__c,EC_User__c,Id,Name,EC_Account_Divisional_Business_Unit_Name__c,EC_SalesOrg__c,EC_Origination_Account_System_Code__c FROM EC_Mulesoft_CDM_Staging__c where EC_IsProcessed__c = false Order By lastmodifieddate desc LIMIT 5000];
        Id BatchId =  DataBase.executeBatch(obj, 10);
        obj.execute(null, lstScope);
        Test.stopTest();
    }


}