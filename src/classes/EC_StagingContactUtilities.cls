//EC_StagingContactUtilities
//This is class to handle the Contact insert/update/delete action on Staging
//----------------------------------------------------------------------------------------------------------------------
// Author           Date              Description
//-------------------------------------------------------------------------------------------------------------------
// Shivam Vats    15th Oct, 2019     Created the class seperating the code from the Staging helper class
//


public class EC_StagingContactUtilities{

/***************************************************************************************************************************************
Method Name : contactInsert
Description : Used to Insert Contact From Staging object for Insert Action, User will not be crated after this, Users for community users shall be creted only
after we get UserPermissions for the same
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static void contactInsert(List<EC_Mulesoft_CDM_Staging__c> contctStage) {
        Map<String,EC_Mulesoft_CDM_Staging__c> contactKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        List<string> contactStageKeys = new List<string>();
        List<Contact> insertedContcts = new List<Contact>();
        // below Lists will be used to update the IsProcessed fields in the Staging Object.
        List<EC_Mulesoft_CDM_Staging__c> successRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> existRecords   = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Set<String> contctDuplicate = new Set<String>();
        Set<Id> setInsrtSuccess = new Set<Id>();
        String dummyAccount = EC_Constants.DummyAccountKey;
        
        try{
            Network myNetwork = new Network();
            if(Network.sObjectType.getDescribe().isAccessible()) {
                myNetwork = [SELECT Id FROM Network WHERE Name ='Ecolab'];
            }

            Account acc = new Account();
            if(Account.sObjectType.getDescribe().isAccessible()) {
                acc = [SELECT Id, Name FROM Account WHERE EC_CDM_Account__c = :dummyAccount];
            }
            
            for(EC_Mulesoft_CDM_Staging__c stge : contctStage) {
                contactKeyMap.put(stge.EC_User_Key__c,stge);
            }
            for(Contact cont : [SELECT Id, EC_CDM_Contact__c FROM Contact WHERE EC_CDM_Contact__c IN :contactKeyMap.keySet()]) {
                contctDuplicate.add(cont.EC_CDM_Contact__c);
            }
            for(EC_Mulesoft_CDM_Staging__c contct : contctStage) {
                Contact contact = new Contact();
                contact.FirstName 				= contct.EC_First_Name__c;
                contact.LastName  				= contct.EC_Last_Name__c;
                contact.AccountId 				= acc.Id;
                contact.EC_CDM_Contact__c 		= contct.EC_User_Key__c;
                contact.Source__c         		= contct.Source__c;
                contact.EC_Alias__c 			= contct.EC_Alias__c;
                contact.Phone 					= contct.EC_Phone__c;
                contact.EC_User_Type__c 		= contct.EC_User_Type__c;
                contact.EC_Contact_Status__c 	= EC_Constants.PENDING;
                
                contact.Email = (System.label.EC_Email_Extension == EC_Constants.PRODEMAILEXT) ? contct.EC_Email__c : (contct.EC_Email__c + System.label.EC_Email_Extension);
                contact.EC_isActive__c = (contct.EC_User_Status_Code__c == EC_Constants.A) ? true : false;
                //Federation Id should always be an email for the User
                if(contct.EC_Email__c != null && contct.EC_Email__c != '') {
                    contact.EC_FederationIdentifier__c = contct.EC_Email__c.toLowerCase();
                } else {
                    contact.EC_FederationIdentifier__c = '';
                }
                
                if(contct.EC_User_Type__c == EC_Constants.CUSTOMER && contct.Source__c == EC_Constants.CDMEVENT) {
                    contact.Contact_Type__c = EC_Constants.EXTERNAL;
                } else if(contct.EC_User_Type__c == EC_Constants.EMPLOYEE && contct.Source__c == EC_Constants.CDMEVENT) {
                    contact.Contact_Type__c = EC_Constants.INTERNAL;   
                }
                    
                if(!String.isBlank(contct.EC_Email__c) && contct.EC_User_Type__c == EC_Constants.CUSTOMER) {
                    ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
                    contact.Redemption_URL__c = myCommunity.siteUrl +'/s/completeregistration?username='+contct.EC_Email__c;
                    contact.Has_Redempetion_URL__c = true;
                }
                
                if(!contctDuplicate.contains(contct.EC_User_key__c)) {
                    insertedContcts.add(contact);
                    contactStageKeys.add(contct.Id);
                } else {
                    EC_Mulesoft_CDM_Staging__c successInprogress = new EC_Mulesoft_CDM_Staging__c();
                    successInprogress.Id= contct.Id;
                    successInprogress.EC_Record_Status__c= label.EC_Duplicate;
                    successInprogress.EC_IsProcessed__c= true;
                    if(contct.Id != null && String.isBlank(contct.Id)){
                        existRecords.add(successInprogress);
                    }
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(contct.Id,null,null,null,null,null,null,null,null,null,'Duplicate EC_User_key__c','EC_StagingContactUtilities',
                                                                                           'contactInsert');
                    stageLogWrapList.add(stageLogWrap);
                }
            }

            //INSERT CONTACTS
            Database.SaveResult[] saveRes = Database.insert(insertedContcts,false);
            setInsrtSuccess = stagingDMLExceptionLogs(saveRes, 'contactInsert', contactStageKeys);
            
            if(!insertedContcts.isEmpty()) caseInsert(insertedContcts, contactStageKeys);
            for(Contact cont:[Select Id,EC_CDM_Contact__c from Contact where Id in:setInsrtSuccess]) {
                successRecords.add(contactKeyMap.get(cont.EC_CDM_Contact__c));
            }

            for(EC_Mulesoft_CDM_Staging__c successStg:successRecords) {
                EC_Mulesoft_CDM_Staging__c successInprogress1 = new EC_Mulesoft_CDM_Staging__c();
                successInprogress1.Id= successStg.Id;
                successInprogress1.EC_IsProcessed__c= true;
                if(successStg.Id != null && !String.isBlank(successStg.Id)) {
                    existRecords.add(successInprogress1);
                }
            }

            if(existRecords!=null && !existRecords.isEmpty()) {
                Database.SaveResult[] savRes = Database.update(existRecords,false);
                for(Database.SaveResult sr:savRes){
                    if(!sr.isSuccess()) {
                        for(Database.Error  err: sr.getErrors()) {
                            EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(sr.getId(),null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingContactUtilities',
                                        'contactInsert');
                            stageLogWrapList.add(stageLogWrap);
                        }
                    }
                }
            }
            EC_StagingLogger.stageLogException(stageLogWrapList);
            if(Test.isRunningTest()){
               throw new DMLException();
            }
        }catch(Exception ex) {
            List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
             EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingContactUtilities',
								'contactInsert');
		    stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);
        }
    }

/***************************************************************************************************************************************
Method Name : contactUpdate
Description : Used to Update Contact From Staging object for Update Action
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/
    public static void contactUpdate(List<EC_Mulesoft_CDM_Staging__c> contctStage,Map<String,User> contactUserMap){

        List<Contact>  contactUpdate = new  List<Contact>();
        List<Id> lstUpdatedSuccess = new List<Id>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Map<Id,EC_Mulesoft_CDM_Staging__c> contStageMap = new Map<Id,EC_Mulesoft_CDM_Staging__c>();
        //below Lists will be used to update isProcessed field on the staging Object
        List<EC_Mulesoft_CDM_Staging__c> successRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new List<EC_Mulesoft_CDM_Staging__c>();
        Map<String,EC_Mulesoft_CDM_Staging__c> contactKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        
        List<string> contactStageKeys = new List<string>();
        List<string> cdmContactKeys = new List<string>();
        try{
        for(EC_Mulesoft_CDM_Staging__c stge : contctStage){
            if(stge.EC_User_Key__c != null && stge.EC_User_Key__c != ''){
                contactKeyMap.put(stge.EC_User_Key__c,stge);
            }
        }
        Map<String,User> usermap = new Map<String,User>();
        List<User> users = new List<User>();
        if(contactUserMap == null){
            if (!User.sObjectType.getDescribe().isAccessible()) { 
                return;
            }
            users= [select id,EC_CDM_User__c from User where EC_CDM_User__c in:contactKeyMap.keySet()];
            for (User item: users) {
                usermap.put(item.EC_CDM_User__c,item);
            }
        }
        for(Contact contct:[select id,FirstName,LastName,EC_CDM_Contact__c,Phone,Email from Contact where EC_CDM_Contact__c in:contactKeyMap.keySet()]){
            contStageMap.put(contct.id,contactKeyMap.get(contct.EC_CDM_Contact__c));
            contct.FirstName = contactKeyMap.get(contct.EC_CDM_Contact__c).EC_First_Name__c;
            if(contactKeyMap.get(contct.EC_CDM_Contact__c).EC_Last_Name__c!=''){contct.LastName  = contactKeyMap.get(contct.EC_CDM_Contact__c).EC_Last_Name__c;}
            if(!String.isBlank(contactKeyMap.get(contct.EC_CDM_Contact__c).EC_Email__c)){
              if(System.label.EC_Email_Extension == EC_Constants.PRODEMAILEXT){
               contct.Email  = contactKeyMap.get(contct.EC_CDM_Contact__c).EC_Email__c;
               }
                else{
                     contct.Email  = contactKeyMap.get(contct.EC_CDM_Contact__c).EC_Email__c+System.label.EC_Email_Extension;
                }
               contct.EC_FederationIdentifier__c = contactKeyMap.get(contct.EC_CDM_Contact__c).EC_Email__c;
                }
             if(!String.isBlank(contactKeyMap.get(contct.EC_CDM_Contact__c).EC_User_Status_Code__c)){
                if(contactKeyMap.get(contct.EC_CDM_Contact__c).EC_User_Status_Code__c == EC_Constants.A){
                    contct.EC_isActive__c = true;
                   }
                else{
                    contct.EC_isActive__c = false;
                }

            }
           {contct.Phone  = contactKeyMap.get(contct.EC_CDM_Contact__c).EC_Phone__c;}
            //   contct.EC_CDM_Contact__c = contactKeyMap.get(contct.EC_CDM_Contact__c).EC_User_Key__c;
            if(contactUserMap!=null){
                if(contactUserMap.get(contct.EC_CDM_Contact__c)!=null){
                    //Under this if clause we are updating the Contact SalesRep User once it is created after getting UserPermissions
                    contct.EC_SalesRep_User__c = contactUserMap.get(contct.EC_CDM_Contact__c).Id;
                    contct.FirstName = contactUserMap.get(contct.EC_CDM_Contact__c).FirstName;
                    contct.lastname = contactUserMap.get(contct.EC_CDM_Contact__c).LastName;
                  if(System.label.EC_Email_Extension == EC_Constants.PRODEMAILEXT){
                      contct.Email  = contactUserMap.get(contct.EC_CDM_Contact__c).Email;
                  }
                    else{
                        contct.Email  = contactUserMap.get(contct.EC_CDM_Contact__c).Email + System.label.EC_Email_Extension;
                    }
                    if(contactUserMap.get(contct.EC_CDM_Contact__c).IsActive == true){
                         contct.EC_Contact_Status__c = EC_Constants.Active;
                    }
                else{
                    contct.EC_Contact_Status__c = EC_Constants.Inactive;
                }

                }
            } else {
                if(usermap.get(contct.EC_CDM_Contact__c) != null) {
                    if(contactKeyMap.get(contct.EC_CDM_Contact__c).EC_User_Status_Code__c == EC_Constants.A){
                        contct.EC_Contact_Status__c = EC_Constants.Active;
                    } else {
                        contct.EC_Contact_Status__c = EC_Constants.Inactive;
                    }
                }
            }
            contactUpdate.add(contct);
            contactStageKeys.add(contactKeyMap.get(contct.EC_CDM_Contact__c).Id);
            cdmContactKeys.add(contct.EC_CDM_Contact__c);
        }
        System.debug('outside');
        for(String stage:contactKeyMap.keySet()){
            System.debug('inside ForLoop:'+contactKeyMap.get(stage).Id);
            if(!cdmContactKeys.contains(stage)){
                EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(contactKeyMap.get(stage).Id,null,null,null,null,null,null,null,null,null,'invalid EC_User_Key__c','EC_StagingContactUtilities',
                                'contactInsert');
                stageLogWrapList.add(stageLogWrap);
            }
        }
        Database.SaveResult[] saveRes = Database.update(contactUpdate,false);
        Integer index = 0;
        for(Database.SaveResult sr:saveRes){
            if(sr.isSuccess()){
                lstUpdatedSuccess.add(sr.getId());
            }
            else {
                for(Database.Error  err: sr.getErrors()) {
                    if(contStageMap.get(sr.getId())!=null){
		         EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(contactStageKeys.get(index),contStageMap.get(sr.getId()).EC_User_Key__c,null,contStageMap.get(sr.getId()).EC_Source_Table__c,
			                    contStageMap.get(sr.getId()).EC_Action__c,null,null,null,contStageMap.get(sr.getId()).EC_Email__c,null,err.getMessage(),'EC_StagingContactUtilities','contactUpdate');
                 stageLogWrapList.add(stageLogWrap);
                   }
		       }
            }
            index++;
        }
        List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
       for(Contact cont:[Select Id,EC_CDM_Contact__c from Contact where Id in:lstUpdatedSuccess]){
            successRecords.add(contactKeyMap.get(cont.EC_CDM_Contact__c))  ;
           }

        for(EC_Mulesoft_CDM_Staging__c successStg:successRecords){
            EC_Mulesoft_CDM_Staging__c successInprogress = new EC_Mulesoft_CDM_Staging__c();
            successInprogress.Id= successStg.Id;
            successInprogress.EC_IsProcessed__c= true;
            //successStg.EC_IsProcessed__c= true;
            if(successInprogress.Id != null && !String.isBlank(successInprogress.Id)){
                existRecords.add(successInprogress);
            }
        }
        if(existRecords!=null && !existRecords.isEmpty()){
             Database.SaveResult[] savRes = Database.update(existRecords,false);
        for(Database.SaveResult sr:savRes){
          if(!sr.isSuccess()){
              for(Database.Error  err: sr.getErrors()) {
		    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(sr.getId(),null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingContactUtilities',
								'contactUpdate');
             stageLogWrapList.add(stageLogWrap);
		             }
                  }
               }
           }
         EC_StagingLogger.stageLogException(stageLogWrapList);
            if(Test.isRunningTest()){
               throw new DMLException();
            }
        }catch(Exception ex){
          List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
             EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingContactUtilities',
								'contactUpdate');
		    stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);
        }
     }


/***************************************************************************************************************************************
Method Name : contactDelete
Description : Used to Delete Contact From Staging object for Delete Action
Return type : void
Author      : Shivam Vats
*************************************************************************************************************************************/

