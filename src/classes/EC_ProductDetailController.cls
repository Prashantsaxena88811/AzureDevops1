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
    public Boolean indirectStreetBrand{get;set;}//WW-152904
    /***************************************************************************************************************************************
  Constructor Name : EC_ProductDetailController
  Description : Constructor to initialize variables of EC_ProductDetailController to be used in the component
  Return type : N/A
 *************************************************************************************************************************************/
    public EC_ProductDetailController(){
        
        viewPrice = false;
        buyOnline = false;
        indirectStreetBrand =false;//ww-152904
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
        indirectStreetBrand =EC_Utility.isIndirectStreetBrandAccount();//ww-152904
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
        /***************************************************************************************************************************************
Class Name : productLineBASetMap
Description : Helper function to fetch all skus which are applicable for Billing arrangements.
Return type : set<ccrz__E_Pricelist__c>
*************************************************************************************************************************************/
    public static Map<String,List<ccrz__E_Pricelist__c>> productLineBASetMap(String accountGroupId, set<string> ProdskuSet){
        Date today = Date.today();
        // Get all BA Types from Custom settings
        Set<String> BATypeSet = new Set<String>();
        BATypeSet = getBATypes();        
        // Get all BA Product Lines from the custom settings
        Set<String> BAProdLineSet = new Set<String>();
        BAProdLineSet = getBAProductLines();
        Set<String> getBothBATypes = new Set<String>();
        getBothBATypes = getBothBATypes();  
        Set<String> getUsageBATypes = new Set<String>();
        getUsageBATypes = getUsageBATypes();
        Map<String,List<ccrz__E_Pricelist__c>> BAMap = new Map<String,List<ccrz__E_Pricelist__c>>();
        String GenEquipment = System.label.GEN_EQUIPMENT;
        list<ccrz__E_PriceListItem__c> PLItems = new list<ccrz__E_PriceListItem__c> ();
        if(ccrz__E_AccountGroupPriceList__c.sObjectType.getDescribe().isAccessible() && ccrz__E_PriceListItem__c.sObjectType.getDescribe().isAccessible()) {
        PLItems = [select Id,name,ccrz__Pricelist__r.BA_Number__c,ccrz__Pricelist__r.ccrz__Desc__c,ccrz__Pricelist__r.EC_Price_List_Type__c,ccrz__Pricelist__r.ccrz__EndDate__c,ccrz__Product__r.ccrz__sku__c,ccrz__EndDate__c,
                   ccrz__Price__c,ccrz__StartDate__c from ccrz__E_PriceListItem__c where ccrz__StartDate__c <= :today AND ccrz__EndDate__c>=:today
                   AND ccrz__Pricelist__c IN (select ccrz__Pricelist__c from ccrz__E_AccountGroupPriceList__c where ccrz__AccountGroup__c=:accountGroupId and ccrz__StartDate__c <= :today and ccrz__EndDate__c>=:today and ccrz__Enable__c = true
                                                          and ccrz__Pricelist__r.EC_Price_List_Type__c IN:BATypeSet AND ccrz__Pricelist__r.ccrz__Enabled__c = true and ccrz__Pricelist__r.ccrz__StartDate__c <= :today 
                                                          AND ccrz__Pricelist__r.ccrz__EndDate__c>=:today) and (ccrz__Product__r.ccrz__sku__c IN:ProdskuSet OR (ccrz__Product__r.ccrz__sku__c =:GenEquipment and ccrz__Pricelist__r.EC_Price_List_Type__c IN:getUsageBATypes)
                   OR (ccrz__Product__r.ccrz__sku__c IN:BAProdLineSet and ccrz__Pricelist__r.EC_Price_List_Type__c IN:getBothBATypes))];
        }
       	system.debug('BA PLItems--->' + PLItems);
        if(!PLItems.isEmpty()) {//PLItems != null
            for(ccrz__E_PriceListItem__c PLItem : PLItems){
                if(BAMap.containsKey(PLItem.ccrz__Product__r.ccrz__sku__c)){
                    BAMap.get(PLItem.ccrz__Product__r.ccrz__sku__c).add(PLItem.ccrz__Pricelist__r);
                }
                else{
                    BAMap.put(PLItem.ccrz__Product__r.ccrz__sku__c, new List<ccrz__E_Pricelist__c>{PLItem.ccrz__Pricelist__r});
                }            
            }
        }
        ccrz.cclog.log('BA BAMap--->' + BAMap);
        return BAMap;
    }
    
    public static set<string> getBATypes(){
        List<Billing_Arrangement_Types__mdt> BATypes = new List<Billing_Arrangement_Types__mdt>();
        BATypes = [Select Label,GenChemical_Enabled__c,GenEquipment_Enabled__c,BA_Type_Code__c,Active__c,Applicable_On_Cart__c from Billing_Arrangement_Types__mdt where Active__c = true  AND Applicable_On_Cart__c = true];
        Set<String> BATypeSet = new Set<String>();
        if(!BATypes.isEmpty()) {
            for (Billing_Arrangement_Types__mdt BAType : BATypes) {
                if(BAType.Active__c == true) {
                    BATypeSet.add(BAType.Label);
                }
            }
        }
        ccrz.cclog.log('BATypeSet-->' + BATypeSet);
        return BATypeSet;
    }
    public static set<string> getBothBATypes(){
        List<Billing_Arrangement_Types__mdt> BATypes = new List<Billing_Arrangement_Types__mdt>();
        BATypes = [Select Label,GenChemical_Enabled__c,GenEquipment_Enabled__c,BA_Type_Code__c,Active__c,Applicable_On_Cart__c from Billing_Arrangement_Types__mdt where Active__c = true AND GenChemical_Enabled__c = true AND GenEquipment_Enabled__c= true  AND Applicable_On_Cart__c = true];
        Set<String> BATypeSet = new Set<String>();
        if(!BATypes.isEmpty()) {
            for (Billing_Arrangement_Types__mdt BAType : BATypes) {
                if(BAType.Active__c == true) {
                    BATypeSet.add(BAType.Label);
                }
            }
        }
        ccrz.cclog.log('getBothBATypes-->' + BATypeSet);
        return BATypeSet;
    }    
    public static set<string> getUsageBATypes(){
        List<Billing_Arrangement_Types__mdt> BATypes = new List<Billing_Arrangement_Types__mdt>();
        BATypes = [Select Label,GenChemical_Enabled__c,GenEquipment_Enabled__c,BA_Type_Code__c,Active__c,Applicable_On_Cart__c from Billing_Arrangement_Types__mdt where Active__c = true AND GenChemical_Enabled__c = false AND GenEquipment_Enabled__c= true  AND Applicable_On_Cart__c = true];
        Set<String> BATypeSet = new Set<String>();
        if(!BATypes.isEmpty()) {
            for (Billing_Arrangement_Types__mdt BAType : BATypes) {
                if(BAType.Active__c == true) {
                    BATypeSet.add(BAType.Label);
                }
            }
        }
        ccrz.cclog.log('getUsageBATypes-->' + BATypeSet);
        return BATypeSet;
    }  
    public static set<string> getBAProductLines(){
        List<BA_Product_Lines__mdt> BAProdLines = new List<BA_Product_Lines__mdt>();
        BAProdLines = [Select Product_Line__c,Active__c from BA_Product_Lines__mdt where Active__c = true];
        Set<String> BAProdLineSet = new Set<String>();
        if(!BAProdLines.isEmpty()) {
            for (BA_Product_Lines__mdt BAProdLine : BAProdLines) {
                if(BAProdLine.Active__c == true) {
                    BAProdLineSet.add(BAProdLine.Product_Line__c);
                }
            }
        }
        ccrz.cclog.log('BAProdLineSet-->' + BAProdLineSet);
        return BAProdLineSet;
    }
/***************************************************************************************************************************************
Method Name : unstampBillingArrangement
Description : Delete the BillingArrangement on cartItem if not entitled
Return type : ccrz.cc_RemoteActionResult
*************************************************************************************************************************************/
    public static List<ccrz__E_CartItem__c> unstampBillingArrangement(Map<id,Set<ccrz__E_Pricelist__c>> productToApplicableBAMap, Map<String,Set<ccrz__E_Pricelist__c>> prodBAsetMap){
        List<ccrz__E_CartItem__c> updateCartItemList = new List<ccrz__E_CartItem__c>();  
        String effAccountId = ccrz.cc_CallContext.effAccountId;
        String EncartId =  CCRZ.cc_CallContext.currCartId;
        Map<String,Set<String>> productToApplicableBAIdMap = new Map<String,Set<String>>();        
        for(String key : productToApplicableBAMap.keySet()){
            Set<String> baIdSet = new Set<String>();
            for(ccrz__E_Pricelist__c pli : productToApplicableBAMap.get(key)){
                baIdSet.add(String.valueOf(pli.Id));
            }
            productToApplicableBAIdMap.put(key,baIdSet);
        }
        ccrz.cclog.log('productToApplicableBAIdMap--->' + productToApplicableBAIdMap);
        if(ccrz__E_CartItem__c.sObjectType.getDescribe().isAccessible()) {
            List<ccrz__E_CartItem__c> cartItems = new List<ccrz__E_CartItem__c>();
            cartItems = [SELECT ccrz__Product__c,Id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,Billing_Arrangement__c 
                         FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: EncartId AND ccrz__Cart__r.ccrz__EffectiveAccountID__c =:effAccountId
                         AND ccrz__Product__c=:productToApplicableBAMap.keySet() AND Billing_Arrangement__c !=null];
            for(ccrz__E_CartItem__c cItem : cartItems){                  
                if(!productToApplicableBAIdMap.get(cItem.ccrz__Product__c).contains(cItem.Billing_Arrangement__c)){
                    if(prodBAsetMap.get(cItem.ccrz__Product__c).isEmpty()) {
                        cItem.Billing_Arrangement__c = null;
                    }
                    cItem.ccrz__PricingType__c='auto';
                    cItem.ccrz__Price__c = 0.0;
                    //  cItem.ccrz__SubAmount__c=cItem.ccrz__Quantity__c*cItem.ccrz__Price__c;
                    updateCartItemList.add(cItem);
                }
                
            }
        }
        ccrz.cclog.log('updateCartItemList--->' + updateCartItemList);
        return updateCartItemList;
    }
}