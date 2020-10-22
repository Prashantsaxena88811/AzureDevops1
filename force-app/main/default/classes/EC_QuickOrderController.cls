/* Class Name    : EC_QuickOrderController
 * Description      :Controller Class for Quick Order Component
 * Created By       :Viraj
 * Created On       :2019-Aug-1
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Aug-1         BC-80775        Created the class   
 *
 */
public class EC_QuickOrderController {

    public Boolean buyOnline {get;set;}
    /***************************************************************************************************************************************
  Constructor Name : EC_QuickOrderController 
  Description : Constructor to initialize variables of EC_QuickOrderController  to be used in the component
  Return type : N/A
 *************************************************************************************************************************************/
    public EC_QuickOrderController (){
        
        buyOnline = false;
        
        List<EC_Utility.PermWrapper> permWrapperLst =   EC_Utility.getPermissionCacheInfo();
        ccrz.ccLog.log('permWrapperLst54'+permWrapperLst);
        for(EC_Utility.PermWrapper perm : permWrapperLst){
            if(perm.permName == 'Buy Online'){
                buyOnline= perm.permVal;
            }
        }
    }
}