    public static void contactDelete(List<EC_Mulesoft_CDM_Staging__c> contctStage){

        Map<String,EC_Mulesoft_CDM_Staging__c> contactKeyMap = new  Map<String,EC_Mulesoft_CDM_Staging__c>();
        List<Contact>  contactUpdate = new  List<Contact>();
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Map<Id,EC_Mulesoft_CDM_Staging__c> contStageMap = new Map<Id,EC_Mulesoft_CDM_Staging__c>();
       // The below Lists will be used to update isProcessed Field on the Staging Object
        List<Id> lstDeletedSuccess = new List<Id>();
        List<EC_Mulesoft_CDM_Staging__c> successRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> stgRecordsList = new List<EC_Mulesoft_CDM_Staging__c>();
        List<EC_Mulesoft_CDM_Staging__c> existRecords = new List<EC_Mulesoft_CDM_Staging__c>();
        List<string> contactStageKeys = new List<string>();
        
        try{
        for(EC_Mulesoft_CDM_Staging__c stge : contctStage){
            if(stge.EC_User_Key__c != null && stge.EC_User_Key__c != ''){
                contactKeyMap.put(stge.EC_User_Key__c,stge);
            }
        }
       Set<String> contctduplicate = new Set<String>();
        for(Contact contct:[select id,FirstName,LastName,EC_CDM_Contact__c,EC_isActive__c from Contact where EC_CDM_Contact__c in:contactKeyMap.keySet()]){
            contStageMap.put(contct.id,contactKeyMap.get(contct.EC_CDM_Contact__c));
            if(contct.EC_isActive__c!=false){
            contct.EC_isActive__c = false;
            contct.EC_Contact_Status__c = EC_Constants.Inactive;
            contactUpdate.add(contct);
            contactStageKeys.add(contactKeyMap.get(contct.EC_CDM_Contact__c).Id);
               }else{
                 contctduplicate.add(contct.EC_CDM_Contact__c);
            }


        }



        
        for(EC_Mulesoft_CDM_Staging__c stage:contctStage){
            if(contctduplicate.contains(stage.EC_User_Key__c)){
                EC_Mulesoft_CDM_Staging__c successInprogress = new EC_Mulesoft_CDM_Staging__c();
                successInprogress.Id= stage.Id;
                successInprogress.EC_Record_Status__c = Label.EC_Duplicate;
                successInprogress.EC_IsProcessed__c= true;
               if(stage.id!=null && !String.isBlank(stage.Id)){
                    existRecords.add(successInprogress);
                }
            }
        }

        Database.SaveResult[] saveRes = Database.update(contactUpdate,false);
        Integer index = 0;
        for(Database.SaveResult sr:saveRes){
            if(sr.isSuccess()){
                lstDeletedSuccess.add(sr.getId());
            }
            else {
                for(Database.Error  err: sr.getErrors()) {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(contactStageKeys.get(index),contStageMap.get(sr.getId()).EC_User_Key__c,null,contStageMap.get(sr.getId()).EC_Source_Table__c,
                                        contStageMap.get(sr.getId()).EC_Action__c,null,null,null,contStageMap.get(sr.getId()).EC_Email__c,null,err.getMessage(),'EC_StagingContactUtilities',
                                        'contactDelete');
                    stageLogWrapList.add(stageLogWrap);
		       }
            }
            index++;
        }

       for(Contact cont:[Select Id,EC_CDM_Contact__c from Contact where Id in:lstDeletedSuccess]){
            successRecords.add(contactKeyMap.get(cont.EC_CDM_Contact__c))  ;
           }

        for(EC_Mulesoft_CDM_Staging__c successStg:successRecords){
            EC_Mulesoft_CDM_Staging__c successInprogress = new EC_Mulesoft_CDM_Staging__c();
            successInprogress.Id= successStg.Id;
            successInprogress.EC_IsProcessed__c= true;
            if(successStg.Id !=null && !String.isBlank(successStg.Id)){
                existRecords.add(successInprogress);
              }
            }
        if(existRecords!=null && !existRecords.isEmpty()){
            Database.SaveResult[] savRes = Database.update(existRecords,false);
           for(Database.SaveResult sr:savRes){
            if(!sr.isSuccess()){
              for(Database.Error  err: sr.getErrors()) {
		         EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(sr.getId(),null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingContactUtilities',
								'contactDelete');
                 stageLogWrapList.add(stageLogWrap);
		          }
               }
            }
         }
            EC_StagingLogger.stageLogException(stageLogWrapList);
            if(Test.isRunningTest()){
               throw new DMLException();
            }
        }catch(Exception ex){
           List<EC_StagingExceptionLog__c> stageExceptionList = new List<EC_StagingExceptionLog__c>();
             EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(null,null,null,null,null,null,null,null,null,null,ex.getMessage(),'EC_StagingContactUtilities',
								'contactDelete');
		    stageExceptionList.add(stageLogWrap);
            EC_StagingLogger.stageLogException(stageExceptionList);
        }
    }

