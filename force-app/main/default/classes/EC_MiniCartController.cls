/* Class Name    : EC_MiniCartController
 * Description      :Controller Class for Mini Cart Component
 * Created By       :Viraj
 * Created On       :2019-Aug-1
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Aug-1         BC-80775        Created the class   
 *
 */
public class EC_MiniCartController {

    public Boolean buyOnline {get;set;}
     /***************************************************************************************************************************************
  Constructor Name : EC_MiniCartController 
  Description : Constructor to initialize variables of EC_MiniCartController to be used in the component
  Return type : N/A
 *************************************************************************************************************************************/
    public EC_MiniCartController (){
        
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