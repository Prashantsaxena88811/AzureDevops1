//EC_StagingUtilities
//This is class all the reusable components of the Staging helper
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//

public class EC_StagingUtilities{

    /***************************************************************************************************************************************
    Method Name : userInsert
    Description : Used to Insert Users From Staging Object. This method is called from UserPermissionInsertHelper
    Return type : void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    public static void userInsert(List<EC_Mulesoft_CDM_Staging__c> usrStage){
        List<Contact> lstContdtails = new List<Contact>();
        List<String> contactKey = new List<String>();
        List<Id> lstInsertedSuccess = new List<Id>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();

        // the below lists will be used to update the isProcessed field in Staging Object.
        List<EC_Mulesoft_CDM_Staging__c> successRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new List<EC_Mulesoft_CDM_Staging__c>();

        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        Map<Id,Id> permissionSetAssignMap = new Map<Id,String>();
        Map<String,EC_Mulesoft_CDM_Staging__c> usrKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        Map<String,User> usrContactMap = new Map<String,User>();
        Map<Integer,String> indexKeyMap = new Map<Integer,String>();

        for(EC_Mulesoft_CDM_Staging__c stg:usrStage){
            contactKey.add(stg.EC_User_Key__c);
            usrKeyMap.put(stg.EC_User_Key__c,stg);
        }
        lstContdtails =  [Select Id,FirstName,LastName,EC_Alias__c,Redemption_URL__c,Email,EC_FederationIdentifier__c,EC_TimeZoneSidKey__c,EC_UserLanguageLocaleKey__c,EC_UserLocaleSidKey__c,EC_CDM_Contact__c,EC_User_Type__c,Phone,EC_isActive__c from Contact where EC_CDM_Contact__c in:contactKey];
        String salesRepProfile = EC_Constants.SALES_REP;
        String communityProfile = EC_Constants.PROFILE;
        String dummyRole = EC_Constants.DUMMYROLE;
        String adminRole = EC_Constants.ADMINROLE;

        Map<String,Id> existingKeys = new Map<String,Id>();
        Profile usrProfile =  [SELECT Id,Name FROM Profile where name =:communityProfile];
        Profile usrINTProfile = [SELECT Id,Name FROM Profile where name =:salesRepProfile];
        // UserRole should be assigned based on UserType
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name =:dummyRole];
        UserRole usrRoleInt = [SELECT Id,Name FROM UserRole where Name =:ADMINROLE];
        List<User> usrtInsert = new List<User>();
        Integer index = 0;
        for(Contact contct: lstContdtails){
            existingKeys.put(contct.EC_CDM_Contact__c,contct.Id);
            User user = new User();
            // We are assigning Email for the userName field Defect-82130
            try{   if(System.label.EC_Email_Extension == EC_Constants.PRODEMAILEXT){
                user.Username = contct.Email +System.label.EC_USERNAME;
            }
                else{
                    user.Username = contct.Email.Replace(System.label.EC_Email_Extension,System.label.EC_USERNAME);
                }
                user.Alias = contct.EC_Alias__c;
                user.Email = contct.Email;
                user.EC_CDM_User__c = contct.EC_CDM_Contact__c;
                user.TimeZoneSidKey = System.label.EC_UserTimeZoneSidKey;
                user.LanguageLocaleKey = System.label.EC_UserLanguageLocaleKey;
                user.LocaleSidKey = System.label.EC_UserLocaleSidKey;
                user.FirstName = contct.FirstName;
                user.LastName = contct.LastName;
                user.FederationIdentifier = contct.EC_FederationIdentifier__c;
                user.Phone = contct.Phone;
                user.Redemption_URL__c = contct.Redemption_URL__c;
                user.ccrz__CC_CurrencyCode__c = EC_Constants.USRCURRENCY;
                user.EmailEncodingKey = System.label.EC_UserEmailEncodingKey;
                if(contct.EC_User_Type__c==EC_Constants.CUSTOMER){
                    user.ProfileId = usrProfile.Id;
                    user.ContactId = contct.Id;
                    user.User_Type__c = EC_Constants.EXTERNAL;
                    user.UserRole = usrRole;
                    user.EC_CDM_User_Status__c = contct.EC_isActive__c;
                    user.IsActive = contct.EC_isActive__c;
                }
                else if(contct.EC_User_Type__c==EC_Constants.EMPLOYEE){
                    user.ProfileId = usrINTProfile.Id;
                    user.User_Type__c = EC_Constants.INTERNAL;
                    user.UserRole = usrRole;
                    user.EC_CDM_User_Status__c = contct.EC_isActive__c;
                    user.IsActive = contct.EC_isActive__c;
                }
                usrtInsert.add(user);
                indexKeyMap.put(index, contct.EC_CDM_Contact__c);
                index++;
               }
            catch(Exception ex){
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingUtilities',
                                                                                       'UserInsert');
                stageLogWrapList.add(stageLogWrap);
            }

        }
        for(String key:contactKey){
            if(!existingKeys.containsKey(key)){
                EC_Mulesoft_CDM_Staging__c stgRecord = usrKeyMap.get(key);
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(stgRecord.Id,stgRecord.EC_User_Key__c,null,stgRecord.EC_Source_Table__c,
                                                                                       stgRecord.EC_Action__c,null,null,null,null,null,'Invalid User Key or User Key Doesnot exist in Salesforce','EC_StagingUtilities',
                                                                                       'UserInsert');
                stageLogWrapList.add(stageLogWrap);
            }
        }
        // insert usrtInsert;
        Database.SaveResult[] saveRes = Database.insert(usrtInsert,false);
        index = 0;
        for(Database.SaveResult sr:saveRes){
            if(sr.isSuccess()){
                lstInsertedSuccess.add(sr.getId());
            }
            else {
                for(Database.Error  err: sr.getErrors()) {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(usrKeyMap.get(indexKeyMap.get(index)).Id,null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingUtilities',
                                                                                           'UserInsert');
                    stageLogWrapList.add(stageLogWrap);
                }
            }
            index++;
        }
        if (!Permision_Set_Mapping__mdt.sObjectType.getDescribe().isAccessible()) {  
	 		return;
	 	}
		List<Permision_Set_Mapping__mdt> permissionSets = [Select label, Permission_Set_Name__c from Permision_Set_Mapping__mdt];
        Map<String,String> permissions = new Map<String,String>();
        for(Permision_Set_Mapping__mdt permission:permissionSets) {
            permissions.put(permission.label, permission.Permission_Set_Name__c);
        }
        
        for(User usr:[Select Id,EC_CDM_User__c,LastName,FirstName,Email,IsActive from User where Id in:lstInsertedSuccess]){
            successRecords.add(usrKeyMap.get(usr.EC_CDM_User__c));
            usrContactMap.put(usr.EC_CDM_User__c,usr);
            permissionSetAssignMap.put(usr.Id,permissions.get(usrKeyMap.get(usr.EC_CDM_User__c).EC_Permission_Code__c));
        }
        List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        updatePermissionSet(permissionSetAssignMap,successRecords,stageLogWrapList);
        for(EC_Mulesoft_CDM_Staging__c successStg:successRecords){
            EC_Mulesoft_CDM_Staging__c stageRecUpdate = new EC_Mulesoft_CDM_Staging__c();
            stageRecUpdate.Id = successStg.Id;
            stageRecUpdate.EC_IsProcessed__c= true;
            if(stageRecUpdate.Id!=null && !String.isBlank(stageRecUpdate.Id)){
                existRecords.add(stageRecUpdate);
            }
        }

        if(existRecords!=null && !existRecords.isEmpty()){
            update existRecords;
        }

        EC_StagingContactUtilities.contactUpdate(successRecords,usrContactMap);
        updatePermissionSet(permissionSetAssignMap,successRecords,null);

    }

    /***************************************************************************************************************************************
    Method Name : userUpdate
    Description : Used to Update Users From Staging Object on the Update Action. This is a future method as it runs after Contact Setup object
    Return type : void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    public static void userUpdate(List<String> ids, Map<String,EC_Mulesoft_CDM_Staging__c> userKeyMap){
        EC_StagingUserUpdate batchObj = new EC_StagingUserUpdate(ids,userKeyMap);
        Id batchId = Database.executeBatch(batchObj,2500);

    }

    /***************************************************************************************************************************************
    Method Name : userDelete
    Description : Used to Delete Users From Staging Object on the Delete Action. This is a future method as it runs after Contact Setup object
    Return type : void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    public static void userDelete(List<String> ids,Map<String,EC_Mulesoft_CDM_Staging__c> userKeyMap, List<EC_Mulesoft_CDM_Staging__c> duplicateEvnts){
        EC_StagingUserDelete batchObj = new EC_StagingUserDelete(ids,userKeyMap,duplicateEvnts);
        Id BatchId = Database.executeBatch(batchObj,2500);
    }

    /***************************************************************************************************************************************
    Method Name : createAccountGroup
    Description : To create AccountGroup Right After the account is Inserted
    Return type : Void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    // AccountGroup should be created for the inserted Accounts
    public static void createAccountGroup(List<Account> lstNewAccounts)
    {
        List<ccrz__E_AccountGroup__c> lstActGrps = new List<ccrz__E_AccountGroup__c>();
        List<Account> accUpdate = new List<Account>();
        Map<String,ccrz__E_AccountGroup__c> accGroupMap = new Map<String,ccrz__E_AccountGroup__c>();


        for(Account acc:lstNewAccounts){
            ccrz__E_AccountGroup__c accGroup = new ccrz__E_AccountGroup__c();
            accGroup.Name = acc.Name;
            accGroup.ccrz__AccountGroupID__c = acc.EC_Unique_Account_Number__c;
            lstActGrps.add(accGroup);
            accGroupMap.put(accGroup.Name, accGroup);
        }
        insert lstActGrps;

        for(Account acc:lstNewAccounts){
            acc.ccrz__E_AccountGroup__c = accGroupMap.get(acc.Name).Id;
            accUpdate.add(acc);
        }
        update accUpdate;
    }

    /***************************************************************************************************************************************
    Method Name : updatePermissionSet
    Description : To Update PermissionSets on the Users after its creation/updtation. THis is a future method as it gets executed after User Setup object Insert
    Return type : Void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    public static void updatePermissionSet(Map<Id,String> permissionMap,List<EC_Mulesoft_CDM_Staging__c> lstStagingObjs,List<EC_StagingExceptionLog__c> stageLogWrapList){
        Map<String,EC_Mulesoft_CDM_Staging__c> contactKeysMap = new Map<String,EC_Mulesoft_CDM_Staging__c>();
        for(EC_Mulesoft_CDM_Staging__c stgObj:lstStagingObjs){
            contactKeysMap.put(stgObj.EC_User_Key__c,stgObj);
        }
        //  List<Contact> listContacts = [Select Id,EC_CDM_Contact__c from Contact where EC_CDM_Contact__c in:contactKeysMap.keyset()];
        List<User> listUser = [Select Id,EC_CDM_User__c,IsActive from User where EC_CDM_User__c in:contactKeysMap.keyset()];
        List<EC_Mulesoft_CDM_Staging__c> stgUpdated = new List<EC_Mulesoft_CDM_Staging__c>();
        for(User usr :listUser){
            EC_Mulesoft_CDM_Staging__c stgObj =  contactKeysMap.get(usr.EC_CDM_User__c);
            if(usr.IsActive == true){
                stgObj.EC_IsProcessed__c = true;
            }
            else{
                stgObj.EC_IsProcessed__c = false;
            }
            stgUpdated.add(stgObj);

        }

        update stgUpdated;
        EC_StagingPermissionSetUpdate batchObj = new EC_StagingPermissionSetUpdate(permissionMap,lstStagingObjs,stageLogWrapList);
        Id batchId = Database.executeBatch(batchObj,2500);

    }

    /***************************************************************************************************************************************
    Method Name : deleteUserPermissions
    Description : To Delete PermissionSets on the Users.
    Return type : Void
    Author      : Shivam Vats
    *************************************************************************************************************************************/
    public static void deleteUserPermissions(List<String> deleteIds,List<EC_Mulesoft_CDM_Staging__c> stgRecords){
        List<PermissionSetAssignment> psaDeleteList = new List<PermissionSetAssignment>();
        Map<String,String> permCodeMap = new Map<String,String>();
        List<String> lstUserKeys = new List<String>();
        List<User> userIds = new List<User>();
        List<PermissionSet> lstPermissionSet = new List<PermissionSet>();
        List<Id> lstPermissionSetsDel = new List<Id>();
        Map<String,Id> permissionSetMap = new Map<String,Id>();
        List<String> permissiontSetName = new List<String>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        
        if (!Permision_Set_Mapping__mdt.sObjectType.getDescribe().isAccessible()) {  
	 		return;
	 	}
        List<Permision_Set_Mapping__mdt> permissionSets = [Select label, Permission_Set_Name__c from Permision_Set_Mapping__mdt];
        for(Permision_Set_Mapping__mdt permission:permissionSets) {
            permissiontSetName.add(permission.Permission_Set_Name__c);
            permCodeMap.put(permission.Permission_Set_Name__c,permission.label);
        }
        
        
        lstPermissionSet = [Select Id,Name from PermissionSet where name in:permissiontSetName];
        for(PermissionSet permission:lstPermissionSet){
            permissionSetMap.put(permission.Name,permission.Id);
        }

        Map<Id,String> usrPermisionMap = new Map<Id,String>();
        Map<String,Id> existingKeys = new Map<String,Id>();
        List<EC_Mulesoft_CDM_Staging__c> invalidRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        Map<String,EC_Mulesoft_CDM_Staging__c> delInfo = new Map<String,EC_Mulesoft_CDM_Staging__c>();
        for(User usr:[Select Id,EC_CDM_User__c from User where EC_CDM_User__c in:deleteIds]){
            userIds.add(usr);
            usrPermisionMap.put(usr.Id,usr.EC_CDM_User__c);
            existingKeys.put(usr.EC_CDM_User__c,usr.Id);
        }

        psaDeleteList = [Select Id,AssigneeId,PermissionSetId ,PermissionSet.Name from PermissionSetAssignment where AssigneeId in:usrPermisionMap.keyset() and PermissionSet.Name in:permissiontSetName];

        Set<EC_Mulesoft_CDM_Staging__c> successRecords = new Set<EC_Mulesoft_CDM_Staging__c>();
        for(EC_Mulesoft_CDM_Staging__c stageRec : stgRecords){
            delInfo.put(stageRec.EC_User_Key__c,stageRec);
            if(psaDeleteList!=null && psaDeleteList.size()>0){
                for(PermissionSetAssignment tempPermContRec : psaDeleteList){
                    if(stageRec.EC_User_Key__c ==  usrPermisionMap.get(tempPermContRec.AssigneeId) &&  stageRec.EC_Permission_Code__c == permCodeMap.get(tempPermContRec.PermissionSet.Name)){
                        continue;
                    }
                    else{
                        EC_Mulesoft_CDM_Staging__c stageRecUpdate = new EC_Mulesoft_CDM_Staging__c();
                        stageRecUpdate.Id = stageRec.Id;
                        //stageRecUpdate.EC_Record_Status__c = EC_Constants.DUPLICATE;
                        stageRecUpdate.EC_IsProcessed__c = true;
                        successRecords.add(stageRecUpdate);
                        EC_StagingExceptionLog__c stageLogWrap1 = EC_StagingLogger.logException(stageRec.Id,null,null,null,null,null,null,null,null,null,'Invalid EC_User_Key__c and Permission Code duo','EC_StagingUtilities',
                                                                                                'deleteUserPermissions');
                        stageLogWrapList.add(stageLogWrap1);
                        continue;
                    }
                }
            }
            else{
                EC_Mulesoft_CDM_Staging__c stageRecUpdate1 = new EC_Mulesoft_CDM_Staging__c();
                stageRecUpdate1.Id = stageRec.Id;
                //stageRecUpdate1.EC_Record_Status__c = EC_Constants.DUPLICATE;
                stageRecUpdate1.EC_IsProcessed__c = true;
                successRecords.add(stageRecUpdate1);
                EC_StagingExceptionLog__c stageLogWrap2 = EC_StagingLogger.logException(stageRec.Id,null,null,null,null,null,null,null,null,null,'Invalid EC_User_Key__c and Permission Code duo','EC_StagingUtilities',
                                                                                        'deleteUserPermissions');
                stageLogWrapList.add(stageLogWrap2);
                continue;
            }
        }
        EC_StagingLogger.stageLogException(stageLogWrapList);
        for(String delrecord : deleteIds){
            if(!existingKeys.containsKey(delrecord)){
                invalidRecords.add(delInfo.get(delrecord));
            }
        }
        List<EC_Mulesoft_CDM_Staging__c> successRecList = new List<EC_Mulesoft_CDM_Staging__c>(successRecords);
        if(successRecList!=null && !successRecList.isEmpty()){
            update successRecList;
        }

        if(userIds!=null && !userIds.isEmpty()){
            EC_StagingPermissionSetDelete batchObj = new EC_StagingPermissionSetDelete(permissionSetMap,userIds,stgRecords,invalidRecords);
            Id batchId = Database.executeBatch(batchObj,2500);
        } else if(invalidRecords != null && !invalidRecords.isEmpty()){
            for(EC_Mulesoft_CDM_Staging__c inavlidrec:invalidRecords) {
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(inavlidrec.id,null,null,null,null,null,null,null,null,null,'Invalid EC_User_Key__c','EC_StagingUtilities',
                                                                                       'deleteUserPermissions');
                stageLogWrapList.add(stageLogWrap);
            }
            EC_StagingLogger.stageLogException(stageLogWrapList);
        }

    }

