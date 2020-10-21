/*********************************************************************************
Class Name      : EC_ServiceRequestHandler
Description     : This class is used as the handler for Service Request lightning component
Created By      : Deloitte
Created Date    : 21-July-19
Modification Log:
---------------------------------------------------------------------------------- 
Developer                 Date                   Description
----------------------------------------------------------------------------------            
Deloitte                  02-July-19             Initial Version 
*********************************************************************************/ 
public class EC_ServiceRequestHandler {
 /*
* @description: 
* @param: 
* @return: 
*/
    @auraenabled(cacheable=true)
    public static String createSRCase(String searchText){
        return 'Success';
    }

    public static Case addSAPFields(Case newCase, String sapCategory, String sapSubCategory){
        System.debug('Inside EC_ServiceRequestHandler. Sap Category: ' + sapCategory + ' SAP Sub Category: ' + sapSubCategory);
        sapCategory = sapCategory.trim();
        sapSubCategory = sapSubCategory.trim();
        List<Portal_ESR_Category_Lookup__c> records = [SELECT 
                                                            Cat_1_4_Chars__c, 
                                                            Cat_1_8_Chars__c, 
                                                            Cat_1_Code__c, 
                                                            Cat_1_Text__c, 
                                                            Cat_2_4_Chars__c, 
                                                            Cat_2_8_Chars__c, 
                                                            Cat_2_Code__c, 
                                                            Cat_2_Text__c,
                                                            Cat_3_Code__c,
                                                            Cat_3_Text__c,
                                                            Cat_4_Code__c,
                                                            Cat_4_Text__c,
                                                            Id, 
                                                            Show_on_Portal__c 
                                                        FROM Portal_ESR_Category_Lookup__c
                                                        WHERE Show_on_Portal__c = true 
                                                        AND Cat_1_Text__c =:sapCategory 
                                                        AND Cat_2_Text__c =:sapSubCategory];

        System.debug('Inside EC_ServiceRequestHandler. Sap qrecords: ' + records );
        if(records != null && records.size() > 0){
            if(newCase != null){
                newCase.Order_Type__c = 'ZESR';
                newCase.Cat_1_Code__c = records[0].Cat_1_Code__c;
                newCase.Category_1_4__c = records[0].Cat_1_4_Chars__c;
                newCase.Category_1_8__c = records[0].Cat_1_8_Chars__c;

                newCase.Cat_2_Code__c = records[0].Cat_2_Code__c;
                newCase.Category_2_4__c = records[0].Cat_2_4_Chars__c;
                newCase.Category_2_8__c = records[0].Cat_2_8_Chars__c;

                newCase.Cat_3_Code__c = records[0].Cat_3_Code__c;
                newCase.Cat_4_Code__c = records[0].Cat_4_Code__c;
            }
        }
        System.debug('EC_ServiceRequestHandler addSAPFields. Case object is... ' + newCase);
        return newCase;
    }
    
    /*******************************************************************************************
    * @description: CaseCreation 
    * @param: Map<String,String>
    * @return: String
    *************************************************************************************************/

