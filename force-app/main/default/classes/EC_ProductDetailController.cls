/* Class Name    : EC_ProductDetailController
 * Description      :Controller Class for Product Detail Component
 * Created By       :Viraj
 * Created On       :2019-Aug-1
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                    2019-Aug-1         BC-80775        Created the class   
 *
 */
public class EC_ProductDetailController {
    public Boolean viewPrice {get;set;}
    public Boolean buyOnline {get;set;}
    /***************************************************************************************************************************************
  Constructor Name : EC_ProductDetailController
  Description : Constructor to initialize variables of EC_ProductDetailController to be used in the component
  Return type : N/A
 *************************************************************************************************************************************/
    public EC_ProductDetailController(){
        
        viewPrice = false;
        buyOnline = false;


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
    }

        /***************************************************************************************************************************************
        Class Name : getDeliveryTemplateCode
        Description : Helper function to get Delivery Template code based on product.
        Return type : set<string>
        *************************************************************************************************************************************/
        
    	public static Map<String,List<String>> getDeliveryTemplateCode(set<String> ProdPkgCode,String salesOrg){
            Map<String,List<String>> packageCodeDelTemplMap = new Map<String,List<String>>();
            try{                
                List<Delivery_Template_Package_Code_Mapping__mdt> Dtemplates = [SELECT Delivery_Template_Code__c,DeveloperName,Package_Code__c,QualifiedApiName,Sales_Org__c FROM Delivery_Template_Package_Code_Mapping__mdt where Package_Code__c IN: ProdPkgCode AND Sales_Org__c=:salesOrg];
                if(!Dtemplates.isEmpty()) {
                    for(Delivery_Template_Package_Code_Mapping__mdt tmp : Dtemplates) {
                        if(packageCodeDelTemplMap.containsKey(tmp.Package_Code__c)){
                            packageCodeDelTemplMap.get(tmp.Package_Code__c).add(tmp.Delivery_Template_Code__c);
                        }else{
                            packageCodeDelTemplMap.put(tmp.Package_Code__c,new List<String>{tmp.Delivery_Template_Code__c});
                        }
                    }
                }
            }catch(Exception ex){
                System.debug('exception getDeliveryTemplateCode-->'+ex.getMessage());
            }
            ccrz.cclog.log('getDeliveryTemplateCode templateCode--->' + packageCodeDelTemplMap); 
            return packageCodeDelTemplMap;
        }
    
        /***************************************************************************************************************************************
        Class Name : isTankNumberApplicable
        Description : Helper function to check if packagecode is applicable for tank details.
        Return type : set<string>
        *************************************************************************************************************************************/
        public static Map<String,boolean> isTankNumberApplicable(set<String> ProdPkgCode,String salesOrg){
            Map<String,Boolean> packageCodeIsTankApplicableMap = new Map<String,Boolean>();
            List<Tank_Number_Applicable_Package_Code__mdt> pkgmetadatas = [SELECT DeveloperName,Id,Label,Package_Type_Code__c,QualifiedApiName,Sales_Org__c FROM Tank_Number_Applicable_Package_Code__mdt where Package_Type_Code__c IN: ProdPkgCode AND Sales_Org__c =:salesOrg];
            if(!pkgmetadatas.isEmpty()) {
                for(Tank_Number_Applicable_Package_Code__mdt pkg : pkgmetadatas ) {
                    packageCodeIsTankApplicableMap.put(pkg.Package_Type_Code__c,true);
                }
            }
            ccrz.cclog.log('packageCodeIsTankApplicableMap' + packageCodeIsTankApplicableMap);
            return packageCodeIsTankApplicableMap;
        }
}