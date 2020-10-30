/* Class Name    : EC_cc_hk_EffectiveAccount
 * Description      :Class to extend the Cloudcraze Order Hook Controller
 * Created By       :Viraj  
 * Created On       :2019-Jun-12

 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Viraj                     2019-Jun-12        BC-75723       Created the class   
 *
 */
global with sharing class EC_cc_hk_EffectiveAccount extends ccrz.cc_hk_EffectiveAccount {
    
    /***************************************************************************************************************************************
  Method Name : fetchAccounts
  Description : fetchAccounts methods queries the sold to and ship to account to display in the effective account picker
  Return type : Returns Map<String,Object>
 *************************************************************************************************************************************/
    global override Map<String,Object> fetchAccounts(Map<String,Object> inputData){
    
        if(Cache.Session.get('local.UserCache.'+UserInfo.getUserId()+'effAccInputData') == null){   
			
            if(!Test.isRunningTest()){
            
                inputData=super.fetchAccounts(inputData);
            }           
            
            
            List<ccrz.cc_bean_EffectiveAccount> effAcctBeans =  new List<ccrz.cc_bean_EffectiveAccount>();
            
            List<ccrz.cc_bean_EffectiveAccount> effAcctBeansOut = new List<ccrz.cc_bean_EffectiveAccount>();
            
            
            List<Contact> currContact = new List<Contact>();
            String accountID;
            String effaccountID;
            
            User loggedInUser = [Select Id, User_Type__c FROM User WHERE Id =:UserInfo.getUserId()];
            if(loggedInUser.User_Type__c==null || loggedInUser.User_Type__c.EqualsIgnoreCase('external')){
                effaccountID = ccrz.cc_CallContext.effAccountId;
                currContact.add(CCRZ.cc_CallContext.currContact);
                accountID = ccrz.cc_CallContext.currAccountId;
                    
            }
            else
            {
                effaccountID = ccrz.cc_CallContext.effAccountId;
                currContact = [Select Id FROM Contact WHERE EC_SalesRep_User__c=:UserInfo.getUserId()];//'0036A00000RTWCm';
                accountID = effaccountID;
            }
			
            List<Account> relatedAccountList = new List<Account>();
            List<AccountContactRelation> relatedAccounts = new List<AccountContactRelation>();
			List<Account> shipToAccountList = new List<Account>();
            List<String> soldToAccIds = new List<String>();
			List<String> shipToAccIds = new List<String>();

            if(currContact.size()>0){
                relatedAccounts = [SELECT accountId,contactId, Account.Name,Account.AccountNumber,Account.RecordTypeId, Account.EC_Division__c,Account.EC_SalesRepresentative__c,Account.EC_SalesRepresentative__r.Name,Account.RecordType.Name,Account.Phone,Account.EC_Status__c,Account.EC_Account_Number__c,Account.ParentId,Account.ShippingStreet,Account.ShippingCity,Account.ShippingState,Account.ShippingPostalCode,Account.ShippingCountry,Account.BillingStreet, Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.Ship_To_Name__c FROM AccountContactRelation where contactId = :currContact[0].id and Account.EC_Status__c != 'Inactive' and (Account.RecordType.Name = :Label.EC_Account_ShipTo or Account.RecordType.Name = :Label.EC_Account_SoldTo) ORDER BY Account.Name];
            }
            
			integer numAccounts = 0;
			//Map of account Id and primary sales rep name
			Map<Id,String> acctIdPriSalesRepMapShipTo = new Map<Id,String>();
			Map<Id,String> acctIdPriSalesRepMapSoldTo = new Map<Id,String>();
             
            for(AccountContactRelation accOb: relatedAccounts){
				if(accOb.Account.RecordType.Name == Label.EC_Account_ShipTo){
					shipToAccountList.add(accOb.Account);
                    shipToAccIds.add(accOb.accountId);
				}else{
					relatedAccountList.add(accOb.Account);
					soldToAccIds.add(accOb.accountId);
				}
				numAccounts++;
            }
            if(shipToAccIds.size() > 0)
				acctIdPriSalesRepMapShipTo = getAccountPrimaryRepMap(shipToAccIds);
             if(soldToAccIds.size() > 0)
				acctIdPriSalesRepMapSoldTo = getAccountPrimaryRepMap(soldToAccIds);           
            
            ccrz.ccLog.log('relatedAccountList '+relatedAccountList);
            
            ccrz.ccLog.log('shipToAccountList'+shipToAccountList);

            ccrz.cclog.log('soldToAccIds:'+soldToAccIds);
			
            List<Account> tempAccList = new List<Account>();
            Map<String,List<Account>> soldToShipToMap = new Map<String,List<Account>>();
            List<Account> shipToAcc = new List<Account>();
            
            Map<String,Object> effShipToAddr = new Map<String,Object>();
            List<Map<String,Object>> effShipToAddrList = new List<Map<String,Object>>();
            Map<String,Object> extrinsicMap = new Map<String,Object>();
            
            String addressString='';
            String accId;
            String[] shipToNumber;
            
            Boolean corpAcc = true;
            
            for(Account accOb : shipToAccountList){
            
                ccrz.cc_bean_EffectiveAccount customBean = new ccrz.cc_bean_EffectiveAccount(accOb);
                extrinsicMap = new Map<String,Object>();
                effShipToAddrList = new List<Map<String,Object>>();
                corpAcc = true;
                tempAccList = new List<Account>();
                
                ccrz.cclog.log('soldToShipToMap.containsKey:'+soldToShipToMap.containsKey(accOb.ParentId));

                if(soldToShipToMap.containsKey(accOb.ParentId)){
                
					tempAccList = soldToShipToMap.get(accOb.ParentId);
                    tempAccList.add(accOb);
                    soldToShipToMap.put(accOb.ParentId,tempAccList);
                    
                }else{
                
                    tempAccList.add(accOb);
                    
                    if(soldToAccIds.contains(accOb.ParentId)){
                        corpAcc = false;
                    }
                    
                    ccrz.cclog.log('Inside else accOb.ParentId:'+accOb.ParentId);
                    ccrz.cclog.log('corpAcc:'+corpAcc);
                    if(accOb.ParentId == null || corpAcc == true){
                        
                        effShipToAddr = new Map<String,Object>();
                        effShipToAddr.put('shipCity',accOb.ShippingCity);
                        effShipToAddr.put('shipState',accOb.ShippingState);
                        effShipToAddr.put('zipCode',accOb.ShippingPostalCode);
                        addressString = accOb.ShippingStreet;
                        effShipToAddr.put('searchString',accOb.name+','+addressString+','+accOb.EC_Account_Number__c);
                        effShipToAddr.put('address',addressString);
                        effShipToAddr.put('shipCountry',accOb.ShippingCountry);
                        effShipToAddr.put('name',accOb.Name);
                        effShipToAddr.put('shipToID',accOb.EC_Account_Number__c);
                        effShipToAddr.put('shipToName',accOb.Ship_To_Name__c);
                        effShipToAddr.put('sfid',accOb.id);
                        effShipToAddr.put('isValidAccount',1);
                        effShipToAddrList.add(effShipToAddr);
                        extrinsicMap.put('shipToType','loneShipTO');
                        extrinsicMap.put('zipCode',accOb.ShippingPostalCode);      
                        addressString = accOb.ShippingStreet;
                        extrinsicMap.put('searchString',accOb.Name+','+addressString+','+accOb.EC_Account_Number__c );
                        extrinsicMap.put('shipToAccounts',effShipToAddrList);
                        extrinsicMap.put('shipState',accOb.ShippingState);
                        extrinsicMap.put('shipCity',accOb.ShippingCity);
                        extrinsicMap.put('shipCountry',accOb.ShippingCountry);
                        extrinsicMap.put('address',addressString);
                        extrinsicMap.put('accountType',accOb.RecordType.Name);
                        extrinsicMap.put('phone',accOb.Phone);
						extrinsicMap.put('isCount','1');
                        extrinsicMap.put('isDisplay','true');
                        if(accOb.EC_Account_Number__c!=null && accOb.EC_Account_Number__c!=''){
                            shipToNumber = accOb.EC_Account_Number__c.split('/');
                            if(shipToNumber.size()>0){
                                extrinsicMap.put('accountNumber',shipToNumber[0]);
                            }
                        }
                        extrinsicMap.put('name',accOb.Name);
                        extrinsicMap.put('sfid',accOb.id);
                        extrinsicMap.put('accountDivision',accOb.EC_Division__c);    
                        extrinsicMap.put('primaryRepName', getPrimaryRep(accOb.id, acctIdPriSalesRepMapShipTo));  //PBI-121283
                        extrinsicMap.put('currUserId',ccrz.cc_CallContext.currUserId);
                        customBean.extrinsic = extrinsicMap;
                        effAcctBeansOut.add(customBean);
                        
                        continue;
                        
                    }
                    soldToShipToMap.put(accOb.ParentId,tempAccList);
                }
                
                extrinsicMap.put('accountType',accOb.RecordType.Name);
                extrinsicMap.put('accountDivision',accOb.EC_Division__c);                                                        
                extrinsicMap.put('shipToID',accOb.EC_Account_Number__c);
                extrinsicMap.put('name',accOb.Name);
                extrinsicMap.put('sfid',accOb.id);
                extrinsicMap.put('currUserId',ccrz.cc_CallContext.currUserId);
                customBean.extrinsic = extrinsicMap;
                effAcctBeansOut.add(customBean);
                
            }
            ccrz.ccLog.log('soldToShipToMap'+soldToShipToMap);
            system.debug('soldToShipToMap'+soldToShipToMap);
            
            for(Account account : relatedAccountList){
                
                ccrz.cc_bean_EffectiveAccount customBean = new ccrz.cc_bean_EffectiveAccount(account);
                effShipToAddrList = new List<Map<String,Object>>();
                extrinsicMap = new Map<String,Object>();
                accId=account.id;
                if(account.EC_Division__c == System.Label.EC_Account_FoodAndBeverage){
				
					effShipToAddr = new Map<String,Object>();
					effShipToAddr.put('shipCity',account.ShippingCity);
                    effShipToAddr.put('shipState',account.ShippingState);
                    effShipToAddr.put('zipCode',account.ShippingPostalCode);
					addressString = account.ShippingStreet;
					effShipToAddr.put('searchString',account.name+','+addressString+','+account.EC_Account_Number__c);
					effShipToAddr.put('address',addressString);
					effShipToAddr.put('shipCountry',account.ShippingCountry);
					effShipToAddr.put('name',account.Name);
					extrinsicMap.put('accountDivision',account.EC_Division__c);                                                        
					effShipToAddr.put('shipToID',account.EC_Account_Number__c);
					effShipToAddr.put('phone',account.Phone);
					effShipToAddr.put('sfid',account.id);
                    effShipToAddr.put('isValidAccount',1);
					effShipToAddrList.add(effShipToAddr);
					
				}else if(soldToShipToMap.containsKey(accId)){
                    shipToAcc = soldToShipToMap.get(accId);
                    for(Account accOb : shipToAcc){
                        effShipToAddr = new Map<String,Object>();
                        effShipToAddr.put('shipCity',accOb.ShippingCity);
                        effShipToAddr.put('shipState',accOb.ShippingState);
                        effShipToAddr.put('zipCode',accOb.ShippingPostalCode);
                        addressString = accOb.ShippingStreet;
                        effShipToAddr.put('searchString',accOb.name+','+addressString+','+accOb.EC_Account_Number__c);
                        effShipToAddr.put('address',addressString);
                        effShipToAddr.put('shipCountry',accOb.ShippingCountry);
                        effShipToAddr.put('name',accOb.Name);
                        extrinsicMap.put('accountDivision',accOb.EC_Division__c);                                                        
                        effShipToAddr.put('shipToID',accOb.EC_Account_Number__c);
                        effShipToAddr.put('shipToName',accOb.Ship_To_Name__c);
                        effShipToAddr.put('phone',accOb.Phone);
                        effShipToAddr.put('sfid',accOb.id);
                        effShipToAddr.put('isValidAccount',1);
                        effShipToAddrList.add(effShipToAddr);
                    }
                    
                }else{
                    continue;
                }
                
                extrinsicMap.put('zipCode',account.ShippingPostalCode);
                addressString = account.ShippingStreet;
                extrinsicMap.put('searchString',account.Name+','+addressString+','+account.EC_Account_Number__c );
                extrinsicMap.put('shipToAccounts',effShipToAddrList);
                extrinsicMap.put('shipState',account.ShippingState);
                extrinsicMap.put('shipCity',account.ShippingCity);
                extrinsicMap.put('shipCountry',account.ShippingCountry);
                extrinsicMap.put('address',addressString);
                extrinsicMap.put('name',account.Name);
                extrinsicMap.put('accountType',account.RecordType.Name);
                extrinsicMap.put('accountDivision',account.EC_Division__c);
                extrinsicMap.put('currUserId',ccrz.cc_CallContext.currUserId);
				extrinsicMap.put('isCount','2');
                extrinsicMap.put('isDisplay','true');
                extrinsicMap.put('sfid',account.id);
                extrinsicMap.put('accountNumber',account.EC_Account_Number__c);
                extrinsicMap.put('primaryRepName', getPrimaryRep(account.Id, acctIdPriSalesRepMapSoldTo));  //PBI-121283
                customBean.extrinsic = extrinsicMap;
                effAcctBeansOut.add(customBean);
            }
			//Sorting Removed because of performance issues
            /*List<ccrz.cc_bean_EffectiveAccount> sortedEffAccs = new List<ccrz.cc_bean_EffectiveAccount>();
            String name;
            String tempName;
            integer indexToAdd = -1;
            
			for(ccrz.cc_bean_EffectiveAccount effAcc : effAcctBeansOut){
				indexToAdd=-1;
				name = (String) effAcc.extrinsic.get('name');
				for(integer  i=0;i<sortedEffAccs.size();i++){
					tempName = (String) sortedEffAccs[i].extrinsic.get('name');
					if(tempName.toLowerCase().compareTo(name.toLowerCase()) > 0){
						indexToAdd=i;
						break;
					}
				}
				if(indexToAdd>-1){
					sortedEffAccs.add(indexToAdd,effAcc);
				}else{
					sortedEffAccs.add(effAcc);
				}
			}*/
            
            inputData.put(PARAM_EFFACCOUNT_LIST, effAcctBeansOut);
            ccrz.cclog.log('final-->'+inputData);
            
            if(numAccounts < 500){
            Cache.Session.put('local.UserCache.'+UserInfo.getUserId()+'effAccInputData',inputData);
            }
            ccrz.cclog.log('aftercache-->'+inputData);
            return inputData;
        }else{
            return (Map<String,Object>) Cache.Session.get('local.UserCache.'+UserInfo.getUserId()+'effAccInputData');
        }
    }
    
    /***************************************************************************************************************************************
    Method Name : getPrimaryRep
    Description : Returns primaryRepName
    Return type : string
    PBI         : 121283
    **************************************************************************************************************************************/
    private static string getPrimaryRep(Id accountId, Map<Id,String> acctIdPriSalesRepMap ){
        return acctIdPriSalesRepMap.get(accountId);
    }
    
    private static Map<Id,String> getAccountPrimaryRepMap(List<String> ids){
        Map<Id, String> accountIdPriSalesRepMap = new Map<Id,String>();
        List<String> accountListToGetSalesRep = new List<String>();      
        ccrz.cclog.log('Inside getAccountPrimaryRepMap. Size is -->'+ ids.size());
        //Retrieve the Sales Reps if directly available on the account. 
        List<Account> salesRepList = new List<Account>();
        if (Account.sObjectType.getDescribe().isAccessible()) {
            salesRepList = [select Id, EC_SalesRepresentative__r.name, EC_CDM_Account__c from account where id IN :ids ];		
        }
        for(Account account: salesRepList)	{
            //check if the sales rep field is not empty. If so, put the account id and sales rep info in the map. Otherwise
            //add the account id to the list of accounts that we need to get sales reps from accountcontactrelation.
            if(String.isBlank(account.EC_SalesRepresentative__r.name)){
                accountListToGetSalesRep.add(account.Id);
            }else{
                accountIdPriSalesRepMap.put(account.Id, account.EC_SalesRepresentative__r.name);
            }           	 
        }

        if(!accountListToGetSalesRep.isEmpty()){
            ccrz.cclog.log('getAccountPrimaryRepMap. Found accounts with no Sales Reps Assigned -->'+ accountListToGetSalesRep.size());
            ccrz.cclog.log('getAccountPrimaryRepMap. Accounts with no Sales Reps Assigned -->'+ accountListToGetSalesRep);
            //First get the accountcontactrelation ids. The below query will only fetch one record per account Id. Adding
            //account Id in this query will fetch multiple records per account id depending on the data	
            
            List<AggregateResult> accountContactAggrList = new List<AggregateResult>();
            if (AccountContactRelation.sObjectType.getDescribe().isAccessible()) {
                accountContactAggrList = [SELECT MAX(Id) Identifier, contact.FirstName, contact.LastName
                                          FROM AccountContactRelation
                                          WHERE accountId IN :accountListToGetSalesRep
                                          AND Alignment_Type__c =: EC_Constants.PRIMARY_ALIGNMENT_TYPE
                                          GROUP BY contact.FirstName, contact.LastName];   
            }
            
            List<String> acctContRelList = new List<String>();
            for(AggregateResult aggrItem: accountContactAggrList){ 
                acctContRelList.add((id)aggrItem.get('Identifier'));  
            }
            ccrz.cclog.log('getAccountPrimaryRepMap. AccountContactRelation rec ids for accounts with no sales rep assigned -->'+ acctContRelList.size());
            
            //Now get the required data of account Id, contact first name and last name based on the rec ids above
            List<AccountContactRelation> accountContactRelList = new List<AccountContactRelation>();
            if (AccountContactRelation.sObjectType.getDescribe().isAccessible()) {
                accountContactRelList = [SELECT accountId, contact.FirstName, contact.LastName
                                         FROM AccountContactRelation
                                         WHERE id IN :acctContRelList];
            }
            
            for(AccountContactRelation accountContactRelItem: accountContactRelList){ 
                accountIdPriSalesRepMap.put(accountContactRelItem.accountId, accountContactRelItem.contact.FirstName + ' ' + accountContactRelItem.contact.LastName);  
            }
            ccrz.cclog.log('getAccountPrimaryRepMap. Accounts with no Sales Reps Assigned -->'+ accountContactRelList.size());
            
        }
        ccrz.cclog.log('getAccountPrimaryRepMap. Final list account and sales rep info -->'+ accountIdPriSalesRepMap);
        return accountIdPriSalesRepMap;
    }
    
    /***************************************************************************************************************************************
  Method Name : saveCart
  Description : savecart updates the carts Bill To Ship To Addresses
  Return type : Returns Map<String,Object
 **************************************************************************************************************************************/
    global override Map<String,Object> saveCart(Map<String,Object> inputData) {
    
            ccrz.ccLog.log('savecart');
            if(!ccrz__E_Cart__c.sObjectType.getDescribe().isAccessible()) {
                return inputData;
            }
            List<ccrz__E_Cart__c> cartData = [SELECT id,ccrz__EffectiveAccountID__c,EC_Ship_To_Account__c,EC_Sold_To_Account__c,ccrz__EncryptedId__c,ccrz__ShipTo__c,ccrz__BillTo__c from ccrz__E_Cart__c where ccrz__EncryptedId__c = :CCRZ.cc_CallContext.currCartId or id =:CCRZ.cc_CallContext.currCartId LIMIT 1];
            
            if(cartData.size()>0){
                String prevEffAcc = cartData[0].ccrz__EffectiveAccountID__c;
                cartData[0].ccrz__EffectiveAccountID__c = ccrz.cc_CallContext.effAccountId;
                
                List<Account> accountList = new List<Account>();
                if(cartData[0].EC_Ship_To_Account__c !=null || cartData[0].EC_Sold_To_Account__c!=null){
                    accountList = [SELECT id,EC_Account_Number__c,Ship_To_Name__c,BillingAddress,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,ShippingAddress,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet from Account where id=:cartData[0].EC_Ship_To_Account__c or id=:cartData[0].EC_Sold_To_Account__c];
                }
                
                Map<String,Object> accountNumberMap = new Map<String,Object>();
                String accType ='';
                String shipAccountId='';   
                
                for(Account accOb : accountList){
                    if(accOb.id == cartData[0].EC_Ship_To_Account__c){
                        accType = 'ShipTo';
                        shipAccountId = accOb.id;                   
                        accountNumberMap.put(accType,accOb);
                    }
                    if(accOb.id == cartData[0].EC_Sold_To_Account__c){
                        accType = 'SoldTo';
                        accountNumberMap.put(accType,accOb);
                    }
                    
                }
                
                List<ccrz__E_AccountAddressBook__c > addressBookList = [Select id,ccrz__E_ContactAddress__c,ccrz__E_ContactAddress__r.ccrz__AddressFirstline__c,ccrz__E_ContactAddress__r.ccrz__AddressSecondline__c,ccrz__E_ContactAddress__r.ccrz__AddressThirdline__c,ccrz__E_ContactAddress__r.EC_Account_Number__c,ccrz__E_ContactAddress__r.ccrz__Country__c,ccrz__E_ContactAddress__r.ccrz__PostalCode__c,ccrz__E_ContactAddress__r.ccrz__State__c,ccrz__E_ContactAddress__r.ccrz__City__c from ccrz__E_AccountAddressBook__c where ccrz__Account__C =:shipAccountId  ];
                
                List<String> conAddrIdList = new List<String>();
                
                for(ccrz__E_AccountAddressBook__c accAddr : addressBookList){
                    conAddrIdList.add(accAddr.ccrz__E_ContactAddress__c);
                }
                
                List<ccrz__E_ContactAddr__c> contactAddrLst = new List<ccrz__E_ContactAddr__c>();
                if(cartData[0].ccrz__BillTo__c!=null || cartData[0].ccrz__ShipTo__c!=null){
                    contactAddrLst = [Select Name,EC_Account_Number__c,ShipTo_Name__c,ccrz__AddressFirstline__c, ccrz__AddressSecondline__c,ccrz__AddressThirdline__c,ccrz__AddrReadOnly__c,ccrz__City__c, ccrz__CompanyName__c,ccrz__ContactAddrId__c,ccrz__Partner_Id__c,ccrz__Country__c,ccrz__CountryISOCode__c,ccrz__DaytimePhone__c,ccrz__Email__c,ccrz__FirstName__c,ccrz__HomePhone__c,ccrz__LastName__c,ccrz__MailStop__c,ccrz__MiddleName__c,ccrz__PostalCode__c,ccrz__ShippingComments__c,ccrz__State__c,ccrz__StateISOCode__c from ccrz__E_ContactAddr__c where Id in :conAddrIdList or id=:cartData[0].ccrz__ShipTo__c or id=:cartData[0].ccrz__BillTo__c or ccrz__Partner_Id__c = :String.valueOf(ccrz.cc_CallContext.effAccountId) + '-' + String.valueOf(cartData[0].id)];
                }
                
                update cartData[0];  
                
                for(ccrz__E_ContactAddr__c contFor : contactAddrLst){
                    if(contFor.id == cartData[0].ccrz__ShipTo__c && accountNumberMap.containsKey('ShipTo')){
                        Account accOb = (Account)accountNumberMap.get('ShipTo');
                        
                        contFor.ccrz__AddressFirstline__c = accOb.ShippingStreet;
                        contFor.ccrz__City__c = accOb.ShippingCity;
                        contFor.ccrz__State__c = accOb.ShippingState;
                        contFor.ccrz__Country__c = accOb.ShippingCountry;
                        contFor.ccrz__PostalCode__c = accOb.ShippingPostalCode;
                        contFor.ShipTo_Name__c = accOb.Ship_To_Name__c;
                        contFor.EC_Account_Number__c = accOb.EC_Account_Number__c;
                        
                    }else if(contFor.id == cartData[0].ccrz__BillTo__c && accountNumberMap.containsKey('SoldTo')){
                        
                        if(addressBookList.size()>0){
                            for(ccrz__E_ContactAddr__c contForInner : contactAddrLst){
                                if(contForInner.id != cartData[0].ccrz__ShipTo__c && contForInner.id != cartData[0].ccrz__BillTo__c){
                                    
                                    contFor.ccrz__Partner_Id__c = contForInner.ccrz__ContactAddrId__c;
                                    contFor.ccrz__AddressFirstline__c = contForInner.ccrz__AddressFirstline__c;
                                    contFor.ccrz__AddressSecondline__c = contForInner.ccrz__AddressSecondline__c;
                                    contFor.ccrz__AddressThirdline__c = contForInner.ccrz__AddressThirdline__c;
                                    contFor.ccrz__City__c = contForInner.ccrz__City__c;
                                    contFor.ccrz__CompanyName__c = contForInner.ccrz__CompanyName__c;
                                    contFor.ccrz__AddressFirstline__c = contForInner.ccrz__AddressFirstline__c;
                                    contFor.ccrz__Country__c = contForInner.ccrz__Country__c;
                                    contFor.ccrz__CountryISOCode__c = contForInner.ccrz__CountryISOCode__c;
                                    contFor.ccrz__DaytimePhone__c = contForInner.ccrz__DaytimePhone__c;
                                    contFor.ccrz__Email__c = contForInner.ccrz__Email__c;
                                    contFor.ccrz__FirstName__c = contForInner.ccrz__FirstName__c;
                                    contFor.ccrz__HomePhone__c = contForInner.ccrz__HomePhone__c;
                                    contFor.ccrz__LastName__c = contForInner.ccrz__LastName__c;
                                    contFor.ccrz__MailStop__c = contForInner.ccrz__MailStop__c;
                                    contFor.ccrz__MiddleName__c = contForInner.ccrz__MiddleName__c;
                                    contFor.ccrz__PostalCode__c = contForInner.ccrz__PostalCode__c;
                                    contFor.ccrz__ShippingComments__c = contForInner.ccrz__ShippingComments__c;
                                    contFor.ccrz__State__c = contForInner.ccrz__State__c;
                                    contFor.ccrz__StateISOCode__c = contForInner.ccrz__StateISOCode__c;
                                    break;
                                }
                            }
                        }else{
                            Account accOb = (Account)accountNumberMap.get('SoldTo');
                            
                            contFor.ccrz__AddressFirstline__c = accOb.BillingStreet;
                            contFor.ccrz__City__c = accOb.BillingCity;
                            contFor.ccrz__State__c = accOb.BillingState;
                            contFor.ccrz__Country__c = accOb.BillingCountry;
                            contFor.ccrz__PostalCode__c = accOb.BillingPostalCode;
                            
                            contFor.EC_Account_Number__c = accOb.EC_Account_Number__c;
                        }
                        
                    }
                }
                
                update contactAddrLst;
                
                
            }
            return inputData;
    }

}