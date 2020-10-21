/* Class Name       :EC_ContactAccountInfo
 * Description      :Class for handling account contact info and account alignments on User Settings page.
 * Created By       :Harsha N
 * Created On       :07-05-2019
 *
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID             Description
 * ----------------------------------------------------------------------------------------------------------------
 * Harsha N       07-05-2019                                   Class for handling account contact info and account alignments on User Settings page.
 * Raghav Sharma
 */
public without sharing class EC_ContactAccountInfo{
    public static string currentClassName = 'EC_ContactAccountInfo';
     /************************************************************************************************************************************
Method Name : getContactAccountInformation
Description : Method to get all the account information grouped by the parent
Return type : contactInfoWrapper
Author      : Harsha N
*************************************************************************************************************************************/

    @AuraEnabled
    public static contactInfoWrapper getContactAccountInformation(){
        contactInfoWrapper contInfoRecReturn = new contactInfoWrapper();

          Contact con = new Contact();
          User usr = [select id, User_Type__c,contactId, contact.account.RecordType.Name, contact.FirstName, contact.LastName, contact.email, contact.phone, contact.accountId, LanguageLocaleKey from User where id=:UserInfo.getUserId()];


            //Extracting the Contact of Salerep
             if(usr!=null && usr.User_Type__c !='External'){
                     List<Contact> conlist = [Select Id,FirstName,LastName,Phone,Email,EC_SalesRep_User__c from Contact where EC_SalesRep_User__c = :UserInfo.getUserId()  limit 1];
                     if(conlist.size()>0){
                     con = conlist[0];


                 }

                  }
             list<AccountContactRelation> lstAccContRel = new  list<AccountContactRelation>();


            if(usr.contactId != null){
                 lstAccContRel = [SELECT id, accountId, account.parentId, account.parent.Name, account.parent.Phone, account.parent.RecordType.Name, account.parent.EC_Account_Number__c, account.parent.EC_SalesRepresentative__r.Name, account.Name, account.EC_SalesRepresentative__r.Name, account.EC_Account_Number__c, account.ShippingStreet, account.ShippingCity, account.ShippingState, account.Ship_To_Name__c, account.EC_Division__c, account.ShippingCountry, account.ShippingPostalCode, account.Phone, account.EC_Status__c FROM AccountContactRelation WHERE contactId =: usr.contactId AND account.RecordType.Name = 'Ship To' AND account.EC_Status__c!='Inactive' order by account.Name];
                } else{
                lstAccContRel =  [SELECT id, accountId, account.parentId, account.parent.Name, account.parent.Phone, account.parent.RecordType.Name, account.parent.EC_Account_Number__c, account.parent.EC_SalesRepresentative__r.Name, account.Name, account.EC_SalesRepresentative__r.Name, account.EC_Account_Number__c, account.ShippingStreet, account.ShippingCity, account.ShippingState, account.Ship_To_Name__c, account.EC_Division__c, account.ShippingCountry, account.ShippingPostalCode, account.Phone, account.EC_Status__c  FROM AccountContactRelation WHERE contactId =: con.Id AND account.RecordType.Name = 'Ship To' AND account.EC_Status__c !='Inactive' order by account.Name];

                }

                map<Id,list<AccountContactRelation>> mapParentChildAcc = new map<Id,list<AccountContactRelation>>();
        		Set<id> accountids = new Set<id>();
                for(AccountContactRelation accContRec : lstAccContRel){
                    if(accContRec.account.parent != null && accContRec.account.parent.RecordType.Name == 'Sold To'){
                        if(mapParentChildAcc.containsKey(accContRec.account.parentId)){
                            mapParentChildAcc.get(accContRec.account.parentId).add(accContRec);
							accountids.add(accContRec.account.id);
                        }else{
                            list<AccountContactRelation> tempAccContList = new list<AccountContactRelation>();
                            tempAccContList.add(accContRec);
                            mapParentChildAcc.put(accContRec.account.parentId, tempAccContList);
							accountids.add(accContRec.account.parentId);
                            accountids.add(accContRec.account.id);
                        }
                    }else{
                        list<AccountContactRelation> tempAccContList = new list<AccountContactRelation>();
                        tempAccContList.add(accContRec);
                        mapParentChildAcc.put(accContRec.accountId, tempAccContList);
                        accountids.add(accContRec.accountId);
                    }
                }

                list<accInfoWrapper> lstAccInfo = new list<accInfoWrapper>();
                list<accInfoWrapper> lstAccInfoSorted = new list<accInfoWrapper>();
                Map<ID, AccountContactRelation> primaryInfo = new Map<ID, AccountContactRelation>();
                for (AccountContactRelation accConItem:[SELECT Id, accountId,contact.FirstName, contact.LastName
                                                      FROM AccountContactRelation
                                                      WHERE accountId in : accountids
                                                      AND Alignment_Type__c =: EC_Constants.PRIMARY_ALIGNMENT_TYPE]) {
                    primaryInfo.put(accConItem.accountId,accConItem);
                }
                for(string parentAccKey : mapParentChildAcc.keyset()){
                    accInfoWrapper accInfoRec = new accInfoWrapper();
                    accInfoRec = createAccInfoRec(mapParentChildAcc.get(parentAccKey),primaryInfo);
                    lstAccInfo.add(accInfoRec);
                }

			   if(usr.ContactId!=null){
					contInfoRecReturn = createContactInfoRec(usr, lstAccInfo);
               } else {

				contInfoRecReturn = createContactInfoRecSalesRep(con,lstAccInfo);
               }

        return contInfoRecReturn;
    }
  /************************************************************************************************************************************
Method Name : createAccInfoRec
Description : Method to create a wrapper info of the parent and the child
Return type : accInfoWrapper
Author      : Harsha N
*************************************************************************************************************************************/

    public static accInfoWrapper createAccInfoRec(List<AccountContactRelation> lstShipAccRec, Map<ID, AccountContactRelation> primaryInfo){
        accInfoWrapper accInfoRec = new accInfoWrapper();
        list<addressInfoWrapper> tempAddInfoWrap = new list<addressInfoWrapper>();
		String primaryRepName = '';
        if(lstShipAccRec[0].account.parent != null && lstShipAccRec[0].account.parent.RecordType.Name == 'Sold To'){
            accInfoRec.accName = lstShipAccRec[0].account.parent.Name;
            accInfoRec.accNum = lstShipAccRec[0].account.parent.EC_Account_Number__c;
            //accInfoRec.primaryRepName = getPrimaryRep(lstShipAccRec[0].account.parentId);  //PBI-121282
            AccountContactRelation accConRel = primaryInfo.get(lstShipAccRec[0].account.parentId);
            if(accConRel != null){
                primaryRepName = accConRel.contact.FirstName + ' ' + accConRel.contact.LastName;
            }
            accInfoRec.primaryRepName = primaryRepName;
            
        }else{
            accInfoRec.accName = lstShipAccRec[0].account.Name;
            accInfoRec.accNum = lstShipAccRec[0].account.EC_Account_Number__c;
            //accInfoRec.primaryRepName = getPrimaryRep(lstShipAccRec[0].accountId);  //PBI-121282
            AccountContactRelation accConRel = primaryInfo.get(lstShipAccRec[0].accountId);
            if(accConRel != null){
                primaryRepName = accConRel.contact.FirstName + ' ' + accConRel.contact.LastName;
            }
            accInfoRec.primaryRepName = primaryRepName;
        }

        for(AccountContactRelation shipAccRec : lstShipAccRec){
            String nalcoDivisions = System.Label.EC_DivisionValueNACLO;
            addressInfoWrapper addInfoRec = new addressInfoWrapper();
            if(shipAccRec.account.ShippingCity == null){
                shipAccRec.account.ShippingCity='';
            }
            else{
                shipAccRec.account.ShippingCity = shipAccRec.account.ShippingCity +', ';
            }
             if(shipAccRec.account.ShippingState == null){
                shipAccRec.account.ShippingState='';
            }
             else{
                shipAccRec.account.ShippingState = shipAccRec.account.ShippingState +', ';
            }

             if(shipAccRec.account.ShippingStreet == null){
                shipAccRec.account.ShippingStreet='';
            }
            else{
                shipAccRec.account.ShippingStreet = shipAccRec.account.ShippingStreet +', ';
            }

             if(shipAccRec.account.ShippingPostalCode == null){
                shipAccRec.account.ShippingPostalCode='';
            }
            else{
                shipAccRec.account.ShippingPostalCode = shipAccRec.account.ShippingPostalCode +', ';
            }
            if(shipAccRec.account.ShippingCountry == null){
                shipAccRec.account.ShippingCountry='';
            } else{
                shipAccRec.account.ShippingCountry = shipAccRec.account.ShippingCountry +', ';
            }

            addInfoRec.shipToId = shipAccRec.account.EC_Account_Number__c;
            addInfoRec.shipToName =shipAccRec.account.Ship_To_Name__c !=null ? shipAccRec.account.Ship_To_Name__c : '';
            addInfoRec.division =shipAccRec.account.EC_Division__c !=null ? shipAccRec.account.EC_Division__c : '';
            if(nalcoDivisions.containsIgnoreCase(shipAccRec.account.EC_Division__c))
            {
                addInfoRec.isNalco =true;
            }
            else{
                addInfoRec.isNalco =false;
            }
            
            
            addInfoRec.shipToAddress = shipAccRec.account.ShippingCity + ', ' + shipAccRec.account.ShippingState + '  ' + shipAccRec.account.ShippingPostalCode + '<br/>' + shipAccRec.account.ShippingCountry;
            addInfoRec.phoneNumber = shipAccRec.account.Phone;
            addInfoRec.shipToCity = shipAccRec.account.ShippingCity.replace(',','');
            addInfoRec.shipToState = shipAccRec.account.ShippingState.replace(',','');
            addInfoRec.shipToStreet = shipAccRec.account.ShippingStreet.replace(',','');
            addInfoRec.fullAddress =  shipAccRec.account.ShippingStreet.replace(',','')+ addInfoRec.shipToAddress;
            tempAddInfoWrap.add(addInfoRec);
        }
        accInfoRec.lstShipTo = tempAddInfoWrap;
        return accInfoRec;
    }

    /************************************************************************************************************************************
    Method Name : getPrimaryRep
    Description : Method to return PrimaryRep
    Return type : string
    PBI         : 121282
    *************************************************************************************************************************************/
    private static string getPrimaryRep(Id accId){
        string primaryRepName = '';
        List<AccountContactRelation> lstSoldAccRel = [SELECT Id, contact.FirstName, contact.LastName
                                                      FROM AccountContactRelation
                                                      WHERE accountId =: accId
                                                      AND Alignment_Type__c =: EC_Constants.PRIMARY_ALIGNMENT_TYPE];
        if(lstSoldAccRel.size() > 0){
            primaryRepName = lstSoldAccRel[0].contact.FirstName + ' ' + lstSoldAccRel[0].contact.LastName;
        }
        return primaryRepName;
    }

 /************************************************************************************************************************************
Method Name : createContactInfoRec
Description : Method to create a wrapper info of the Contact
Return type : contactInfoWrapper
Author      : Raghav Sharma
*************************************************************************************************************************************/

    public static contactInfoWrapper createContactInfoRec(user userRec, list<accInfoWrapper> soldInfoRec){
        contactInfoWrapper contInfoRec = new contactInfoWrapper();
        contInfoRec.contactName = userRec.contact.FirstName + ' ' + userRec.contact.LastName;
        contInfoRec.contEmail = userRec.contact.email;
        contInfoRec.contPhone = userRec.contact.phone;
        contInfoRec.userType = 'External';
        contInfoRec.lstAcc = soldInfoRec;
        return contInfoRec;
    }
/************************************************************************************************************************************
Method Name : createContactInfoRecSalesRep
Description : Method to create a wrapper info of the Contact for Sales rep
Return type : contactInfoWrapper
Author      : Raghav Sharma
*************************************************************************************************************************************/

    public static contactInfoWrapper createContactInfoRecSalesRep(Contact cont, list<accInfoWrapper> soldInfoRec){
        contactInfoWrapper contInfoRec = new contactInfoWrapper();
        contInfoRec.contactName = cont.FirstName + ' ' + cont.LastName;
        contInfoRec.contEmail = cont.email;
        contInfoRec.contPhone = cont.phone;
        contInfoRec.userType = 'Internal';
        contInfoRec.lstAcc = soldInfoRec;
        return contInfoRec;
    }

    public class contactInfoWrapper{
        @AuraEnabled
        public string contactName, contEmail, contPhone, userType;
        @AuraEnabled
        public list<accInfoWrapper> lstAcc;
    }

    public class accInfoWrapper{
        @AuraEnabled
        public string accName, accNum, primaryRepName;
        @AuraEnabled
        public list<addressInfoWrapper> lstShipTo;
    }

    public class addressInfoWrapper{
        @AuraEnabled
        public string shipToId, shipToName, division, shipToAddress, shipToCity, shipToState, shipToStreet, fullAddress, phoneNumber;
        @AuraEnabled public boolean isNalco;
    }

/*************************************************************************************************************************************
Method Name : formRegAPIJson
Description : Method to create the request JSON
Parameter   : Map
Return type : List
Author      : Raghav Sharma
*************************************************************************************************************************************/
    @AuraEnabled
    public static String formRegAPIJson(Map<String, String> accountAlignment){
        String AccountNumber=accountAlignment.get('AccountNumber');
        String SalesRepEmail=accountAlignment.get('SalesRepEmail');
        User user = [Select Id, ContactId, EC_CDM_User__c From User Where Id =:userinfo.getuserid()];
        String userKey = user.EC_CDM_User__c;
        EC_RegMuleSoftWrapper getValues = new EC_RegMuleSoftWrapper(AccountNumber,SalesRepEmail,userKey);
        String postJSon = JSON.serialize(getValues);
        return postJSon;
    }
     /************************************************************************************************************************************
Method Name : selfAccountAlignment
Description : To validate AccountNo. and SalesRepEmail from CDM and align Contact to particular account based upon reponse from CDM
Return type : List<EC_MulesoftIntegration_Custom_Codes__mdt>
Author      : Raghav Sharma
*************************************************************************************************************************************/

    @AuraEnabled
    public static List<EC_MulesoftIntegration_Custom_Codes__mdt> selfAccountAlignment(Map<String, String> accountAlignment){
        String methodName = 'selfAccountAlignment';
        EC_LogsEnabler__c punch =  EC_LogsEnabler__c.getValues(methodName);

        User user = [Select Id, ContactId, EC_CDM_User__c From User Where Id =:userinfo.getuserid()];
        Contact currentContact = [Select Id,AccountId from contact where id =:user.ContactId];
        String postJSon = formRegAPIJson(accountAlignment);

        EC_WebServiceCalloutsLog__c logRec = new EC_WebServiceCalloutsLog__c();
        logRec.EC_RequestName__c = EC_Constants.SELFALIGNMENT;
        logRec.EC_CodeTraverseLog__c = currentClassName + EC_Constants.classEntry;
        logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodEntry;

        logRec.EC_RequestCall__c = postJSon;

        EC_Mulesoft_Integration__c headerValues = EC_QueryUtility.getHeader(EC_Constants.SELFALIGNMENT);
        String clientId = headerValues.EC_ClientId__c;
        String clientSecret = headerValues.EC_Client_Secret__c;
        String endPointUrl = headerValues.EC_Endpoint__c;
        String content_type = System.Label.EC_CONTENT_TYPE_VALUE;
        HttpResponse response = EC_HTTPCalloutUtils.doPost(endPointUrl,postJSon, clientId, clientSecret);
        String responseCode ='';
        String message = '';
        String result = response.getBody();
        EC_RegMuleSoftWrapper wrapper_Result = (EC_RegMuleSoftWrapper) JSON.deserialize(result, EC_RegMuleSoftWrapper.class);
            responseCode = wrapper_Result.responseCode;
        List<EC_MulesoftIntegration_Custom_Codes__mdt> code = EC_QueryUtility.getCustomCodeSelfAlignment(responseCode);
        // Parse the JSON response
      if(code[0].EC_CustomCodes__c == '1001'){
            alignContactAccount(wrapper_Result, currentContact); logRec.EC_Status__c = EC_Constants.SUCCESS;logRec.EC_ResponseCall__c = result;
            logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
            logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit;insert logRec;
        }else{
            logRec.EC_Status__c = EC_Constants.failure;
            logRec.EC_ResponseCall__c = result;
            logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + methodName + EC_Constants.methodExit;
            logRec.EC_CodeTraverseLog__c = logRec.EC_CodeTraverseLog__c + EC_Constants.stringSeperater + currentClassName + EC_Constants.classExit;
            if(punch.EC_LogsEnabled__c == true){
            insert logRec;
            }
        }
        return code;

    }
     /************************************************************************************************************************************
Method Name : alignContactAccount
Description : to align account to logged in contact
Return type : void
Author      : Raghav Sharma
*************************************************************************************************************************************/

     @AuraEnabled
    public static void alignContactAccount(EC_RegMuleSoftWrapper wrapper_Result, Contact currentContact){
         try{
            String accKey = wrapper_Result.accountKey.trim();
            List<Account> accList = [Select Id,Name,RecordType.Name from Account where EC_CDM_Account__c =:accKey];
             if(accList!=null && !accList.isEmpty()){
             Account acc = accList[0];
             if(acc.RecordType.Name == 'Ship To'){
                 alignShipTo(acc,currentContact);
             }

             else if(acc.RecordType.Name == 'Sold To'){
                 alignSoldToAndRelatedShipTo(acc,currentContact);
             }
          }
        }
            catch(Exception ex){
        }
    }
 /************************************************************************************************************************************
Method Name : alignShipTo
Description : to align shipTo with logged in contact
Return type : void
Author      : Raghav Sharma
*************************************************************************************************************************************/

    public static void alignShipTo(Account acc, Contact currentContact){
        List<AccountContactRelation> updateAccContList = new List<AccountContactRelation>();
        list<AccountContactRelation> lstAccContRel = [SELECT id, accountId,IsActive,IsDirect,ContactId FROM AccountContactRelation WHERE contactId =: currentContact.Id];
        Boolean accPresent = false;
        For(AccountContactRelation accConRec : lstAccContRel){    // Checking Ship to Account
            if(accConRec.AccountId == acc.Id){
                accPresent = true;
              if(accConRec.IsActive == false){
                  accConRec.IsActive = true;
                  updateAccContList.add(accConRec);
                }

            }
        }
            update updateAccContList;
        if(!accPresent){
            AccountContactRelation accRec = new AccountContactRelation();
            accRec.AccountId = acc.Id;
            accRec.ContactId = currentContact.Id;
            accRec.IsActive = True;
            insert accrec;
        }
    }
  /************************************************************************************************************************************
Method Name : alignSoldToAndRelatedShipTo
Description : to align soldTo and related shipTo with logged in user
Return type : void
Author      : Harsha N
*************************************************************************************************************************************/
    public static void alignSoldToAndRelatedShipTo(Account acc, Contact currentContact){
        List<AccountContactRelation> updateAccContList = new List<AccountContactRelation>();
        List<AccountContactRelation> accContListInsrt = new List<AccountContactRelation>();
        List<Account> lstAccChildRec = [Select id From Account Where account.parentId =: acc.id];
        list<AccountContactRelation> lstAccContRel = [SELECT id, accountId,contactId,IsActive From AccountContactRelation WHERE contactId =: currentContact.Id];
             // Checking for Sold to Account only uses same shipto logic here
                 alignShipTo(acc,currentContact);

             // Checking for Related Child Accounts
                 Boolean accPresent = false;
             For(Account childAcc : lstAccChildRec){
                 accPresent = false;
             For(AccountContactRelation accConRec : lstAccContRel){
        if(accConRec.AccountId == childAcc.Id){
                accPresent = true;
            if(accConRec.IsActive == false){
                accConRec.IsActive = true;
                updateAccContList.add(accConRec);
            }
            }
        }
        if(!accPresent){
            AccountContactRelation accRec = new AccountContactRelation();
            accRec.AccountId = childAcc.Id;
            accRec.ContactId = currentContact.Id;
            accRec.IsActive = True;
            accContListInsrt.add(accrec);
          }
        }
         update updateAccContList;
         insert accContListInsrt;
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

    }