    @AuraEnabled
    public static String createServiceRequestCase(Map<String, String> registrationDetails){
        
        String AccountNumber =registrationDetails.get('Account');
        String RequestType=registrationDetails.get('RequestType');
        String Category=registrationDetails.get('Category');
        String Note=registrationDetails.get('Note');
        String contactPhone=registrationDetails.get('Phone');
        String soldTo=registrationDetails.get('soldTo');
        String contactEmail=registrationDetails.get('email');
        String contactName=registrationDetails.get('contactName');

        List<Case> cslist = new List<Case>();
        Id caseId ;
        EC_CacheWrapper usr = EC_CacheHelper.getCacheInfo();
        String ContactId = usr.portalConId ; 
        
        String returnText = Label.EC_SUCCESS;

        case caseRec = new case();
        caseRec.EC_Request_Service_Type__c = RequestType ;
        caseRec.EC_Category_Values__c = Category ;
        caseRec.Description = Note;
        
        caseRec.status = Label.EC_Status_New;
        caseRec.Origin = Label.EC_Origin_Portal;
        caseRec.Type = Label.EC_Type_Request_Service;
        caseRec.Subject = AccountNumber +' - ' +Label.EC_Type_Request_Service;
        caseRec.SuppliedName = contactName;
        caseRec.SuppliedEmail = contactEmail;
        caseRec.SuppliedPhone = contactPhone;
        caseRec.EC_User__c = UserInfo.getUserId();
        caseRec.Sold_To__c = soldTo;
        caseRec.Ship_To__c = AccountNumber;

        EC_ServiceRequestAssignmentRule ruleRunning = new EC_ServiceRequestAssignmentRule();
        caseRec = ruleRunning.caseRules(caseRec);

        if(AccountNumber != null) {
            List<Account> acc = [Select Id,Name,EC_Account_Number__c  from Account where EC_Account_Number__c =: AccountNumber LIMIT 1];
            if(acc.size() >0) {
                caseRec.AccountId = acc[0].Id;
            }
        } 
        caseRec = addSAPFields(caseRec, RequestType, Category);
        //  cslist.add(caseRec);
        Database.SaveResult sr = Database.insert(caseRec,false);
        System.debug('testing:'+sr);
        if(sr.isSuccess()) {
            System.debug('Successfully inserted case. Case ID: ' + sr.getId());
            caseId =  sr.getId() ;
            /*if(ContactId != null){
                List<ContentDocumentLink> cdLinkList = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId=:ContactId];
                if(cdLinkList.size() >0){
                    ContentDocumentLink newcdLink = cdLinkList[0].clone();
                    newcdLink.linkedentityid = caseId;
                    newcdLink.ShareType = 'V';
                    if(!Test.isRunningTest())
                    	delete cdLinkList[0];
                    insert newcdLink;
                }             
            }*/
            returnText = Label.EC_SUCCESS+'::'+caseId;
        }
        return returnText ;
    }
    
     /*******************************************************************************************
    * @description: delete the file 
    * @param: 
    * @return: String
    *************************************************************************************************/
    @AuraEnabled
    public static String updateCancel(){
        EC_CacheWrapper user= EC_CacheHelper.getCacheInfo();
        String ContactId = user.portalConId ;
        if(ContactId != null){
            List<ContentDocumentLink> cdLinkList = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId=:ContactId];
            if(cdLinkList.size() >0){ 
                if(!Test.isRunningTest())
               		delete cdLinkList[0];
            }             
        }
        return Label.EC_SUCCESS;
    }
    /*******************************************************************************************
    * @description: UserInfo
    * @param: 
    * @return: Boolean
    *************************************************************************************************/
    private static Boolean getUserAccountDivision() { 
        Boolean isInstUser = false;
        User u= [select Id,contact.account.EC_Division__c from user where Id =: UserInfo.getUserId()];
		if(u.contact != null && u.contact.account != null && u.contact.account.EC_Division__c == 'INSTITUTIONAL'){
            isInstUser = true;
        } 
        return isInstUser;
    } 
    
    /*******************************************************************************************
    * @description: EffectiveAccountID
    * @param: 
    * @return: String
    *************************************************************************************************/
    private static String getEffeciveAccount(String contactId) { 
        String effectiveAccId= '';
        List<ccrz__E_Cart__c> cart= [select Id,ccrz__EffectiveAccountID__c from ccrz__E_Cart__c where ccrz__ActiveCart__c=TRUE and ccrz__Contact__c=: contactId order by lastmodifieddate desc limit 1];
		
        if(cart.size()>0){
            effectiveAccId = cart[0].ccrz__EffectiveAccountID__c;
        } 
        return effectiveAccId;
    } 
    
    /*******************************************************************************************
    * @description: CacheValue
    * @param: 
    * @return: String
    *************************************************************************************************/
    @AuraEnabled
    public static ServiceReqWrapper getUserDetailsCache(){
        EC_CacheWrapper user= EC_CacheHelper.getCacheInfo();
        ServiceReqWrapper ServiceReq = new ServiceReqWrapper();
        System.debug('Value retrieved from cache is++++++++'+user);
        ServiceReq.ContactId = user.portalConId;
        ServiceReq.acclist = user.contactAccList ;
        ServiceReq.ConFirstName = user.userFirstName ;
        ServiceReq.ConLastName = user.userLastName  ; 
        ServiceReq.ConEmail = user.portalConEmail;
        ServiceReq.isInstUser = getUserAccountDivision();
        ServiceReq.effectiveAccountId=getEffeciveAccount(user.portalConId);
        Account acc = [Select Name,EC_Account_Number__c,Parent.EC_Account_Number__c,Parent.RecordType.Name  FROM Account WHERE Id = :ServiceReq.effectiveAccountId];
        ServiceReq.SelectedAccount = acc.Name;
        ServiceReq.SelectedAccountNumber = acc.EC_Account_Number__c;
        if(acc.ParentId != null && acc.Parent.RecordType.Name=='Sold To'){
            ServiceReq.SelectedParentAccountNumber = acc.Parent.EC_Account_Number__c;                  
        } else {
        	ServiceReq.SelectedParentAccountNumber = acc.EC_Account_Number__c;
        }
        if(user.portalConPhone != null){
            ServiceReq.ConPhone = user.portalConPhone  ; 
        } else {
            ServiceReq.ConPhone ='' ;
        }
        return ServiceReq;
    }

    public class ServiceReqWrapper{
        @auraEnabled
        public String ContactId;
        @auraEnabled
        public List<String> acclist;
         @auraEnabled
        public String ConFirstName;
        @auraEnabled
        public String effectiveAccountId;
        @auraEnabled
        public String ConLastName;
        @auraEnabled
        public String ConEmail;
         @auraEnabled
        public String ConPhone;
        @auraEnabled
        public Boolean isInstUser;
        @auraEnabled
        public String SelectedAccount;
        @auraEnabled
        public String SelectedAccountNumber;
        @auraEnabled
        public String SelectedParentAccountNumber;
    }
    