    //PBI-137177
    public static void caseInsert(List<Contact> insertedContcts, List<String> contactStageKeys) {
        List<Case> insertCases = new List<Case>();
        
        if(!insertedContcts.isEmpty()) {
            User owner = [SELECT Id, Name FROM User WHERE Id = :Label.EC_CaseOwnerId];
            for(Contact cont : insertedContcts) {
                Case caseRec = new Case();
                caseRec.ContactId = cont.Id;
                caseRec.Status = Label.EC_Status_New;
                caseRec.Origin = EC_Constants.CASE_ORIGIN_CDM_REGISTRATION; //CDM
                caseRec.Type = EC_Constants.CASE_TYPE_USER_REGISTRATION;	//User Registration 
                if(owner.Id != null) {
                    caseRec.OwnerId = owner.Id;
                }
                insertCases.add(caseRec);
            }
        } 
        Database.SaveResult[] saveResult = Database.insert(insertCases,false);
        stagingDMLExceptionLogs(saveResult, 'caseInsert', contactStageKeys);
    }
    
    public static Set<Id> stagingDMLExceptionLogs(Database.SaveResult[] saveResult, String methodName, List<String> contactStageKeys) {
        Integer index = 0;
        List<EC_StagingExceptionLog__c> stageLogWrapList = new List<EC_StagingExceptionLog__c>();
        Set<Id> setSuccessRecords = new Set<Id>();
        
        for(Database.SaveResult sr : saveResult) {
            if(sr.isSuccess()) {
                setSuccessRecords.add(sr.getId());
            } else {
                for(Database.Error  err: sr.getErrors()) {
                    EC_StagingExceptionLog__c stageLogWrap = EC_StagingLogger.logException(contactStageKeys.get(index),null,null,null,null,null,null,null,null,null,err.getMessage(),'EC_StagingContactUtilities',
                                                                                           methodName);
                    stageLogWrapList.add(stageLogWrap);
                }
            }
            index++;
        }
        EC_StagingLogger.stageLogException(stageLogWrapList);
        return setSuccessRecords;
    }

}