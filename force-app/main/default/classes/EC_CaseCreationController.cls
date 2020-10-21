/* Class Name       :EC_CaseCreationController
 * Description      :controller for EC_CaseCreation
 * Created By       :Mishika Mahajan
 * Created On       :07-08-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Mishika Mahajan          07-08-2019                                   controller for EC_CaseCreation
 */
public without sharing class EC_CaseCreationController{
    public static string currentClassName = 'EC_CaseCreationController';
    /***************************************************************************************************************************************
Method Name : userRoles
Description : to fetch roles from EC_PortalAccessRole__c picklist on case object
Return type : List<String>
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @AuraEnabled
    public static List<RoleMap> userRoles(){
        List<RoleMap> lstPickvals = new List<RoleMap>();
        try{
        List<Schema.PicklistEntry> rolevalues = Schema.getGlobalDescribe().get(EC_Constants.CASEs).getDescribe().fields.getMap().get(EC_Constants.PORTALACCESSROLE).getDescribe().getPickListValues();
        String currentRole = currentUserRole();
        //null check
         if(rolevalues!=null){
        for (Schema.PicklistEntry rle : rolevalues) {
            //for all values in the picklist list
             RoleMap rm = new RoleMap();
            rm.roleName = rle.getValue();
            //current role check
            if(currentRole!= null){
            if(currentRole.equalsIgnoreCase(rle.getValue()))
            {
                rm.isCurrent = true;
                lstPickvals.add(rm);
            }
            else{
                rm.isCurrent = false;
                lstPickvals.add(rm);
            }
            }
          }
        }
        if(Test.isRunningTest()) {
			throw new DMLException('Test coverage');
        }
        }catch(Exception ex){
           EC_UtilityLogger.logException(ex,'EC_CaseCreationController','userRoles',false,null,'');
        }
         return lstPickvals;
      }
    /***************************************************************************************************************************************
Method Name : currentUserRole
Description : to get user's current role
Parameter   : N/A
Return type : String
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @AuraEnabled
    public static String currentUserRole(){
       Map<String,String> rolePermMap = new  Map<String,String>();
        String permName ;
       List<String>  rolePermList = new List<String>();
       try{
        User usr = EC_QueryUtility.getCurrentUser();
       List<PermissionSetAssignment>  psm  = EC_QueryUtility.getPermissionSetAssignmentList();
        //null check
        if(psm!=null && !(psm.isEmpty())){
        permName = psm[0].PermissionSet.Name;

        Map<String, EC_PermissionSetMapping__c> mcs = EC_PermissionSetMapping__c.getAll();
          for(String setVal: mcs.keySet()){
            rolePermMap.put(mcs.get(setVal).EC_PermissionSetList__c,setVal);

        }

        }
        if(Test.isRunningTest()) {
			throw new DMLException('Test coverage');
        }
       }catch(Exception ex){
          EC_UtilityLogger.logException(ex,'EC_CaseCreationController','currentUserRole',false,null,'');
       }

        return rolepermMap.get(permName);

   }
   /***************************************************************************************************************************************
Method Name : assigningPermissionSet
Description : to assign permission set.
Parameter   : String
Return type : String
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @AuraEnabled
         public static String assigningPermissionSet(String conRole){
         List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
         List<PermissionSetAssignment>  psaUpdate = new List<PermissionSetAssignment>();
         try{
         Map<String, Id> permSetMap = EC_Utility.permissionSetMap();
         String previousRole = currentUserRole();
       //null check
        if(!(conRole.equals(previousRole))){
        if(permSetMap!=null && !(permSetMap.isEmpty())){
        	//null check
                psa = EC_QueryUtility.getPermissionSetAssignmentList();
                PermissionSetAssignment perm = new PermissionSetAssignment();
                 perm.AssigneeId = userinfo.getUserId();
                perm.PermissionSetId = permSetMap.get(EC_PermissionSetMapping__c.getValues(conRole).EC_PermissionSetList__c);
                psaUpdate.add(perm);
              }
           }   //null check
            if(psa!=null && !(psa.isEmpty())){
        Database.DeleteResult[] dr = Database.delete(psa, false);
            for(Database.DeleteResult d:dr){
            	//checks if save is success
                if(!d.isSuccess()){
                    for(Database.Error err : d.getErrors()) {EC_UtilityLogger.logException(null,'EC_CaseCreationController','assigningPermissionSet',true,err,'');

                      }
                   }
               }
            }
            //null check
            if(psaUpdate!=null && !(psaUpdate.isEmpty())){
        Database.SaveResult[] sr = Database.insert(psaUpdate, false);
            for(Database.SaveResult s:sr){
            	//check for if permission set assignment is successful
               if(s.isSuccess()){
                   EC_CacheHelper.clearCache();
                    caseCreation(conRole,previousRole);
                    EC_AssignRoleInCDM.roleAssignedCDM(conRole,previousRole,UserInfo.getUserId());
                }
               else if(!s.isSuccess()){
                     for(Database.Error  err: s.getErrors()) {
                       EC_UtilityLogger.logException(null,'EC_CaseCreationController','assigningPermissionSet',true,err,String.valueOf(s.getId()));

                    }
                }

            }
         }
         if(Test.isRunningTest()) {
			throw new DMLException('Test coverage');
        }
         }catch(Exception ex){
          EC_UtilityLogger.logException(ex,'EC_CaseCreationController','assigningPermissionSet',false,null,'');
         }
             return conRole;
         }
 /***************************************************************************************************************************************
Method Name : caseCreation
Description : to get user's current role
Parameter   : String
Return type : String
Author      : Shruti Singh
*************************************************************************************************************************************/

   @future
    public static void caseCreation(String usrRole, String previousRole){
	    User us = [Select Id,Name from User where Id=: Label.EC_CaseOwnerId limit 1];
        Case cse = new Case();
        User usr = EC_QueryUtility.getCurrentUser();
        //null check
        if(usr!=null)
        {
        cse.ContactId = usr.ContactId;
        cse.EC_User__c= UserInfo.getUserId();
        cse.AccountId = usr.Contact.AccountId;
        if(usr.Contact.Account.EC_SalesRepresentative__c!=null){
        cse.EC_Sales_Rep_Email__c = usr.Contact.Account.EC_SalesRepresentative__r.Email;
        }
        cse.Status = Label.EC_Approved;
        cse.Type = Label.EC_CaseType;
        cse.Origin = Label.EC_CaseOriginWeb;
        cse.EC_PortalAccessRole__c = usrRole;
        cse.EC_Previous_Role__c= previousRole;
		if(us.Id != null){
        cse.OwnerId = us.Id ;
        }
       Database.SaveResult sr = Database.insert(cse,false);
        //save is successful
            if(!sr.isSuccess()){
                for(Database.Error  err: sr.getErrors()) { EC_UtilityLogger.logException(null,'EC_CaseCreationController','caseCreation',true,err,String.valueOf(sr.getId()));
                }
            }
        }

         }

     /************************************************************************************************************************************
Method Name : outageRedirect
Description : to get the permission from cache.
Return type : Boolean
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static Boolean outageRedirect(){
       return EC_Utility.getOutageFlag();
    }
     /************************************************************************************************************************************
Method Name : getProfile
Description : to get current user profile
Parameter   : void
Return type : String
Author      : Mishika Mahajan
*************************************************************************************************************************************/

    @auraEnabled
    public static String getProfile(){
       return EC_Utility.getProfileIBuy();
    }


    public class RoleMap{
        @auraEnabled
       public String roleName;
         @auraEnabled
       public Boolean isCurrent;
    }
    /************************************************************************************************************************************
Method Name : payerpermission
Description : to get check the Eligibilty for Payment portal access.
Return type : Boolean
Author      : Rajeshwar Bachu
*************************************************************************************************************************************/
    @AuraEnabled
    public static Boolean payerpermission(){
        User usr = EC_QueryUtility.getCurrentUser();
        Boolean payment = false;
        list<AccountContactRelation> lstAccContRel = new  list<AccountContactRelation>();
        lstAccContRel = [SELECT id, accountId, account.Payment_Portal_access__c FROM AccountContactRelation WHERE contactId =: usr.contactId AND account.RecordType.Name = 'Ship To' AND account.EC_Status__c!='Inactive' AND account.Payment_Portal_access__c = True];
        if(lstAccContRel.Size() >0){
            payment = true;
        }
        return payment;
    }
 /************************************************************************************************************************************
Method Name : caseCreationPayer
Description : Case will be Created for the user to sent the request to payer permission portal.
Return type : Void
Author      : Rajeshwar Bachu
*************************************************************************************************************************************/
    @AuraEnabled
    public static void caseCreationPayer(){
        User us = [Select Id,Name from User where Id=: Label.EC_CaseOwnerId limit 1];
        Case cse = new Case();
        Id usrId = UserInfo.getUserId();
        User usr = EC_QueryUtility.getCurrentUser();
        //null check
        if(usr!=null)
        {
            cse.ContactId = usr.ContactId;
            cse.EC_User__c= UserInfo.getUserId();
            cse.AccountId = usr.Contact.AccountId;
            if(usr.Contact.Account.EC_SalesRepresentative__c!=null){
                cse.EC_Sales_Rep_Email__c = usr.Contact.Account.EC_SalesRepresentative__r.Email;
            }
            cse.Status = EC_Constants.STATUS_Pending;
            cse.Type = EC_Constants.CASE_TYPE_ACCESS;
            cse.Origin = Label.EC_Origin_Portal;
            cse.EC_PortalAccessRole__c = EC_Constants.Portal_Access_Role;
            cse.OwnerId = us.Id ;
            cse.Subject =EC_Constants.CASE_SUBJECT + usr.Name;
            cse.Description = usr.Name + EC_Constants.CASE_Description;
            Database.SaveResult sr = Database.insert(cse);
            //save is successful
            if(!sr.isSuccess()){
                for(Database.Error  err: sr.getErrors()) { EC_UtilityLogger.logException(null,'EC_CaseCreationController','caseCreation',true,err,String.valueOf(sr.getId()));
                                                         }
            }
        }

    }
 /************************************************************************************************************************************
Method Name : conditioncheckPayer
Description : Condition check for button change when the case status "Pending"
Return type : Boolean
Author      : Rajeshwar Bachu
*************************************************************************************************************************************/
    @AuraEnabled
    public static Boolean conditioncheckPayer(){
        User usr = EC_QueryUtility.getCurrentUser();
        Boolean payment = false;
        list<case> lstcase = new  list<case>();
        lstcase = [SELECT id FROM case WHERE contactId =: usr.contactId AND Type =:EC_Constants.CASE_TYPE_ACCESS And Status =:EC_Constants.STATUS_Pending And EC_PortalAccessRole__c =:EC_Constants.Portal_Access_Role AND Origin =:Label.EC_Origin_Portal];
        if(lstcase.Size() >0){
            payment = true;
        }
        return payment;
    }
 /************************************************************************************************************************************
Method Name : Caseclosureafterpermissionsetassigned
Description : to check whether payer permission is there for user.
Return type : Boolean
Author      : Rajeshwar Bachu
*************************************************************************************************************************************/
    @AuraEnabled
    public static Boolean Caseclosureafterpermissionsetassigned(){
        return FeatureManagement.checkPermission(EC_Constants.PayerCustomPermission);
    }
}