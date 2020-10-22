/* Class Name       :EC_ccServiceProduct
* Description      :Service Product Related inherited cloud craze interface
* Created By       :Ashish Kr. 
* Created On       :07-08-2019

* Modification Log:
* ------------------------------------------------------------------------------------------------------------------
* Developer                Date            Modification ID         Description
* ------------------------------------------------------------------------------------------------------------------
* Ashish Kr.               07-08-2019                              Initial version (log modification)
*
*
*/

global without sharing class EC_ccServiceProduct extends ccrz.ccServiceProduct{
    
    /***************************************************************************************************************************************
    Method Name : fetch
    Description : Sets the lastPurchaseDate field in the product bean
    Return type : Map<String, Object>
    *************************************************************************************************************************************/
 global override Map<String, Object> fetch(Map<String, Object> inputData){
        ID ownerId = UserInfo.getUserId();
        Map<String,ccrz__E_CartItem__c> cartItemMap = new Map<String,ccrz__E_CartItem__c>();
        for(ccrz__E_Cart__c wishCart : [Select Name,OwnerId,EC_PurchasedWishlist__c, (Select Id,ccrz__Product__c,EC_Last_Purchased_Date__c,EC_LastPurchasedDateFormatted__c from ccrz__E_CartItems__r) from ccrz__E_Cart__c
                                        Where OwnerId = :ownerId AND ccrz__CartType__c='WishList' AND EC_PurchasedWishlist__c = TRUE Limit 1]){
                                            for(ccrz__E_CartItem__c cartItem : wishCart.ccrz__E_CartItems__r){
                                                cartItemMap.put(cartItem.ccrz__Product__c, cartItem);
                                            }
                                        }
        inputData = super.fetch(inputData);
        if(!inputData.containsKey('includeProductIndex') || !(Boolean)(inputData.get('includeProductIndex'))) {
            List<Chemical_Product_Type__c> pkgTypes = new List<Chemical_Product_Type__c>();
            pkgTypes = Chemical_Product_Type__c.getall().values();
            Set<String> pkgCodeSet = new Set<String>();
            if(!pkgTypes.isEmpty()) {
                for (Chemical_Product_Type__c pkgType : pkgTypes) {
                    if(pkgType.Active__c == true) {
                        pkgCodeSet.add(pkgType.Package_Code__c);
                    }
                }
            }
            ccrz.cclog.log('pkgCodeSet-->' + pkgCodeSet);
            if(inputData.containsKey('productList')){
                List<Map<String,Object>> prodList = (List<Map<String,Object>>) inputData.get('productList');                
                // Tank Number & unloading point Logic
               String effAccountId = ccrz.cc_CallContext.effAccountId;
               List<Account> effAccountList = [Select Id,EC_SalesOrg__c,EC_Division__c FROM Account WHERE Id=:effAccountId LIMIT 1];
                for(Map<String,Object> prod : prodList){
                    String productID = String.valueOf(prod.get('sfid')); 
                    if(!effAccountList.isEmpty()){
                        prod.put('ECDivision',effAccountList[0].EC_Division__c);
                    }
                    String packageCode = String.valueOf(prod.get('packageCode'));
                    ccrz.cclog.log('prod Output' + prod);
                    if(!pkgCodeSet.isEmpty() && pkgCodeSet.contains(packageCode)) {
                        prod.put('packageTypeUOM','Bulk');
                    } else {
                        prod.put('packageTypeUOM','NonBulk');
                    }
                    
                    if(!cartItemMap.isEmpty() && cartItemMap.containsKey(productID) && cartItemMap.get(productID).EC_Last_Purchased_Date__c != null){
                        // 4/2/20 | TB | Story 116762 - replaced formatted value with actual value for sorting purposes. Formatting is done on VF component
                        //prod.put('lastPurchaseDate',(Object)String.valueOf(cartItemMap.get(productID).EC_LastPurchasedDateFormatted__c));
                        prod.put('lastPurchaseDate',(Object)String.valueOf(cartItemMap.get(productID).EC_Last_Purchased_Date__c));
                    }
                }              
                ccrz.cclog.log('CCTXX: ' ,'super fetch--->' + inputData);
                
                // TankNumber & Delivery Point Logic :
                if(ccrz.cc_CallContext.currPageName =='ccrz__Cart') {
                    set<string> deliverTmpltMaterialSet = new set<string>();
                    Map<String,List<String>> packageCodeDelTemplMap = new Map<String,List<String>>();
                    Map<String,List<String>> packageCodeMaterialListMap = new Map<String,List<String>>();
                    Map<String,boolean> isTankNumberApplicableMap = new Map<String,Boolean>();
                    for(Map<String,Object> prod : prodList){
                        String packageCode = String.valueOf(prod.get('packageCode'));
                        String material = String.valueOf(prod.get('materialDescription'));
                        packageCodeDelTemplMap.put(packageCode,new List<String>());
                        if(packageCodeMaterialListMap.containsKey(packageCode)){
                            packageCodeMaterialListMap.get(packageCode).add(material);
                        }else{
                            packageCodeMaterialListMap.put(packageCode,new List<String>{material});
                        }
                    }
                    
                    ccrz.cclog.log('packageCodeDelTemplMap--->' + packageCodeDelTemplMap);
                    if(!packageCodeDelTemplMap.isEmpty()) {
                        String salesOrg='';
                        if(!effAccountList.isEmpty()){
                            salesOrg = effAccountList[0].EC_SalesOrg__c;
                        }
                        
                        isTankNumberApplicableMap = EC_ProductDetailController.isTankNumberApplicable(packageCodeDelTemplMap.keySet(),salesOrg);
                        ccrz.cclog.log('isTankNumberApplicableMap--->' + isTankNumberApplicableMap);
                        packageCodeDelTemplMap = EC_ProductDetailController.getDeliveryTemplateCode(isTankNumberApplicableMap.keySet(),salesOrg);
                        ccrz.cclog.log('packageCodeDelTemplMap--->' + packageCodeDelTemplMap);
                        if(!packageCodeMaterialListMap.isEmpty()){
                            for(String packageCode : packageCodeMaterialListMap.keySet()){
                                for(String material : packageCodeMaterialListMap.get(packageCode)){
                                    if(!packageCodeDelTemplMap.isEmpty() && packageCodeDelTemplMap.containsKey(packageCode)){
                                        for(String delTemp : packageCodeDelTemplMap.get(packageCode)){
                                            String material_DeliveryTempCode = material+ '.'+delTemp;
                                            deliverTmpltMaterialSet.add(material_DeliveryTempCode);
                                        }
                                    }
                                }
                            }
                        }
                        
                        ccrz.cclog.log('deliverTmpltMaterialSet keyset--->' + deliverTmpltMaterialSet);
                    }
                    
                    Map<String,Set<Tank_Detail__c>> materialDelTemplTankList = new Map<String,Set<Tank_Detail__c>>();
                    materialDelTemplTankList  = EC_CartDetailController.getTankNumbersbytmpltCodes(deliverTmpltMaterialSet);
                    ccrz.cclog.log('materialDelTemplTankList--->' + materialDelTemplTankList); 
                    
                    for(Map<String,Object> prod : prodList) {
                        String packageCode = String.valueOf(prod.get('packageCode'));
                        String material = String.valueOf(prod.get('materialDescription'));
                        List<Tank_Detail__c> TankNumbers = new List<Tank_Detail__c>();
                        if(!packageCodeDelTemplMap.isEmpty() && packageCodeDelTemplMap.containsKey(packageCode)){
                            for(String delTemp : packageCodeDelTemplMap.get(packageCode)){
                                String material_DeliveryTempCode = material+ '.'+delTemp;
                                if(!materialDelTemplTankList.isEmpty() && materialDelTemplTankList.containsKey(material_DeliveryTempCode)){
                                    TankNumbers.addAll(materialDelTemplTankList.get(material_DeliveryTempCode));
                                }
                            }
                        }

                        if(TankNumbers != null) {
                            prod.put('TankNumbers',TankNumbers);
                            
                        }
                        
                        if(!isTankNumberApplicableMap.isEmpty() && isTankNumberApplicableMap.containsKey(packageCode)){
                             prod.put('packageTypeTank','Bulk');
                        }else{
                            prod.put('packageTypeTank','NonBulk'); 
                        }
                        ccrz.cclog.log('TankNumbers--->' + TankNumbers);
                    }
                }
            }
        }
        return inputData;
    }

/***************************************************************************************************************************************
  Method Name : getFieldsMap
  Description : used to include object fields in the model on front end
  Return type : Returns Map<String,Object>
**************************************************************************************************************************************/
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData){
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',Biocide_Disclaimer__c,Package_Code__c,Taxonomy__c,Material_Description__c,FeaturesAndBenefits__c,EC_Statement_Of_Assurance__c,ERP_Product_Description__c';
        inputData.put(ccrz.ccService.OBJECTFIELDS, objectFields);
        return inputData;
    }
}