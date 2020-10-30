/* Class Name    : EC_ProductListController
 * Description      :Controller Class for Product List Component
 * Created By       :Viraj
 * Created On       :2019-Aug-1
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Aug-1         BC-80775        Created the class   
 *
 */
public class EC_ProductListController {

     public Boolean viewPrice {get;set;}
     public Boolean buyOnline {get;set;}
     public Boolean indirectStreetBrand{get;set;}//ISE-152904
     /***************************************************************************************************************************************
  Constructor Name : EC_ProductListController
  Description : Constructor to initialize variables of EC_ProductListController to be used in the component
  Return type : N/A
 *************************************************************************************************************************************/
     public EC_ProductListController(){
        
        viewPrice = false;
        buyOnline = false;
        indirectStreetBrand = false;//ISE-152904
        List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermissionCacheInfo();
        ccrz.ccLog.log('permWrapperLst54'+permWrapperLst);
        for(EC_Utility.PermWrapper perm : permWrapperLst){
            if(perm.permName == 'View Price'){
                viewPrice = perm.permVal;
            }
            if(perm.permName == 'Buy Online'){
                buyOnline= perm.permVal;
            }
        }
        indirectStreetBrand =EC_Utility.isIndirectStreetBrandAccount();//ISE-152904
    }
}