/* Class Name       :EC_CacheWrapperTest
 * Description      :This is the test class to test the EC_CacheWrapper class
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
public class EC_CacheWrapperTest {

	@isTest
	public static void CacheWrapperTest() {
		EC_Testdata.setupCatalog();
		EC_CacheWrapper cacheWrapper = new EC_CacheWrapper();

	}
}