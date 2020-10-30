/* Class Name       :EC_ConstantsTest
 * Description      :This is the test class to test the EC_ConstantsTest class
 * Created By       :Shruti Sinha
 * Created On       :07-05-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Shivam Vats         07-05-2019                                   controller class for EC_CacheComponent
 *
 */
@isTest
public class EC_ConstantsTest {

    public static testmethod void constmethod(){

     String  AUG = 'August';
     test.startTest();
     System.assertEquals('August',AUG );
     test.stopTest();
    }

}