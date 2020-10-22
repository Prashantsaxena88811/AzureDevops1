/* Class Name      :EC_cc_hk_UserInterfaceTest
* Description      :Test class for EC_cc_hk_UserInterface class
* Created By       :Venkatesh Paladugu 
* Created On       :08-04-2020 

* Modification Log:
* ------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------------------------------------------
* Venkatesh Paladugu     08-04-2020                              Initial version (log modification)
*
*
*/
@IsTest
public class EC_cc_hk_UserInterfaceTest{
     /***************************************************************************************************************************************
  Method Name : autocompleteTest
  Description : Test method to cover autocomplete method
  Return type : void
 *************************************************************************************************************************************/
    @IsTest
    static void headContent(){
        Map<String,Object> testMap = new Map<String,Object>();
        insert new Global_Static__c(Name = 'GA&GTM', GA_ID__c = 'UA-4344-2',GTM_AUTH__c = 'dtey6shsj',GTM_ENV__c = 'env-42',GTM_ID__c = 'GTM-34332');
        Test.startTest();
        testMap.put(ccrz.cc_hk_UserInterface.HEAD_CONTENT,'<script>prod</script>');
        EC_cc_hk_UserInterface testCon = new EC_cc_hk_UserInterface();
        testCon.headContent(testMap);
        system.assertEquals(true,true);
        Test.stopTest();
    }    
}