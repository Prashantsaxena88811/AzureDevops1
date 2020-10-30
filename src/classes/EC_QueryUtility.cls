/* Class Name       :EC_QueryUtility
* Description      :Common Utility for SOQL Queries.
* Created By       :Mishika Mahajan
* Created On       :07-29-2019
*
* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID             Description
* ----------------------------------------------------------------------------------------------------------------
* Mishika Mahajan          07-29-2019                                   Utility for SOQL queries.
* Parju 				   09-09-2019									Added a field in SOQL, for getAccountContactRelation method.
*
*/
public without sharing class EC_QueryUtility {

    /***************************************************************************************************************************************
Method Name : getCurrentUser
Description : to fetch current user record
Return type : User
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static User getCurrentUser(){
        List<User> usr = new List<User>();
        usr=  [SELECT contactId,contact.name,contact.Email,Is_User_Logged_In__c,User_Type__c,Name, contact.accountId,contact.Phone,Contact.Account.EC_SalesRepresentative__r.Email, LanguageLocaleKey, EC_CDM_User__c FROM User where Id =:UserInfo.getUserId()];
        if(usr!=null){
            // This Logic is implemented to close case on users first login in
            //<<< B2C: Close case on User's first Sign-In
            if (!usr[0].Is_User_Logged_In__c) {
                List<Case> updateCase = [SELECT Id, Status FROM Case WHERE Contact.Email =: UserInfo.getUserEmail() 
                                   AND Status =: Label.EC_Status_New AND Type = :EC_Constants.USER_REGISTRATION AND
                                   (Origin =: EC_Constants.CASE_ORIGIN_CONNECT_REGISTRATION OR Origin =: EC_Constants.CASE_ORIGIN_CDM_REGISTRATION)]; 
                
                if(updateCase != null && !updateCase.isEmpty()) {
                    usr[0].Is_User_Logged_In__c = true;
                    update usr[0];
                    updateCase[0].Status = EC_Constants.STATUS_CLOSED;
                    update updateCase;
                }
            }
            //>>> B2C: Close case on User's first Sign-In 
            return usr[0];
        }else{
            return null;
        }
    }
    /***************************************************************************************************************************************
Method Name : getProfile
Description : to fetch profile name
Return type : String
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static String getProfile(){
        Profile usrProfile;
        if(userinfo.getProfileId()!=null){
            usrProfile = [Select Name from Profile where Id =:userinfo.getProfileId()];
        }
        return usrProfile.Name;
    }


    /***************************************************************************************************************************************
Method Name : getPermissionSetAssignment
Description : to fetch PermissionSetAssignment record of user
Return type : List<PermissionSetAssignment
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<PermissionSetAssignment> getPermissionSetAssignment(){
        List<PermissionSetAssignment> permissionSetAsignment =  new List<PermissionSetAssignment>();
        if(userinfo.getUserId()!=null){
            permissionSetAsignment = [SELECT AssigneeId,PermissionSetId FROM PermissionSetAssignment where AssigneeId =:userinfo.getUserId()];
        }
        return permissionSetAsignment;
    }
    /***************************************************************************************************************************************
Method Name : getPermissionSet
Description : to fetch PermissionSet record of user
Return type : List<PermissionSet>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<PermissionSet> getPermissionSet(){
        List<PermissionSet> permissionSetList = new List<PermissionSet>();
        if(userinfo.getUserId()!=null){
            permissionSetList = [Select Id,Name from PermissionSet where Id in (SELECT PermissionSetId FROM PermissionSetAssignment where AssigneeId =:userinfo.getUserId())];
        }
        return permissionSetList;
    }

    /***************************************************************************************************************************************
Method Name : getPermissionSetAssignmentList
Description : to fetch PermissionSet record of user
Return type : List<PermissionSetAssignment>
Author      : Ayusha Patnaik
*************************************************************************************************************************************/
    public static List<PermissionSetAssignment> getPermissionSetAssignmentList(){
        List<PermissionSetAssignment> permissionSetList = [select PermissionSetId, PermissionSet.Name, AssigneeId from PermissionSetAssignment where AssigneeId = :userinfo.getUserId()
                                                           and PermissionSetId in (select id from PermissionSet where IsOwnedByProfile=false) and PermissionSet.Name in (:Label.EC_BasicSetID,:Label.EC_BuyerSet)];

        return permissionSetList;
    }


/***************************************************************************************************************************************
Method Name : getUserPermissionSetAssignmentList
Description : to fetch PermissionSet record of user
Return type : List<PermissionSetAssignment>
Author      : Aravind Tallapaka
*************************************************************************************************************************************/
    public static List<PermissionSetAssignment> getUserPermissionSetAssignmentList(){
        List<PermissionSetAssignment> permissionSetList = [select PermissionSetId, PermissionSet.Name, AssigneeId from PermissionSetAssignment where AssigneeId = :userinfo.getUserId()
                                                           and PermissionSetId in (select id from PermissionSet where IsOwnedByProfile=false) and PermissionSet.Name in (:Label.EC_BasicSetID,:Label.EC_BuyerSet,:Label.EC_PayerSet)];

        return permissionSetList;
    }

    /***************************************************************************************************************************************
Method Name : getUserRoleCDMmdt
Description : to fetch PermissionSet record of user
Return type : List<EC_User_Role_CDM__mdt>
Author      : Ayusha Patnaik
*************************************************************************************************************************************/
    public static List<EC_User_Role_CDM__mdt> getUserRoleCDMmdt(String usrRole,String previousRole){
        List<EC_User_Role_CDM__mdt> usrCDMMeta = new List<EC_User_Role_CDM__mdt>();
        if(usrRole!=null){
            usrCDMMeta = [ select label, EC_CDM_Role_Name__c, EC_Permission_Name__c from EC_User_Role_CDM__mdt where label = :usrRole limit 1];
        }
        else if(previousRole!=null){
            usrCDMMeta = [ select label, EC_CDM_Role_Name__c, EC_Permission_Name__c from EC_User_Role_CDM__mdt where label = :previousRole limit 1];
        }
        return usrCDMMeta;
    }



    /***************************************************************************************************************************************
Method Name : getAccountContactRelation
Description : to fetch AccountContactRelation
Return type : List<AccountContactRelation>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<AccountContactRelation> getAccountContactRelation(User usr){
        List<AccountContactRelation> lstAccContRel = new List<AccountContactRelation>();
        if(usr!=null && usr.contactId!=null){
            lstAccContRel = [SELECT id, accountId, account.ccrz__E_AccountGroup__c,Account.EC_Division__c FROM AccountContactRelation WHERE contactId =: usr.contactId WITH SECURITY_ENFORCED];
        }
        return lstAccContRel;
    }
    /***************************************************************************************************************************************
Method Name : getOrderListItem
Description : to fetch orderItems
Return type : List<ccrz__E_OrderItem__c>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<ccrz__E_OrderItem__c> getOrderListItem(Set<Id> orderIds){
        List<ccrz__E_OrderItem__c>  ordrItemList = new list<ccrz__E_OrderItem__c>();
        if(orderIds!=null){
            ordrItemList = [Select Id,ccrz__Order__r.EC_Related_Products__c,ccrz__Product__c,ccrz__Product__r.Name,ccrz__Order__c,ccrz__Product__r.ccrz__SKU__c from ccrz__E_OrderItem__c WHERE Id IN: orderIds];
        }
        return ordrItemList;
    }

    /***************************************************************************************************************************************
Method Name : getOrderListItemSortByName
Description : to fetch orderItems
Return type : List<ccrz__E_OrderItem__c>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<ccrz__E_OrderItem__c> getOrderListItemSortByName(List<String> lstAccIds){
        List<ccrz__E_OrderItem__c> lstOrderItem = new  List<ccrz__E_OrderItem__c>();
        if(lstAccIds!=null && ccrz__E_OrderItem__c.sObjectType.getDescribe().isAccessible()){
            lstOrderItem = [SELECT id, ccrz__Product__r.Package_Code__c, ccrz__Product__r.Taxonomy__c, Custom_PricingUOM__c, Custom_UnitPrice__c,Price_Per__c, ccrz__Product__c, ccrz__Price__c, ccrz__Order__c,ccrz__Order__r.ccrz__Account__r.ccrz__E_AccountGroup__c, ccrz__Product__r.Name,ccrz__Product__r.ccrz__UnitOfMeasure__c , ccrz__Product__r.ccrz__SKU__c, ccrz__Order__r.ccrz__OrderNumber__c,ccrz__Order__r.EC_ERP_Order_Number__c, ccrz__Order__r.ccrz__OrderDate__c, ccrz__Order__r.ccrz__Account__c, ccrz__Order__r.ccrz__Account__r.EC_Division__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressSecondline__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressThirdline__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__City__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__State__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__Country__c, ccrz__Order__r.ccrz__ShipTo__r.ccrz__PostalCode__c FROM ccrz__E_OrderItem__c WHERE ccrz__Order__r.ccrz__Account__c IN: lstAccIds order by Name desc LIMIT 6];
        }
        return lstOrderItem;
    }

    /***************************************************************************************************************************************
Method Name : getListProdMedia
Description : to fetch Product images
Return type : List<ccrz__E_ProductMedia__c>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<ccrz__E_ProductMedia__c> getListProdMedia(Set<Id> lstProduct){
        List<ccrz__E_ProductMedia__c> prodMediaList = new List<ccrz__E_ProductMedia__c>();
        if(lstProduct!=null){
            prodMediaList = [select id, ccrz__URI__c, ccrz__Product__c, ccrz__MediaType__c from ccrz__E_ProductMedia__c
                             where ccrz__Product__c in :lstProduct AND ccrz__MediaType__c='Product Image'];
        }

        return prodMediaList;
    }

            /***************************************************************************************************************************************
Method Name : getListProdSDS
Description : to fetch Product SDS
Return type : List<ccrz__E_ProductMedia__c>
Author      : Pradeep Rajagopal
*************************************************************************************************************************************/
    public static List<ccrz__E_ProductMedia__c> getListProdSDS(Set<Id> lstProduct){
        List<ccrz__E_ProductMedia__c> prodMediaList = new List<ccrz__E_ProductMedia__c>();
        if(lstProduct!=null){
            prodMediaList = [select id, ccrz__URI__c, ccrz__Product__c, ccrz__MediaType__c from ccrz__E_ProductMedia__c
                             where ccrz__Product__c in :lstProduct AND ccrz__MediaType__c='Safety Documents'];
        }

        return prodMediaList;
    }

    /***************************************************************************************************************************************
Method Name : getAccountGroupPriceList
Description : to fetch AccountGroupPriceList
Return type : List<ccrz__E_AccountGroupPriceList__c>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<ccrz__E_Cart__c> getActiveCartRec(String cartEncodedId)
    {
        List<ccrz__E_Cart__c> activeCartRec = new List<ccrz__E_Cart__c>();
        if(cartEncodedId!=null){
            activeCartRec = [SELECT Id, ccrz__EffectiveAccountID__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =: cartEncodedId limit 1];
        }
        return activeCartRec;
    }

    /***************************************************************************************************************************************
Method Name : getAccountGroupPriceList
Description : to fetch AccountGroupPriceList
Return type : List<ccrz__E_AccountGroupPriceList__c>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<ccrz__E_AccountGroupPriceList__c> getAccountGroupPriceList(List<String> lstAccGrpIds){
        List<ccrz__E_AccountGroupPriceList__c> lstAccGrpPriceList = new List<ccrz__E_AccountGroupPriceList__c>();
        if(lstAccGrpIds!=null){
            lstAccGrpPriceList = [SELECT id, ccrz__Pricelist__c FROM ccrz__E_AccountGroupPriceList__c WHERE ccrz__AccountGroup__c IN: lstAccGrpIds];
        }
        return lstAccGrpPriceList;
    }


    /***************************************************************************************************************************************
Method Name : getOrderList
Description : to fetch List Of Past Orders
Return type : List<ccrz__E_Order__c>
Author      : Shruti Sinha
*************************************************************************************************************************************/
    public static list<ccrz__E_Order__c> getOrderList(List<String> lstAccIds,String OrderId){
        List<ccrz__E_Order__c> lstOrder = new List<ccrz__E_Order__c>();
        if(lstAccIds != null && OrderId==''){
            lstOrder = [SELECT id,EC_TotalQuantity__c,ccrz__OriginatedCart__r.ccrz__PONumber__c,ccrz__OrderDate__c,ccrz__OriginatedCart__c, ccrz__OrderNumber__c,ccrz__User__r.Name, ccrz__TotalAmount__c, ccrz__OrderStatus__c,EC_Customer_Order_Status__c, ccrz__PONumber__c, ccrz__CurrencyISOCode__c,ccrz__OrderId__c,ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondline__c, ccrz__BillTo__r.ccrz__AddressThirdline__c, ccrz__BillTo__r.ccrz__City__c, ccrz__BillTo__r.ccrz__State__c, ccrz__BillTo__r.ccrz__Country__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondline__c, ccrz__ShipTo__r.ccrz__AddressThirdline__c, ccrz__ShipTo__r.ccrz__City__c, ccrz__ShipTo__r.ccrz__State__c, ccrz__ShipTo__r.ccrz__Country__c, ccrz__ShipTo__r.ccrz__PostalCode__c, ccrz__Account__r.EC_Account_Number__c, ccrz__Account__r.EC_Division__c, ccrz__Account__r.Recordtype.Name, ccrz__Account__r.parent.EC_Account_Number__c,EC_ERP_Order_Number__c FROM ccrz__E_Order__c WHERE ccrz__Account__c IN: lstAccIds and ccrz__OrderDate__c >= LAST_N_DAYS:365 order by CreatedDate desc];
        } else if((lstAccIds == null && OrderId !=NULL)){
            lstOrder=[Select Id ,EC_TotalQuantity__c ,ccrz__TotalAmount__c,ccrz__OriginatedCart__c,ccrz__EffectiveAccountID__c,ccrz__OriginatedCart__r.ccrz__Account__c,ccrz__User__r.Name,ccrz__OriginatedCart__r.ccrz__EffectiveAccountID__c,ccrz__OrderNumber__c,EC_Customer_Order_Status__c,ccrz__BillTo__c,ccrz__ShipTo__c,(Select Id,ccrz__Product_Name__c,ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.ccrz__UnitOfMeasure__c,ccrz__Quantity__c,ccrz__Price__c,ccrz__Product__c, ccrz__Order__r.ccrz__CurrencyISOCode__c, ccrz__OriginalQuantity__c, ccrz__UnitOfMeasure__c from ccrz__E_OrderItems__r),ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__AddressSecondline__c,ccrz__BillTo__r.ccrz__AddressThirdline__c, ccrz__BillTo__r.ccrz__City__c, ccrz__BillTo__r.ccrz__State__c, ccrz__BillTo__r.ccrz__Country__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondline__c, ccrz__ShipTo__r.ccrz__AddressThirdline__c, ccrz__ShipTo__r.ccrz__City__c, ccrz__ShipTo__r.ccrz__State__c, ccrz__ShipTo__r.ccrz__Country__c, ccrz__ShipTo__r.ccrz__PostalCode__c,ccrz__OriginatedCart__r.ccrz__PONumber__c, ccrz__Account__r.EC_Account_Number__c, ccrz__Account__r.EC_Division__c, ccrz__Account__r.Recordtype.Name, ccrz__Account__r.parent.EC_Account_Number__c from ccrz__E_Order__c where Id  =:OrderId LIMIT 1];
        }
        return lstOrder ;
    }

    /***************************************************************************************************************************************
Method Name : getCustomCodes
Description : to fetch Custom Code details returned in Mulsesoft response
Return type : List<>
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public static List<EC_UserRegistration_Custom_Code__mdt> getCustomCodeUserRegistration(String responseCode){
        List<EC_UserRegistration_Custom_Code__mdt> cpd = [select EC_CustomCodes__c,EC_Message__c,EC_Popup_Label__c from EC_UserRegistration_Custom_Code__mdt  Where EC_CustomCodes__c=:responseCode Limit 1];
        return cpd;
    }

    /***************************************************************************************************************************************
Method Name : getCustomCodes
Description : to fetch Custom Code details returned in Mulsesoft response
Return type : List<>
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public static List<EC_MulesoftIntegration_Custom_Codes__mdt> getCustomCodeSelfAlignment(String responseCode){
        List<EC_MulesoftIntegration_Custom_Codes__mdt> cpd = [select EC_CustomCodes__c,EC_Message__c,EC_Popup_Label__c from EC_MulesoftIntegration_Custom_Codes__mdt  Where EC_CustomCodes__c=:responseCode Limit 1];

        return cpd;
    }

    /***************************************************************************************************************************************
Method Name : getCartList
Description : to fetch Cart
Return type : List<ccrz__E_Cart__c>
Author      : Shruti Sinha
*************************************************************************************************************************************/
    public static list<ccrz__E_Cart__c> getCartList(String ContactId,Boolean check){
        List<ccrz__E_Cart__c> cartList = new List<ccrz__E_Cart__c>();
        if(ContactId !='' && check == TRUE){
            cartList = [SELECT Id, ccrz__Contact__c,ccrz__ActiveCart__c, LastModifiedDate, ccrz__EncryptedId__c
                        FROM ccrz__E_Cart__c
                        WHERE ccrz__Contact__c =:ContactId
                        AND ccrz__ActiveCart__c = TRUE
                        order by lastModifieddate desc];
        }
        return cartlist;

    }


    /***************************************************************************************************************************************
Method Name : getPriceListItems
Description : to fetch PriceListItems from the entitled price lists
Return type : List<ccrz__E_PriceListItem__c>
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static List<ccrz__E_PriceListItem__c> getPriceListItems(set<string> setEntitledPriceList,String searchText){
        String restWordSearch = ' ' + searchText;
        List<ccrz__E_PriceListItem__c> lstProdRecs = [SELECT id, EC_OrderedDate__c,CreatedDate,ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.CreatedDate, ccrz__Product__c, ccrz__Product__r.ccrz__UnitOfMeasure__c, ccrz__Product__r.ccrz__ShortDesc__c, ccrz__Product__r.ccrz__LongDesc__c,ccrz__Product__r.ccrz__FilterData__c FROM ccrz__E_PriceListItem__c WHERE ccrz__Pricelist__c IN: setEntitledPriceList AND ccrz__Product__r.ccrz__ProductStatus__c != 'Blocked' AND ccrz__Product__r.ccrz__EndDate__c >= TODAY ORDER BY ccrz__Product__r.CreatedDate DESC];

        List<ccrz__E_PriceListItem__c> lstProdRecsOut = new List<ccrz__E_PriceListItem__c>();
        for(ccrz__E_PriceListItem__c tempRec : lstProdRecs){
            if(tempRec.ccrz__Product__r.Name.startsWithIgnoreCase(searchText) || tempRec.ccrz__Product__r.Name.containsIgnoreCase(restWordSearch) || (tempRec.ccrz__Product__r.ccrz__ShortDesc__c != null && (tempRec.ccrz__Product__r.ccrz__ShortDesc__c.startsWithIgnoreCase(searchText) || tempRec.ccrz__Product__r.ccrz__ShortDesc__c.containsIgnoreCase(restWordSearch))) || (tempRec.ccrz__Product__r.ccrz__LongDesc__c != null && (tempRec.ccrz__Product__r.ccrz__LongDesc__c.startsWithIgnoreCase(searchText) || tempRec.ccrz__Product__r.ccrz__LongDesc__c.containsIgnoreCase(restWordSearch))) || (tempRec.ccrz__Product__r.ccrz__FilterData__c != null && tempRec.ccrz__Product__r.ccrz__FilterData__c.containsIgnoreCase(searchText))  || tempRec.ccrz__Product__r.ccrz__SKU__c.startsWithIgnoreCase(searchText)){
                lstProdRecsOut.add(tempRec);
            }
        }
        return lstProdRecsOut;
    }


   /***************************************************************************************************************************************
Method Name : getPriceListItemsAutoSuggest
Description : to fetch PriceListItems from the entitled price lists only for AutoSuggestion
Return type : List<ccrz__E_PriceListItem__c>
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static List<ccrz__E_PriceListItem__c> getPriceListItemsAutoSuggest(set<string> setEntitledPriceList,String searchText){
        String restWordSearch = ' ' + searchText;
        List<ccrz__E_PriceListItem__c> lstProdRecs = [SELECT id, EC_OrderedDate__c,CreatedDate,ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.CreatedDate, ccrz__Product__c, ccrz__Product__r.ccrz__UnitOfMeasure__c, ccrz__Product__r.ccrz__ShortDesc__c, ccrz__Product__r.ccrz__LongDesc__c,ccrz__Product__r.ccrz__FilterData__c FROM ccrz__E_PriceListItem__c WHERE ccrz__Pricelist__c IN: setEntitledPriceList AND ccrz__Product__r.ccrz__ProductStatus__c != 'Blocked' AND ccrz__Product__r.ccrz__EndDate__c >= TODAY ORDER BY ccrz__Product__r.CreatedDate DESC];

        integer recCount = 0;
        List<ccrz__E_PriceListItem__c> lstProdRecsOut = new List<ccrz__E_PriceListItem__c>();
        for(ccrz__E_PriceListItem__c tempRec : lstProdRecs){
            if(recCount < 100){
                if(tempRec.ccrz__Product__r.Name.startsWithIgnoreCase(searchText) || tempRec.ccrz__Product__r.Name.containsIgnoreCase(restWordSearch) || (tempRec.ccrz__Product__r.ccrz__ShortDesc__c != null && (tempRec.ccrz__Product__r.ccrz__ShortDesc__c.startsWithIgnoreCase(searchText) || tempRec.ccrz__Product__r.ccrz__ShortDesc__c.containsIgnoreCase(restWordSearch))) || (tempRec.ccrz__Product__r.ccrz__LongDesc__c != null && (tempRec.ccrz__Product__r.ccrz__LongDesc__c.startsWithIgnoreCase(searchText) || tempRec.ccrz__Product__r.ccrz__LongDesc__c.containsIgnoreCase(restWordSearch))) || (tempRec.ccrz__Product__r.ccrz__FilterData__c != null && tempRec.ccrz__Product__r.ccrz__FilterData__c.containsIgnoreCase(searchText))|| tempRec.ccrz__Product__r.ccrz__SKU__c.startsWithIgnoreCase(searchText)){
                    lstProdRecsOut.add(tempRec);
                    recCount++;
                }
            }else{
                break;
            }
        }
        return lstProdRecsOut;
    }
    /***************************************************************************************************************************************
Method Name : getOrderPriceListItems
Description : to fetch PriceListItems from the entitled price lists for order items
Return type : List<ccrz__E_PriceListItem__c>
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static List<ccrz__E_PriceListItem__c> getOrderPriceListItems(set<string> setEntitledPriceList,String searchText){

        List<ccrz__E_PriceListItem__c> lstProdRecs = [SELECT id, EC_OrderedDate__c, createdDate, ccrz__Product__c, ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.ccrz__UnitOfMeasure__c FROM ccrz__E_PriceListItem__c WHERE ccrz__Pricelist__c IN: setEntitledPriceList AND (ccrz__Product__r.Name LIKE: searchText OR ccrz__Product__r.ccrz__SKU__c LIKE: searchText) AND ccrz__Product__r.ccrz__ProductStatus__c !='Blocked' ORDER BY EC_OrderedDate__c DESC];

        return lstProdRecs;

    }

    /***************************************************************************************************************************************
Method Name : getProductmediaList
Description : to fetch ProductMedia List for getting the images
Return type : List<ccrz__E_ProductMedia__c>
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static List<ccrz__E_ProductMedia__c> getProductmediaList(Map<String, ccrz__E_PriceListItem__c> recentRecMap){

        List<ccrz__E_ProductMedia__c> lstProductMedia = [SELECT id, ccrz__URI__c, ccrz__MediaType__c, ccrz__ProductDescription__c, ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__r.ccrz__SKU__c IN: recentRecMap.keyset() AND ccrz__MediaType__c = 'Product Image'];

        return lstProductMedia;

    }

    /***************************************************************************************************************************************
Method Name : getProductsFromSkuIds
Description : to fetch Products from sku list
Return type : List<ccrz__E_Product__c>
Author      : Aravind Tallapaka
*************************************************************************************************************************************/
    public static List<ccrz__E_Product__c> getProductsFromSkuIds(List<String> productSkuList){

        List<ccrz__E_Product__c> lstProducts = [SELECT Id, ccrz__SKU__c, ccrz__UnitOfMeasure__c FROM ccrz__E_Product__c where ccrz__SKU__c in :productSkuList];

        return lstProducts;

    }

    /***************************************************************************************************************************************
Method Name : getOrderList
Description : to fetch Order List
Return type : List<ccrz__E_Order__c>
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static List<ccrz__E_Order__c> getOrderList(EC_CacheWrapper user){

        List<ccrz__E_Order__c> lstAllOrderItems = [SELECT id, Name, ccrz__OrderNumber__c, ccrz__CurrencyISOCode__c, EC_Related_Products__c, EC_TotalQuantity__c, ccrz__OrderDate__c, ccrz__Contact__r.Name, ccrz__Contact__r.account.EC_Account_Number__c, ccrz__TotalAmount__c, ccrz__OrderStatus__c, ccrz__PONumber__c, ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondline__c, ccrz__BillTo__r.ccrz__AddressThirdline__c, ccrz__BillTo__r.ccrz__City__c, ccrz__BillTo__r.ccrz__State__c, ccrz__BillTo__r.ccrz__Country__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondline__c, ccrz__ShipTo__r.ccrz__AddressThirdline__c, ccrz__ShipTo__r.ccrz__City__c, ccrz__ShipTo__r.ccrz__State__c, ccrz__ShipTo__r.ccrz__Country__c, ccrz__ShipTo__r.ccrz__PostalCode__c, EC_Customer_Order_Status__c, ccrz__Account__r.EC_Account_Number__c, ccrz__Account__r.EC_Division__c, ccrz__Account__r.Recordtype.Name, ccrz__Account__r.parent.EC_Account_Number__c, ccrz__User__r.Name, ccrz__OriginatedCart__r.ccrz__PONumber__c, EC_ERP_Order_Number__c FROM ccrz__E_Order__c WHERE ccrz__Account__c IN: user.contactAccList ORDER BY Name DESC];

        return lstAllOrderItems;

    }

    /***************************************************************************************************************************************
Method Name : getProductMediaDocSearch
Description : to fetch the productMedia List based on list of resulted products in docsearch
Return type : List<ccrz__E_ProductMedia__c>
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static List<ccrz__E_ProductMedia__c> getProductMediaDocSearch(Set<String> resultProdIdLst){

        List<ccrz__E_ProductMedia__c> lstProductMedia = [SELECT id, ccrz__URI__c, ccrz__MediaType__c, ccrz__ProductDescription__c, ccrz__Product__r.Name, ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_ProductMedia__c WHERE ccrz__Product__c IN: resultProdIdLst AND ccrz__MediaType__c = 'Safety Documents'];

        return lstProductMedia;

    }
    /***************************************************************************************************************************************
Method Name : getInvoice
Description : to fetch the Invoice
Return type : List<ccrz__E_Invoice__c>
Author      : Shruti Sinha
*************************************************************************************************************************************/
    public static List<ccrz__E_Invoice__c> getInvoice(String OrderId){
        List<ccrz__E_Invoice__c> inv = new  List<ccrz__E_Invoice__c>();
        inv = [select id from ccrz__E_Invoice__c where ccrz__CCOrder__c =:orderId limit 1];
        return inv;

    }
    /***************************************************************************************************************************************
Method Name : getInvoice
Description : to fetch the Invoice
Return type : List<ccrz__E_ProductMedia__c>
Author      : Shruti Sinha
*************************************************************************************************************************************/
    public static List<ccrz__E_ProductMedia__c> getDocuments(List<Id> productList){
        List<ccrz__E_ProductMedia__c> prm = new  List<ccrz__E_ProductMedia__c>();
        prm =[Select Id,ccrz__URI__c,ccrz__Product__c from ccrz__E_ProductMedia__c  where ccrz__Product__c =: productList ] ;
        return prm;
    }

    /***************************************************************************************************************************************
Method Name : getActiveCart
Description : to fetch the active cart of logged in user
Return type : List<ccrz__E_Cart__c>
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public static List<ccrz__E_Cart__c> getActiveCart(){

        List<ccrz__E_Cart__c> lstCart = [select id, ccrz__TotalQuantity__c, ccrz__TotalAmount__c, ccrz__EncryptedId__c,
                                         ccrz__EffectiveAccountID__c from ccrz__E_Cart__c where
                                         ccrz__User__c = : UserInfo.getUserId() and ccrz__ActiveCart__c=TRUE Order By LastModifiedDate DESC];
        return lstCart;

    }

    /***************************************************************************************************************************************
Method Name : getActiveOpenCart
Description : to fetch the active cart of logged in user
Return type : List<ccrz__E_Cart__c>
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public static List<ccrz__E_Cart__c> getActiveOpenCart(){

        List<ccrz__E_Cart__c> lstCart = [select id, ccrz__TotalQuantity__c,ccrz__EffectiveAccountID__c,ccrz__EncryptedId__c from ccrz__E_Cart__c where ccrz__User__c =:userInfo.getUserId() and ccrz__ActiveCart__c=true AND ccrz__CartType__c =: Label.EC_CartType_Cart AND ccrz__CartStatus__c =: Label.EC_CartStatus_Open order by LastModifiedDate desc limit 1];
        return lstCart;
    }

    /***************************************************************************************************************************************
Method Name : getUserContact
Description : to fetch the active cart of logged in user
Return type : String
Author      : Ayusha Patnaik
*************************************************************************************************************************************/
    public static String getUserContact(){

        User usr = [SELECT id, contactId FROM User WHERE id=:UserInfo.getUserId()];
        Contact cont = [Select Name from contact where Id =:usr.contactId];
        return cont.Name;
    }

    /***************************************************************************************************************************************
Method Name : getHeader
Description : to fetch the clientId,clientSecret and endPointUrl for Mulesoft API Callout.
Return type : Object
Author      : Raghav Sharma
*************************************************************************************************************************************/
    public static EC_Mulesoft_Integration__c getHeader(String callingAPI){
        EC_Mulesoft_Integration__c srObject = [Select Id, EC_ClientId__c, EC_Client_Secret__c, EC_Endpoint__c From EC_Mulesoft_Integration__c Where Name=:callingAPI limit 1];
        return srObject;
    }



     /***************************************************************************************************************************************
Method Name : getAccShare
Description : to fetch accountshare records
Return type : List<AccountShare>
Author      : Mishika Mahajan
*************************************************************************************************************************************/
    public static List<AccountShare> getAccShare(List<Id> accConIdList,List<Id> usrIdList){
        List<AccountShare> accShareList = new List<AccountShare>();
        if(accConIdList!=null && !(accConIdList.isEmpty())){
           accShareList = [select id,AccountId,UserOrGroupId from AccountShare where AccountId in :accConIdList AND UserOrGroupId in :usrIdList and  RowCause = :EC_Constants.MANUAL];
        }
       return  accShareList;
    }

 /***************************************************************************************************************************************
Method Name : getSaleRepContact
Description : to fetch SalesRepContact
Return type : List<Contact>
Author      : Shruti Sinha
*************************************************************************************************************************************/
    public static List<Contact> getSaleRepContact(){
        List<Contact> ContactList = new List<Contact>();
        if(userinfo.getUserId()!=null){
            ContactList =[Select Id,FirstName,LastName,Name,Email,Phone,EC_SalesRep_User__c from Contact where EC_SalesRep_User__c =: UserInfo.getUserId() limit 1];
        }
        return ContactList;
    }

/***************************************************************************************************************************************
Method Name : getResponseCode
Description : to fetch EC_PunchinCodes__mdt records
Return type : List<>
Author      : Raghav Sharma
*************************************************************************************************************************************/

    public static List<EC_PunchinCodes__mdt> getResponseCode(String responseCode){
  List<EC_PunchinCodes__mdt> punCode = [Select EC_CustomCodes__c, EC_Message__c FROM EC_PunchinCodes__mdt WHERE EC_CustomCodes__c=:responseCode limit 1 ];   //query the result here and assign in wrapper and json response
   return punCode;
    }
    
/***************************************************************************************************************************************
Method Name : getProdSDS
Description : to fetch Product SDS
Return type : List<ccrz__E_ProductMedia__c>
Author      : Raghu Varma
*************************************************************************************************************************************/
    public static List<ccrz__E_ProductMedia__c> getProdSDS(Set<Id> lstProduct){
        List<ccrz__E_ProductMedia__c> prodMediaList = new List<ccrz__E_ProductMedia__c>();
        if(lstProduct!=null){
            prodMediaList = [select id, ccrz__URI__c, ccrz__Product__c, ccrz__MediaType__c from ccrz__E_ProductMedia__c
                                where ccrz__Product__c in :lstProduct AND ccrz__MediaType__c='Safety Documents']; 
        }
        
        return prodMediaList;
    }
  
  /***************************************************************************************************************************************
    Method Name : getInstSalesEntitlements
    Description : to fetch INST Sales Entitlements data for Chemical Products
    Return type : Map<String, INST_Sales_Entitlement__c>
    PBI         : 139350
    *************************************************************************************************************************************/
    public static Map<String, INST_Sales_Entitlement__c> getInstSalesEntitlements(Set<Id> setAccIds) {
        Map<String, INST_Sales_Entitlement__c> mapInstSalesEntitlements = new Map<String, INST_Sales_Entitlement__c>();
        try{
            if(setAccIds != null){
                //Fetch INST chemical products that belongs to the accounts
                for(INST_Sales_Entitlement__c instSales : [SELECT Account_Salesforce_Id__c, SKU__c, Taxonomy__c  FROM INST_Sales_Entitlement__c WHERE Taxonomy__c = :EC_Constants.TAXONOMY_CHEMICAL AND Account_Salesforce_Id__c IN :setAccIds]) {
                    if(instSales.SKU__c == null) {
                        mapInstSalesEntitlements.put(instSales.Account_Salesforce_Id__c, instSales); //INDIRECT CORE
                    } else {
                        mapInstSalesEntitlements.put(instSales.SKU__c, instSales); 					 //HYBRID/DIRECT ACCOUNT
                    }
                }
            }
        } catch(Exception e){
            System.debug('Exception found @EC_QueryUtility.getInstSalesEntitlements-->'+ e.getTypeName() + ' '+ e.getLineNumber() + ' '+ e.getMessage());
        }
        return mapInstSalesEntitlements;
    }
    /***************************************************************************************************************************************
    Method Name : getPriceListItems
    Description : to fetch pricelistItems
    Return type : Map<Id, Boolean>
    *************************************************************************************************************************************/
    public static  Map<Id, Boolean> getProdPricelistItems(Set<Id> lstProduct, Set<Id> accountGrpset){
        List<ccrz__E_PriceListItem__c> prodPriceListItems = new List<ccrz__E_PriceListItem__c>();
        Map<Id, Boolean> mapPrdctPrice = new Map<Id, Boolean>();
        // List<ccrz__E_AccountGroupPriceList__c> acctGrpPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
        Set<Id> pricelstIds = new Set<Id>();
        pricelstIds = getPriceLists(accountGrpset);
        prodPriceListItems = getAccGrpPriceListItems(lstProduct, pricelstIds);
        Set<String> priceListTypes = new Set<String>();
        List<EC_PriceList_Type__mdt> ecPriceListTypes = new List<EC_PriceList_Type__mdt>();
        ecPriceListTypes = [SELECT id, Pricelist_Type__c FROM EC_PriceList_Type__mdt WHERE Label = 'FlatFeePriceLists'];
        String pricelistTypestr =  (String)ecPriceListTypes[0].Pricelist_Type__c;
        priceListTypes.addall(pricelistTypestr.split(','));

        if (prodPriceListItems != null && !prodPriceListItems.isEmpty()) {
            for(ccrz__E_PriceListItem__c priceListItem : prodPriceListItems){
                Boolean isFlatFee_NoChrg_Prd = false;

                if(priceListTypes.contains(priceListItem.ccrz__Pricelist__r.EC_Price_List_Type__c)) {
                    isFlatFee_NoChrg_Prd = true;
                }
                mapPrdctPrice.put(priceListItem.ccrz__Product__c, isFlatFee_NoChrg_Prd);
            }
        }
        system.debug('mapPrdctPrice'+JSON.serialize(mapPrdctPrice));
        return mapPrdctPrice;
    }
    
    /***************************************************************************************************************************************
    Method Name : getFlatFeeItemDetail
    Description : Check if item is flatfee/NoCharge Item.
    Return type : Boolean
    *************************************************************************************************************************************/
    public static Boolean getFlatFeeCartDetail(){
        String EncartId =  CCRZ.cc_CallContext.currCartId;
        String effAccountId = ccrz.cc_CallContext.effAccountId;
        Boolean isFlatFeeCart = false;
        Set<Id> prodIdSet = new Set<Id>();
        List<ccrz__E_CartItem__c> cartItems = [SELECT ccrz__Product__c,Id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,Tank_Number__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: EncartId AND ccrz__Cart__r.ccrz__EffectiveAccountID__c =:effAccountId];
        if(cartItems!=null) {
            for(ccrz__E_CartItem__c cartItem:cartItems) {
                prodIdSet.add(cartItem.ccrz__Product__c);
            }    
        }
       Map<Id, Boolean> mapPrdctFlatfee = getAccountGroupList(prodIdSet);
        for(ccrz__E_CartItem__c cartItem:cartItems) {
            if(mapPrdctFlatfee != null && mapPrdctFlatfee.containsKey(cartItem.ccrz__Product__c)){
                isFlatFeeCart = true;
                break;
            }
        }
        return isFlatFeeCart;
    }

    /***************************************************************************************************************************************
    Method Name : getPricelIsts
    Description : Check if item is flatfee/NoCharge Item.
    Return type : Boolean
    *************************************************************************************************************************************/
    public static Set<Id> getPriceLists(Set<Id>accountGrpset){
        List<ccrz__E_AccountGroupPriceList__c>acctGrpPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
        Date today = Date.today();
        if(ccrz__E_AccountGroupPriceList__c.SObjectType.getDescribe().isAccessible()) {
            acctGrpPriceLists = [select id, ccrz__Pricelist__c, ccrz__Pricelist__r.EC_Price_List_Type__c  from ccrz__E_AccountGroupPriceList__c where
            ccrz__Enable__c = true and ccrz__AccountGroup__c in:accountGrpset and ccrz__Pricelist__r.ccrz__Enabled__c = true 
            and ccrz__StartDate__c <= :today and ccrz__EndDate__c >= :today and 
            (ccrz__Pricelist__r.EC_Price_List_Type__c = 'FlatFee' or ccrz__Pricelist__r.EC_Price_List_Type__c = 'NoCharge') 
            and ccrz__Pricelist__r.ccrz__StartDate__c <= :today and ccrz__Pricelist__r.ccrz__EndDate__c >= :today ];
        }
        Set<Id> pricelstIds = new Set<Id>();
        if(acctGrpPriceLists != null && !acctGrpPriceLists.isEmpty()) {
            for (ccrz__E_AccountGroupPriceList__c acctGrpPriceList : acctGrpPriceLists) {
                pricelstIds.add(acctGrpPriceList.ccrz__Pricelist__c);
            }
        }
        return pricelstIds;
    }
    /***************************************************************************************************************************************
    Method Name : getPricelIsts
    Description : Check if item is flatfee/NoCharge Item.
    Return type : Boolean
    *************************************************************************************************************************************/
    public static List<ccrz__E_PriceListItem__c> getAccGrpPriceListItems(Set<Id>lstProduct, Set<Id>pricelstIds){
        List<ccrz__E_PriceListItem__c>prodPriceListItems = new List<ccrz__E_PriceListItem__c>();
        Date today = Date.today();
        if(ccrz__E_PriceListItem__c.SObjectType.getDescribe().isAccessible() && lstProduct!=null) {
            prodPriceListItems = [select id, ccrz__Pricelist__c,ccrz__Product__c,ccrz__Pricelist__r.Name,  ccrz__Pricelist__r.EC_Price_List_Type__c from ccrz__E_PriceListItem__c where ccrz__Pricelist__c in:pricelstIds and ccrz__Product__c in: lstProduct
            and ccrz__Product__r.ccrz__StartDate__c <= :today and ccrz__Product__r.ccrz__EndDate__c >= :today and ccrz__StartDate__c <= :today and ccrz__EndDate__c >= :today];
        }
        
        return prodPriceListItems;
    }
    
     /***************************************************************************************************************************************
    Method Name : getAccountGroupList
    Description : Check if item is flatfee/NoCharge Item.
    Return type : Set<id>
    *************************************************************************************************************************************/
    public static Map<Id, Boolean> getAccountGroupList(Set<Id>prodIdset){
        String effAccountId = ccrz.cc_CallContext.effAccountId;
         List<Account> effAccountList  = new List<Account>();
        if(Account.SObjectType.getDescribe().isAccessible()) {
            effAccountList = [Select Id,EC_SalesOrg__c,EC_Division__c,ccrz__E_AccountGroup__c FROM Account WHERE Id=:effAccountId LIMIT 1];
        }
        Set<Id> acctGrpSet = new Set<Id>();
        if(!effAccountList.isEmpty()) {
            for(Account effAccount: effAccountList) {
                acctGrpSet.add(effAccount.ccrz__E_AccountGroup__c);
            }
        }
        Map<Id, Boolean> mapPrdctFlatfee = new  Map<Id, Boolean>();
        if(effAccountList[0].EC_Division__c == EC_Constants.INSTITUTIONAL || effAccountList[0].EC_Division__c == EC_Constants.FOODANDBEVERAGE || effAccountList[0].EC_Division__c == EC_Constants.TEXTILECARE){
            mapPrdctFlatfee = getProdPricelistItems(prodIdset, acctGrpSet);
        }
        return mapPrdctFlatfee;
    }
    
    /***************************************************************************************************************************************
    Method Name : getPriceListItems
    Description : to fetch pricelistItems
    Return type : Map<Id, Boolean>
    *************************************************************************************************************************************/
    public static  Map<Id,Map<Id, Boolean>> getAcctGrpProdPricelistItems(Set<Id> lstProduct, Set<Id> accountGrpset){
        List<ccrz__E_PriceListItem__c> prodPriceListItems = new List<ccrz__E_PriceListItem__c>();
        // List<ccrz__E_AccountGroupPriceList__c> acctGrpPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
        Set<Id> pricelstIds = new Set<Id>();
        Map<Id, Boolean> mapPrdctPrice = new Map<Id, Boolean>();
        List<ccrz__E_AccountGroupPriceList__c>acctGrpPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
        pricelstIds = getPriceLists(accountGrpset);
        acctGrpPriceLists = getAccGrpPriceLists(accountGrpset);
        prodPriceListItems = getAccGrpPriceListItems(lstProduct, pricelstIds);
        Map<Id, Map<Id, Boolean>> acctGrpPrdctFlatFeeMap= new Map<Id, Map<Id, Boolean>>();
        
        Set<String> priceListTypes = new Set<String>();
        List<EC_PriceList_Type__mdt> ecPriceListTypes = new List<EC_PriceList_Type__mdt>();
        if(EC_PriceList_Type__mdt.SObjectType.getDescribe().isAccessible()){
          ecPriceListTypes = [SELECT id, Pricelist_Type__c FROM EC_PriceList_Type__mdt WHERE Label = 'FlatFeePriceLists'];  
        }
        if(!ecPriceListTypes.isEmpty()){
        	String pricelistTypestr =  (String)ecPriceListTypes[0].Pricelist_Type__c;
	        priceListTypes.addall(pricelistTypestr.split(','));
        }

        if (prodPriceListItems != null && !prodPriceListItems.isEmpty()) {
            for(ccrz__E_PriceListItem__c priceListItem : prodPriceListItems){
                Boolean isFlatFee_NoChrg_Prd = false;
                if(acctGrpPriceLists != null && !acctGrpPriceLists.isEmpty()) {
                     for (ccrz__E_AccountGroupPriceList__c acctGrpPriceList : acctGrpPriceLists) {
                         // Map<Id, Boolean> mapPrdctPrice = new Map<Id, Boolean>();
                        if(pricelistItem.ccrz__Pricelist__c == acctGrpPriceList.ccrz__Pricelist__c) {
                            if(priceListTypes.contains(priceListItem.ccrz__Pricelist__r.EC_Price_List_Type__c)) {
                                isFlatFee_NoChrg_Prd = true;
                            }
                            mapPrdctPrice.put(priceListItem.ccrz__Product__c, isFlatFee_NoChrg_Prd);
                            acctGrpPrdctFlatFeeMap.put(acctGrpPriceList.ccrz__AccountGroup__c,mapPrdctPrice);
                        }
                     }
                }
                
            }
        }
        system.debug('acctGrpPrdctFlatFeeMap'+JSON.serialize(acctGrpPrdctFlatFeeMap));
        return acctGrpPrdctFlatFeeMap;
    }
    /***************************************************************************************************************************************
    Method Name : getPricelIsts
    Description : Check if item is flatfee/NoCharge Item.
    Return type : Boolean
    *************************************************************************************************************************************/
    public static List<ccrz__E_AccountGroupPriceList__c> getAccGrpPriceLists(Set<Id>accountGrpset){
        List<ccrz__E_AccountGroupPriceList__c>acctGrpPriceLists = new List<ccrz__E_AccountGroupPriceList__c>();
        Date today = Date.today();
        if(ccrz__E_AccountGroupPriceList__c.SObjectType.getDescribe().isAccessible()) {
            acctGrpPriceLists = [select id, ccrz__Pricelist__c, ccrz__AccountGroup__c, ccrz__Pricelist__r.EC_Price_List_Type__c  from ccrz__E_AccountGroupPriceList__c where ccrz__Enable__c = true and ccrz__AccountGroup__c in:accountGrpset and ccrz__Pricelist__r.ccrz__Enabled__c = true and ccrz__StartDate__c <= :today and ccrz__EndDate__c >= :today and (ccrz__Pricelist__r.EC_Price_List_Type__c = 'FlatFee' or ccrz__Pricelist__r.EC_Price_List_Type__c = 'NoCharge') and ccrz__Pricelist__r.ccrz__StartDate__c <= :today and ccrz__Pricelist__r.ccrz__EndDate__c >= :today ];
        }
        return acctGrpPriceLists;
    }
}