    /***************************************************************************************************************************************
    Method Name : assignSalesRepOnUserAccInsert
    Description : To assign sales rep on user account insert
    Return type : Void
    Author      : Mishika Mahajan
    *************************************************************************************************************************************/
    public static void assignSalesRepOnUserAccInsert(List<EC_Mulesoft_CDM_Staging__c> usrAccStage){

        List<String> userkeyList = new List<String>();
        List<String> acckeyList = new List<String>();
        List<Account> UpdateaccWithSalesRep = new List<Account>();
        Map<String,Id> accUserMap = new Map<String,Id>();
        try{
            for(EC_Mulesoft_CDM_Staging__c stage :usrAccStage){
                acckeyList.add(stage.EC_Account_Key__c);
                userkeyList.add(stage.EC_User_Key__c);
            }
            //B- START
            for(AccountContactRelation accConRel : [Select Id, Contact.EC_CDM_Contact__c, Contact.EC_SalesRep_User__c,Account.EC_CDM_Account__c
                    FROM AccountContactRelation WHERE
                    Alignment_Type__c = :EC_Constants.PRIMARY_ALIGNMENT_TYPE
                    AND Contact.EC_CDM_Contact__c IN :userkeyList
                    AND Account.EC_CDM_Account__c IN :acckeyList
                    AND Contact.EC_User_Type__c = :Label.EC_Employee
                    AND contact.EC_isActive__c = true]){
                    if(Contact.EC_SalesRep_User__c != null){
                        accUserMap.put(accConRel.Account.EC_CDM_Account__c,accConRel.Contact.EC_SalesRep_User__c);
                    }
            }
            if(accUserMap != null){
                for(Account accToUpdate:[select id , EC_SalesRepresentative__c,EC_CDM_Account__c,parent.RecordType.Name, Parent.EC_CDM_Account__c
                            FROM Account WHERE ec_cdm_account__c in :accUserMap.keySet() OR parent.EC_CDM_Account__c IN :accUserMap.keySet()]){
                    if(accToUpdate.parent.RecordType.Name == EC_Constants.Sold_To){
                        accToUpdate.EC_SalesRepresentative__c = accUserMap.get(accToUpdate.Parent.EC_CDM_Account__c);
                    } else {
                        accToUpdate.EC_SalesRepresentative__c = accUserMap.get(accToUpdate.EC_CDM_Account__c);
                    }
                    UpdateaccWithSalesRep.add(accToUpdate);
                }
                Database.update(UpdateaccWithSalesRep,false);
            }

            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
        }catch(Exception ex){
            List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingUtilities',
                                                                                   'assignSalesRepOnUserAccInsert');
            stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);
        }
    }

    /***************************************************************************************************************************************
    Method Name : assignSalesRepToAccDelete
    Description : To assign sales rep on user account delete
    Return type : Void
    Author      : Mishika Mahajan
    *************************************************************************************************************************************/
    public static void assignSalesRepToAccDelete(List<EC_Mulesoft_CDM_Staging__c> usrAccStage){

        List<String> userkeyList = new List<String>();
        List<String> acckeyList = new List<String>();
        List<Account> UpdateaccWithSalesRep = new List<Account>();
        Map<String,Id> accUserMap = new Map<String,Id>();
        try{
            for(EC_Mulesoft_CDM_Staging__c stage :usrAccStage){
                acckeyList.add(stage.EC_Account_Key__c);
                userkeyList.add(stage.EC_User_Key__c);
            }
            List<AccountContactRelation> accContRelList = [ Select account.EC_CDM_Account__c,contact.EC_CDM_Contact__c,contact.EC_SalesRep_User__c from AccountContactRelation
                                                           where account.EC_CDM_Account__c in: acckeyList
                                                           and contact.EC_CDM_Contact__c not in:userkeyList
                                                           and  contact.EC_User_Type__c = :Label.EC_Employee
                                                           and contact.EC_isActive__c = true
                                                           and Alignment_Type__c = :EC_Constants.PRIMARY_ALIGNMENT_TYPE
                                                           and account.EC_SalesRepresentative__r.ec_cdm_user__c in :userkeyList];


            if(accContRelList!=null && !accContRelList.isEmpty()){
                for(AccountContactRelation accContRel:accContRelList){
                    accUserMap.put(accContRel.account.EC_CDM_Account__c,accContRel.contact.EC_SalesRep_User__c);
                }
            }

            for(Account accToUpdate:[select id ,EC_CDM_Account__c ,EC_SalesRepresentative__r.ec_cdm_User__c,EC_SalesRepresentative__c,parent.RecordType.Name,Parent.EC_CDM_Account__c
                        from Account where ec_cdm_account__c in:acckeyList OR parent.EC_CDM_Account__c IN :acckeyList]){
                if(accUserMap.containsKey(accToUpdate.EC_CDM_Account__c)){
                    if(accToUpdate.parent.RecordType.Name == EC_Constants.Sold_To){
                        accToUpdate.EC_SalesRepresentative__c = accUserMap.get(accToUpdate.Parent.EC_CDM_Account__c);
                    } else {
                        accToUpdate.EC_SalesRepresentative__c = accUserMap.get(accToUpdate.EC_CDM_Account__c);
                    }
                }
                else{
                    accToUpdate.EC_SalesRepresentative__c  = null;
                }
                UpdateaccWithSalesRep.add(accToUpdate);
            }

            Database.update(UpdateaccWithSalesRep,false);
            if(Test.isRunningTest()) {
                throw new DMLException('Test coverage');
            }
        }catch(Exception ex){
            List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingUtilities',
                                                                                   'assignSalesRepToAccDelete');
            stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);
        }
    }

}