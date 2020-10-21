/* Class Name      :EC_ccServiceProductIndexTest
* Description      :EC_ccServiceProductIndexTest is used for code coverage EC_ccServiceProductIndex
* Created By       :Rajeshwar Bachu. 
* Created On       :25-05-2020

* Modification Log:
* ------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------------------------------------------
* Rajeshwar bachu         25-05-2020                             Initial version (log modification)
*
*
*/
@isTest
public class EC_ccServiceProductIndexTest {  
   static testMethod void getFieldsMapMethod()
    {
        EC_ccServiceProductIndex csProductIndex=new EC_ccServiceProductIndex();
        Test.startTest();
        Map<String, Object> testData=new Map<String, Object>();
        csProductIndex.getFieldsMap(testData);
        system.assertEquals(0, testData.size());
        Test.stopTest();
    }


}