/*******************************************************************************************
* @description: MapPicklistValues 
* @param: Map<String,String>
* @return: String
*************************************************************************************************/
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = case.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String label {get;set;}
        public String validFor {get;set;}
    }
    @AuraEnabled
    public static String getContactName(){
        EC_CacheWrapper usr = EC_CacheHelper.getCacheInfo();
        String FirstName = usr.userFirstName ; 
        String LastName = usr.userLastName ; 
        String NameVal = FirstName + ' ' + LastName ;
        return NameVal ;
    }
    
    @AuraEnabled
    public Static  Map<Id, List<AccountListWrapper>> getContactAccounts(String searchKey){
        user loggedInUser = [SELECT id, ccrz__CC_CurrencyCode__c, ContactId FROM User WHERE Id =: userinfo.getuserId()];
        List<AccountContactRelation> lstAccContRel = new List<AccountContactRelation>();
        if(loggedInUser!=null && loggedInUser.contactId!=null){
            lstAccContRel = [SELECT id, accountId, account.ccrz__E_AccountGroup__c FROM AccountContactRelation WHERE contactId =: loggedInUser.contactId];
        }
        
        List<Id> lstAccIds = new List<Id>();
        List<Id> lstParentAccIds = new List<Id>();
        Map<Id, List<AccountListWrapper>> accountMap = new Map<Id, List<AccountListWrapper>>();
        //to check if contact record is associated to the account
        if(lstAccContRel!=null){
            for(AccountContactRelation accContRec : lstAccContRel){
                lstAccIds.add(accContRec.accountId);
            }
        }
        List<Account> accountList =[select Id,RecordType.Name, Name,EC_Account_Number__c, AccountNumber, ParentId, Parent.RecordType.Name, Type,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, ShippingAddress FROM Account WHERE Id IN :lstAccIds and EC_Status__c!='Inactive'];
        system.debug('accountList'+accountList);
        system.debug('searchKey' +searchKey);
        for(Account a : accountList){
            if(a.ParentId != NULL  && a.RecordType.Name=='Ship To' && a.Parent.RecordType.Name == 'Sold To' ){
                lstParentAccIds.add(a.ParentId);
                
            }else if(a.RecordType.Name=='Ship To' && (a.ParentId == NULL || a.Parent.RecordType.Name == 'Corporate' || a.Parent.RecordType.Name=='Ship To')){
                lstParentAccIds.add(a.Id);
            } 
        }
        System.debug('Parent Account Ids+++++ '+lstParentAccIds); 

        //PBI-128708, BUG-131723       
        List<Account> parentAccountList = new List<Account>();
        if(searchKey == NULL || searchKey == '')
        	parentAccountList = [select Id,RecordType.Name, Name,EC_Account_Number__c, AccountNumber, ParentId, Parent.RecordType.Name, Type,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, ShippingAddress from Account where Id IN :lstParentAccIds];
        else{
            string tempInput = '%' + searchKey + '%';
            List<AccountContactRelation> lstSearchRelAcc = [Select Id, AccountId FROM AccountContactRelation
                                                            WHERE AccountId IN :lstParentAccIds //AND ContactId = :loggedInUser.contactId
                                                            AND (Account.Name like :tempInput OR Account.EC_Account_Number__c like :tempInput 
                                                                 OR Account.ShippingCity like :tempInput OR Account.ShippingStreet like :tempInput OR Account.ShippingState like :tempInput OR Account.ShippingCountry like :tempInput OR Account.ShippingPostalCode like :tempInput 
                                                                 OR Account.Parent.Name like :tempInput OR Account.parent.EC_Account_Number__c like :tempInput 
                                                                 OR ((Contact.FirstName like :tempInput OR Contact.LastName like :tempInput ) AND Alignment_Type__c =: EC_Constants.PRIMARY_ALIGNMENT_TYPE))];
            Set<Id> lstRelAccId = new Set<Id>();
            if(lstSearchRelAcc!=null){
                for(AccountContactRelation accContRel : lstSearchRelAcc){
                    lstRelAccId.add(accContRel.accountId);
                }
            }
            parentAccountList = [select Id,RecordType.Name, Name,EC_Account_Number__c, AccountNumber, ParentId, Parent.RecordType.Name, Type,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, ShippingAddress from Account where Id IN :lstRelAccId];
        }
        
        for(Account pa : parentAccountList){
            system.debug('Parent'+pa);
            Set<AccountListWrapper> templistset=New Set<AccountListWrapper>();
			List<AccountListWrapper> tempList= new List<AccountListWrapper>();	          
            system.debug('templistset'+ templistset);
            if (!accountMap.containsKey(pa.Id)){
                accountMap.put(pa.Id,tempList);
                system.debug('accountMap'+ accountMap);
            }            
            for(Account ca : accountList){
                if( accountMap.containsKey(pa.Id) && ca.ParentId == pa.Id && pa.RecordType.Name=='Sold To'){
                    AccountListWrapper tempAccWrap=new AccountListWrapper();
                    tempAccWrap=AccountWrapperMethod(ca,pa.Name,pa.EC_Account_Number__c,pa.Id);
                    templistset.add(tempAccWrap);                    
                }  
                system.debug('templistset'+ templistset);
            }
            tempList = new List<AccountListWrapper>(templistset);
            accountMap.put(pa.Id, tempList);
        }
        for(Account pa : parentAccountList){
            List<AccountListWrapper> templist1=accountMap.get(pa.Id);
            List<AccountListWrapper> tempList2=new List<AccountListWrapper>();
            if(templist1.isempty() || templist1==NULL){
                AccountListWrapper tempAccWrap2=AccountWrapperMethod(pa,pa.Name,pa.EC_Account_Number__c,pa.Id);
                tempList2.add(tempAccWrap2);
				accountMap.put(pa.Id, tempList2);                
            }  
        }
        return accountMap;
    }
    
    @AuraEnabled
    public static AccountListWrapper AccountWrapperMethod(account acc, String parAccName,String parAccNumber, Id accId){                    
            AccountListWrapper aw=new AccountListWrapper();            
            aw.ID=acc.Id;
            aw.Name=acc.Name;
            aw.ParentAccountNumber=parAccNumber;
            aw.ParentAccountName=parAccName;
            //PBI-126181
            List<AccountContactRelation> lstAccRel = [SELECT Id, contact.FirstName, contact.LastName
                                                      FROM AccountContactRelation
                                                      WHERE accountId =: accId
                                                      AND Alignment_Type__c =: EC_Constants.PRIMARY_ALIGNMENT_TYPE];
            if(lstAccRel.size() > 0){
            	aw.PrimaryRepName = lstAccRel[0].contact.FirstName + ' ' + lstAccRel[0].contact.LastName;
            }
        	aw.AccountNumber=acc.EC_Account_Number__c;
            //PBI-128708: To exclude null values from display
            if(!String.isBlank(acc.ShippingStreet) && !String.isBlank(acc.ShippingCity) && !String.isBlank(acc.ShippingState) && !String.isBlank(acc.ShippingPostalCode) && !String.isBlank(acc.ShippingCountry)){
                aw.ShippingAddress=acc.ShippingStreet + '</br>' + acc.ShippingCity + ', ' + acc.ShippingState + ' ' + acc.ShippingPostalCode + '</br>' + acc.ShippingCountry; 
            } else if(!String.isBlank(acc.ShippingStreet) || !String.isBlank(acc.ShippingCity) || !String.isBlank(acc.ShippingState) || !String.isBlank(acc.ShippingPostalCode) || !String.isBlank(acc.ShippingCountry)){
                aw.ShippingAddress = '';
                if(!String.isBlank(acc.ShippingStreet))		aw.ShippingAddress+=acc.ShippingStreet + '</br>';
                if(!String.isBlank(acc.ShippingCity))		aw.ShippingAddress+=acc.ShippingCity + ', ';
                if(!String.isBlank(acc.ShippingState))		aw.ShippingAddress+=acc.ShippingState + ' ';
                if(!String.isBlank(acc.ShippingPostalCode)) aw.ShippingAddress+=acc.ShippingPostalCode + '</br>';
                if(!String.isBlank(acc.ShippingCountry))	aw.ShippingAddress+=acc.ShippingCountry;
            } else {
                aw.ShippingAddress = EC_Constants.NOTAPPLICABLE; //'N/A'
            }
            //aw.ShippingAddress=acc.ShippingStreet + ' ' + acc.ShippingCity + ' ' + acc.ShippingState + ' ' + acc.ShippingCountry + ' ' + acc.ShippingPostalCode;                
            return aw;
        }
    
    public class AccountListWrapper{
        @AuraEnabled
        public String ID {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String AccountNumber {get;set;}
        @AuraEnabled
        public String ParentAccountNumber {get;set;}
        @AuraEnabled
        public String ParentAccountName {get;set;}
        @AuraEnabled
        public String PrimaryRepName {get;set;} //PBI-126181
        @AuraEnabled
        public String ShippingAddress {get;set;}
        
    }
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType) {
        //   for update the attachment with reamins chunks   
        System.debug('Inserting into caseId: ' + parentId);
        Id fieldId;
        String fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        fieldId = Id.valueOf(fileId);
        return fieldId;
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String versiondata, String contentType) {
        ContentVersion cv = new ContentVersion();
        cv.title = fileName;
        versiondata = EncodingUtil.urlDecode(versiondata, 'UTF-8');
		cv.PathOnClient = '/' + fileName;
        cv.VersionData =EncodingUtil.base64Decode(versiondata);
        insert cv;   
       	Id cdID;
       	ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id]; 
        if(contentVersion != null) {
            cdID = contentVersion.ContentDocumentId;
            List<ContentDocumentLink> cdLinkList  = new List<ContentDocumentLink>();
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=parentId;
            contentlink.ShareType= 'V'; 
            contentlink.ContentDocumentId = cdID;
            contentlink.Visibility = 'AllUsers'; 
            cdLinkList.add(contentlink);
            insert cdLinkList;
        }
        return cdID;
    }
    @AuraEnabled
    public static List<String> getFileTypes() {
        List<String> acceptedTypes = new List<String>();
        try {
            //EC_Accepted_File_Types__c serviceRequestPage = EC_Accepted_File_Types__c.getValues('ServiceRequestPage');
            EC_Accepted_File_Types__mdt serviceRequestPage = new EC_Accepted_File_Types__mdt();
            serviceRequestPage = [SELECT id, Accepted_Types__c FROM EC_Accepted_File_Types__mdt WHERE Label = 'ServiceRequestPage'];
            String acceptedTypestr =  (String)serviceRequestPage.Accepted_Types__c;
            acceptedTypes = acceptedTypestr.split(',');
        } catch(Exception ex) {
            system.debug('Exception on fetching file types'+ ex.getMessage());
        } finally {
            system.debug('acceptedTypes'+ acceptedTypes);
        }
        return acceptedTypes;
    }

}